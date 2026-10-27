; *************************************************************************************
;
; Level C: FIRE-WORKS
;
; Save game variables:
;
;     save_game_level_c_got_torch ($0a0a):
;               0: not got
;             1-8: torch lit (animation state)
;             $ff: got
;     save_game_level_c_burning_table_progress ($0a0b):
;               0: not burnt
;              1+: burn in progress
;             $ff: got
;     save_game_level_c_room_0_and_2_burning_rope_progress ($0a0c):
;               0: not burnt
;              1+: burn in progress
;             $ff: got
;     save_game_level_c_room_1_burning_rope_progress ($0a0d):
;               0: not burnt
;              1+: burn in progress
;             $ff: got
;
; Solution:
;
;   1. Climb the right hand rope up to the room above and enter the right side room.
;   2. Climb rope to get the torch object.
;   3. Use the torch to light the table in the lower left corner.
;   4. Go back down to the start room and light the left hand rope.
;   5. Climb back up the right hand rope and at the top exit to the left room.
;   6. From the top of the bottom left rock pile, climb the leftmost rope to the top.
;   7. Fall to the bottom of the rope (ahead of the parrot) and quickly jump across the
;      ropes to the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_fire1                        = 6
objectid_fire2                        = 7
objectid_fire3                        = 8
objectid_parrot                       = 5
objectid_rope_end                     = 3
objectid_rope_fire                    = 4
objectid_spell                        = 6
objectid_table                        = 5
objectid_torch                        = 2
spriteid_boulder                      = 200
spriteid_cache1                       = 204
spriteid_cache2                       = 206
spriteid_cache3                       = 207
spriteid_cache4                       = 208
spriteid_cache5                       = 209
spriteid_cache6                       = 210
spriteid_cache7                       = 211
spriteid_cache8                       = 217
spriteid_empty_hook                   = 216
spriteid_fire                         = 205
spriteid_fire_bottom                  = 215
spriteid_parrot1                      = 218
spriteid_parrot2                      = 219
spriteid_parrot_squawk                = 220
spriteid_table                        = 201
spriteid_table_burnt1                 = 212
spriteid_table_burnt2                 = 213
spriteid_table_burnt3                 = 214
spriteid_torch_menu_item              = 203
spriteid_torch_object                 = 202
spriteid_torch_object2                = 223

; Memory locations
player_to_parrot_distance_x_low                     = &0070
room_exit_direction                                 = &0070
temp_player_y_high                                  = &0070
player_to_parrot_distance_x_high                    = &0071
save_game_level_c_got_torch                         = &0a0a
save_game_level_c_burning_table_progress            = &0a0b
save_game_level_c_room_0_and_2_burning_rope_progress = &0a0c
save_game_level_c_room_1_burning_rope_progress      = &0a0d
room_0_rope_burning_progress                        = &0a6f
room_1_rope_burning_progress                        = &0a70
room_0_and_2_parrot_y                               = &0a71
room_0_and_2_parrot_animation_index                 = &0a72
room_0_and_2_parrot_animation_step                  = &0a73
room_0_and_2_parrot_delay_before_chirp              = &0a74
room_3_parrot_y                                     = &0a75
room_3_parrot_animation_index                       = &0a76
room_3_parrot_animation_step                        = &0a77
room_3_parrot_delay_before_chirp                    = &0a78

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelC_sprite_table - level_data
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
    equb 0
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "FIRE-WORKS", &0D

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
    sta save_game_level_c_got_torch
.developer_mode_inactive
    lda save_game_level_c_got_torch
    beq return1
    lda #spriteid_torch_menu_item
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
    jsr update_torch
    rts

; *************************************************************************************
; 
; Room 0 initialisation and game loop
; 
; *************************************************************************************
.room_0_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ###         ################   |     ###
; ###         ################   |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###         ################   |     ###
; ###         ################   |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                            |     ###
; ###                                  ###
; ###                                  ###
; ###                               OOO###
; ############                      OOO###
; ##############                 OOOOOO###
; ################    P          OOOOOO###
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
; draw 3x255 rectangle at (0,0)
    ldx #0
    ldy #0
    lda #3
    sta width_in_cells
    lda #&ff
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x255 rectangle at (37,0)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 9x255 rectangle at (3,19)
    ldx #3
    ldy #&13
    lda #9
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 25x255 rectangle at (12,22)
    ldx #&0c
    ldy #&16
    lda #&19
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (12,21)
    dey
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 2x1 rectangle at (12,20)
    dey
    dec width_in_cells
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,0)
    ldx #&0c
    ldy #0
    lda #&10
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,9)
    ldy #9
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (31,0) length 16
    ldx #&1f
    ldy #0
    lda #&10
    jsr draw_rope
