; *************************************************************************************
;
; Level G: 'BALLOONACY'
;
; Save game variables:
;
;     save_game_level_g_got_bow_or_arrow_in_flight_progress ($0a17):
;               0: not got bow
;              1+: arrow is in flight
;             $ff: bow is ready to fire arrow
;
;     save_game_level_g_dropped_table_progress ($0a18):
;               0: table suspended
;              1+: table falling (y position)
;             $ff: table fully fallen
;
;     save_game_level_g_baby_progress ($0a19):
;               0: not started
;              1+: animations in progress (an animation index)
;             $1b: dead (also an animation index)
;
; Solution:
;
;   1. Move left into the room with the two balloons on short pieces of rope. Hang from one
;      and jump off at the appropriate time to continue left to the leftmost room.
;   2. Navigate the balloon and ropes to get to the bow in the top left corner.
;   3. Go back to the start room, and fire the bow at the balloon above the suspended table.
;      (The table falls)
;   4. As the cat, climb over the table and into the rightmost room.
;   5. Shoot the baby/imp with the arrow, to clear the way for you to get to the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_arrow                        = 2
objectid_baby                         = 5
objectid_balloon1                     = 3
objectid_balloon1_rope                = 4
objectid_balloon2                     = 5
objectid_balloon2_rope                = 6
objectid_bow                          = 2
objectid_spell                        = 6
objectid_table                        = 5
objectid_table_rope                   = 6
spriteid_arrow                        = 204
spriteid_baby                         = 212
spriteid_baby_dead                    = 215
spriteid_baby_fall                    = 214
spriteid_baby_push                    = 217
spriteid_baby_surprise                = 213
spriteid_balloon                      = 200
spriteid_bow                          = 202
spriteid_bow_menu_item                = 203
spriteid_burst_balloon                = 211
spriteid_erase_cache1                 = 205
spriteid_erase_cache2                 = 207
spriteid_rope_bottom                  = 208
spriteid_rope_end1                    = 201
spriteid_rope_top                     = 209
spriteid_rope_top_broken              = 210
spriteid_table                        = 206
spriteid_wood_block                   = 216

; Memory locations
room_exit_direction                                     = &0070
temp_player_x                                           = &0070
object_left_cell_x                                      = &0078
object_right_cell_x                                     = &0079
save_game_level_g_got_bow_or_arrow_in_flight_progress   = &0a17
save_game_level_g_dropped_table_progress                = &0a18
save_game_level_g_baby_progress                         = &0a19
arrow_direction                                         = &0a6f
arrow_x_position_low                                    = &0a70
arrow_x_position_high                                   = &0a71
arrow_y_position_low                                    = &0a72
arrow_room                                              = &0a73
arrow_active_progress                                   = &0a74
room_1_left_hand_balloon_y_position                     = &0a75
room_1_right_hand_balloon_y_position                    = &0a76
room_3_balloon_y_position                               = &0a77
room_0_balloon_y_position                               = &0a78
room_3_baby_animation_step                              = &0a79
room_3_baby_y_position                                  = &0a7a

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelG_sprite_table - level_data
ELSE
    EQUW sprite_data - level_data
ENDIF
.level_specific_initialisation_ptr
    equw level_specific_initialisation                                ; address of level initialisation code
.level_specific_update_ptr
    equw level_specific_update                                        ; address of level update code
.level_specific_password_ptr
    equw level_specific_password                                      ; address of level password
.initial_room_index
    equb 2
.initial_room_index_cheat
    equb 3
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "BALLOONACY", &0D

; *************************************************************************************
; 
; Level initialisation
; 
; This is called whenever a new room is entered.
; 
; *************************************************************************************
; check for level change (branch if not)
.level_specific_initialisation
IF swr_renderer_enabled
    JSR swr_level_initialise
ENDIF
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq return1
    lda developer_flags
    bpl developer_mode_inactive
    lda #&ff
    sta save_game_level_g_got_bow_or_arrow_in_flight_progress
.developer_mode_inactive
    lda save_game_level_g_got_bow_or_arrow_in_flight_progress
    beq return1
    lda #spriteid_bow_menu_item
    jsr find_or_create_menu_slot_for_A
.return1
    rts

