; *************************************************************************************
;
; Level B: TIME-FLIES
;
; Save game variables:
;
;     save_game_level_b_cuckoo_room_1_progress ($0a05):
;               0: hidden in room 1 clock,
;              1+: cuckooing
;             $ff: got cuckoo (cuckoo object created)
;     save_game_level_b_cuckoo_room_2_progress ($0a06):
;               0: in room 2 clock or held
;               1: installed in clock
;              15: just launched
;           16-40: animation being thrown into room3 (just the odd numbers)
;             $ff: in room 3
;     save_game_level_b_room_2_falling_boulder_progress ($0a07):
;               0: suspended
;             $ff: finished falling
;       otherwise: falling (Y coordinate)
;     save_game_level_b_room_0_falling_boulder_progress ($0a08):
;               0: suspended
;             $ff: finished falling
;       otherwise: falling (Y coordinate)
;     save_game_level_b_got_hourglass_flag ($0a09)
;
; Solution:
;
;   1. Get the hourglass collectable from room 2 (to the right of the start room 0)
;   2. Stand as the wizard on top of the suspended boulder in room 0 holding the hourglass
;           (The boulder falls)
;   3. Jump left into room 1 from the fallen boulder, and go to the far left edge
;   4. Jump into the pendulum to set it ticking for a short time
;   5. As the cat, jump back to the right of the room, up onto the ledge and as the monkey jump
;      onto the rope and into the cuckoo before the clock stops. Timing is tight here.
;      Alternatively, jump as the cat towards the rope from the right below the rope and
;      change mid-air into the monkey to grab onto the rope.
;   6. Take the cuckoo to the clock in room 2 and use it on top of the clock to fix the clock.
;   7. Set the clock ticking by jumping into the pendulum.
;           (The cuckoo is thrown into room 3, and the suspended boulder falls)
;   8. Jump to the right into room 3 from the fallen boulder
;   9. Climb the rope over to the right side of the room and jump into the spell collectable.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_clock_workings               = 3
objectid_cuckoo                       = 2
objectid_hourglass                    = 7
objectid_pendulum                     = 2
objectid_rope_broken_bottom_end       = 6
objectid_rope_broken_top_end          = 5
objectid_spell                        = 5
objectid_suspended_boulder            = 4
spriteid_boulder                      = 213
spriteid_cache1                       = 215
spriteid_cache2                       = 216
spriteid_cache3                       = 223
spriteid_clock                        = 200
spriteid_clock_workings               = 209
spriteid_cuckoo                       = 211
spriteid_cuckoo_appear_full           = 208
spriteid_cuckoo_appear_partly         = 207
spriteid_cuckoo_menu_item             = 212
spriteid_cuckoo_open_beak             = 214
spriteid_hourglass                    = 221
spriteid_hourglass_menu_item          = 222
spriteid_pendulum1                    = 201
spriteid_pendulum2                    = 202
spriteid_pendulum3                    = 203
spriteid_pendulum4                    = 204
spriteid_pendulum5                    = 205
spriteid_rope_broken_bottom_end       = 219
spriteid_rope_broken_falling_end      = 218
spriteid_rope_broken_top_end          = 220
spriteid_rope_end_at_object           = 217
spriteid_table                        = 210
spriteid_vertical_rod                 = 206

; Memory locations
previous_boulder_progress                           = &0070
room_exit_direction                                 = &0070
save_game_level_b_cuckoo_room_1_progress            = &0a05
save_game_level_b_cuckoo_room_2_progress            = &0a06
save_game_level_b_room_2_falling_boulder_progress   = &0a07
save_game_level_b_room_0_falling_boulder_progress   = &0a08
save_game_level_b_got_hourglass_flag                = &0a09
room_1_clock_repeat_counter                         = &0a6f
room_1_clock_repeat_limit                           = &0a70
room_1_pendulum_swing_index                         = &0a71
room_2_clock_repeat_counter                         = &0a72
room_2_clock_repeat_limit                           = &0a73
room_2_pendulum_swing_index                         = &0a74
player_playing_cuckoo_progress                      = &0a75

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelB_sprite_table - level_data
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
    equb 0
.initial_room_index_cheat
    equb 1
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "TIME-FLIES", &0D

; *************************************************************************************
; 
; Level initialisation
; 
; This is called whenever a new room is entered.
; 
; *************************************************************************************
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
    sta save_game_level_b_cuckoo_room_1_progress
.developer_mode_inactive
    lda save_game_level_b_got_hourglass_flag
    beq check_got_cuckoo
    lda #spriteid_hourglass_menu_item
    jsr find_or_create_menu_slot_for_A
.check_got_cuckoo
    lda save_game_level_b_cuckoo_room_1_progress
    beq return1
    lda save_game_level_b_cuckoo_room_2_progress
    bne return1
    lda #spriteid_cuckoo_menu_item
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
    jsr room_1_update_handler
    jsr room_2_update_handler
    jsr update_hourglass_handler
    jsr room_0_update_handler
    jsr room_3_update_handler
    jsr update_playing_cuckoo_handler
    rts

