; *************************************************************************************
;
; Level I: 'SEE-SWORD'
;
; Save game variables:
;
;     save_game_level_i_room_0_seesaw_puzzle_progress            ($0a24):
;               0: untouched
;              1+: stone thrown, animating
;             $ff: taken
;
;     save_game_level_i_sword_puzzle_progress                    ($0a25):
;               0: untouched
;              1+: animating
;             $15: sword in wall
;             $ff: sword taken
;
;     save_game_level_i_spell_puzzle_progress                    ($0a26):
;               0: untouched
;              1+: animating
;             $1f: spell on floor
;
;     save_game_level_i_small_stone_x_low                        ($0a27):
;     save_game_level_i_small_stone_x_high                       ($0a28):
;     save_game_level_i_small_stone_y_low                        ($0a29):
;     save_game_level_i_small_stone_y_high                       ($0a2a):
;           position of small stone in the room
;
;     save_game_level_i_small_stone_direction_without_bounces    ($0a2b):
;             1: thrown right
;           $ff: thrown left
;
;     save_game_level_i_small_stone_room_0_seesaw_animation_step ($0a2c):
;           the step (index) of the current animation step for the small stone
;
;     save_game_level_i_small_stone_room                         ($0a2d):
;           the room containing the small stone (if not held by player)
;
;     save_game_level_i_small_stone_direction_including_bounces  ($0a2e):
;             1: travelling right
;           $ff: travelling left
;
;     save_game_level_i_room_3_seesaw_puzzle_progress            ($0a2f):
;             0: untouched
;            1+: animating
;           $19: small stone on ledge
;           $ff: small stone taken
;
; Solution:
;
;   1. Climb the right hand rope to the room above and jump into the large stone.
;           (Small stone ends on ledge)
;   2. Retrieve small stone and descend to the room below.
;   3. Go to the left room (on ground floor) and from the slightly raised floor,
;      throw the small stone to the left.
;           (the sword sticks into the wall)
;   4. From the previous room, ascend the left rope and exit left to the raised section of the leftmost room.
;   5. Fall to collect the sword.
;   6. In the rightmost room, use the sword to cut the rope and get the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_big_stone_room_0              = 5
objectid_big_stone_room_3              = 4
objectid_boulder_room_2                = 5
objectid_long_rope_end_room_2          = 7
objectid_old_small_stone_object        = 13
objectid_rope_end_room_2               = 8
objectid_seesaw                        = 3
objectid_short_rope_end_room_2         = 6
objectid_small_stone_object            = 2
objectid_spell                         = 4
objectid_sword                         = 4
spriteid_big_stone                     = 203
spriteid_boulder                       = 221
spriteid_erase_big_stone_or_rope_end   = 204
spriteid_erase_seesaw                  = 205
spriteid_erase_small_stone             = 201
spriteid_erase_sword                   = 207
spriteid_horizontal_rope               = 216
spriteid_left_hook                     = 214
spriteid_long_rope_end1                = 218
spriteid_long_rope_end2                = 219
spriteid_right_hook                    = 215
spriteid_rope_broken                   = 220
spriteid_seesaw                        = 206
spriteid_short_rope                    = 217
spriteid_short_rope_end                = 222
spriteid_small_stone                   = 200
spriteid_stone_menu_item               = 202
spriteid_sword                         = 208
spriteid_sword_menu_item               = 209
spriteid_sword_spinA                   = 210
spriteid_sword_spinB                   = 211
spriteid_sword_spinC                   = 212
spriteid_sword_spinD                   = 213

; Memory locations
l0070                                                       = &0070
room_exit_direction                                         = &0070
object_left_cell_x                                          = &0078
object_right_cell_x                                         = &0079
object_top_cell_y                                           = &007a
object_bottom_cell_y                                        = &007b
save_game_level_i_room_0_seesaw_puzzle_progress             = &0a24
save_game_level_i_sword_puzzle_progress                     = &0a25
save_game_level_i_spell_puzzle_progress                     = &0a26
save_game_level_i_small_stone_x_low                         = &0a27
save_game_level_i_small_stone_x_high                        = &0a28
save_game_level_i_small_stone_y_low                         = &0a29
save_game_level_i_small_stone_y_high                        = &0a2a
save_game_level_i_small_stone_direction_without_bounces     = &0a2b
save_game_level_i_small_stone_room_0_seesaw_animation_step  = &0a2c
save_game_level_i_small_stone_room                          = &0a2d
save_game_level_i_small_stone_direction_including_bounces   = &0a2e
save_game_level_i_room_3_seesaw_puzzle_progress             = &0a2f

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelI_sprite_table - level_data
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
    equb 1
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "SEE-SWORD", &0D

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
    beq set_ground_tiles
    lda developer_flags
    bpl developer_mode_inactive
    lda #&ff
    sta save_game_level_i_room_0_seesaw_puzzle_progress
    lda #spriteid_sword_menu_item
    jsr find_or_create_menu_slot_for_A
; if stone got, then add to toolbar
.developer_mode_inactive
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    bpl not_got_stone
    lda #spriteid_stone_menu_item
    jsr find_or_create_menu_slot_for_A
; if sword got, then add to toolbar
.not_got_stone
    lda save_game_level_i_sword_puzzle_progress
    bpl not_got_sword
    lda #spriteid_sword_menu_item
    jsr find_or_create_menu_slot_for_A
.not_got_sword
    lda desired_room_index
    cmp #3
    bne set_ground_tiles
; in room 3. Switch to room 1, and set player position
    lda #1
    sta desired_room_index
    ldx #&14
    ldy #7
    lda #0
    sta temp_sprite_y_offset
    lda #objectid_player
    jsr set_object_position_from_cell_xy
.set_ground_tiles
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
    jsr update_room_0_seesaw_puzzle
    jsr update_room_3_seesaw_puzzle
    jsr update_sword_puzzle
    jsr room_2_update_handler
    jmp room_1_update_handler

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 20                                                           ; initial player X cell
    equb 21                                                           ; initial player Y cell

