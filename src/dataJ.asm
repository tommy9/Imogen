; *************************************************************************************
;
; Level J: 'BABBOONACY'
;
; Save game variables:
;
;     save_game_level_j_got_cannonball_progress                  ($0a30):
;               0: untouched
;              1+: cannonball thrown, animating
;             $ff: held by babboon
;
;     save_game_level_j_room_0_babboon_animation                 ($0a31):
;               0: untouched
;              1+: animating babboon
;             $37: descending with cannonball
;             $3f: cannonball thrown
;
;     save_game_level_j_partition_progress                       ($0a32):
;               0: untouched
;             1,2: partition falling over
;             $ff: partition fallen over
;
; Solution:
;
;   1. Move to left room and collect a cannonball that's thrown, then move back to room
;      to the right.
;   2. Stand next to the babboon and throw the cannonball at the babboon.
;   3. Quickly move back to the leftmost room and collect another cannonball.
;   4. Quickly move back to the initial room and jump over the babboon before they
;      reach the top of the rope.
;   5. Jump across the bottom of the three ropes, avoiding the babboons.
;   6. Throw the cannonball at the partition to knock it over, then collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_babboon1                      = 3
objectid_babboon2                      = 4
objectid_babboon3                      = 5
objectid_cannonball                    = 2
objectid_fire                          = 5
objectid_old_cannonball                = 13
objectid_partition                     = 4
objectid_spell                         = 3
spriteid_babboon1                      = 204
spriteid_babboon2                      = 205
spriteid_babboon_push                  = 206
spriteid_cannonball1                   = 200
spriteid_cannonball2                   = 208
spriteid_cannonball_and_arm            = 209
spriteid_cannonball_menu_item          = 202
spriteid_collision                     = 203
spriteid_erase_babboon1_or_partition   = 207
spriteid_erase_babboon2                = 214
spriteid_erase_babboon3                = 215
spriteid_erase_cannonball              = 201
spriteid_partition                     = 211
spriteid_partition_fallen              = 213
spriteid_partition_falling             = 212
spriteid_partition_remains             = 210

; Memory locations
room_exit_direction                                 = &0070
temp_babboon_y                                      = &0070
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
save_game_level_j_got_cannonball_progress           = &0a30
save_game_level_j_room_0_babboon_animation          = &0a31
save_game_level_j_partition_progress                = &0a32
cannonball_fast_forward_steps                       = &0a6f
cannonball_x_low                                    = &0a70
cannonball_x_high                                   = &0a71
cannonball_y_low                                    = &0a72
cannonball_y_high                                   = &0a73
cannonball_direction                                = &0a74
cannonball_room                                     = &0a75
cannonball_animation_step                           = &0a76
room_0_babboon_animation_step                       = &0a77
room_0_babboon_y_low                                = &0a78
room_0_cannonball_throw_animation_step              = &0a79
room_1_babboon_y                                    = &0a7a
room_1_babboon_animation                            = &0a7b
room_1_babboon_animation_step                       = &0a7c
delay_before_babboon_moves_up_rope                  = &0a7d
delay_timer                                         = &0a7e

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelJ_sprite_table - level_data
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
    equb 1
.initial_room_index_cheat
    equb 2
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "BABBOONACY", &0D

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
    sta save_game_level_j_got_cannonball_progress
.developer_mode_inactive
    lda save_game_level_j_got_cannonball_progress
    cmp #&ff
    bne return1
    lda #spriteid_cannonball_menu_item
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
    jsr update_cannonball
    jsr room_0_update_handler
    jsr room_1_update_handler
    jsr room_2_update_handler
    jsr room_3_update_handler
    rts

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 20                                                           ; initial player X cell
    equb 15                                                           ; initial player Y cell

; ########################################
; ########################################
; ####      |                  |
; ###       |                  |
; ###       |                  |
; ###       |                  |
; ###       |                  |
; ###       |                  |
; ###       |   ############   |   #######
; ###       |   ############   |   #######
;           |                  |       ###
;           |                  |       ###
;           |                  |       ###
;           |                  |       ###
;           |         P        |       ###
; #######   |   ############   |       ###
; #######   |   ############   |       ###
; ###       |                  |       ###
; ###       |                  |       ###
; ###       |                  |       ###
; ###                                  ###
; ###                                  ###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (0,3)
    iny
    dec width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (0,15)
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 3x14 rectangle at (37,8)
    ldx #&25 ; '%'
    ldy #8
    lda #&0e
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    lda #4
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (33,8)
    ldx #&21 ; '!'
    ldy #8
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (14,8)
    ldx #&0e
    lda #&0c
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (14,15)
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (10,2) length 18
    ldx #&0a
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (29,2) length 18
    ldx #&1d
    jsr draw_rope
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