; *************************************************************************************
; 
; Room 0 initialisation and game loop
; 
; *************************************************************************************
.room_0_data
    equb 22                                                           ; initial player X cell
    equb 20                                                           ; initial player Y cell

; ########################################
; ########################################
; #####                       |      #####
; ####                        |       ####
; ###                         |        ###
; ###                         |        ###
; ###                         |        ###
; ###                         |        ###
; ########           ######   |   ########
; ########           ######   |   ########
;                             |        ###
;                             |        ###
;                             |        ###
;                             |
;                             |
; #####                       |
; #####                       |
; #####                       |
; #####    OOOOOOOOO                 #####
; #####    OOOOOOOOO    P            #####
; ########################################
; ########################################
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
; draw 5x1 rectangle at (0,2)
    ldy #2
    lda #5
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (35,2)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,3)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (0,4)
    ldx #0
    iny
    dec width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (37,4)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 8x2 rectangle at (0,8)
    ldx #0
    ldy #8
    sty width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 8x2 rectangle at (32,8)
    ldx #&20 ; ' '
    jsr copy_rectangle_of_memory_to_screen
; draw 8x3 rectangle at (37,10)
    ldx #&25 ; '%'
    ldy #&0a
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x5 rectangle at (0,15)
    ldx #0
    ldy #&0f
    lda #5
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x5 rectangle at (0,20)
    ldy #&14
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (35,18)
    ldx #&23 ; '#'
    ldy #&12
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x2 rectangle at (19,8)
    ldx #&13
    ldy #8
    lda #6
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (9,18) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #9
    ldy #&12
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (12,18) of size (3x2)
    ldx #&0c
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (15,18) of size (3x2)
    ldx #&0f
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (28,2) length 16
    ldx #&1c
    ldy #2
    lda #&10
    jsr draw_rope
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_0_check_right_exit
; exit room left, to room 1
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.room_0_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_0_game_update_loop
; exit room right, to room 2
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_0_update_handler
    lda update_room_first_update_flag
    beq room_0_update_suspended_boulder_puzzle
; on the first update, if we have changed levels, then define the envelope
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_0_update_suspended_boulder_puzzle
; level changed, define the envelope
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope

.room_0_update_suspended_boulder_puzzle
    lda #0
    sta player_on_suspended_boulder_holding_object
; check if in room 0
    lda desired_room_index
    cmp #0
    bne room_0_update_boulder_falling_progress
; check the player is holding something
    lda player_held_object_spriteid
    beq room_0_update_boulder_falling_progress
; check the player Y coordinate is less than 64
    lda object_y_low
    cmp #&40 ; '@'
    bcs room_0_update_boulder_falling_progress
    lda object_x_high
    bne room_0_update_boulder_falling_progress
; check the player X coordinate is between 96 and 127
    lda object_x_low
    cmp #&60 ; '`'
    bcc room_0_update_boulder_falling_progress
    cmp #&80
    bcs room_0_update_boulder_falling_progress
; with a bottom offset of 2 pixels, look if we are on the rope
    lda #2
    sta temp_bottom_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    and #collision_map_rope
    beq room_0_update_boulder_falling_progress
    dec player_on_suspended_boulder_holding_object

.room_0_update_boulder_falling_progress
    lda save_game_level_b_room_0_falling_boulder_progress
    sta falling_boulder_progress
    ldy #&10
    sty fallen_boulder_y
    lda #0
    ldx #&0d
    ldy #8
    jsr update_suspended_boulder_at_xy_in_room_a
    lda falling_boulder_progress
    sta save_game_level_b_room_0_falling_boulder_progress
    lda update_room_first_update_flag
    bne return2
    lda desired_room_index
    cmp #0
    bne return2
    lda save_game_level_b_room_0_falling_boulder_progress
    cmp #&10
    bne return2
    jsr play_boulder_landing_sounds
.return2
    rts

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 13                                                           ; initial player X cell
    equb 20                                                           ; initial player Y cell

