; *************************************************************************************
;
; Level M: 'HAMSTER-JAM'
;
; Save game variables:
;
;     save_game_level_m_hamster_animation                        ($0a3f):
;               0: untouched
;              1+: animations for hamster
;             $3b: hamster jam landed
;
;     save_game_level_m_got_tulip_bulb_progress                  ($0a40):
;               0: untouched
;        1, 9, 14: tulip bulb animations
;             $ff: taken
;
;     save_game_level_m_tulip_bulb_x_animation_step              ($0a41):
;               step within animations above
;
;     save_game_level_m_tulip_bulb_x_low                         ($0a42):
;     save_game_level_m_tulip_bulb_x_high                        ($0a43):
;               position of tulip bulb (x coordinate)
;
;     save_game_level_m_tulip_bulb_y                             ($0a44):
;               position of tulip bulb (y coordinate)
;
;     save_game_level_m_tulip_bulb_direction1                    ($0a45):
;                 1: pointing right
;               $ff: pointing left
;
;     save_game_level_m_tulip_bulb_room                          ($0a46):
;               room that the tulip bulb is in
;
;     save_game_level_m_tulip_bulb_direction2                    ($0a47):
;               same as save_game_level_m_tulip_bulb_direction1
;
;     save_game_level_m_tulip_bulb_y_animation_step              ($0a48):
;               animation step for a falling tulip bulb
;
;     save_game_level_m_tulip_growth_index                       ($0a49):
;               0: not growing
;           1-$44: growing
;             $45: fully grown
;
; Solution:
;
;   1. Jump on the block to the right as the cat, and between the cat and the monkey
;      traverse the rest of the obstacles to exit the room.
;   2. Get the tulip bulb under the sign. Exit to the left using the middle exit.
;   3. Climb onto the rope and descend to the bottom. Time falling off the rope
;      to squash the hamster.
;   4. Drop the tulip bulb onto the hamster jam. (A tulip grows)
;   5. Climb the tulip to exit the room to the left.
;   6. Climb the three ropes, and turn into the cat on the final block.
;   7. Jump across to collect the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_block                        = 3
objectid_fire1                        = 2
objectid_fire2                        = 3
objectid_hamster_body                 = 7
objectid_hamster_feet_or_jam          = 5
objectid_old_tulip_bulb               = 17
objectid_rope_end                     = 2
objectid_rope_to_block                = 4
objectid_sparkles                     = 2
objectid_tulip_bulb                   = 6
objectid_tulip_head                   = 6
spriteid_erase1                       = 207
spriteid_erase2                       = 212
spriteid_erase3                       = 218
spriteid_flying_hamster_jam           = 213
spriteid_frayed_rope_end              = 205
spriteid_hamster_body                 = 228
spriteid_hamster_jam                  = 214
spriteid_hamster_legs_1               = 208
spriteid_hamster_legs_2               = 209
spriteid_hamster_legs_3               = 210
spriteid_hamster_legs_4               = 211
spriteid_hamster_looking_back         = 215
spriteid_horizontal_rope              = 202
spriteid_left_hook                    = 200
spriteid_long_rope                    = 203
spriteid_long_rope_to_block           = 227
spriteid_right_hook                   = 201
spriteid_short_rope                   = 204
spriteid_short_rope_to_block1         = 225
spriteid_short_rope_to_block2         = 226
spriteid_sign                         = 219
spriteid_tall_block                   = 206
spriteid_tulip_bulb                   = 217
spriteid_tulip_bulb_menu_item         = 216
spriteid_tulip_flower1                = 224
spriteid_tulip_flower2                = 223
spriteid_tulip_flower3                = 222
spriteid_tulip_head                   = 220
spriteid_tulip_stalk                  = 221

; Memory locations
l0070                                               = &0070
room_exit_direction                                 = &0070
temp_y                                              = &0070
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
save_game_level_m_hamster_animation                 = &0a3f
save_game_level_m_got_tulip_bulb_progress           = &0a40
save_game_level_m_tulip_bulb_x_animation_step       = &0a41
save_game_level_m_tulip_bulb_x_low                  = &0a42
save_game_level_m_tulip_bulb_x_high                 = &0a43
save_game_level_m_tulip_bulb_y                      = &0a44
save_game_level_m_tulip_bulb_direction1             = &0a45
save_game_level_m_tulip_bulb_room                   = &0a46
save_game_level_m_tulip_bulb_direction2             = &0a47
save_game_level_m_tulip_bulb_y_animation_step       = &0a48
save_game_level_m_tulip_growth_index                = &0a49
block_y_position                                    = &0a6f
hamster_animation_step                              = &0a70
hamster_x                                           = &0a71
hamster_y                                           = &0a72
hamster_direction                                   = &0a73
tulip_bulb_steps_to_catch_up_while_offscreen        = &0a74

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelM_sprite_table - level_data
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
    equb 3
.initial_room_index_cheat
    equb 2
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "HAMSTER-JAM", &0D

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
.developer_mode_inactive
    lda save_game_level_m_got_tulip_bulb_progress
    bpl set_rock_tiles
    lda #spriteid_tulip_bulb_menu_item
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
    jsr room_3_update_handler
    jsr room_1_update_handler
    jsr update_hamster
    jsr room_2_update_handler
    jsr update_tulip_growth
    jsr room_0_update_handler
    rts