.babboon_base_animation
    equb 0
.babboon_idle_animation
    equb spriteid_babboon1
    equb   0, &80
.babboon_climb_up_animation
    equb spriteid_babboon2
    equb 252
    equb spriteid_babboon1
    equb 252, &80
.babboon_climb_down_animation
    equb spriteid_babboon1
    equb   6, &80

; check for first update in room (branch if not)
.room_1_update_handler
    lda update_room_first_update_flag
    beq room_1_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_room
    lda #babboon_idle_animation - babboon_base_animation
    sta room_1_babboon_animation
    sta room_1_babboon_animation_step
    lda #&38 ; '8'
    sta room_1_babboon_y
.initialise_room
    lda desired_room_index
    cmp #1
    bne update_babboon_object_if_in_room_1_local
; initialise room 1 babboon
    lda #spriteid_erase_babboon1_or_partition
    sta object_erase_type + objectid_babboon1
    lda #&c0
    sta object_z_order + objectid_babboon1
    lda #&ef
    sta object_x_low + objectid_babboon1
    lda #&ff
    sta object_direction + objectid_babboon1
.update_babboon_object_if_in_room_1_local
    jmp update_babboon_object_if_in_room_1

.room_1_not_first_update
    lda room_1_babboon_animation_step
    clc
    adc #2
    tay
    lda babboon_base_animation,y
    cmp #&80
    bne got_babboon_animation_step_in_y
    ldy room_1_babboon_animation
.got_babboon_animation_step_in_y
    lda room_1_babboon_animation
    cmp #babboon_climb_down_animation - babboon_base_animation
    bne babboon_not_climbing_down
; babboon climbing down
    lda room_1_babboon_y
    cmp #&98
    bne set_animation_step
    jmp set_babboon_idle

.babboon_not_climbing_down
    lda room_1_babboon_animation
    cmp #babboon_climb_up_animation - babboon_base_animation
    bne check_if_babboon_idle
    cpy room_1_babboon_animation
    bne set_animation_step
.set_babboon_idle
    ldy #babboon_idle_animation - babboon_base_animation
    sty room_1_babboon_animation
    lda #&18
    sta delay_before_babboon_moves_up_rope
.check_if_babboon_idle
    lda room_1_babboon_animation
    cmp #babboon_idle_animation - babboon_base_animation
    bne set_animation_step
; check_if_babboon_should_climb_up
    lda room_1_babboon_y
    cmp #&38 ; '8'
    beq set_animation_step
    lda delay_before_babboon_moves_up_rope
    beq set_babboon_climbing_up
    dec delay_before_babboon_moves_up_rope
    jmp set_animation_step

.set_babboon_climbing_up
    ldy #babboon_climb_up_animation - babboon_base_animation
    sty room_1_babboon_animation
.set_animation_step
    sty room_1_babboon_animation_step
; update room 1 babboon y
    iny
    lda babboon_base_animation,y
    clc
    adc room_1_babboon_y
    sta room_1_babboon_y
    cmp #&99
    bcc update_babboon_object_if_in_room_1
    lda #&98
    sta room_1_babboon_y
.update_babboon_object_if_in_room_1
    lda desired_room_index
    cmp #1
    bne return2
; update babboon object
    ldy room_1_babboon_animation_step
    lda babboon_base_animation,y
    sta object_spriteid + objectid_babboon1
    lda room_1_babboon_y
    sta object_y_low + objectid_babboon1
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne return2
; check for player babboon collision
    ldx #objectid_player
    ldy #objectid_babboon1
    jsr test_for_collision_between_objects_x_and_y
    beq check_babboon_cannonball_collision
    lda #&80
    sta player_wall_collision_reaction_speed
.check_babboon_cannonball_collision
    ldx #objectid_babboon1
    ldy #objectid_cannonball
    jsr test_for_collision_between_objects_x_and_y
    beq return2
; collision found, set babboon climbing down the rope
    lda #babboon_climb_down_animation - babboon_base_animation
    sta room_1_babboon_animation
    sta room_1_babboon_animation_step
    jsr show_cannonball_collision
.return2
    rts

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 16                                                           ; initial player X cell
    equb 15                                                           ; initial player Y cell