; ########################################
; ########################################
; ######            #####           ######
; #####              ###             #####
; ####                |               ####
; ###                 |                ###
; ###                 |                ###
; ###                 |                ###
; ###                 |                ###
; ###                 |                ###
; ###                 |
; ###                 |
; ###                 |
; ###                 |    ####
; ###                 |    ####
; ###                 |              #####
; ###OOO                             #####
; ###OOO                           #######
; ###OOOOOO                        #######
; ###OOOOOO    P          ################
; #################       ################
; #################       ################
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
; draw 6x1 rectangle at (0,2)
    ldy #2
    lda #6
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (34,2)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (18,2)
    ldx #&12
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (0,3)
    ldx #0
    iny
    lda #5
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (35,3)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (19,3)
    ldx #&13
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,4)
    ldx #0
    iny
    lda #4
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,4)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x5 rectangle at (37,5)
    inx
    iny
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x255 rectangle at (0,5)
    ldx #0
    dec width_in_cells
    lda #&ff
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 14x255 rectangle at (3,20)
    ldx #3
    ldy #&14
    lda #&0e
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x255 rectangle at (16,22)
    ldx #&10
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x3 rectangle at (24,19)
    ldx #&18
    ldy #&13
    lda #3
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (33,17)
    ldx #&21 ; '!'
    ldy #&11
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (35,15)
    ldx #&23 ; '#'
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (25,13)
    ldx #&19
    ldy #&0d
    lda #4
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (6,18) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #6
    ldy #&12
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (3,18) of size (3x2)
    ldx #3
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (3,16) of size (3x2)
    ldy #&10
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (20,4) length 12
    ldx #&14
    ldy #4
    lda #&0c
    jsr draw_rope
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_1_game_update_loop
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

.room_1_update_handler
    lda #1
    sta currently_updating_logic_for_room_index
    lda #4
    ldx #&25 ; '%'
    ldy #7
    jsr update_brazier_and_fire
; update room 1 clock
    lda room_1_clock_repeat_counter
    sta clock_repeat_counter
    lda room_1_clock_repeat_limit
    sta clock_repeat_limit
    lda room_1_pendulum_swing_index
    sta pendulum_swing_index
    lda #1
    ldx #&0c
    ldy #&0b
    jsr update_clock
    lda clock_repeat_counter
    sta room_1_clock_repeat_counter
    lda clock_repeat_limit
    sta room_1_clock_repeat_limit
    lda pendulum_swing_index
    sta room_1_pendulum_swing_index
; check for first update (branch if not)
    lda update_room_first_update_flag
    beq update_room_1_cuckoo
; check for level change (branch if not)
    lda level_before_latest_level_and_room_initialisation
    cmp current_level
    beq set_clock_workings_in_room_1
; the level has changed. If we don't actually have the cuckoo, then reset any cuckoo
; progress to zero
    lda save_game_level_b_cuckoo_room_1_progress
    bmi set_clock_workings_in_room_1
    lda #0
    sta save_game_level_b_cuckoo_room_1_progress
.set_clock_workings_in_room_1
    lda desired_room_index
    cmp #1
    bne update_room_1_cuckooing_animation_local
    ldx #objectid_clock_workings
    jsr set_object_position_from_current_sprite_position
    lda #1
    sta object_direction,x
    lda #&ff
    sta object_erase_type,x
    sta object_z_order,x
.update_room_1_cuckooing_animation_local
    jmp update_room_1_cuckooing_animation

.update_room_1_cuckoo
    lda save_game_level_b_cuckoo_room_1_progress
    bmi update_room_1_cuckooing_animation
    beq room_1_increment_the_clock_timers
    lda desired_room_index
    cmp #1
    bne update_room_1_cuckooing
; check for collision in room 1 with cuckoo
    ldx #objectid_old_player
    ldy #objectid_clock_workings
    jsr test_for_collision_between_objects_x_and_y
    beq update_room_1_cuckooing
    lda #spriteid_cuckoo_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #&ff
    sta save_game_level_b_cuckoo_room_1_progress
    bmi update_room_1_cuckooing_animation
.room_1_increment_the_clock_timers
    lda room_1_clock_repeat_counter
    cmp #3
    bcc update_room_1_cuckooing_animation
    lda room_1_clock_repeat_limit
    sec
    sbc room_1_clock_repeat_counter
    cmp #3
    bcc update_room_1_cuckooing_animation
    lda room_1_clock_repeat_counter
    and #3
    bne update_room_1_cuckooing_animation
    lda room_1_pendulum_swing_index
    bne update_room_1_cuckooing_animation
.update_room_1_cuckooing
    ldy save_game_level_b_cuckoo_room_1_progress
    iny
    cpy #6
    bcc save_cuckooing_progress
    ldy #0
.save_cuckooing_progress
    sty save_game_level_b_cuckoo_room_1_progress
    lda desired_room_index
    cmp #1
    bne update_room_1_cuckooing_animation
    cpy #2
    bne update_room_1_cuckooing_animation
    jsr play_cuckoo_two_sounds
.update_room_1_cuckooing_animation
    lda desired_room_index
    cmp #1
    bne return9
    ldy save_game_level_b_cuckoo_room_1_progress
    bpl set_cuckooing_animation_to_index_y
    lda #spriteid_clock_workings
    bne set_cuckooing_animation_spriteid                              ; ALWAYS branch

.set_cuckooing_animation_to_index_y
    lda cuckooing_spriteid_table,y
.set_cuckooing_animation_spriteid
    sta object_spriteid + objectid_clock_workings
.return9
    rts