; #####   |                      |   #####
; #####   |                      |   #####
;         |                      |
;         |                      |
;         |                      |
;         |                      |
;         |                      |
; #####   |   ################   |   #####
; #####   |   ################   |   #####
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
;         |                      |
;         |                      |
; 
;                     P
;        ##########################
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 5x2 rectangle at (0,0)
.room_1_code
    ldx #0
    ldy #0
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (35,0)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,7)
    ldx #0
    ldy #7
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (35,7)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,7)
    ldx #&0c
    lda #&10
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,9)
    ldx #0
    ldy #9
    lda #3
    sta width_in_cells
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (37,9)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 255x8 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 26x1 rectangle at (7,21)
    ldx #7
    dey
    lda #&1a
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (8,0) length 19
    ldx #8
    ldy #0
    lda #&13
    jsr draw_rope
; draw rope at (31,0) length 19
    ldx #&1f
    jsr draw_rope
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_top
    beq room_1_check_left_exit
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

.room_1_check_left_exit
    lda room_exit_direction
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
    ldx #3
    ldy #&0c
    lda #3
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #4
    jmp update_brazier_and_fire

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 16                                                           ; initial player X cell
    equb 21                                                           ; initial player Y cell

; ########################################
; ########################################
;                                    #####
;                                     ####
;                                      ###
;                                      ###
;                                      ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
;                    ###               ###
;                    ###               ###
;                    ###               ###
;                 P  ###               ###
;        ###############               ###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_2_code
    jsr draw_top_and_bottom_rows_of_solid_rock
; draw 255x1 rectangle at (35,2)
    ldx #&23 ; '#'
    ldy #2
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (36,3)
    inx
    iny
    jsr copy_rectangle_of_memory_to_screen
; draw 255x18 rectangle at (37,4)
    inx
    iny
    lda #&12
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (0,7)
    ldx #0
    ldy #7
    lda #3
    sta width_in_cells
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (19,17)
    ldx #&13
    ldy #&11
    lda #3
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x1 rectangle at (7,21)
    ldx #7
    ldy #&15
    lda #&0c
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_2_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.spell_trajectory_y_coordinates_table
    equb 146, 136, 128, 121, 114, 108, 104, 100,  98,  97,  96
    equb  96,  97,  99, 102, 106, 112, 120, 130, 139, 152, 168

.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    ldx #&1f
    ldy #&15
    lda #3
    sta temp_sprite_y_offset
    lda #objectid_spell
    jsr update_level_completion
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne initialise_if_room_2
    jmp update_spell

; check for level change (branch if not)
.initialise_if_room_2
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq check_for_being_in_room_2
    lda save_game_level_i_spell_puzzle_progress
    beq check_for_being_in_room_2
    lda #&1f
    sta save_game_level_i_spell_puzzle_progress
.check_for_being_in_room_2
    lda desired_room_index
    cmp #2
    beq initialise_room_2_objects
    jmp update_rope_and_seesaw_visuals_local

.initialise_room_2_objects
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    lda #&40 ; '@'
    sta object_z_order + objectid_spell
    lda #spriteid_erase_seesaw
    sta object_erase_type + objectid_seesaw
    ldx #&1d
    lda #4
    sta temp_sprite_x_offset
    ldy #&16
    lda #objectid_seesaw
    jsr set_object_position_from_cell_xy
    lda #spriteid_seesaw
    sta object_spriteid + objectid_seesaw
    lda #1
    sta width_in_cells
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    ldx #&0d
    ldy #2
    lda #spriteid_left_hook
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    ldx #&1b
    lda #spriteid_right_hook
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    dex
    dex
    lda #spriteid_horizontal_rope
.draw_room_2_horizontal_rope_loop
    jsr draw_sprite_a_at_cell_xy
    dex
    cpx #&0f
    bcs draw_room_2_horizontal_rope_loop
    lda save_game_level_i_spell_puzzle_progress
    cmp #&0a
    bcc got_room_2_rope_position
    lda #&0a
.got_room_2_rope_position
    sta room_2_rope_position
    ldx #&0d
    lda #&12
    sec
    sbc room_2_rope_position
    tay
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dey
.draw_room_2_short_rope_loop
    lda #spriteid_short_rope
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dey
    cpy #3
    bcs draw_room_2_short_rope_loop
    lda #objectid_long_rope_end_room_2
    jsr set_object_position_from_cell_xy
    lda #objectid_rope_end_room_2
    ldy #&15
    jsr set_object_position_from_cell_xy
    lda #spriteid_erase_big_stone_or_rope_end
    sta object_erase_type + objectid_rope_end_room_2
    ldx #&1b
    lda #7
    clc
    adc room_2_rope_position
    tay
    lda #spriteid_short_rope
.draw_rope_loop
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_rope_loop
; initialise rope end
    lda #spriteid_short_rope_end
    sta object_spriteid + objectid_short_rope_end_room_2
    lda #objectid_short_rope_end_room_2
    jsr set_object_position_from_cell_xy
    lda #&c0
    sta object_z_order + objectid_short_rope_end_room_2
; initialise boulder
    lda #spriteid_boulder
    sta object_spriteid + objectid_boulder_room_2
    lda #objectid_boulder_room_2
    dex
    jsr set_object_position_from_cell_xy
    lda #&e0
    sta object_z_order + objectid_boulder_room_2
.update_rope_and_seesaw_visuals_local
    jmp update_rope_and_seesaw_visuals

.update_spell
    lda save_game_level_i_spell_puzzle_progress
    beq check_for_using_sword
    cmp #&1f
    beq update_rope_and_seesaw_visuals_local
    inc save_game_level_i_spell_puzzle_progress
    jmp cutting_rope_in_progress

