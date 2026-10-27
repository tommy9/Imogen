; *************************************************************************************
;
; Level P: 'TENDER-HOOKS'
;
; Save game variables:
;
;     save_game_level_p_ring_animation                           ($0a62):
;              $0: sea lion is bouncing the ring
;              $1: on left hook in room 2
;              $2: on right hook in room 2
;              $3: on magnet
;              $4: on left hook in room 1
;              $5: on right hook in room 1
;              $6: falling to one side
;             $15: falling off edge to one side
;             $22: fall straight down
;             $25: stationary
;             $28: bounced off wall
;             $ff: taken
;
;     save_game_level_p_ring_animation_step                      ($0a63):
;             step within the animations above
;
;     save_game_level_p_ring_x_low                               ($0a64):
;     save_game_level_p_ring_x_high                              ($0a65):
;             x position of the ring
;
;     save_game_level_p_ring_direction_without_bounces           ($0a66):
;             direction the ring was thrown in
;
;     save_game_level_p_ring_direction_with_bounces              ($0a67):
;             as above, but including any subsequent bounces off walls
;
;     save_game_level_p_ring_room                                ($0a68):
;             current room containing the ring
;
;     save_game_level_p_ring_y_low                               ($0a69):
;     save_game_level_p_ring_y_high                              ($0a6a):
;             y position of the ring
;
;     save_game_level_p_left_hook_y                              ($0a6b):
;             y position of the left hook in room 2 ($18 to $78)
;
;     save_game_level_p_left_hook_speed                          ($0a6c):
;              $0: stationary
;              $4: moving down
;             $fc: moving up
;
;     save_game_level_p_magnet_x                                 ($0a6d):
;             x position of the magnet on the bar in cells ($0c to $1b)
;
;     save_game_level_p_magnet_direction                         ($0a6e):
;              $0: stationary
;              $1: moving right
;             $ff: moving left
;
; Solution:
;
;   1. Go to the leftmost room with the sea lion bouncing a ring. Climb the left rope.
;   2. Jump into the magnet to make it travel across the screen past the ring as the ring reaches
;      its highest point. (The ring sticks to the magnet)
;   3. Jump into the ring from the other rope to collect it.
;   4. In the room to the right, climb the rope with the cane attached and exit right.
;   5. Use the ring to throw it onto the left hook. (The rope descends on the left)
;   6. Collect the ring and repeat with the right hook to jump over to the right side of the room
;      at the top.
;   7. In the rightmost room, jump across the ropes to collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_cane                         = 7
objectid_fire1                        = 3
objectid_fire2                        = 4
objectid_magnet                       = 3
objectid_old_ring                     = 13
objectid_ring                         = 2
objectid_room1_left_hook              = 5
objectid_room1_right_hook             = 6
objectid_room2_left_hook              = 3
objectid_room2_right_hook             = 5
objectid_sea_lion_head                = 5
objectid_short_bar                    = 4
objectid_short_left_rope              = 4
objectid_short_right_rope             = 6
ring_on_magnet                        = 3
ring_on_room1_left_hook               = 4
ring_on_room1_right_hook              = 5
ring_on_room2_left_hook               = 1
ring_on_room2_right_hook              = 2
spriteid_boulder                      = 210
spriteid_cane                         = 221
spriteid_erase1                       = 202
spriteid_hook                         = 207
spriteid_hook_with_ring               = 208
spriteid_horizontal_bar               = 211
spriteid_horizontal_rope              = 205
spriteid_left_bar                     = 212
spriteid_left_hook                    = 203
spriteid_rght_hook                    = 204
spriteid_right_bar                    = 213
spriteid_ring                         = 200
spriteid_ring_menu_item               = 201
spriteid_rope                         = 206
spriteid_rope_with_magnet             = 214
spriteid_sea_lion_body                = 216
spriteid_sea_lion_head1               = 217
spriteid_sea_lion_head2a              = 218
spriteid_sea_lion_head2b              = 219
spriteid_short_bar                    = 215
spriteid_short_rope                   = 209
spriteid_table                        = 220

; Memory locations
remember_a                                          = &0070
room_exit_direction                                 = &0070
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
save_game_level_p_ring_animation                    = &0a62
save_game_level_p_ring_animation_step               = &0a63
save_game_level_p_ring_x_low                        = &0a64
save_game_level_p_ring_x_high                       = &0a65
save_game_level_p_ring_direction_without_bounces    = &0a66
save_game_level_p_ring_direction_with_bounces       = &0a67
save_game_level_p_ring_room                         = &0a68
save_game_level_p_ring_y_low                        = &0a69
save_game_level_p_ring_y_high                       = &0a6a
save_game_level_p_left_hook_y                       = &0a6b
save_game_level_p_left_hook_speed                   = &0a6c
save_game_level_p_magnet_x                          = &0a6d
save_game_level_p_magnet_direction                  = &0a6e
fast_forward_ring_movement_steps                    = &0a6f
ring_bounce_cycle_animation_step                    = &0a70
ring_y_position                                     = &0a71

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelP_sprite_table - level_data
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
    encode "TENDER-HOOKS", &0D

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
    bpl developer_mode_inactive
    lda #&ff
    sta save_game_level_p_ring_animation
