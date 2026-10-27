; *************************************************************************************
;
; Level D: 'GNU-PROBLEM'
;
; Save game variables:
;
;     save_game_level_d_got_axe ($0a03):
;               0: not got
;             $ff: got
;     save_game_level_d_got_gun ($0a0f):
;               0: not got
;             $ff: got
;     save_game_level_d_gnu_sign_position ($0a10):
;             $20-$30: X position of 'GNU CLIMBING' sign
;     save_game_level_d_partition_progress ($0a11):
;               0: normal position
;               1: falling
;             $ff: fallen
;     save_game_level_d_baby_progress ($0a12):
;               0: not started
;             $12: sleeping
;             $14: blocking exit
;             $21: surprised
;             $2c: dead
;
; Solution:
;
;   1. Get gun in the far right room
;   2. Shoot the baby to escape the room
;   3. In the far left room, shoot the gnu climbing sign until it is no longer visible
;   4. Get the axe
;   5. Move two rooms to the right, climb up the rope and move into the room to the left.
;   6. Shoot the sign until it's back offscreen to the left.
;   7. Climb up the rope, over the gnu head, then back to exit the room at the top right.
;   8. Chop down the wooden partition wall with the axe, and collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_axe                          = 3
objectid_baby                         = 5
objectid_gun                          = 3
objectid_partition                    = 4
objectid_sign                         = 5
objectid_sign_stand                   = 4
objectid_spell                        = 3
spriteid_axe                          = 201
spriteid_axe_menu_item                = 202
spriteid_baby_dead                    = 218
spriteid_baby_sit                     = 220
spriteid_baby_smile                   = 216
spriteid_baby_surprise                = 217
spriteid_baby_walk                    = 219
spriteid_broken_partition_base        = 212
spriteid_cache1                       = 208
spriteid_cache2                       = 209
spriteid_fallen_partition             = 215
spriteid_falling_partition            = 214
spriteid_gnu_head                     = 203
spriteid_gun                          = 205
spriteid_gun_held                     = 206
spriteid_gun_menu_item                = 207
spriteid_partition                    = 213
spriteid_rock                         = 204
spriteid_sign                         = 211
spriteid_sign_stand                   = 210
spriteid_wood_block                   = 200

; Memory locations
l0070                                               = &0070
room_exit_direction                                 = &0070
save_game_level_d_got_axe                           = &0a0e
save_game_level_d_got_gun                           = &0a0f
save_game_level_d_gnu_sign_position                 = &0a10
save_game_level_d_partition_progress                = &0a11
save_game_level_d_baby_progress                     = &0a12
baby_animation_step_index                           = &0a6f
baby_x_position                                     = &0a70
baby_y_position                                     = &0a71

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelD_sprite_table - level_data
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
    encode "GNU-PROBLEM", &0D

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
    sta save_game_level_d_got_gun
    lda #&ff
    sta save_game_level_d_got_axe
.developer_mode_inactive
    lda save_game_level_d_got_gun
    beq no_gun
    lda #spriteid_gun_menu_item
    jsr find_or_create_menu_slot_for_A