.draw_top_and_bottom_rows_of_rock
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
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
; Room 0 initialisation and game loop
; 
; *************************************************************************************
.room_0_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ####      |    |    |               ####
; ###       |    |    |                ###
; ###       |    |    |                ###
; ###       |    |    |                ###
; ###       |    |    |                ###
; ###       |    |   OSO        ##########
; ###       |    |   OOO        ##########
; ###       |    |
; ###       |    |
; ###       |    |
; ###       |    |
; ###       |   OSO
; ###       |   OOO                  #####
; ###       |                        #####
; ###       |                          ###
; ###       |                          ###
; ###       |                          ###
; ###                                  ###
; ########                             ###
; #############       P                ###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_0_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x20 rectangle at (0,2)
    ldx #0
    ldy #2
    lda #3
    sta width_in_cells
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (37,16)
    ldy #&10
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (35,14)
    ldx #&23 ; '#'
    ldy #&0e
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x2 rectangle at (30,7)
    ldx #&1e
    ldy #7
    lda #7
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (3,20)
    ldx #3
    ldy #&14
    lda #5
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 10x1 rectangle at (3,21)
    iny
    lda #&0a
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (10,2) length 17
    ldx #&0a
    ldy #2
    lda #&11
    jsr draw_rope
; draw rope at (15,2) length 12
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&0f
    ldy #2
    lda #&0c
    jsr draw_rope
; draw tall block at (14,13) of size (3x2)
    dex
    ldy #&0d
    lda #spriteid_tall_block
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw short rope to block2 at (15,13)
    inx
    lda #spriteid_short_rope_to_block2
    jsr draw_sprite_a_at_cell_xy
; draw rope at (20,2) length 6
    ldx #&14
    ldy #2
    lda #6
    jsr draw_rope
; draw tall block at (19,7) of size (3x2)
    dex
    ldy #7
    lda #spriteid_tall_block
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw short rope to block2 at (20,7)
    inx
    lda #spriteid_short_rope_to_block2
    jsr draw_sprite_a_at_cell_xy
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
    ldx #3
    ldy #&0a
    lda #objectid_fire2
    jsr update_brazier_and_fire
    ldx #&21 ; '!'
    ldy #7
    lda #2
    jmp update_level_completion

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
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; 
; 
; 
;               ############
;               ############
; #####                              #####
; #####                              #####
; ###
; ###
; ###
; ###
; ###
; ###                 P              #####
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_1_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x7 rectangle at (0,2)
    ldx #0
    ldy #2
    lda #3
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (37,2)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (0,16)
    ldx #0
    ldy #&10
    lda #6
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,14)
    ldy #&0e
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (35,14)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 12x2 rectangle at (14,12)
    ldx #&0e
    ldy #&0c
    lda #&0c
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 12x1 rectangle at (35,21)
    ldx #&23 ; '#'
    ldy #&15
    lda #1
    sta height_in_cells
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

.hamster_animations
    equb 0
.hamster_walk_animation
    equb spriteid_hamster_legs_1
    equb 2, 0
    equb spriteid_hamster_legs_2
    equb 2, 0
    equb spriteid_hamster_legs_3
    equb 2, 0
    equb spriteid_hamster_legs_4
    equb 2, 0
    equb &ff
.hamster_look_back_animation
    equb spriteid_hamster_looking_back
    equb 0, 0
.hamster_static_animation
    equb spriteid_hamster_legs_4
    equb 0, 0
    equb &ff
.hamster_jam_flying
    equb spriteid_one_pixel_masked_out
    equb 0, 0
    equb spriteid_flying_hamster_jam
    equb 0, 0
    equb spriteid_flying_hamster_jam
    equb &f8,   2
    equb spriteid_flying_hamster_jam
    equb &f8,   3
    equb spriteid_flying_hamster_jam
    equb &fa,   4
    equb spriteid_flying_hamster_jam
    equb &fa,   5
    equb spriteid_flying_hamster_jam
    equb &fb,   6
    equb spriteid_flying_hamster_jam
    equb &fc,   6
    equb spriteid_flying_hamster_jam
    equb &fd,   7
    equb spriteid_flying_hamster_jam
    equb &fe,   7
    equb spriteid_flying_hamster_jam
    equb &fe,   8
    equb &ff
.hamster_jam_static_animation
    equb spriteid_flying_hamster_jam
    equb 0, 8
    equb &ff
.hamster_jam_landed_animation
    equb spriteid_hamster_jam
    equb 0, 0
    equb &ff

; check for first update in room (branch if not)
.update_hamster
    lda update_room_first_update_flag
    beq update_hamster_animation_step
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_changed_only1
    lda save_game_level_m_hamster_animation
    beq initalise_to_hamster_walk_animation
    cmp #hamster_walk_animation - hamster_animations
    beq initalise_to_hamster_walk_animation
    cmp #hamster_look_back_animation - hamster_animations
    bne set_hamster_jam_landed
.initalise_to_hamster_walk_animation
    ldy #hamster_walk_animation - hamster_animations
    lda #&a0
    sta hamster_x
    lda #&60 ; '`'
    sta hamster_y
    lda #1
    sta hamster_direction
    jmp set_hamster_animation

.set_hamster_jam_landed
    ldy #hamster_jam_landed_animation - hamster_animations
    lda #&44 ; 'D'
    sta hamster_x
    lda #&b0
    sta hamster_y
    lda #1
    sta hamster_direction
.set_hamster_animation
    sty save_game_level_m_hamster_animation
    sty hamster_animation_step
.room_changed_only1
    lda desired_room_index
    cmp #1
    bne set_hamster_objects_local