; draw boulder at (34,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&22 ; '"'
    ldy #&14
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (31,20) of size (3x2)
    ldx #&1f
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (34,18) of size (3x2)
    ldx #&22 ; '"'
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_top
    beq room_0_game_update_loop
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_0_update_handler
    lda #0
    sta currently_updating_logic_for_room_index
    ldx #3
    ldy #&0a
    lda #objectid_fire1
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #objectid_fire2
    jsr update_brazier_and_fire
    lda room_0_rope_burning_progress
    sta burning_rope_pixel_y
    lda save_game_level_c_room_0_and_2_burning_rope_progress
    sta burning_rope_progress
    ldx #objectid_fire3
    ldy #0
    lda #&10
    jsr update_burnable_rope
    lda burning_rope_pixel_y
    sta room_0_rope_burning_progress
    lda burning_rope_progress
    sta save_game_level_c_room_0_and_2_burning_rope_progress
    rts

; *************************************************************************************
; 
; Update a burnable rope
; 
; On Entry:
;     A: length of rope
;     (X,Y): cell position of top of rope
; 
; *************************************************************************************
.update_burnable_rope
    sta burnable_rope_length
    stx burnable_rope_cell_x
    sty burnable_rope_cell_y
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne update_burnable_rope_first_update
    jmp update_burnable_rope_not_first_update

; check for level change (branch if not)
.update_burnable_rope_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq no_level_change
    lda burning_rope_progress
    beq no_level_change
    lda #&ff
    sta burning_rope_progress
.no_level_change
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne check_rope_fire_starting_local
    ldx #4
    lda #spriteid_cache8
    sta object_erase_type,x
    lda #&e0
    sta object_z_order,x
    ldx burnable_rope_cell_x
    ldy burnable_rope_cell_y
    lda burning_rope_progress
    beq not_burnt_yet
    bpl burning_in_progress
    lda burnable_rope_cell_y
    beq check_rope_fire_starting_local
    lda #spriteid_empty_hook
    jsr draw_sprite_a_at_cell_xy
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
    jmp check_rope_fire_starting_local

.burning_in_progress
    lda burning_rope_pixel_y
    clc
    adc #3
    lsr a
    lsr a
    lsr a
    sec
    sbc burnable_rope_cell_y
    beq check_rope_fire_starting_local
    clc
    adc #1
    jsr draw_rope
    sec
    sbc #1
    clc
    adc burnable_rope_cell_y
    tay
    lda #sprite_op_flags_erase_to_fg_colour
    sta sprite_op_flags
    lda #spriteid_rope_end
    jsr draw_sprite_a_at_cell_xy
    lda #0
    jsr write_a_single_value_to_cell_in_collision_map
    jmp check_rope_fire_starting_local

.not_burnt_yet
    lda burnable_rope_length
    jsr draw_rope
    tya
    clc
    adc burnable_rope_length
    tay
    dey
    lda #objectid_rope_end
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_rope_end
    sta object_spriteid,x
.check_rope_fire_starting_local
    jmp check_rope_fire_starting

.return2_local
    jmp return2

.update_burnable_rope_not_first_update
    lda burning_rope_progress
    bmi return2_local
    bne rope_is_burning
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return2_local
    ldx #objectid_torch
    ldy #objectid_rope_end
    jsr test_for_collision_between_objects_x_and_y
    beq return2_local
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_rope_end
    lda burnable_rope_cell_y
    clc
    adc burnable_rope_length
    sec
    sbc #1
    asl a
    asl a
    asl a
    ora #5
    sta burning_rope_pixel_y
    lda #1
    sta burning_rope_progress
    jmp check_rope_fire_starting

.rope_is_burning
    lda burning_rope_progress
    cmp #2
    beq finish_rope_all_burnt
    lda burning_rope_pixel_y
    sec
    sbc #4
    sta burning_rope_pixel_y
    cmp #&c0
    bcs finish_rope_burning_gone_off_top_of_screen
; check for fire reaching the top of the rope
    lsr a
    lsr a
    lsr a
    beq check_rope_fire_starting
    cmp burnable_rope_cell_y
    bne check_rope_fire_starting
; fire has reached the top of the rope
    lda #2
    sta burning_rope_progress
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne check_rope_fire_starting
; put out fire, replace with cache of what was there before
    lda #spriteid_cache2
    sta object_spriteid + objectid_rope_fire
.finish_rope_all_burnt
    lda #&ff
    sta burning_rope_progress
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne check_rope_fire_starting
; position and show the empty hook as the rope end
    ldx burnable_rope_cell_x
    ldy burnable_rope_cell_y
    lda #objectid_rope_end
    jsr set_object_position_from_cell_xy
    lda #spriteid_empty_hook
    sta object_spriteid + objectid_rope_end
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_rope_fire
    jmp check_rope_fire_starting

.finish_rope_burning_gone_off_top_of_screen
    lda #&ff
    sta burning_rope_progress
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne check_rope_fire_starting
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_rope_end
    sta object_spriteid + objectid_rope_fire
.check_rope_fire_starting
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return2
    lda burning_rope_progress
    cmp #1
    bne return2
; show rope fire starting
    lda #spriteid_fire_bottom
    sta object_spriteid + objectid_rope_end
    lda burning_rope_pixel_y
    lsr a
    lsr a
    and #7
    clc
    adc #spriteid_fire1
    sta object_spriteid + objectid_rope_fire
    ldx burnable_rope_cell_x
    lda #3
    sta temp_sprite_x_offset
    ldy #0
    lda #objectid_rope_end
    jsr set_object_position_from_cell_xy
    lda #3
    sta temp_sprite_x_offset
    lda #objectid_rope_fire
    jsr set_object_position_from_cell_xy
    lda burning_rope_pixel_y
    sta object_y_low + objectid_rope_end
    sta object_y_low + objectid_rope_fire
    ldx #8
    lda burning_rope_pixel_y
    lsr a
    lsr a
    lsr a
    tay
    lda #0
    jsr write_a_single_value_to_cell_in_collision_map
.return2
    rts

.burning_rope_progress
    equb 0
.burning_rope_pixel_y
    equb 0
.burnable_rope_cell_x
    equb 0
.burnable_rope_cell_y
    equb 0
.burnable_rope_length
    equb 0
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
; ####             #######            ####
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###OOO                               ###
; ###OOO                               ###
; ###OOOOOO                      OOOOOO###
; ###OOOOOO                      OOOOOO###
; #################       ################
; #################       ################
;                                     ####
;                                      ###
;                                      ###
;                                      ###
;                                      ###
; #####                                ###
; #####                                ###
; #####OOO                             ###
; #####OOO            P                ###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x1 rectangle at (17,2)
    ldx #&11
    lda #7
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,3)
    ldx #0
    iny
    lda #3
    sta width_in_cells
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (37,3)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (0,11)
    ldx #0
    ldy #&0b
    lda #&11
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (24,11)
    ldx #&18
    jsr copy_rectangle_of_memory_to_screen