; ########################################
; ########################################
;           |          |   |   |      ####
;           |          |   |   |       ###
;           |          |   |   |       ###
;           |          |   |   |       ###
;           |          |   |   |       ###
;           |          |   |   |       ###
; #######   |          |   |   |       ###
; #######   |          |   |   |       ###
; ###       |          |   |   |
; ###       |          |   |   |
; ###       |          |   |   |
; ###       |
; ###       |     P
; ###       |   ####               #######
; ###       |   ####               #######
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###                                  ###
; ###                                  ###
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
; draw 255x1 rectangle at (36,2)
    ldx #&24 ; '$'
    ldy #2
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x7 rectangle at (37,3)
    inx
    iny
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x7 rectangle at (37,15)
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 3x14 rectangle at (0,8)
    ldx #0
    ldy #8
    lda #3
    sta width_in_cells
    lda #&0e
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (3,8)
    ldx #3
    inc width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (33,15)
    ldx #&21 ; '!'
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (14,15)
    ldx #&0e
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (10,2) length 18
    ldx #&0a
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (21,2) length 11
    ldx #&15
    lda #&0b
    jsr draw_rope
; draw rope at (25,2) length 11
    ldx #&19
    jsr draw_rope
; draw rope at (29,2) length 11
    ldx #&1d
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

; check for first update in room (branch if not)
.room_2_update_handler
    lda update_room_first_update_flag
    beq update_delay_timer
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq skip_reset_delay
    lda #0
    sta delay_timer
.skip_reset_delay
    lda desired_room_index
    cmp #2
    bne update_room_2_babboons_local
    lda #spriteid_erase_babboon1_or_partition
    sta object_erase_type + objectid_babboon1
    lda #spriteid_erase_babboon2
    sta object_erase_type + objectid_babboon2
    lda #spriteid_erase_babboon3
    sta object_erase_type + objectid_babboon3
    lda #&af
    sta object_x_low + objectid_babboon1
    lda #&ff
    sta object_direction + objectid_babboon1
    lda #&cf
    sta object_x_low + objectid_babboon2
    lda #&ff
    sta object_direction + objectid_babboon2
    lda #&ef
    sta object_x_low + objectid_babboon3
    lda #&ff
    sta object_direction + objectid_babboon3
.update_room_2_babboons_local
    jmp update_room_2_babboons

.update_delay_timer
    inc delay_timer
    lda delay_timer
    cmp #&3c ; '<'
    bcc update_room_2_babboons
    lda #0
    sta delay_timer
.update_room_2_babboons
    lda desired_room_index
    cmp #2
    bne return3
    lda delay_timer
    ldx #objectid_babboon1
    jsr update_room_2_babboon
    lda delay_timer
    clc
    adc #&28 ; '('
    ldx #objectid_babboon2
    jsr update_room_2_babboon
    lda delay_timer
    clc
    adc #&32 ; '2'
    ldx #objectid_babboon3
    jsr update_room_2_babboon
.return3
    rts

; bring the delay timer (in A) into range 0-$3c
.update_room_2_babboon
    cmp #&3c ; '<'
    bcc got_delay_timer
    sec
    sbc #&3c ; '<'
.got_delay_timer
    tay
    asl a
    asl a
    sta temp_babboon_y
    lda #spriteid_babboon1
    sta object_spriteid,x
    lda #&60 ; '`'
    sec
    sbc temp_babboon_y
    cpy #&0a
    bcc store_y_position
    lda #&38 ; '8'
    cpy #&1e
    bcc store_y_position
    tya
    sec
    sbc #&1e
    asl a
    asl a
    sta temp_babboon_y
    lda #&38 ; '8'
    clc
    adc temp_babboon_y
    cpy #&28 ; '('
    bcc store_y_position
    lda #&60 ; '`'
.store_y_position
    sta object_y_low,x
    and #7
    beq check_babboon_player_collision
    lda #spriteid_babboon2
    sta object_spriteid,x
; check for first update in room (branch if so)
.check_babboon_player_collision
    lda update_room_first_update_flag
    bne return4
    ldy #objectid_player
    jsr test_for_collision_between_objects_x_and_y
    beq return4
    lda #&80
    sta player_wall_collision_reaction_speed
.return4
    rts

; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 4                                                            ; initial player X cell
    equb 15                                                           ; initial player Y cell

; ########################################
; ########################################
; ####      |                         ####
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###       |   ##########################
; ###       |   ##########################
;           |                          ###
;           |                          ###
;           |                          ###
;           |                          ###
;     P     |                          ###
; #######   |   ##########################
; #######   |   ##########################
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###                                  ###
; ###                                  ###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (0,15)
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (37,3)
    ldx #&25 ; '%'
    ldy #3
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    lda #4
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 23x2 rectangle at (14,15)
    ldx #&0e
    lda #&17
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 23x2 rectangle at (14,8)
    ldy #8
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (10,2) length 18
    ldx #&0a
    ldy #2
    lda #&12
    jsr draw_rope
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
    ldx #&1d
    lda #4
    sta temp_sprite_x_offset
    ldy #&0f
    lda #objectid_spell
    jsr update_level_completion
    ldx #3
    ldy #6
    lda #5
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_3_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_room_3
    lda save_game_level_j_partition_progress
    beq initialise_room_3
    lda #&ff
    sta save_game_level_j_partition_progress