; initialise hamster when entering room 1
    lda #spriteid_erase2
    sta object_erase_type + objectid_hamster_feet_or_jam
    lda #&e0
    sta object_z_order + objectid_hamster_feet_or_jam
    lda #&df
    sta object_z_order + objectid_hamster_body
.set_hamster_objects_local
    jmp set_hamster_objects

.update_hamster_animation_step
    lda hamster_animation_step
    clc
    adc #3
    tay
    lda hamster_animations,y
    cmp #&ff
    bne set_hamster_static_animation
    ldy save_game_level_m_hamster_animation
.set_hamster_static_animation
    cpy #hamster_static_animation - hamster_animations
    bne check_if_hamster_is_looking_back
    lda hamster_direction
    eor #&fe
    sta hamster_direction
.check_if_hamster_is_looking_back
    lda save_game_level_m_hamster_animation
    cmp #hamster_look_back_animation - hamster_animations
    bne check_if_hamster_is_walking
    cpy save_game_level_m_hamster_animation
    bne set_hamster_animation_step
    ldy #hamster_walk_animation - hamster_animations
    sty save_game_level_m_hamster_animation
.check_if_hamster_is_walking
    lda save_game_level_m_hamster_animation
    cmp #hamster_walk_animation - hamster_animations
    bne set_hamster_animation_step
    ldx hamster_x
    lda hamster_direction
    bmi hamster_looking_left
    cpx #&c0
    bne set_hamster_animation_step
    beq set_hamster_looking_back                                      ; ALWAYS branch

.hamster_looking_left
    cpx #&80
    beq set_hamster_looking_back
    cpx #&9c
    bne set_hamster_animation_step
    lda block_y_position
    cmp #&48 ; 'H'
    bcc set_hamster_animation_step
.set_hamster_looking_back
    ldy #hamster_look_back_animation - hamster_animations
    sty save_game_level_m_hamster_animation
    jmp set_hamster_animation_step                                    ; redundant instruction

.set_hamster_animation_step
    sty hamster_animation_step
    iny
    lda hamster_animations,y
    ldx hamster_direction
    bpl hamster_looking_right
    eor #&ff
    clc
    adc #1
.hamster_looking_right
    clc
    adc hamster_x
    sta hamster_x
    iny
    lda hamster_animations,y
    clc
    adc hamster_y
    sta hamster_y
    cmp #&b0
    bcc set_hamster_objects
    lda #&b0
    sta hamster_y
    lda #hamster_jam_landed_animation - hamster_animations
    cmp save_game_level_m_hamster_animation
    beq set_hamster_objects
    sta save_game_level_m_hamster_animation
    sta hamster_animation_step
    lda desired_room_index
    cmp #1
    bne set_hamster_objects
    jsr play_landing_sound
.set_hamster_objects
    lda desired_room_index
    cmp #1
    bne return1
    lda hamster_x
    sta object_x_low + objectid_hamster_feet_or_jam
    sta object_x_low + objectid_hamster_body
    lda hamster_y
    sta object_y_low + objectid_hamster_feet_or_jam
    sta object_y_low + objectid_hamster_body
    lda hamster_direction
    sta object_direction + objectid_hamster_feet_or_jam
    sta object_direction + objectid_hamster_body
    ldy hamster_animation_step
    lda hamster_animations,y
    ldx #spriteid_one_pixel_masked_out
    cmp #spriteid_hamster_legs_1
    bcc set_hamster_sprites
    cmp #spriteid_erase2
    bcs set_hamster_sprites
    ldx #spriteid_hamster_body
.set_hamster_sprites
    sta object_spriteid + objectid_hamster_feet_or_jam
    stx object_spriteid + objectid_hamster_body
.return1
    rts

; check for first update in room (branch if so)
.room_1_update_handler
    lda update_room_first_update_flag
    bne initialise_room_1
    jmp update_room_1

; check for level change (branch if not)
.initialise_room_1
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_changed_only2
    lda #&50 ; 'P'
    sta block_y_position
.room_changed_only2
    lda desired_room_index
    cmp #1
    beq initialise
    jmp position_rope_and_write_to_collision_map_local

.initialise
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
    ldx #<envelope4
    ldy #>envelope4
    jsr define_envelope
    ldx #&10
    ldy #2
    lda #spriteid_left_hook
    jsr draw_sprite_a_at_cell_xy
    inx
    inx
    lda #spriteid_horizontal_rope
.draw_horizontal_rope
    jsr draw_sprite_a_at_cell_xy
    inx
    cpx #&1e
    bcc draw_horizontal_rope
    inx
    lda #spriteid_right_hook
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    lda #&50 ; 'P'
    sec
    sbc block_y_position
    clc
    adc #&5c ; '\'
    lsr a
    lsr a
    lsr a
    tay
    dey
.draw_rope_loop1
    lda #spriteid_long_rope
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dey
    cpy #3
    bcs draw_rope_loop1
    lda #objectid_rope_end
    jsr set_object_position_from_cell_xy
    lda #spriteid_frayed_rope_end
    sta object_spriteid + objectid_rope_end
    ldx #&10
    lda block_y_position
    and #4
    beq draw_long_rope_sprites
    lda block_y_position
    sec
    sbc #&0c
    lsr a
    lsr a
    lsr a
    tay
    lda #spriteid_short_rope
    jsr draw_sprite_a_at_cell_xy
.draw_long_rope_sprites
    lda block_y_position
    lsr a
    lsr a
    lsr a
    tay
    dey
    dey
    cpy #3
    bcc draw_block
    lda #spriteid_long_rope