; draw 17x1 rectangle at (36,13)
    ldx #&24 ; '$'
    ldy #&0d
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x8 rectangle at (37,14)
    inx
    iny
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x4 rectangle at (0,18)
    ldx #0
    ldy #&12
    lda #5
    sta width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x255 rectangle at (0,22)
    ldy #&16
    lda #&ff
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (34,9) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&22 ; '"'
    ldy #9
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (31,9) of size (3x2)
    ldx #&1f
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (6,9) of size (3x2)
    ldx #6
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (3,9) of size (3x2)
    ldx #3
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (3,7) of size (3x2)
    ldy #7
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (5,20) of size (3x2)
    ldx #5
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_1_game_update_loop
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_1_update_handler
    lda #1
    sta currently_updating_logic_for_room_index
    lda #8
    ldx #&25 ; '%'
    ldy #&11
    jsr update_brazier_and_fire
    lda room_1_rope_burning_progress
    sta burning_rope_pixel_y
    lda save_game_level_c_room_1_burning_rope_progress
    sta burning_rope_progress
    ldx #&14
    ldy #3
    lda #&11
    jsr update_burnable_rope
    lda burning_rope_pixel_y
    sta room_1_rope_burning_progress
    lda burning_rope_progress
    sta save_game_level_c_room_1_burning_rope_progress
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_table_state
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq set_room_1_objects
    lda save_game_level_c_burning_table_progress
    beq set_room_1_objects
    lda #&ff
    sta save_game_level_c_burning_table_progress
.set_room_1_objects
    lda desired_room_index
    cmp #1
    bne update_table_local
    ldx #5
    ldy #&12
    lda #objectid_table
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_cache5
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
    ldx #5
    lda #6
    sta temp_sprite_x_offset
    ldy #&12
    lda #objectid_fire1
    jsr set_object_position_from_cell_xy
    tax
    lda #&ff
    sta object_direction,x
    lda #spriteid_cache6
    sta object_erase_type,x
    lda #&a0
    sta object_z_order,x
    ldx #7
    lda #2
    sta temp_sprite_x_offset
    ldy #&12
    lda #objectid_fire2
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_cache7
    sta object_erase_type,x
    lda #&a0
    sta object_z_order,x
.update_table_local
    jmp update_table

.return3_local
    jmp return3