.initialise_room_3
    lda desired_room_index
    cmp #3
    bne update_partition_local
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    ldx #&11
    ldy #&0f
    lda #spriteid_partition_remains
    jsr draw_sprite_a_at_cell_xy
    lda #4
    jsr set_object_position_from_cell_xy
    lda #spriteid_erase_babboon1_or_partition
    sta object_erase_type + objectid_partition
    lda #&c0
    sta object_z_order + objectid_partition
.update_partition_local
    jmp update_partition

.room_3_not_first_update
    lda save_game_level_j_partition_progress
    bmi update_partition
    bne partition_animation_in_progress
; check we are in room 3
    lda desired_room_index
    cmp #3
    bne update_partition
; check for cannonball partition collision (branch if none)
    ldx #objectid_cannonball
    ldy #objectid_partition
    jsr test_for_collision_between_objects_x_and_y
    beq update_partition
.partition_animation_in_progress
    ldy save_game_level_j_partition_progress
    iny
    sty save_game_level_j_partition_progress
    cpy #2
    bcc update_partition
; write to clear collision map from partition area
    ldy #&ff
    sty save_game_level_j_partition_progress
    lda desired_room_index
    cmp #3
    bne update_partition
    ldx #&11
    ldy #&0a
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp update_partition

; unused?
    lda #0
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
.update_partition
    lda desired_room_index
    cmp #3
    bne return5
    ldy save_game_level_j_partition_progress
    bpl set_partition_object
    ldy #2
.set_partition_object
    lda partition_animation,y
    sta object_spriteid + objectid_partition
; write collision for partition
    ldx #&11
    ldy #&0a
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda save_game_level_j_partition_progress
    bpl write_collision_if_needed
    ldy #&0e
    lda #6
    sta width_in_cells
    lda #1
    sta height_in_cells
.write_collision_if_needed
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return5
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return5
    rts

.partition_animation
    equb spriteid_partition
    equb spriteid_partition_falling
    equb spriteid_partition_fallen

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
; ####      |                         ####
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ########  |  ###########################
; ########  |  ###########################
; ###       |                  |
; ###       |                  |
; ###       |                  |
; ###       |                  |
; ###       |                  |
; ###       |                  |   #######
; ###       |                  |   #######
; ###       |                  |       ###
; ###       |                  |       ###
; ###       |                  |       ###
; ###                                  ###
; ###                 P                ###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (37,17)
    ldy #&11
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (3,8)
    ldx #3
    ldy #8
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (13,8)
    ldx #&0d
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (33,15)
    ldx #&21 ; '!'
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (10,2) length 18
    ldx #&0a
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (29,10) length 10
    ldx #&1d
    ldy #&0a
    lda #&0a
    jsr draw_rope
; draw cannonballs
    lda #0
    sta sprite_x_base_high
    sta sprite_y_base_high
    lda #spriteid_cannonball2
    sta sprite_id
    lda #&68 ; 'h'
    sta sprite_x_base_low
    lda #&3e ; '>'
    sta sprite_y_base_low
; draw base of three cannonballs
    ldx #3
.draw_base_loop
    jsr sprite_op
    lda sprite_x_base_low
    clc
    adc #8
    sta sprite_x_base_low
    dex
    bne draw_base_loop
; draw second row of cannonballs
    lda #&6c ; 'l'
    sta sprite_x_base_low
    lda sprite_y_base_low
    sec
    sbc #6
    sta sprite_y_base_low
    ldx #2
.draw_second_row_loop
    jsr sprite_op
    lda sprite_x_base_low
    clc
    adc #8
    sta sprite_x_base_low
    dex
    bne draw_second_row_loop
; draw top cannonball
    lda #&70 ; 'p'
    sta sprite_x_base_low
    lda sprite_y_base_low
    sec
    sbc #6
    sta sprite_y_base_low
    jsr sprite_op
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.babboon_room_0_animations
    equb 0
.babboon_room_0_move_up_animation
    equb spriteid_babboon2
    equb 252
    equb spriteid_babboon1
    equb 252
    equb spriteid_babboon2
    equb 252
    equb spriteid_babboon1
    equb 252
    equb spriteid_babboon2
    equb 252
    equb spriteid_babboon1
    equb 252
    equb spriteid_babboon2
    equb 252
    equb spriteid_babboon1
    equb 252
    equb spriteid_babboon2
    equb 252
    equb spriteid_babboon1
    equb 252
    equb spriteid_babboon1
    equb 0
    equb spriteid_babboon_push
    equb 0
    equb spriteid_babboon_push
    equb   0, &80