.developer_mode_inactive
    lda save_game_level_p_ring_animation
    bpl set_rock_tiles
    lda #spriteid_ring_menu_item
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
    jsr update_sea_lion_and_ring
    jsr update_magnet_and_rod
    jsr update_ring
    jsr room_2_update_handler
    jsr room_1_update_handler
    jsr room_3_update_handler
    rts

.draw_rock_in_top_corner_cells
    ldx #3
    ldy #2
    lda #1
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    ldx #&24 ; '$'
    jmp copy_rectangle_of_memory_to_screen

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
; ####                                ####
; ###                                  ###
; ###                                  ###
; ###
; ###
; ###
; ###
; ######                            ######
; ######              S             ######
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; 
; 
; 
; 
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
; draw 3x3 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #3
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (37,9)
    ldy #9
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,9)
    ldx #3
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,9)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (34,21)
    ldy #&15
    lda #6
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (0,21)
    ldx #0
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_rock_in_top_corner_cells
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw ball at (20,10)
    ldx #&14
    ldy #&0a
    lda #spriteid_ball
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
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
; update braziers
    ldx #&14
    ldy #&0a
    lda #objectid_fire1
    jsr update_brazier_and_fire
    inx
    lda #objectid_fire2
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_1_not_first_update
    lda desired_room_index
    cmp #1
    bne set_ring_sprites_local1
    ldx #&0a
    ldy #2
    lda #&0e
    jsr draw_rope
    ldy #&0f
    lda #sprite_op_flags_erase_to_fg_colour
    sta sprite_op_flags
    lda #spriteid_rope_end
    jsr draw_sprite_a_at_cell_xy
    lda #objectid_room1_left_hook
    jsr set_object_position_from_cell_xy
    ldx #&1d
    ldy #2
    lda #&0e
    jsr draw_rope
    ldy #&0f
    lda #sprite_op_flags_erase_to_fg_colour
    sta sprite_op_flags
    lda #spriteid_rope_end
    jsr draw_sprite_a_at_cell_xy
    lda #objectid_short_right_rope
    jsr set_object_position_from_cell_xy
    lda #objectid_cane
    jsr set_object_position_from_cell_xy
    lda #spriteid_cane
    sta object_spriteid + objectid_cane
    lda #&c0
    sta object_z_order + objectid_cane
    iny
    lda #1
    sta width_in_cells
    lda #4
    sta height_in_cells
    lda #collision_map_rope
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.set_ring_sprites_local1
    jmp set_ring_sprites

.room_1_not_first_update
    lda save_game_level_p_ring_animation
    cmp #ring_on_room1_left_hook
    beq ring_is_on_room1_left_hook
    cmp #ring_on_room1_right_hook
    beq ring_is_on_room1_right_hook
    lda desired_room_index
    cmp #1
    bne set_ring_sprites
    lda save_game_level_p_ring_direction_with_bounces
    bmi set_ring_sprites
    ldx #objectid_room1_left_hook
    jsr check_for_hook_x_collision_with_ring
    beq set_ring_sprites_local2
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    lda #ring_on_room1_left_hook
    sta save_game_level_p_ring_animation
    jmp set_ring_sprites

.set_ring_sprites_local2
    jmp set_ring_sprites

; unused code
    ldx #objectid_room1_right_hook
    jsr check_for_hook_x_collision_with_ring
    beq set_ring_sprites
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    lda #ring_on_room1_right_hook
    sta save_game_level_p_ring_animation
    jmp set_ring_sprites

.ring_is_on_room1_left_hook
    ldx #objectid_room1_left_hook
    bne got_hook_sprite_in_x                                          ; ALWAYS branch

.ring_is_on_room1_right_hook
    ldx #objectid_room1_right_hook
.got_hook_sprite_in_x
    lda desired_room_index
    cmp #1
    bne set_ring_sprites
    jsr check_for_picking_up_ring_from_hook_x
.set_ring_sprites
    lda desired_room_index
    cmp #1
    bne return1
    lda #spriteid_hook
    sta object_spriteid + objectid_room1_left_hook
    lda save_game_level_p_ring_animation
    cmp #ring_on_room1_left_hook
    bne set_ring_sprite
    lda #spriteid_hook_with_ring
    sta object_spriteid + objectid_room1_left_hook
.set_ring_sprite
    lda #spriteid_hook
    sta object_spriteid + objectid_room1_right_hook
    lda save_game_level_p_ring_animation
    cmp #ring_on_room1_right_hook
    bne return1
    lda #spriteid_hook_with_ring
    sta object_spriteid + objectid_room1_right_hook
.return1
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
; ####                                ####
; ###                                  ###
; ###                                  ###
; 
; 
; 
; 
; ######         ##########         ######
; ######         ##########         ######
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; 
; 
; 
; 
; ######              P             ######
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
; draw 3x3 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x3 rectangle at (37,2)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,9)
    ldx #0
    ldy #9
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (37,9)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,9)
    ldx #3
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,9)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 10x2 rectangle at (15,9)
    ldx #&0f
    lda #&0a
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (0,21)
    ldx #0
    ldy #&15
    lda #6
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (34,21)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_rock_in_top_corner_cells
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
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

; check for first update in room (branch if so)
.room_2_update_handler
    lda update_room_first_update_flag
    bne initialise_room_2
    jmp room_2_not_first_update

; check for level change (branch if not)
.initialise_room_2
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq position_room_2_hooks_and_rope
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    lda save_game_level_p_left_hook_y
    beq set_left_hook_y_in_up_position
    lda save_game_level_p_left_hook_speed
    beq position_room_2_hooks_and_rope
    bmi set_left_hook_y_in_up_position