.no_gun
    lda save_game_level_d_got_axe
    beq return1
    lda #spriteid_axe_menu_item
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
    jsr room_2_update_handler
    jsr room_3_update_handler
    jsr update_gnu_sign_puzzle
    jsr update_baby_puzzle
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
; ####                |    |          ####
; ###                 |    |           ###
; ###                 |    |           ###
; ###                 |    |           ###
; ###                 |    |           ###
; ###                 |    |   ###########
; ###                 |    |   ###########
; ###                 |
; ###                 |
; ###                 |
; ###                 |
; ###                 |
; #######             |        ###########
; #######             |        ###########
; #######OOO          |
; #######OOO          |
; #######OOOOOO       |
; #######OOOOOO       |
; #######OOOOOOOOO
; #######OOOOOOOOO    P        ###########
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
; draw 3x11 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #&0b
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (29,7)
    ldx #&1d
    ldy #7
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x8 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #7
    sta width_in_cells
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x8 rectangle at (0,22)
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (29,21)
    ldx #&1d
    ldy #&15
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (29,14)
    ldx #&1d
    ldy #&0e
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw wood block at (13,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_wood_block
    ldx #&0d
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (10,20) of size (3x2)
    ldx #&0a
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (7,20) of size (3x2)
    ldx #7
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (7,18) of size (3x2)
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (10,18) of size (3x2)
    ldx #&0a
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (7,16) of size (3x2)
    ldx #7
    ldy #&10
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (20,2) length 18
    ldx #&14
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (25,2) length 7
    ldx #&19
    lda #7
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
    lda #2
    ldx #3
    ldy #8
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_0_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_change_only
; new level
    lda #spriteid_axe_menu_item
    sta toolbar_collectable_spriteids+2
    lda #spriteid_axe
    sta collectable_spriteids+2
    sta collectable_being_used_spriteids+2
; no_level_change, just a room change only
.room_change_only
    lda desired_room_index
    cmp #0
    bne return2
; in room 0
    lda save_game_level_d_got_axe
    bne return2
; not got axe yet, position the axe
    ldx #&23 ; '#'
    lda #5
    sta temp_sprite_x_offset
    ldy #5
    lda #1
    sta temp_sprite_y_offset
    lda #objectid_axe
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_axe
    sta object_spriteid,x
    lda #spriteid_cache1
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
.return2
    rts

.room_0_not_first_update
    lda desired_room_index
    cmp #0
    bne return3
    lda save_game_level_d_got_axe
    bne return3
; not got axe. check for collision with axe
    ldx #objectid_old_player
    ldy #objectid_axe
    jsr test_for_collision_between_objects_x_and_y
    beq return3
; player has collided with axe. mark axe as collected.
    lda #&ff
    sta save_game_level_d_got_axe
; add axe to toolbar
    lda #spriteid_axe_menu_item
    jsr find_or_create_menu_slot_for_A
; mark axe object as invisible
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_axe
.return3
    rts

; check for first update in room (branch if not)
.update_gnu_sign_puzzle
    lda update_room_first_update_flag
    beq update_gnu_sign_puzzle_not_first_update
; initialise sign position
    lda save_game_level_d_gnu_sign_position
    bne draw_rock_and_block_passage
; initial position of the sign
    lda #&21 ; '!'
    sta save_game_level_d_gnu_sign_position
.draw_rock_and_block_passage
    ldy #&0e
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda desired_room_index
    cmp #1
    beq draw_rock_in_room_1
    bcs deal_with_sign_position_consequences_local
; draw rock in room 0
    ldx #&1e
    lda #spriteid_rock
    jsr draw_sprite_a_at_cell_xy
    dex
    jmp set_up_sign_object

.draw_rock_in_room_1
    ldx #9
    lda #4
    sta temp_sprite_x_offset
    lda #spriteid_rock
    jsr draw_sprite_a_at_cell_xy
    inx
.set_up_sign_object
    ldy #9
    jsr write_a_single_value_to_cell_in_collision_map
    ldx #4
    lda #spriteid_sign_stand
    sta object_spriteid,x
    lda #spriteid_cache2
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
    lda #spriteid_sign
    sta object_spriteid + objectid_sign
.deal_with_sign_position_consequences_local
    jmp deal_with_sign_position_consequences

.update_gnu_sign_puzzle_not_first_update
    lda desired_room_index
    cmp #3
    beq deal_with_sign_position_consequences
; check if player is currently using the gun, and branch if not
    lda #spriteid_gun_menu_item
    cmp player_using_object_spriteid
    bne deal_with_sign_position_consequences
; check if player just used the gun this game tick
    cmp previous_player_using_object_spriteid
    beq deal_with_sign_position_consequences
; check the Y coordinate of theplayer to see if it at the same height as the sign
    lda object_y_low
    cmp #&6e ; 'n'
    bne deal_with_sign_position_consequences
; if not in room 0 then branch
    lda desired_room_index
    bne check_for_gun_in_rooms_other_than_0
; in room 0, make sure we are pointing right (branch if not)
    lda object_direction
    bmi deal_with_sign_position_consequences
; move the sign to the right if not already fully to the right (position $30 is fully
; right)
    lda save_game_level_d_gnu_sign_position
    cmp #&30 ; '0'
    beq deal_with_sign_position_consequences
    inc save_game_level_d_gnu_sign_position
    jmp deal_with_sign_position_consequences

; rooms other than room 0 need the player to look left for the gun to work (branch
; otherwise)
.check_for_gun_in_rooms_other_than_0
    lda object_direction
    bpl deal_with_sign_position_consequences
; move sign left not already all the way left (position $20 is fully left)
    lda save_game_level_d_gnu_sign_position
    cmp #&20 ; ' '
    beq deal_with_sign_position_consequences
    dec save_game_level_d_gnu_sign_position
.deal_with_sign_position_consequences
    lda #1
    sta width_in_cells
    lda save_game_level_d_gnu_sign_position
    ldx desired_room_index
    cpx #1
    beq check_if_gnu_sign_is_in_room_1
    bcs return4
; player in room 0. if (sign is in position >= $29) then add collision map for ropes
    ldx #collision_map_rope
    cmp #&29 ; ')'
    bcs add_ropes_to_collision_map_room_0
    ldx #collision_map_none
.add_ropes_to_collision_map_room_0
    stx value_to_write_to_collision_map
    ldx #&14
    ldy #3
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq already_written_to_collision_map_room_0
    lda #&11
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #&19
    lda #6
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.already_written_to_collision_map_room_0
    lda save_game_level_d_gnu_sign_position
    jmp set_sign_object_position

.check_if_gnu_sign_is_in_room_1
    ldx #collision_map_rope
    cmp #&28 ; '('
    bcc add_ropes_to_collision_map_room_1
    ldx #collision_map_none
.add_ropes_to_collision_map_room_1
    stx value_to_write_to_collision_map
    ldx #&0e
    ldy #3
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq already_written_to_collision_map_room_1
    lda #6
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #&19
    lda #&0d
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.already_written_to_collision_map_room_1
    lda save_game_level_d_gnu_sign_position
    sec
    sbc #&28 ; '('
.set_sign_object_position
    tax
    ldy #&0e
    lda #objectid_sign_stand
    jsr set_object_position_from_cell_xy
    lda #objectid_sign
    jsr set_object_position_from_cell_xy
.return4
    rts

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
; ####          |          |
; ###           |          |
; ###           |          |
; ###           |          |
; ###           |          |
; ###########   |   OOOO   |   ###########
; ###########   |          |   ###########
;                          |
;                          |
;                          |
;                          |
;                          |
; ###########              |   ###########
; ###########              |   ###########
; 
; 
; 
; 
; 
; ###########         P        ###########
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
    iny
    iny
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (0,3)
    iny
    dec width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (0,7)
    ldy #7
    lda #&0b
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (29,7)
    ldx #&1d
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #&0b
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (29,14)
    ldx #&1d
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x1 rectangle at (0,21)
    dey
    lda #&0b
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x1 rectangle at (29,21)
    ldx #&1d
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw gnu head at (18,7) of size (4x1)
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    ldx #&12
    ldy #7
    lda #spriteid_gnu_head
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    inx
    iny
    lda #2
    sta width_in_cells
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
; draw rope at (14,2) length 7
    ldx #&0e
    ldy #2
    lda #7
    jsr draw_rope
; draw rope at (25,2) length 14
    ldx #&19
    lda #&0e
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

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 30                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
;                                     ####
;                                      ###
;                                      ###
;                                      ###
;                                      ###
; ########################################
; ########################################
;               |                     ####
;               |                      ###
;               |                      ###
;               |                      ###
;               |                      ###
; ###########   |                      ###
; ###########   |                      ###
;               |                      ###
;               |
;               |
;               |
;                   OOOOOO
; ###########       OOOOOO      P
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
; draw 255x1 rectangle at (36,2)
    ldx #&24 ; '$'
    ldy #2
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x4 rectangle at (37,3)
    inx
    iny
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,7)
    ldx #0
    ldy #7
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (36,9)
    ldx #&24 ; '$'
    ldy #9
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x7 rectangle at (37,10)
    inx
    iny
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #&0b
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x1 rectangle at (0,21)
    dey
    lda #&0b
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw wood block at (21,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&15
    ldy #&14
    lda #spriteid_wood_block
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw wood block at (18,20) of size (3x2)
    ldx #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (14,9) length 11
    ldx #&0e
    ldy #9
    lda #&0b
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
    ldx #&25 ; '%'
    ldy #&0d
    lda #2
    jsr update_brazier_and_fire
    ldx #&1f
    ldy #7
    lda #objectid_spell
    jsr update_level_completion
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_partition_puzzle
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq level_changed
; if partition is partly fallen over, make it fully fallen
    lda save_game_level_d_partition_progress
    beq level_changed
    lda #&ff
    sta save_game_level_d_partition_progress
.level_changed
    lda desired_room_index
    cmp #2
    bne update_partition_sprite_local
    ldx #&14
    ldy #7
    lda #spriteid_broken_partition_base
    jsr draw_sprite_a_at_cell_xy
    lda #objectid_partition
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_cache1
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
    ldx #&14
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda save_game_level_d_partition_progress
    bne set_partition_to_solid_collision_map
    ldy #2
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp update_partition_sprite_local

.set_partition_to_solid_collision_map
    ldy #6
    lda #6
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.update_partition_sprite_local
    jmp update_partition_sprite

.update_partition_puzzle
    lda save_game_level_d_partition_progress
    bmi update_partition_sprite
    bne update_partition_progress
    lda desired_room_index
    cmp #2
    bne update_partition_sprite
    lda player_using_object_spriteid
    cmp #spriteid_axe_menu_item
    bne update_partition_sprite
    lda #1
    sta temp_right_offset
    ldx #objectid_player_accessory
    ldy #4
    jsr test_for_collision_between_objects_x_and_y
    beq update_partition_sprite
    ldx #&14
    ldy #2
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldy #6
    lda #6
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jsr play_baby_dying_or_partition_landing_sounds
.update_partition_progress
    ldy save_game_level_d_partition_progress
    iny
    cpy #2
    bcc partition_is_falling
    lda desired_room_index
    cmp #2
    bne redundant_branch
.redundant_branch
    ldy #&ff
.partition_is_falling
    sty save_game_level_d_partition_progress
.update_partition_sprite
    lda desired_room_index
    cmp #2
    bne return5
    ldy save_game_level_d_partition_progress
    bpl set_partition_sprite
    ldy #2
.set_partition_sprite
    lda partition_spriteid_table,y
    sta object_spriteid + objectid_partition
.return5
    rts

.partition_spriteid_table
    equb spriteid_partition
    equb spriteid_falling_partition
    equb spriteid_fallen_partition

.play_baby_dying_or_partition_landing_sounds
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    rts

.play_gunshot_sound
    lda #0
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    rts

; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 14                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ####               |             |  ####
; ###                |             |   ###
; ###                |             |   ###
; ###                |             |   ###
; ###                |             |   ###
; ################   |   #######   |   ###
; ################   |   #######   |   ###
; ####               |     ###     |   ###
; ###                |     ###     |   ###
; ###                |     ###     |   ###
; ###                |     ###     |   ###
; ###                |     ###     |   ###
; ###                |     ###     |   ###
; ######             |     ###     |   ###
; ######             |     ###     |   ###
;                    |     ###     |   ###
;                    |     ###     |   ###
;                    |     ###     |   ###
;                          ###OOO      ###
;               P          ###OOO      ###
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
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (0,7)
    ldx #0
    ldy #7
    lda #&10
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x2 rectangle at (23,7)
    ldx #&17
    lda #7
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,9)
    ldx #0
    ldy #9
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x13 rectangle at (25,9)
    ldx #&19
    lda #3
    sta width_in_cells
    lda #&0d
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (0,10)
    ldx #0
    iny
    lda #3
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x2 rectangle at (0,15)
    ldy #&0f
    lda #6
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw wood block at (28,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&1c
    ldy #&14
    lda #spriteid_wood_block
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (19,2) length 18
    ldx #&13
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (33,2) length 18
    ldx #&21 ; '!'
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
    ldx #&19
    ldy #&0d
    lda #2
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_gun
    lda #spriteid_gun_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_gun_held
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_gun_in_room_3
    lda save_game_level_d_got_gun
    beq initialise_gun_in_room_3
    lda #&ff
    sta save_game_level_d_got_gun
.initialise_gun_in_room_3
    lda save_game_level_d_got_gun
    bne return6
    lda desired_room_index
    cmp #3
    bne return6
    ldx #&1d
    lda #4
    sta temp_sprite_x_offset
    ldy #&14
    lda #&fd
    sta temp_sprite_y_offset
    lda #objectid_gun
    jsr set_object_position_from_cell_xy
    tax
    lda #spriteid_gun
    sta object_spriteid,x
    lda #spriteid_cache1
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
.return6
    rts

.update_gun
    lda save_game_level_d_got_gun
    bne update_gunshot
    lda desired_room_index
    cmp #3
    bne return7
    ldx #objectid_old_player
    ldy #objectid_gun
    jsr test_for_collision_between_objects_x_and_y
    beq return7
    lda #spriteid_gun_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_gun
    lda #&ff
    sta save_game_level_d_got_gun
    jmp return7

.update_gunshot
    lda #spriteid_gun_menu_item
    cmp player_using_object_spriteid
    bne return7
    cmp previous_player_using_object_spriteid
    beq return7
    jsr play_gunshot_sound
.return7
    rts

.baby_x_offsets
    equb 4
    equb 0
    equb 0
    equb 0
    equb 0
    equb 0
    equb 6
    equb 5
    equb 5
    equb 4
    equb 0
    equb 0
    equb 0
    equb 0
    equb 0
    equb 0
    equb 0
.baby_y_offsets
    equb 0
    equb 0
    equb 0
    equb 0
    equb 0
    equb 0
    equb &fa
    equb &fe
    equb 2
    equb 6
    equb 8
    equb 8
    equb 8
    equb 8
    equb 8
    equb 8
    equb 8
.baby_base_spriteids
.baby_walk_to_block_exit_animation
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb 0
.baby_sit_animation
    equb spriteid_baby_sit
    equb 0
.baby_smile_animation
    equb spriteid_baby_smile
    equb 0
.baby_walk_animation
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb spriteid_baby_walk
    equb 0
.baby_surprise_animation
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb spriteid_baby_surprise
    equb 0
.baby_dead_animation
    equb spriteid_baby_dead
    equb 0

; check for first update in room (branch if not)
.update_baby_puzzle
    lda update_room_first_update_flag
    beq update_baby_animation_step
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq update_baby_object_if_in_room_3
    lda #baby_sit_animation - baby_base_spriteids
    sta l0070
    ldx #&20 ; ' '
    ldy #&76 ; 'v'
    lda save_game_level_d_baby_progress
    beq set_baby_position_and_animation
    cmp #baby_sit_animation - baby_base_spriteids
    beq set_baby_position_and_animation
    lda #baby_dead_animation - baby_base_spriteids
    sta l0070
    ldx #&38 ; '8'
    ldy #&ae
    lda save_game_level_d_baby_progress
    cmp #baby_dead_animation - baby_base_spriteids
    beq set_baby_position_and_animation
    cmp #baby_surprise_animation - baby_base_spriteids
    beq set_baby_position_and_animation
    lda #baby_smile_animation - baby_base_spriteids
    sta l0070
.set_baby_position_and_animation
    lda l0070
    sta save_game_level_d_baby_progress
    sta baby_animation_step_index
    stx baby_x_position
    sty baby_y_position
.update_baby_object_if_in_room_3
    lda desired_room_index
    cmp #3
    bne copy_new_baby_state_back_to_object_local
    ldx #objectid_baby
    lda #0
    sta object_x_high,x
    sta object_y_high,x
    lda #spriteid_cache2
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
.copy_new_baby_state_back_to_object_local
    jmp copy_new_baby_state_back_to_object

.set_baby_animation_step_local
    jmp set_baby_animation_step

.update_baby_animation_step
    lda baby_animation_step_index
    clc
    adc #1
    tay
    lda baby_base_spriteids,y
    bne baby_animation_in_progress
    ldy save_game_level_d_baby_progress
.baby_animation_in_progress
    lda save_game_level_d_baby_progress
    cmp #baby_sit_animation - baby_base_spriteids
    bne baby_is_not_sitting
    lda desired_room_index
    cmp #3
    bne set_baby_animation_step_local
    lda object_x_high
    bne set_baby_animation_step_local
    lda object_x_low
    cmp #&80
    bcc set_baby_animation_step_local
    ldy #baby_walk_to_block_exit_animation - baby_base_spriteids
    sty save_game_level_d_baby_progress
    jmp set_baby_animation_step

.baby_is_not_sitting
    cmp #baby_walk_to_block_exit_animation - baby_base_spriteids
    bne baby_is_not_walking_to_block_exit
; check if we have reached the end of the 'walk to block exit' animation (branch if so)
    cpy #baby_walk_to_block_exit_animation+16 - baby_base_spriteids
    beq reached_end_of_walk_to_block_exit_animation
    cpy #baby_walk_to_block_exit_animation - baby_base_spriteids
    beq start_of_walk_to_block_exit_animation
    jmp set_baby_animation_step

.reached_end_of_walk_to_block_exit_animation
    lda desired_room_index
    cmp #3
    bne set_baby_animation_step_local
    jsr play_landing_sound
    ldy #baby_walk_to_block_exit_animation+16 - baby_base_spriteids
    jmp set_baby_animation_step

.start_of_walk_to_block_exit_animation
    lda #baby_smile_animation - baby_base_spriteids
    sta save_game_level_d_baby_progress
    tay
.baby_is_not_walking_to_block_exit
    cmp #baby_smile_animation - baby_base_spriteids
    bne baby_is_not_smiling
    lda desired_room_index
    cmp #3
    bne set_baby_animation_step_local
    lda #spriteid_gun_menu_item
    cmp player_using_object_spriteid
    bne check_for_player_baby_collision
    cmp previous_player_using_object_spriteid
    beq check_for_player_baby_collision
    lda object_direction
    bpl check_for_player_baby_collision
    lda object_y_low
    cmp #&a8
    bcc check_for_player_baby_collision
    lda object_x_high
    bne check_for_player_baby_collision
    lda object_x_low
    cmp #&d0
    bcs check_for_player_baby_collision
    ldy #baby_surprise_animation - baby_base_spriteids
    sty save_game_level_d_baby_progress
    jmp set_baby_animation_step

.check_for_player_baby_collision
    ldx #objectid_player
    sty temp_animation_index
    ldy #objectid_baby
    jsr test_for_collision_between_objects_x_and_y
    ldy temp_animation_index
    ora #0
    bne got_player_baby_collision
    ldx #objectid_player_accessory
    sty temp_animation_index
    ldy #objectid_baby
    jsr test_for_collision_between_objects_x_and_y
    ldy temp_animation_index
    ora #0
    beq set_baby_animation_step
.got_player_baby_collision
    lda #6
    sta player_wall_collision_reaction_speed
    ldy #baby_walk_animation - baby_base_spriteids
    jmp set_baby_animation_step

.baby_is_not_smiling
    cmp #baby_surprise_animation - baby_base_spriteids
    bne set_baby_animation_step
    cpy #baby_surprise_animation - baby_base_spriteids
    bne set_baby_animation_step
; beginning the surprise animation, clear collision map for baby
    lda desired_room_index
    cmp #3
    bne set_dead_baby_animation
    jsr play_baby_dying_or_partition_landing_sounds
    lda #collision_map_none
    sta value_to_write_to_collision_map
    ldx #6
    ldy #&13
    lda #2
    sta width_in_cells
    lda #3
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.set_dead_baby_animation
    ldy #baby_dead_animation - baby_base_spriteids
    sty save_game_level_d_baby_progress
.set_baby_animation_step
    sty baby_animation_step_index
    lda save_game_level_d_baby_progress
    cmp #0
    bne copy_new_baby_state_back_to_object
    lda baby_x_offsets,y
    clc
    adc baby_x_position
    sta baby_x_position
    lda baby_y_offsets,y
    clc
    adc baby_y_position
    sta baby_y_position
.copy_new_baby_state_back_to_object
    lda desired_room_index
    cmp #3
    bne return8
    ldy baby_animation_step_index
    lda baby_base_spriteids,y
    sta object_spriteid + objectid_baby
    lda baby_x_position
    sta object_x_low + objectid_baby
    lda baby_y_position
    sta object_y_low + objectid_baby
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda save_game_level_d_baby_progress
    cmp #baby_smile_animation - baby_base_spriteids
    beq add_baby_to_collision_map
    cmp #baby_surprise_animation - baby_base_spriteids
    beq add_baby_to_collision_map
    cmp #baby_walk_to_block_exit_animation - baby_base_spriteids
    beq add_baby_to_collision_map
    cmp #baby_dead_animation - baby_base_spriteids
    bne return8
; write sold rock values into the collision map for the dead baby
    lda #3
    sta width_in_cells
    lda #1
    sta height_in_cells
    ldx #4
    ldy #&15
    jsr read_collision_map_value_for_xy
    bne return8
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp return8

.add_baby_to_collision_map
    lda #2
    sta width_in_cells
    lda #3
    sta height_in_cells
    ldx #6
    ldy #&13
    jsr read_collision_map_value_for_xy
    bne return8
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return8
    rts

.temp_animation_index
    equb 0
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
.sound4
    equw &0010                                                        ; channel
    equw 5                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound3
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 200                                                          ; pitch
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
.sound2
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound1
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 210                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %00001000
    equb %00010100
    equb %00100010
    equb %01000001
    equb %10000000
    equb %01000000
    equb %00100000
    equb %00010000
.ground_fill_2x2_top_right
    equb %00010000
    equb %00100000
    equb %11000000
    equb %00100000
    equb %00010001
    equb %00001010
    equb %00000100
    equb %00000100
.ground_fill_2x2_bottom_left
    equb %00100000
    equb %00100000
    equb %01010000
    equb %10001000
    equb %00000100
    equb %00000011
    equb %00000100
    equb %00001000
.ground_fill_2x2_bottom_right
    equb %00001000
    equb %00000100
    equb %00000010
    equb %00000001
    equb %10000010
    equb %01000100
    equb %00101000
    equb %00010000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelD_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelD.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelD"
ENDIF
ENDIF
.pydis_end

save "build/dataD", pydis_start, pydis_end