.babboon_room_0_move_down_animation
    equb spriteid_babboon1
    equb 0
    equb spriteid_babboon1
    equb 0
    equb spriteid_babboon2
    equb 4
    equb spriteid_babboon1
    equb 4
    equb spriteid_babboon2
    equb 4
    equb spriteid_babboon1
    equb 4
    equb spriteid_babboon2
    equb 4
    equb spriteid_babboon1
    equb 4
    equb spriteid_babboon2
    equb 4
    equb spriteid_babboon1
    equb 4
    equb spriteid_babboon2
    equb 4
    equb spriteid_babboon1
    equb 4
    equb spriteid_babboon1
    equb   0, &80
.babboon_room_0_stationary1_animation
    equb spriteid_babboon1
    equb   0, &80
.babboon_room_0_push_animation
    equb spriteid_babboon_push
    equb 0
    equb spriteid_babboon_push
    equb   0, &80
.babboon_room_0_stationary2_animation
    equb spriteid_babboon1
    equb   0, &80
; (dX,dY) pairs of bytes when throwing a cannonball
.cannonball_throw_animation
    equb 0
    equb 8, 1
    equb 16,  3
    equb 24,  6
    equb 32, 10
    equb 40, 16
    equb 47, 24
    equb 54, 34
    equb 60, 45
    equb 65, 57
    equb 68, 70
    equb 0

; check for first update in room (branch if not)
.room_0_update_handler
    lda update_room_first_update_flag
    beq update_babboon_animation_step
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_room_0
; initialise level
    lda #&3f ; '?'
    sta save_game_level_j_room_0_babboon_animation
    sta room_0_babboon_animation_step
    lda #&68 ; 'h'
    sta room_0_babboon_y_low
.initialise_room_0
    lda desired_room_index
    cmp #0
    bne update_room_0_babboon_and_cannonball_puzzle_local
    lda #spriteid_erase_babboon1_or_partition
    sta object_erase_type + objectid_babboon1
    lda #&c0
    sta object_z_order + objectid_babboon1
    lda #&50 ; 'P'
    sta object_x_low + objectid_babboon1
.update_room_0_babboon_and_cannonball_puzzle_local
    jmp update_room_0_babboon_and_cannonball_puzzle

.update_babboon_animation_step
    lda room_0_babboon_animation_step
    clc
    adc #2
    tay
    lda babboon_room_0_animations,y
    cmp #&80
    bne check_if_room_0_babboon_is_climbing_up_rope
    ldy save_game_level_j_room_0_babboon_animation
.check_if_room_0_babboon_is_climbing_up_rope
    lda save_game_level_j_room_0_babboon_animation
    cmp #babboon_room_0_move_up_animation - babboon_room_0_animations
    bne check_if_room_0_babboon_is_stationary
    cpy save_game_level_j_room_0_babboon_animation
    bne set_room_0_babboon_animation_step
    ldy #babboon_room_0_move_down_animation - babboon_room_0_animations
    lda #babboon_room_0_stationary1_animation - babboon_room_0_animations
    sta save_game_level_j_room_0_babboon_animation
    lda #&ff
    sta room_0_cannonball_throw_animation_step
    jmp set_room_0_babboon_animation_step

.check_if_room_0_babboon_is_stationary
    lda save_game_level_j_room_0_babboon_animation
    cmp #babboon_room_0_stationary1_animation - babboon_room_0_animations
    bne check_if_room_0_babboon_is_throwing_cannonball
    cpy save_game_level_j_room_0_babboon_animation
    bne set_room_0_babboon_animation_step
    lda desired_room_index
    cmp #0
    bne set_room_0_babboon_animation_step
    lda #1
    sta room_0_cannonball_throw_animation_step
    ldy #babboon_room_0_push_animation - babboon_room_0_animations
    lda #babboon_room_0_stationary2_animation - babboon_room_0_animations
    sta save_game_level_j_room_0_babboon_animation
    jmp set_room_0_babboon_animation_step

.check_if_room_0_babboon_is_throwing_cannonball
    ldx room_0_cannonball_throw_animation_step
    beq check_if_in_room_0_and_cannonball_animations_are_in_progress
    inx
    inx
    stx room_0_cannonball_throw_animation_step
    lda cannonball_throw_animation,x
    cmp #0
    bne set_room_0_babboon_animation_step
    lda #0
    sta room_0_cannonball_throw_animation_step
    lda desired_room_index
    cmp #0
    bne set_room_0_babboon_animation_step
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_cannonball
    jmp set_room_0_babboon_animation_step