.draw_rope_loop2
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_rope_loop2
.draw_block
    lda #objectid_block
    dex
    jsr set_object_position_from_cell_xy
    inx
    lda #spriteid_tall_block
    sta object_spriteid + objectid_block
    lda #spriteid_erase1
    sta object_erase_type + objectid_block
    lda #&c0
    sta object_z_order + objectid_block
    lda #objectid_rope_to_block
    jsr set_object_position_from_cell_xy
    tax
    jsr copy_object_state_to_old
    lda #spriteid_short_rope_to_block2
    sta object_spriteid + objectid_rope_to_block
    lda #&bf
    sta object_z_order + objectid_rope_to_block
    ldx #&0f
    ldy #&0a
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.position_rope_and_write_to_collision_map_local
    jmp position_rope_and_write_to_collision_map

.update_room_1
    lda desired_room_index
    cmp #1
    bne move_block_position_up
    lda current_player_character
    cmp #6
    bne move_block_position_up
    lda object_x_high
    sta l0070
    lda object_x_low
    lsr l0070
    ror a
    lsr l0070
    ror a
    lsr l0070
    ror a
    cmp #&14
    bcc move_block_position_up
    lda current_player_animation
    cmp #monkey_climb_animation - monkey_base_animation
    beq player_is_a_climbing_monkey
    cmp #monkey_climb_idle_animation - monkey_base_animation
    beq player_is_a_climbing_monkey
    cmp #monkey_climb_down_animation - monkey_base_animation
    bne move_block_position_up
.player_is_a_climbing_monkey
    lda block_y_position
    cmp #&20 ; ' '
    beq position_rope_and_write_to_collision_map_local
; move player and accessory up
    lda object_y_low
    clc
    adc #4
    sta object_y_low
    lda object_y_low + objectid_player_accessory
    clc
    adc #4
    sta object_y_low + objectid_player_accessory
; move block down
    lda block_y_position
    sec
    sbc #4
    sta block_y_position
; check if the player is in room 1
    lda desired_room_index
    cmp #1
    bne position_rope_and_write_to_collision_map_local
; play rope movement sound
    jsr play_sound5
; set end of rope sprites
    lda #spriteid_short_rope_to_block2
    sta object_spriteid_old + objectid_rope_to_block
    sta object_spriteid + objectid_rope_to_block
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_rope_end
    jmp position_rope_and_write_to_collision_map

.move_block_position_up
    lda block_y_position
    cmp #&50 ; 'P'
    bcs position_rope_and_write_to_collision_map_local
    ldx #&0c
    ldy #spriteid_short_rope
    adc #4
    cmp #&50 ; 'P'
    bcs store_block_y_position
    ldx #&10
    ldy #spriteid_long_rope
    adc #4
.store_block_y_position
    sta block_y_position
    stx unused_x_value
    sty unused_rope_spriteid
    lda desired_room_index
    cmp #1
    bne check_if_rope_is_moving
; set rope sprites
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_rope_to_block
    lda #spriteid_long_rope_to_block
    sta object_spriteid + objectid_rope_to_block
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_rope_end
.check_if_rope_is_moving
    lda block_y_position
    cmp #&50 ; 'P'
    beq rope_is_at_rest_so_check_for_hamster_being_squashed
    lda desired_room_index
    cmp #1
    bne position_rope_and_write_to_collision_map
    jsr play_sound5
    jmp position_rope_and_write_to_collision_map

.rope_is_at_rest_so_check_for_hamster_being_squashed
    lda save_game_level_m_hamster_animation
    cmp #hamster_jam_static_animation - hamster_animations
    beq make_sound_for_block_landing_or_hamster_jam_landing
    cmp #hamster_jam_landed_animation - hamster_animations
    beq make_sound_for_block_landing_or_hamster_jam_landing
    ldx hamster_x
    lda hamster_direction
    bmi hamster_looking_left1
    cpx #&98
    bcc hamster_just_killed
    bcs make_sound_for_block_landing_or_hamster_jam_landing
.hamster_looking_left1
    cpx #&9c
    bcc hamster_just_killed
    bcs make_sound_for_block_landing_or_hamster_jam_landing
.hamster_just_killed
    lda #hamster_jam_static_animation - hamster_animations
    sta save_game_level_m_hamster_animation
    lda #hamster_jam_flying - hamster_animations
    sta hamster_animation_step
    lda #&70 ; 'p'
    sta hamster_x
    lda #1
    sta hamster_direction
    lda desired_room_index
    cmp #1
    bne position_rope_and_write_to_collision_map
; hamster death sound
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    jmp position_rope_and_write_to_collision_map

.make_sound_for_block_landing_or_hamster_jam_landing
    lda desired_room_index
    cmp #1
    bne position_rope_and_write_to_collision_map
; block landing sound
    lda #0
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
.position_rope_and_write_to_collision_map
    lda desired_room_index
    cmp #1
    bne return2
    lda #&50 ; 'P'
    sec
    sbc block_y_position
    clc
    adc #&58 ; 'X'
    sta object_y_low + objectid_rope_end
    ldx #&1f
    clc
    adc #4
    lsr a
    lsr a
    lsr a
    tay
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #collision_map_none
    jsr write_a_single_value_to_cell_in_collision_map
    lda block_y_position
    sta object_y_low + objectid_block
    sta object_y_low + objectid_rope_to_block
.return2
    rts

.unused_x_value
    equb 0
.unused_rope_spriteid
    equb 0