.update_table_state
    ldy save_game_level_c_burning_table_progress
    bmi update_table
    bne update_table_burning_progress
    lda desired_room_index
    cmp #1
    bne update_table
    ldx #objectid_torch
    ldy #objectid_table
    jsr test_for_collision_between_objects_x_and_y
    beq update_table
.update_table_burning_progress
    ldy save_game_level_c_burning_table_progress
    iny
    sty save_game_level_c_burning_table_progress
    cpy #&30 ; '0'
    bcc update_table
    ldy #&ff
    sty save_game_level_c_burning_table_progress
.update_table
    lda desired_room_index
    cmp #1
    bne return3_local
    ldx #5
    ldy #&12
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda save_game_level_c_burning_table_progress
    beq table_is_unburnt
    bpl update_burning_table
    jmp set_table_fully_burnt

.table_is_unburnt
    lda #spriteid_table
    sta object_spriteid + objectid_table
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_fire1
    sta object_spriteid + objectid_fire2
    jmp write_solid_table_collision_map

.update_burning_table
    lda save_game_level_c_burning_table_progress
    and #7
    clc
    adc #spriteid_fire1
    sta object_spriteid + objectid_fire1
    lda save_game_level_c_burning_table_progress
    clc
    adc #4
    and #7
    adc #spriteid_fire1
    sta object_spriteid + objectid_fire2
    lda save_game_level_c_burning_table_progress
    cmp #&24 ; '$'
    bcs table_at_burn_level3
    cmp #&18
    bcs table_at_burn_level2
    cmp #&0c
    bcs table_at_burn_level1
    lda #spriteid_table
    sta object_spriteid + objectid_table
    lda #&8e
    sta object_y_low + objectid_fire1
    sta object_y_low + objectid_fire2
    lda save_game_level_c_burning_table_progress
    cmp #2
    bcs write_solid_table_collision_map
    lda #spriteid_cache2
    sta object_spriteid + objectid_fire1
    sta object_spriteid + objectid_fire2
    jmp write_solid_table_collision_map

.table_at_burn_level1
    lda #spriteid_table_burnt1
    sta object_spriteid + objectid_table
    lda #&92
    sta object_y_low + objectid_fire1
    sta object_y_low + objectid_fire2
    jmp write_solid_table_collision_map

.table_at_burn_level2
    lda #spriteid_table_burnt2
    sta object_spriteid + objectid_table
    lda #&97
    sta object_y_low + objectid_fire1
    sta object_y_low + objectid_fire2
    jmp table_height_reduced_due_to_burning

.table_at_burn_level3
    lda #spriteid_table_burnt3
    sta object_spriteid + objectid_table
    lda #&9d
    sta object_y_low + objectid_fire1
    sta object_y_low + objectid_fire2
    lda save_game_level_c_burning_table_progress
    cmp #&2f ; '/'
    bcc table_height_reduced_due_to_burning
    lda #spriteid_cache2
    sta object_spriteid + objectid_fire1
    sta object_spriteid + objectid_fire2
    jmp table_height_reduced_due_to_burning

.set_table_fully_burnt
    lda #spriteid_table_burnt3
    sta object_spriteid + objectid_table
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_fire1
    sta object_spriteid + objectid_fire2
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp return3

.table_height_reduced_due_to_burning
    dec height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    iny
.write_solid_table_collision_map
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return3
    rts

; check for first update in room (branch if not)
.update_torch
    lda update_room_first_update_flag
    beq check_for_collecting_torch_in_room_1
    lda #spriteid_torch_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_torch_object
    sta collectable_spriteids+1
    lda #spriteid_torch_object2
    sta collectable_being_used_spriteids + 1
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq update_room_1_torch
    lda save_game_level_c_got_torch
    beq update_room_1_torch
    lda #&ff
    sta save_game_level_c_got_torch
.update_room_1_torch
    lda #spriteid_cache1
    sta object_erase_type + objectid_torch
    lda save_game_level_c_got_torch
    bne check_for_player_using_torch
    lda desired_room_index
    cmp #1
    bne return4
    ldx #&23 ; '#'
    ldy #8
    lda #1
    sta temp_sprite_y_offset
    lda #objectid_torch
    jsr set_object_position_from_cell_xy
    tax
    lda #&c0
    sta object_z_order + objectid_torch
    lda #spriteid_torch_object
    sta object_spriteid + objectid_torch
.return4
    rts

.return5_local
    jmp return5

.check_for_collecting_torch_in_room_1
    lda save_game_level_c_got_torch
    bne check_for_player_using_torch
    lda desired_room_index
    cmp #1
    bne return5_local
; check for collision with torch collectable
    ldx #objectid_old_player
    ldy #objectid_torch
    jsr test_for_collision_between_objects_x_and_y
    beq return5_local