.check_if_in_room_0_and_cannonball_animations_are_in_progress
    lda desired_room_index
    cmp #0
    bne set_room_0_babboon_animation_step
    lda save_game_level_j_got_cannonball_progress
    cmp #&ff
    beq set_room_0_babboon_animation_step
    ora #0
    beq start_babboon_move_up_animation
    lda desired_room_index
    cmp cannonball_room
    beq set_room_0_babboon_animation_step
    lda cannonball_fast_forward_steps
    cmp #4
    bcc set_room_0_babboon_animation_step
.start_babboon_move_up_animation
    ldy #babboon_room_0_move_up_animation - babboon_room_0_animations
    sty save_game_level_j_room_0_babboon_animation
.set_room_0_babboon_animation_step
    sty room_0_babboon_animation_step
    iny
    lda babboon_room_0_animations,y
    clc
    adc room_0_babboon_y_low
    sta room_0_babboon_y_low
    jmp update_room_0_babboon_and_cannonball_puzzle

.return6_local
    jmp return6

.update_room_0_babboon_and_cannonball_puzzle
    lda desired_room_index
    cmp #0
    bne return6_local
    ldy room_0_babboon_animation_step
    lda babboon_room_0_animations,y
    sta object_spriteid + objectid_babboon1
    lda room_0_babboon_y_low
    sta object_y_low + objectid_babboon1
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne skip_setting_collision_result
    ldx #objectid_player
    ldy #objectid_babboon1
    jsr test_for_collision_between_objects_x_and_y
    beq skip_setting_collision_result
; fall straight down
    lda #&80
    sta player_wall_collision_reaction_speed
.skip_setting_collision_result
    ldx room_0_cannonball_throw_animation_step
    beq return6_local
; set cannonball object, starting at the babboon coordinates with the cannonball and
; arm sprite
    lda #spriteid_erase_cannonball
    sta object_erase_type + objectid_cannonball
    lda #&40 ; '@'
    sta object_z_order + objectid_cannonball
    lda object_x_low + objectid_babboon1
    sta object_x_low + objectid_cannonball
    lda #0
    sta object_x_high + objectid_cannonball
    lda object_y_low + objectid_babboon1
    sta object_y_low + objectid_cannonball
    lda #0
    sta object_y_high + objectid_cannonball
    lda #1
    sta object_direction + objectid_cannonball
    lda #spriteid_cannonball_and_arm
    sta object_spriteid + objectid_cannonball
    cpx #&ff
    beq return6_local
; update cannonball position based on animation
    lda cannonball_throw_animation,x
    clc
    adc #&58 ; 'X'
    sta object_x_low + objectid_cannonball
    inx
    lda cannonball_throw_animation,x
    clc
    adc #&68 ; 'h'
    sta object_y_low + objectid_cannonball
    lda #spriteid_cannonball2
    sta object_spriteid + objectid_cannonball
    inx
    lda cannonball_throw_animation,x
    cmp #0
    bne update_player_cannonball_collision_to_collect_cannonball
    lda #spriteid_collision
    sta object_spriteid + objectid_cannonball
; check for first update in room (branch if so)
.update_player_cannonball_collision_to_collect_cannonball
    lda update_room_first_update_flag
    bne return6
    ldx #objectid_old_player
    ldy #objectid_old_cannonball
    jsr test_for_collision_between_objects_x_and_y
    beq test_for_cannonball_end_of_life
; cannonball collected
    lda #spriteid_cannonball_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_cannonball
    sta room_0_cannonball_throw_animation_step
    lda #&ff
    sta save_game_level_j_got_cannonball_progress
    jmp return6

.test_for_cannonball_end_of_life
    lda object_spriteid + objectid_cannonball
    cmp #spriteid_collision
    bne return6
    jsr show_cannonball_collision
    lda #0
    sta save_game_level_j_got_cannonball_progress
.return6
    rts

.cannonball_animations
    equb 0
.cannonball_animation1
    equb 0, 0
    equb   6, &fc
    equb   6, &ff
    equb 6, 2
    equb 4, 4
    equb 2, 6
    equb &80
.cannonball_animation2
    equb 0, 8
    equb &80
.cannonball_animation3
    equb 0, 0
    equb &80

; check for first update in room (branch if not)
.update_cannonball
    lda update_room_first_update_flag
    beq update_cannonball_not_first_update
; initialise
    lda #spriteid_cannonball_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_cannonball1
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq check_if_cannonball_in_current_room
    lda save_game_level_j_got_cannonball_progress
    cmp #&ff
    beq check_if_cannonball_in_current_room
; reset cannonball animation progress
    lda #0
    sta save_game_level_j_got_cannonball_progress
