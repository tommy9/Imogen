; *************************************************************************************
;
; Level F: 'FOLLOW-ME'
;
; Save game variables:
;
;     save_game_level_f_got_banana_or_banana_y_position ($0a16):
;               0: not got
;              1+: banana y position
;             $ff: got
;
; Solution:
;
;   1. Head to the left room and down the ladder
;   2. Collect the banana that's fallen on the right side of the room
;   3. Head up the rope to the right of the gorilla in the room above, and exit the room to the right
;   4. Jump on the rope and climb until the partition is raised
;   5. Jump off the rope to the right. Hold the banana as the wizard until the gorilla starts to climb the left rope.
;   6. Stop holding the banana.
;   7. Jump right as the cat to get through to the right hand room, and collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_banana                       = 2
objectid_connecting_rope              = 4
objectid_gorilla                      = 5
objectid_partition                    = 3
objectid_room_0_brazier               = 2
objectid_room_1_brazier               = 6
objectid_rope_end                     = 2
objectid_spell                        = 3
spriteid_banana                       = 218
spriteid_banana_bunch                 = 220
spriteid_banana_menu_item             = 219
spriteid_banana_on_ground             = 221
spriteid_boulder                      = 208
spriteid_erase_gorilla                = 209
spriteid_erase_partition_or_banana    = 207
spriteid_gorilla1                     = 210
spriteid_gorilla2                     = 211
spriteid_gorilla3                     = 212
spriteid_gorilla4                     = 213
spriteid_gorilla5                     = 214
spriteid_gorilla_climb1               = 215
spriteid_gorilla_climb2               = 216
spriteid_gorilla_jump                 = 217
spriteid_gorilla_pushes               = 222
spriteid_rope_and_partition           = 206
spriteid_rope_hook_left               = 200
spriteid_rope_hook_right              = 201
spriteid_rope_short_horizontal        = 202
spriteid_rope_short_vertical          = 203
spriteid_rope_vertical                = 204
spriteid_rope_vertical_end            = 205

; Memory locations
room_exit_direction                                 = &0070
temp_x                                              = &0070
save_game_level_f_got_banana_or_banana_y_position   = &0a16
partition_position_y                                = &0a6f
gorilla_animation                                   = &0a70
gorilla_y_position                                  = &0a71
gorilla_x_position                                  = &0a72
gorilla_direction                                   = &0a73
gorilla_animation_step                              = &0a74
delay_before_gorilla_state_change                   = &0a75

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelF_sprite_table - level_data
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
    equb 0
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "FOLLOW-ME", &0D

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
    beq set_rock
    lda developer_flags
    bpl developer_mode_inactive
    lda #&ff
    sta save_game_level_f_got_banana_or_banana_y_position
.developer_mode_inactive
    lda save_game_level_f_got_banana_or_banana_y_position
    cmp #&ff
    bne set_rock
    lda #spriteid_banana_menu_item
    jsr find_or_create_menu_slot_for_A
.set_rock
    lda #<ground_fill_2x2_top_left
    sta source_sprite_memory_low
    lda #>ground_fill_2x2_top_left
    sta source_sprite_memory_high
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
    jsr update_gorilla_puzzle
    jsr room_1_update_handler
    jsr update_banana_puzzle
    jsr room_2_update_handler
    rts

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
; ####  |                   |        #####
; ###   |                   |        #####
; ###   |                   |        #####
; ###   |                   |        #####
; ###   |                   |        #####
; ###   |                   |        #####
; ###   |                   |        #####
; ###   |                   |
; ###   |                   |
; ###   |                   |
; ###   |                   |
; ###   |                   |
; ###   |   ##############  |  ###########
; ###   |   ##############  |  ###########
; ###   |                   |
; ###   |                   |
; ###   |                   |
; ###   |                   |
; ###   |
; ###   |             P              #####
; ###   |   ##############################
; ###   |   ##############################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
.room_0_code
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x7 rectangle at (35,2)
    ldx #&23 ; '#'
    lda #&ff
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x255 rectangle at (0,3)
    ldx #0
    iny
    lda #3
    sta width_in_cells
    lda #&ff
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (35,21)
    ldx #&23 ; '#'
    ldy #&15
    lda #&ff
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (10,22)
    ldx #&0a
    iny
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 14x2 rectangle at (10,14)
    ldx #&0a
    ldy #&0e
    lda #&0e
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 14x2 rectangle at (29,14)
    ldx #&1d
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (6,2) length 255
    ldx #6
    ldy #2
    lda #&ff
    jsr draw_rope