; add torch to toolbar
    lda #spriteid_torch_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #&ff
    sta save_game_level_c_got_torch
.check_for_player_using_torch
    ldy save_game_level_c_got_torch
    beq return5_local
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne store_animation_state_y
    lda player_using_object_spriteid
    cmp #spriteid_torch_menu_item
    beq player_is_using_torch
    ldy #&ff
    bne store_animation_state_y
.player_is_using_torch
    cpy #&ff
    bne get_fire_sprite
    ldy #&0a
    jmp store_animation_state_y

.get_fire_sprite
    iny
    lda fire_spriteid_table,y
    bne store_animation_state_y
    ldy #1
.store_animation_state_y
    sty save_game_level_c_got_torch
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_torch
    cpy #&ff
    beq return5
; set fire sprite for the torch object, setting the direction, position and z-order too
; based on the player's accessory object
    ldx #objectid_torch
    lda fire_spriteid_table,y
    sta object_spriteid,x
    lda #&40 ; '@'
    sta object_z_order,x
    lda object_direction + objectid_player_accessory
    sta object_direction,x
    bmi looking_left_so_adjust_x_position_of_accessory
    lda object_x_low + objectid_player_accessory
    clc
    adc #6
    sta object_x_low,x
    lda object_x_high + objectid_player_accessory
    adc #0
    sta object_x_high,x
    jmp move_accessory_down

.looking_left_so_adjust_x_position_of_accessory
    lda object_x_low + objectid_player_accessory
    sec
    sbc #6
    sta object_x_low,x
    lda object_x_high + objectid_player_accessory
    sbc #0
    sta object_x_high,x
.move_accessory_down
    lda object_y_low + objectid_player_accessory
    clc
    adc #&fd
    sta object_y_low,x
    lda object_y_high + objectid_player_accessory
    adc #&ff
    sta object_y_high,x
.return5
    rts

.fire_spriteid_table
    equb 0
    equb spriteid_fire1
    equb spriteid_fire2
    equb spriteid_fire3
    equb spriteid_fire4
    equb spriteid_fire5
    equb spriteid_fire6
    equb spriteid_fire7
    equb spriteid_fire8
    equb 0
    equb spriteid_cache2
    equb 0
; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 20                                                           ; initial player X cell
    equb 11                                                           ; initial player Y cell

; ########################################
; ########################################
; ####        ################   |    ####
; ###                            |     ###
; ###                            |     ###
;                                |     ###
;                                |     ###
;                                |     ###
;                                |     ###
;                                |     ###
;                     P          |     ###
; #####       ################   |     ###
; #####       ################   |     ###
; ###                            |
; ###                            |
; ###                            |
; ###                            |
; ###                            |
; ###                            |   #####
; ###                            |   #####
; ###         ################   |     ###
; ###         ################   |     ###
; ###         ################   |     ###
; ###         ################   |     ###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,11)
    ldx #0
    ldy #&0b
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (35,18)
    ldx #&23 ; '#'
    ldy #&12
    jsr copy_rectangle_of_memory_to_screen
; draw 3x255 rectangle at (0,13)
    ldx #0
    ldy #&0d
    lda #3
    sta width_in_cells
    lda #&ff
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x255 rectangle at (37,20)
    ldx #&25 ; '%'
    ldy #&14
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,11)
    ldx #&0c
    ldy #&0b
    lda #&10
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x255 rectangle at (12,20)
    ldy #&14
    lda #&ff
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x1 rectangle at (12,2)
    ldy #2
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (31,2) length 255
    ldx #&1f
    ldy #2
    lda #&ff
    jsr draw_rope
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_2_check_bottom_exit
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

.room_2_check_bottom_exit
    lda room_exit_direction
    and #exit_room_bottom
    beq room_2_check_right_exit
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

.room_2_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_2_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    ldx #&25 ; '%'
    ldy #7
    lda #objectid_fire1
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_room_0_or_2_parrot
    lda desired_room_index
    cmp #2
    bne update_room_0_or_2_parrot
; first update for room 2
    ldx #8
    ldy #2
    lda save_game_level_c_room_0_and_2_burning_rope_progress
    beq room_2_draw_full_length_rope
    lda #spriteid_empty_hook
    jsr draw_sprite_a_at_cell_xy
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
    jmp update_room_0_or_2_parrot

.room_2_draw_full_length_rope
    lda #&ff
    jsr draw_rope