.check_for_using_sword
    lda desired_room_index
    cmp #2
    bne update_rope_and_seesaw_visuals_local
    lda player_using_object_spriteid
    cmp #spriteid_sword_menu_item
    bne update_rope_and_seesaw_visuals_local
    lda object_direction + objectid_player_accessory
    bmi adjust_offsets_for_looking_left
    lda #1
    sta temp_right_offset
    lda #2
    sta temp_left_offset
    jmp check_for_sword_rope_collision

.adjust_offsets_for_looking_left
    lda #&ff
    sta temp_left_offset
    lda #&fe
    sta temp_right_offset
.check_for_sword_rope_collision
    ldx #objectid_player_accessory
    ldy #objectid_rope_end_room_2
    jsr test_for_collision_between_objects_x_and_y
; sword has cut rope. Change the collision map and update the progress
    beq update_rope_and_seesaw_visuals
    ldx #&0d
    ldy #&13
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    inc save_game_level_i_spell_puzzle_progress
.cutting_rope_in_progress
    lda desired_room_index
    cmp #2
    bne update_rope_and_seesaw_visuals
    lda save_game_level_i_spell_puzzle_progress
    beq update_rope_and_seesaw_visuals
    cmp #&0a
    beq update_landing_sound
    bcc rope_moving_sound
    cmp #&1f
    bne update_rope_and_seesaw_visuals
    lda object_spriteid + objectid_spell
    beq update_rope_and_seesaw_visuals
    jsr play_landing_sound
    jmp update_rope_and_seesaw_visuals

.update_landing_sound
    lda sound_priority_per_channel_table
    cmp #&41 ; 'A'
    bcs sound_priorities_updated
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
.sound_priorities_updated
    jsr play_boulder_landing_sound
    jmp update_rope_and_seesaw_visuals

.rope_moving_sound
    lda #&40 ; '@'
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    jmp update_rope_and_seesaw_visuals

.return1_local
    jmp return1

.update_rope_and_seesaw_visuals
    lda desired_room_index
    cmp #2
    bne return1_local
    lda save_game_level_i_spell_puzzle_progress
    ldx #&ff
    cmp #&0a
    bcc got_seesaw_direction
    lda #&0a
    ldx #1
.got_seesaw_direction
    sta room_2_rope_position
    stx object_direction + objectid_seesaw
    lda room_2_rope_position
    bne set_rope_end_sprites
; show rope in initial position
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_long_rope_end_room_2
    lda #spriteid_long_rope_end2
    sta object_spriteid + objectid_rope_end_room_2
    ldx #&0d
    ldy #&13
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_rope
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq skip_writing_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.skip_writing_to_collision_map
    jmp set_right_hand_rope_and_boulder_objects

.set_rope_end_sprites
    lda #&12
    sec
    sbc room_2_rope_position
    tay
    asl a
    asl a
    asl a
    sta object_y_low + objectid_long_rope_end_room_2
    lda #spriteid_rope_end
    sta object_spriteid + objectid_long_rope_end_room_2
    lda #spriteid_rope_broken
    sta object_spriteid + objectid_rope_end_room_2
    ldx #&0d
    iny
    lda #collision_map_none
    jsr write_a_single_value_to_cell_in_collision_map
.set_right_hand_rope_and_boulder_objects
    lda room_2_rope_position
    clc
    adc #8
    asl a
    asl a
    asl a
    ldx room_2_rope_position
    cpx #&0a
    bcc got_rope_y_position
    clc
    adc #4
.got_rope_y_position
    sta object_y_low + objectid_short_rope_end_room_2
    clc
    adc #8
    sta object_y_low + objectid_boulder_room_2
    lda object_y_low + objectid_short_rope_end_room_2
    cmp object_y_low_old + objectid_short_rope_end_room_2
    beq update_spell_object_position
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_short_rope_end_room_2
.update_spell_object_position
    lda save_game_level_i_spell_puzzle_progress
    cmp #&0a
    bcc return1
    sec
    sbc #&0a
    tax
    asl a
    asl a
    asl a
    sta l0070
    lda #&f0
    sec
    sbc l0070
    sta object_x_low + objectid_spell
    lda spell_trajectory_y_coordinates_table,x
    sta object_y_low + objectid_spell
    lda object_direction + objectid_spell
    bpl return1
    inc object_x_low + objectid_spell
.return1
    rts

.room_2_rope_position
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
; #####   |     ###      ###     |   #####
; ####    |                      |    ####
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |     OOO              |     ###
; ###     |     OOO              |     ###
; ###     |     ###      ###     |     ###
; ###     |     ###      ###     |     ###
; ###     |     ###      ###     |     ###
; ###     |     ###      ###     |     ###
; ###     |     ############     |     ###
; ###     |     ############     |     ###
; ###     |       ########       |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |           P          |     ###
; #####   |                      |   #####
; #####   |                      |   #####
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x2 rectangle at (0,0)
.room_3_code
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
; draw 3x18 rectangle at (0,4)
    ldx #0
    iny
    dec width_in_cells
    lda #&12
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x18 rectangle at (37,4)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x18 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #5
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x18 rectangle at (35,22)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (14,2)
    ldx #&0e
    ldy #2
    lda #3
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (23,2)
    ldx #&17
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (14,12)
    ldx #&0e
    ldy #&0c
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (23,12)
    ldx #&17
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (14,16)
    ldx #&0e
    ldy #&10
    lda #&0c
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 8x1 rectangle at (16,18)
    ldx #&10
    ldy #&12
    lda #8
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (14,10) of size (3x2)
    ldx #&0e
    ldy #&0a
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (8,2) length 255
    ldx #8
    ldy #2
    lda #&ff
    jsr draw_rope
; draw rope at (31,2) length 255
    ldx #&1f
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_bottom
    beq room_3_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.big_stone_room_3_seesaw_animation
    equb 0, 0
    equb 248,   0
    equb 241,   0
    equb 235,   6
    equb 233,  16
    equb 232,  27