.check_if_cannonball_in_current_room
    lda desired_room_index
    cmp cannonball_room
    bne hide_cannonball1
    lda save_game_level_j_got_cannonball_progress
    beq hide_cannonball1
    cmp #&ff
    beq hide_cannonball1
    jsr set_cannonball_object
.fast_forward_cannonball_loop
    lda desired_room_index
    cmp cannonball_room
    bne hide_cannonball1
    lda cannonball_fast_forward_steps
    beq hide_cannonball1
    dec cannonball_fast_forward_steps
    ldx #objectid_cannonball
    jsr copy_object_state_to_old
    jsr move_to_next_cannonball_animation_step
    jmp fast_forward_cannonball_loop

.hide_cannonball1
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_cannonball
.return7_local
    jmp return7

.update_cannonball_not_first_update
    lda object_spriteid_old + objectid_cannonball
    sta remember_cannonball_spriteid
    lda save_game_level_j_got_cannonball_progress
    beq return7_local
    bmi check_if_player_is_using_cannonball
    lda desired_room_index
    cmp cannonball_room
    beq update_cannonball_in_room
    lda cannonball_fast_forward_steps
    bmi return7_local
    inc cannonball_fast_forward_steps
    jmp return7

.check_if_player_is_using_cannonball
    lda #spriteid_cannonball_menu_item
    cmp player_using_object_spriteid
    bne return7_local
; check if just stopped 'using' cannonball
    cmp previous_player_using_object_spriteid
    beq return7_local
; remove cannonabll from toolbar
    lda #spriteid_cannonball_menu_item
    jsr remove_item_from_toolbar_menu
; remove accessory object
    lda #0
    sta object_spriteid + objectid_player_accessory
    sta player_using_object_spriteid
    sta player_held_object_spriteid
; add cannonball to room
    lda desired_room_index
    sta cannonball_room
; set current and next animations
    lda #cannonball_animation1 - cannonball_animations
    sta cannonball_animation_step
    lda #cannonball_animation2 - cannonball_animations
    sta save_game_level_j_got_cannonball_progress
; set cannonball position to be where accessory was
    lda object_x_low + objectid_player_accessory
    sta cannonball_x_low
    lda object_x_high + objectid_player_accessory
    sta cannonball_x_high
    lda object_y_low + objectid_player_accessory
    sta cannonball_y_low
    lda object_y_high + objectid_player_accessory
    sta cannonball_y_high
; set cannonball direction
    lda object_direction
    sta cannonball_direction
    jsr set_cannonball_object
; cannonball was drawn as accessory object, so copy to the old state
    ldx #objectid_cannonball
    jsr copy_object_state_to_old
.update_cannonball_in_room
    jsr move_to_next_cannonball_animation_step
    lda remember_cannonball_spriteid
    sta object_spriteid_old + objectid_cannonball
    lda desired_room_index
    cmp cannonball_room
    beq check_cannonball_last_animation
    lda #0
    sta cannonball_fast_forward_steps
    jmp return7

.check_cannonball_last_animation
    lda cannonball_animation_step
    cmp #cannonball_animation3 - cannonball_animations
    bne return7
    jsr show_cannonball_collision
.return7
    rts

.show_cannonball_collision
    lda #spriteid_collision
    sta object_spriteid + objectid_cannonball
    lda #cannonball_animation3 - cannonball_animations
    sta save_game_level_j_got_cannonball_progress
    sta cannonball_animation_step
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
; check player cannonball collision
    ldx #objectid_player
    ldy #objectid_cannonball
    jsr test_for_collision_between_objects_x_and_y
    beq return8
; decide on reaction direction based on relative x position of the cannonball and
; player
    lda #&fa
    sta player_wall_collision_reaction_speed
    lda object_x_low + objectid_cannonball
    sec
    sbc object_x_low
    lda object_x_high + objectid_cannonball
    sbc object_x_high
    bpl return8
    lda #6
    sta player_wall_collision_reaction_speed
.return8
    rts

.move_to_next_cannonball_animation_step
    lda cannonball_animation_step
    clc
    adc #2
    tay
    lda cannonball_animations,y
    cmp #&80
    bne check_for_final_cannonball_animation
    ldy save_game_level_j_got_cannonball_progress
.check_for_final_cannonball_animation
    lda save_game_level_j_got_cannonball_progress
    cmp #cannonball_animation3 - cannonball_animations
    bne save_cannonball_animation_step
    cpy save_game_level_j_got_cannonball_progress
    bne save_cannonball_animation_step
    lda #0
    sta cannonball_animation_step
    sta save_game_level_j_got_cannonball_progress
    sta object_spriteid + objectid_cannonball
    sta cannonball_fast_forward_steps
    jmp return9