.update_room_0_or_2_parrot
    lda #2
    sta parrot_speed
    lda #&20 ; ' '
    sta parrot_minimum_y
    lda #&80
    sta parrot_maximum_y
    lda room_0_and_2_parrot_y
    sta parrot_y
    lda room_0_and_2_parrot_delay_before_chirp
    sta parrot_delay_before_chirp
    lda room_0_and_2_parrot_animation_index
    sta parrot_animation_index
    lda room_0_and_2_parrot_animation_step
    sta parrot_animation_step
; X,Y: the X coordinate of the rope/parrot, A: the direction of the parrot
    ldx #&40 ; '@'
    ldy #0
    lda #1
    jsr update_parrot_and_burnable_rope
    lda parrot_y
    sta room_0_and_2_parrot_y
    lda parrot_delay_before_chirp
    sta room_0_and_2_parrot_delay_before_chirp
    lda parrot_animation_index
    sta room_0_and_2_parrot_animation_index
    lda parrot_animation_step
    sta room_0_and_2_parrot_animation_step
    rts

.parrot_spriteid_table
.parrot_state_0
    equb spriteid_parrot2
    equb spriteid_parrot1
    equb 0
.parrot_state_1
    equb spriteid_parrot2
    equb spriteid_parrot1
    equb 0
.parrot_state_2
    equb spriteid_parrot1
    equb 0
.parrot_state_squawk
    equb spriteid_parrot_squawk
    equb spriteid_parrot_squawk
    equb spriteid_parrot_squawk
    equb spriteid_parrot_squawk
    equb spriteid_parrot_squawk
    equb spriteid_parrot_squawk
    equb 0

.update_parrot_and_burnable_rope
    sta parrot_direction
    stx parrot_x_low
    sty parrot_x_high
    lda currently_updating_logic_for_room_index
    cmp #3
    beq update_parrot_with_rope
    lda save_game_level_c_room_0_and_2_burning_rope_progress
    bmi return6_local
; check for first update in room (branch if not)
.update_parrot_with_rope
    lda update_room_first_update_flag
    beq update_parrot_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq only_the_room_changed
; level changed, set the envelope.
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
; if the rope burning is in progress, set it done.
    lda save_game_level_c_room_0_and_2_burning_rope_progress
    beq rope_is_not_burned
    lda #&ff
    sta save_game_level_c_room_0_and_2_burning_rope_progress
    lda currently_updating_logic_for_room_index
    cmp #3
    bne return6_local
.rope_is_not_burned
    lda parrot_minimum_y
    sta parrot_y
    lda #parrot_state_2 - parrot_spriteid_table
    sta parrot_animation_index
    sta parrot_animation_step
    lda #&10
    sta parrot_delay_before_chirp
.only_the_room_changed
    lda desired_room_index
    cmp #1
    beq just_entered_room_one
    ldx #objectid_parrot
    lda #spriteid_cache5
    sta object_erase_type,x
    lda #&f0
    sta object_z_order,x
.just_entered_room_one
    jmp update_parrot_object

.return6_local
    jmp return6

; calculate the desired parrot y position as half the player y position
.update_parrot_not_first_update
    lda object_y_high
    sta temp_player_y_high
    lda object_y_low
    lsr temp_player_y_high
    ror a
    ldx desired_room_index
    cpx currently_updating_logic_for_room_index
    beq update_parrot_visible
    cpx #0
    bne update_parrot_not_visible_in_room_0
    ldx currently_updating_logic_for_room_index
    cpx #2
    beq update_parrot_not_visible_in_room_2
.update_parrot_not_visible_in_room_0
    lda parrot_minimum_y
    sta parrot_desired_y
    lda #0
    sta parrot_cell_distance_to_player_x
    jmp update_parrot_animation

.update_parrot_not_visible_in_room_2
    clc
    adc #&60 ; '`'
.update_parrot_visible
    sta parrot_desired_y
; get difference between player and parrot x position
    lda object_x_low
    sec
    sbc parrot_x_low
    sta player_to_parrot_distance_x_low
    lda object_x_high
    sbc parrot_x_high
    sta player_to_parrot_distance_x_high
    bpl got_distance_from_player_to_parrot
; invert $70,71
    lda player_to_parrot_distance_x_low
    eor #&ff
    clc
    adc #1
    sta player_to_parrot_distance_x_low
    lda player_to_parrot_distance_x_high
    eor #&ff
    adc #0
    sta player_to_parrot_distance_x_high
; divide distance by eight to get a cell distance
.got_distance_from_player_to_parrot
    lsr player_to_parrot_distance_x_high
    lda player_to_parrot_distance_x_low
    ror a
    lsr a
    lsr a
    sta parrot_cell_distance_to_player_x
.update_parrot_animation
    lda parrot_animation_step
; increment parrot animation step, loop back to start of animation if at end
    clc
    adc #1
    tay
    lda parrot_spriteid_table,y
    bne check_if_parrot_should_move_up_rope
    ldy parrot_animation_index
