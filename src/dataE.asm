; *************************************************************************************
;
; Level E: 'DUCK-EGG-BLUES'
;
; Save game variables:
;
;     save_game_level_e_small_egg_status                         ($0a13):
;               0: uninitialised
;               1: stationary
;              $c: thrown right
;             $25: thrown left
;             $32: falling
;             $ff: taken
;
;     save_game_level_e_big_egg_animation_index                  ($0a14):
;               0: uninitialised
;               1: normal position
;               5: tilted position
;               9: falling off ledge
;             $16: falling straight down
;             $1a: landed
;
;     save_game_level_e_bird_global_x_position                   ($0a15):
;             X position within the bird's cross-screen flight path
;             $ff: taken
;
; Solution:
;
;   1. Move to the room to the right and climb the rope to collect the small egg
;   2. Return to the starting room and climb the rope exiting on the right to stand on nest.
;   3. As the wizard, use the small egg to tilt the big egg.
;   4. Collect the small egg and throw from the same position. (The big egg falls)
;   5. Jump onto the big egg as the cat and jump onto the left platform to exit the room left.
;   6. Climb the rope while looking right to the top then jump off to the right, timing it to
;      collide with the bird.
;   7. Change into the bird and fly up to the top room to collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
bird_max_global_x_position            = 116
bird_min_global_x_position            = 30
objectid_bird                         = 4
objectid_bird_wings                   = 5
objectid_egg                          = 3
objectid_fire1                        = 3
objectid_fire2                        = 4
objectid_small_egg                    = 2
objectid_sparkles                     = 5
small_egg_status_collected            = 255
spriteid_bird_1                       = 200
spriteid_bird_2                       = 201
spriteid_bird_toolbar                 = 209
spriteid_bird_transform_1             = 204
spriteid_bird_transform_2             = 205
spriteid_bird_turn                    = 202
spriteid_bird_wing_1                  = 206
spriteid_bird_wing_2                  = 207
spriteid_bird_wing_3                  = 208
spriteid_egg                          = 210
spriteid_egg_toolbar                  = 211
spriteid_erase_bird_wings             = 223
spriteid_erase_large_egg              = 222
spriteid_erase_small_egg              = 214
spriteid_large_egg_sideways           = 221
spriteid_large_egg_tilted             = 220
spriteid_large_egg_upright            = 219
spriteid_nest                         = 212
spriteid_small_egg_down               = 216
spriteid_small_egg_left               = 217
spriteid_small_egg_right              = 215
spriteid_small_egg_upright            = 218

; Memory locations
timeout_while_bird_on_ground_stationary                 = &0023
object_left_low                                         = &0070
room_exit_direction                                     = &0070
object_left_high                                        = &0071
object_right_low                                        = &0072
object_right_high                                       = &0073
object_left_cell_x                                      = &0078
object_right_cell_x                                     = &0079
object_current_index_in_animation                       = &09d4
save_game_level_e_small_egg_status                      = &0a13
save_game_level_e_big_egg_animation_index               = &0a14
save_game_level_e_bird_global_x_position                = &0a15
level_workspace_small_egg_offscreen_time                = &0a6f
thrown_egg_x_low                                        = &0a70
thrown_egg_x_high                                       = &0a71
thrown_egg_y_low                                        = &0a72
thrown_egg_direction                                    = &0a73
small_egg_animation_step                                = &0a74
room_containing_small_egg                               = &0a75
egg_animation_index                                     = &0a76
room_1_egg_x                                            = &0a77
room_1_egg_y                                            = &0a78
bird_object_direction                                   = &0a79
bird_x_direction                                        = &0a7a
bird_wing_animation_index                               = &0a7b

org level_data_load_address