.small_stone_room_3_seesaw_animation
    equb  0, 62
    equb  2, 51
    equb  8, 40
    equb 16, 29
    equb 24, 22
    equb 32, 16
    equb 40, 11
    equb 48,  9
    equb 56,  7
    equb 64,  6
    equb 72,  7
    equb 80,  9
    equb 88, 11
    equb 96, 16
    equb 104,  22
    equb 112,  29
    equb 120,  40
    equb 126,  51
    equb 131,  64
    equb 135,  80
    equb 138,  96
    equb 140, 115

; check for first update in room (branch if not)
.update_room_3_seesaw_puzzle
    lda update_room_first_update_flag
    beq update_room_3_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_big_stone_and_seesaw_in_room_3
    lda save_game_level_i_room_3_seesaw_puzzle_progress
    beq initialise_big_stone_and_seesaw_in_room_3
    cmp #&ff
    beq initialise_big_stone_and_seesaw_in_room_3
; level has changed. set to final position if it was halfway through the animation
    lda #&19
    sta save_game_level_i_room_3_seesaw_puzzle_progress
.initialise_big_stone_and_seesaw_in_room_3
    lda desired_room_index
    cmp #3
    bne set_seesaw_direction_in_room_3_local
    lda #spriteid_erase_big_stone_or_rope_end
    sta object_erase_type + objectid_big_stone_room_3
    lda #&e0
    sta object_z_order + objectid_big_stone_room_3
    lda #spriteid_big_stone
    sta object_spriteid + objectid_big_stone_room_3
    lda #spriteid_erase_seesaw
    sta object_erase_type + objectid_seesaw
    ldx #&14
    ldy #&10
    lda #objectid_seesaw
    jsr set_object_position_from_cell_xy
    lda #spriteid_seesaw
    sta object_spriteid + objectid_seesaw
.set_seesaw_direction_in_room_3_local
    jmp set_seesaw_direction_in_room_3

.update_room_3_not_first_update
    lda save_game_level_i_room_3_seesaw_puzzle_progress
    beq check_for_player_big_stone_collision
    cmp #&19
    beq check_for_player_small_stone_collision
    cmp #&ff
    beq set_seesaw_direction_in_room_3
    inc save_game_level_i_room_3_seesaw_puzzle_progress
    lda desired_room_index
    cmp #3
    bne set_seesaw_direction_in_room_3
    lda save_game_level_i_room_3_seesaw_puzzle_progress
    cmp #5
    beq big_stone_lands
    cmp #&19
    bne set_seesaw_direction_in_room_3
.big_stone_lands
    jsr play_landing_sound
    jmp set_seesaw_direction_in_room_3

.check_for_player_big_stone_collision
    lda desired_room_index
    cmp #3
    bne set_seesaw_direction_in_room_3
    ldx #objectid_old_player
    ldy #objectid_big_stone_room_3
    jsr test_for_collision_between_objects_x_and_y
    beq set_seesaw_direction_in_room_3
; set big stone animation going
    inc save_game_level_i_room_3_seesaw_puzzle_progress
    jmp set_seesaw_direction_in_room_3

.check_for_player_small_stone_collision
    lda desired_room_index
    cmp #3
    bne set_seesaw_direction_in_room_3
    ldx #objectid_old_player
    ldy #objectid_small_stone_object
    jsr test_for_collision_between_objects_x_and_y
    beq set_seesaw_direction_in_room_3
; collected small stone object, add to toolbar
    lda #spriteid_stone_menu_item
    jsr find_or_create_menu_slot_for_A
; mark small stone as being in the player's possession
    lda #&ff
    sta save_game_level_i_room_3_seesaw_puzzle_progress
    sta save_game_level_i_room_0_seesaw_puzzle_progress
; hide small stone object
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_small_stone_object
.set_seesaw_direction_in_room_3
    lda desired_room_index
    cmp #3
    bne return2
    lda #1
    sta object_direction + objectid_seesaw
    ldx save_game_level_i_room_3_seesaw_puzzle_progress
    ldy #0
    cpx #5
    bcc set_big_stone_position_in_room_3
    lda #&ff
    sta object_direction + objectid_seesaw
    ldx #5
    lda save_game_level_i_room_3_seesaw_puzzle_progress
    sec
    sbc #5
    tay
    iny
.set_big_stone_position_in_room_3
    txa
    asl a
    tax
    lda big_stone_room_3_seesaw_animation,x
    clc
    adc #&c4
    sta object_x_low + objectid_big_stone_room_3
    inx
    lda big_stone_room_3_seesaw_animation,x
    dex
    clc
    adc #&5e ; '^'
    sta object_y_low + objectid_big_stone_room_3
    ldx #&18
    sty small_stone_animation_step
    ldy #&0b
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    ldy small_stone_animation_step
    lda save_game_level_i_room_3_seesaw_puzzle_progress
    cmp #&ff
    beq return2
; position small stone to be animated. Animation step Y.
    lda #spriteid_erase_small_stone
    sta object_erase_type + objectid_small_stone_object
    lda #&a0
    sta object_z_order + objectid_small_stone_object
    lda #spriteid_small_stone
    sta object_spriteid + objectid_small_stone_object
    tya
    asl a
    tay
    lda small_stone_room_3_seesaw_animation,y
    clc
    adc #&90
    sta object_x_low + objectid_small_stone_object
    lda #0
    adc #0
    sta object_x_high + objectid_small_stone_object
    iny
    lda small_stone_room_3_seesaw_animation,y
    clc
    adc #&38 ; '8'
    sta object_y_low + objectid_small_stone_object
.return2
    rts

.draw_top_and_bottom_rows_of_solid_rock
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    ldy #&16
    jmp copy_rectangle_of_memory_to_screen

; *************************************************************************************
; 
; Room 0 initialisation and game loop
; 
; *************************************************************************************
.room_0_data
    equb 31                                                           ; initial player X cell
    equb 21                                                           ; initial player Y cell