.cuckooing_spriteid_table
    equb         spriteid_vertical_rod, spriteid_cuckoo_appear_partly
    equb   spriteid_cuckoo_appear_full,   spriteid_cuckoo_appear_full
    equb   spriteid_cuckoo_appear_full, spriteid_cuckoo_appear_partly

.update_clock
    sta currently_updating_logic_for_room_index
    lda update_room_first_update_flag
    beq update_clock_not_first_update
; first update in room
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq update_clock_first_update_same_level
; changed level, so reset clock (reset pendulum swings)
    lda #0
    sta clock_repeat_counter
    sta clock_repeat_limit
    sta pendulum_swing_index
.update_clock_first_update_same_level
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne update_swinging_pendulum_local
; player is in the same room as the clock. Draw the clock.
    lda #4
    sta temp_sprite_x_offset
    lda #spriteid_clock
    jsr draw_sprite_a_at_cell_xy
; write clock to collison map
    dex
    dey
    dey
    dey
    lda #3
    sta width_in_cells
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #2
    jsr set_object_position_from_current_sprite_position
    lda #1
    sta object_direction,x
    lda #&ff
    sta object_erase_type,x
    sta object_z_order,x
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
.update_swinging_pendulum_local
    jmp finish_swinging_pendulum

.update_clock_not_first_update
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne update_swinging_pendulum
    ldx #objectid_old_player
    ldy #objectid_pendulum
    jsr test_for_collision_between_objects_x_and_y
    beq update_swinging_pendulum
; add to clock counter
    lda clock_repeat_counter
    clc
    adc #&10
    sta clock_repeat_limit
.update_swinging_pendulum
    ldy #0
    lda clock_repeat_counter
    cmp clock_repeat_limit
    beq finish_swinging_pendulum
    ldy pendulum_swing_index
    iny
    cpy #&0a
    bcc still_mid_swing
    ldy #0
    inc clock_repeat_counter
.still_mid_swing
    sty pendulum_swing_index
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne finish_swinging_pendulum
    cpy #2
    bne check_for_clock_tock
; clock tick
    lda #0
    ldx #<sound_tick
    ldy #>sound_tick
    jsr play_sound_yx
    jmp clock_bass

.check_for_clock_tock
    cpy #7
    bne finish_swinging_pendulum
; clock tock
    lda #0
    ldx #<sound_tock
    ldy #>sound_tock
    jsr play_sound_yx
.clock_bass
    lda #0
    ldx #<sound_clock_bass
    ldy #>sound_clock_bass
    jsr play_sound_yx
.finish_swinging_pendulum
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne check_for_end_of_clock_ticking
    ldy pendulum_swing_index
    lda swinging_pendulum_spriteids,y
    sta object_spriteid + objectid_pendulum
.check_for_end_of_clock_ticking
    lda clock_repeat_counter
    cmp clock_repeat_limit
    bne return10
    lda #0
    sta clock_repeat_counter
    sta clock_repeat_limit
.return10
    rts

.clock_repeat_counter
    equb 0
.clock_repeat_limit
    equb 0
.pendulum_swing_index
    equb 0
.swinging_pendulum_spriteids
    equb spriteid_pendulum1
    equb spriteid_pendulum2
    equb spriteid_pendulum3
    equb spriteid_pendulum3
    equb spriteid_pendulum2
    equb spriteid_pendulum1
    equb spriteid_pendulum4
    equb spriteid_pendulum5
    equb spriteid_pendulum5
    equb spriteid_pendulum4

.cuckoo_tweeting_spriteids
    equb spriteid_cuckoo_open_beak
    equb spriteid_cuckoo_open_beak
    equb spriteid_cuckoo_open_beak
    equb spriteid_cuckoo

.update_playing_cuckoo_handler
    lda update_room_first_update_flag
    beq update_playing_cuckoo_not_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_cuckoo
    lda #0
    sta player_playing_cuckoo_progress
.initialise_cuckoo
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
    lda #spriteid_cuckoo_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_cuckoo
    sta collectable_spriteids+1
    jmp set_cuckoo_sprite

.update_playing_cuckoo_not_first_update
    lda #spriteid_cuckoo_menu_item
    cmp player_using_object_spriteid
    beq player_using_cuckoo
    lda #0
    sta player_playing_cuckoo_progress
    jmp set_cuckoo_sprite

.player_using_cuckoo
    ldy player_playing_cuckoo_progress
    cpy #3
    beq set_cuckoo_sprite
    iny
    sty player_playing_cuckoo_progress
.set_cuckoo_sprite
    ldy player_playing_cuckoo_progress
    lda cuckoo_tweeting_spriteids,y
    sta collectable_being_used_spriteids + 1
    lda update_room_first_update_flag
    bne return3
    dey
    bne return3
    jsr play_cuckoo_two_sounds
.return3
    rts