.play_sound5
    lda #0
    ldx #<sound5
    ldy #>sound5
    jmp play_sound_yx

.tulip_flower_animation
    equb spriteid_tulip_flower1
    equb spriteid_tulip_flower2
    equb spriteid_tulip_flower3

.return3_local
    jmp return3

.update_tulip_growth
    lda save_game_level_m_tulip_growth_index
    beq return3_local
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq tulip_stalk_is_drawn
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq draw_stalk_at_corrent_position
; set tulip animation to finished growing
    lda #&45 ; 'E'
    sta save_game_level_m_tulip_growth_index
.draw_stalk_at_corrent_position
    lda desired_room_index
    cmp #1
    bne tulip_stalk_is_drawn
    lda save_game_level_m_tulip_growth_index
    sec
    sbc #8
    bcc tulip_stalk_is_drawn
    sta temp_y
    ldy #&38 ; '8'
    sec
    sbc #&3b ; ';'
    bcs calculate_y_position_of_top_of_stalk
    asl temp_y
    lda #&ac
    sec
    sbc temp_y
    tay
.calculate_y_position_of_top_of_stalk
    tya
    clc                                                               ; redundant instruction
    tay                                                               ; redundant instruction
    tya                                                               ; redundant instruction
    and #7
    sta temp_sprite_y_offset
; calculate cell y for stalk by dividing by eight
    tya
    lsr a
    lsr a
    lsr a
    tay
    ldx #8
    lda #spriteid_tulip_stalk
.draw_tulip_stalk_loop
    cpy #&15
    bcs tulip_stalk_is_drawn
    jsr draw_sprite_a_at_cell_xy
    iny
    bne draw_tulip_stalk_loop
.tulip_stalk_is_drawn
    lda desired_room_index
    cmp #1
    beq update_tulip_head_object
.increment_tulip_growth_animation_local
    jmp increment_tulip_growth_animation

.update_tulip_head_object
    lda #&40 ; '@'
    sta object_x_low + objectid_tulip_head
    lda #0
    sta object_x_high + objectid_tulip_head
    sta object_spriteid + objectid_tulip_head
    lda #1
    sta object_direction + objectid_tulip_head
    lda save_game_level_m_tulip_growth_index
    sec
    sbc #8
    bcc increment_tulip_growth_animation_local
    sta l0070
    lda #&ff
    sta object_erase_type + objectid_tulip_head
    lda #&f0
    sta object_z_order + objectid_tulip_head
    lda l0070
    sec
    sbc #&3b ; ';'
    bcs update_tulip_flower
    asl l0070
    lda #&ac
    sec
    sbc l0070
    sta object_y_low + objectid_tulip_head
    lda #spriteid_tulip_head
    sta object_spriteid + objectid_tulip_head
; nothing to erase
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_tulip_head
    jmp set_tulip_collision_map

.update_tulip_flower
    tay
    lda tulip_flower_animation,y
    sta object_spriteid + objectid_tulip_head
    lda #&38 ; '8'
    sta object_y_low + objectid_tulip_head
    lda object_spriteid + objectid_tulip_head
    cmp object_spriteid_old + objectid_tulip_head
    bne finished_animating_head_so_nothing_to_erase
    lda object_y_low + objectid_tulip_head
    cmp object_y_low_old + objectid_tulip_head
    beq set_tulip_collision_map
.finished_animating_head_so_nothing_to_erase
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_tulip_head
.set_tulip_collision_map
    lda object_y_low + objectid_tulip_head
    cmp #&89
    bcs increment_tulip_growth_animation
    ldx #8
    ldy #2
    lda #1
    sta width_in_cells
    lda #&14
    sta height_in_cells
    lda #collision_map_rope
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq set_tulip_head_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.set_tulip_head_collision_map
    lda object_y_low + objectid_tulip_head
    sec
    sbc #6
    lsr a
    lsr a
    lsr a
    tay
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
; check for first update in room (branch if so)
.increment_tulip_growth_animation
    lda update_room_first_update_flag
    bne return3
    lda save_game_level_m_tulip_growth_index
    beq return3
    cmp #&45 ; 'E'
    beq return3
    inc save_game_level_m_tulip_growth_index
.return3
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
; ####    |           |          |    ####
; ###     |           |          |     ###
; ###     |           |          |     ###
; ###     |          S|          |     ###
; ###     |                      |     ###
; ###     |                      |     ###
; ###     |                      |     ###
;         |                      |
;         |                      |
;         |                      |
;         |   ################   |
;         |   ################   |
; #####   |                      |   #####
; #####   |                      |   #####
;         |                      |     ###
;         |                      |     ###
;         |                      |     ###
;         |                      |     ###
;                                      ###
; #####               P                ###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_2_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x7 rectangle at (0,2)
    ldx #0
    ldy #2
    lda #3
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (37,2)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x6 rectangle at (37,16)
    ldy #&10
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (35,14)
    ldx #&23 ; '#'
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,12)
    ldx #&0c
    ldy #&0c
    lda #&10
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (0,21)
    ldx #0
    ldy #&15
    lda #5
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (8,2) length 18
    ldx #8
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (31,2) length 18
    ldx #&1f
    jsr draw_rope
; draw rope at (20,2) length 4
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&14
    ldy #2
    lda #4
    jsr draw_rope
; draw sign at (19,5)
    dex
    ldy #5
    lda #spriteid_sign
    jsr draw_sprite_a_at_cell_xy
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

.tulip_bulb_x_animations
    equb 0
