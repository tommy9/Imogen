; *************************************************************************************
;
; Level A: SAXOPHOBIA
;
; Save game variables:
;
;     save_game_level_a_room1_trapdoor_open_flag                     ($09ff):
;               0: closed
;               1: partway open
;             $ff: taken
;
;     save_game_level_a_saxophone_collected_flag                     ($0a00):
;               0: untouched
;             $ff: taken
;
;     save_game_level_a_table_x_position                             ($0a01):
;             $0a: leftmost position
;             $16: rightmost position
;             (cell based X position)
;
;     save_game_level_a_table_x_speed                                ($0a02):
;               0: not moving
;               1: moving right
;             $ff: moving left
;
;     save_game_level_a_room_2_baby_pixel_x_coordinate               ($0a03):
;
;     save_game_level_a_room_2_baby_direction                        ($0a04):
;               0: not moving
;               1: moving right
;             $ff: moving left
;
; Solution:
;
;   1. Climb between the mice and time the climb to get above the ball.
;   2. Exit to the right by bouncing off the right mouse's head.
;   3. Walk to the right over the trapdoor.
;   4. Drop down and as the cat bump into the table to slide it to the left.
;   5. Jump onto the table and out of the room, to the left.
;   6. Collect the saxophone, and make your way back to the trapdoor.
;   7. Hold the saxophone to drop through the trapdoor.
;   8. As the cat, jump onto the baby's ledge and as the wizard quickly use the saxophone
;      to stun/kill? the baby.
;   9. Collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
baby_max_pixel_x                      = 212
baby_min_pixel_x                      = 108
max_mouse_ball_animation_position     = 29
mouse_ball_left_x_base                = 136
mouse_ball_right_x_base               = 192
mouse_ball_top_y_base                 = 83
objectid_baby                         = 2
objectid_brazier                      = 5
objectid_brazier2                     = 3
objectid_left_mouse                   = 2
objectid_left_trapdoor                = 2
objectid_mouse_ball                   = 4
objectid_right_mouse                  = 3
objectid_right_trapdoor               = 3
objectid_saxophone                    = 4
objectid_spell                        = 5
objectid_table                        = 2
player_collision_flag_baby            = 6
player_collision_flag_mouse_ball      = 128
spriteid_baby_dead                    = 220
spriteid_baby_shrug                   = 219
spriteid_baby_smile                   = 221
spriteid_baby_stunned                 = 218
spriteid_baby_walk_cycle_0            = 214
spriteid_baby_walk_cycle_1            = 215
spriteid_baby_walk_cycle_2            = 216
spriteid_baby_walk_cycle_3            = 217
spriteid_erase1                       = 204
spriteid_erase2                       = 205
spriteid_erase3                       = 206
spriteid_mouse                        = 200
spriteid_mouse_hands1                 = 201
spriteid_mouse_hands2                 = 202
spriteid_mouse_hands3                 = 212
spriteid_mouse_hands4                 = 213
spriteid_saxophone                    = 210
spriteid_saxophone_menu_item          = 211
spriteid_small_ball                   = 203
spriteid_table                        = 222
spriteid_trapdoor_diagonal            = 208
spriteid_trapdoor_horizontal          = 207
spriteid_trapdoor_vertical            = 209
table_max_x                           = 22
table_min_x                           = 10
trapdoor_left_x                       = 136
trapdoor_right_x                      = 184

; Memory locations
old_table_x_position                                = &0070
room_exit_direction                                 = &0070
save_game_level_a_room1_trapdoor_open_flag          = &09ff
save_game_level_a_saxophone_collected_flag          = &0a00
save_game_level_a_table_x_position                  = &0a01
save_game_level_a_table_x_speed                     = &0a02
save_game_level_a_room_2_baby_pixel_x_coordinate    = &0a03
save_game_level_a_room_2_baby_direction             = &0a04
mouse_ball_animation_position                       = &0a6f
baby_pixel_x_coordinate                             = &0a70
baby_pixel_x_speed                                  = &0a71
baby_animation                                      = &0a72
baby_animation_step                                 = &0a73

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
IF swr_renderer_enabled
    EQUW levelA_sprite_table - level_data
ELSE
    equw sprite_data - level_data                                     ; offset to sprite data
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
    encode "SAXOPHOBIA", &0D

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
; if level is unchanged, skip forwards
    cmp level_before_latest_level_and_room_initialisation
    beq set_ground_fill_2x2_as_source_sprite
; if not in developer mode, skip forwards
    lda developer_flags
    bpl developer_mode_not_active
; add the saxophone menu item to the toolbar (due to being in developer mode)
    lda #spriteid_saxophone_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #&ff                                                          ; redundant instruction
; check the saxophone collected flag. The user can choose during the course of a game
; to enter the password to continue playing this level having previously got the
; saxophone. Or indeed may have just loaded a previously saved game.
.developer_mode_not_active
    lda save_game_level_a_saxophone_collected_flag
    beq set_ground_fill_2x2_as_source_sprite
; add the saxophone menu item to the toolbar (due to having collected it on a previous
; visit to the level)
    lda #spriteid_saxophone_menu_item
    jsr find_or_create_menu_slot_for_A