; ########################################
; ########################################
; #####
; ####
; ###
; ###          OOO         OOO
; ###          OOO         OOO
; ###          ###############         ###
; ###          ###############         ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###                     ###
; ###          ###
; ###          ###         ###
; ###          ###         ###
; ###          ###         ###   P
; ###          ###         ########
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_0_code
    jsr draw_top_and_bottom_rows_of_solid_rock
; draw 5x1 rectangle at (0,2)
    ldy #2
    lda #5
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,3)
    iny
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x18 rectangle at (0,4)
    iny
    dec width_in_cells
    lda #&12
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (37,7)
    ldx #&25 ; '%'
    ldy #7
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 15x2 rectangle at (13,7)
    ldx #&0d
    ldy #7
    lda #&0f
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x13 rectangle at (13,9)
    ldy #9
    lda #3
    sta width_in_cells
    lda #&0d
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (25,18)
    ldx #&19
    ldy #&12
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (28,21)
    ldx #&1c
    ldy #&15
    lda #5
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (13,5) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&0d
    ldy #5
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (25,5) of size (3x2)
    ldx #&19
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    jsr set_or_clear_collision_map_cell_for_big_stone
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.big_stone_animation
    equb 0, 0
    equb &f8,   0
    equb &f1,   0
    equb &eb,   2
    equb &e5,   6
    equb &e0, &0c
    equb &dd, &13
    equb &dc, &1b
.sword_animation
    equb   4, &48
    equb &0b, &3e
    equb &14, &2f
    equb &1d, &25
    equb &26, &1e
    equb &2f, &19
    equb &38, &14
    equb &41, &10
    equb &4a, &0c
    equb &53, &0a
    equb &5c,   8
    equb &65,   7
    equb &6f,   6
    equb &79,   5
    equb &83,   5
    equb &8d,   5
.sword_animation_spriteids
    equb         spriteid_sword_spinA - spriteid_small_stone
    equb 256 - (spriteid_sword_spinA - spriteid_small_stone)
    equb 256 - (spriteid_sword_spinB - spriteid_small_stone)
    equb 256 - (spriteid_sword_spinC - spriteid_small_stone)
    equb 256 - (spriteid_sword_spinD - spriteid_small_stone)
    equb         spriteid_sword_spinD - spriteid_small_stone
    equb         spriteid_sword_spinC - spriteid_small_stone
    equb         spriteid_sword_spinB - spriteid_small_stone
    equb         spriteid_sword_spinA - spriteid_small_stone
    equb 256 - (spriteid_sword_spinA - spriteid_small_stone)
    equb 256 - (spriteid_sword_spinB - spriteid_small_stone)
    equb 256 - (spriteid_sword_spinC - spriteid_small_stone)
    equb 256 - (spriteid_sword_spinD - spriteid_small_stone)
    equb         spriteid_sword_spinD - spriteid_small_stone
    equb         spriteid_sword_spinC - spriteid_small_stone
    equb         spriteid_sword_spinB - spriteid_small_stone

; check for first update in room (branch if not)
.update_sword_puzzle
    lda update_room_first_update_flag
    beq update_sword_puzzle_not_first_update
    lda #spriteid_sword_menu_item
    sta toolbar_collectable_spriteids+2
    lda #spriteid_sword
    sta collectable_spriteids+2
    sta collectable_being_used_spriteids+2
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq check_for_room_0
; if sword animation is not in progress, branch
    lda save_game_level_i_sword_puzzle_progress
    beq check_for_room_0
    cmp #&ff
    beq check_for_room_0
; if sword animation was partway finished, then set it to finished (sword in wall)
    lda #&15
    sta save_game_level_i_sword_puzzle_progress
.check_for_room_0
    lda desired_room_index
    cmp #0
    bne update_room_0_seesaw_animation_if_in_room_0_local
; initialise room 0
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
; initialise big stone
    lda #spriteid_erase_big_stone_or_rope_end
    sta object_erase_type + objectid_big_stone_room_0
    lda #&e0
    sta object_z_order + objectid_big_stone_room_0
    lda #spriteid_big_stone
    sta object_spriteid + objectid_big_stone_room_0
; initialise seesaw
    lda #spriteid_erase_seesaw
    sta object_erase_type + objectid_seesaw
    ldx #&14
    lda #4
    sta temp_sprite_x_offset
    ldy #&16
    lda #objectid_seesaw
    jsr set_object_position_from_cell_xy
    lda #spriteid_seesaw
    sta object_spriteid + objectid_seesaw
; initialise sword
    lda #spriteid_erase_sword
    sta object_erase_type + objectid_sword
    lda #&c0
    sta object_z_order + objectid_sword
.update_room_0_seesaw_animation_if_in_room_0_local
    jmp update_room_0_seesaw_animation_if_in_room_0

.update_sword_puzzle_not_first_update
    lda save_game_level_i_sword_puzzle_progress
    beq sword_puzzle_not_started_yet
    cmp #&15
    beq sword_in_wall
    cmp #&ff
    beq update_room_0_seesaw_animation_if_in_room_0
    inc save_game_level_i_sword_puzzle_progress
    lda desired_room_index
    cmp #0
    bne update_room_0_seesaw_animation_if_in_room_0
    lda save_game_level_i_sword_puzzle_progress
    cmp #7
    bne check_for_sword_hitting_wall_sound
    jsr play_landing_sound
    jmp update_room_0_seesaw_animation_if_in_room_0

.check_for_sword_hitting_wall_sound
    lda save_game_level_i_sword_puzzle_progress
    cmp #&15
    bne update_room_0_seesaw_animation_if_in_room_0
    ldx #<sword_thud_sound
    ldy #>sword_thud_sound
    jsr play_sound_yx
    jmp update_room_0_seesaw_animation_if_in_room_0

.sword_puzzle_not_started_yet
    lda desired_room_index
    cmp #0
    bne update_room_0_seesaw_animation_if_in_room_0
; check for small stone big stone collision
    ldx #objectid_old_small_stone_object
    ldy #objectid_big_stone_room_0
    jsr test_for_collision_between_objects_x_and_y
    beq update_room_0_seesaw_animation_if_in_room_0