; draw rope at (26,2) length 18
    ldx #&1a
    lda #&12
    jsr draw_rope
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_bottom
    beq room_0_check_right_exit
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

.room_0_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.room_0_update_handler
    lda #0
    sta currently_updating_logic_for_room_index
    lda #objectid_room_0_brazier
    ldx #&23 ; '#'
    ldy #5
    jmp update_brazier_and_fire

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; #####                              #####
; #####                              #####
; #####                              #####
; #####                              #####
; #####                              #####
; #####                              #####
; #####                              #####
; 
; 
; 
; 
; 
; ###########     ############     #######
; ###########     ############     #######
; 
; 
; 
; 
; 
; #####               P              #####
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
.room_1_code
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x7 rectangle at (0,2)
    ldy #2
    lda #5
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x7 rectangle at (35,2)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #&0b
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (16,14)
    ldx #&10
    lda #&0c
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (33,14)
    ldx #&21 ; '!'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (0,21)
    ldx #0
    ldy #&15
    lda #5
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (35,21)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldx #0
    iny
    lda #&ff
    sta width_in_cells
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
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
    ldx #5
    ldy #5
    lda #objectid_room_1_brazier
    jsr update_brazier_and_fire
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne room_1_first_update
    jmp update_partition_puzzle

; check for level change (branch if not)
.room_1_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq skip_level_change
    lda #&48 ; 'H'
    sta partition_position_y
.skip_level_change
    lda desired_room_index
    cmp #1
    beq room_1_initialise
    jmp update_rope_end_position_local

.room_1_initialise
    ldx #<partition_moving_envelope
    ldy #>partition_moving_envelope
    jsr define_envelope
    ldx #<partition_landing_envelope
    ldy #>partition_landing_envelope
    jsr define_envelope
; draw hooks, including collision map
    lda #1
    sta width_in_cells
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    ldx #&0d
    ldy #2
    lda #spriteid_rope_hook_left
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    ldx #&22 ; '"'
    lda #spriteid_rope_hook_right
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    dex
    dex
    lda #spriteid_rope_short_horizontal
.draw_horizontal_rope_loop
    jsr draw_sprite_a_at_cell_xy
    dex
    cpx #&0f
    bcs draw_horizontal_rope_loop
; left vertical hand rope
    ldx #&0d
    lda #&48 ; 'H'
    sec
    sbc partition_position_y
    clc
    adc #&6c ; 'l'
    lsr a
    lsr a
    lsr a
    tay
    dey
.draw_left_vertical_rope_loop
    lda #spriteid_rope_vertical
    jsr draw_sprite_a_at_cell_xy
    lda #2
    jsr write_a_single_value_to_cell_in_collision_map
    dey
    cpy #3
    bcs draw_left_vertical_rope_loop
; set rope end object
    lda #objectid_rope_end
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_rope_vertical_end
    sta object_spriteid,x
    ldx #&22 ; '"'
    lda partition_position_y
    and #4
    beq check_amount_of_vertical_rope_to_draw
; draw short end rope to hit partition
    lda partition_position_y
    sec
    sbc #&0c
    lsr a
    lsr a
    lsr a
    tay
    lda #spriteid_rope_short_vertical
    jsr draw_sprite_a_at_cell_xy
.check_amount_of_vertical_rope_to_draw
    lda partition_position_y
    and #&f8
    cmp #&20 ; ' '
    beq skip_right_hand_rope_drawing_as_partition_already_fully_up
    lsr a
    lsr a
    lsr a
    tay
    dey
    dey
    lda #spriteid_rope_vertical
.draw_right_vertical_rope_loop
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_right_vertical_rope_loop
; write values to partition object
.skip_right_hand_rope_drawing_as_partition_already_fully_up
    lda #objectid_partition
    jsr set_object_position_from_cell_xy
    lda #objectid_connecting_rope
    jsr set_object_position_from_cell_xy
    tax
    jsr copy_object_state_to_old
    lda #&c1
    sta object_z_order,x
    ldx #objectid_partition
    lda #spriteid_rope_and_partition
    sta object_spriteid,x
    lda #spriteid_erase_partition_or_banana
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
.update_rope_end_position_local
    jmp update_rope_end_position

.update_partition_puzzle
    lda desired_room_index
    cmp #1
    bne skip_reset_sound_priority