; *************************************************************************************
; 
; Level update
; 
; This generally calls individual functions to update the logic in each room.
; 
; While updating the logic for a room, 'currently_updating_logic_for_room_index' is
; normally set. In practice this only actually needs to be set if it calls
; 'update_brazier_and_fire' or 'update_level_completion'
; 
; *************************************************************************************
.level_specific_update
    jsr room_0_update_handler
    jsr room_1_update_handler
    jsr room_2_update_handler
    jsr room_3_update_handler
    rts

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 19                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |   #####                      ###
; ###   |   #####                      ###
; ###   |     ###                      ###
; ###   |     ###                      ###
; ###   |     ###                      ###
; ###   |     ###                      ###
; ###   |     ###                      ###
; ###   |     ###                      ###
; ###   |     ###                      ###
;       |                      ###
;       |                      ###
;       |                      ###
;                        OOOOOO###
;                    P   OOOOOO###
; ########################################
; ########################################
; set ground fill tile to use
.room_2_code
    lda #<ground_fill_2x2_top_left
    sta source_sprite_memory_low
    lda #>ground_fill_2x2_top_left
    sta source_sprite_memory_high
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (37,2)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (29,17)
    ldx #&1d
    ldy #&11
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (12,8)
    ldx #&0c
    ldy #8
    lda #9
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 2x2 rectangle at (10,8)
    ldx #&0a
    lda #2
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw wood block at (23,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&17
    ldy #&14
    lda #spriteid_wood_block
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (26,20) of size (3x2)
    ldx #&1a
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (6,2) length 18
    ldx #6
    ldy #2
    lda #&12
    jsr draw_rope
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_2_check_right_exit
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.room_2_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_2_game_update_loop
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    lda #6
    ldx #&0f
    ldy #&0c
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_table_not_first_update
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_if_room_2
    lda save_game_level_g_dropped_table_progress
    beq initialise_if_room_2
    lda #&ff
    sta save_game_level_g_dropped_table_progress
.initialise_if_room_2
    lda desired_room_index
    cmp #2
    bne update_balloon_bursting_local
; initialise room 2
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    lda #spriteid_erase_cache2
    sta object_erase_type + objectid_balloon1_rope
    lda #&c0
    sta object_z_order + objectid_balloon1_rope
    lda #&bf
    sta object_z_order + objectid_balloon1
    lda #spriteid_table
    sta object_spriteid + objectid_table
.update_balloon_bursting_local
    jmp update_balloon_bursting

.return2_local
    jmp return2

.update_table_not_first_update
    lda save_game_level_g_dropped_table_progress
    bmi return2_local
    cmp #9
    bcs continue_dropping_table
    cmp #1
    beq start_dropping_table
    lda desired_room_index
    cmp #2
    bne return2_local
; check for arrow colliding with balloon
    ldx #objectid_arrow
    ldy #objectid_balloon1
    jsr test_for_collision_between_objects_x_and_y
    beq return2_local
    inc save_game_level_g_dropped_table_progress
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    jmp update_balloon_bursting

.start_dropping_table
    lda #9
    sta save_game_level_g_dropped_table_progress
.continue_dropping_table
    ldy save_game_level_g_dropped_table_progress
    sty dropped_table_y
    cpy #&12
    bcc table_dropping_in_progress
; finished dropping table
    lda #&ff
    sta save_game_level_g_dropped_table_progress
    jmp update_balloon_bursting

.table_dropping_in_progress
    iny
    sty save_game_level_g_dropped_table_progress
    cpy #&12
    bcc write_fallen_table_to_collision_map
; are we in room 2? branch if not
    lda desired_room_index
    cmp #2
    bne write_fallen_table_to_collision_map
; play table landing sounds
    lda #0
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
.write_fallen_table_to_collision_map
    lda desired_room_index
    cmp #2
    bne return2_local
    ldx #&1a
    ldy dropped_table_y
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
; read collision map and skip if already written
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq update_balloon_bursting
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.update_balloon_bursting
    lda desired_room_index
    cmp #2
    bne return2
    lda save_game_level_g_dropped_table_progress
    bmi end_of_table_falling
    cmp #9
    bcs end_of_balloon
    cmp #1
    beq burst_the_balloon
    lda #spriteid_balloon
    sta object_spriteid + objectid_balloon1
    lda #spriteid_rope_bottom
    sta object_spriteid + objectid_balloon1_rope
    ldy #9
    jmp update_table_and_rope_objects

.burst_the_balloon
    lda #spriteid_burst_balloon
    sta object_spriteid + objectid_balloon1
    lda #spriteid_rope_top
    sta object_spriteid + objectid_balloon1_rope
    ldy #9
    jmp update_table_and_rope_objects

.end_of_balloon
    tay
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_balloon1
    lda #spriteid_rope_top
    sta object_spriteid + objectid_balloon1_rope
    jmp update_table_and_rope_objects

.end_of_table_falling
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_balloon1
    lda #spriteid_rope_top_broken
    sta object_spriteid + objectid_balloon1_rope
    ldy #&12
.update_table_and_rope_objects
    ldx #&1a
    lda #objectid_table
    jsr set_object_position_from_cell_xy
    lda #objectid_balloon1_rope
    jsr set_object_position_from_cell_xy
    lda #8
    sta temp_sprite_x_offset
    lda #&f4
    sta temp_sprite_y_offset
    lda #3
    jsr set_object_position_from_cell_xy
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return2
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return2
    rts

.dropped_table_y
    equb 0
; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ###   |         |                    ###
; ###   |         |                    ###
; ###   |         |                    ###
; ###   |         |                    ###
; ###   |         |                    ###
; ###   |         |                    ###
; ###   |         |   ####################
; ###   |         |   ####################
; ###   |                     |        ###
; ###   |                     |        ###
; ###   |                     |        ###
; ###                         |        ###
; ###                         |        ###
; ########       ##########   |   ########
; ########       ##########   |   ########
;                             |        ###
;                             |        ###
;                             |        ###
;                                      ###
;                     P                ###
; ########################################
; ########################################
; set ground fill tile to use
.room_3_code
    lda #<ground_fill_2x2_top_left
    sta source_sprite_memory_low
    lda #>ground_fill_2x2_top_left
    sta source_sprite_memory_high
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x20 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (20,8)
    ldx #&14
    ldy #8
    lda #&11
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    lda #5
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (32,15)
    ldx #&20 ; ' '
    jsr copy_rectangle_of_memory_to_screen
; draw 10x2 rectangle at (15,15)
    ldx #&0f
    lda #&0a
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (6,2) length 11
    ldx #6
    ldy #2
    lda #&0b
    jsr draw_rope
; draw rope at (16,2) length 8
    ldx #&10
    lda #8
    jsr draw_rope
; draw rope at (28,10) length 10
    ldx #&1c
    ldy #&0a
    lda #&0a
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_3_game_update_loop
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

; Baby animations. Each frame of animation is two bytes, the first byte for the sprite
; id and the second for the Y offset. Each animation is zero terminated.
.baby_animations
    equb 0
.baby_holding_rope_animation
    equb spriteid_baby
    equb 0, 0
.baby_push_animation
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0
    equb spriteid_baby_push
    equb 0, 0
.baby_surprise_animation
    equb spriteid_baby_surprise
    equb 0, 0
.baby_fall_animation
    equb spriteid_baby_fall
    equb 8, 0
.baby_dead_animation
    equb spriteid_baby_dead
    equb 0, 0

.room_3_update_handler
    lda #3
    sta currently_updating_logic_for_room_index
    lda #objectid_spell
    ldx #&22 ; '"'
    ldy #8
    jsr update_level_completion
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_3_update_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq same_level_new_room
; initialise baby progress, or set the baby progress to done if enough if in mid
; animation
    ldy #baby_holding_rope_animation - baby_animations
    lda save_game_level_g_baby_progress
    beq initialise_baby_progress
    cmp #baby_holding_rope_animation - baby_animations
    beq initialise_baby_progress
    ldy #baby_dead_animation - baby_animations
.initialise_baby_progress
    sty save_game_level_g_baby_progress
    sty room_3_baby_animation_step
; branch if not in room 3
.same_level_new_room
    lda desired_room_index
    cmp #3
    bne nothing_to_initialise
; define envelope for room 3
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
; set X position of baby and erase sprite
    lda #spriteid_erase_cache2
    sta object_erase_type + objectid_baby
    lda #&58 ; 'X'
    sta object_x_low + objectid_baby
.nothing_to_initialise
    jmp set_baby_object_sprite_if_in_room_3

; increment the animation step, and loop if at end
.room_3_update_not_first_update
    lda room_3_baby_animation_step
    clc
    adc #2
    tay
    lda baby_animations,y
    cmp #0                                                            ; redundant instruction
    bne got_next_animation_step_in_y
; set current step to start of baby animation
    ldy save_game_level_g_baby_progress
.got_next_animation_step_in_y
    lda save_game_level_g_baby_progress
    cmp #baby_holding_rope_animation - baby_animations
    beq baby_is_holding_rope
    cmp #baby_fall_animation - baby_animations
    beq baby_is_falling
    jmp reset_sound_priorities_if_in_room_3

.baby_is_holding_rope
    lda desired_room_index
    cmp #3
    bne check_for_player_baby_collision
; check for arrow-baby collision
    ldx #objectid_baby
    sty temp_remember_animation_step
    ldy #objectid_arrow
    jsr test_for_collision_between_objects_x_and_y
    ldy temp_remember_animation_step
    ora #0
    beq check_for_player_baby_collision
; got arrow baby collision
    lda #0
    ldx #<sound5
    ldy #>sound5
    jsr play_sound_yx
; hide arrow
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_arrow
; mark bow as being available to fire
    lda #&ff
    sta save_game_level_g_got_bow_or_arrow_in_flight_progress
; set baby y position, surprised, about to fall
    lda #&60 ; '`'
    sta room_3_baby_y_position
    ldy #baby_surprise_animation - baby_animations
    lda #baby_fall_animation - baby_animations
    sta save_game_level_g_baby_progress
    jmp set_baby_animation_step_to_y

.check_for_player_baby_collision
    lda desired_room_index
    cmp #3
    bne set_baby_animation_step_to_y
    lda #8
    sta temp_top_offset
; check for collision
    ldx #objectid_baby
    sty temp_remember_animation_step
    ldy #objectid_player
    jsr test_for_collision_between_objects_x_and_y
    ldy temp_remember_animation_step
    ora #0
    beq set_baby_animation_step_to_y
; collision_found
    lda #6
    sta player_wall_collision_reaction_speed
    ldy #baby_push_animation - baby_animations
    jmp set_baby_animation_step_to_y

.baby_is_falling
    lda room_3_baby_y_position
    cmp #&98
    bcc set_baby_animation_step_to_y
    lda desired_room_index
    cmp #3
    bne skip_sound_since_not_in_room_3
    lda #&40 ; '@'
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
.skip_sound_since_not_in_room_3
    ldy #baby_dead_animation - baby_animations
    sty save_game_level_g_baby_progress
    jmp set_baby_animation_step_to_y

.reset_sound_priorities_if_in_room_3
    lda desired_room_index
    cmp #3
    bne set_baby_animation_step_to_y
    lda sound_priority_per_channel_table
    cmp #&41 ; 'A'
    bcs set_baby_animation_step_to_y
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table+1
.set_baby_animation_step_to_y
    sty room_3_baby_animation_step
    iny
; add y offset at current animation step
    lda baby_animations,y
    clc
    adc room_3_baby_y_position
    sta room_3_baby_y_position
.set_baby_object_sprite_if_in_room_3
    lda desired_room_index
    cmp #3
    bne update_room_3_bits
    ldy room_3_baby_animation_step
    lda baby_animations,y
    sta object_spriteid + objectid_baby
    lda save_game_level_g_baby_progress
    cmp #baby_dead_animation - baby_animations
    beq baby_is_dead
    lda #&a0
    sta object_z_order + objectid_baby
    lda save_game_level_g_baby_progress
    cmp #baby_holding_rope_animation - baby_animations
    bne set_baby_y_position
    lda #&60 ; '`'
    sta object_y_low + objectid_baby
    jmp update_room_3_bits

.set_baby_y_position
    lda room_3_baby_y_position
    sta object_y_low + objectid_baby
    jmp update_room_3_bits

.baby_is_dead
    lda #&e0
    sta object_z_order + objectid_baby
    lda #&b0
    sta object_y_low + objectid_baby
    ldx #9
    ldy #&15
    lda #3
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq update_room_3_bits
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.update_room_3_bits
    lda #3
    sta currently_updating_logic_for_room_index
    lda #3
    sta balloon_objectid
    lda #4
    sta rope_end_objectid
    ldy #&60 ; '`'
    lda save_game_level_g_baby_progress
    cmp #baby_holding_rope_animation - baby_animations
    beq store_min_balloon_y
    lda room_3_baby_animation_step
    cmp #&15
    beq store_min_balloon_y
    ldy #&20 ; ' '
.store_min_balloon_y
    sty balloon_min_pixel_y
    ldx #&0b
    ldy room_3_balloon_y_position
    jsr update_balloon
    sty room_3_balloon_y_position
    rts

.temp_remember_animation_step
    equb 0
; *************************************************************************************
; 
; Room 0 initialisation and game loop
; 
; *************************************************************************************
.room_0_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ###              |               |   ###
; ###              |               |   ###
; ###              |               |   ###
; ###              |               |   ###
; ###OOO           |               |   ###
; ###OOO           |               |   ###
; ##############   |        ####   |   ###
; ##############   |        ####   |   ###
; ###   |          |               |   ###
; ###   |          |               |   ###
; ###   |          |               |   ###
; ###   |          |                   ###
; ###   |          |                   ###
; ###   |   ####            ##############
; ###   |   ####            ##############
; ###   |
; ###   |
; ###   |
; ###
; ###                 P
; ########################################
; ########################################
; set ground fill tile to use
.room_0_code
    lda #<ground_fill_2x2_top_left
    sta source_sprite_memory_low
    lda #>ground_fill_2x2_top_left
    sta source_sprite_memory_high
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x20 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (3,8)
    ldx #3
    ldy #8
    lda #&0b
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (26,15)
    ldx #&1a
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (10,15)
    ldx #&0a
    lda #4
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (26,8)
    ldx #&1a
    ldy #8
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (3,6) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #3
    ldy #6
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (6,10) length 10
    ldx #6
    ldy #&0a
    lda #&0a
    jsr draw_rope
; draw rope at (17,2) length 13
    ldx #&11
    ldy #2
    lda #&0d
    jsr draw_rope
; draw rope at (33,2) length 11
    ldx #&21 ; '!'
    ldy #2
    lda #&0b
    jsr draw_rope
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.room_0_update_handler
    lda #0
    sta currently_updating_logic_for_room_index
    lda #3                                                            ; redundant instruction
    ldx #&25 ; '%'                                                    ; redundant instruction
    ldy #&0d                                                          ; redundant instruction
    lda #5
    sta balloon_objectid
    lda #6
    sta rope_end_objectid
    lda #&20 ; ' '
    sta balloon_min_pixel_y
    ldx #&16
    ldy room_0_balloon_y_position
    jsr update_balloon
    sty room_0_balloon_y_position
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne initialise_room_0
    jmp room_0_not_first_update

.initialise_room_0
    lda #spriteid_bow_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_bow
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
    ldx #<envelope4
    ldy #>envelope4
    jsr define_envelope
    ldx #<envelope5
    ldy #>envelope5
    jsr define_envelope
    ldx #<envelope6
    ldy #>envelope6
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq no_level_change
; new level. If arrow is in flight (non_zero), then stop it, and mark we have got the
; bow ($ff).
    lda save_game_level_g_got_bow_or_arrow_in_flight_progress
    beq no_level_change
    lda #&ff
    sta save_game_level_g_got_bow_or_arrow_in_flight_progress
.no_level_change
    lda #spriteid_erase_cache1
    sta object_erase_type + objectid_bow
    lda #0
    sta object_y_high + objectid_bow
    lda save_game_level_g_got_bow_or_arrow_in_flight_progress
    bne fast_forward_arrow_progress
; position bow in room 0
    lda desired_room_index
    cmp #0
    bne return3
    ldx #4
    ldy #5
    lda #&ff
    sta temp_sprite_y_offset
    lda #2
    jsr set_object_position_from_cell_xy
    lda #spriteid_bow
    sta object_spriteid + objectid_bow
.return3
    rts

; If returning to a room where the arrow is in flight, then play the arrow's flight in
; a loop until done
.fast_forward_arrow_progress
    cmp #&ff
    beq got_bow
; arrow is in the air. Check: Is it in the current room? Branch if not.
    lda desired_room_index
    cmp arrow_room
    bne got_bow
; update arrow object in the current room
    jsr set_arrow_object
.arrow_in_flight_loop
    lda desired_room_index
    cmp arrow_room
    bne got_bow
    lda arrow_active_progress
    beq got_bow
    dec arrow_active_progress
    ldx #objectid_arrow
    jsr copy_object_state_to_old
    jsr update_arrow_wall_collision
    jmp arrow_in_flight_loop

.got_bow
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_bow
.return4_local
    jmp return4

.update_arrow_active_progress_local
    jmp update_arrow_active_progress

; Check if the arrow is still in the room (branch if not)
.room_0_not_first_update
    lda save_game_level_g_got_bow_or_arrow_in_flight_progress
    bne update_arrow
; return if not in room 0
    lda desired_room_index
    cmp #0
    bne return4_local
; check for player and bow collision, return if none
    ldx #objectid_old_player
    ldy #objectid_bow
    jsr test_for_collision_between_objects_x_and_y
    beq return4_local
; add bow to toolbar
    lda #spriteid_bow_menu_item
    jsr find_or_create_menu_slot_for_A
; remove bow object's sprite
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_bow
; decrement value to $ff, meaning the bow is in the posession of the player and the
; arrow is not flying through the air
    dec save_game_level_g_got_bow_or_arrow_in_flight_progress
    jmp return4

.update_arrow
    lda #0
    sta arrow_just_fired_flag
    lda object_spriteid_old + objectid_bow
    sta bow_or_arrow_spriteid
    ldx #0
; check if player is using the bow. Branch if not.
    lda #spriteid_bow_menu_item
    cmp player_using_object_spriteid
    bne store_bow_just_used_flag
; check if player just started using the bow this frame. Branch if not. Otherwise
; decrement X to 255.
    cmp previous_player_using_object_spriteid
    beq store_bow_just_used_flag
    dex
.store_bow_just_used_flag
    stx player_just_started_using_bow_flag
    lda save_game_level_g_got_bow_or_arrow_in_flight_progress
    cmp #&ff
    beq arrow_is_available_to_fire
    lda arrow_room
    cmp desired_room_index
    beq arrow_is_in_current_room
    lda arrow_active_progress
    cmp #&0a
    bcc update_arrow_active_progress_local
    lda player_just_started_using_bow_flag
    beq update_arrow_active_progress_local
    bne arrow_just_fired                                              ; ALWAYS branch

.arrow_is_available_to_fire
    lda player_just_started_using_bow_flag
    beq return4_local
.arrow_just_fired
    dec arrow_just_fired_flag
    lda #1
    sta save_game_level_g_got_bow_or_arrow_in_flight_progress
; Arrow just fired: set the arrow room to the current room
    lda desired_room_index
    sta arrow_room
; arrow is fired in the same direction as the player
    lda object_direction
    sta arrow_direction
; arrow position is set to the player accessory position (i.e. the bow position)
    lda object_x_low + objectid_player_accessory
    sta arrow_x_position_low
    lda object_x_high + objectid_player_accessory
    sta arrow_x_position_high
    lda object_y_low + objectid_player_accessory
    sta arrow_y_position_low
; count the arrow in flight progress
    lda #0
    sta arrow_active_progress
; position the actual arrow object
    jsr set_arrow_object
    ldx #objectid_arrow
    jsr copy_object_state_to_old
.arrow_is_in_current_room
    jsr update_arrow_wall_collision
    lda desired_room_index
    cmp arrow_room
    beq check_for_player_bow_collision
    lda #0
    sta arrow_active_progress
.check_for_player_bow_collision
    lda bow_or_arrow_spriteid
    sta object_spriteid_old + objectid_bow
    ldx #objectid_old_player
    ldy #objectid_bow
    jsr test_for_collision_between_objects_x_and_y
    bne player_collided_with_bow
    lda #objectid_bow
    jsr get_solid_rock_collision_for_object_a
    bne player_collided_with_bow
    lda arrow_just_fired_flag
    beq update_arrow_collision_sound_local
    lda desired_room_index
    cmp arrow_room
    bne play_arrow_fired_sound
    lda object_spriteid + objectid_bow
    beq update_arrow_collision_sound_local
.play_arrow_fired_sound
    lda #0
    ldx #<sound6
    ldy #>sound6
    jsr play_sound_yx
    ldx #<sound7
    ldy #>sound7
    jsr play_sound_yx
.update_arrow_collision_sound_local
    jsr update_arrow_collision_sound
    jmp return4

.player_collided_with_bow
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_bow
    lda #&ff
    sta save_game_level_g_got_bow_or_arrow_in_flight_progress
    jmp return4

.update_arrow_active_progress
    lda arrow_active_progress
    bmi return4
    inc arrow_active_progress
.return4
    rts

.player_just_started_using_bow_flag
    equb 0
.arrow_just_fired_flag
    equb 0
.bow_or_arrow_spriteid
    equb 0

.update_arrow_wall_collision
    lda #1
    sta temp_bottom_offset
    dec temp_left_offset
    inc temp_right_offset
    lda #objectid_arrow
    jsr get_solid_rock_collision_for_object_a
    beq move_arrow_in_arrow_direction
; arrow hit wall. Hide arrow, and reset arrow in flight progress
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_arrow
    sta arrow_active_progress
; set flag to indicate the player has the bow/arrow
    lda #&ff
    sta save_game_level_g_got_bow_or_arrow_in_flight_progress
    jmp return5

.move_arrow_in_arrow_direction
    lda #8
    ldx arrow_direction
    bpl skip_invert_if_arrow_moving_left
; invert A. [since A=8 at this point, could just 'lda #f8' here instead]
    eor #&ff
    clc
    adc #1
; sign extend arrow velocity in A to 16 bit 'XA' value
.skip_invert_if_arrow_moving_left
    ldx #0
    ora #0
    bpl add_offset_to_arrow_object_position
    dex
.add_offset_to_arrow_object_position
    clc
    adc arrow_x_position_low
    sta arrow_x_position_low
    txa
    adc arrow_x_position_high
    sta arrow_x_position_high
    jsr set_arrow_object
    lda #objectid_arrow
    jsr update_object_a_solid_rock_collision
    lda #objectid_arrow
    jsr get_solid_rock_collision_for_object_a
    beq copy_arrow_position
; move arrow
    lda arrow_direction
    bpl arrow_going_left
    lda object_x_low + objectid_arrow
    clc
    adc #8
    sta object_x_low + objectid_arrow
    lda object_x_high + objectid_arrow
    adc #0
    sta object_x_high + objectid_arrow
    jmp copy_arrow_position

.arrow_going_left
    lda object_x_low + objectid_arrow
    sec
    sbc #8
    sta object_x_low + objectid_arrow
    lda object_x_high + objectid_arrow
    sbc #0
    sta object_x_high + objectid_arrow
.copy_arrow_position
    lda object_x_low + objectid_arrow
    sta arrow_x_position_low
    lda object_x_high + objectid_arrow
    sta arrow_x_position_high
    lda object_y_low + objectid_arrow
    sta arrow_y_position_low
    ldx #objectid_arrow
    jsr find_left_and_right_of_object
; check arrow direction, and check if off the edge of the room
    lda arrow_direction
    bmi check_if_arrow_is_off_the_left_edge_of_the_room
; check if arrow is off the right edge of the room
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return5
; subtract 320 from the arrow x position and increment the arrow room number to move it
; one room to the right
    lda arrow_x_position_low
    sec
    sbc #&40 ; '@'
    sta arrow_x_position_low
    lda #0
    sbc #0
    sta arrow_x_position_high
    inc arrow_room
    jmp hide_arrow_object_sprite

.check_if_arrow_is_off_the_left_edge_of_the_room
    lda object_right_cell_x
    bpl return5
; add 320 to the arrow x position and decrement the arrow room number to move it one
; room to the left
    lda arrow_x_position_low
    clc
    adc #&40 ; '@'
    sta arrow_x_position_low
    lda #1
    sta arrow_x_position_high
    dec arrow_room
.hide_arrow_object_sprite
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_arrow
.return5
    rts

.set_arrow_object
    lda arrow_x_position_low
    sta object_x_low + objectid_arrow
    lda arrow_x_position_high
    sta object_x_high + objectid_arrow
    lda arrow_y_position_low
    sta object_y_low + objectid_arrow
    lda #0
    sta object_y_high + objectid_arrow
    lda arrow_direction
    sta object_direction + objectid_arrow
    lda #spriteid_arrow
    sta object_spriteid + objectid_arrow
    lda #&40 ; '@'
    sta object_z_order + objectid_arrow
    rts

.update_arrow_collision_sound
    lda desired_room_index
    cmp arrow_room
    bne return6
    lda #1
    sta temp_bottom_offset
    inc temp_right_offset
    dec temp_left_offset
    lda #objectid_arrow
    jsr get_solid_rock_collision_for_object_a
    beq return6
; arrow thud
    lda #0
    ldx #<sound8
    ldy #>sound8
    jsr play_sound_yx
.return6
    rts

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 26                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ###   |        ###               |   ###
; ###   |        ###               |   ###
; ###   |        ###               |   ###
; ###   |        ###               |   ###
; ###   |        ###               |   ###
; ###   |        ###               |   ###
; ###   |        ###       #####   |   ###
; ###   |        ###       #####   |   ###
; ###   |        ###       ###     |   ###
; ###   |        ###       ###     |   ###
; ###   |                  ###     |   ###
; ###   |                  ###     |   ###
; ###   |                  ###     |   ###
; ###   |                  ###     |   ###
; ###   |                  ###     |   ###
;       |        ###               |
;       |        ###               |
;       |        ###               |
;                ###
;                ###        P
; ########################################
; ########################################
; set ground fill tile to use
.room_1_code
    lda #<ground_fill_2x2_top_left
    sta source_sprite_memory_low
    lda #>ground_fill_2x2_top_left
    sta source_sprite_memory_high
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (37,2)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (15,2)
    ldx #&0f
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (15,17)
    ldy #&11
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (25,8)
    ldx #&19
    ldy #8
    lda #9
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 2x2 rectangle at (28,8)
    ldx #&1c
    lda #2
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (6,2) length 18
    ldx #6
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (33,2) length 18
    ldx #&21 ; '!'
    jsr draw_rope
    ldx #&0a
    lda #&0d
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_1_check_right_exit
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

.room_1_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_1_game_update_loop
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_1_update_handler
    lda #1
    sta currently_updating_logic_for_room_index
    lda #&20 ; ' '
    sta balloon_min_pixel_y
    lda #3
    sta balloon_objectid
    lda #4
    sta rope_end_objectid
    ldx #&0b
    ldy room_1_left_hand_balloon_y_position
    jsr update_balloon
    sty room_1_left_hand_balloon_y_position
    lda #5
    sta balloon_objectid
    lda #6
    sta rope_end_objectid
    ldx #&15
    ldy room_1_right_hand_balloon_y_position
    jsr update_balloon
    sty room_1_right_hand_balloon_y_position
    rts

.update_balloon
    stx balloon_cell_x
    sty balloon_pixel_y
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_balloon_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq set_balloon_and_rope_end_object_positions
; new level. Set the balloon to the topmost position
    lda balloon_min_pixel_y
    sta balloon_pixel_y
.set_balloon_and_rope_end_object_positions
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne update_balloon_object_if_in_room_local
    ldx balloon_cell_x
    ldy #0
    lda balloon_objectid
    jsr set_object_position_from_cell_xy
    lda rope_end_objectid
    jsr set_object_position_from_cell_xy
    lda #spriteid_balloon
    ldx balloon_objectid
    sta object_spriteid,x
    lda #spriteid_rope_end1
    ldx rope_end_objectid
    sta object_spriteid,x
    lda #&c0
    sta object_z_order,x
    jsr check_if_monkey_can_climb
.update_balloon_object_if_in_room_local
    jmp update_balloon_object_if_in_room

.return_with_balloon_position_in_xy_local
    jmp return_with_balloon_position_in_xy

.update_balloon_not_first_update
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne move_balloon_upwards
    jsr check_if_monkey_can_climb
    lda inhibit_monkey_climb_flag_local
    beq move_balloon_upwards
; move player down four pixels
    lda #4
    sta downwards_movement_while_player_is_holding_balloon
    clc
    adc object_y_low
    sta object_y_low
    lda downwards_movement_while_player_is_holding_balloon
    clc
    adc object_y_low + objectid_player_accessory
    sta object_y_low + objectid_player_accessory
.move_down_by_smaller_amounts_until_no_collision_loop
    lda #1
    sta temp_bottom_offset
    lda #objectid_player
    jsr get_solid_rock_collision_for_object_a
    beq move_balloon_down_with_player
    dec downwards_movement_while_player_is_holding_balloon
    dec object_y_low
    dec object_y_low + objectid_player_accessory
    jmp move_down_by_smaller_amounts_until_no_collision_loop

.move_balloon_down_with_player
    lda downwards_movement_while_player_is_holding_balloon
    beq return_with_balloon_position_in_xy_local
    clc
    adc balloon_pixel_y
    sta balloon_pixel_y
    lda #&a0                                                          ; redundant instruction
    lda #&e0
    ldx balloon_objectid
    sta object_z_order,x
    lda #2
    sta temp_bottom_offset
    lda #objectid_player
    jsr get_solid_rock_collision_for_object_a
    beq update_balloon_object_if_in_room
    jsr play_landing_sound
    jmp update_balloon_object_if_in_room

.move_balloon_upwards
    lda balloon_pixel_y
    cmp balloon_min_pixel_y
    beq return_with_balloon_position_in_xy_local
    sec
    sbc #8
    cmp balloon_min_pixel_y
    bcs store_ballon_y
    lda balloon_min_pixel_y
.store_ballon_y
    sta balloon_pixel_y
    lda #&e0
    ldx balloon_objectid
    sta object_z_order,x
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne update_balloon_object_if_in_room
    lda balloon_pixel_y
    cmp balloon_min_pixel_y
    bne update_balloon_object_if_in_room
    jsr play_landing_sound
.update_balloon_object_if_in_room
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return_with_balloon_position_in_xy
    lda balloon_pixel_y
    ldx balloon_objectid
    sta object_y_low,x
    ldx rope_end_objectid
    sta object_y_low,x
; update collision map
    ldx balloon_cell_x
    lda balloon_pixel_y
    lsr a
    lsr a
    lsr a
    tay
    dey
    dey
    lda #0
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #2
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    jsr read_collision_map_value_for_xy
    cmp #3
    beq return_with_balloon_position_in_xy
    lda balloon_pixel_y
    and #7
    beq clear_final_collisions_map_cell
    lda #2
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    jsr read_collision_map_value_for_xy
    cmp #3
    beq return_with_balloon_position_in_xy
.clear_final_collisions_map_cell
    lda #0
    jsr write_a_single_value_to_cell_in_collision_map
.return_with_balloon_position_in_xy
    ldx balloon_cell_x
    ldy balloon_pixel_y
    rts

.downwards_movement_while_player_is_holding_balloon
    equb 0
.balloon_cell_x
    equb 0
.balloon_pixel_y
    equb 0
.balloon_min_pixel_y
    equb 0
.balloon_objectid
    equb 0
.rope_end_objectid
    equb 0

.check_if_monkey_can_climb
    lda #0
    sta inhibit_monkey_climb_flag_local
    lda current_player_character
    cmp #spriteid_icodata_monkey
    bne return7
    lda object_x_high
    lsr a
    sta temp_player_x
    lda object_x_low
    ror a
    lsr temp_player_x
    ror a
    lsr temp_player_x
    ror a
    sta temp_player_x
    sec
    sbc #2
    cmp balloon_cell_x
    bcs return7
    lda temp_player_x
    clc
    adc #1
    cmp balloon_cell_x
    bcc return7
    lda current_player_animation
    cmp #monkey_climb_animation - monkey_base_animation
    beq stop_monkey_from_climbing
    cmp #monkey_climb_idle_animation - monkey_base_animation
    beq stop_monkey_from_climbing
    cmp #monkey_climb_down_animation - monkey_base_animation
    bne return7
.stop_monkey_from_climbing
    lda #&ff
    sta inhibit_monkey_climb_flag
    sta inhibit_monkey_climb_flag_local
.return7
    rts

.inhibit_monkey_climb_flag_local
    equb 0
.envelope4
    equb 5                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 255                                                          ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 1                                                            ; number of steps in section 1
    equb 1                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 110                                                          ; change of amplitude per step during attack phase
    equb 252                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 248                                                          ; change of amplitude per step during release phase
    equb 110                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound8
    equw &0013                                                        ; channel
    equw 5                                                            ; amplitude
    equw 201                                                          ; pitch
    equw 1                                                            ; duration
.envelope1
    equb 6                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 80                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 250                                                          ; change of amplitude per step during release phase
    equb 115                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound4
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound3
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 210                                                          ; pitch
    equw 1                                                            ; duration
.envelope2
    equb 7                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 126                                                          ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 252                                                          ; change of amplitude per step during sustain phase
    equb 248                                                          ; change of amplitude per step during release phase
    equb 126                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound2
    equw &0010                                                        ; channel
    equw 7                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound1
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 200                                                          ; pitch
    equw 1                                                            ; duration
.envelope3
    equb 7                                                            ; envelope number
    equb 129                                                          ; step length (100ths of a second)
    equb 252                                                          ; pitch change per step in section 1
    equb 254                                                          ; pitch change per step in section 2
    equb 255                                                          ; pitch change per step in section 3
    equb 8                                                            ; number of steps in section 1
    equb 8                                                            ; number of steps in section 2
    equb 8                                                            ; number of steps in section 3
    equb 96                                                           ; change of amplitude per step during attack phase
    equb 252                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 252                                                          ; change of amplitude per step during release phase
    equb 96                                                           ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound5
    equw &0013                                                        ; channel
    equw 7                                                            ; amplitude
    equw 245                                                          ; pitch
    equw 2                                                            ; duration
.envelope5
    equb 8                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 110                                                          ; change of amplitude per step during attack phase
    equb 254                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 252                                                          ; change of amplitude per step during release phase
    equb 110                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound7
    equw &0010                                                        ; channel
    equw 8                                                            ; amplitude
    equw 3                                                            ; pitch
    equw 2                                                            ; duration
.envelope6
    equb 9                                                            ; envelope number
    equb 132                                                          ; step length (100ths of a second)
    equb 2                                                            ; pitch change per step in section 1
    equb 2                                                            ; pitch change per step in section 2
    equb 2                                                            ; pitch change per step in section 3
    equb 4                                                            ; number of steps in section 1
    equb 4                                                            ; number of steps in section 2
    equb 4                                                            ; number of steps in section 3
    equb 0                                                            ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 0                                                            ; change of amplitude per step during release phase
    equb 0                                                            ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound6
    equw &0011                                                        ; channel
    equw 9                                                            ; amplitude
    equw 110                                                          ; pitch
    equw 2                                                            ; duration
.ground_fill_2x2_top_left
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11000111
    equb %00001000
    equb %00010000
    equb %00010000
    equb %00010000
.ground_fill_2x2_top_right
    equb %00010000
    equb %00010000
    equb %00001000
    equb %11000111
    equb %00100001
    equb %00010001
    equb %00010001
    equb %00010001
.ground_fill_2x2_bottom_left
    equb %00010000
    equb %00010000
    equb %00001000
    equb %11000111
    equb %00100001
    equb %00010001
    equb %00010001
    equb %00010001
.ground_fill_2x2_bottom_right
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11000111
    equb %00001000
    equb %00010000
    equb %00010000
    equb %00010000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelG_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelG.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelG"
ENDIF
ENDIF
.pydis_end

save "build/dataG", pydis_start, pydis_end