.tulip_bulb_x_animation0
    equb 0
    equb 7
    equb 7
    equb 7
    equb 6
    equb 6
    equb 5
    equb &80
.tulip_bulb_x_animation1
    equb 4
    equb 3
    equb 2
    equb 1
    equb &80
.tulip_bulb_x_animation2
    equb 0
    equb &80
.tulip_bulb_y_animations
    equb 1
    equb 2
    equb 3
    equb 4
    equb 6
    equb 8
    equb &80

.return4
    rts

.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    ldx #3
    ldy #6
    lda #objectid_fire1
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #objectid_fire2
    jsr update_brazier_and_fire
    lda save_game_level_m_tulip_growth_index
    bne return4
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne initialise_room_2
    jmp room_2_not_first_update

.initialise_room_2
    lda #spriteid_tulip_bulb_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_tulip_bulb
    sta collectable_spriteids+1
    sta collectable_being_used_spriteids + 1
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_change_only
    lda save_game_level_m_got_tulip_bulb_progress
    beq initialise_tulip_bulb
    bmi room_change_only
    dec tulip_bulb_steps_to_catch_up_while_offscreen
    jmp room_change_only

.initialise_tulip_bulb
    lda #&a1
    sta save_game_level_m_tulip_bulb_x_low
    lda #0
    sta save_game_level_m_tulip_bulb_x_high
    lda #1
    sta save_game_level_m_tulip_bulb_direction1
    sta save_game_level_m_tulip_bulb_direction2
    lda #&5b ; '['
    sta save_game_level_m_tulip_bulb_y
    lda #2
    sta save_game_level_m_tulip_bulb_room
    lda #tulip_bulb_x_animation2 - tulip_bulb_x_animations
    sta save_game_level_m_got_tulip_bulb_progress
    sta save_game_level_m_tulip_bulb_x_animation_step
.room_change_only
    lda desired_room_index
    cmp save_game_level_m_tulip_bulb_room
    bne hide_bulb1
    lda save_game_level_m_got_tulip_bulb_progress
    bmi hide_bulb1
    jsr update_tulip_bulb_object
.fast_forward_tulip_bulb
    lda desired_room_index
    cmp save_game_level_m_tulip_bulb_room
    bne hide_bulb1
    lda tulip_bulb_steps_to_catch_up_while_offscreen
    beq hide_bulb1
    dec tulip_bulb_steps_to_catch_up_while_offscreen
    ldx #objectid_tulip_bulb
    jsr copy_object_state_to_old
    jsr update_tulip
    jmp fast_forward_tulip_bulb

.hide_bulb1
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_tulip_bulb
.return5_local
    jmp return5

.room_2_not_first_update
    lda #0
    sta player_just_used_tulip_bulb_flag
    lda player_held_object_spriteid
    sta remember_player_help_sprite
    lda object_spriteid_old + objectid_tulip_bulb
    sta remember_old_tulip_bulb_sprite
    lda save_game_level_m_got_tulip_bulb_progress
    bmi player_is_holding_tulip_bulb
    lda desired_room_index
    cmp save_game_level_m_tulip_bulb_room
    beq tulip_is_in_current_room
    lda tulip_bulb_steps_to_catch_up_while_offscreen
    bmi return5_local
    inc tulip_bulb_steps_to_catch_up_while_offscreen
    jmp return5

.player_is_holding_tulip_bulb
    lda #spriteid_tulip_bulb_menu_item
    cmp player_using_object_spriteid
    bne return5_local
    cmp previous_player_using_object_spriteid
    beq return5_local
; player just used the tulip bulb
    dec player_just_used_tulip_bulb_flag
    lda desired_room_index
; set up tulip bulb object
    sta save_game_level_m_tulip_bulb_room
    lda object_direction
    sta save_game_level_m_tulip_bulb_direction1
    sta save_game_level_m_tulip_bulb_direction2
    lda object_x_low + objectid_player_accessory
    sta save_game_level_m_tulip_bulb_x_low
    lda object_x_high + objectid_player_accessory
    sta save_game_level_m_tulip_bulb_x_high
    lda object_y_low + objectid_player_accessory
    sta save_game_level_m_tulip_bulb_y
    lda #tulip_bulb_x_animation0 - tulip_bulb_x_animations
    sta save_game_level_m_tulip_bulb_x_animation_step
    sta save_game_level_m_got_tulip_bulb_progress
    lda #0
    sta save_game_level_m_tulip_bulb_y_animation_step
    jsr update_tulip_bulb_object
    ldx #objectid_tulip_bulb
    jsr copy_object_state_to_old
    lda #0
    sta player_held_object_spriteid
.tulip_is_in_current_room
    jsr update_tulip
    lda desired_room_index
    cmp save_game_level_m_tulip_bulb_room
    beq check_for_tulib_bulb_player_collision
    lda #0
    sta tulip_bulb_steps_to_catch_up_while_offscreen
.check_for_tulib_bulb_player_collision
    lda remember_old_tulip_bulb_sprite
    sta object_spriteid_old + objectid_tulip_bulb
    ldx #objectid_old_player
    ldy #objectid_tulip_bulb
    jsr test_for_collision_between_objects_x_and_y
    ldx remember_player_help_sprite
    stx player_held_object_spriteid
    ora #0
    beq check_if_bulb_just_used
    lda player_just_used_tulip_bulb_flag
    bne take_bulb
    lda #spriteid_tulip_bulb_menu_item
    jsr find_or_create_menu_slot_for_A