; set left hook low down and stopped
    lda #&78 ; 'x'
    sta save_game_level_p_left_hook_y
    lda #0
    sta save_game_level_p_left_hook_speed
    beq position_room_2_hooks_and_rope
.set_left_hook_y_in_up_position
    lda #&18
    sta save_game_level_p_left_hook_y
    lda #0
    sta save_game_level_p_left_hook_speed
.position_room_2_hooks_and_rope
    lda desired_room_index
    cmp #2
    bne set_hook_and_rope_objects_local1
    ldx #&0a
    ldy #0
    lda #objectid_room2_left_hook
    jsr set_object_position_from_cell_xy
    lda #objectid_short_left_rope
    jsr set_object_position_from_cell_xy
    lda #&c0
    sta object_z_order + objectid_short_left_rope
    ldx #&1d
    lda #objectid_room2_right_hook
    jsr set_object_position_from_cell_xy
    lda #objectid_short_right_rope
    jsr set_object_position_from_cell_xy
    lda #&c0
    sta object_z_order + objectid_short_right_rope
    ldx #&0a
    ldy #2
    lda #spriteid_left_hook
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    inx
    inx
    lda #spriteid_horizontal_rope
.draw_horizontal_rope_loop
    jsr draw_sprite_a_at_cell_xy
    inx
    cpx #&1c
    bcc draw_horizontal_rope_loop
    inx
    lda #spriteid_rght_hook
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    ldx #&0a
    lda save_game_level_p_left_hook_y
    jsr calculate_rope_y_in_cells_and_draw_it
    ldx #&1d
    lda #&90
    sec
    sbc save_game_level_p_left_hook_y
    jsr calculate_rope_y_in_cells_and_draw_it
.set_hook_and_rope_objects_local1
    jmp set_hook_and_rope_objects

.calculate_rope_y_in_cells_and_draw_it
    sec
    sbc #4
    lsr a
    lsr a
    lsr a
    tay
    jmp draw_right_rope

.draw_right_rope_loop
    lda #spriteid_rope
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dey
.draw_right_rope
    cpy #3
    bcs draw_right_rope_loop
    rts

.room_2_not_first_update
    lda save_game_level_p_ring_animation
    cmp #ring_on_room2_left_hook
    beq ring_is_on_room_2_left_hook
    cmp #ring_on_room2_right_hook
    beq ring_is_on_room_2_right_hook
    lda save_game_level_p_left_hook_speed
    beq room_2_left_hook_stationary
    jmp add_speed_to_left_hook_y

.room_2_left_hook_stationary
    lda desired_room_index
    cmp #2
    bne set_hook_and_rope_objects_local2
    lda save_game_level_p_ring_animation
    cmp #ring_fall_to_side_animation - ring_animations
    bcc set_hook_and_rope_objects_local2
    lda save_game_level_p_ring_direction_with_bounces
    bmi set_hook_and_rope_objects_local2
; handle left hook
    ldx #objectid_room2_left_hook
    jsr check_for_hook_x_collision_with_ring
    beq handle_right_hook
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    lda #ring_on_room2_left_hook
    sta save_game_level_p_ring_animation
    lda save_game_level_p_left_hook_y
    cmp #&78 ; 'x'
    beq set_hook_and_rope_objects_local2
    lda #4
    sta save_game_level_p_left_hook_speed
    jmp set_hook_and_rope_objects

.handle_right_hook
    ldx #objectid_room2_right_hook
    jsr check_for_hook_x_collision_with_ring
    beq set_hook_and_rope_objects_local2
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    lda #ring_on_room2_right_hook
    sta save_game_level_p_ring_animation
    lda save_game_level_p_left_hook_y
    cmp #&18
    beq set_hook_and_rope_objects_local2
    lda #&fc
    sta save_game_level_p_left_hook_speed
.set_hook_and_rope_objects_local2
    jmp set_hook_and_rope_objects

.check_for_hook_x_collision_with_ring
    lda #7
    sta temp_top_offset
    lda #&fa
    sta temp_bottom_offset
    lda #7
    sta temp_left_offset
    lda #&f9
    sta temp_right_offset
    ldy #objectid_old_ring
    jsr test_for_collision_between_objects_x_and_y
    pha
    beq skip_playing_hook_to_ring_collision_sound
    jsr play_ring_sound
.skip_playing_hook_to_ring_collision_sound
    pla
    rts

.ring_is_on_room_2_left_hook
    ldx #objectid_room2_left_hook
    bne check_for_picking_up_ring_if_in_room_2                        ; ALWAYS branch

.ring_is_on_room_2_right_hook
    ldx #objectid_room2_right_hook
.check_for_picking_up_ring_if_in_room_2
    lda desired_room_index
    cmp #2
    bne add_speed_to_left_hook_y
    jsr check_for_picking_up_ring_from_hook_x
    jmp add_speed_to_left_hook_y

.check_for_picking_up_ring_from_hook_x
    lda #8
    sta temp_top_offset
    lda #3
    sta temp_left_offset
    lda #&fe
    sta temp_right_offset
    ldy #objectid_old_player
    jsr test_for_collision_between_objects_x_and_y
    beq return2
    lda #&ff
    sta save_game_level_p_ring_animation
    lda #spriteid_ring_menu_item
    jsr find_or_create_menu_slot_for_A