; update room 1 sound priorities
    lda sound_priority_per_channel_table
    cmp #&41 ; 'A'
    bcs skip_reset_sound_priority
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
.skip_reset_sound_priority
    lda gorilla_x_position
    cmp #&50 ; 'P'
    bcc gorilla_not_on_rope
    lda gorilla_animation
    cmp #gorilla_climbing_rope_animation - gorilla_animations_table
    beq gorilla_on_rope
    cmp #gorilla_on_rope_animation - gorilla_animations_table
    bne gorilla_not_on_rope
.gorilla_on_rope
    lda partition_position_y
    cmp #&20 ; ' '
    beq return1_local
    lda gorilla_y_position
    clc
    adc #4
    sta gorilla_y_position
    ldx desired_room_index
    cpx #1
    bne move_partition_up
    sta object_y_low + objectid_gorilla
    jmp move_partition_up

.return1_local
    jmp return1

.gorilla_not_on_rope
    lda desired_room_index
    cmp #1
    bne player_not_on_rope
; update the rope position. First check player is the monkey
    lda current_player_character
    cmp #spriteid_icodata_monkey
    bne player_not_on_rope
; check player animation
    lda current_player_animation
    cmp #monkey_climb_animation - monkey_base_animation
    beq player_is_monkey_on_rope
    cmp #monkey_climb_idle_animation - monkey_base_animation
    beq player_is_monkey_on_rope
    cmp #monkey_climb_down_animation - monkey_base_animation
    bne player_not_on_rope
; check partition position. If fully raised, then return
.player_is_monkey_on_rope
    lda partition_position_y
    cmp #&20 ; ' '
    beq return1_local
; move player down rope as it moves
    lda object_y_low
    clc
    adc #4
    sta object_y_low
    lda object_y_low + objectid_player_accessory
    clc
    adc #4
    sta object_y_low + objectid_player_accessory
.move_partition_up
    lda partition_position_y
    sec
    sbc #4
    sta partition_position_y
; check if we are in room 1
    lda desired_room_index
    cmp #1
    bne return1_local
    jsr play_partition_moving_sound
    ldx #objectid_connecting_rope
    lda partition_position_y
    sec
    sbc #8
    sta object_y_low_old,x
; while partition is moving, remove the short vertical rope
    lda #spriteid_rope_short_vertical
    sta object_spriteid_old,x
    lda #0
    sta object_spriteid,x
    jmp update_rope_end_position

.player_not_on_rope
    lda partition_position_y
    cmp #&48 ; 'H'
    bne calculate_connecting_rope
    jmp return1

.calculate_connecting_rope
    ldx #&0c
    ldy #spriteid_rope_short_vertical
    adc #4
    cmp #&48 ; 'H'
    beq remember_connecting_rope
    ldx #&10
    ldy #spriteid_rope_vertical
    adc #4
.remember_connecting_rope
    sta partition_position_y
    stx remembered_rope_y_offset
    sty remembered_connecting_rope_spriteid
; check if we are in room 1
    lda desired_room_index
    cmp #1
    bne update_rope_end_position
; check for partition landing or moving (for playing sound)
    lda partition_position_y
    cmp #&48 ; 'H'
    beq play_partition_landing_sound
    jsr play_partition_moving_sound
    jmp update_connecting_rope_position

.play_partition_landing_sound
    lda #0
    ldx #<partition_landing_sound1
    ldy #>partition_landing_sound1
    jsr play_sound_yx
    ldx #<partition_landing_sound2
    ldy #>partition_landing_sound2
    jsr play_sound_yx
.update_connecting_rope_position
    ldx #objectid_connecting_rope
    lda partition_position_y
    sec
    sbc remembered_rope_y_offset
    sta object_y_low,x
; restore the connecting rope
    lda #0
    sta object_spriteid_old,x
    lda remembered_connecting_rope_spriteid
    sta object_spriteid,x
.update_rope_end_position
    lda desired_room_index
    cmp #1
    bne return1
    ldx #objectid_rope_end
    lda #0
    sta object_spriteid_old,x
    lda #&48 ; 'H'
    sec
    sbc partition_position_y
    clc
    adc #&68 ; 'h'
    sta object_y_low,x
; update collision map for rope and partition
    ldx #&0d
    clc
    adc #4
    lsr a
    lsr a
    lsr a
    tay
    lda #2
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #0
    jsr write_a_single_value_to_cell_in_collision_map
    lda partition_position_y
    sta object_y_low + objectid_partition
    ldx #&22 ; '"'
    ldy #9
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda partition_position_y
    cmp #&48 ; 'H'
    beq partition_is_closed
    lda #collision_map_none
    sta value_to_write_to_collision_map