.play_cuckoo_two_sounds
    lda #0
    ldx #<sound_cuckoo1
    ldy #>sound_cuckoo1
    jsr play_sound_yx
    ldx #<sound_cuckoo2
    ldy #>sound_cuckoo2
    jsr play_sound_yx
    rts

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 14                                                           ; initial player X cell
    equb 20                                                           ; initial player Y cell

; ########################################
; ########################################
; ######   |        #####           ######
; #####    |         ###             #####
; ####     |                          ####
; ###      |                           ###
; ###      |                           ###
; ###      |                           ###
; ###      |                           ###
; ###      |
; ###      |
; ###      |
; ###      |
;          |
;          |
;          |                         #####
;          |                         #####
;          |                         #####
; #####              OOO    OOOOOOOOO#####
; #####         P    OOO    OOOOOOOOO#####
; ########################################
; ########################################
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
; draw 6x1 rectangle at (0,2)
    ldy #2
    lda #6
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (34,2)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (18,2)
    ldx #&12
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (0,3)
    ldx #0
    iny
    lda #5
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (35,3)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (19,3)
    ldx #&13
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,4)
    ldx #0
    iny
    lda #4
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,4)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x4 rectangle at (37,5)
    inx
    iny
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,5)
    ldx #0
    dec width_in_cells
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,18)
    ldy #&12
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x255 rectangle at (0,20)
    ldy #&14
    lda #&ff
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x5 rectangle at (35,15)
    ldx #&23 ; '#'
    ldy #&0f
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (9,2) length 16
    ldx #9
    ldy #2
    lda #&10
    jsr draw_rope
; draw boulder at (19,18) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&13
    ldy #&12
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (26,18) of size (3x2)
    ldx #&1a
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (29,18) of size (3x2)
    ldx #&1d
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (32,18) of size (3x2)
    ldx #&20 ; ' '
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_2_check_right_exit
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

.room_2_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_2_game_update_loop
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

; update room 2 clock
.room_2_update_handler
    lda room_2_clock_repeat_counter
    sta clock_repeat_counter
    lda room_2_clock_repeat_limit
    sta clock_repeat_limit
    lda room_2_pendulum_swing_index
    sta pendulum_swing_index
    lda #2
    ldx #&0d
    ldy #&0b
    jsr update_clock
    lda clock_repeat_counter
    sta room_2_clock_repeat_counter
    lda clock_repeat_limit
    sta room_2_clock_repeat_limit
    lda pendulum_swing_index
    sta room_2_pendulum_swing_index
; check for first update
    lda update_room_first_update_flag
    beq room_2_update_clock_puzzle
; first update. check for level change
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_2_draw_clock_workings
; level changed. if cuckoo in room 2 had enough progress, then set as completed.
    lda save_game_level_b_cuckoo_room_2_progress
    cmp #2
    bcc room_2_draw_clock_workings
    lda #&ff
    sta save_game_level_b_cuckoo_room_2_progress
.room_2_draw_clock_workings
    lda desired_room_index
    cmp #2
    bne skip_draw_workings
    ldx #&0d
    ldy #&0b
    lda #4
    sta temp_sprite_x_offset
    lda #spriteid_clock_workings
    jsr draw_sprite_a_at_cell_xy
    ldx #objectid_clock_workings
    lda #1
    sta object_direction,x
    lda #&c0
    sta object_z_order,x
    lda #spriteid_cache1
    sta object_erase_type,x
.skip_draw_workings
    jmp room_2_update_clock_workings

.room_2_update_clock_puzzle
    lda save_game_level_b_cuckoo_room_2_progress
    bmi room_2_update_clock_workings
    cmp #1
    beq room_2_update_cuckoo_in_clock
    bcs room_2_update_cuckoo_being_thrown_into_room_3
; check in room 2
    lda desired_room_index
    cmp #2
    bne room_2_update_clock_workings
; check player is using the cuckoo on the clock (in room 2)
    lda player_using_object_spriteid
    cmp #spriteid_cuckoo_menu_item
    bne room_2_update_clock_workings
    lda object_y_low
    cmp #&40 ; '@'
    bcs room_2_update_clock_workings
    lda #2
    sta temp_bottom_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    and #2
    beq room_2_update_clock_workings
; remove cuckoo from the toolbar and player's hand, increment progress, and reset
; wizard animation state
    lda #spriteid_cuckoo_menu_item
    jsr remove_item_from_toolbar_menu
    lda #1
    sta save_game_level_b_cuckoo_room_2_progress
    lda #0
    sta player_held_object_spriteid
    sta object_spriteid + objectid_player_accessory
    lda player_using_object_spriteid
    cmp #spriteid_cuckoo_menu_item
    bne room_2_update_cuckoo_in_clock
    lda #0
    sta player_using_object_spriteid
    lda #spriteid_wizard7
    sta object_spriteid
; check if clock in room 2 is running (branch if not)
.room_2_update_cuckoo_in_clock
    lda room_2_clock_repeat_counter
    cmp room_2_clock_repeat_limit
    beq room_2_update_clock_workings