.check_if_parrot_should_move_up_rope
    lda parrot_y
    cmp parrot_minimum_y
    beq check_if_parrot_should_move_down_rope
    bcc check_if_parrot_should_move_down_rope
    lda currently_updating_logic_for_room_index
    cmp #3
    beq skip_in_room_3
    lda save_game_level_c_room_0_and_2_burning_rope_progress
    bne move_parrot_up_rope
.skip_in_room_3
    lda parrot_y
    cmp parrot_desired_y
    beq update_squawk
    bcc check_if_parrot_should_move_down_rope
    sbc parrot_desired_y
    cmp parrot_cell_distance_to_player_x
    beq update_squawk
    bcc update_squawk
.move_parrot_up_rope
    lda parrot_y
    sec
    sbc parrot_speed
    sta parrot_y
    lda #parrot_state_0 - parrot_spriteid_table
    cmp parrot_animation_index
    beq store_animation_step_y_local
    sta parrot_animation_index
    tay
.store_animation_step_y_local
    jmp store_animation_step_y

.check_if_parrot_should_move_down_rope
    lda parrot_y
    cmp parrot_maximum_y
    bcs update_squawk
    lda parrot_desired_y
    cmp parrot_y
    beq update_squawk
    bcc update_squawk
    sbc parrot_y
    cmp parrot_cell_distance_to_player_x
    beq update_squawk
    bcc update_squawk
; move parrot down rope
    lda parrot_y
    clc
    adc parrot_speed
    sta parrot_y
    lda #parrot_state_1 - parrot_spriteid_table
    cmp parrot_animation_index
    beq store_animation_step_y_local
    sta parrot_animation_index
    tay
    jmp store_animation_step_y

.update_squawk
    lda parrot_animation_index
    cmp #parrot_state_2 - parrot_spriteid_table
    beq parrot_in_state_2
    cmp #parrot_state_squawk - parrot_spriteid_table
    bne get_new_delay_before_chirp
    cpy #parrot_state_squawk - parrot_spriteid_table
    bne store_animation_step_y
.get_new_delay_before_chirp
    lda #&0f
    jsr get_random_number_up_to_a
    clc
    adc #&10
    sta parrot_delay_before_chirp
    ldy #parrot_state_2 - parrot_spriteid_table
    sty parrot_animation_index
.parrot_in_state_2
    dec parrot_delay_before_chirp
    bpl store_animation_step_y
    lda currently_updating_logic_for_room_index
    cmp #3
    bne room_0_or_2_rope
    cmp desired_room_index
    beq chirp_sound
    bne reset_parrot_animation                                        ; ALWAYS branch

.room_0_or_2_rope
    ldy room_0_and_2_parrot_y
    lda desired_room_index
    cmp #2
    beq room_2_parrot
    cmp #0
    bne reset_parrot_animation
; room 0 rope
    cpy #&66 ; 'f'
    bcs chirp_sound
    bcc reset_parrot_animation                                        ; ALWAYS branch

.room_2_parrot
    cpy #&68 ; 'h'
    bcs reset_parrot_animation
.chirp_sound
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
.reset_parrot_animation
    ldy #parrot_state_squawk - parrot_spriteid_table
    sty parrot_animation_index
.store_animation_step_y
    sty parrot_animation_step
.update_parrot_object
    lda parrot_y
    ldx desired_room_index
    cpx currently_updating_logic_for_room_index
    beq sign_extend_parrot_y
    cpx #0
    bne return6
    ldx currently_updating_logic_for_room_index
    cpx #2
    bne return6
; move from room 2 to room 0, move parrot up off screen
    sec
    sbc #&60 ; '`'
.sign_extend_parrot_y
    ldx #0
    ora #0
    bpl store_parrot_object_y_position
    dex
.store_parrot_object_y_position
    stx object_y_high + objectid_parrot
    asl a
    rol object_y_high + objectid_parrot
    sta object_y_low + objectid_parrot
    lda parrot_direction
    sta object_direction + objectid_parrot
    lda parrot_x_low
    sta object_x_low + objectid_parrot
    lda parrot_x_high
    sta object_x_high + objectid_parrot
    ldy parrot_animation_step
    lda parrot_spriteid_table,y
    sta object_spriteid + objectid_parrot
    lda update_room_first_update_flag
    bne return6
    ldx #objectid_player
    ldy #objectid_parrot
    jsr test_for_collision_between_objects_x_and_y
    beq return6
    lda #&80
    sta player_wall_collision_reaction_speed
.return6
    rts

.parrot_desired_y
    equb 0
.parrot_cell_distance_to_player_x
    equb 0
.parrot_direction
    equb 0