.set_ground_fill_2x2_as_source_sprite
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
    jsr room0_update_handler
    jsr room1_update_handler
    jsr room2_update_handler
    jsr room1_saxophone_and_brazier_handler
    jsr room3_update_handler
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
; ####      |         |         |
; ###       |         |         |
; ###       |         |         |
; ###       |         |         |
; ###       |         |         |
; ###       |         |         |   ######
; ###       |         |         |   ######
; ###       |         |         |      ###
; ###       |         |         |      ###
; ###       |   ###   |   ###   |      ###
; ###           ###   |   ###          ###
; ###            |    |    |           ###
; ###            |    |    |           ###
; ###            |    |    |           ###
; ###            |    |    |           ###
; ###            |    |    |           ###
; ###OOOOOO                            ###
; ###OOOOOO                            ###
; ###OOOOOOOOO                         ###
; ###OOOOOOOOO        P                ###
; ########################################
; ########################################
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
; draw 3x19 rectangle at (0,3)
    iny
    dec width_in_cells
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x19 rectangle at (0,22)
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x2 rectangle at (34,7)
    ldx #&22 ; '"'
    ldy #7
    lda #6
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x13 rectangle at (37,9)
    ldx #&25 ; '%'
    ldy #9
    lda #&0d
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (14,11)
    ldx #&0e
    ldy #&0b
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (24,11)
    ldx #&18
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (3,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_table
    ldx #3
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (6,20) of size (3x2)
    ldx #6
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (9,20) of size (3x2)
    ldx #9
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (3,18) of size (3x2)
    ldx #3
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (6,18) of size (3x2)
    ldx #6
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (10,2) length 10
    ldx #&0a
    ldy #2
    lda #&0a
    jsr draw_rope
; draw rope at (30,2) length 10
    ldx #&1e
    jsr draw_rope
; draw rope at (20,2) length 16
    ldx #&14
    lda #&10
    jsr draw_rope
; draw rope at (15,13) length 5
    ldx #&0f
    ldy #&0d
    lda #5
    jsr draw_rope
; draw rope at (25,13) length 5
    ldx #&19
    jsr draw_rope
; start main game loop for room 1
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jsr initialise_level_and_room

; *************************************************************************************
; 
; Room 0 update
; 
; Room 0 has two mice throwing a ball back and forth.
; 
; *************************************************************************************
.room0_update_handler
    lda update_room_first_update_flag
    bne room0_first_update
    jmp bump_and_wrap_mouse_ball_position

.room0_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq level_unchanged
    lda #0
    sta mouse_ball_animation_position
.level_unchanged
    lda desired_room_index
    cmp #0
    bne move_mouse_ball_if_room_0_local
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
; Perform shared initialisation for both mice
    lda #2
    sta width_in_cells
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
; Set up the left mouse
    ldx #&10
    ldy #&0b
    lda #&fe
    sta temp_sprite_y_offset
    lda #spriteid_mouse
    jsr draw_sprite_a_at_cell_xy
    dex
    dey
    dey
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #objectid_left_mouse
    jsr set_object_position_from_current_sprite_position
    lda #spriteid_erase2
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
; Set up the right mouse
    lda #&ff
    sta sprite_reflect_flag
    ldx #&19
    ldy #&0b
    lda #&fe
    sta temp_sprite_y_offset
    lda #spriteid_mouse
    jsr draw_sprite_a_at_cell_xy
    dex
    dey
    dey
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #objectid_right_mouse
    jsr set_object_position_from_current_sprite_position
    lda #&ff
    sta object_direction,x
    lda #spriteid_erase3
    sta object_erase_type,x
    lda #&c0
    sta object_z_order,x
; Set up the ball
    ldx #objectid_mouse_ball
    lda #0
    sta object_x_high,x
    sta object_y_high,x
    lda #1
    sta object_direction,x
    lda #spriteid_erase1
    sta object_erase_type,x
    lda #&40 ; '@'
    sta object_z_order,x
.move_mouse_ball_if_room_0_local
    jmp move_mouse_ball_if_room_0

.bump_and_wrap_mouse_ball_position
    ldy mouse_ball_animation_position
    iny
    cpy #max_mouse_ball_animation_position + 1
    bcc no_wrap_needed
    ldy #0
.no_wrap_needed
    sty mouse_ball_animation_position
    lda desired_room_index
    cmp #0
    bne move_mouse_ball_if_room_0
; Play the mouse ball sounds at positions 0 and $f
    tya
    beq play_mouse_ball_sounds
    cpy #&0f
    bne move_mouse_ball_if_room_0
.play_mouse_ball_sounds
    lda #0                                                            ; redundant instruction
    ldx #<mouse_ball_sound1
    ldy #>mouse_ball_sound1
    jsr play_sound_yx
    ldx #<mouse_ball_sound2
    ldy #>mouse_ball_sound2
    jsr play_sound_yx
    ldx #<mouse_ball_sound3
    ldy #>mouse_ball_sound3
    jsr play_sound_yx
.move_mouse_ball_if_room_0
    lda desired_room_index
    cmp #0
    bne return1
    lda mouse_ball_animation_position
    cmp #8
    bcs mouse_ball_position_ge_8
    ldy #0
    beq set_mouse_hand_and_ball_sprites_from_left                     ; ALWAYS branch
.mouse_ball_position_ge_8
    cmp #&0f
    bcs mouse_ball_position_ge_0xf
    sec
    sbc #8
; Multiply by 4 because each table entry is 4 bytes.
    asl a
    asl a
    tay
.set_mouse_hand_and_ball_sprites_from_left
    lda mouse_hand_sprites_and_ball_movement_table,y
; Set the mouse sprites as a pair of values in the table
    sta object_spriteid + objectid_left_mouse
    iny
    lda mouse_hand_sprites_and_ball_movement_table,y
    sta object_spriteid + objectid_right_mouse
    lda #mouse_ball_left_x_base
    clc
    iny
    adc mouse_hand_sprites_and_ball_movement_table,y
    bne finish_mouse_ball_movement                                    ; ALWAYS branch
.mouse_ball_position_ge_0xf
    cmp #&17
    bcs mouse_ball_position_ge_0x17
    ldy #0
    beq set_mouse_hand_and_ball_sprites_from_right                    ; ALWAYS branch
.mouse_ball_position_ge_0x17
    sec
    sbc #&17
; Multiply by 4 because each table entry is 4 bytes.
    asl a
    asl a
    tay
.set_mouse_hand_and_ball_sprites_from_right
    lda mouse_hand_sprites_and_ball_movement_table,y
    sta object_spriteid + objectid_right_mouse
    iny
    lda mouse_hand_sprites_and_ball_movement_table,y
    sta object_spriteid + objectid_left_mouse
    lda #mouse_ball_right_x_base
    sec
    iny
    sbc mouse_hand_sprites_and_ball_movement_table,y
.finish_mouse_ball_movement
    sta object_x_low + objectid_mouse_ball
    lda #mouse_ball_top_y_base
    sec
    iny
    sbc mouse_hand_sprites_and_ball_movement_table,y
    sta object_y_low + objectid_mouse_ball
    lda #spriteid_small_ball
    sta object_spriteid + objectid_mouse_ball
    lda update_room_first_update_flag
    bne return1
; Check for player-ball collision
    ldx #objectid_player
    ldy #objectid_mouse_ball
    jsr test_for_collision_between_objects_x_and_y
    beq return1
    lda #player_collision_flag_mouse_ball
    sta player_wall_collision_reaction_speed
.return1
    rts

; This table is indexed by a function of mouse_ball_position (it's not directly indexed
; to exploit the symmetry of the animation). Each table entry consists of four bytes:
; 0) left mouse hands sprite ID
; 1) right mouse hands sprite ID
; 2) ball X offset (applied to mouse_ball_left_x_base or mouse_ball_right_x_base
; depending on mouse_ball_position)
; 3) ball Y offset (applied to mouse_ball_top_y_base)
.mouse_hand_sprites_and_ball_movement_table
    equb spriteid_mouse_hands3
    equb spriteid_mouse_hands1
    equb 0, 0
    equb spriteid_mouse_hands2
    equb spriteid_mouse_hands1
    equb 8, 6
    equb spriteid_mouse_hands2
    equb spriteid_mouse_hands1
    equb 16, 10
    equb spriteid_mouse_hands2
    equb spriteid_mouse_hands4
    equb 24, 12
    equb spriteid_mouse_hands4
    equb spriteid_mouse_hands2
    equb 32, 12
    equb spriteid_mouse_hands1
    equb spriteid_mouse_hands2
    equb 40, 10
    equb spriteid_mouse_hands1
    equb spriteid_mouse_hands2
    equb 48,  6
; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 9                                                            ; initial player X cell
    equb 7                                                            ; initial player Y cell

; ########################################
; ########################################
; 
; 
; 
; 
;          P
; #################      #################
; #################      #################
; ####         ####      ####         ####
; ###           ###      ###           ###
; ###           ###      ###           ###
; ###           ###      ###           ###
; ###           ###      ###
; ###           ###      ###
; ###           ###      ###
; ###           ###      ###
; ###           ###      ###
; ###           ###      ###        OOO###
; ###           ###      ###        OOO###
; ###    OOO    ###      ###OOO     OOO###
; ###    OOO    ###      ###OOO     OOO###
; #################      #################
; #################      #################
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
; draw 17x2 rectangle at (0,7)
    ldy #7
    lda #&11
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (23,7)
    ldx #&17
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (0,22)
    ldx #0
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (23,22)
    ldx #&17
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,9)
    ldx #0
    ldy #9
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (13,9)
    ldx #&0d
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (23,9)
    ldx #&17
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,9)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x12 rectangle at (0,10)
    ldx #0
    iny
    dec width_in_cells
    lda #&0c
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x12 rectangle at (14,10)
    ldx #&0e
    jsr copy_rectangle_of_memory_to_screen
; draw 3x12 rectangle at (23,10)
    ldx #&17
    jsr copy_rectangle_of_memory_to_screen
