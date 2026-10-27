; *************************************************************************************
;
; Level O: 'DOWN-AND-OUT'
;
; Save game variables:
;
;     save_game_level_o_bowl_progress                            ($0a55):
;              $0: untouched
;              $1: stationary
;             $2+: animating
;             $ff: taken
;
;     save_game_level_o_bowl_animation_step                      ($0a56):
;             current step within bowl animations above
;
;     save_game_level_o_bowl_x_low                               ($0a57):
;     save_game_level_o_bowl_x_high                              ($0a58):
;     save_game_level_o_bowl_y                                   ($0a59):
;             position of bowl in level
;
;     save_game_level_o_bowl_direction_without_bounces           ($0a5a):
;             direction the bowl was thrown in
;
;     save_game_level_o_bowl_room                                ($0a5b):
;             which room the bowl is in
;
;     save_game_level_o_bowl_direction_with_bounces              ($0a5c):
;             direction of bowl including any bounces off walls
;
;     save_game_level_o_bowl_is_full_flag                        ($0a5d):
;              $0: empty
;             $ff: full (of TNT)
;
;     save_game_level_o_trapdoor_y                               ($0a5e):
;             Y coordinate of trapdoor
;
;     save_game_level_o_tnt_barrel_animation_step                ($0a5f):
;              $0: untouched
;              $1: falling
;              $2: fallen over
;
;     save_game_level_o_holding_stick                            ($0a60):
;              $0: not holding stick
;             $ff: holding stick
;
;     save_game_level_o_trapdoor_open_flag                       ($0a61):
;              $0: closed
;             $ff: open
;
; Solution:
;
;   1. Move into the room to the left, and get the bowl (bottom left of the screen)
;   2. Move back to the start room and climb the rope, dropping down the other side and collecting the stick.
;   3. In the room to the right, jump into the side of the barrel to tip it over.
;   4. Drop the bowl onto the spilled TNT to fill the bowl. Recollect the bowl.
;   5. Retrace your steps back to the room left of the start. Climb the rope and proceed into the leftmost room.
;   6. Drop the full bowl onto the trapdoor. Use the stick in the fire bowl (in the room to the right) to light the taper.
;   7. Use the stick on the bowl to explode the trapdoor and go 'down and out' to the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
inkey_key_l                           = 169
inkey_key_o                           = 201
objectid_bowl                         = 2
objectid_explosion                    = 6
objectid_fire                         = 3
objectid_fire_bowl                    = 4
objectid_smoke                        = 5
objectid_sparkles                     = 3
objectid_stick                        = 4
objectid_tnt                          = 4
objectid_tnt_barrel                   = 3
objectid_trapdoor                     = 4
spriteid_bowl                         = 200
spriteid_bowl_menu_item               = 202
spriteid_erase1                       = 204
spriteid_erase2                       = 207
spriteid_erase3                       = 216
spriteid_erase4a                      = 218
spriteid_erase4b                      = 219
spriteid_explosion                    = 217
spriteid_fire_bowl                    = 228
spriteid_full_bowl                    = 201
spriteid_full_bowl_menu_item          = 203
spriteid_smoke1                       = 220
spriteid_smoke2                       = 221
spriteid_smoke3                       = 222
spriteid_smoke4                       = 223
spriteid_smoke5                       = 224
spriteid_smoke6                       = 225
spriteid_smoke7                       = 226
spriteid_smoke8                       = 227
spriteid_stick                        = 213
spriteid_stick_held                   = 214
spriteid_stick_menu_item              = 212
spriteid_stick_using                  = 215
spriteid_table                        = 205
spriteid_tnt                          = 208
spriteid_tnt_powder                   = 211
spriteid_tnt_sideways                 = 210
spriteid_tnt_tipping                  = 209
spriteid_trapdoor                     = 206

; Memory locations
room_exit_direction                                 = &0070
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
save_game_level_o_bowl_progress                     = &0a55
save_game_level_o_bowl_animation_step               = &0a56
save_game_level_o_bowl_x_low                        = &0a57
save_game_level_o_bowl_x_high                       = &0a58
save_game_level_o_bowl_y                            = &0a59
save_game_level_o_bowl_direction_without_bounces    = &0a5a
save_game_level_o_bowl_room                         = &0a5b
save_game_level_o_bowl_direction_with_bounces       = &0a5c
save_game_level_o_bowl_is_full_flag                 = &0a5d
save_game_level_o_trapdoor_y                        = &0a5e
save_game_level_o_tnt_barrel_animation_step         = &0a5f
save_game_level_o_holding_stick                     = &0a60
save_game_level_o_trapdoor_open_flag                = &0a61
fast_forward_bowl_step_count                        = &0a6f
fire_bowl_animation_step                            = &0a70
explosion_animation_step                            = &0a71

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelO_sprite_table - level_data
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
    encode "DOWN-AND-OUT", &0D

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
    beq set_rock_tiles
    lda developer_flags
    bpl developer_mode_inactive1
    lda #&ff
    sta save_game_level_o_bowl_progress
    sta save_game_level_o_bowl_is_full_flag
    sta save_game_level_o_holding_stick