.partition_is_closed
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq collision_map_written
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.collision_map_written
    ldx #objectid_player
    ldy #objectid_partition
    jsr test_for_collision_between_objects_x_and_y
    beq return1
; player collided with partition, get pushed left
    lda #&fa
    sta player_wall_collision_reaction_speed
; but if player is to the right of the wall, the get pushed right
    lda object_x_high
    cmp #1
    bne return1
    lda object_x_low
    cmp #&14
    bcc return1
    lda #6
    sta player_wall_collision_reaction_speed
.return1
    rts

.remembered_rope_y_offset
    equb 0
.remembered_connecting_rope_spriteid
    equb 0

.play_partition_moving_sound
    lda #&40 ; '@'
    ldx #<partition_moving_sound
    ldy #>partition_moving_sound
    jsr play_sound_yx
    rts

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; #####                            |  ####
; #####                            |   ###
; #####                            |   ###
; #####                            |   ###
; #####                            |   ###
; #####                            |   ###
; #####                            |   ###
;                                  |   ###
;                                  |   ###
;                                  |   ###
;             OOO          OOO     |   ###
;             OOO          OOO     |   ###
; #######     ################     |   ###
; #######     ################     |   ###
;                                      ###
;                                      ###
;                                   OOO###
;                                   OOO###
;                                OOOOOO###
; #####               P          OOOOOO###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
.room_2_code
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x7 rectangle at (0,2)
    ldy #2
    lda #5
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (36,2)
    ldx #&24 ; '$'
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x19 rectangle at (37,3)
    inx
    iny
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (0,21)
    ldx #0
    ldy #&15
    lda #5
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x255 rectangle at (0,22)
    ldx #0
    iny
    lda #&ff
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x2 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #7
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,14)
    ldx #&0c
    lda #&10
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (12,12) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_boulder
    ldx #&0c
    ldy #&0c
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (25,12) of size (3x2)
    ldx #&19
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (31,20) of size (3x2)
    ldx #&1f
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (34,20) of size (3x2)
    ldx #&22 ; '"'
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (34,18) of size (3x2)
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (33,2) length 14
    ldx #&21 ; '!'
    ldy #2
    lda #&0e
    jsr draw_rope
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_2_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    lda #objectid_room_0_brazier
    ldx #5
    ldy #5
    jsr update_brazier_and_fire
    lda #objectid_spell
    ldx #&14
    ldy #&0e
    jsr update_level_completion
    rts

.gorilla_animations_table
.gorilla_push_animation
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb spriteid_gorilla_pushes,                       0
    equb                       0
    equb 0
.gorilla_idle_animation
    equb spriteid_gorilla5,                 0,                 0
    equb 0
.gorilla_walk_cycle_animation
    equb spriteid_gorilla1,                 1,                 0
    equb spriteid_gorilla2,                 1,                 0
    equb spriteid_gorilla3,                 1,                 0
    equb spriteid_gorilla4,                 1,                 0
    equb 0
.gorilla_jump_on_rope_animation
    equb spriteid_gorilla_jump,                     1
    equb                   &fb
    equb spriteid_gorilla_jump,                     1
    equb                   &fc
    equb spriteid_gorilla_jump,                     1
    equb                   &fd
    equb spriteid_gorilla_jump,                     1
    equb                   &fd
    equb spriteid_gorilla_jump,                     1
    equb                   &fe
    equb spriteid_gorilla_jump,                     1
    equb                   &fe
    equb spriteid_gorilla_jump,                     1
    equb                   &ff
    equb 0
.gorilla_jump_off_rope_animation
    equb spriteid_gorilla_jump,                     1
    equb                     1
    equb spriteid_gorilla_jump,                     1
    equb                     2
    equb spriteid_gorilla_jump,                     1
    equb                     2
    equb spriteid_gorilla_jump,                     1
    equb                     3
    equb spriteid_gorilla_jump,                     1
    equb                     3
    equb spriteid_gorilla_jump,                     1
    equb                     4
    equb spriteid_gorilla_jump,                     1
    equb                     5
    equb 0
.gorilla_on_rope_animation
    equb spriteid_gorilla_climb1,                       0
    equb                       0
    equb 0