; mark the cuckoo in room 2 as launched
    lda #&0f
    sta save_game_level_b_cuckoo_room_2_progress
; if player is in room 2 then play the cuckoo sound
    lda desired_room_index
    cmp #2
    bne room_2_update_clock_workings
    jsr play_cuckoo_two_sounds
    jmp room_2_update_clock_workings

.room_2_update_cuckoo_being_thrown_into_room_3
    lda save_game_level_b_cuckoo_room_2_progress
    clc
    adc #2
    sta save_game_level_b_cuckoo_room_2_progress
    cmp #&28 ; '('
    bcc room_2_update_clock_workings
; cuckoo finished being thrown animation, now in room 3
    lda #&ff
    sta save_game_level_b_cuckoo_room_2_progress

.room_2_update_clock_workings
    lda desired_room_index
    cmp #2
    bne room_2_update_suspended_boulder_puzzle
    lda #0
    sta object_spriteid + objectid_clock_workings
    lda save_game_level_b_cuckoo_room_2_progress
    bmi room_2_update_suspended_boulder_puzzle
    cmp #2
    bcc room_2_update_suspended_boulder_puzzle
    tax
    lda #5
    sta temp_sprite_x_offset
    ldy #9
    sta temp_sprite_y_offset
    lda #objectid_clock_workings
    jsr set_object_position_from_cell_xy
    lda #spriteid_cuckoo_open_beak
    sta object_spriteid + objectid_clock_workings
    cpx #&15
    bcc room_2_update_suspended_boulder_puzzle
    lda #spriteid_cuckoo
    sta object_spriteid + objectid_clock_workings

.room_2_update_suspended_boulder_puzzle
    lda #0
    sta player_on_suspended_boulder_holding_object
    lda save_game_level_b_cuckoo_room_2_progress
    cmp #&1b
    bcc room_2_update_boulder_falling_progress
    dec player_on_suspended_boulder_holding_object
.room_2_update_boulder_falling_progress
    lda save_game_level_b_room_2_falling_boulder_progress
    sta falling_boulder_progress
    ldy #&10
    sty fallen_boulder_y
    lda #2
    ldx #&1b
    ldy #&0b
    jsr update_suspended_boulder_at_xy_in_room_a
    lda falling_boulder_progress
    sta save_game_level_b_room_2_falling_boulder_progress
    lda update_room_first_update_flag
    bne return6
    lda desired_room_index
    cmp #2
    bne return6
    lda save_game_level_b_room_2_falling_boulder_progress
    cmp #&10
    bne return6
    jsr play_boulder_landing_sounds
.return6
    rts

.play_boulder_landing_sounds
    lda #0
    ldx #<sound6
    ldy #>sound6
    jsr play_sound_yx
    ldx #<sound7
    ldy #>sound7
    jsr play_sound_yx
    rts

.update_suspended_boulder_at_xy_in_room_a
    sta currently_updating_logic_for_room_index
    stx suspended_boulder_x
    sty suspended_boulder_y
; branch if not the first room update
    lda update_room_first_update_flag
    beq update_falling_boulder
; check if level just changed
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_2_initialise_suspended_boulder
; new level, finish any falling boulder progress immediately
    lda falling_boulder_progress
    beq room_2_initialise_suspended_boulder
    lda #&ff
    sta falling_boulder_progress
.room_2_initialise_suspended_boulder
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne update_rope_sprites_and_boulder_collision_map_local
; draw rope above boulder
    ldx suspended_boulder_x
    ldy #2
    lda suspended_boulder_y
    sec
    sbc #3
    jsr draw_rope
    ldy suspended_boulder_y
    dey
    dey
    lda #sprite_op_flags_erase_to_fg_colour
    sta sprite_op_flags
    lda #spriteid_rope_end
    jsr draw_sprite_a_at_cell_xy
    lda #objectid_rope_broken_top_end
    jsr set_object_position_from_cell_xy
; set boulder sprite for object
    lda #spriteid_boulder
    sta object_spriteid + objectid_suspended_boulder
; broken rope in front of boulder needs offscreen cache
    lda #spriteid_cache2
    sta object_erase_type + objectid_rope_broken_bottom_end
    lda #&e0
    sta object_z_order + objectid_rope_broken_bottom_end
.update_rope_sprites_and_boulder_collision_map_local
    jmp update_rope_sprites_and_boulder_collision_map

.return7_local
    jmp return7

.update_falling_boulder
    lda falling_boulder_progress
    bmi return7_local
    bne boulder_is_falling
; is the player on the boulder and holding an object?
    lda player_on_suspended_boulder_holding_object
    beq return7_local
; start the boulder falling
    lda suspended_boulder_y
    sta falling_boulder_progress
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne boulder_is_falling
.boulder_is_falling
    ldy falling_boulder_progress
    sty previous_boulder_progress
    cpy fallen_boulder_y
    bcc move_falling_boulder_down
    lda #&ff
    sta falling_boulder_progress
    jmp update_rope_sprites_and_boulder_collision_map