.save_cannonball_animation_step
    sty cannonball_animation_step
    lda cannonball_animations,y
    ldx cannonball_direction
    bpl sign_extend_based_on_direction
    eor #&ff
    clc
    adc #1
.sign_extend_based_on_direction
    ldx #0
    ora #0
    bpl add_animation_with_direction_to_cannonball_x
    dex
.add_animation_with_direction_to_cannonball_x
    clc
    adc cannonball_x_low
    sta cannonball_x_low
    txa
    adc cannonball_x_high
    sta cannonball_x_high
    iny
    lda cannonball_animations,y
    ldx #0
    ora #0
    bpl add_animation_to_cannonball_y
    dex
.add_animation_to_cannonball_y
    clc
    adc cannonball_y_low
    sta cannonball_y_low
    txa
    adc cannonball_y_high
    sta cannonball_y_high
    jsr set_cannonball_object
; update based on collision with room
    lda #objectid_cannonball
    jsr update_object_a_solid_rock_collision
    lda object_x_low + objectid_cannonball
    sta cannonball_x_low
    lda object_x_high + objectid_cannonball
    sta cannonball_x_high
    lda object_y_low + objectid_cannonball
    sta cannonball_y_low
    lda object_y_high + objectid_cannonball
    sta cannonball_y_high
; check for collision with extra surround
    dec temp_top_offset
    lda #2
    sta temp_bottom_offset
    dec temp_left_offset
    inc temp_right_offset
    lda #objectid_cannonball
    jsr get_solid_rock_collision_for_object_a
    beq no_collision
    lda #cannonball_animation3 - cannonball_animations
    sta save_game_level_j_got_cannonball_progress
    sta cannonball_animation_step
    jsr set_cannonball_object
.no_collision
    ldx #objectid_cannonball
    jsr find_left_and_right_of_object
    jsr find_top_and_bottom_of_object
    lda cannonball_direction
    bmi cannonball_move_left_one_room_if_needed
; cannonball move right one room if needed
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return9
    lda cannonball_x_low
    sec
    sbc #&40 ; '@'
    sta cannonball_x_low
    lda #0
    sbc #0
    sta cannonball_x_high
    inc cannonball_room
    jmp hide_cannonball2

.cannonball_move_left_one_room_if_needed
    lda object_right_cell_x
    bpl return9
    lda cannonball_x_low
    clc
    adc #&40 ; '@'
    sta cannonball_x_low
    lda #1
    sta cannonball_x_high
    dec cannonball_room
.hide_cannonball2
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_cannonball
.return9
    rts

.remember_cannonball_spriteid
    equb 0

.set_cannonball_object
    lda #spriteid_erase_cannonball
    sta object_erase_type + objectid_cannonball
    lda #&40 ; '@'
    sta object_z_order + objectid_cannonball
    lda cannonball_x_low
    sta object_x_low + objectid_cannonball
    lda cannonball_x_high
    sta object_x_high + objectid_cannonball
    lda cannonball_y_low
    sta object_y_low + objectid_cannonball
    lda cannonball_y_high
    sta object_y_high + objectid_cannonball
    lda cannonball_direction
    sta object_direction + objectid_cannonball
    lda #spriteid_cannonball1
    sta object_spriteid + objectid_cannonball
    lda save_game_level_j_got_cannonball_progress
    cmp #cannonball_animation3 - cannonball_animations
    bne return10
    lda #spriteid_collision
    sta object_spriteid + objectid_cannonball
.return10
    rts

.envelope2
    equb 5                                                            ; envelope number
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
    equw 5                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound1
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 220                                                          ; pitch
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
.sound3
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound4
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 240                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %01000010
    equb %10000001
    equb %00000000
    equb %00000000
    equb %00000011
    equb %00000100
    equb %10001000
    equb %01001000
.ground_fill_2x2_top_right
    equb %01000010
    equb %10000001
    equb %00000000
    equb %00000000
    equb %11000000
    equb %00100000
    equb %00010001
    equb %00010010
.ground_fill_2x2_bottom_left
    equb %01001000
    equb %10001000
    equb %00000100
    equb %00000011
    equb %00000000
    equb %00000000
    equb %10000001
    equb %01000010
.ground_fill_2x2_bottom_right
    equb %00010010
    equb %00010001
    equb %00100000
    equb %11000000
    equb %00000000
    equb %00000000
    equb %10000001
    equb %01000010
IF swr_renderer_enabled
INCLUDE "build/runtime/levelJ_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelJ.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelJ"
ENDIF
ENDIF
.pydis_end

save "build/dataJ", pydis_start, pydis_end