.gorilla_climbing_rope_animation
    equb spriteid_gorilla_climb2,                       0
    equb                     &fc
    equb spriteid_gorilla_climb1,                       0
    equb                     &fc
    equb 0

; check for first update in room (branch if not)
.update_gorilla_puzzle
    lda update_room_first_update_flag
    beq update_gorilla_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_room_only
    lda #&22 ; '"'
    sta gorilla_x_position
    lda #&6e ; 'n'
    sta gorilla_y_position
    lda #1
    sta gorilla_direction
    lda #gorilla_idle_animation - gorilla_animations_table
    sta gorilla_animation
    sta gorilla_animation_step
    jsr get_random_gorilla_idle_delay
.initialise_room_only
    lda desired_room_index
    cmp #2
    bcs initialise_room_2_or_3
    lda #spriteid_erase_gorilla
    sta object_erase_type + objectid_gorilla
    lda #&c0
    sta object_z_order + objectid_gorilla
    lda #0
    sta object_y_high + objectid_gorilla
.initialise_room_2_or_3
    jmp update_gorilla_object

; take the player x position, divide by four to get an x position that ranges from
; (0-79)
.update_gorilla_not_first_update
    lda object_x_high
    lsr a
    sta temp_x
    lda object_x_low
    ror a
    lsr temp_x
    ror a
; add 80 for room 1 and another 80 for room 2
    ldx desired_room_index
    beq got_the_player_position
    clc
    adc #&50 ; 'P'
    cpx #1
    beq got_the_player_position
    clc
    adc #&50 ; 'P'
.got_the_player_position
    ldx #0
    sec
    sbc gorilla_x_position
    beq got_direction_for_the_gorilla
    ldx #1
    bcs got_direction_for_the_gorilla
    ldx #&ff
.got_direction_for_the_gorilla
    stx gorilla_to_player_direction
; set Y to next animation step
    lda gorilla_animation_step
    clc
    adc #3
    tay
    lda gorilla_animations_table,y
    bne loop_animation_if_needed
    ldy gorilla_animation
.loop_animation_if_needed
    lda delay_before_gorilla_state_change
    beq update_gorilla_delay
    dec delay_before_gorilla_state_change
.update_gorilla_delay
    lda gorilla_animation
    cmp #gorilla_jump_on_rope_animation - gorilla_animations_table
    bne not_jump_on_rope
; gorilla is jumping onto a rope. Are we at the end of the animation?
    cpy gorilla_animation
    bne gorilla_in_room_0_local
; set (loop) the animation to the on rope animation. [not technically needed, isnt it
; already set?]
    ldy #gorilla_on_rope_animation - gorilla_animations_table
    sty gorilla_animation
; set a 4 frame delay before changing state
    lda #4
    sta delay_before_gorilla_state_change
    lda gorilla_x_position
    cmp #&50 ; 'P'
    bcc gorilla_in_room_0_local
    ldy #gorilla_climbing_rope_animation - gorilla_animations_table
    sty gorilla_animation
    lda #0
    sta delay_before_gorilla_state_change
.not_jump_on_rope
    lda gorilla_animation
    cmp #gorilla_climbing_rope_animation - gorilla_animations_table
    bne gorilla_check_jumping_off_rope
    lda partition_position_y
    cmp #&20 ; ' '
    bne gorilla_in_room_0_local
    ldy #gorilla_on_rope_animation - gorilla_animations_table
    sty gorilla_animation
    lda #4
    sta delay_before_gorilla_state_change
.gorilla_in_room_0_local
    jmp update_gorilla_state

.gorilla_check_jumping_off_rope
    lda gorilla_animation
    cmp #gorilla_jump_off_rope_animation - gorilla_animations_table
    bne update_gorilla_if_banana_held
; are we at the end of the animation?
    cpy gorilla_animation
    bne gorilla_in_room_0_local
    ldy #gorilla_idle_animation - gorilla_animations_table
    sty gorilla_animation
    jsr get_random_gorilla_idle_delay
.update_gorilla_if_banana_held
    lda player_held_object_spriteid
    cmp #spriteid_banana_menu_item
    bne check_for_gorilla_on_rope
    lda object_y_low
    cmp #&70 ; 'p'
    bcs check_for_gorilla_on_rope
    ldx desired_room_index
    beq update_gorilla_jumping_off_rope
    cpx #3
    bcs check_for_gorilla_on_rope
    lda partition_position_y
    cmp #&20 ; ' '
    beq update_gorilla_jumping_off_rope
    cpx #2
    beq check_for_gorilla_on_rope
    lda object_x_high
    cmp #1
    bne update_gorilla_jumping_off_rope
    lda object_x_low
    cmp #&10
    bcc update_gorilla_jumping_off_rope