; found small stone big stone collision
    inc save_game_level_i_sword_puzzle_progress
    jmp update_room_0_seesaw_animation_if_in_room_0

.sword_in_wall
    lda desired_room_index
    cmp #0
    bne update_room_0_seesaw_animation_if_in_room_0
; check for player sword collision
    ldx #objectid_old_player
    ldy #objectid_sword
    jsr test_for_collision_between_objects_x_and_y
    beq update_room_0_seesaw_animation_if_in_room_0
; found player sword collision, add sword to toolbar
    lda #spriteid_sword_menu_item
    jsr find_or_create_menu_slot_for_A
; mark sword as taken
    lda #&ff
    sta save_game_level_i_sword_puzzle_progress
.update_room_0_seesaw_animation_if_in_room_0
    lda desired_room_index
    cmp #0
    beq update_room_0_seesaw_animation
    jmp return3

.update_room_0_seesaw_animation
    lda #1
    sta object_direction + objectid_seesaw
; set X to the animation step for position, and Y to the sprite index
    ldx save_game_level_i_sword_puzzle_progress
    ldy #0
    cpx #7
    bcc update_big_stone_position_and_sprite
; flip seesaw
    lda #&ff
    sta object_direction + objectid_seesaw
    ldx #7
    lda save_game_level_i_sword_puzzle_progress
    sec
    sbc #7
    tay
    iny
.update_big_stone_position_and_sprite
    txa
    asl a
    tax
    lda big_stone_animation,x
    clc
    adc #&d4
    sta object_x_low + objectid_big_stone_room_0
    inx
    lda big_stone_animation,x
    dex
    clc
    adc #&8e
    sta object_y_low + objectid_big_stone_room_0
    tya
    pha
    jsr set_or_clear_collision_map_cell_for_big_stone
    pla
    tay
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_sword
    lda save_game_level_i_sword_puzzle_progress
    cmp #&ff
    beq return3
    lda sword_animation_spriteids,y
    bmi spin_sword_in_opposite_direction
    clc
    adc #spriteid_small_stone
    sta object_spriteid + objectid_sword
    lda #1
    sta object_direction + objectid_sword
    jmp update_sword_position

.spin_sword_in_opposite_direction
    eor #&ff
    sec
    adc #spriteid_small_stone
    sta object_spriteid + objectid_sword
    lda #&ff
    sta object_direction + objectid_sword
.update_sword_position
    tya
    asl a
    tay
    lda sword_animation,y
    clc
    adc #&90
    sta object_x_low + objectid_sword
    lda #0
    adc #0
    sta object_x_high + objectid_sword
    iny
    lda sword_animation,y
    clc
    adc #&58 ; 'X'
    sta object_y_low + objectid_sword
.return3
    rts

.set_or_clear_collision_map_cell_for_big_stone
    lda #collision_map_solid_rock
    ldx save_game_level_i_sword_puzzle_progress
    cpx #4
    bcc write_to_collision_map_for_big_stone
    lda #collision_map_none
.write_to_collision_map_for_big_stone
    ldx #&1a
    ldy #&11
    jsr write_a_single_value_to_cell_in_collision_map
    rts

.small_stone_room_0_seesaw_animations
    equb 0
.small_stone_rising_arc_room_0_seesaw_animation
    equb 0, 0
    equb   8, &f8
    equb   6, &fa
    equb   6, &fc
    equb   6, &fe
    equb   6, &ff
    equb &80
.small_stone_falling_arc_room_0_seesaw_animation
    equb 6, 1
    equb 6, 2
    equb 6, 4
    equb 6, 6
    equb 4, 8
    equb 2, 8
    equb &80
.small_stone_falling_room_0_seesaw_animation
    equb 0, 8
    equb &80
.small_stone_still_room_0_seesaw_animation
    equb 0, 0
    equb &80
.small_stone_fall_off_edge_room_0_seesaw_animation
    equb 4, 2
    equb 3, 3
    equb 2, 4
    equb 1, 6
    equb &80

; check for first update in room (branch if so)
.update_room_0_seesaw_puzzle
    lda update_room_first_update_flag
    bne update_room_0_seesaw_puzzle_first_update
    jmp update_room_0_seesaw_puzzle_not_first_update

.update_room_0_seesaw_puzzle_first_update
    lda #spriteid_stone_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_small_stone
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq no_level_change
    lda #0
    sta level_workspace
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    beq no_level_change
    bmi no_level_change
    cmp #small_stone_still_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    beq no_level_change
    dec level_workspace
.no_level_change
    lda desired_room_index
    cmp save_game_level_i_small_stone_room
    bne hide_small_stone
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    beq hide_small_stone
    bmi hide_small_stone
    jsr set_small_stone_object
.fast_forward_small_stone_animation_loop
    lda desired_room_index
    cmp save_game_level_i_small_stone_room
    bne hide_small_stone
    lda level_workspace
    beq hide_small_stone
    dec level_workspace
    ldx #objectid_small_stone_object
    jsr copy_object_state_to_old
    jsr move_to_next_animation_step
    jmp fast_forward_small_stone_animation_loop

.hide_small_stone
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_small_stone_object
.return4_local
    jmp return4

.update_room_0_seesaw_puzzle_not_first_update
    lda #0
    sta small_stone_just_thrown
    lda player_held_object_spriteid
    sta remember_player_held_object
    lda object_spriteid_old + objectid_small_stone_object
    sta rememebr_old_small_stone_spriteid
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    beq return4_local
    bmi initialise_room_0_seesaw_puzzle
    lda desired_room_index
    cmp save_game_level_i_small_stone_room
    beq stone_in_room
    lda level_workspace
    bmi return4_local
    inc level_workspace
    jmp return4