; set up menu slot for bowl (empty or full)
.developer_mode_inactive1
    lda save_game_level_o_bowl_progress
    cmp #&ff
    bne set_up_stick_menu_item_if_stick_is_held
    lda #spriteid_bowl_menu_item
    ldx save_game_level_o_bowl_is_full_flag
    beq set_menu_slot
    lda #spriteid_full_bowl_menu_item
.set_menu_slot
    jsr find_or_create_menu_slot_for_A
.set_up_stick_menu_item_if_stick_is_held
    lda save_game_level_o_holding_stick
    beq set_rock_tiles
    lda #spriteid_stick_menu_item
    jsr find_or_create_menu_slot_for_A
.set_rock_tiles
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
    jsr room_3_update_handler
    jsr update_fire_bowl
    jsr room_2_update_handler
    rts

; *************************************************************************************
; 
; Room 0 initialisation and game loop
; 
; *************************************************************************************
.room_0_data
    equb 30                                                           ; initial player X cell
    equb 14                                                           ; initial player Y cell

; ########################################
; ########################################
; ###            ###                   ###
; ###            ###                   ###
; ###            ###                   ###
; ###            ###                   ###
; ###            #########################
; ###            #########################
; ###            ###
; ###            ###
; ###            ###
; ###            ###
; ###            ###
; ###            ###            P      ###
; ##################    ##################
; ##################    ##################
; ###                   ###            ###
; ###                   ###            ###
; ###                   ###            ###
; ###                   ###            ###
; ###OOO                ###            ###
; ###OOO                ###            ###
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
; draw 3x14 rectangle at (15,2)
    ldx #&0f
    lda #&0e
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (22,14)
    ldx #&16
    ldy #&0e
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (37,13)
    ldx #&25 ; '%'
    dey
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (37,2)
    ldy #2
    lda #6
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (3,14)
    ldx #3
    ldy #&0e
    lda #&0c
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (25,14)
    ldx #&19
    jsr copy_rectangle_of_memory_to_screen