.move_falling_boulder_down
    iny
    sty falling_boulder_progress
; check we are in the right room
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return7
; clear collision where the boulder was
    ldx suspended_boulder_x
    dex
    ldy previous_boulder_progress
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq update_rope_sprites_and_boulder_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.update_rope_sprites_and_boulder_collision_map
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return7
; check progress
    lda falling_boulder_progress
    bmi set_rope_ends_once_boulder_landed
    bne set_rope_ends_while_boulder_falling
; set rope and collision when suspended
    lda #spriteid_rope_end_at_object
    sta object_spriteid + objectid_rope_broken_bottom_end
    ldy suspended_boulder_y
    jmp write_boulder_position_to_collision_map

.set_rope_ends_while_boulder_falling
    tay
    lda #spriteid_rope_broken_top_end
    sta object_spriteid + objectid_rope_broken_top_end
    lda #spriteid_rope_broken_falling_end
    sta object_spriteid + objectid_rope_broken_bottom_end
    jmp write_boulder_position_to_collision_map

.set_rope_ends_once_boulder_landed
    lda #spriteid_rope_broken_top_end
    sta object_spriteid + objectid_rope_broken_top_end
    lda #spriteid_rope_broken_bottom_end
    sta object_spriteid + objectid_rope_broken_bottom_end
    ldy fallen_boulder_y
.write_boulder_position_to_collision_map
    ldx suspended_boulder_x
    dex
    lda #objectid_suspended_boulder
    jsr set_object_position_from_cell_xy
    lda #objectid_rope_broken_bottom_end
    jsr set_object_position_from_cell_xy
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return7
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return7
    rts

.falling_boulder_progress
    equb 0
.suspended_boulder_x
    equb 0
.suspended_boulder_y
    equb 0
.fallen_boulder_y
    equb 0
.player_on_suspended_boulder_holding_object
    equb 0

.update_hourglass_handler
    lda update_room_first_update_flag
    beq room_2_update_hourglass
    lda #spriteid_hourglass_menu_item
    sta toolbar_collectable_spriteids+2
    lda #spriteid_hourglass
    sta collectable_spriteids+2
    sta collectable_being_used_spriteids+2
; check for being in room 2
    lda desired_room_index
    cmp #2
    bne return4
; room 2 update
    lda save_game_level_b_got_hourglass_flag
    bne return4
    ldx #&14
    ldy #&11
    lda #objectid_hourglass
    jsr set_object_position_from_cell_xy
    tax
    lda #1
    sta object_direction,x
    lda #spriteid_cache3
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
    lda #spriteid_hourglass
    sta object_spriteid,x
.return4
    rts

.room_2_update_hourglass
    lda desired_room_index
    cmp #2
    bne return8
    lda save_game_level_b_got_hourglass_flag
    bne return8
    ldx #objectid_old_player
    ldy #objectid_hourglass
    jsr test_for_collision_between_objects_x_and_y
    beq return8
    lda #spriteid_hourglass_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #0
    sta object_spriteid + objectid_hourglass
    lda #&ff
    sta save_game_level_b_got_hourglass_flag
.return8
    rts

; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 20                                                           ; initial player X cell
    equb 7                                                            ; initial player Y cell

; ########################################
; ########################################
; ######   |                    |   ######
; #####    |                    |    #####
; ####     |                    |     ####
; ###      |                    |      ###
; ###      |          P         |      ###
; ###      |   ###############  |      ###
; ###      |   ###############  |      ###
;          |                    |      ###
;          |                    |      ###
;          |          S         |      ###
;          |                    |      ###
;          |                    |      ###
;          |                    |      ###
; #####    |                    |      ###
; #####    |     OOO     OOO    |      ###
; ###      |     OOO     OOO    |      ###
; ###      |     OOOOSOOOSOO    |      ###
; ###      |     OOOOOOOOOOO    |      ###
; ###          ###############         ###
; ###         #################        ###
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
; draw 6x1 rectangle at (0,2)
    ldy #2
    lda #6
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (34,2)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (35,3)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,4)
    ldx #0
    iny
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,4)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (0,5)
    ldx #0
    iny
    dec width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x17 rectangle at (37,5)
    ldx #&25 ; '%'
    lda #&11
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,15)
    ldx #0
    ldy #&0f
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (0,17)
    ldy #&11
    lda #3
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x5 rectangle at (0,22)
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x1 rectangle at (12,21)
    ldx #&0c
    dey
    lda #&11
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 15x1 rectangle at (13,20)
    inx
    dey
    lda #&0f
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 15x2 rectangle at (13,7)
    ldx #&0d
    ldy #7
    lda #&0f
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (9,2) length 18
; draw rope
    ldx #9
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (30,2) length 18
    ldx #&1e
    jsr draw_rope