.initialise_room_0_seesaw_puzzle
    lda #spriteid_stone_menu_item
    cmp player_using_object_spriteid
    bne return4_local
    cmp previous_player_using_object_spriteid
    beq return4_local
    dec small_stone_just_thrown
    lda desired_room_index
    sta save_game_level_i_small_stone_room
    lda object_direction
    sta save_game_level_i_small_stone_direction_without_bounces
    sta save_game_level_i_small_stone_direction_including_bounces
    lda object_x_low + objectid_player_accessory
    sta save_game_level_i_small_stone_x_low
    lda object_x_high + objectid_player_accessory
    sta save_game_level_i_small_stone_x_high
    lda object_y_low + objectid_player_accessory
    sta save_game_level_i_small_stone_y_low
    lda object_y_high + objectid_player_accessory
    sta save_game_level_i_small_stone_y_high
    lda #small_stone_rising_arc_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    sta save_game_level_i_small_stone_room_0_seesaw_animation_step
    sta save_game_level_i_room_0_seesaw_puzzle_progress
    jsr set_small_stone_object
    ldx #objectid_small_stone_object
    jsr copy_object_state_to_old
    lda #0
    sta player_held_object_spriteid
.stone_in_room
    jsr move_to_next_animation_step
    lda desired_room_index
    cmp save_game_level_i_small_stone_room
    beq check_for_player_small_stone_collision1
    lda #0
    sta level_workspace
.check_for_player_small_stone_collision1
    lda rememebr_old_small_stone_spriteid
    sta object_spriteid_old + objectid_small_stone_object
    ldx #objectid_old_player
    ldy #objectid_small_stone_object
    jsr test_for_collision_between_objects_x_and_y
    ldx remember_player_held_object
    stx player_held_object_spriteid
    ora #0
    beq no_player_small_stone_collision
    lda small_stone_just_thrown
    bne hide_small_stone1
; add stone to toolbar
    lda #spriteid_stone_menu_item
    jsr find_or_create_menu_slot_for_A
.hide_small_stone1
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_small_stone_object
; mark small stone as obtained by player
    lda #&ff
    sta save_game_level_i_room_0_seesaw_puzzle_progress
    jmp return4

.no_player_small_stone_collision
    lda small_stone_just_thrown
    beq check_for_stone_moving_in_x
; remove small stone from toolbar
    lda #spriteid_stone_menu_item
    jsr remove_item_from_toolbar_menu
; stone is no longer held or being used by player
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_player_accessory
    sta player_using_object_spriteid
    sta player_held_object_spriteid
.check_for_stone_moving_in_x
    lda object_x_low + objectid_small_stone_object
    cmp object_x_low_old + objectid_small_stone_object
    beq check_for_stone_moving_in_y
; stone is moving in x, check for collision with walls
    lda save_game_level_i_small_stone_direction_including_bounces
    bmi stone_moving_left
; stone moving right
    inc temp_right_offset
    jmp check_for_stone_bouncing

.stone_moving_left
    dec temp_left_offset
.check_for_stone_bouncing
    lda #1
    sta temp_bottom_offset
    lda #objectid_small_stone_object
    jsr get_solid_rock_collision_for_object_a
    beq check_for_stone_moving_in_y
    jsr play_landing_sound
    jmp return4

.check_for_stone_moving_in_y
    lda object_y_low + objectid_small_stone_object
    cmp object_y_low_old + objectid_small_stone_object
    beq return4
; check for stone landing
    dec temp_top_offset
    lda #2
    sta temp_bottom_offset
    lda #objectid_small_stone_object
    jsr get_solid_rock_collision_for_object_a
    beq return4
    jsr play_landing_sound
.return4
    rts

.move_to_next_animation_step
    lda save_game_level_i_small_stone_room_0_seesaw_animation_step
    clc
    adc #2
    tay
    lda small_stone_room_0_seesaw_animations,y
    cmp #&80
    bne got_valid_animation_step
    ldy save_game_level_i_room_0_seesaw_puzzle_progress
.got_valid_animation_step
    lda save_game_level_i_small_stone_direction_including_bounces
    bmi bouncing_left
    inc temp_right_offset
    jmp check_for_stone_wall_collision

.bouncing_left
    dec temp_left_offset
.check_for_stone_wall_collision
    lda #1
    sta temp_bottom_offset
    lda #objectid_small_stone_object
    jsr get_solid_rock_collision_for_object_a
    beq no_collision
; reverse direction because stone bounced off wall
    lda save_game_level_i_small_stone_direction_including_bounces
    eor #&fe
    sta save_game_level_i_small_stone_direction_including_bounces
.no_collision
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    cmp #small_stone_rising_arc_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    bne check_for_hitting_floor
    dec temp_top_offset
    lda #objectid_small_stone_object
    jsr get_solid_rock_collision_for_object_a
    bne start_small_stone_falling
    cpy save_game_level_i_room_0_seesaw_puzzle_progress
    bne set_small_stone_animation_step
.start_small_stone_falling
    lda #small_stone_falling_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    sta save_game_level_i_room_0_seesaw_puzzle_progress
    ldy #small_stone_falling_arc_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
.check_for_hitting_floor
    lda #objectid_small_stone_object
    jsr update_object_hitting_floor
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    cmp #small_stone_falling_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    bne check_for_stone_falling_off_edge
    lda object_has_hit_floor_flag
    beq set_small_stone_animation_step
    ldy #small_stone_still_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    sty save_game_level_i_room_0_seesaw_puzzle_progress
.check_for_stone_falling_off_edge
    lda object_just_fallen_off_edge_direction
    beq set_small_stone_animation_step
    ldy #small_stone_falling_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    sty save_game_level_i_room_0_seesaw_puzzle_progress
    ldy #small_stone_fall_off_edge_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    ldx #1
    stx save_game_level_i_small_stone_direction_including_bounces
    ora #0
    bpl set_small_stone_animation_step
    ldx #&ff
    stx save_game_level_i_small_stone_direction_including_bounces