; draw 19x2 rectangle at (18,6)
    ldx #&12
    ldy #6
    lda #&13
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (3,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #3
    ldy #&14
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
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
    ldx #4
    stx temp_sprite_x_offset
    ldy #&14
    lda #3
    jsr update_level_completion
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_trapdoor
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_trapdoor
; initialise trapdoor for new level
    lda save_game_level_o_trapdoor_y
    cmp #&71 ; 'q'
    bcs initialise_trapdoor_down
    lda save_game_level_o_trapdoor_open_flag
    bne initialise_trapdoor_down
    lda #&70 ; 'p'
    sta save_game_level_o_trapdoor_y
    bne initialise_trapdoor
.initialise_trapdoor_down
    lda #&a8
    sta save_game_level_o_trapdoor_y
.initialise_trapdoor
    lda desired_room_index
    cmp #0
    bne update_trapdoor_collision_map_local
    lda #&90
    sta object_x_low + objectid_trapdoor
    lda #spriteid_trapdoor
    sta object_spriteid + objectid_trapdoor
    lda #spriteid_erase2
    sta object_erase_type + objectid_trapdoor
.update_trapdoor_collision_map_local
    jmp update_trapdoor_collision_map

.update_trapdoor
    lda save_game_level_o_trapdoor_y
    cmp #&a8
    beq update_trapdoor_collision_map
    cmp #&70 ; 'p'
    bne update_trapdoor_y_position
    lda desired_room_index
    cmp #0
    bne update_trapdoor_collision_map
    lda developer_flags
    bpl developer_mode_inactive2
; pressing 'O' in developer mode opens the trapdoor
    ldx #inkey_key_o
    jsr negative_inkey
    bne update_trapdoor_y_position
.developer_mode_inactive2
    lda explosion_animation_step
    cmp #2
    bne update_trapdoor_collision_map
    lda save_game_level_o_trapdoor_open_flag
    beq update_trapdoor_collision_map
.update_trapdoor_y_position
    lda save_game_level_o_trapdoor_y
    clc
    adc #8
    sta save_game_level_o_trapdoor_y
    cmp #&a8
    bcc update_trapdoor_collision_map
    lda #&a8                                                          ; redundant instruction
    lda desired_room_index
    cmp #0                                                            ; redundant instruction
    bne update_trapdoor_collision_map
    jsr play_explosion_or_barrel_overturning_sound
.update_trapdoor_collision_map
    lda desired_room_index
    cmp #0
    bne return1
    lda save_game_level_o_trapdoor_y
    sta object_y_low + objectid_trapdoor
    ldx #&12
    lsr a
    lsr a
    lsr a
    tay
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda save_game_level_o_trapdoor_y
    cmp #&70 ; 'p'
    beq set_collision_map_for_trapdoor
    cmp #&a8
    beq set_collision_map_for_trapdoor
    ldy #&0e
    lda #collision_map_none
    sta value_to_write_to_collision_map
.set_collision_map_for_trapdoor
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return1
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return1
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
; ###                |             |   ###
; ###                |             |   ###
; ###                |             |   ###
; ###                |             |   ###
; ###                |             |   ###
; ###                |             |   ###
;                    |   #######   |   ###
;                    |   #######   |   ###
;                    |       ###   |   ###
;                    |       ###   |   ###
;                            ###   |   ###
; ###                        ###   |   ###
; ##############################   |   ###
; ##############################   |   ###
; ###                              |
; ###                              |
; ###                              |
; ###                              |
; ###OOO
; ###OOO              P                ###
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
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #6
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (0,13)
    ldy #&0d
    lda #9
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x14 rectangle at (37,2)
    ldx #&25 ; '%'
    ldy #2
    lda #&0e
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (37,21)
    ldy #&15
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 24x2 rectangle at (3,14)
    ldx #3
    ldy #&0e
    lda #&18
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (23,8)
    ldx #&17
    ldy #8
    lda #4
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (27,8)
    ldx #&1b
    lda #3
    sta width_in_cells
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (3,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #3
    ldy #&14
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (19,2) length 10
    ldx #&13
    ldy #2
    lda #&0a
    jsr draw_rope
; draw rope at (33,2) length 18
    ldx #&21 ; '!'
    lda #&12
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

.bowl_animations
    equb 0
.bowl_fall_sideways_animation
    equb 0, 0
    equb 7, 1
    equb 6, 2
    equb 4, 4
    equb 2, 6
    equb &80
.bowl_fall_off_edge_animation
    equb 4, 1
    equb 3, 2
    equb 2, 4
    equb 1, 6
    equb &80
.bowl_fall_straight_down_animation
    equb 0, 1
    equb 0, 2
    equb 0, 4
    equb 0, 6
    equb &80
.bowl_fall_down_fast_animation
    equb 0, 8
    equb &80
.bowl_stationary_animation
    equb 0, 0
    equb &80

.room_1_update_handler
    lda #1
    sta currently_updating_logic_for_room_index
    ldx #3
    ldy #5
    lda #objectid_fire
    jsr update_brazier_and_fire
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne initialise_room_1
    jmp room_1_not_first_update

.initialise_room_1
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    lda #spriteid_bowl_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_bowl
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
    lda #spriteid_full_bowl_menu_item
    sta toolbar_collectable_spriteids+2
    lda #spriteid_full_bowl
    sta collectable_spriteids+2
    sta collectable_being_used_spriteids + 2
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_bowl_object_if_in_current_room
    lda save_game_level_o_bowl_progress
    beq initialise_bowl
    bmi initialise_bowl_object_if_in_current_room
    dec fast_forward_bowl_step_count
    jmp initialise_bowl_object_if_in_current_room

.initialise_bowl
    lda #&1e
    sta save_game_level_o_bowl_x_low
    lda #0
    sta save_game_level_o_bowl_x_high
    lda #1
    sta save_game_level_o_bowl_direction_without_bounces
    sta save_game_level_o_bowl_direction_with_bounces
    lda #&9b
    sta save_game_level_o_bowl_y
    lda #1
    sta save_game_level_o_bowl_room
    lda #bowl_stationary_animation - bowl_animations
    sta save_game_level_o_bowl_progress
    sta save_game_level_o_bowl_animation_step
.initialise_bowl_object_if_in_current_room
    lda desired_room_index
    cmp save_game_level_o_bowl_room
    bne hide_bowl1
    lda save_game_level_o_bowl_progress
    bmi hide_bowl1
    jsr set_bowl_object
.fast_forward_bowl_loop
    lda desired_room_index
    cmp save_game_level_o_bowl_room
    bne hide_bowl1
    lda fast_forward_bowl_step_count
    beq hide_bowl1
    dec fast_forward_bowl_step_count
    ldx #objectid_bowl
    jsr copy_object_state_to_old
    jsr update_bowl_step
    jmp fast_forward_bowl_loop

.hide_bowl1
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_bowl
.return2_local
    jmp return2

.room_1_not_first_update
    lda #0
    sta just_started_using_bowl_flag
    lda player_held_object_spriteid
    sta remember_sprite_held
    lda object_spriteid_old + objectid_bowl
    sta temp_old_bowl_sprite
    lda save_game_level_o_bowl_progress
    bmi check_for_player_using_bowl
    lda desired_room_index
    cmp save_game_level_o_bowl_room
    beq regular_bowl_update
    lda fast_forward_bowl_step_count
    bmi return2_local
    inc fast_forward_bowl_step_count
    jmp return2

.check_for_player_using_bowl
    lda player_using_object_spriteid
    cmp #spriteid_bowl_menu_item
    beq using_a_bowl
    cmp #spriteid_full_bowl_menu_item
    bne return2_local
.using_a_bowl
    cmp previous_player_using_object_spriteid
    beq return2_local
; just started using the bowl
    dec just_started_using_bowl_flag
; drop bowl
    lda desired_room_index
    sta save_game_level_o_bowl_room
    lda object_direction
    sta save_game_level_o_bowl_direction_without_bounces
    sta save_game_level_o_bowl_direction_with_bounces
    lda object_x_low + objectid_player_accessory
    sta save_game_level_o_bowl_x_low
    lda object_x_high + objectid_player_accessory
    sta save_game_level_o_bowl_x_high
    lda object_y_low + objectid_player_accessory
    sta save_game_level_o_bowl_y
; start by dropping bowl sideways...
    lda #bowl_fall_sideways_animation - bowl_animations
    sta save_game_level_o_bowl_animation_step
; ...then drop bowl straight down
    lda #bowl_fall_down_fast_animation - bowl_animations
    sta save_game_level_o_bowl_progress
    jsr set_bowl_object
    ldx #objectid_bowl
    jsr copy_object_state_to_old
    lda #0
    sta player_held_object_spriteid
.regular_bowl_update
    jsr update_bowl_step
    lda desired_room_index
    cmp save_game_level_o_bowl_room
    beq skip_resetting_fast_forward_for_bowl
    lda #0
    sta fast_forward_bowl_step_count
.skip_resetting_fast_forward_for_bowl
    lda temp_old_bowl_sprite
    sta object_spriteid_old + objectid_bowl
    lda player_held_object_spriteid
    cmp #spriteid_stick_menu_item
    bne check_for_player_bowl_collision
    lda #spriteid_one_pixel_masked_out
    sta player_held_object_spriteid
    lda #4
    sta temp_left_offset
    lda #&fc
    sta temp_right_offset
.check_for_player_bowl_collision
    ldx #objectid_old_player
    ldy #objectid_bowl
    jsr test_for_collision_between_objects_x_and_y
    ldx remember_sprite_held
    stx player_held_object_spriteid
    ora #0
    beq no_player_bowl_collision
    lda just_started_using_bowl_flag
    bne hide_bowl2
    lda #spriteid_bowl_menu_item
    ldx save_game_level_o_bowl_is_full_flag
    beq set_bowl_menu_slot
    lda #spriteid_full_bowl_menu_item
.set_bowl_menu_slot
    jsr find_or_create_menu_slot_for_A
.hide_bowl2
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_bowl
    lda #&ff
    sta save_game_level_o_bowl_progress
    jmp return2

.no_player_bowl_collision
    lda just_started_using_bowl_flag
    beq if_bowl_is_moving_then_check_for_room_collision
    lda #spriteid_bowl_menu_item
    ldx save_game_level_o_bowl_is_full_flag
    beq remove_from_toolbar
    lda #spriteid_full_bowl_menu_item
.remove_from_toolbar
    jsr remove_item_from_toolbar_menu
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_player_accessory
    sta player_using_object_spriteid
    sta player_held_object_spriteid
.if_bowl_is_moving_then_check_for_room_collision
    lda object_x_low + objectid_bowl
    cmp object_x_low_old + objectid_bowl
    beq check_for_bowl_room_collision_again
    lda save_game_level_o_bowl_direction_with_bounces
    bmi adjust_for_looking_left
    inc temp_right_offset
    jmp check_for_bowl_room_collision

.adjust_for_looking_left
    dec temp_left_offset
.check_for_bowl_room_collision
    lda #1
    sta temp_bottom_offset
    lda #objectid_bowl
    jsr get_solid_rock_collision_for_object_a
    beq check_for_bowl_room_collision_again
    jmp play_bowl_collision_sound

.check_for_bowl_room_collision_again
    lda object_y_low + objectid_bowl
    cmp object_y_low_old + objectid_bowl
    beq return2
    dec temp_top_offset
    lda #2
    sta temp_bottom_offset
    lda #2
    jsr get_solid_rock_collision_for_object_a
    beq return2
.play_bowl_collision_sound
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
.return2
    rts

.update_bowl_step
    lda save_game_level_o_bowl_animation_step
    clc
    adc #2
    tay
    lda bowl_animations,y
    cmp #&80
    bne check_if_bowl_is_hitting_the_floor
    ldy save_game_level_o_bowl_progress
.check_if_bowl_is_hitting_the_floor
    lda #objectid_bowl
    jsr update_object_hitting_floor
    bne bowl_is_hitting_floor
    lda save_game_level_o_bowl_progress
    cmp #bowl_fall_down_fast_animation - bowl_animations
    beq set_bowl_animation_step
    ldy #bowl_fall_straight_down_animation - bowl_animations
    lda #bowl_fall_down_fast_animation - bowl_animations
    sta save_game_level_o_bowl_progress
    jmp set_bowl_animation_step

.bowl_is_hitting_floor
    lda object_just_fallen_off_edge_direction
    beq set_bowl_stationary
    ldy #bowl_fall_down_fast_animation - bowl_animations
    sty save_game_level_o_bowl_progress
    ldy #&0c
    ldx #1
    stx save_game_level_o_bowl_direction_with_bounces
    ora #0
    bpl set_bowl_animation_step
    ldx #&ff
    stx save_game_level_o_bowl_direction_with_bounces
    bne set_bowl_animation_step
.set_bowl_stationary
    ldy #bowl_stationary_animation - bowl_animations
    sty save_game_level_o_bowl_progress
    lda #0
    sta fast_forward_bowl_step_count
.set_bowl_animation_step
    sty save_game_level_o_bowl_animation_step
    lda bowl_animations,y
    ldx save_game_level_o_bowl_direction_with_bounces
    bpl sign_extend_a_to_ax
    eor #&ff
    clc
    adc #1
.sign_extend_a_to_ax
    ldx #0
    ora #0
    bpl add_to_bowl_x
    dex
.add_to_bowl_x
    clc
    adc save_game_level_o_bowl_x_low
    sta save_game_level_o_bowl_x_low
    txa
    adc save_game_level_o_bowl_x_high
    sta save_game_level_o_bowl_x_high
    iny
    lda bowl_animations,y
    clc
    adc save_game_level_o_bowl_y
    sta save_game_level_o_bowl_y
    jsr set_bowl_object
    lda #objectid_bowl
    jsr update_object_a_solid_rock_collision
    lda object_x_low + objectid_bowl
    sta save_game_level_o_bowl_x_low
    lda object_x_high + objectid_bowl
    sta save_game_level_o_bowl_x_high
    lda object_y_low + objectid_bowl
    sta save_game_level_o_bowl_y
    ldx #objectid_bowl
    jsr find_left_and_right_of_object
    lda save_game_level_o_bowl_direction_with_bounces
    bmi move_bowl_left_one_room_if_needed
; move bowl right one room if needed
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return3
    lda save_game_level_o_bowl_x_low
    sec
    sbc #&40 ; '@'
    sta save_game_level_o_bowl_x_low
    lda #0
    sbc #0
    sta save_game_level_o_bowl_x_high
    inc save_game_level_o_bowl_room
    jmp hide_bowl3

.move_bowl_left_one_room_if_needed
    lda object_right_cell_x
    bpl return3
    lda save_game_level_o_bowl_x_low
    clc
    adc #&40 ; '@'
    sta save_game_level_o_bowl_x_low
    lda #1
    sta save_game_level_o_bowl_x_high
    dec save_game_level_o_bowl_room
.hide_bowl3
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_bowl
.return3
    rts

.set_bowl_object
    lda #spriteid_erase1
    sta object_erase_type + objectid_bowl
    lda #&a0
    sta object_z_order + objectid_bowl
    lda save_game_level_o_bowl_x_low
    sta object_x_low + objectid_bowl
    lda save_game_level_o_bowl_x_high
    sta object_x_high + objectid_bowl
    lda save_game_level_o_bowl_y
    sta object_y_low + objectid_bowl
    lda #spriteid_bowl
    ldx save_game_level_o_bowl_is_full_flag
    beq set_bowl_sprite
    lda #spriteid_full_bowl
.set_bowl_sprite
    sta object_spriteid + objectid_bowl
    lda save_game_level_o_bowl_direction_without_bounces
    sta object_direction + objectid_bowl
    rts

.just_started_using_bowl_flag
    equb 0
.remember_sprite_held
    equb 0
.temp_old_bowl_sprite
    equb 0
; unused
    equb &60

; check for first update in room (branch if not)
.update_fire_bowl
    lda update_room_first_update_flag
    beq update_fire_bowl_animation
    lda desired_room_index
    cmp #1
    bne set_sprite_for_fire_bowl_local
    ldx #&19
    ldy #&0a
    lda #2
    sta width_in_cells
    lda #4
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    ldy #&0e
    lda #spriteid_fire_bowl
    jsr draw_sprite_a_at_cell_xy
    ldx #&19
    lda #5
    sta temp_sprite_x_offset
    ldy #&0c
    lda #2
    sta temp_sprite_y_offset
    lda #objectid_fire_bowl
    jsr set_object_position_from_cell_xy
.set_sprite_for_fire_bowl_local
    jmp set_sprite_for_fire_bowl

.update_fire_bowl_animation
    inc fire_bowl_animation_step
.set_sprite_for_fire_bowl
    lda desired_room_index
    cmp #1
    bne return4
; calculate sprite id
    lda fire_bowl_animation_step
    and #7
    clc
    adc #spriteid_fire1
    sta object_spriteid + objectid_fire_bowl
.return4
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
; ###   |             |                ###
; ###   |             |                ###
; ###   |             |                ###
; ###   |             |                ###
; ###   |             |                ###
; ###   |             |                ###
; ###   |   #######   |
; ###   |   #######   |
; ###   |   ###       |
; ###   |   ###       |
; ###   |   ###
; ###   |   ###                        ###
; ###   |   ##############################
; ###   |   ##############################
;       |                              ###
;       |                              ###
;       |                              ###
;       |                              ###
;                                      ###
; ###                 P                ###
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
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x14 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0e
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (0,21)
    ldy #&15
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (37,2)
    ldx #&25 ; '%'
    ldy #2
    lda #6
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (37,13)
    ldy #&0d
    lda #9
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (10,8)
    ldx #&0a
    ldy #8
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (13,8)
    ldx #&0d
    inc width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 24x2 rectangle at (13,14)
    ldy #&0e
    lda #&18
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (6,2) length 18
    ldx #6
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (20,2) length 10
    ldx #&14
    lda #&0a
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
    ldy #5
    lda #objectid_fire
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_2_not_first_update
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    lda #spriteid_stick_menu_item
    sta toolbar_collectable_spriteids + 3
    lda #spriteid_stick_using
    sta collectable_spriteids + 3
    lda #spriteid_stick_held
    sta collectable_being_used_spriteids + 3
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_changed_only1
    lda save_game_level_o_holding_stick
    beq room_changed_only1
    lda #&ff
    sta save_game_level_o_holding_stick
; There is no object with id 5, so these instructions are redundant
.room_changed_only1
    lda #spriteid_erase4b
    sta object_erase_type + 5
    lda #&40 ; '@'
    sta object_z_order + 5
    lda #spriteid_erase3
    sta object_erase_type + objectid_explosion
    lda #&90
    sta object_z_order + objectid_explosion
    lda desired_room_index
    cmp #2
    bne initialise_explosion_local1
    lda save_game_level_o_holding_stick
    bne initialise_explosion_local1
    lda #spriteid_erase2
    sta object_erase_type + objectid_trapdoor
    ldx #&0d
    ldy #&0e
    lda #4
    jsr set_object_position_from_cell_xy
    lda #spriteid_stick
    sta object_spriteid + objectid_stick
.initialise_explosion_local1
    jmp initialise_explosion

.room_2_not_first_update
    lda explosion_animation_step
    beq set_explosion_animation_step
    clc
    adc #1
    cmp #3
    bcc set_explosion_animation_step
    lda #0
.set_explosion_animation_step
    sta explosion_animation_step
    lda save_game_level_o_holding_stick
    beq check_player_bowl_collision
    bmi check_for_developer_mode_shortcuts
    bpl update_smoke_animation                                        ; ALWAYS branch

.check_player_bowl_collision
    lda desired_room_index
    cmp #2
    bne initialise_explosion_local2
    ldx #objectid_old_player
    ldy #objectid_stick
    jsr test_for_collision_between_objects_x_and_y
    beq initialise_explosion_local2
    lda #spriteid_stick_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_stick
    lda #&ff
    sta save_game_level_o_holding_stick
.initialise_explosion_local2
    jmp initialise_explosion

.check_for_developer_mode_shortcuts
    lda developer_flags
    bpl developer_mode_inactive3
; pressing 'L' in developer mode lights the stick
    ldx #inkey_key_l
    jsr negative_inkey
    bne light_stick
.developer_mode_inactive3
    lda desired_room_index
    cmp #1
    bne initialise_explosion_local2
    lda player_held_object_spriteid
    cmp #spriteid_stick_menu_item
    bne initialise_explosion_local2
    dec temp_left_offset
    ldx #objectid_stick
    ldy #objectid_player_accessory
    jsr test_for_collision_between_objects_x_and_y
    beq initialise_explosion_local2
.light_stick
    lda #1
    sta save_game_level_o_holding_stick
    jmp initialise_explosion

.update_smoke_animation
    ldy save_game_level_o_holding_stick
    iny
    cpy #9
    bcc got_smoke_animation_step
    ldy #1
.got_smoke_animation_step
    lda player_held_object_spriteid
    cmp #spriteid_stick_menu_item
    beq set_holding_stick
    ldy #&ff
.set_holding_stick
    sty save_game_level_o_holding_stick
    lda explosion_animation_step
    bne initialise_explosion
    lda save_game_level_o_bowl_is_full_flag
    beq initialise_explosion
    ldx #objectid_old_player_accessory
    ldy #objectid_bowl
    jsr test_for_collision_between_objects_x_and_y
    beq initialise_explosion
    lda #0
    sta save_game_level_o_bowl_is_full_flag
    lda #&ff
    sta save_game_level_o_holding_stick
; start explosion animation
    lda #1
    sta explosion_animation_step
    lda #0
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    lda object_x_low
    sec
    sbc object_x_low + objectid_bowl
    lda object_x_high
    sbc object_x_high + objectid_bowl
    bmi set_move_left_after_collision
    lda #6
    sta player_wall_collision_reaction_speed
    jmp check_for_bowl_stick_collision

.set_move_left_after_collision
    lda #&fa
    sta player_wall_collision_reaction_speed
.check_for_bowl_stick_collision
    lda #6
    sta temp_left_offset
    ldx #objectid_bowl
    ldy #objectid_stick
    jsr test_for_collision_between_objects_x_and_y
    beq initialise_explosion
    lda #&ff
    sta save_game_level_o_trapdoor_open_flag
.initialise_explosion
    lda object_x_low + objectid_bowl
    sta object_x_low + objectid_explosion
    lda object_x_high + objectid_bowl
    sta object_x_high + objectid_explosion
    lda object_y_low + objectid_bowl
    sta object_y_low + objectid_explosion
    lda object_direction + objectid_bowl
    sta object_direction + objectid_explosion
    ldy explosion_animation_step
    lda explosion_animation,y
    sta object_spriteid + objectid_explosion
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_smoke
; set up smoke object if needed
    lda save_game_level_o_holding_stick
    beq return5
    bmi return5
    clc
    adc #spriteid_smoke1 - 1
    sta object_spriteid + objectid_smoke
    lda object_x_low + objectid_player_accessory
    sta object_x_low + objectid_smoke
    lda object_x_high + objectid_player_accessory
    sta object_x_high + objectid_smoke
    lda object_y_low + objectid_player_accessory
    sta object_y_low + objectid_smoke
    lda object_direction + objectid_player_accessory
    sta object_direction + objectid_smoke
; check if using stick (return if not)
    lda player_using_object_spriteid
    cmp #spriteid_stick_menu_item
    bne return5
; redundant instructions - adding zero to x position
    lda object_x_low + objectid_smoke
    clc
    adc #0
    sta object_x_low + objectid_smoke
    lda object_x_high + objectid_smoke
    adc #0
    sta object_x_high + objectid_smoke
; move smoke up a few pixels when using the stick
    lda object_y_low + objectid_smoke
    clc
    adc #&fc
    sta object_y_low + objectid_smoke
.return5
    rts

.explosion_animation
    equb 0
    equb spriteid_explosion
    equb spriteid_explosion
; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************

.room_3_data
    equb 10                                                           ; initial player X cell
    equb 14                                                           ; initial player Y cell

; ########################################
; ########################################
; ###                     ###          ###
; ###                     ###          ###
; ###                     ###          ###
; ###                     ###          ###
; ###########################          ###
; ###########################          ###
;                     |   ###          ###
;                     |   ###          ###
;                     |   ###          ###
;                     |   ###          ###
;                     |   ###          ###
; ###       P         |   ###          ###
; #################   |   ################
; #################   |   ################
; ###                 |                ###
; ###                 |                ###
; ###                 |                ###
; ###                 |                ###
; ###                                  ###
; ###                                  ###
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
; draw 255x2 rectangle at (0,22)
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #6
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (0,13)
    ldy #&0d
    lda #9
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x14 rectangle at (24,2)
    ldx #&18
    ldy #2
    lda #&0e
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x20 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 21x2 rectangle at (3,6)
    ldx #3
    ldy #6
    lda #&15
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 14x2 rectangle at (3,14)
    ldy #&0e
    lda #&0e
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 10x2 rectangle at (27,14)
    ldx #&1b
    lda #&0a
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (20,8) length 12
    ldx #&14
    ldy #8
    lda #&0c
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_3_game_update_loop
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

; check for first update in room (branch if not)
.room_3_update_handler
    lda update_room_first_update_flag
    beq room_3_not_first_update
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_changed_only2
    lda save_game_level_o_tnt_barrel_animation_step
    beq room_changed_only2
    lda #2
    sta save_game_level_o_tnt_barrel_animation_step
.room_changed_only2
    lda desired_room_index
    cmp #3
    bne update_tnt_barrel_local
    lda #&cf
    sta object_erase_type + objectid_tnt_barrel
    ldx #&0a
    ldy #&14
    lda #3
    jsr set_object_position_from_cell_xy
    lda #objectid_trapdoor
    jsr set_object_position_from_cell_xy
    lda #&c0
    sta object_z_order + objectid_trapdoor
.update_tnt_barrel_local
    jmp update_tnt_barrel

.room_3_not_first_update
    lda save_game_level_o_tnt_barrel_animation_step
    beq barrel_still_standing
    cmp #2
    bne move_to_next_barrel_animation_step
    beq update_tnt_barrel                                             ; ALWAYS branch

.barrel_still_standing
    lda desired_room_index
    cmp #3
    bne update_tnt_barrel
    lda object_room_collision_flags
    and #1
    beq update_tnt_barrel
    lda object_x_low
    cmp #&90
    bcs update_tnt_barrel
    lda object_y_low
    cmp #&80
    bcc update_tnt_barrel
    cmp #&aa
    bcs update_tnt_barrel
.move_to_next_barrel_animation_step
    inc save_game_level_o_tnt_barrel_animation_step
    lda save_game_level_o_tnt_barrel_animation_step
    cmp #2
    bne update_tnt_barrel
    lda desired_room_index
    cmp #3
    bne update_tnt_barrel
    jsr play_explosion_or_barrel_overturning_sound
.update_tnt_barrel
    lda desired_room_index
    cmp #3
    bne update_bowl
    ldy save_game_level_o_tnt_barrel_animation_step
    lda tnt_barrel_animation,y
    sta object_spriteid + objectid_tnt_barrel
    cpy #2
    bne write_tnt_barrel_collision_map
    lda #spriteid_tnt_powder
    sta object_spriteid + objectid_tnt
.write_tnt_barrel_collision_map
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
; check if the tnt barrel animation has started (branch if so)
    lda save_game_level_o_tnt_barrel_animation_step
    bne write_horizontal_tnt_barrel_collision_map
; write vertical tnt barrel collision map
    ldx #&0e
    ldy #&13
    lda #1
    sta width_in_cells
    lda #3
    sta height_in_cells
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq update_bowl
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    jmp update_bowl

.write_horizontal_tnt_barrel_collision_map
    ldx #&0a
    ldy #&14
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq update_bowl
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    lda #collision_map_none
    sta value_to_write_to_collision_map
    ldx #&0e
    ldy #&13
    lda #1
    sta width_in_cells
    lda #3
    sta height_in_cells
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.update_bowl
    lda desired_room_index
    cmp #3
    bne return6
    lda save_game_level_o_bowl_progress
    cmp #&ff
    beq return6
    lda save_game_level_o_bowl_is_full_flag
    bne return6
    lda #2
    sta temp_bottom_offset
    lda #2
    jsr get_solid_rock_collision_for_object_a
    beq return6
    lda #8
    sta temp_left_offset
    ldx #objectid_tnt
    ldy #objectid_bowl
    jsr test_for_collision_between_objects_x_and_y
    beq return6
; bowl and tnt have collided, so fill bowl
    lda #&ff
    sta save_game_level_o_bowl_is_full_flag
    lda #spriteid_full_bowl
    sta object_spriteid + objectid_bowl
.return6
    rts

.tnt_barrel_animation
    equb spriteid_tnt
    equb spriteid_tnt_tipping
    equb spriteid_tnt_sideways

.play_explosion_or_barrel_overturning_sound
    lda #0
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    ldx #<sound5
    ldy #>sound5
    jmp play_sound_yx

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
.envelope3
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
.sound5
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound4
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
.sound3
    equw &0010                                                        ; channel
    equw 7                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound2
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 220                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11010011
    equb %00001100
    equb %00001000
    equb %00010000
    equb %00010000
.ground_fill_2x2_top_right
    equb %00001000
    equb %00000100
    equb %11100010
    equb %00010001
    equb %00001000
    equb %00000100
    equb %00000100
    equb %00000100
.ground_fill_2x2_bottom_left
    equb %00100000
    equb %00100000
    equb %00100000
    equb %00010000
    equb %10001000
    equb %01000111
    equb %00100000
    equb %00010000
.ground_fill_2x2_bottom_right
    equb %00001000
    equb %00001000
    equb %00010000
    equb %00110000
    equb %11001011
    equb %00000100
    equb %00001000
    equb %00001000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelO_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelO.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelO"
ENDIF
ENDIF
.pydis_end

save "build/dataO", pydis_start, pydis_end