.check_for_gorilla_on_rope
    lda gorilla_animation
    cmp #gorilla_on_rope_animation - gorilla_animations_table
    beq gorilla_in_room_0_local
    jmp update_gorilla_if_not_idle

.update_gorilla_jumping_off_rope
    lda gorilla_to_player_direction
    beq update_gorilla_state
    sta gorilla_direction
    lda gorilla_animation
    cmp #gorilla_on_rope_animation - gorilla_animations_table
    bne check_gorilla_x_position
    lda delay_before_gorilla_state_change
    bne update_gorilla_state
    ldy #gorilla_jump_off_rope_animation - gorilla_animations_table
    sty gorilla_animation
    jmp update_gorilla_state

.check_gorilla_x_position
    lda gorilla_direction
    bmi check_gorilla_x_position_moving_left
; check gorilla x position moving right
    lda gorilla_x_position
    cmp #&2e ; '.'
    bcc update_gorilla_if_walk_cycle
    beq gorilla_set_jump_on_rope
    cmp #&64 ; 'd'
    bcc update_gorilla_if_walk_cycle
    beq gorilla_set_jump_on_rope
    cmp #&86
    bcc update_gorilla_if_walk_cycle
    jmp update_gorilla_if_not_idle

.check_gorilla_x_position_moving_left
    lda gorilla_x_position
    cmp #&72 ; 'r'
    beq gorilla_set_jump_on_rope
    bcs update_gorilla_if_walk_cycle
    cmp #&3c ; '<'
    beq gorilla_set_jump_on_rope
    bcs update_gorilla_if_walk_cycle
    cmp #&17
    bcs update_gorilla_if_walk_cycle
    jmp update_gorilla_if_not_idle

.gorilla_set_jump_on_rope
    ldy #gorilla_jump_on_rope_animation - gorilla_animations_table
    sty gorilla_animation
    jmp update_gorilla_state

.update_gorilla_if_walk_cycle
    lda #gorilla_walk_cycle_animation - gorilla_animations_table
    cmp gorilla_animation
    beq update_gorilla_state
    tay
    sty gorilla_animation
    jmp update_gorilla_state

.update_gorilla_if_not_idle
    lda #gorilla_idle_animation - gorilla_animations_table
    cmp gorilla_animation
    beq update_gorilla_state
    tay
    sty gorilla_animation
    jsr get_random_gorilla_idle_delay
.update_gorilla_state
    lda desired_room_index
    cmp #3
    bcs update_gorilla_idle_delay
    ldx #0
    sty remember_gorilla_state
    ldy #5
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_gorilla_state
    ora #0
    beq update_gorilla_idle_delay
    lda save_game_level_f_got_banana_or_banana_y_position
    cmp #&ff
    bne set_player_reaction_speed
    lda player_held_object_spriteid
    cmp #&db
    bne set_player_reaction_speed
    jsr remove_item_from_toolbar_menu
    lda #0
    sta player_held_object_spriteid
    sta object_spriteid + objectid_player_accessory
    sta player_using_object_spriteid
    sta save_game_level_f_got_banana_or_banana_y_position
; if gorilla is climbing or on rope then fall off gorilla
.set_player_reaction_speed
    lda #&80
    sta player_wall_collision_reaction_speed
; branch if climbing or on rope
    lda gorilla_animation
    cmp #gorilla_climbing_rope_animation - gorilla_animations_table
    beq update_gorilla_idle_delay
    cmp #gorilla_on_rope_animation - gorilla_animations_table
    beq update_gorilla_idle_delay
    lda #6
    ldx gorilla_to_player_direction
    bpl set_player_reaction_speed_bounce_off_gorilla
    lda #&fa
.set_player_reaction_speed_bounce_off_gorilla
    sta player_wall_collision_reaction_speed
    lda gorilla_animation
    cmp #gorilla_jump_on_rope_animation - gorilla_animations_table
    beq update_gorilla_idle_delay
    cmp #gorilla_jump_off_rope_animation - gorilla_animations_table
    beq update_gorilla_idle_delay
    lda #1
    ldx gorilla_to_player_direction
    bpl set_gorilla_direction
    lda #&ff