.levelE
{
    ; *************************************************************************************
    ;
    ; Level header
    ;
    ; *************************************************************************************
    .level_data
    IF swr_renderer_enabled
        EQUW levelE_sprite_table - level_data
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
        equb 3
    .level_room_data_table
        equw room_0_data                                                  ; table of room data/initialisation code
        equw room_1_data
        equw room_2_data
        equw room_3_data

    ; *************************************************************************************
    .level_specific_password
        encode "DUCK-EGG-BLUES", &0D

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
        beq bird_not_captured_yet
        lda developer_flags
        bpl developer_mode_not_active
        lda #small_egg_status_collected
        sta save_game_level_e_small_egg_status
        lda #spriteid_bird_toolbar
        jsr insert_character_menu_item_into_toolbar
    .developer_mode_not_active
        lda save_game_level_e_small_egg_status
        bpl dont_have_egg
        lda #spriteid_egg_toolbar
        jsr find_or_create_menu_slot_for_A
    .dont_have_egg
        lda save_game_level_e_bird_global_x_position
        cmp #&ff
        bne bird_not_captured_yet
        lda #spriteid_bird_toolbar
        jsr insert_character_menu_item_into_toolbar
    .bird_not_captured_yet
        lda #<update_bird
        sta jmp_for_update_extra_player_character + 1
        lda #>update_bird
        sta jmp_for_update_extra_player_character + 2
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
        jsr room_1_update_handler
        jsr room_2_update_handler
        jmp room_3_update_handler

    ; This table is 0-terminated
    .bird_wing_animation_table
        equb spriteid_bird_wing_1, spriteid_bird_wing_2
        equb spriteid_bird_wing_3, spriteid_bird_wing_2
        equb                    0
    ; bird doesn't have accessories
    .bird_accessory_sprite_list
        equb 0
    .bird_base_animations
    .bird_transition_in_animation
        equb spriteid_one_pixel_masked_out
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_2
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_2
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 0
        equb 0
        equb 0                                                            ; terminator

    .bird_transition_out_animation
        equb spriteid_bird_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_1
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_2
        equb 0
        equb 0
        equb 0
        equb spriteid_bird_transform_2
        equb 0
        equb 0
        equb 0
        equb 0                                                            ; terminator

    .bird_stationary_for_a_while_animation
        equb spriteid_bird_1
        equb 0
        equb 0
        equb 0
        equb 0                                                            ; terminator

    .bird_turn1_animation
        equb spriteid_bird_turn
        equb 0
        equb &fc
        equb 0
    .bird_turn1_mid_way
        equb spriteid_bird_2
        equb 2
        equb &fe
        equb 0
        equb 0                                                            ; terminator

    .bird_stationary_on_floor_animation
        equb spriteid_bird_1
        equb 0
        equb 0
        equb 0
        equb 0                                                            ; terminator

    .bird_animation5
        equb spriteid_bird_2
        equb 0
        equb 0
        equb &ff
        equb 0                                                            ; terminator

    .bird_fly_straight_up_animation
        equb spriteid_bird_2
        equb 0
        equb &fc
        equb &ff
        equb 0                                                            ; terminator

    .bird_flying_sideways_animation
        equb spriteid_bird_2
        equb 4
        equb 0
        equb &ff
        equb 0                                                            ; terminator

    .bird_animation8
        equb spriteid_bird_2
        equb 4
        equb &fc
        equb &ff
        equb 0                                                            ; terminator

    .bird_turn_while_flying_animation
        equb spriteid_bird_turn
        equb 0
        equb 0
        equb &ff
    .bird_turn_while_flying_mid_way
        equb spriteid_bird_2
        equb 2
        equb 0
        equb &ff
        equb 0                                                            ; terminator

    .bird_start_hop_animation
        equb spriteid_bird_2
        equb 4
        equb &fc
        equb 0
        equb spriteid_bird_2
        equb 4
        equb &fe
        equb 0
        equb 0                                                            ; terminator

    .bird_animation11
        equb spriteid_bird_1
        equb 4
        equb 2
        equb 0
        equb spriteid_bird_1
        equb 4
        equb 4
        equb 0
        equb spriteid_bird_1
        equb 2
        equb 4
        equb 0
        equb 0                                                            ; terminator

    .bird_animation12
        equb spriteid_bird_1
        equb 3
        equb 1
        equb 0
        equb spriteid_bird_1
        equb 2
        equb 3
        equb 0
        equb spriteid_bird_1
        equb 1
        equb 5
        equb 0
        equb 0                                                            ; terminator

    .bird_animation13
        equb spriteid_bird_1
        equb 4
        equb 2
        equb 0
        equb spriteid_bird_1
        equb 3
        equb 3
        equb 0
        equb spriteid_bird_1
        equb 2
        equb 4
        equb 0
        equb spriteid_bird_1
        equb 1
        equb 5
        equb 0
        equb 0                                                            ; terminator

    .bird_animation14
        equb spriteid_bird_1
        equb &fc
        equb 2
        equb 0
        equb spriteid_bird_1
        equb &fd
        equb 3
        equb 0
        equb spriteid_bird_1
        equb &fe
        equb 4
        equb 0
        equb spriteid_bird_1
        equb &ff
        equb 5
        equb 0
        equb 0                                                            ; terminator

    .bird_animation15
        equb spriteid_bird_1
        equb 0
        equb 1
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 2
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 3
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 4
        equb 0
        equb spriteid_bird_1
        equb 0
        equb 5
        equb 0
        equb 0                                                            ; terminator

    .bird_fall_straight_down_animation
        equb spriteid_bird_1
        equb 0
        equb 7
        equb 0
        equb 0                                                            ; terminator


    .draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        lda #3
        sta width_in_cells
        lda #1
        sta height_in_cells
        lda #spriteid_nest
        jmp draw_sprite_a_at_cell_xy_and_write_to_collision_map

    ; *************************************************************************************
    ;
    ; Room 2 initialisation and game loop
    ;
    ; *************************************************************************************
    .room_2_data
        equb 20                                                           ; initial player X cell
        equb 22                                                           ; initial player Y cell

    ; #################      #################
    ; #################      #################
    ; ###        |
    ; ###        |
    ; ###        |
    ; ###        |
    ; ###        |
    ; ###        |     ######              ###
    ; ###        |     ######              ###
    ; ###        |        ###              ###
    ; ###        |        ###              ###
    ; ###OOO     |        ###           OOO###
    ; ######     |        ###           ######
    ; ######     |        ###           ######
    ; ###        |        ###OOO
    ; ###        |        ######
    ; ###        |        ######
    ; ###        |
    ; ###        |
    ; ###        |                      ######
    ; ###                            #########
    ; ###                 P       ############
    ; ########################################
    ; ########################################
    ; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
    ; map.
    ; draw 17x2 rectangle at (0,0)
    .room_2_code
        ldx #0
        ldy #0
        lda #&11
        sta width_in_cells
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 17x2 rectangle at (23,0)
        ldx #&17
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x20 rectangle at (0,2)
        ldx #0
        ldy #2
        lda #3
        sta width_in_cells
        lda #&14
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x20 rectangle at (0,22)
        ldy #&16
        lda #&ff
        sta width_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x1 rectangle at (28,21)
        ldx #&1c
        dey
        lda #1
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x1 rectangle at (31,20)
        ldx #&1f
        dey
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x1 rectangle at (34,19)
        ldx #&22 ; '"'
        dey
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (3,12)
        ldx #3
        ldy #&0c
        lda #3
        sta width_in_cells
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (34,12)
        ldx #&22 ; '"'
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (17,7)
        ldx #&11
        ldy #7
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (23,15)
        ldx #&17
        ldy #&0f
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x10 rectangle at (20,7)
        ldx #&14
        ldy #7
        lda #&0a
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x7 rectangle at (37,7)
        ldx #&25 ; '%'
        lda #7
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; carve the floor, walls and ceiling into the rock
        jsr draw_floor_walls_and_ceiling_around_solid_rock
        ldx #3
        ldy #&0b
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&22 ; '"'
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&17
        ldy #&0e
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&13
        ldy #9
        lda #1
        sta width_in_cells
        lda #3
        sta height_in_cells
        jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ; draw rope at (11,2) length 18
        ldx #&0b
        ldy #2
        lda #&12
        jsr draw_rope
        jsr start_room
    .room_2_game_update_loop
        jsr game_update
        sta room_exit_direction
        and #exit_room_top
        beq room_2_check_right_exit
        ldx #3
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
        lda #objectid_fire1
        ldx #&14
        ldy #&0c
        jsr update_brazier_and_fire
    ; check for first update in room (branch if not)
        lda update_room_first_update_flag
        beq room_2_not_first_update
        lda save_game_level_e_bird_global_x_position
        cmp #&ff
        beq choose_bird_sprite_if_in_room_1_or_2_local
    ; check for level change (branch if not)
        lda current_level
        cmp level_before_latest_level_and_room_initialisation
        beq initialise_bird_in_room_1_or_2
        lda #&73 ; 's'
        sta save_game_level_e_bird_global_x_position
        lda #&ff
        sta bird_object_direction
        sta bird_x_direction
        lda #0
        sta bird_wing_animation_index
    .initialise_bird_in_room_1_or_2
        lda desired_room_index
        beq choose_bird_sprite_if_in_room_1_or_2_local
        cmp #3
        bcs choose_bird_sprite_if_in_room_1_or_2_local
    ; initialise bird
        lda #spriteid_erase_bird_wings
        sta object_erase_type + objectid_bird_wings
        lda #&fe
        sta object_z_order + objectid_bird_wings
        lda #&2c ; ','
        sta object_y_low + objectid_bird
        sta object_y_low + objectid_bird_wings
        lda #0
        sta object_y_high + objectid_bird
        sta object_y_high + objectid_bird_wings
    .choose_bird_sprite_if_in_room_1_or_2_local
        jmp choose_bird_sprite_if_in_room_1_or_2

    .return1_local
        jmp return1

    .room_2_not_first_update
        lda save_game_level_e_bird_global_x_position
        cmp #&ff
        beq return1_local
        lda desired_room_index
        cmp #2
        bne update_bird_animation
        ldx #objectid_old_player
        ldy #objectid_bird
        jsr test_for_collision_between_objects_x_and_y
        beq update_bird_animation
        lda #spriteid_bird_toolbar
        jsr insert_character_menu_item_into_toolbar
        lda #spriteid_one_pixel_masked_out
        sta object_spriteid + objectid_bird
        sta object_spriteid + objectid_bird_wings
        lda #&ff
        sta save_game_level_e_bird_global_x_position
        bmi return1_local
    .update_bird_animation
        ldy bird_wing_animation_index
        iny
        lda bird_wing_animation_table,y
        bne store_bird_wind_animation_index
        ldy #0
    .store_bird_wind_animation_index
        sty bird_wing_animation_index
        lda bird_x_direction
        bne check_bird_x_range_limits
    ; flip bird direction
        lda bird_object_direction
        eor #&fe
        sta bird_object_direction
        sta bird_x_direction
        jmp add_direction_to_bird_x_position

    .check_bird_x_range_limits
        lda save_game_level_e_bird_global_x_position
        cmp #bird_min_global_x_position
        beq bird_hit_min_or_max_global_x_position
        cmp #bird_max_global_x_position
        bne add_direction_to_bird_x_position
    .bird_hit_min_or_max_global_x_position
        lda #0
        sta bird_x_direction
    .add_direction_to_bird_x_position
        lda save_game_level_e_bird_global_x_position
        clc
        adc bird_x_direction
        sta save_game_level_e_bird_global_x_position
    .choose_bird_sprite_if_in_room_1_or_2
        lda save_game_level_e_bird_global_x_position
        cmp #&ff
        beq return1
        lda desired_room_index
        beq return1
        cmp #3
        bcs return1
        lda #spriteid_bird_2
        ldx bird_x_direction
        bne set_bird_sprite
        lda #spriteid_bird_turn
    .set_bird_sprite
        sta object_spriteid + objectid_bird
        ldy bird_wing_animation_index
        lda bird_wing_animation_table,y
        sta object_spriteid + objectid_bird_wings
        lda save_game_level_e_bird_global_x_position
        ldx desired_room_index
        cpx #2
        beq set_x_to_high_byte_of_bird_x_position
        sec
        sbc #&50 ; 'P'
    .set_x_to_high_byte_of_bird_x_position
        ldx #0
        cmp #&a0
        bcc set_bird_object_x_and_direction
        dex
    .set_bird_object_x_and_direction
        stx object_x_high + objectid_bird
        asl a
        rol object_x_high + objectid_bird
        asl a
        rol object_x_high + objectid_bird
        sta object_x_low + objectid_bird
        sta object_x_low + objectid_bird_wings
        lda object_x_high + objectid_bird
        sta object_x_high + objectid_bird_wings
        lda bird_object_direction
        sta object_direction + objectid_bird
        sta object_direction + objectid_bird_wings
    .return1
        rts

    ; *************************************************************************************
    ;
    ; Room 3 initialisation and game loop
    ;
    ; *************************************************************************************
    .room_3_data
        equb 12                                                           ; initial player X cell
        equb 8                                                            ; initial player Y cell

    ; ########################################
    ; ########################################
    ; ###                                  ###
    ; ###                                  ###
    ; ###                                  ###
    ; ###                                  ###
    ; ###                                  ###
    ; ###         P                        ###
    ; ###     #########      #########     ###
    ; ###     #########      #########     ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; ###        OOO###      ###OOO        ###
    ; ###        ######      ######        ###
    ; ###        ######      ######        ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; ###           ###      ###           ###
    ; #################      #################
    ; #################      #################
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
    ; draw 3x20 rectangle at (0,2)
        ldy #2
        lda #3
        sta width_in_cells
        lda #&14
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x20 rectangle at (37,2)
        ldx #&25 ; '%'
        jsr copy_rectangle_of_memory_to_screen
    ; draw 17x20 rectangle at (0,22)
        ldx #0
        ldy #&16
        lda #&11
        sta width_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 17x20 rectangle at (23,22)
        ldx #&17
        jsr copy_rectangle_of_memory_to_screen
    ; draw 9x2 rectangle at (8,8)
        ldx #8
        ldy #8
        lda #9
        sta width_in_cells
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 9x2 rectangle at (23,8)
        ldx #&17
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x12 rectangle at (14,10)
        ldx #&0e
        ldy #&0a
        lda #3
        sta width_in_cells
        lda #&0c
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x12 rectangle at (23,10)
        ldx #&17
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (11,15)
        ldx #&0b
        ldy #&0f
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (26,15)
        ldx #&1a
        jsr copy_rectangle_of_memory_to_screen
    ; carve the floor, walls and ceiling into the rock
        jsr draw_floor_walls_and_ceiling_around_solid_rock
        ldx #&0b
        ldy #&0e
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&1a
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #3
        ldy #2
        lda #1
        sta width_in_cells
        lda #3
        sta height_in_cells
        jsr write_value_to_a_rectangle_of_cells_in_collision_map
        ldx #&24 ; '$'
        jsr write_value_to_a_rectangle_of_cells_in_collision_map
        jsr start_room
    .room_3_game_update_loop
        jsr game_update
        and #exit_room_bottom
        beq room_3_game_update_loop
        ldx #2
        ldy current_level
        jmp initialise_level_and_room

    .room_3_update_handler
        lda #3
        sta currently_updating_logic_for_room_index
        lda #objectid_fire1
        ldx #3
        ldy #5
        jsr update_brazier_and_fire
        lda #objectid_fire2
        ldx #&25 ; '%'
        jsr update_brazier_and_fire
        ldx #&1b
        lda #4
        sta temp_sprite_x_offset
        ldy #&0e
        lda #objectid_sparkles
        jmp update_level_completion

    .update_bird
        lda #bird_transition_out_animation - bird_base_animations
        sta transform_out_animation
        ldx #<bird_base_animations
        ldy #>bird_base_animations
        lda #objectid_bird
        jsr set_base_animation_address_and_handle_transform_in_out
        bne set_player_animation_step_local
    ; check for reversing bird direction
        cpy #bird_turn1_mid_way - bird_base_animations
        beq reverse_direction_of_player
        cpy #bird_turn_while_flying_mid_way - bird_base_animations
        bne check_bird_wall_and_floor_collision
    .reverse_direction_of_player
        lda object_direction
        eor #&fe
        sta object_direction
        jmp set_player_animation_step

    .check_bird_wall_and_floor_collision
        jsr update_player_hitting_floor_or_pushed
        beq no_floor_collision
        jmp bird_hit_wall_or_floor

    .no_floor_collision
        lda jump_requested
        beq no_flying_requested
        ldx #bird_fly_straight_up_animation - bird_base_animations
        lda move_left_requested
        ora move_right_requested
        bne left_or_right_requested
        dec temp_top_offset
        bne check_for_player_rock_collisions                              ; ALWAYS branch

    .left_or_right_requested
        ldx #bird_animation5 - bird_base_animations
        lda move_left_requested
        and move_right_requested
        bne left_and_right_requested
        ldx #bird_turn_while_flying_animation - bird_base_animations
        lda player_move_direction_requested
        cmp object_direction
        bne left_and_right_requested
        ldx #bird_flying_sideways_animation - bird_base_animations
        lda #1
        sta temp_bottom_offset
        lda object_direction
        cmp #&ff
        beq player_looking_left
        inc temp_right_offset
        bne check_for_player_rock_collisions
    .player_looking_left
        dec temp_left_offset
    .check_for_player_rock_collisions
        lda #objectid_player
        jsr get_solid_rock_collision_for_object_a
        beq left_and_right_requested
        stx current_player_animation
        ldy #bird_animation8 - bird_base_animations
        jmp set_player_animation_step_local

    .left_and_right_requested
        cpx current_player_animation
        beq set_player_animation_step_local
        stx current_player_animation
        txa
        tay
    .set_player_animation_step_local
        jmp set_player_animation_step

    .no_flying_requested
        lda current_player_animation
        cmp #bird_start_hop_animation - bird_base_animations
        bne check_if_player_is_on_the_floor
        dec temp_top_offset
        lda #objectid_player
        jsr get_solid_rock_collision_for_object_a
        bne set_falling_straight_down
        cpy #bird_start_hop_animation - bird_base_animations
        beq set_falling_straight_down
        jmp set_player_animation_step

    .set_falling_straight_down
        lda #bird_fall_straight_down_animation - bird_base_animations
        sta current_player_animation
        ldy #bird_animation11 - bird_base_animations
    .check_if_player_is_on_the_floor
        lda object_has_hit_floor_flag
        bne check_for_player_change_of_direction
    .bird_hit_wall_or_floor
        lda #bird_fall_straight_down_animation - bird_base_animations
        cmp current_player_animation
        beq set_player_animation_step_local
        ldx current_player_animation
        sta current_player_animation
        ldy #bird_animation12 - bird_base_animations
        cpx #bird_flying_sideways_animation - bird_base_animations
        beq set_player_animation_step_local
        ldy #bird_animation15 - bird_base_animations
        jmp set_player_animation_step

    .check_for_player_change_of_direction
        ldx player_move_direction_requested
        beq bird_is_stationary
        ldy #bird_turn1_animation - bird_base_animations
        cpx object_direction
        bne set_next_animation_to_hop
        ldy #bird_start_hop_animation - bird_base_animations
    .set_next_animation_to_hop
        lda #bird_start_hop_animation - bird_base_animations
        sta current_player_animation
        jmp check_for_falling_off_edge

    .bird_is_stationary
        lda current_player_animation
        cmp #bird_stationary_on_floor_animation - bird_base_animations
        beq check_for_change_to_stationary_for_a_while_state
        cmp #bird_stationary_for_a_while_animation - bird_base_animations
        beq check_for_falling_off_edge
    ; bird is staionary on the ground. set a delay before the bird changes to the
    ; 'stationary for a while' state. There seems to be no point in this extra state.
    ; Perhaps there were once idle sprites that were later dropped during development.
        ldy #&40 ; '@'
        sty timeout_while_bird_on_ground_stationary
        ldy #bird_stationary_on_floor_animation - bird_base_animations
        sty current_player_animation
        jmp check_for_falling_off_edge

    .check_for_change_to_stationary_for_a_while_state
        dec timeout_while_bird_on_ground_stationary
        bne check_for_falling_off_edge
        ldy #bird_stationary_for_a_while_animation - bird_base_animations
        sty current_player_animation
    .check_for_falling_off_edge
        ldx #0
        lda player_move_direction_requested
        beq check_for_player_just_fallen_off_edge
        inx
    .check_for_player_just_fallen_off_edge
        lda object_just_fallen_off_edge_direction,x
        beq set_player_animation_step
    ; next animation is falling straight down
        ldy #bird_fall_straight_down_animation - bird_base_animations
        sty current_player_animation
        ldy #bird_animation13 - bird_base_animations
        cmp object_direction
        beq set_player_animation_step
        ldy #bird_animation14 - bird_base_animations
    .set_player_animation_step
        sty object_current_index_in_animation
        tya
        ldx #<bird_base_animations
        ldy #>bird_base_animations
        jsr set_player_spriteid_and_offset_from_animation_table
        lda #objectid_player
        jsr update_object_a_solid_rock_collision
        ; &FF accessory control cycles the wing table; the empty sprite list
        ; below only supplies positional offsets (the wings share the body anchor).
        ; object_left_low/high alias the engine's animation address workspace.
        lda #<bird_wing_animation_table
        sta object_left_low
        lda #>bird_wing_animation_table
        sta object_left_high
        ldx object_current_index_in_animation
        inx
        inx
        inx
        lda bird_base_animations,x
        ldx #<bird_accessory_sprite_list
        ldy #>bird_accessory_sprite_list
        jmp update_player_accessory_object_animation

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
    ; ###     |     ###      ###     |     ###
    ; ###     |     ###      ###     |     ###
    ; ###     |     ###      ###     |     ###
    ; ###     |     ###      ###     |     ###
    ; ###     |     ###      ###     |     ###
    ; ###     |     ###      ###     |     ###
    ; ###OOO  |     ###      ###OOO  |     ###
    ; ######  |     ###      ######  |     ###
    ; ######  |     ###      ######  |  OOO###
    ; ###     |     ###              |  ######
    ; ###     |  ######              |  ######
    ; ###     |  ######              |     ###
    ; ###     |                      |     ###
    ; ###     |                      |     ###
    ;         |                      |     ###
    ;         |                      |     ###
    ;         |                      |     ###
    ;         |                      |     ###
    ;                                      ###
    ; ######              P                ###
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
    ; draw 3x14 rectangle at (0,2)
        ldy #2
        lda #3
        sta width_in_cells
        lda #&0e
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x12 rectangle at (14,2)
        ldx #&0e
        lda #&0c
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x9 rectangle at (23,2)
        ldx #&17
        lda #9
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x20 rectangle at (37,2)
        ldx #&25 ; '%'
        lda #&14
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (3,9)
        ldx #3
        ldy #9
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (11,12)
        ldx #&0b
        ldy #&0c
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (26,9)
        ldx #&1a
        ldy #9
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (34,11)
        ldx #&22 ; '"'
        ldy #&0b
        jsr copy_rectangle_of_memory_to_screen
    ; draw 6x1 rectangle at (0,21)
        ldx #0
        ldy #&15
        lda #6
        sta width_in_cells
        lda #1
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x255 rectangle at (0,22)
        iny
        lda #&ff
        sta width_in_cells
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; carve the floor, walls and ceiling into the rock
        jsr draw_floor_walls_and_ceiling_around_solid_rock
        ldx #3
        ldy #8
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&1a
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&22 ; '"'
        ldy #&0a
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
    ; draw rope at (8,2) length 18
        ldx #8
        ldy #2
        lda #&12
        jsr draw_rope
    ; draw rope at (31,2) length 18
        ldx #&1f
        jsr draw_rope
        jsr start_room
    .room_0_game_update_loop
        jsr game_update
        and #exit_room_left
        beq room_0_game_update_loop
        ldx #1
        ldy current_level
        jmp initialise_level_and_room

    ; Table for the small egg animations. Each step in an animation is three bytes:
    ; (0) spriteid, (1) X offset, (2) Y offset.
    ; Each animation is terminated by an extra zero byte.
    .small_egg_animations
        equb 0
    .small_egg_stationary_animation
        equb spriteid_small_egg_upright
        equb 0
        equb 0
        equb 0
    .small_egg_start_throwing_animation
        equb spriteid_one_pixel_masked_out
        equb 0
        equb 0
        equb spriteid_small_egg_right
        equb &0a
        equb 1
        equb 0
    .small_egg_thrown_right_animation
        equb spriteid_small_egg_right
        equb 8
        equb 0
        equb spriteid_small_egg_down
        equb 8
        equb 0
        equb spriteid_small_egg_down
        equb 8
        equb 0
        equb spriteid_small_egg_left
        equb 8
        equb 0
        equb spriteid_small_egg_left
        equb 8
        equb 0
        equb spriteid_small_egg_upright
        equb 8
        equb 0
        equb spriteid_small_egg_upright
        equb 8
        equb 0
        equb spriteid_small_egg_right
        equb 8
        equb 0
        equb 0
    .small_egg_thrown_left_animation
        equb spriteid_small_egg_right
        equb &fc
        equb 0
        equb spriteid_small_egg_upright
        equb &fe
        equb 2
        equb spriteid_small_egg_upright
        equb &fe
        equb 4
        equb spriteid_small_egg_upright
        equb 0
        equb 6
        equb 0
    .small_egg_falling_animation
        equb spriteid_small_egg_upright
        equb 0
        equb 8
        equb 0

    ; The small egg starts in room 0 but it can move between rooms, either by being carried
    ; by the player or by being thrown. Its position updating is always handled by
    ; room_0_update_handler wherever it is.
    .room_0_update_handler
        lda #0
        sta currently_updating_logic_for_room_index
        ldx #&25 ; '%'
        ldy #&11
        lda #objectid_fire1
        jsr update_brazier_and_fire
    ; check for first update in room (branch if so)
        lda update_room_first_update_flag
        bne room0_first_update
        jmp room0_not_first_update

    .room0_first_update
        lda #spriteid_egg_toolbar
        sta toolbar_collectable_spriteids+1
        lda #spriteid_egg
        sta collectable_spriteids+1
        sta collectable_being_used_spriteids + 1
        ldx #<envelope1
        ldy #>envelope1
        jsr define_envelope
    ; check for level change (branch if not)
        lda current_level
        cmp level_before_latest_level_and_room_initialisation
        beq initialise_small_egg
        lda save_game_level_e_small_egg_status
        bmi initialise_small_egg                                          ; branch if have collected egg
        lda #0
        sta room_containing_small_egg
        lda #1
        sta thrown_egg_direction
        lda #&da
        sta thrown_egg_x_low
        lda #0
        sta thrown_egg_x_high
        lda #&3a ; ':'
        sta thrown_egg_y_low
        lda #small_egg_stationary_animation - small_egg_animations
        sta save_game_level_e_small_egg_status
        sta small_egg_animation_step
        lda #0
        sta level_workspace_small_egg_offscreen_time
    .initialise_small_egg
        lda #spriteid_erase_small_egg
        sta object_erase_type + objectid_small_egg
        lda #&c0
        sta object_z_order + objectid_small_egg
        lda desired_room_index
        cmp room_containing_small_egg
        bne skip_small_egg_setup
        lda save_game_level_e_small_egg_status
        bmi skip_small_egg_setup                                          ; branch if have collected egg
        jsr update_object_properties_for_small_egg
        ldy small_egg_animation_step
        lda small_egg_animations,y
        sta object_spriteid + objectid_small_egg
    ; Update the egg position repeatedly (without updating the screen) to catch up on any
    ; missed animation between it being thrown off screen and now when we are going to see
    ; it again. Note that small_egg_animation_update will set the offscreen time to 0 if
    ; there is nothing else to do, so this loop doesn't do unnecessary work.
    .small_egg_animation_catch_up_loop
        lda desired_room_index
        cmp room_containing_small_egg
        bne skip_small_egg_setup
        lda level_workspace_small_egg_offscreen_time
        beq skip_small_egg_setup
        dec level_workspace_small_egg_offscreen_time
        ldx #objectid_small_egg
        jsr copy_object_state_to_old
        jsr small_egg_animation_update
        jmp small_egg_animation_catch_up_loop

    .skip_small_egg_setup
        lda #spriteid_one_pixel_masked_out
        sta object_spriteid_old + objectid_small_egg
        jmp return2

    .room0_not_first_update
        lda #0
        sta player_just_used_small_egg_flag
        lda player_held_object_spriteid
        sta remember_object_held_sprite
        lda object_spriteid_old + objectid_small_egg
        sta remember_small_egg_sprite
        lda save_game_level_e_small_egg_status
        bmi have_small_egg                                                ; branch if have collected egg
        lda desired_room_index
        cmp room_containing_small_egg
        beq small_egg_in_room
    ; The egg is off screen for this update, so increment the offscreen time (capping at
    ; &880 so its position can be correctly updated when it next appears on screen.
        lda level_workspace_small_egg_offscreen_time
        bmi return2_local
        inc level_workspace_small_egg_offscreen_time
    .return2_local
        jmp return2

    .have_small_egg
        lda #spriteid_egg_toolbar
        cmp player_using_object_spriteid
        bne return2_local
        cmp previous_player_using_object_spriteid
        beq return2_local
        dec player_just_used_small_egg_flag
        lda desired_room_index
        sta room_containing_small_egg
        lda object_direction
        sta thrown_egg_direction
        lda object_x_low + objectid_player_accessory
        sta thrown_egg_x_low
        lda object_x_high + objectid_player_accessory
        sta thrown_egg_x_high
        lda object_y_low + objectid_player_accessory
        sta thrown_egg_y_low
        lda #small_egg_thrown_right_animation - small_egg_animations
        sta save_game_level_e_small_egg_status
        lda #small_egg_start_throwing_animation - small_egg_animations
        sta small_egg_animation_step
        jsr update_object_properties_for_small_egg
        lda object_spriteid + objectid_player_accessory
        sta object_spriteid + objectid_small_egg
        ldx #objectid_small_egg
        jsr copy_object_state_to_old
        lda #0
        sta player_held_object_spriteid
    .small_egg_in_room
        jsr small_egg_animation_update
        lda desired_room_index
        cmp room_containing_small_egg
        beq restore_small_egg_sprite_and_test_for_collision_with_player
        lda #0
        sta level_workspace_small_egg_offscreen_time
    .restore_small_egg_sprite_and_test_for_collision_with_player
        lda remember_small_egg_sprite
        sta object_spriteid_old + objectid_small_egg
        ldx #objectid_old_player
        ldy #objectid_small_egg
        jsr test_for_collision_between_objects_x_and_y
        ldx remember_object_held_sprite
        stx player_held_object_spriteid
        ora #0
        beq update_small_egg_sounds_and_check_if_just_used_egg
        lda player_just_used_small_egg_flag
        bne take_small_egg
    ; add small egg to toolbar
        lda #spriteid_egg_toolbar
        jsr find_or_create_menu_slot_for_A
    .take_small_egg
        lda #spriteid_one_pixel_masked_out
        sta object_spriteid + objectid_small_egg
        lda #small_egg_status_collected
        sta save_game_level_e_small_egg_status
        jmp return2

    .update_small_egg_sounds_and_check_if_just_used_egg
        jsr update_small_egg_collision_sounds
        lda player_just_used_small_egg_flag
        beq return2
        lda #spriteid_egg_toolbar
        jsr remove_item_from_toolbar_menu
        lda #spriteid_one_pixel_masked_out
        sta object_spriteid + objectid_player_accessory
        sta player_using_object_spriteid
        sta player_held_object_spriteid
    .return2
        rts

    .small_egg_animation_update
        lda small_egg_animation_step
        clc
        adc #3
        tay
        lda small_egg_animations,y
        bne got_small_egg_animation_step_in_y
        ldy save_game_level_e_small_egg_status
    .got_small_egg_animation_step_in_y
        lda save_game_level_e_small_egg_status
        cmp #small_egg_thrown_right_animation - small_egg_animations
        bne small_egg_not_being_thrown
        lda thrown_egg_direction
        bmi small_egg_thrown_left
        inc temp_right_offset
        bne small_egg_temp_left_right_offset_set                          ; ALWAYS branch
    .small_egg_thrown_left
        dec temp_left_offset
    .small_egg_temp_left_right_offset_set
        lda #1
        sta temp_bottom_offset
        lda #objectid_small_egg
        jsr get_solid_rock_collision_for_object_a
        beq set_small_egg_animation_step
        lda #small_egg_falling_animation - small_egg_animations
        sta save_game_level_e_small_egg_status
        ldy #small_egg_thrown_left_animation - small_egg_animations
        jmp set_small_egg_animation_step

    .small_egg_not_being_thrown
        cmp #small_egg_falling_animation - small_egg_animations
        bne small_egg_not_falling
        lda #objectid_small_egg
        sta temp_bottom_offset
        lda #objectid_small_egg                                           ; redundant instruction
        jsr get_solid_rock_collision_for_object_a
        beq set_small_egg_animation_step                                  ; branch if not collided with anything
        ldy #small_egg_stationary_animation - small_egg_animations
        sty save_game_level_e_small_egg_status
    .small_egg_not_falling
        lda #0
        sta level_workspace_small_egg_offscreen_time
    .set_small_egg_animation_step
        sty small_egg_animation_step
        lda small_egg_animations,y
        sta object_spriteid + objectid_small_egg
    ; get the X offset from the animation table
        iny
        lda small_egg_animations,y
        ldx thrown_egg_direction
        bpl egg_thrown_to_right
    ; the egg has been thrown left, so negate the X offset from the animation table
        eor #&ff
        clc
        adc #1
    ; Set X to the high byte of the X offset
    .egg_thrown_to_right
        ldx #0
        ora #0                                                            ; set flags based on A
        bpl adding_positive_value_to_x
        dex
    ; Add 16-bit offset in XA to thrown_egg_x.
    .adding_positive_value_to_x
        clc
        adc thrown_egg_x_low
        sta thrown_egg_x_low
        txa
        adc thrown_egg_x_high
        sta thrown_egg_x_high
    ; Get the Y offset from the animation table and add it to thrown_egg_y_low. This is an
    ; 8-bit value so no need to mess around with high byte.
        iny
        lda small_egg_animations,y
        clc
        adc thrown_egg_y_low
        sta thrown_egg_y_low
        jsr update_object_properties_for_small_egg
        lda #objectid_small_egg
        jsr update_object_a_solid_rock_collision
        lda object_x_low + objectid_small_egg
        sta thrown_egg_x_low
        lda object_x_high + objectid_small_egg
        sta thrown_egg_x_high
        lda object_y_low + objectid_small_egg
        sta thrown_egg_y_low
        lda save_game_level_e_small_egg_status
        cmp #small_egg_thrown_right_animation - small_egg_animations
        bne return3
        ldx #objectid_small_egg
        jsr find_left_and_right_of_object
        lda thrown_egg_direction
        bmi check_and_move_small_egg_one_room_right
    ; check and move small egg one room left
        lda object_left_cell_x
        cmp #game_area_width_cells
        bcc return3
        lda thrown_egg_x_low
        sec
        sbc #&40 ; '@'
        sta thrown_egg_x_low
        lda #0
        sbc #0
        sta thrown_egg_x_high
        dec room_containing_small_egg
        jmp hide_small_egg

    .check_and_move_small_egg_one_room_right
        lda object_right_cell_x
        bpl return3
        lda thrown_egg_x_low
        clc
        adc #&40 ; '@'
        sta thrown_egg_x_low
        lda #1
        sta thrown_egg_x_high
        inc room_containing_small_egg
    .hide_small_egg
        lda #spriteid_one_pixel_masked_out
        sta object_spriteid + objectid_small_egg
    .return3
        rts

    .update_object_properties_for_small_egg
        lda thrown_egg_x_low
        sta object_x_low + objectid_small_egg
        lda thrown_egg_x_high
        sta object_x_high + objectid_small_egg
        lda thrown_egg_y_low
        sta object_y_low + objectid_small_egg
        lda #0
        sta object_y_high + objectid_small_egg
        lda thrown_egg_direction
        sta object_direction + objectid_small_egg
        rts

    .update_small_egg_collision_sounds
        lda desired_room_index
        cmp room_containing_small_egg
        bne return4
        lda #2
        sta temp_bottom_offset
        lda #objectid_small_egg
        jsr get_solid_rock_collision_for_object_a
        beq check_for_delta_x_in_small_egg_movement
        lda object_y_low + objectid_small_egg
        cmp object_y_low_old + objectid_small_egg
        beq check_for_delta_x_in_small_egg_movement
        jsr play_landing_sound
    .check_for_delta_x_in_small_egg_movement
        lda object_x_low + objectid_small_egg
        sec
        sbc object_x_low_old + objectid_small_egg
        beq return4
        lda object_x_high + objectid_small_egg
        sbc object_x_high_old + objectid_small_egg
        bpl small_egg_moving_right
        dec temp_left_offset
        jmp test_for_small_egg_collision_with_rock_and_play_sound

    .small_egg_moving_right
        inc temp_right_offset
    .test_for_small_egg_collision_with_rock_and_play_sound
        lda #1
        sta temp_bottom_offset
        lda #objectid_small_egg
        jsr get_solid_rock_collision_for_object_a
        beq return4
        lda #0
        ldx #<sound1
        ldy #>sound1
        jsr play_sound_yx
    .return4
        rts

    .player_just_used_small_egg_flag
        equb 0
    .remember_object_held_sprite
        equb 0
    .remember_small_egg_sprite
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
    ;                        ###     |     ###
    ;                        ###     |     ###
    ;                        ###     |     ###
    ;                        ###     |     ###
    ;                     OOO###     |     ###
    ; #############################  |     ###
    ; #############################  |     ###
    ; ###                            |     ###
    ; ###                            |     ###
    ; ###                            |     ###
    ; ###                            |     ###
    ; ###          OOO               |  OOO###
    ;              ###               |  ######
    ;              ###               |  ######
    ;                                |
    ;                                |
    ;                                |
    ; ######                         |
    ; ######
    ; ######              P             ######
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
    ; draw 3x5 rectangle at (23,2)
        ldx #&17
        ldy #2
        lda #3
        sta width_in_cells
        lda #5
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x12 rectangle at (37,2)
        ldx #&25 ; '%'
        lda #&0c
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 29x2 rectangle at (0,7)
        ldx #0
        ldy #7
        lda #&1d
        sta width_in_cells
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 29x2 rectangle at (34,14)
        ldx #&22 ; '"'
        ldy #&0e
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x5 rectangle at (0,9)
        ldx #0
        ldy #9
        lda #3
        sta width_in_cells
        lda #5
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 3x2 rectangle at (13,14)
        ldx #&0d
        ldy #&0e
        lda #3
        sta width_in_cells
        lda #2
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 6x3 rectangle at (0,19)
        ldx #0
        ldy #&13
        lda #6
        sta width_in_cells
        lda #3
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x3 rectangle at (0,22)
        ldy #&16
        lda #&ff
        sta width_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; draw 255x1 rectangle at (34,21)
        ldx #&22 ; '"'
        dey
        lda #1
        sta height_in_cells
        jsr copy_rectangle_of_memory_to_screen
    ; carve the floor, walls and ceiling into the rock
        jsr draw_floor_walls_and_ceiling_around_solid_rock
        ldx #&0d
        ldy #&0d
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&14
        ldy #6
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
        ldx #&22 ; '"'
        ldy #&0d
        jsr draw_sprite_nest_at_cell_xy_and_write_to_collision_map
    ; draw rope at (31,2) length 18
        ldx #&1f
        ldy #2
        lda #&12
        jsr draw_rope
        jsr start_room
    .room_1_game_update_loop
        jsr game_update
        sta room_exit_direction
        and #exit_room_left
        beq room_1_check_right_exit
        ldx #2
        ldy current_level
        jmp initialise_level_and_room

    .room_1_check_right_exit
        lda room_exit_direction
        and #exit_room_right
        beq room_1_game_update_loop
        ldx #0
        ldy current_level
        jmp initialise_level_and_room

    ; Table of animations for the big egg. There are three bytes per entry. First byte is a
    ; sprite ID. Second and third bytes of each entry are signed (X,Y) position offsets,
    ; added to the egg position. Each animation is terminated with an extra zero byte.
    .egg_animations_table
        equb 0

    .egg_normal_animation
        equb spriteid_large_egg_upright
        equb 0
        equb 0
        equb 0                                                            ; terminator

    .egg_tilted_animation
        equb spriteid_large_egg_tilted
        equb 0
        equb 0
        equb 0                                                            ; terminator

    .egg_falling_off_animation
        equb spriteid_large_egg_tilted
        equb &f8
        equb 0
        equb spriteid_large_egg_sideways
        equb &f8
        equb 8
        equb spriteid_large_egg_sideways
        equb &fc
        equb 4
        equb spriteid_large_egg_sideways
        equb &fc
        equb 4
        equb 0                                                            ; terminator

    .egg_falling_straight_down_animation
        equb spriteid_large_egg_sideways
        equb 0
        equb 8
        equb 0                                                            ; terminator

    .egg_stationary_animation
        equb spriteid_large_egg_sideways
        equb 0
        equb 0
        equb 0                                                            ; terminator

    ; check for first update in room (branch if not)
    .room_1_update_handler
        lda update_room_first_update_flag
        beq room_1_not_first_update
    ; check for level change (branch if not)
        lda current_level
        cmp level_before_latest_level_and_room_initialisation
        beq room_1_not_this_room1
        ldx #&70 ; 'p'
        ldy #&58 ; 'X'
        lda save_game_level_e_big_egg_animation_index
        cmp #egg_normal_animation - egg_animations_table
        beq room_1_set_egg_animation_and_position
        cmp #egg_tilted_animation - egg_animations_table
        beq room_1_set_egg_animation_and_position
        ora #0                                                            ; set flags based on A
        bne egg_on_floor
        lda #egg_normal_animation - egg_animations_table
        jmp room_1_set_egg_animation_and_position

    .egg_on_floor
        ldx #&58 ; 'X'
        ldy #&a8
        lda #egg_stationary_animation - egg_animations_table
    .room_1_set_egg_animation_and_position
        sta save_game_level_e_big_egg_animation_index
        sta egg_animation_index
        stx room_1_egg_x
        sty room_1_egg_y
    .room_1_not_this_room1
        lda desired_room_index
        cmp #1
        bne room_1_not_this_room2
        ldx #<envelope2
        ldy #>envelope2
        jsr define_envelope
        lda #spriteid_erase_large_egg
        sta object_erase_type + objectid_egg
        lda #0
        sta object_x_high + objectid_egg
        sta object_y_high + objectid_egg
    .room_1_not_this_room2
        jmp finish_setting_up_egg

    .room_1_not_first_update
        lda egg_animation_index
        clc
        adc #3
        tay
        lda egg_animations_table,y
        bne not_end_of_egg_animation_sequence
        ldy save_game_level_e_big_egg_animation_index
    .not_end_of_egg_animation_sequence
        lda save_game_level_e_big_egg_animation_index
        cmp #egg_normal_animation - egg_animations_table
        bne check_if_egg_is_tilted
        jsr test_if_small_egg_hit_large_egg
        beq new_egg_animation_index_in_y
        ldy #egg_tilted_animation - egg_animations_table
        sty save_game_level_e_big_egg_animation_index
        jmp new_egg_animation_index_in_y

    .check_if_egg_is_tilted
        cmp #egg_tilted_animation - egg_animations_table
        bne check_if_egg_is_falling_straight_down
        jsr test_if_small_egg_hit_large_egg
        beq new_egg_animation_index_in_y
        lda desired_room_index
        cmp #1
        bne room_1_not_this_room3
        lda #collision_map_none
        sta value_to_write_to_collision_map
        ldx #&0e
        ldy #&0b
        lda #1
        sta width_in_cells
        lda #2
        sta height_in_cells
        jsr write_value_to_a_rectangle_of_cells_in_collision_map
    .room_1_not_this_room3
        lda #egg_falling_straight_down_animation - egg_animations_table
        sta save_game_level_e_big_egg_animation_index
        ldy #egg_falling_off_animation - egg_animations_table
        jmp new_egg_animation_index_in_y

    .check_if_egg_is_falling_straight_down
        cmp #egg_falling_straight_down_animation - egg_animations_table
        bne new_egg_animation_index_in_y
        lda room_1_egg_y
        cmp #&a0
        bcc new_egg_animation_index_in_y
        bne set_egg_stationary
        lda desired_room_index
        cmp #1
        bne new_egg_animation_index_in_y
        lda #0
        ldx #<sound2
        ldy #>sound2
        jsr play_sound_yx
        ldx #<sound3
        ldy #>sound3
        jsr play_sound_yx
        ldy #egg_falling_straight_down_animation - egg_animations_table
        jmp new_egg_animation_index_in_y

    .set_egg_stationary
        ldy #egg_stationary_animation - egg_animations_table
        sty save_game_level_e_big_egg_animation_index
    .new_egg_animation_index_in_y
        sty egg_animation_index
        iny
    ; add animation x offset to egg x position
        lda egg_animations_table,y
        clc
        adc room_1_egg_x
        sta room_1_egg_x
    ; add animation y offset to egg y position
        iny
        lda egg_animations_table,y
        clc
        adc room_1_egg_y
        sta room_1_egg_y
    .finish_setting_up_egg
        lda desired_room_index
        cmp #1
        bne return5
        ldy egg_animation_index
        lda egg_animations_table,y
        sta object_spriteid + objectid_egg
        lda room_1_egg_x
        sta object_x_low + objectid_egg
        lda room_1_egg_y
        sta object_y_low + objectid_egg
        lda #collision_map_solid_rock
        sta value_to_write_to_collision_map
        ldx #&0e
        ldy #&0b
        lda #1
        sta width_in_cells
        lda #2
        sta height_in_cells
        lda save_game_level_e_big_egg_animation_index
        cmp #egg_normal_animation - egg_animations_table
        beq write_egg_to_collision_map
        cmp #egg_tilted_animation - egg_animations_table
        beq write_egg_to_collision_map
        ldx #&0b
        ldy #&15
        inc width_in_cells
        dec height_in_cells
        lda room_1_egg_y
        cmp #&a8
        bcc return5
    .write_egg_to_collision_map
        jsr read_collision_map_value_for_xy
        cmp value_to_write_to_collision_map
        beq return5
        jsr write_value_to_a_rectangle_of_cells_in_collision_map
    .return5
        rts

    ; Preserves Y. A is $ff on exit if small egg has hit large egg, 0 otherwise. Flags
    ; reflect A on exit.
    .test_if_small_egg_hit_large_egg
        lda #0
        sta return_a
        lda room_containing_small_egg
        cmp #1
        bne load_a_and_return
    ; Why not lda object_spriteid+2? And similarly for following lda abs,x
        ldx #objectid_small_egg
        lda object_spriteid,x
        beq load_a_and_return
        lda object_x_high,x
        bne load_a_and_return
        lda object_y_low,x
        cmp #&70 ; 'p'
        bcs load_a_and_return
        sty saved_y
        jsr find_left_and_right_of_object
        ldy saved_y
        lda object_left_low
        cmp #&78 ; 'x'
        bne load_a_and_return
        dec return_a
    .load_a_and_return
        lda return_a
        rts

    .return_a
        equb 0
    .saved_y
        equb 0

    .envelope1
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
    .sound1
        equw &0013                                                        ; channel
        equw 5                                                            ; amplitude
        equw 201                                                          ; pitch
        equw 1                                                            ; duration
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
    .sound3
        equw &0010                                                        ; channel
        equw 6                                                            ; amplitude
        equw 7                                                            ; pitch
        equw 1                                                            ; duration
    .sound2
        equw &0011                                                        ; channel
        equw 0                                                            ; amplitude
        equw 210                                                          ; pitch
        equw 1                                                            ; duration

    .ground_fill_2x2_top_left
        equb %00100000
        equb %00010000
        equb %10010000
        equb %01100001
        equb %00000010
        equb %00000010
        equb %00001100
        equb %00010000
    .ground_fill_2x2_top_right
        equb %00000100
        equb %00001000
        equb %00001001
        equb %10000110
        equb %01000000
        equb %01000000
        equb %00110000
        equb %00001000
    .ground_fill_2x2_bottom_left
        equb %00010000
        equb %00001100
        equb %00000010
        equb %00000010
        equb %01100001
        equb %10010000
        equb %00010000
        equb %00100000
    .ground_fill_2x2_bottom_right
        equb %00001000
        equb %00110000
        equb %01000000
        equb %01000000
        equb %10000110
        equb %00001001
        equb %00001000
        equb %00000100
    .sprite_data
IF swr_renderer_enabled = 0
IF swr_measurement = 0
    INCBIN "build/levelE"
ENDIF
ENDIF
}
IF swr_renderer_enabled
INCLUDE "build/runtime/levelE_runtime.asm"
INCLUDE "build/swr_assets/includes/levelE.asm"
ENDIF
.levelE_end

save "build/dataE", levelE, levelE_end