.set_small_stone_animation_step
    sty save_game_level_i_small_stone_room_0_seesaw_animation_step
    lda save_game_level_i_room_0_seesaw_puzzle_progress
    cmp #small_stone_still_room_0_seesaw_animation - small_stone_room_0_seesaw_animations
    bne set_small_stone_position_based_on_animation_step
    lda #0
    sta level_workspace
.set_small_stone_position_based_on_animation_step
    lda small_stone_room_0_seesaw_animations,y
    ldx save_game_level_i_small_stone_direction_including_bounces
    bpl stone_travelling_right
    eor #&ff
    clc
    adc #1
.stone_travelling_right
    ldx #0
    ora #0
    bpl add_to_small_stone_x
    dex
.add_to_small_stone_x
    clc
    adc save_game_level_i_small_stone_x_low
    sta save_game_level_i_small_stone_x_low
    txa
    adc save_game_level_i_small_stone_x_high
    sta save_game_level_i_small_stone_x_high
    iny
    lda small_stone_room_0_seesaw_animations,y
    ldx #0
    ora #0
    bpl add_to_small_stone_y
    dex
.add_to_small_stone_y
    clc
    adc save_game_level_i_small_stone_y_low
    sta save_game_level_i_small_stone_y_low
    txa
    adc save_game_level_i_small_stone_y_high
    sta save_game_level_i_small_stone_y_high
    jsr set_small_stone_object
; collide object with world, then save the results
    lda #objectid_small_stone_object
    jsr update_object_a_solid_rock_collision
    lda object_x_low + objectid_small_stone_object
    sta save_game_level_i_small_stone_x_low
    lda object_x_high + objectid_small_stone_object
    sta save_game_level_i_small_stone_x_high
    lda object_y_low + objectid_small_stone_object
    sta save_game_level_i_small_stone_y_low
    lda object_y_high + objectid_small_stone_object
    sta save_game_level_i_small_stone_y_high
; get extents of the small stone
    ldx #objectid_small_stone_object
    jsr find_left_and_right_of_object
    jsr find_top_and_bottom_of_object
; move to the next room if needed
    lda save_game_level_i_small_stone_room
    cmp #3
    beq move_small_stone_one_room_down_if_needed
    lda save_game_level_i_small_stone_direction_including_bounces
    bmi move_small_stone_one_room_left_if_needed
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return5
; move small stone right one room
    lda save_game_level_i_small_stone_x_low
    sec
    sbc #&40 ; '@'
    sta save_game_level_i_small_stone_x_low
    lda #0
    sbc #0
    sta save_game_level_i_small_stone_x_high
    inc save_game_level_i_small_stone_room
    jmp hide_stone

.move_small_stone_one_room_left_if_needed
    lda object_right_cell_x
    bpl return5
    lda save_game_level_i_small_stone_x_low
    clc
    adc #<(game_area_width_cells * 8)
    sta save_game_level_i_small_stone_x_low
    lda #>(game_area_width_cells * 8)
    sta save_game_level_i_small_stone_x_high
    dec save_game_level_i_small_stone_room
    jmp hide_stone

.move_small_stone_one_room_down_if_needed
    lda object_top_cell_y
    cmp #game_area_height_cells
    bcc return5
    lda save_game_level_i_small_stone_x_low                           ; [bug - should be y coordinate?]
    sec
    sbc #<(game_area_height_cells * 8)
    sta save_game_level_i_small_stone_y_low
    lda #0
    sbc #>(game_area_height_cells * 8)
    sta save_game_level_i_small_stone_y_high
    lda #1
    sta save_game_level_i_small_stone_room
.hide_stone
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_small_stone_object
.return5
    rts

.set_small_stone_object
    lda #spriteid_erase_small_stone
    sta object_erase_type + objectid_small_stone_object
    lda #&a0
    sta object_z_order + objectid_small_stone_object
    lda save_game_level_i_small_stone_x_low
    sta object_x_low + objectid_small_stone_object
    lda save_game_level_i_small_stone_x_high
    sta object_x_high + objectid_small_stone_object
    lda save_game_level_i_small_stone_y_low
    sta object_y_low + objectid_small_stone_object
    lda save_game_level_i_small_stone_y_high
    sta object_y_high + objectid_small_stone_object
    lda #spriteid_small_stone
    sta object_spriteid + objectid_small_stone_object
    lda save_game_level_i_small_stone_direction_without_bounces
    sta object_direction + objectid_small_stone_object
    rts

.small_stone_just_thrown
    equb 0
.remember_player_held_object
    equb 0
.rememebr_old_small_stone_spriteid
    equb 0
.small_stone_animation_step
    equb 0

.play_boulder_landing_sound
    lda #0
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    ldx #<sound4
    ldy #>sound4
    jmp play_sound_yx

.envelope3
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
.sword_thud_sound
    equw &0013                                                        ; channel
    equw 5                                                            ; amplitude
    equw 201                                                          ; pitch
    equw 1                                                            ; duration
.envelope1
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
.sound1
    equw &0010                                                        ; channel
    equw 5                                                            ; amplitude
    equw 4                                                            ; pitch
    equw 4                                                            ; duration
.envelope2
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
.ground_fill_2x2_top_left
    equb %00001000
    equb %00001000
    equb %00010100
    equb %00100011
    equb %11000000
    equb %00100000
    equb %00010000
    equb %00010000
.ground_fill_2x2_top_right
    equb %00010000
    equb %00010000
    equb %00101000
    equb %11000100
    equb %00000011
    equb %00000100
    equb %00001000
    equb %00001000
.ground_fill_2x2_bottom_left
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11000000
    equb %00100011
    equb %00010100
    equb %00001000
    equb %00001000
.ground_fill_2x2_bottom_right
    equb %00001000
    equb %00001000
    equb %00000100
    equb %00000011
    equb %11000100
    equb %00101000
    equb %00010000
    equb %00010000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelI_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelI.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelI"
ENDIF
ENDIF
.pydis_end

save "build/dataI", pydis_start, pydis_end