; draw 3x3 rectangle at (37,10)
    ldx #&25 ; '%'
    lda #3
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (37,18)
    ldy #&12
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (26,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_table
    ldx #&1a
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (34,20) of size (3x2)
    ldx #&22 ; '"'
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (34,18) of size (3x2)
    ldy #&12
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (7,20) of size (3x2)
    ldx #7
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_1_check_bottom_exit
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

.room_1_check_bottom_exit
    lda room_exit_direction
    and #exit_room_bottom
    beq room_1_check_right_exit
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_1_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_1_game_update_loop
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

; *************************************************************************************
; 
; Room 1 update
; 
; Room 1 has a trapdoor which opens when the wizard stands on it holding the saxophone.
; 
; *************************************************************************************
.room1_update_handler
    lda update_room_first_update_flag
    beq room1_not_first_update
    lda level_before_latest_level_and_room_initialisation
    cmp current_level
    beq level_unchanged2
    lda save_game_level_a_room1_trapdoor_open_flag
    beq level_unchanged2
    lda #&ff
    sta save_game_level_a_room1_trapdoor_open_flag
.level_unchanged2
    lda desired_room_index
    cmp #1
    bne room1_initial_setup_done
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
; Set up the objects for the two trapdoors.
    ldx #&11
    ldy #7
    lda #objectid_left_trapdoor
    jsr set_object_position_from_cell_xy
    tax
    lda #1
    sta object_direction,x
    ldx #&17
    lda #objectid_right_trapdoor
    jsr set_object_position_from_cell_xy
    tax
    lda #&ff
    sta object_direction,x
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
; Set up the collision map for the two trapdoors.
    lda save_game_level_a_room1_trapdoor_open_flag
    bne set_up_open_trapdoor_collision_map
; Set up the trapdoor collision map if they are closed.
    ldx #&11
    ldy #7
    lda #6
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp room1_initial_setup_done

.set_up_open_trapdoor_collision_map
    ldx #&11
    ldy #8
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #&16
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.room1_initial_setup_done
    jmp set_room1_trapdoor_sprites_if_required

.room1_not_first_update
    ldy save_game_level_a_room1_trapdoor_open_flag
    bmi set_room1_trapdoor_sprites_if_required                        ; branch if trapdoor fully open
    bne increment_trapdoor_open_flag                                  ; branch if trapdoor partially open
; The trapdoor is closed.
    lda desired_room_index
    cmp #1
    bne set_room1_trapdoor_sprites_if_required
; Is the player holding something?
    lda player_held_object_spriteid
    beq set_room1_trapdoor_sprites_if_required
; Yes. Is the player standing over the trapdoor? The player's Y coordinate is not
; checked here, but there's a check below to see if the wizard is colliding with rock
; (which can only mean standing on the ground, including the closed trapdoors). The
; trapdoors don't open if the wizard is jumping in the air
    lda object_x_high + objectid_player
    bne set_room1_trapdoor_sprites_if_required
    lda object_x_low + objectid_player
    cmp #trapdoor_left_x
    bcc set_room1_trapdoor_sprites_if_required
    cmp #trapdoor_right_x
    bcs set_room1_trapdoor_sprites_if_required
; Yes. Is the player colliding with solid rock? (We probably 'should' only check for
; collision below the player, but in practice the other directions aren't possible.)
    lda #2
    sta temp_bottom_offset
; This is the state of the player as currently drawn on the screen, before being
; updated in the current game tick.
    lda #objectid_old_player
    jsr get_solid_rock_collision_for_object_a
    beq set_room1_trapdoor_sprites_if_required
; Yes, so we need to open the trapdoor. Remove the closed trapdoor from the collision
; map.
    ldx #&11
    ldy #7
    lda #6
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
; Add the two open trapdoors to the collision map.
    iny
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldx #&16
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.increment_trapdoor_open_flag
    ldy save_game_level_a_room1_trapdoor_open_flag
    iny
    cpy #2
    bcc new_room1_trapdoor_open_flag_in_y
    lda desired_room_index
    cmp #1
    bne skip_play_sound
; This is the trapdoor opening sound
    jsr play_sound12
.skip_play_sound
    ldy #&ff
.new_room1_trapdoor_open_flag_in_y
    sty save_game_level_a_room1_trapdoor_open_flag
.set_room1_trapdoor_sprites_if_required
    lda desired_room_index
    cmp #1
    bne return2
    ldy save_game_level_a_room1_trapdoor_open_flag
    bpl adjusted_room1_trapdoor_open_flag_in_y_is_ge_0
; Use sprite index 2 (vertical) if room1_trapdoor_open_flag is $ff
    ldy #2
.adjusted_room1_trapdoor_open_flag_in_y_is_ge_0
    lda trapdoor_sprite_table,y
    sta object_spriteid + objectid_left_trapdoor
    sta object_spriteid + objectid_right_trapdoor
.return2
    rts

.trapdoor_sprite_table
    equb spriteid_trapdoor_horizontal
    equb spriteid_trapdoor_diagonal
    equb spriteid_trapdoor_vertical

.play_sound12
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    rts

.room1_saxophone_and_brazier_handler
    lda #1
    sta currently_updating_logic_for_room_index
    lda #objectid_brazier
    ldx #&1a
    ldy #&0e
    jsr update_brazier_and_fire
    lda update_room_first_update_flag
    beq not_first_room_update
    lda #spriteid_saxophone_menu_item
    sta toolbar_collectable_spriteids + 1
    lda #spriteid_saxophone
    sta collectable_spriteids + 1
    sta collectable_being_used_spriteids + 1
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
    lda desired_room_index
    cmp #1
    bne return3
    lda save_game_level_a_saxophone_collected_flag
    bne return3
; The player has not collected the saxophone, so place it in the lower left of the
; room.
    ldx #&1b
    ldy #&12
    lda #7
    sta temp_sprite_y_offset
    lda #objectid_saxophone
    jsr set_object_position_from_cell_xy
    tax
    lda #1
    sta object_direction,x
    lda #spriteid_erase1
    sta object_erase_type,x
    lda #spriteid_saxophone
    sta object_spriteid,x
.return3
    rts

.not_first_room_update
    lda player_using_object_spriteid
    cmp #spriteid_saxophone_menu_item
    bne dont_play_saxophone_sound
    lda #0
    ldx #<saxophone_sound
    ldy #>saxophone_sound
    jsr play_sound_yx
.dont_play_saxophone_sound
    lda desired_room_index
    cmp #1
    bne return6
    lda save_game_level_a_saxophone_collected_flag
    bne return6
    lda #spriteid_saxophone
    sta object_spriteid + objectid_saxophone
; This is the state of the player as currently drawn on the screen, before being
; updated in the current game tick.
    ldx #objectid_old_player
    ldy #objectid_saxophone
    jsr test_for_collision_between_objects_x_and_y
    beq return6
; Collect the saxophone.
    lda #spriteid_saxophone_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #0
    sta object_spriteid + objectid_saxophone
    lda #&ff
    sta save_game_level_a_saxophone_collected_flag
.return6
    rts

; *************************************************************************************
; 
; Use copy_rectangle_of_memory_to_screen repeatedly to create a pseudo-circle shape -
; room 2 (the baby/spell room) has one of these in each corner.
; 
; On Entry:
;     X and Y registers specify top left cell of pseudo-circle
;     Everything else except {width,height}_in_cells_to_write as for
;         copy_rectangle_of_memory_to_screen
; 
; On Exit:
;     Preserves X,Y
; 
; *************************************************************************************
.copy_pseudo_circle_to_screen
    stx copy_pseudo_circle_to_screen_saved_x
    sty copy_pseudo_circle_to_screen_saved_y
    inx
    inx
    lda #5
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    dex
    iny
    lda #7
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
    dex
    iny
    lda #9
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    inx
    tya
    clc
    adc #5
    tay
    lda #7
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    inx
    iny
    lda #5
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
    ldx copy_pseudo_circle_to_screen_saved_x
    ldy copy_pseudo_circle_to_screen_saved_y
    rts

.copy_pseudo_circle_to_screen_saved_x
    equb 0
.copy_pseudo_circle_to_screen_saved_y
    equb 0
; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 20                                                           ; initial player X cell
    equb 9                                                            ; initial player Y cell

; #################      #################
; #################      #################
; #####     #######      #######     #####
; ####       ######      ######       ####
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                 P                ###
; ####       ##################       ####
; #####     ####################     #####
; ##############################     #####
; ##############################     #####
; #####     ####################     #####
; ####       ##################       ####
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ####       ##################       ####
; #####     ####################     #####
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 255x255 rectangle at (0,0)
.room_2_code
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; set ground fill tile to use
    lda #<tile_all_set_pixels
    sta source_sprite_memory_low
    lda #>tile_all_set_pixels
    sta source_sprite_memory_high
    lda #collision_map_none
    sta value_to_write_to_collision_map
    lda #copy_mode_simple
    sta copy_mode
    ldx #3
    ldy #2
    jsr copy_pseudo_circle_to_screen
    ldx #&1c
    jsr copy_pseudo_circle_to_screen
    ldy #&0d
    jsr copy_pseudo_circle_to_screen
    ldx #3
    jsr copy_pseudo_circle_to_screen
; draw 6x4 rectangle at (17,0)
    ldx #&11
    ldy #0
    lda #6
    sta width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x5 rectangle at (12,4)
    ldx #&0c
    ldy #4
    lda #&10
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x5 rectangle at (12,15)
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (30,11)
    ldx #&1e
    ldy #&0b
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    and #exit_room_top
    beq room_2_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.baby_spriteid_data
    equb spriteid_baby_walk_cycle_0
    equb spriteid_baby_walk_cycle_1
    equb spriteid_baby_walk_cycle_2
    equb spriteid_baby_walk_cycle_3
    equb 0
.baby_spriteid_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
    equb spriteid_baby_smile
.baby_spriteid_stunned
    equb &ff
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb spriteid_baby_stunned
    equb 0
.baby_spriteid_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
    equb spriteid_baby_shrug
.baby_spriteid_none
    equb &ff
.baby_spriteid_walk3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb spriteid_baby_walk_cycle_3
    equb 0
.baby_spriteid_dead
    equb spriteid_baby_dead
    equb 0

; *************************************************************************************
; 
; Room 2 update
; 
; Room 2 has the spell, guarded by a baby.
; 
; *************************************************************************************
.room2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    lda #3                                                            ; redundant instruction
    ldx #3                                                            ; redundant instruction
    ldy #&11                                                          ; redundant instruction
    ldx #7
    lda #4
    sta temp_sprite_x_offset
    ldy #&16
    lda #objectid_spell
    jsr update_level_completion
    lda update_room_first_update_flag
    beq room2_not_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room2_update_handler_not_new_level
    ldy #baby_spriteid_dead - baby_spriteid_data
    lda save_game_level_a_room_2_baby_direction
    ldx save_game_level_a_room_2_baby_pixel_x_coordinate
    bne have_valid_baby_properties_in_axy
    ldy #0
    lda #1
    ldx #&a0
.have_valid_baby_properties_in_axy
    sty baby_animation
    sty baby_animation_step
    sta save_game_level_a_room_2_baby_direction
    sta baby_pixel_x_speed
    stx baby_pixel_x_coordinate
.room2_update_handler_not_new_level
    lda desired_room_index
    cmp #2
    bne room2_update_second_part_local
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    ldx #0
    ldy #&14
    lda #&fe
    sta temp_sprite_y_offset
    lda #objectid_baby
    jsr set_object_position_from_cell_xy
    lda #spriteid_erase1
    sta object_erase_type + objectid_baby
.room2_update_second_part_local
    jmp room2_update_second_part

.room2_update_handler_temp
    equb 0

.room2_not_first_update
    ldy baby_animation_step
    cpy #baby_spriteid_dead - baby_spriteid_data
    bne baby_not_dead
    jmp room2_update_second_part

.baby_not_dead
    iny
    lda baby_spriteid_data,y
    bne have_specific_baby_spriteid
; if at the end of one animation, start the same one (loop) or a new one
    ldy baby_animation
.have_specific_baby_spriteid
    lda desired_room_index
    cmp #2
    bne player_not_collided_with_baby
    lda baby_animation
    cmp #baby_spriteid_dead - baby_spriteid_data
    beq baby_spriteid_index_if_baby_spriteid_data_is_zero_set
    ldx #objectid_player
    sty room2_update_handler_temp
    ldy #objectid_baby
    jsr test_for_collision_between_objects_x_and_y
    ldy room2_update_handler_temp
    ora #0                                                            ; set flags to reflect value in set flags to reflect value in A
    beq player_not_collided_with_baby
    lda #player_collision_flag_baby
    sta player_wall_collision_reaction_speed
    lda #0
    sta player_using_object_spriteid
    lda #1
    sta save_game_level_a_room_2_baby_direction
    ldy #baby_spriteid_walk3 - baby_spriteid_data
    lda #5
    sta baby_animation
.baby_spriteid_index_if_baby_spriteid_data_is_zero_set
    jmp move_baby

; Y contains the baby animation step
.player_not_collided_with_baby
    cpy #baby_spriteid_none - baby_spriteid_data
    bne check_for_using_saxophone
    ldy #baby_spriteid_smile - baby_spriteid_data
    sty baby_animation
.check_for_using_saxophone
    lda desired_room_index
    cmp #2
    bne player_not_using_saxophone
    lda player_using_object_spriteid
    cmp #spriteid_saxophone_menu_item
    bne player_not_using_saxophone
    ldy #&0e
    lda #baby_spriteid_shrug - baby_spriteid_data
    sta baby_animation
    lda object_y_low
    cmp #&a0
    bcs move_baby
    cmp #&78 ; 'x'
    bcc move_baby
; set baby dead
    lda #baby_spriteid_dead - baby_spriteid_data
    sta baby_animation
    jmp move_baby

.player_not_using_saxophone
    cpy #baby_spriteid_stunned - baby_spriteid_data
    bne baby_not_stunned
; start walk cycle
    ldy #0
    sty baby_animation
.baby_not_stunned
    lda baby_animation
    cmp #0                                                            ; redundant instruction
    bne move_baby
    lda baby_pixel_x_speed
    sta save_game_level_a_room_2_baby_direction
    lda baby_pixel_x_coordinate
    ldx baby_pixel_x_speed
    bmi baby_pixel_x_speed_negative
    cmp #baby_max_pixel_x
    beq baby_pixel_x_coordinate_is_max_or_min
    bcc baby_pixel_x_coordinate_within_min_max
    bcs baby_pixel_x_coordinate_outside_min_max                       ; ALWAYS branch

.baby_pixel_x_speed_negative
    cmp #baby_min_pixel_x
    beq baby_pixel_x_coordinate_is_max_or_min
    bcs baby_pixel_x_coordinate_within_min_max
    bcc baby_pixel_x_coordinate_outside_min_max                       ; ALWAYS branch

.baby_pixel_x_coordinate_is_max_or_min
    ldy #baby_spriteid_smile - baby_spriteid_data
    sty baby_animation
    jmp baby_pixel_x_coordinate_within_min_max

; reverse baby direction
.baby_pixel_x_coordinate_outside_min_max
    lda baby_pixel_x_speed
    eor #&fe
    sta baby_pixel_x_speed
    sta save_game_level_a_room_2_baby_direction
.baby_pixel_x_coordinate_within_min_max
    lda baby_pixel_x_speed
    asl a
    asl a
    clc
    adc baby_pixel_x_coordinate
    sta baby_pixel_x_coordinate
    jmp baby_pixel_x_coordinate_updated

.move_baby
    lda save_game_level_a_room_2_baby_direction
    bmi baby_direction_negative
    lda baby_pixel_x_coordinate
    clc
    adc #4
    and #&f8
    sta baby_pixel_x_coordinate
    jmp baby_pixel_x_coordinate_updated

.baby_direction_negative
    lda baby_pixel_x_coordinate
    and #&f8
    sta baby_pixel_x_coordinate
.baby_pixel_x_coordinate_updated
    sty baby_animation_step
    lda desired_room_index
    cmp #2
    bne room2_update_second_part
    cpy #baby_spriteid_dead - baby_spriteid_data
    bne room2_update_second_part
; This is the dead baby sound
    jsr play_sound12
.room2_update_second_part
    lda desired_room_index
    cmp #2
    bne return5
    lda baby_animation
    cmp #baby_spriteid_dead - baby_spriteid_data
    bne set_baby_object_properties
    lda baby_pixel_x_coordinate
    sta save_game_level_a_room_2_baby_pixel_x_coordinate
    lsr a
    lsr a
    lsr a
    tax
    lda baby_animation_step
    cmp #baby_spriteid_dead - baby_spriteid_data
    beq update_collision_map_for_baby
; Add the baby to the collision map.
    dex
    ldy #&11
    lda #2
    sta width_in_cells
    lda #3
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp set_baby_object_properties

; When the baby is killed, remove the baby from the collision map and add it at its new
; position.
.update_collision_map_for_baby
    dex
    ldy #&11
    lda #2
    sta width_in_cells
    lda #3
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    lda save_game_level_a_room_2_baby_direction
    bmi baby_direction_negative2
    dex
.baby_direction_negative2
    ldy #&13
    lda #3
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.set_baby_object_properties
    ldx #objectid_baby
    lda baby_pixel_x_coordinate
    sta object_x_low,x
    ldy baby_animation_step
    lda baby_spriteid_data,y
    sta object_spriteid,x
    lda save_game_level_a_room_2_baby_direction
    sta object_direction,x
.return5
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
;                                  |  ####
;                                  |   ###
;                                  |   ###
;                                  |   ###
;                     P            |   ###
; #####     ####################   |   ###
; #####     ####################   |   ###
; ###                              |   ###
; ###                              |   ###
; ###                              |   ###
; ###                 S            |   ###
;                                  |   ###
;                                  |   ###
;                                  |   ###
;                                      ###
;                                      ###
; #####                         ##########
; #####                         ##########
; #####                         ##########
; ##########               ###############
; ########################################
; ########################################
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
; draw 255x1 rectangle at (36,2)
    ldx #&24 ; '$'
    ldy #2
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x15 rectangle at (37,3)
    inx
    iny
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x3 rectangle at (0,18)
    ldx #0
    ldy #&12
    lda #5
    sta width_in_cells
    lda #3
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x3 rectangle at (30,18)
    ldx #&1e
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 10x1 rectangle at (0,21)
    ldx #0
    ldy #&15
    lda #&0a
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x1 rectangle at (25,21)
    ldx #&19
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldx #0
    iny
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 20x2 rectangle at (10,7)
    ldx #&0a
    ldy #7
    lda #&14
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,7)
    ldx #0
    lda #5
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x4 rectangle at (0,9)
    ldy #9
    lda #3
    sta width_in_cells
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw ball at (20,12)
    ldx #&14
    ldy #&0c
    lda #spriteid_ball
    jsr draw_sprite_a_at_cell_xy
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
; draw rope at (33,2) length 14
    ldx #&21 ; '!'
    ldy #2
    lda #&0e
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_3_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

; *************************************************************************************
; 
; Room 3 update
; 
; Room 3 has a table which can be pushed to the left or right side of the screen.
; 
; *************************************************************************************
.room3_update_handler
    lda #3
    sta currently_updating_logic_for_room_index
    lda #objectid_brazier2
    ldx #&14
    ldy #&0c
    jsr update_brazier_and_fire
    lda #4
    inx
    jsr update_brazier_and_fire
    lda update_room_first_update_flag
    beq room3_not_first_update
    lda level_before_latest_level_and_room_initialisation
    cmp current_level
    beq table_x_position_update_finished
    lda save_game_level_a_table_x_position
    beq set_table_x_position_to_right_side
    lda save_game_level_a_table_x_speed
    beq table_x_position_update_finished
    bpl set_table_x_position_to_right_side
; Set table_x_position to left side of screen
    lda #table_min_x
    sta save_game_level_a_table_x_position
    lda #0
    sta save_game_level_a_table_x_speed
    beq table_x_position_update_finished                              ; ALWAYS branch
.set_table_x_position_to_right_side
    lda #table_max_x
    sta save_game_level_a_table_x_position
    lda #0
    sta save_game_level_a_table_x_speed
.table_x_position_update_finished
    lda desired_room_index
    cmp #3
    bne add_table_to_collision_map_if_room_3_local
    ldx #<envelope4
    ldy #>envelope4
    jsr define_envelope
    ldx #objectid_table
    lda #spriteid_table
    sta object_spriteid,x
    lda #spriteid_erase1
    sta object_erase_type,x
.add_table_to_collision_map_if_room_3_local
    jmp add_table_to_collision_map_if_room_3

.return4_local
    jmp return4

.room3_not_first_update
    lda save_game_level_a_table_x_speed
    bne move_table
    lda desired_room_index
    cmp #3
    bne return4_local
    lda save_game_level_a_table_x_position
    cmp #table_max_x
    beq table_at_max_x_position
    lda object_room_collision_flags
    and #object_collided_right_wall
    beq return4_local
    lda #1
    sta temp_right_offset
    ldx #objectid_player
    ldy #objectid_table
    jsr test_for_collision_between_objects_x_and_y
    beq return4_local
    lda #1
    sta save_game_level_a_table_x_speed
    bne move_table                                                    ; ALWAYS branch
.table_at_max_x_position
    lda object_room_collision_flags
    and #object_collided_left_wall
    beq return4_local
    lda #&ff
    sta temp_left_offset
    ldx #objectid_player
    ldy #objectid_table
    jsr test_for_collision_between_objects_x_and_y
    beq return4_local
    lda #&ff
    sta save_game_level_a_table_x_speed
.move_table
    lda save_game_level_a_table_x_position
    sta old_table_x_position
    clc
    adc save_game_level_a_table_x_speed
    sta save_game_level_a_table_x_position
    cmp #table_min_x
    beq moving_table_hit_wall
    cmp #table_max_x
    bne moving_table_not_hit_wall
.moving_table_hit_wall
    lda #0
    sta save_game_level_a_table_x_speed
    lda desired_room_index
    cmp #3
    bne return4
    lda sound_priority_per_channel_table
    cmp #&81
    bcs ready_to_play_table_hit_wall_sound
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
.ready_to_play_table_hit_wall_sound
    jsr play_landing_sound
    jmp remove_table_from_collision_map_at_old_table_x_position

.moving_table_not_hit_wall
    lda desired_room_index
    cmp #3
    bne return4
    lda #&80
    ldx #<some_sound4
    ldy #>some_sound4
    jsr play_sound_yx
.remove_table_from_collision_map_at_old_table_x_position
    ldx old_table_x_position
    ldy #&14
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.add_table_to_collision_map_if_room_3
    lda desired_room_index
    cmp #3
    bne return4
; Add the table to the collision map and set its object position.
    ldx save_game_level_a_table_x_position
    ldy #&14
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    lda #objectid_table
    jsr set_object_position_from_cell_xy
.return4
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
    equb 20                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 255                                                          ; change of amplitude per step during sustain phase
    equb 246                                                          ; change of amplitude per step during release phase
    equb 100                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.saxophone_sound
    equw &0013                                                        ; channel
    equw 5                                                            ; amplitude
    equw 0                                                            ; pitch
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
.envelope4
    equb 6                                                            ; envelope number
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
.some_sound4
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 4                                                            ; pitch
    equw 4                                                            ; duration
.envelope1
    equb 6                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 30                                                           ; change of amplitude per step during attack phase
    equb 206                                                          ; change of amplitude per step during decay phase
    equb 206                                                          ; change of amplitude per step during sustain phase
    equb 156                                                          ; change of amplitude per step during release phase
    equb 100                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.mouse_ball_sound3
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.mouse_ball_sound2
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 190                                                          ; pitch
    equw 1                                                            ; duration
.mouse_ball_sound1
    equw &0010                                                        ; channel
    equw 0                                                            ; amplitude
    equw 0                                                            ; pitch
    equw 0                                                            ; duration
.ground_fill_2x2_top_left
    equb %00010000
    equb %00100000
    equb %01000000
    equb %10000011
    equb %00000100
    equb %00001000
    equb %00010000
    equb %00010000
; Note that the next three tiles are all identical. This is done because the 'tiling'
; code in copy_rectangle_of_memory_to_screen for copy_mode=1 uses a 2x2 tiling
; arrangement.
.ground_fill_2x2_top_right
    equb %00001000
    equb %00000100
    equb %00000010
    equb %00000001
    equb %10000000
    equb %01000000
    equb %00100000
    equb %00010000
.ground_fill_2x2_bottom_left
    equb %00001000
    equb %00000100
    equb %00000010
    equb %00000001
    equb %10000000
    equb %01000000
    equb %00100000
    equb %00010000
.ground_fill_2x2_bottom_right
    equb %00001000
    equb %00000100
    equb %00000010
    equb %00000001
    equb %10000000
    equb %01000000
    equb %00100000
    equb %00010000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelA_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelA.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelA"
ENDIF
ENDIF
.pydis_end

save "build/dataA", pydis_start, pydis_end