.take_bulb
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_tulip_bulb
    lda #&ff
    sta save_game_level_m_got_tulip_bulb_progress
    jmp return5

.check_if_bulb_just_used
    lda player_just_used_tulip_bulb_flag
    beq check_for_bulb_movement
    lda #spriteid_tulip_bulb_menu_item
    jsr remove_item_from_toolbar_menu
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_player_accessory
    sta player_using_object_spriteid
    sta player_held_object_spriteid
.check_for_bulb_movement
    lda object_x_low + objectid_tulip_bulb
    cmp object_x_low_old + objectid_tulip_bulb
    beq check_for_bulb_movement_in_y
    lda save_game_level_m_tulip_bulb_direction2
    bmi moving_bulb_left
    inc temp_right_offset
    jmp moving_bulb

.moving_bulb_left
    dec temp_left_offset
.moving_bulb
    lda #1
    sta temp_bottom_offset
    lda #objectid_tulip_bulb
    jsr get_solid_rock_collision_for_object_a
    bne bulb_landed
.check_for_bulb_movement_in_y
    lda object_y_low + objectid_tulip_bulb
    cmp object_y_low_old + objectid_tulip_bulb
    beq return5
; check for room collision
    dec temp_top_offset
    lda #2
    sta temp_bottom_offset
    lda #objectid_tulip_bulb
    jsr get_solid_rock_collision_for_object_a
    beq return5
.bulb_landed
    jsr play_landing_sound
.return5
    rts

.update_tulip
    lda save_game_level_m_tulip_bulb_room
    cmp #1
    bne move_bulb_x_position1
    ldx #objectid_old_tulip_bulb
    ldy #objectid_hamster_feet_or_jam
    jsr test_for_collision_between_objects_x_and_y
    beq move_bulb_x_position1
; the tulip bulb is planted in the ground with hamster jam
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_tulip_bulb
; start growing
    lda #1
    sta save_game_level_m_tulip_growth_index
    lda #0
    sta tulip_bulb_steps_to_catch_up_while_offscreen
.move_bulb_x_position1
    lda save_game_level_m_tulip_bulb_x_animation_step
    clc
    adc #1
    tay
    lda tulip_bulb_x_animations,y
    cmp #&80
    bne check_animation
    ldy save_game_level_m_got_tulip_bulb_progress
.check_animation
    lda save_game_level_m_got_tulip_bulb_progress
    cmp #tulip_bulb_x_animation0 - tulip_bulb_x_animations
    bne check_if_tulip_bulb_x_animation1
    cpy save_game_level_m_got_tulip_bulb_progress
    bne set_bulb_animation_step
    ldy #tulip_bulb_x_animation1 - tulip_bulb_x_animations
    sty save_game_level_m_got_tulip_bulb_progress
    jmp set_bulb_animation_step

.check_if_tulip_bulb_x_animation1
    cpy #tulip_bulb_x_animation1 - tulip_bulb_x_animations
    bne update_bulb_animation
    ldy #tulip_bulb_x_animation2 - tulip_bulb_x_animations
    sty save_game_level_m_got_tulip_bulb_progress
.update_bulb_animation
    lda #objectid_tulip_bulb
    jsr update_object_hitting_floor
    beq set_bulb_animation_step
    lda object_just_fallen_off_edge_direction
    beq set_bulb_animation_step
    ldy #tulip_bulb_x_animation1 - tulip_bulb_x_animations
    sty save_game_level_m_got_tulip_bulb_progress
.set_bulb_animation_step
    sty save_game_level_m_tulip_bulb_x_animation_step
    lda tulip_bulb_x_animations,y
    ldx save_game_level_m_tulip_bulb_direction2
    bpl sign_extending_a_to_ax
    eor #&ff
    clc
    adc #1
.sign_extending_a_to_ax
    ldx #0
    ora #0
    bpl move_bulb_x_position2
    dex
.move_bulb_x_position2
    clc
    adc save_game_level_m_tulip_bulb_x_low
    sta save_game_level_m_tulip_bulb_x_low
    txa
    adc save_game_level_m_tulip_bulb_x_high
    sta save_game_level_m_tulip_bulb_x_high
    ldy save_game_level_m_tulip_bulb_y_animation_step
    lda #2
    sta temp_bottom_offset
    lda #objectid_tulip_bulb
    jsr get_solid_rock_collision_for_object_a
    beq update_bulb_y_position
    ldy #0
    lda save_game_level_m_got_tulip_bulb_progress
    cmp #tulip_bulb_x_animation2 - tulip_bulb_x_animations
    bne update_bulb_y_position
    sty tulip_bulb_steps_to_catch_up_while_offscreen
.update_bulb_y_position
    lda tulip_bulb_y_animations,y
    clc
    adc save_game_level_m_tulip_bulb_y
    sta save_game_level_m_tulip_bulb_y
    iny
    lda tulip_bulb_y_animations,y
    cmp #&80
    bne save_bulb_animation_step
    dey
.save_bulb_animation_step
    sty save_game_level_m_tulip_bulb_y_animation_step
    jsr update_tulip_bulb_object
    lda #objectid_tulip_bulb
    jsr update_object_a_solid_rock_collision
    lda object_x_low + objectid_tulip_bulb
    sta save_game_level_m_tulip_bulb_x_low
    lda object_x_high + objectid_tulip_bulb
    sta save_game_level_m_tulip_bulb_x_high
    lda object_y_low + objectid_tulip_bulb
    sta save_game_level_m_tulip_bulb_y
    ldx #objectid_tulip_bulb
    jsr find_left_and_right_of_object
    lda save_game_level_m_tulip_bulb_direction2
    bmi move_bulb_one_room_left
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return6
; move bulb to next room to the right
    lda save_game_level_m_tulip_bulb_x_low
    sec
    sbc #&40 ; '@'
    sta save_game_level_m_tulip_bulb_x_low
    lda #0
    sbc #0
    sta save_game_level_m_tulip_bulb_x_high
    inc save_game_level_m_tulip_bulb_room
    jmp hide_bulb