.return2
    rts

.add_speed_to_left_hook_y
    lda save_game_level_p_left_hook_speed
    beq set_hook_and_rope_objects
    sta remember_left_hook_speed
    clc
    adc save_game_level_p_left_hook_y
    sta save_game_level_p_left_hook_y
    ldx #&18
    cmp #&19
    bcc store_left_hook_y
    ldx #&78 ; 'x'
    cmp #&78 ; 'x'
    bcc play_rope_movement_sound_if_in_room_2
.store_left_hook_y
    stx save_game_level_p_left_hook_y
    lda #0
    sta save_game_level_p_left_hook_speed
.play_rope_movement_sound_if_in_room_2
    lda desired_room_index
    cmp #2
    bne set_hook_and_rope_objects
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_short_left_rope
    sta object_spriteid + objectid_short_left_rope
    lda remember_left_hook_speed
    bmi stop_drawing_short_right_rope
    lda #spriteid_short_rope
    sta object_spriteid + objectid_short_left_rope
.stop_drawing_short_right_rope
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_short_right_rope
    sta object_spriteid + objectid_short_right_rope
    lda remember_left_hook_speed
    bpl hook_moving_down
    lda #spriteid_short_rope
    sta object_spriteid + objectid_short_right_rope
.hook_moving_down
    jsr check_for_monkey_on_rope
.set_hook_and_rope_objects
    lda desired_room_index
    cmp #2
    bne return3
; update room 2 left hook and rope
    lda save_game_level_p_left_hook_y
    sta object_y_low + objectid_room2_left_hook
    sta object_y_low + objectid_short_left_rope
    ldx #&0a
    jsr update_rope_collision_map
    lda #spriteid_hook
    sta object_spriteid + objectid_room2_left_hook
    lda save_game_level_p_ring_animation
    cmp #ring_on_room2_left_hook
    bne update_room2_right_hook_and_rope
    lda #spriteid_hook_with_ring
    sta object_spriteid + objectid_room2_left_hook
.update_room2_right_hook_and_rope
    lda #&90
    sec
    sbc save_game_level_p_left_hook_y
    sta object_y_low + objectid_room2_right_hook
    sta object_y_low + objectid_short_right_rope
    ldx #&1d
    jsr update_rope_collision_map
    lda #spriteid_hook
    sta object_spriteid + objectid_room2_right_hook
    lda save_game_level_p_ring_animation
    cmp #ring_on_room2_right_hook
    bne return3
    lda #spriteid_hook_with_ring
    sta object_spriteid + objectid_room2_right_hook
.return3
    rts

.update_rope_collision_map
    lsr a
    lsr a
    lsr a
    tay
    cpy #3
    bcc clear_collision_map_of_rope
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
.clear_collision_map_of_rope
    iny
    lda #collision_map_none
    jmp write_a_single_value_to_cell_in_collision_map

.remember_left_hook_speed
    equb 0

.check_for_monkey_on_rope
    lda current_player_character
    cmp #spriteid_icodata_monkey
    bne return4
    lda current_player_animation
    cmp #monkey_climb_animation - monkey_base_animation
    beq player_is_monkey_on_rope
    cmp #monkey_climb_idle_animation - monkey_base_animation
    beq player_is_monkey_on_rope
    cmp #monkey_climb_down_animation - monkey_base_animation
    bne return4
.player_is_monkey_on_rope
    lda remember_left_hook_speed
    eor #&ff
    clc
    adc #1
    ldx object_x_high
    bne adding_to_player_y_position_when_on_rope
    ldx object_x_low
    cpx #&a0
    bcs adding_to_player_y_position_when_on_rope
    lda remember_left_hook_speed
.adding_to_player_y_position_when_on_rope
    ldy #0
    tax
    bpl add_ay_to_player_y_position
    dey
.add_ay_to_player_y_position
    clc
    adc object_y_low
    sta object_y_low
    tya
    adc object_y_high
    sta object_y_high
    txa
    clc
    adc object_y_low + objectid_player_accessory
    sta object_y_low + objectid_player_accessory
    tya
    adc object_y_high + objectid_player_accessory
    sta object_y_high + objectid_player_accessory
.return4
    rts