; draw table at (15,18) of size (11x2)
    lda #&0b
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&0f
    ldy #&12
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (19,18)
    ldx #&13
    jsr draw_sprite_a_at_cell_xy
; draw table at (23,18)
    ldx #&17
    jsr draw_sprite_a_at_cell_xy
; draw boulder at (15,16) of size (3x2)
    lda #3
    sta width_in_cells
    ldx #&0f
    ldy #&10
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (23,16) of size (3x2)
    ldx #&17
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw ball at (20,11)
    ldx #&14
    ldy #&0b
    lda #spriteid_ball
    jsr draw_sprite_a_at_cell_xy
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_3_game_update_loop
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_3_update_handler
    lda #3
    sta currently_updating_logic_for_room_index
; update fire
    lda #3
    ldx #&14
    ldy #&0b
    jsr update_brazier_and_fire
    lda #4
    inx
    jsr update_brazier_and_fire
; position and update the spell collectable object
    ldx #&14
    lda #4
    sta temp_sprite_x_offset
    ldy #&12
    lda #objectid_spell
    jsr update_level_completion
; check for room 3 (return if not)
    lda desired_room_index
    cmp #3
    bne return5
    lda update_room_first_update_flag
    beq room_3_not_first_update
; first update in room 3
    lda save_game_level_b_cuckoo_room_2_progress
    cmp #2
    bcc return5
    ldx #&23 ; '#'
    lda #3
    sta temp_sprite_x_offset
    ldy #&15
    lda #objectid_cuckoo
    jsr set_object_position_from_cell_xy
; set properties of the cuckoo in room 3
    tax
    lda #1
    sta object_direction,x
    lda #spriteid_cache1
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
    lda #spriteid_cuckoo
    sta object_spriteid,x
    jmp return5

.room_3_not_first_update
    ldx #objectid_old_player
    ldy #objectid_cuckoo
    jsr test_for_collision_between_objects_x_and_y
    beq return5
    lda #spriteid_cuckoo_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #0
    sta object_spriteid + objectid_pendulum
    lda #0
    sta save_game_level_b_cuckoo_room_2_progress
.return5
    rts

.envelope3
    equb 5                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 40                                                           ; change of amplitude per step during attack phase
    equb 246                                                          ; change of amplitude per step during decay phase
    equb 246                                                          ; change of amplitude per step during sustain phase
    equb 236                                                          ; change of amplitude per step during release phase
    equb 100                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound_cuckoo1
    equw &0013                                                        ; channel
    equw 5                                                            ; amplitude
    equw 149                                                          ; pitch
    equw 3                                                            ; duration
.sound_cuckoo2
    equw 3                                                            ; channel
    equw 5                                                            ; amplitude
    equw 137                                                          ; pitch
    equw 2                                                            ; duration
.envelope2
    equb 6                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 100                                                          ; change of amplitude per step during attack phase
    equb 206                                                          ; change of amplitude per step during decay phase
    equb 206                                                          ; change of amplitude per step during sustain phase
    equb 156                                                          ; change of amplitude per step during release phase
    equb 100                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound_clock_bass
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound_tick
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 250                                                          ; pitch
    equw 0                                                            ; duration
.sound_tock
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 190                                                          ; pitch
    equw 0                                                            ; duration
.envelope_unused
    equb 7                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 255                                                          ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 1                                                            ; number of steps in section 1
    equb 1                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 120                                                          ; change of amplitude per step during attack phase
    equb 252                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 248                                                          ; change of amplitude per step during release phase
    equb 120                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound_unused
    equw &0013                                                        ; channel
    equw 7                                                            ; amplitude
    equw 200                                                          ; pitch
    equw 1                                                            ; duration
.envelope1
    equb 7                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 55                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 250                                                          ; change of amplitude per step during release phase
    equb 110                                                          ; target of level at end of attack phase
    equb 55                                                           ; target of level at end of decay phase
.sound7
    equw &0010                                                        ; channel
    equw 7                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound6
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 210                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %00100000
    equb %00010000
    equb %10001000
    equb %01000100
    equb %00100011
    equb %00010000
    equb %00001000
    equb %00001000
.ground_fill_2x2_top_right
    equb %00000100
    equb %00001000
    equb %00010001
    equb %11100010
    equb %00000100
    equb %00001000
    equb %00001000
    equb %00001000
.ground_fill_2x2_bottom_left
    equb %00010000
    equb %00010000
    equb %00010000
    equb %00100000
    equb %01000111
    equb %10001000
    equb %00010000
    equb %00100000
.ground_fill_2x2_bottom_right
    equb %00010000
    equb %00010000
    equb %00001000
    equb %11000100
    equb %00100010
    equb %00010001
    equb %00001000
    equb %00000100
IF swr_renderer_enabled
INCLUDE "build/runtime/levelB_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelB.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelB"
ENDIF
ENDIF
.pydis_end

save "build/dataB", pydis_start, pydis_end