.set_gorilla_direction
    sta gorilla_direction
    ldy #gorilla_idle_animation - gorilla_animations_table
    sty gorilla_animation
    ldy #0
    jsr get_random_gorilla_idle_delay
.update_gorilla_idle_delay
    lda gorilla_animation
    cmp #gorilla_idle_animation - gorilla_animations_table
    bne update_gorilla_state_based_on_animation_step
    lda delay_before_gorilla_state_change
    bne update_gorilla_state_based_on_animation_step
    jsr get_random_gorilla_idle_delay
.update_gorilla_state_based_on_animation_step
    sty gorilla_animation_step
    iny
    lda gorilla_animations_table,y
    ldx gorilla_direction
    bpl add_offset_to_x_position
    eor #&ff
    clc
    adc #1
.add_offset_to_x_position
    clc
    adc gorilla_x_position
    sta gorilla_x_position
    iny
; add offset to y position
    lda gorilla_animations_table,y
    clc
    adc gorilla_y_position
    sta gorilla_y_position
.update_gorilla_object
    lda desired_room_index
    cmp #2
    bcs return2
    ldy gorilla_animation_step
    lda gorilla_animations_table,y
    sta object_spriteid + objectid_gorilla
    lda gorilla_direction
    sta object_direction + objectid_gorilla
    lda gorilla_y_position
    sta object_y_low + objectid_gorilla
    lda gorilla_x_position
; reduce gorilla position to room position
    ldx desired_room_index
    beq reduced_to_room_0
    sec
    sbc #&50 ; 'P'
.reduced_to_room_0
    ldx #0
    cmp #&a0
    bcc set_gorilla_x_position
    dex
.set_gorilla_x_position
    stx object_x_high + objectid_gorilla
    asl a
    rol object_x_high + objectid_gorilla
    asl a
    rol object_x_high + objectid_gorilla
    sta object_x_low + objectid_gorilla
    lda gorilla_direction
    bpl update_gorilla_jump_off_rope
    lda object_x_low + objectid_gorilla
    sec
    sbc #1
    sta object_x_low + objectid_gorilla
    lda object_x_high + objectid_gorilla
    sbc #0
    sta object_x_high + objectid_gorilla
; check for first update in room (branch if so)
.update_gorilla_jump_off_rope
    lda update_room_first_update_flag
    bne return2
    lda gorilla_animation
    cmp #gorilla_jump_off_rope_animation - gorilla_animations_table
    bne return2
    lda #2
    sta temp_bottom_offset
    lda #5
    jsr get_solid_rock_collision_for_object_a
    beq return2
    jsr play_landing_sound
.return2
    rts

.get_random_gorilla_idle_delay
    lda #&1f
    jsr get_random_number_up_to_a
    clc
    adc #&20 ; ' '
    sta delay_before_gorilla_state_change
    rts

.gorilla_to_player_direction
    equb 0
.remember_gorilla_state
    equb 0
; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 20                                                           ; initial player X cell
    equb 10                                                           ; initial player Y cell

; ###   |   ##############################
; ###   |   ##############################
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###   |             P                ###
; ###   |   ####################       ###
; ###   |   ####################       ###
; ###   |                              ###
; ###   |                              ###
; ###   |                              ###
; ###                                  ###
; ###                                  ###
; ##########                    ##########
; ##########OOO                 ##########
; ##########OOO                 ##########
; ##########OOOOOO              ##########
; ##########OOOOOO              ##########
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 27x2 rectangle at (10,0)
.room_3_code
    ldx #&0a
    ldy #0
    lda #&1b
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x17 rectangle at (0,0)
    ldx #0
    lda #3
    sta width_in_cells
    lda #&11
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x17 rectangle at (37,0)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 10x5 rectangle at (0,17)
    ldx #0
    ldy #&11
    lda #&0a
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 10x5 rectangle at (30,17)
    ldx #&1e
    jsr copy_rectangle_of_memory_to_screen