.move_bulb_one_room_left
    lda object_right_cell_x
    bpl return6
    lda save_game_level_m_tulip_bulb_x_low
    clc
    adc #&40 ; '@'
    sta save_game_level_m_tulip_bulb_x_low
    lda #1
    sta save_game_level_m_tulip_bulb_x_high
    dec save_game_level_m_tulip_bulb_room
.hide_bulb
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_tulip_bulb
.return6
    rts

.update_tulip_bulb_object
    lda #spriteid_erase3
    sta object_erase_type + objectid_tulip_bulb
    lda #&f0
    sta object_z_order + objectid_tulip_bulb
    lda save_game_level_m_tulip_bulb_x_low
    sta object_x_low + objectid_tulip_bulb
    lda save_game_level_m_tulip_bulb_x_high
    sta object_x_high + objectid_tulip_bulb
    lda save_game_level_m_tulip_bulb_y
    sta object_y_low + objectid_tulip_bulb
    lda #spriteid_tulip_bulb
    sta object_spriteid + objectid_tulip_bulb
    lda save_game_level_m_tulip_bulb_direction1
    sta object_direction + objectid_tulip_bulb
    rts

.player_just_used_tulip_bulb_flag
    equb 0
.remember_player_help_sprite
    equb 0
.remember_old_tulip_bulb_sprite
    equb 0
    equb &60                                                          ; unused
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
; ####    |           |           |   ####
; ###     |           |           |    ###
; ###     |           |           |    ###
; ###     |           |           |    ###
; ###     |           |           |    ###
; ###     |           |           |    ###
; ###     |           |           |    ###
;         |           |           |    ###
;         |    OOO    |    OOO    |    ###
;         |    OOO         OOO    |    ###
;         |   #####       #####   |    ###
;         |   #####       #####   |    ###
; #####   |                       |    ###
; #####   |                       |    ###
; ###     |                       |    ###
; ###     |                       |    ###
; ###                                  ###
; ###                                  ###
; ###                               OOO###
; ###                 P             OOO###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_3_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x7 rectangle at (0,2)
    ldx #0
    ldy #2
    lda #3
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x20 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,14)
    ldx #0
    ldy #&0e
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 2x2 rectangle at (3,14)
    ldx #3
    dec width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (12,12)
    ldx #&0c
    ldy #&0c
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (24,12)
    ldx #&18
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw tall block at (13,10) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&0d
    ldy #&0a
    lda #spriteid_tall_block
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw tall block at (25,10) of size (3x2)
    ldx #&19
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw tall block at (34,20) of size (3x2)
    ldx #&22 ; '"'
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (8,2) length 16
    ldx #8
    ldy #2
    lda #&10
    jsr draw_rope
; draw rope at (32,2) length 16
    ldx #&20 ; ' '
    jsr draw_rope
; draw rope at (20,2) length 9
    ldx #&14
    lda #9
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
    ldy #6
    lda #objectid_fire2
    jmp update_brazier_and_fire

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
.sound5
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
.envelope4
    equb 7                                                            ; envelope number
    equb 2                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 120                                                          ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 246                                                          ; change of amplitude per step during sustain phase
    equb 246                                                          ; change of amplitude per step during release phase
    equb 120                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound2
    equw &0010                                                        ; channel
    equw 7                                                            ; amplitude
    equw 3                                                            ; pitch
    equw 2                                                            ; duration
.envelope3
    equb 8                                                            ; envelope number
    equb 130                                                          ; step length (100ths of a second)
    equb 252                                                          ; pitch change per step in section 1
    equb 254                                                          ; pitch change per step in section 2
    equb 255                                                          ; pitch change per step in section 3
    equb 20                                                           ; number of steps in section 1
    equb 40                                                           ; number of steps in section 2
    equb 80                                                           ; number of steps in section 3
    equb 0                                                            ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 0                                                            ; change of amplitude per step during release phase
    equb 0                                                            ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound1
    equw &0011                                                        ; channel
    equw 8                                                            ; amplitude
    equw 128                                                          ; pitch
    equw 2                                                            ; duration
.ground_fill_2x2_top_left
    equb %10000001
    equb %00000110
    equb %00011000
    equb %01100000
    equb %10000000
    equb %10000000
    equb %01000011
    equb %01001100
.ground_fill_2x2_top_right
    equb %10001001
    equb %01000110
    equb %01000000
    equb %00100000
    equb %00100000
    equb %11000000
    equb %00000000
    equb %00001100
.ground_fill_2x2_bottom_left
    equb %00110000
    equb %00000000
    equb %00001110
    equb %00010001
    equb %10010001
    equb %10010001
    equb %01001110
    equb %01000000
.ground_fill_2x2_bottom_right
    equb %00110010
    equb %01000010
    equb %01000001
    equb %00100001
    equb %00100000
    equb %00010000
    equb %00010000
    equb %00001000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelM_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelM.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelM"
ENDIF
ENDIF
.pydis_end

save "build/dataM", pydis_start, pydis_end