.play_ring_sound
    lda #0
    ldx #<sound2
    ldy #>sound2
    jmp play_sound_yx

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
; ####      |    |                    ####
; ###       |    |                     ###
; ###       |    |                     ###
;           |    |                     ###
;           |    |                     ###
;           |    |                     ###
;           |    |                     ###
; ######    |    |    ####################
; ######    |    |    ####################
; ###       |    |                     ###
; ###       |    |                     ###
; ###       |    |                     ###
; ###       |    |                     ###
; ###       |    |                     ###
; ###       |    |                     ###
;                                      ###
;                                      ###
;                                      ###
;                                OOOOOO###
; ######              P          OOOOOO###
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
; draw 255x20 rectangle at (37,2)
    ldx #&25 ; '%'
    ldy #2
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x3 rectangle at (0,2)
    ldx #0
    lda #3
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,9)
    ldy #9
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,9)
    ldx #3
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (20,9)
    ldx #&14
    lda #&11
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (0,21)
    ldx #0
    ldy #&15
    lda #6
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_rock_in_top_corner_cells
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw table at (34,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&22 ; '"'
    ldy #&14
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (31,20) of size (3x2)
    dex
    dex
    dex
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (10,2) length 15
    ldx #&0a
    ldy #2
    lda #&0f
    jsr draw_rope
; draw rope at (15,2) length 15
    ldx #&0f
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
    ldx #3
    ldy #&0e
    lda #4
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #5
    jsr update_brazier_and_fire
    ldx #&22 ; '"'
    ldy #9
    lda #3
    jmp update_level_completion

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
; ####   |                        |   ####
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |                        |    ###
; ###    |     ##############     |    ###
; ###    |     ##############     |    ###
; ###    |                        |
; ###    |                        |
; ###    |
; ###
; ###                 P             ######
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
; draw 3x15 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 6x1 rectangle at (34,21)
    ldx #&22 ; '"'
    ldy #&15
    lda #6
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 14x2 rectangle at (13,15)
    ldx #&0d
    ldy #&0f
    lda #&0e
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_rock_in_top_corner_cells
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (7,2) length 18
    ldx #7
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (32,2) length 17
    ldx #&20 ; ' '
    lda #&11
    jsr draw_rope
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.ring_bounce_y_table
    equb 8, 6, 5, 4, 3, 2, 2, 1, 0

; check for first update in room (branch if not)
.update_sea_lion_and_ring
    lda update_room_first_update_flag
    beq update_ring_bouncing
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq update_room_only
    lda #&60 ; '`'
    sta ring_y_position
.update_room_only
    lda desired_room_index
    cmp #0
    bne update_sea_lion_local
    ldx #&14
    ldy #&0f
    lda #spriteid_sea_lion_body
    jsr draw_sprite_a_at_cell_xy
    lda #objectid_sea_lion_head
    jsr set_object_position_from_cell_xy
.update_sea_lion_local
    jmp update_sea_lion

.update_ring_bouncing
    ldy ring_bounce_cycle_animation_step
    iny
    cpy #&1a
    bcc store_ring_bounce_animation_step_y
    ldy #0
.store_ring_bounce_animation_step_y
    sty ring_bounce_cycle_animation_step
    tya
    sec
    sbc #8
    bcc update_sea_lion
    tay
    sec
    sbc #9
    bcs bounce_down
    lda ring_bounce_y_table,y
    eor #&ff
    clc
    adc #1
    jmp add_a_to_ring_y_position

.bounce_down
    sta remember_a
    lda #9
    clc
    sbc remember_a
    tay
    lda ring_bounce_y_table,y
.add_a_to_ring_y_position
    clc
    adc ring_y_position
    sta ring_y_position
.update_sea_lion
    lda desired_room_index
    cmp #0
    bne return5
    ldx #spriteid_sea_lion_head2b
    stx object_spriteid + objectid_sea_lion_head
    lda save_game_level_p_ring_animation
    cmp #ring_on_magnet
    beq return5
    ldx #spriteid_sea_lion_head1
    stx object_spriteid + objectid_sea_lion_head
    tax
    bne return5
    lda ring_bounce_cycle_animation_step
    cmp #8
    bcc set_ring_object
    cmp #&19
    bne set_alternative_sea_lion_head
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne set_ring_object
    jsr play_landing_sound
    jmp set_ring_object

.set_alternative_sea_lion_head
    ldx #spriteid_sea_lion_head2b
    stx object_spriteid + objectid_sea_lion_head
.set_ring_object
    lda #spriteid_ring
    sta object_spriteid + objectid_ring
    lda #&a6
    sta object_x_low + objectid_ring
    lda ring_y_position
    sta object_y_low + objectid_ring
    lda #&a0
    sta object_z_order + objectid_ring
    lda #&f7
    sta temp_top_offset
    ldx #objectid_old_ring
    ldy #objectid_magnet
    jsr test_for_collision_between_objects_x_and_y
    beq return5
    lda #ring_on_magnet
    sta save_game_level_p_ring_animation
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    jsr play_ring_sound
.return5
    rts

; check for first update in room (branch if not)
.update_magnet_and_rod
    lda update_room_first_update_flag
    beq magnet_and_rod_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_room
    lda save_game_level_p_magnet_x
    beq set_magnet_fully_left
    lda save_game_level_p_magnet_direction
    beq initialise_room
    bpl set_magnet_fully_right
    lda #&0c
    bne set_magnet_x                                                  ; ALWAYS branch

.set_magnet_fully_right
    lda #&1b
    bne set_magnet_x                                                  ; ALWAYS branch

.set_magnet_fully_left
    lda #&0c
.set_magnet_x
    sta save_game_level_p_magnet_x
    lda #0
    sta save_game_level_p_magnet_direction
.initialise_room
    lda desired_room_index
    cmp #0
    bne update_magnet_local
    ldx #&0b
    ldy #2
    lda #spriteid_left_bar
    jsr draw_sprite_a_at_cell_xy
    inx
    inx
    lda #spriteid_horizontal_bar
.draw_horizontal_bar_loop
    jsr draw_sprite_a_at_cell_xy
    inx
    cpx #&1b
    bcc draw_horizontal_bar_loop
    lda #spriteid_right_bar
    jsr draw_sprite_a_at_cell_xy
    lda #spriteid_rope_with_magnet
    sta object_spriteid + objectid_magnet
    lda #&c0
    sta object_z_order + objectid_short_bar
.update_magnet_local
    jmp update_magnet

.magnet_and_rod_not_first_update
    lda save_game_level_p_magnet_direction
    bne set_short_bar_object_if_in_room_0
; magnet is not moving. check for player magnet collision
    ldx #objectid_player
    ldy #objectid_magnet
    jsr test_for_collision_between_objects_x_and_y
    beq update_magnet
    lda object_room_collision_flags
    and #4
    bne set_magnet_going_right
    lda object_room_collision_flags
    and #1
    beq update_magnet
    lda #&ff
    sta save_game_level_p_magnet_direction
    bne set_short_bar_object_if_in_room_0
.set_magnet_going_right
    lda #1
    sta save_game_level_p_magnet_direction
.set_short_bar_object_if_in_room_0
    lda desired_room_index
    cmp #0
    bne move_magnet_bar
    ldx save_game_level_p_magnet_x
    ldy #2
    lda #objectid_short_bar
    jsr set_object_position_from_cell_xy
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_short_bar
    lda #spriteid_short_bar
    sta object_spriteid + objectid_short_bar
.move_magnet_bar
    lda save_game_level_p_magnet_x
    clc
    adc save_game_level_p_magnet_direction
    sta save_game_level_p_magnet_x
    cmp #&0c
    beq magnet_at_end_of_bar
    cmp #&1b
    beq magnet_at_end_of_bar
    lda desired_room_index
    cmp #0
    bne update_magnet
; play magnet moving along bar sound
    lda #&40 ; '@'
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    jmp update_magnet

.magnet_at_end_of_bar
    lda #0
    sta save_game_level_p_magnet_direction
    lda desired_room_index
    cmp #0
    bne update_magnet
    lda sound_priority_per_channel_table
    cmp #&41 ; 'A'
    bcs skip_reset_sound_priorities
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table+1
.skip_reset_sound_priorities
    jsr play_landing_sound
.update_magnet
    lda desired_room_index
    cmp #0
    bne return6
; set magnet object position
    ldx save_game_level_p_magnet_x
    ldy #2
    lda #objectid_magnet
    jsr set_object_position_from_cell_xy
; set collision map for magnet
    iny
    iny
    iny
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq check_for_player_ring_collision
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    lda #collision_map_none
    sta value_to_write_to_collision_map
    dex
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    inx
    inx
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.check_for_player_ring_collision
    lda save_game_level_p_ring_animation
    cmp #ring_on_magnet
    bne return6
; collision check
    ldx #objectid_old_player
    ldy #objectid_ring
    jsr test_for_collision_between_objects_x_and_y
    beq no_player_ring_collision1
; collided. hide ring, add to toolbar
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    lda #&ff
    sta save_game_level_p_ring_animation
    lda #spriteid_ring_menu_item
    jsr find_or_create_menu_slot_for_A
    jmp return6

.no_player_ring_collision1
    ldx save_game_level_p_magnet_x
    lda #&ff
    sta temp_sprite_x_offset
    ldy #2
    lda #&2d ; '-'
    sta temp_sprite_y_offset
    lda #objectid_ring
    jsr set_object_position_from_cell_xy
    lda #spriteid_ring
    sta object_spriteid + objectid_ring
    lda #&a0
    sta object_z_order + objectid_ring
.return6
    rts

.ring_animations
    equb 8
    equb &80
    equb 0, 8
    equb 0, 0
.ring_fall_to_side_animation
    equb 0, 0
    equb   8, &f8
    equb   6, &f8
    equb   6, &fa
    equb   6, &fc
    equb   6, &fe
    equb   6, &ff
    equb &80
.ring_fall_off_edge_animation
    equb 6, 1
    equb 6, 2
    equb 6, 4
    equb 6, 6
    equb 4, 8
    equb 2, 8
    equb &80
.ring_straight_down_animation
    equb 0, 8
    equb &80
.ring_stationary_animation
    equb 0, 0
    equb &80
.ring_bounced_off_wall_animation
    equb 4, 2
    equb 3, 3
    equb 2, 4
    equb 1, 6
    equb &80

; check for first update in room (branch if so)
.update_ring
    lda update_room_first_update_flag
    bne initialise_ring
    jmp update_ring_not_first_update

.initialise_ring
    lda #spriteid_ring_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_ring
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_ring_room_changed_only
    lda save_game_level_p_ring_animation
    bmi initialise_ring_room_changed_only
    cmp #ring_fall_to_side_animation - ring_animations
    bcc initialise_ring_room_changed_only
    cmp #ring_stationary_animation - ring_animations
    beq initialise_ring_room_changed_only
    dec fast_forward_ring_movement_steps
.initialise_ring_room_changed_only
    lda desired_room_index
    cmp save_game_level_p_ring_room
    bne hide_ring1
    lda save_game_level_p_ring_animation
    bmi hide_ring1
    cmp #ring_fall_to_side_animation - ring_animations
    bcc hide_ring1
    jsr update_ring_object
.fast_forward_ring_loop
    lda desired_room_index
    cmp save_game_level_p_ring_room
    bne hide_ring1
    lda fast_forward_ring_movement_steps
    beq hide_ring1
    dec fast_forward_ring_movement_steps
    ldx #objectid_ring
    jsr copy_object_state_to_old
    jsr update_ring_animation
    jmp fast_forward_ring_loop

.hide_ring1
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_ring
.return7_local
    jmp return7

.update_ring_not_first_update
    lda #0
    sta just_used_ring
    lda player_held_object_spriteid
    sta remember_held_object
    lda object_spriteid_old + objectid_ring
    sta ring_sprite_as_drawn
    lda save_game_level_p_ring_animation
    bmi check_for_using_the_ring
    cmp #ring_fall_to_side_animation - ring_animations
    bcc return7_local
    lda desired_room_index
    cmp save_game_level_p_ring_room
    beq update_ring_in_room
    lda fast_forward_ring_movement_steps
    bmi return7_local
    inc fast_forward_ring_movement_steps
    jmp return7

.check_for_using_the_ring
    lda #spriteid_ring_menu_item
    cmp player_using_object_spriteid
    bne return7_local
    cmp previous_player_using_object_spriteid
    beq return7_local
    dec just_used_ring
    lda desired_room_index
    sta save_game_level_p_ring_room
    lda object_direction
    sta save_game_level_p_ring_direction_without_bounces
    sta save_game_level_p_ring_direction_with_bounces
    lda object_x_low + objectid_player_accessory
    sta save_game_level_p_ring_x_low
    lda object_x_high + objectid_player_accessory
    sta save_game_level_p_ring_x_high
    lda object_y_low + objectid_player_accessory
    sta save_game_level_p_ring_y_low
    lda object_y_high + objectid_player_accessory
    sta save_game_level_p_ring_y_high
    lda #ring_fall_to_side_animation - ring_animations
    sta save_game_level_p_ring_animation_step
    sta save_game_level_p_ring_animation
    jsr update_ring_object
    ldx #objectid_ring
    jsr copy_object_state_to_old
    lda #spriteid_one_pixel_masked_out
    sta player_held_object_spriteid
.update_ring_in_room
    jsr update_ring_animation
    lda desired_room_index
    cmp save_game_level_p_ring_room
    beq check_player_ring_collision
    lda #0
    sta fast_forward_ring_movement_steps
.check_player_ring_collision
    lda ring_sprite_as_drawn
    sta object_spriteid_old + objectid_ring
    ldy #&0d                                                          ; redundant instruction
    lda just_used_ring                                                ; redundant instruction
    ldy #objectid_ring
    ldx #objectid_old_player
    jsr test_for_collision_between_objects_x_and_y
    ldx remember_held_object
    stx player_held_object_spriteid
    ora #0
    beq no_player_ring_collision2
    lda just_used_ring
    bne taken_ring
    lda #spriteid_ring_menu_item
    jsr find_or_create_menu_slot_for_A
.taken_ring
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
    lda #&ff
    sta save_game_level_p_ring_animation
    jmp return7

.no_player_ring_collision2
    lda just_used_ring
    beq check_for_ring_moving
    lda #spriteid_ring_menu_item
    jsr remove_item_from_toolbar_menu
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_player_accessory
    sta player_using_object_spriteid
    sta player_held_object_spriteid
.check_for_ring_moving
    lda object_x_low + objectid_ring
    cmp object_x_low_old + objectid_ring
    beq check_ring_movement_in_y
    lda save_game_level_p_ring_direction_with_bounces
    bmi ring_moving_left1
    inc temp_right_offset
    jmp check_ring_rock_collision

.ring_moving_left1
    dec temp_left_offset
.check_ring_rock_collision
    lda #1
    sta temp_bottom_offset
    lda #objectid_ring
    jsr get_solid_rock_collision_for_object_a
    beq check_ring_movement_in_y
    jsr play_ring_sound
    jmp return7

.check_ring_movement_in_y
    lda object_y_low + objectid_ring
    cmp object_y_low_old + objectid_ring
    beq return7
    dec temp_top_offset
    lda #2
    sta temp_bottom_offset
    lda #objectid_ring
    jsr get_solid_rock_collision_for_object_a
    beq return7
    jsr play_ring_sound
.return7
    rts

.update_ring_animation
    lda save_game_level_p_ring_animation_step
    clc
    adc #2
    tay
    lda ring_animations,y
    cmp #&80
    bne got_next_ring_animation_step_in_y
    ldy save_game_level_p_ring_animation
.got_next_ring_animation_step_in_y
    lda save_game_level_p_ring_direction_with_bounces
    bmi ring_moving_left2
    inc temp_right_offset
    jmp check_for_ring_rock_collision

.ring_moving_left2
    dec temp_left_offset
.check_for_ring_rock_collision
    lda #1
    sta temp_bottom_offset
    lda #objectid_ring
    jsr get_solid_rock_collision_for_object_a
    beq check_ring_falling_to_side
; bounce the ring by inverting the X direction
    lda save_game_level_p_ring_direction_with_bounces
    eor #&fe
    sta save_game_level_p_ring_direction_with_bounces
.check_ring_falling_to_side
    lda save_game_level_p_ring_animation
    cmp #ring_fall_to_side_animation - ring_animations
    bne check_ring_hitting_floor
    dec temp_top_offset
    lda #objectid_ring
    jsr get_solid_rock_collision_for_object_a
    bne ring_collided_so_fall_straight_down
    cpy save_game_level_p_ring_animation
    bne store_ring_animation_step
.ring_collided_so_fall_straight_down
    lda #ring_straight_down_animation - ring_animations
    sta save_game_level_p_ring_animation
    ldy #ring_fall_off_edge_animation - ring_animations
.check_ring_hitting_floor
    lda #objectid_ring
    jsr update_object_hitting_floor
    lda save_game_level_p_ring_animation
    cmp #ring_straight_down_animation - ring_animations
    bne check_ring_fallen_off_edge_direction
    lda object_has_hit_floor_flag
    beq store_ring_animation_step
    ldy #ring_stationary_animation - ring_animations
    sty save_game_level_p_ring_animation
.check_ring_fallen_off_edge_direction
    lda object_just_fallen_off_edge_direction
    beq store_ring_animation_step
    ldy #ring_straight_down_animation - ring_animations
    sty save_game_level_p_ring_animation
    ldy #ring_bounced_off_wall_animation - ring_animations
    ldx #1
    stx save_game_level_p_ring_direction_with_bounces
    ora #0
    bpl store_ring_animation_step
    ldx #&ff
    stx save_game_level_p_ring_direction_with_bounces
.store_ring_animation_step
    sty save_game_level_p_ring_animation_step
    lda save_game_level_p_ring_animation
    cmp #ring_stationary_animation - ring_animations
    bne get_animation_movement_in_x_position
    lda #0
    sta fast_forward_ring_movement_steps
.get_animation_movement_in_x_position
    lda ring_animations,y
    ldx save_game_level_p_ring_direction_with_bounces
    bpl sign_extend_a_to_ax
    eor #&ff
    clc
    adc #1
.sign_extend_a_to_ax
    ldx #0
    ora #0
    bpl add_ax_to_ring_x_position
    dex
.add_ax_to_ring_x_position
    clc
    adc save_game_level_p_ring_x_low
    sta save_game_level_p_ring_x_low
    txa
    adc save_game_level_p_ring_x_high
    sta save_game_level_p_ring_x_high
    iny
    lda ring_animations,y
    ldx #0
    ora #0
    bpl add_ax_to_ring_y_position
    dex
.add_ax_to_ring_y_position
    clc
    adc save_game_level_p_ring_y_low
    sta save_game_level_p_ring_y_low
    txa
    adc save_game_level_p_ring_y_high
    sta save_game_level_p_ring_y_high
    jsr update_ring_object
    lda #objectid_ring
    jsr update_object_a_solid_rock_collision
    lda object_x_low + objectid_ring
    sta save_game_level_p_ring_x_low
    lda object_x_high + objectid_ring
    sta save_game_level_p_ring_x_high
    lda object_y_low + objectid_ring
    sta save_game_level_p_ring_y_low
    lda object_y_high + objectid_ring
    sta save_game_level_p_ring_y_high
    ldx #objectid_ring
    jsr find_left_and_right_of_object
    jsr find_top_and_bottom_of_object
    lda save_game_level_p_ring_direction_with_bounces
    bmi check_if_ring_should_move_one_room_left
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return8
; move ring right one room
    lda save_game_level_p_ring_x_low
    sec
    sbc #&40 ; '@'
    sta save_game_level_p_ring_x_low
    lda #0
    sbc #0
    sta save_game_level_p_ring_x_high
    inc save_game_level_p_ring_room
    jmp hide_ring2

.check_if_ring_should_move_one_room_left
    lda object_right_cell_x
    bpl return8
    lda save_game_level_p_ring_x_low
    clc
    adc #&40 ; '@'
    sta save_game_level_p_ring_x_low
    lda #1
    sta save_game_level_p_ring_x_high
    dec save_game_level_p_ring_room
.hide_ring2
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_ring
.return8
    rts

.update_ring_object
    lda #spriteid_erase1
    sta object_erase_type + objectid_ring
    lda #&a0
    sta object_z_order + objectid_ring
    lda save_game_level_p_ring_x_low
    sta object_x_low + objectid_ring
    lda save_game_level_p_ring_x_high
    sta object_x_high + objectid_ring
    lda save_game_level_p_ring_y_low
    sta object_y_low + objectid_ring
    lda save_game_level_p_ring_y_high
    sta object_y_high + objectid_ring
    lda #spriteid_ring
    sta object_spriteid + objectid_ring
    lda save_game_level_p_ring_direction_without_bounces
    sta object_direction + objectid_ring
    rts

.just_used_ring
    equb 0
.remember_held_object
    equb 0
.ring_sprite_as_drawn
    equb   0, &60
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
.sound2
    equw &0013                                                        ; channel
    equw 6                                                            ; amplitude
    equw 201                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %00110000
    equb %00011000
    equb %10001100
    equb %11000110
    equb %01100011
    equb %00110001
    equb %00011000
    equb %00001100
.ground_fill_2x2_top_right
    equb %00001100
    equb %00011000
    equb %00110001
    equb %01100011
    equb %11000110
    equb %10001100
    equb %00011000
    equb %00110000
.ground_fill_2x2_bottom_left
    equb %00001100
    equb %00011000
    equb %00110001
    equb %01100011
    equb %11000110
    equb %10001100
    equb %00011000
    equb %00110000
.ground_fill_2x2_bottom_right
    equb %00110000
    equb %00011000
    equb %10001100
    equb %11000110
    equb %01100011
    equb %00110001
    equb %00011000
    equb %00001100
IF swr_renderer_enabled
INCLUDE "build/runtime/levelP_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelP.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelP"
ENDIF
ENDIF
.pydis_end

save "build/dataP", pydis_start, pydis_end