; draw 255x5 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 20x2 rectangle at (10,10)
    ldx #&0a
    ldy #&0a
    lda #&14
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (13,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_boulder
    ldx #&0d
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (10,20) of size (3x2)
    ldx #&0a
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (10,18) of size (3x2)
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (6,0) length 15
    ldx #6
    ldy #0
    lda #&0f
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_top
    beq room_3_game_update_loop
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

; check for first update in room (branch if not)
.update_banana_puzzle
    lda update_room_first_update_flag
    beq update_banana_not_first_update
; initialise banana
    lda #spriteid_banana_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_banana
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_banana_new_room
    lda save_game_level_f_got_banana_or_banana_y_position
    beq initialise_banana_new_room
    cmp #&ff
    beq initialise_banana_new_room
    lda #&86
    sta save_game_level_f_got_banana_or_banana_y_position
.initialise_banana_new_room
    lda desired_room_index
    cmp #3
    bne banana_already_landed_or_taken_local
; in room 3. Draw bunch of bananas
    ldx #&21 ; '!'
    lda #4
    sta temp_sprite_x_offset
    ldy #2
    lda #spriteid_banana_bunch
    jsr draw_sprite_a_at_cell_xy
    lda #spriteid_erase_partition_or_banana
    sta object_erase_type + objectid_banana
    lda #&c0
    sta object_z_order + objectid_banana
    lda #&0c
    sta object_x_low + objectid_banana
    lda #1
    sta object_x_high + objectid_banana
    lda #0
    sta object_y_high + objectid_banana
.banana_already_landed_or_taken_local
    jmp banana_already_landed_or_taken

.update_banana_not_first_update
    lda save_game_level_f_got_banana_or_banana_y_position
    cmp #&ff
    beq banana_already_landed_or_taken
    ora #0
    bne update_banana_in_room_3
    lda desired_room_index
    cmp #3
    bne banana_already_landed_or_taken
; as soon as the player lands, then create a banana
    lda #2
    sta temp_bottom_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    beq banana_already_landed_or_taken
    lda #&28 ; '('
    bne set_banana_y                                                  ; ALWAYS branch

.update_banana_in_room_3
    lda desired_room_index
    cmp #3
    bne no_banana_collision
    ldx #objectid_old_player
    ldy #2
    jsr test_for_collision_between_objects_x_and_y
    beq no_banana_collision
    lda #spriteid_banana_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #&ff
    bne set_banana_y                                                  ; ALWAYS branch

.no_banana_collision
    lda save_game_level_f_got_banana_or_banana_y_position
    cmp #&86
    beq banana_already_landed_or_taken
    clc
    adc #8
    cmp #&80
    bcc set_banana_y
    bne banana_on_ground
    sta save_game_level_f_got_banana_or_banana_y_position
    lda desired_room_index
    cmp #3
    bne banana_already_landed_or_taken
    jsr play_landing_sound
    jmp banana_already_landed_or_taken

.banana_on_ground
    lda #&86
.set_banana_y
    sta save_game_level_f_got_banana_or_banana_y_position
.banana_already_landed_or_taken
    lda desired_room_index
    cmp #3
    bne return3
; don't show the banana object if there's no banana visible yet
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_banana
    lda save_game_level_f_got_banana_or_banana_y_position
    beq return3
; don't show the banana object if it's already taken
    cmp #&ff
    beq return3
; set the banana y position
    sta object_y_low + objectid_banana
; set the banana on the ground sprite, exit if on the ground
    ldx #spriteid_banana_on_ground
    stx object_spriteid + objectid_banana
    cmp #&86
    beq return3
; set the banana in the air sprite
    lda #spriteid_banana
    sta object_spriteid + objectid_banana
.return3
    rts

.partition_moving_envelope
    equb 5                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 10                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 216                                                          ; change of amplitude per step during release phase
    equb 40                                                           ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.partition_moving_sound
    equw &0010                                                        ; channel
    equw 5                                                            ; amplitude
    equw 4                                                            ; pitch
    equw 4                                                            ; duration
.partition_landing_envelope
    equb 6                                                            ; envelope number
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
.partition_landing_sound2
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.partition_landing_sound1
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 210                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %00010000
    equb %00001000
    equb %00000100
    equb %10000010
    equb %01000001
    equb %00100001
    equb %00010010
    equb %00001100
.ground_fill_2x2_top_right
    equb %00001000
    equb %00010000
    equb %00100000
    equb %01000001
    equb %10000010
    equb %00000100
    equb %00001000
    equb %00010000
.ground_fill_2x2_bottom_left
    equb %00001000
    equb %00010000
    equb %00100000
    equb %01000001
    equb %10000010
    equb %00000100
    equb %00001000
    equb %00010000
.ground_fill_2x2_bottom_right
    equb %00110000
    equb %01001000
    equb %10000100
    equb %10000010
    equb %01000001
    equb %00100000
    equb %00010000
    equb %00001000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelF_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelF.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelF"
ENDIF
ENDIF
.pydis_end

save "build/dataF", pydis_start, pydis_end