.parrot_x_low
    equb 0
.parrot_x_high
    equb 0
.parrot_minimum_y
    equb 0
.parrot_maximum_y
    equb 0
.parrot_y
    equb 0
.parrot_animation_index
    equb 0
.parrot_animation_step
    equb 0
.parrot_delay_before_chirp
    equb 0
.parrot_speed
    equb 0
; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 29                                                           ; initial player X cell
    equb 11                                                           ; initial player Y cell

; ########################################
; ########################################
; ####    |    |    |                 ####
; ###     |    |    |                  ###
; ###     |    |    |                  ###
; ###     |    |    |
; ###     |    |    |
; ###     |    |    |
; ###     |    |    |
; ###     |    |    |
; ###     |    |    |          P
; ###     |    |    |   ##################
; ###     |    |    |   ##################
; ###     |    |    |                 ####
; ###     |    |    |                  ###
; ###     |    |    |                  ###
; ###          |    |                  ###
; ###               |                  ###
; ###OOO                               ###
; ###OOO                OOO         OOO###
; ###OOOOOO             OOO         OOO###
; ###OOOOOO             ##################
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
; draw 4x1 rectangle at (0,2)
    iny
    iny
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x255 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #&ff
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (22,11)
    ldx #&16
    ldy #&0b
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (36,13)
    ldx #&24 ; '$'
    iny
    iny
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x7 rectangle at (37,14)
    inx
    iny
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (22,21)
    ldx #&16
    ldy #&15
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (3,22)
    ldx #3
    iny
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (34,19) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&22 ; '"'
    ldy #&13
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (22,19) of size (3x2)
    ldx #&16
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (6,20) of size (3x2)
    ldx #6
    iny
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (3,20) of size (3x2)
    ldx #3
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (3,18) of size (3x2)
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (8,2) length 14
    ldx #8
    ldy #2
    lda #&0e
    jsr draw_rope
; draw rope at (13,2) length 15
    ldx #&0d
    lda #&0f
    jsr draw_rope
; draw rope at (18,2) length 16
    ldx #&12
    lda #&10
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_right
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
    ldy #&15
    lda #objectid_spell
    jsr update_level_completion
    lda #1
    sta parrot_speed
    lda #&18
    sta parrot_minimum_y
    lda #&3c ; '<'
    sta parrot_maximum_y
    lda room_3_parrot_y
    sta parrot_y
    lda room_3_parrot_delay_before_chirp
    sta parrot_delay_before_chirp
    lda room_3_parrot_animation_index
    sta parrot_animation_index
    lda room_3_parrot_animation_step
    sta parrot_animation_step
; X,Y: the X coordinate of the rope/parrot, A: the direction of the parrot
    ldx #&6f ; 'o'
    ldy #0
    lda #&ff
    jsr update_parrot_and_burnable_rope
    lda parrot_y
    sta room_3_parrot_y
    lda parrot_delay_before_chirp
    sta room_3_parrot_delay_before_chirp
    lda parrot_animation_index
    sta room_3_parrot_animation_index
    lda parrot_animation_step
    sta room_3_parrot_animation_step
    rts

.envelope1
    equb 5                                                            ; envelope number
    equb 129                                                          ; step length (100ths of a second)
    equb 1                                                            ; pitch change per step in section 1
    equb 254                                                          ; pitch change per step in section 2
    equb 252                                                          ; pitch change per step in section 3
    equb 8                                                            ; number of steps in section 1
    equb 8                                                            ; number of steps in section 2
    equb 8                                                            ; number of steps in section 3
    equb 60                                                           ; change of amplitude per step during attack phase
    equb 255                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 252                                                          ; change of amplitude per step during release phase
    equb 90                                                           ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound1
    equw &0013                                                        ; channel
    equw 5                                                            ; amplitude
    equw 230                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %01000000
    equb %11000000
    equb %00100000
    equb %00010000
    equb %00001011
    equb %00000100
    equb %00001000
    equb %00001000
.ground_fill_2x2_top_right
    equb %00000010
    equb %00000011
    equb %00000100
    equb %00001000
    equb %11010000
    equb %00100000
    equb %00010000
    equb %00010000
.ground_fill_2x2_bottom_left
    equb %00001000
    equb %00001000
    equb %00000100
    equb %00001011
    equb %00010000
    equb %00100000
    equb %11000000
    equb %01000000
.ground_fill_2x2_bottom_right
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11010000
    equb %00001000
    equb %00000100
    equb %00000011
    equb %00000010
IF swr_renderer_enabled
INCLUDE "build/runtime/levelC_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelC.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelC"
ENDIF
ENDIF
.pydis_end

save "build/dataC", pydis_start, pydis_end
