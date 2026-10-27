; *************************************************************************************
;
; Level K: 'DRIPPING-STUFF'
;
; Save game variables:
;
;     save_game_level_k_plant_top_y                              ($0a33):
;             $70: plant starting y position
;             $50: plant grown once y position
;             $30: plant grown twice y position
;             $10: plant full y position
;
;     save_game_level_k_plant_growth_timer                       ($0a34):
;               0: not growing
;           1-$15: growing
;            $80+: being poisoned
;
;     save_game_level_k_got_bottle_flag                          ($0a35):
;               0: bottle not got
;               1: empty bottle taken
;             $ff: full bottle taken
;
;     save_game_level_k_poison_in_bottle_flag                    ($0a36):
;               0: no poison in bottle
;             $ff: poison in bottle
;
;     save_game_level_k_dog_animation:                           ($0a37):
;               1: dead
;               5: drinking
;             $1b: pushing player
;             $3a: stunned before dying
;
;     save_game_level_k_poison_dog_animation_step                ($0a38):
;               a timer for the dog's death sequence
;
; Solution:
;
;   1. Collect the bottle from the leftmost room
;   2. Hold the bottle under the drip in the initial room to fill with water
;   3. pour the water onto the stem of the plant one room to the right
;   4. repeat until plant is fully grown (reaches ceiling)
;   5. climb plant and go to room to the right
;   6. Fill bottle with poison from the drip
;   7. go to the leftmost room and climb the rope to the dog
;   8. pour the poison into the dog bowl (the dog dies) and jump over to reach the spell
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
inkey_key_g                           = 172
inkey_key_p                           = 200
objectid_bottle_pour                  = 2
objectid_dog_body                     = 5
objectid_dog_bowl                     = 7
objectid_dog_head                     = 6
objectid_drip                         = 3
objectid_empty_bottle                 = 3
objectid_leaf1                        = 4
objectid_leaf2                        = 5
objectid_old_drip                     = 14
objectid_room2_fire1                  = 6
objectid_room2_fire2                  = 7
objectid_room_1_fire1                 = 4
objectid_room_1_fire2                 = 5
objectid_room_3_fire                  = 4
objectid_spell                        = 4
objectid_top_of_stalk                 = 3
spriteid_bucket                       = 216
spriteid_dog_body                     = 233
spriteid_dog_bowl1                    = 236
spriteid_dog_bowl2                    = 237
spriteid_dog_dead                     = 232
spriteid_dog_head                     = 234
spriteid_dog_head_licking             = 235
spriteid_droplet                      = 218
spriteid_droplet1                     = 219
spriteid_droplet2                     = 220
spriteid_droplet3                     = 221
spriteid_droplet4                     = 222
spriteid_empty_bottle                 = 210
spriteid_empty_bottle_held            = 211
spriteid_empty_bottle_menu_item       = 214
spriteid_emptying_bottle              = 213
spriteid_erase_1                      = 209
spriteid_erase_2                      = 228
spriteid_erase_3                      = 231
spriteid_full_bottle                  = 204
spriteid_full_bottle_held             = 212
spriteid_full_bottle_menu_item        = 215
spriteid_leaf                         = 205
spriteid_leaf_grow1                   = 208
spriteid_leaf_grow2                   = 207
spriteid_leaf_grow3                   = 206
spriteid_leaf_wilt_1                  = 224
spriteid_leaf_wilt_2                  = 225
spriteid_leaf_wilt_3                  = 226
spriteid_leaf_wilt_4                  = 227
spriteid_pour                         = 223
spriteid_shelf                        = 229
spriteid_shelf_support                = 230
spriteid_splash                       = 217
spriteid_stalk                        = 200
spriteid_stalk_bottom_end             = 201
spriteid_stalk_top_end                = 202
spriteid_stalk_top_end_short          = 203

; Memory locations
room_exit_direction                                 = &0070
stalk_cell_y_min                                    = &0070
temp_stalk_y                                        = &0070
temp_y                                              = &0070
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
save_game_level_k_plant_top_y                       = &0a33
save_game_level_k_plant_growth_timer                = &0a34
save_game_level_k_got_bottle_flag                   = &0a35
save_game_level_k_poison_in_bottle_flag             = &0a36
save_game_level_k_dog_animation                     = &0a37
save_game_level_k_poison_dog_animation_step         = &0a38
room_1_drip_timer                                   = &0a6f
bottle_pour_x_low                                   = &0a70
bottle_pour_x_high                                  = &0a71
bottle_pour_y                                       = &0a72
bottle_pour_animation_step                          = &0a73
bottle_pour_direction                               = &0a74
room_3_drip_timer                                   = &0a75
dog_animation_step                                  = &0a76

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelK_sprite_table - level_data
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
    encode "DRIPPING-STUFF", &0D

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
    beq set_ground_tile
    lda developer_flags
    bpl developer_mode_inactive1
; in developer mode, we have the bottle filled with poison
    lda #&ff
    sta save_game_level_k_got_bottle_flag
    lda #&ff
    sta save_game_level_k_poison_in_bottle_flag
.developer_mode_inactive1
    lda save_game_level_k_got_bottle_flag
    beq set_ground_tile
; add full or empty bottle to taskbar
    cmp #&ff
    beq add_full_bottle_to_toolbar
    lda #spriteid_empty_bottle_menu_item
    jsr find_or_create_menu_slot_for_A
    jmp set_ground_tile

.add_full_bottle_to_toolbar
    lda #spriteid_full_bottle_menu_item
    jsr find_or_create_menu_slot_for_A
.set_ground_tile
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
    jsr room_2_update_handler
    jsr update_dog_puzzle
    rts

.draw_top_and_bottom_rows
    ldx #0
    ldy #0
    lda #&ff
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    ldy #&16
    jmp copy_rectangle_of_memory_to_screen

.draw_top_left_and_right_corners
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
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 14                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ####
; ###
; ###
; ###
; ###
; #################       ################
; #################       ################
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ######                            ######
; ######                            ######
; 
; 
; 
; 
;               P
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_2_code
    jsr draw_top_and_bottom_rows
; draw 3x15 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (37,7)
    ldx #&25 ; '%'
    ldy #7
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 14x2 rectangle at (3,7)
    ldx #3
    lda #&0e
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 13x2 rectangle at (24,7)
    ldx #&18
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,15)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 1x1 rectangle at (3,2)
    ldx #3
    ldy #2
    lda #1
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
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
; right of room 2 is room 3
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

.growing_leaf_animation
    equb spriteid_leaf_grow1
    equb spriteid_leaf_grow2
    equb spriteid_leaf_grow3
.full_leaf
    equb spriteid_leaf
.leaf_wilt_animation
    equb spriteid_leaf_wilt_4
    equb spriteid_leaf_wilt_3
    equb spriteid_leaf_wilt_2
.leaf_start_wilting
    equb spriteid_leaf_wilt_1

.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
; update the two brazier fires
    ldx #3
    ldy #&0c
    lda #objectid_room2_fire1
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #objectid_room2_fire2
    jsr update_brazier_and_fire
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne initialise_room_2
    jmp update_room_2

; check for level change (branch if not)
.initialise_room_2
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_changed_only
; initialise plant top y value
    lda save_game_level_k_plant_top_y
    bne check_plant_growth_timer
; set initial height of the plant
    lda #&70 ; 'p'
    sta save_game_level_k_plant_top_y
    lda #0
    sta save_game_level_k_plant_growth_timer
    beq room_changed_only                                             ; ALWAYS branch

.check_plant_growth_timer
    lda save_game_level_k_plant_growth_timer
    bmi initialise_poisoned_plant
    beq room_changed_only
; reset timer and grow plant by 32 pixels
    lda #0
    sta save_game_level_k_plant_growth_timer
    lda save_game_level_k_plant_top_y
    sec
    sbc #&20 ; ' '
    sta save_game_level_k_plant_top_y
    jmp room_changed_only

; poisoned plant starts at maximum height
.initialise_poisoned_plant
    lda #&10
    sta save_game_level_k_plant_top_y
    lda #&80
    sta save_game_level_k_plant_growth_timer
.room_changed_only
    lda desired_room_index
    cmp #2
    beq initialise_in_room_2
    jmp plant_is_growing_local1

.initialise_in_room_2
    ldy #&10
    lda save_game_level_k_plant_growth_timer
    bmi got_top_of_stalk_in_y
; calculate position of top of stalk
    ldy save_game_level_k_plant_top_y
    sec
    sbc #4
    bcc got_top_of_stalk_in_y
    asl a
    sta temp_stalk_y
    cmp #&20 ; ' '
    bcc got_temp_stalk_y
    lda #&20 ; ' '
    sta temp_stalk_y
.got_temp_stalk_y
    lda save_game_level_k_plant_top_y
    sec
    sbc temp_stalk_y
    tay
.got_top_of_stalk_in_y
    ldx #&14
    lda #1
    sta width_in_cells
    sta height_in_cells
    tya
    pha
    lsr a
    lsr a
    lsr a
    tay
    dey
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #collision_map_rope
    sta value_to_write_to_collision_map
    pla
    and #7
    sta temp_sprite_y_offset
    lda #spriteid_stalk_top_end
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    ldx #objectid_top_of_stalk
    jsr set_object_position_from_current_sprite_position
    ldx #&14
    iny
    lda #spriteid_stalk
.draw_stalk_to_bottom
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    iny
    cpy #&15
    bcc draw_stalk_to_bottom
; draw bottom of stalk
    lda #spriteid_stalk_bottom_end
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    lda save_game_level_k_plant_top_y
    lsr a
    lsr a
    lsr a
    tay
    lda full_leaf
    sta draw_leaf_sprite
    lda save_game_level_k_plant_growth_timer
    bpl draw_leaves
    tya
    sec
    sbc #4
    ldy #2
    jsr draw_leaves_on_stalk
    lda save_game_level_k_plant_top_y
    lsr a
    lsr a
    lsr a
    tay
    lda leaf_start_wilting
    sta draw_leaf_sprite
.draw_leaves
    lda #&12
    jsr draw_leaves_on_stalk
    lda #&e0
    sta object_z_order + objectid_leaf1
    sta object_z_order + objectid_leaf2
    lda #&ff
    sta object_direction + objectid_leaf2
.plant_is_growing_local1
    jmp plant_is_growing_or_poisoned

.draw_leaves_on_stalk
    sta stalk_cell_y_max
    sty stalk_cell_y_min
    sec
    sbc stalk_cell_y_min
    bmi return1
    beq return1
.draw_leaves_loop
    ldx #&14
    iny
    lda draw_leaf_sprite
    jsr draw_sprite_a_at_cell_xy
    ldx #objectid_leaf1
    jsr set_object_position_from_current_sprite_position
    ldx #&15
    lda #&ff
    sta temp_sprite_x_offset
    iny
    iny
    lda #&ff
    sta sprite_reflect_flag
    lda draw_leaf_sprite
    jsr draw_sprite_a_at_cell_xy
    ldx #objectid_leaf2
    jsr set_object_position_from_current_sprite_position
    iny
    cpy stalk_cell_y_max
    bcc draw_leaves_loop
.return1
    rts

.draw_leaf_sprite
    equb 0
.stalk_cell_y_max
    equb 0

.plant_is_growing_local2
    jmp plant_is_growing_or_poisoned

.update_room_2
    lda save_game_level_k_plant_growth_timer
    bne check_plant_timer
    lda desired_room_index
    cmp #2
    bne plant_is_growing_local2
    lda developer_flags
    bpl developer_mode_inactive2
; in developer mode 'G' grows the plant, and 'P' poisons it
    ldx #inkey_key_g
    jsr negative_inkey
    bne grow_plant
    ldx #inkey_key_p
    jsr negative_inkey
    bne poison_plant
.developer_mode_inactive2
    lda object_spriteid + objectid_bottle_pour
    cmp #spriteid_splash
    bne plant_is_growing_local2
    ldx #objectid_bottle_pour
    jsr find_left_and_right_of_object
    lda object_left_cell_x
    cmp #&15
    bcs plant_is_growing_local2
    lda object_right_cell_x
    cmp #&14
    bcc plant_is_growing_local2
    lda save_game_level_k_poison_in_bottle_flag
    bne poison_plant
.grow_plant
    lda save_game_level_k_plant_top_y
    cmp #&10
    beq plant_is_growing_or_poisoned
    jmp check_plant_timer

.poison_plant
    lda save_game_level_k_plant_top_y
    cmp #&10
    bne plant_is_growing_or_poisoned
    lda #&90
    sta save_game_level_k_plant_top_y
    lda #&80
    sta save_game_level_k_plant_growth_timer
.check_plant_timer
    lda save_game_level_k_plant_growth_timer
    bmi plant_is_poisoned
    lda save_game_level_k_plant_growth_timer
    cmp #&0f
    bcc increment_growth
    cmp #&15
    bcs finished_growing
.increment_growth
    clc
    adc #1
    sta save_game_level_k_plant_growth_timer
    jmp plant_is_growing_or_poisoned

.finished_growing
    lda #0
    sta save_game_level_k_plant_growth_timer
    lda save_game_level_k_plant_top_y
    sec
    sbc #&20 ; ' '
    sta save_game_level_k_plant_top_y
    jmp plant_is_growing_or_poisoned

.plant_is_poisoned
    lda save_game_level_k_plant_top_y
    cmp #&10
    beq plant_is_growing_or_poisoned
    lda save_game_level_k_plant_growth_timer
    cmp #&8f
    bcc increment_poisoning_state
    cmp #&8f
    bcs poison_stage_increases
.increment_poisoning_state
    clc
    adc #1
    sta save_game_level_k_plant_growth_timer
    jmp plant_is_growing_or_poisoned

.poison_stage_increases
    lda #&80
    sta save_game_level_k_plant_growth_timer
    lda save_game_level_k_plant_top_y
    sec
    sbc #&20 ; ' '
    sta save_game_level_k_plant_top_y
.plant_is_growing_or_poisoned
    lda desired_room_index
    cmp #2
    bne return2_local
    ldy #&10
    lda save_game_level_k_plant_growth_timer
    bmi update_stalk_top_object_and_collision_map
    ldy save_game_level_k_plant_top_y
    sec
    sbc #4
    bcc update_stalk_top_object_and_collision_map
    asl a
    sta temp_stalk_y
    cmp #&20 ; ' '
    bcc get_y_position_of_stalk
    lda #&20 ; ' '
    sta temp_stalk_y
.get_y_position_of_stalk
    lda save_game_level_k_plant_top_y
    sec
    sbc temp_stalk_y
    tay
.update_stalk_top_object_and_collision_map
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_top_of_stalk
    sta object_spriteid + objectid_top_of_stalk
    cpy object_y_low + objectid_top_of_stalk
    beq hide_leaf_objects_when_stalk_is_full
    sty object_y_low + objectid_top_of_stalk
    ldx #&14
    tya
    lsr a
    lsr a
    lsr a
    tay
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dey
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    lda #spriteid_stalk_top_end_short
    sta object_spriteid + objectid_top_of_stalk
    jmp hide_leaf_objects_when_stalk_is_full

.return2_local
    jmp return2

.hide_leaf_objects_when_stalk_is_full
    lda save_game_level_k_plant_top_y
    cmp #&10
    bne set_leaf_positions
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_leaf1
    sta object_spriteid_old + objectid_leaf2
    sta object_spriteid + objectid_leaf1
    sta object_spriteid + objectid_leaf2
    jmp return2

.set_leaf_positions
    lda save_game_level_k_plant_top_y
    sec
    sbc #&18
    sta object_y_low + objectid_leaf1
    lda save_game_level_k_plant_top_y
    sec
    sbc #8
    sta object_y_low + objectid_leaf2
    lda save_game_level_k_plant_growth_timer
    bmi update_plant_wilting
    bne plant_growing
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_leaf1
    sta object_spriteid_old + objectid_leaf2
.plant_growing
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_leaf1
    sta object_spriteid + objectid_leaf2
    lda save_game_level_k_plant_growth_timer
    sec
    sbc #&0a
    bcc return2_local
    ldy #3
    cmp #4
    bcs set_leaf2_sprite
    tay
.set_leaf2_sprite
    lda growing_leaf_animation,y
    sta object_spriteid + objectid_leaf2
    lda save_game_level_k_plant_growth_timer
    sec
    sbc #&12
    bcc return2
    ldy #3
    cmp #4
    bcs set_leaf1_sprite
    tay
.set_leaf1_sprite
    lda growing_leaf_animation,y
    sta object_spriteid + objectid_leaf1
    jmp return2

.update_plant_wilting
    and #&7f
    bne set_full_leaf
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne set_full_leaf
; copy to old, so the leaves don't get erased when the objects move
    ldx #objectid_leaf2
    jsr copy_object_state_to_old
    ldx #objectid_leaf1
    jsr copy_object_state_to_old
    lda full_leaf
    sta object_spriteid_old + objectid_leaf1
    sta object_spriteid_old + objectid_leaf2
.set_full_leaf
    lda full_leaf
    sta object_spriteid + objectid_leaf1
    sta object_spriteid + objectid_leaf2
    lda save_game_level_k_plant_growth_timer
    and #&7f
    sec
    sbc #4
    bcc return2
    ldy #3
    cmp #4
    bcs update_leaf2
    tay
.update_leaf2
    lda leaf_wilt_animation,y
    sta object_spriteid + objectid_leaf2
    lda save_game_level_k_plant_growth_timer
    and #&7f
    sec
    sbc #&0c
    bcc return2
    ldy #3
    cmp #4
    bcs update_leaf1
    tay
.update_leaf1
    lda leaf_wilt_animation,y
    sta object_spriteid + objectid_leaf1
.return2
    rts

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
;                                     ####
;                                      ###
;                                      ###
;                                      ###
;                                      ###
; ####################              S  S##
; ####################                 ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ######              ####################
; ######              ####################
;                                      ###
;                                      ###
;                                      ###
;                                      ###
;                     P                ###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_3_code
    jsr draw_top_and_bottom_rows
; draw 255x20 rectangle at (37,2)
    ldx #&25 ; '%'
    ldy #2
    lda #&14
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
; draw 17x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #&11
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 17x2 rectangle at (20,15)
    ldx #&14
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,15)
    ldx #3
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 1x1 rectangle at (36,2)
    ldx #&24 ; '$'
    ldy #2
    lda #1
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw shelf at (37,7)
    ldx #&25 ; '%'
    ldy #7
    lda #4
    sta temp_sprite_y_offset
    lda #&ff
    sta sprite_reflect_flag
    lda #spriteid_shelf
    jsr draw_sprite_a_at_cell_xy
; draw shelf support at (37,7)
    lda #4
    sta temp_sprite_y_offset
    lda #&ff
    sta sprite_reflect_flag
    lda #spriteid_shelf_support
    jsr draw_sprite_a_at_cell_xy
; draw full bottle at (34,7)
    ldx #&22 ; '"'
    lda #4
    sta temp_sprite_x_offset
    sta temp_sprite_y_offset
    lda #spriteid_full_bottle
    jsr draw_sprite_a_at_cell_xy
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
    ldy #&0c
    lda #objectid_room_3_fire
    jsr update_brazier_and_fire
    lda #&ff
    sta drip_is_poison_flag
    lda #8
    sta drip_start_frame
    lda #&40 ; '@'
    sta drip_initial_y
    lda #&13
    sta drip_timer_limit
    ldx #&10
    ldy #1
    lda room_3_drip_timer
    jsr update_drip
    sta room_3_drip_timer
    rts

.dog_death_sound
    lda #0
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    ldx #<sound2
    ldy #>sound2
    jmp play_sound_yx

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
; ####      |                   |     ####
; ###       |                   |      ###
; ###       |                   |      ###
; ###       |                   |      ###
; ###       |                   |      ###
; ###SOOO   |                   |      ###
; ###       |                   |      ###
; ###       |                   |      ###
; ###       |                   |      ###
; ###       |                   |      ###
; ###       |                   |      ###
; ###                           |      ###
; ###                           |      ###
; ###########################   |   ######
; ###########################   |   ######
; ###                           |
; ###                           |
; ###                           |
; ###
; ###                 P
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_0_code
    jsr draw_top_and_bottom_rows
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
; draw 24x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    lda #&18
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,15)
    ldx #&22 ; '"'
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_top_left_and_right_corners
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw shelf at (3,7) of size (4x1)
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #spriteid_shelf
    ldx #3
    ldy #7
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw shelf support at (3,7)
    lda #spriteid_shelf_support
    jsr draw_sprite_a_at_cell_xy
; draw rope at (10,2) length 11
    ldx #&0a
    ldy #2
    lda #&0b
    jsr draw_rope
; draw rope at (30,2) length 18
    ldx #&1e
    lda #&12
    jsr draw_rope
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.dog_head_animations
    equb 0
.dog_head_dead_animation
    equb 0, 0, 0
    equb &80
.dog_head_drinking_animation
    equb spriteid_dog_head
    equb &18, &ff
    equb spriteid_dog_head
    equb &18, &ff
    equb spriteid_dog_head
    equb &18, &ff
    equb spriteid_dog_head
    equb &18, &ff
    equb spriteid_dog_head_licking
    equb &18,   0
    equb spriteid_dog_head_licking
    equb &19,   0
    equb spriteid_dog_head_licking
    equb &19, &ff
    equb &80
.dog_head_push_animation
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb spriteid_dog_head
    equb &19, &fe
    equb &80
.dog_head_stunned_animation
    equb spriteid_dog_head
    equb &18, &fe
    equb &80

; check for first update in room (branch if not)
.update_dog_puzzle
    lda update_room_first_update_flag
    beq update_dog_head_animation
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_dog_puzzle
    lda save_game_level_k_poison_dog_animation_step
    beq set_dog_head_drinking_animation
    lda #dog_head_dead_animation - dog_head_animations
    sta save_game_level_k_dog_animation
    sta dog_animation_step
    jmp initialise_dog_puzzle

.set_dog_head_drinking_animation
    lda #dog_head_drinking_animation - dog_head_animations
    sta save_game_level_k_dog_animation
    sta dog_animation_step
.initialise_dog_puzzle
    lda desired_room_index
    cmp #0
    bne set_dog_head_object_local
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    ldx #&0e
    ldy #&0e
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    lda #&78 ; 'x'
    sta object_y_low + objectid_leaf2
    lda #&e0
    sta object_z_order + objectid_dog_body
    lda #&e7
    sta object_erase_type + objectid_dog_head
    lda #&c0
    sta object_z_order + objectid_dog_head
    lda #&8e
    sta object_x_low + objectid_dog_bowl
    lda #&78 ; 'x'
    sta object_y_low + objectid_dog_bowl
    lda #spriteid_dog_bowl2
    sta object_spriteid + objectid_dog_bowl
.set_dog_head_object_local
    jmp set_dog_head_object

.update_dog_head_animation
    lda dog_animation_step
    clc
    adc #3
    tay
    lda dog_head_animations,y
    cmp #&80
    bne got_dog_animation_step_in_y
    ldy save_game_level_k_dog_animation
.got_dog_animation_step_in_y
    lda save_game_level_k_dog_animation
    cmp #dog_head_dead_animation - dog_head_animations
    beq set_dog_animation_step_local
    lda save_game_level_k_poison_dog_animation_step
    bne update_dog_poisoning_animation
    lda desired_room_index
    cmp #0
    bne check_if_dog_is_dying
    lda object_spriteid + objectid_bottle_pour
    cmp #spriteid_splash
    bne check_if_dog_is_dying
    lda save_game_level_k_poison_in_bottle_flag
    beq check_if_dog_is_dying
; check for bottle and dog bowl collision
    ldx #objectid_bottle_pour
    sty remember_y
    ldy #objectid_dog_bowl
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    ora #0
    beq check_if_dog_is_dying
.update_dog_poisoning_animation
    lda save_game_level_k_poison_dog_animation_step
    cmp #&10
    bcs check_if_dog_is_dying
    inc save_game_level_k_poison_dog_animation_step
.check_if_dog_is_dying
    lda save_game_level_k_poison_dog_animation_step
    cmp #8
    bcc check_for_player_colliding_with_dog
    ldy #dog_head_stunned_animation - dog_head_animations
    sty save_game_level_k_dog_animation
    cmp #&10
    bcc set_dog_animation_step
    lda desired_room_index
    cmp #0
    bne set_dog_head_dead_animation
    jsr dog_death_sound
.set_dog_head_dead_animation
    ldy #dog_head_dead_animation - dog_head_animations
    sty save_game_level_k_dog_animation
.set_dog_animation_step_local
    jmp set_dog_animation_step

.check_for_player_colliding_with_dog
    lda desired_room_index
    cmp #0
    bne set_dog_animation_step
    lda #&f8
    sta temp_top_offset
    ldx #objectid_dog_head
    sty remember_y
    ldy #objectid_player
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    ora #0
    beq set_dog_animation_step
    lda #6
    sta player_wall_collision_reaction_speed
    ldy #dog_head_push_animation - dog_head_animations
.set_dog_animation_step
    sty dog_animation_step
.set_dog_head_object
    lda desired_room_index
    cmp #0
    bne return3
    ldy dog_animation_step
    lda dog_head_animations,y
    sta object_spriteid + objectid_dog_head
    iny
    lda dog_head_animations,y
    clc
    adc #&74 ; 't'
    sta object_x_low + objectid_dog_head
    iny
    lda dog_head_animations,y
    clc
    adc #&78 ; 'x'
    sta object_y_low + objectid_dog_head
    lda #spriteid_dog_body
    sta object_spriteid + objectid_dog_body
    lda #&74 ; 't'
    sta object_x_low + objectid_dog_body
    lda save_game_level_k_dog_animation
    cmp #dog_head_dead_animation - dog_head_animations
    beq dog_is_dead
    cmp #dog_head_stunned_animation - dog_head_animations
    bne return3
; set solid rock collision
    ldx #&11
    ldy #&0c
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    jsr write_a_single_value_to_cell_in_collision_map
    jmp return3

.dog_is_dead
    ldx #&11
    ldy #&0c
    lda #collision_map_none
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    jsr write_a_single_value_to_cell_in_collision_map
    lda #spriteid_dog_dead
    sta object_spriteid + objectid_dog_body
    lda #&70 ; 'p'
    sta object_x_low + objectid_dog_body
.return3
    rts

.remember_y
    equb 0

.room_0_update_handler
    lda #0
    sta currently_updating_logic_for_room_index
    ldx #5
    ldy #7
    lda #objectid_spell
    jsr update_level_completion
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_0_not_first_update
; initialise room 0
    lda #spriteid_empty_bottle_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_empty_bottle_held
    sta collectable_spriteids+1
    lda #spriteid_emptying_bottle
    sta collectable_being_used_spriteids + 1
    lda #spriteid_full_bottle_menu_item
    sta toolbar_collectable_spriteids+2
    lda #spriteid_full_bottle_held
    sta collectable_spriteids+2
    lda #spriteid_emptying_bottle
    sta collectable_being_used_spriteids + 2
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq check_for_room_change
    lda #0
    sta bottle_pour_animation_step
.check_for_room_change
    lda desired_room_index
    cmp previous_room_index
    beq initialise_bottle
    lda #0
    sta bottle_pour_animation_step
.initialise_bottle
    lda #spriteid_erase_2
    sta object_erase_type + objectid_bottle_pour
    lda #&60 ; '`'
    sta object_z_order + objectid_bottle_pour
    lda desired_room_index
    cmp #0
    bne update_pouring_object_local
; initialise room 0
    lda save_game_level_k_got_bottle_flag
    bne update_pouring_object_local
    ldx #&23 ; '#'
    lda #4
    sta temp_sprite_x_offset
    ldy #&0f
    lda #3
    jsr set_object_position_from_cell_xy
    lda #spriteid_empty_bottle
    sta object_spriteid + objectid_empty_bottle
    lda #spriteid_erase_1
    sta object_erase_type + objectid_drip
    lda #&c0
    sta object_z_order + objectid_drip
.update_pouring_object_local
    jmp update_pouring_object

.room_0_not_first_update
    lda save_game_level_k_got_bottle_flag
    bne update_in_room_0_with_bottle
    lda desired_room_index
    cmp #0
    bne return4_local
; update bottle in room 0
    lda save_game_level_k_got_bottle_flag
    bne update_pouring_object_local
    ldx #objectid_old_player
    ldy #objectid_empty_bottle
    jsr test_for_collision_between_objects_x_and_y
    beq return4_local
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_empty_bottle
    lda #1
    sta save_game_level_k_got_bottle_flag
    lda #spriteid_empty_bottle_menu_item
    jsr find_or_create_menu_slot_for_A
.return4_local
    jmp return4

; check if already pouring
.update_in_room_0_with_bottle
    lda bottle_pour_animation_step
    bne pour_in_progress
; check if starting to pour
    lda #spriteid_full_bottle_menu_item
    cmp player_using_object_spriteid
    bne update_pouring_object
; set empty bottle
    lda #spriteid_empty_bottle_menu_item
    sta player_held_object_spriteid
    sta player_using_object_spriteid
; set empty bottle in toolbar
    ldx menu_index_for_extra_items
    sta desired_menu_slots,x
; start pouring animation
    lda #1
    sta bottle_pour_animation_step
    lda #1                                                            ; redundant instruction
    sta save_game_level_k_got_bottle_flag
; move player accessory in X based on player direction
    lda #4
    ldx object_direction
    bpl sign_extend_a_to_ax
    eor #&ff
    clc
    adc #1
.sign_extend_a_to_ax
    ldx #0
    ora #0
    bpl add_to_bottle_accessory_x
    dex
.add_to_bottle_accessory_x
    clc
    adc object_x_low + objectid_player_accessory
    sta bottle_pour_x_low
    txa
    adc object_x_high + objectid_player_accessory
    sta bottle_pour_x_high
; move accessory up four pixels. X is irrelevant.
    ldx #0                                                            ; redundant instruction
    lda #&fc
    bpl move_bottle_accessory_up_in_y                                 ; redundant instruction
    dex                                                               ; redundant instruction
.move_bottle_accessory_up_in_y
    clc
    adc object_y_low + objectid_player_accessory
    sta bottle_pour_y
    lda object_direction
    sta bottle_pour_direction
    jmp update_pouring_object

.pour_in_progress
    inc bottle_pour_animation_step
    beq update_pouring_object
    lda bottle_pour_y
    clc
    adc #8
    sta bottle_pour_y
.update_pouring_object
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_bottle_pour
    ldx bottle_pour_animation_step
    beq return4_local
    lda bottle_pour_x_low
    sta object_x_low + objectid_bottle_pour
    lda bottle_pour_x_high
    sta object_x_high + objectid_bottle_pour
    lda bottle_pour_direction
    sta object_direction + objectid_bottle_pour
    lda bottle_pour_y
    sta object_y_low + objectid_bottle_pour
    lda #spriteid_pour
    sta object_spriteid + objectid_bottle_pour
    cpx #1
    beq check_for_bottle_pouring_offscreen
    lda #spriteid_splash
    sta object_spriteid + objectid_bottle_pour
    cpx #&ff
    beq check_for_bottle_pouring_offscreen
; start droplet
    lda #spriteid_droplet
    sta object_spriteid + objectid_bottle_pour
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne check_for_bottle_pouring_offscreen
    lda object_spriteid_old + objectid_bottle_pour
    cmp #&da
    bne check_for_bottle_pouring_offscreen
    lda #1
    sta temp_bottom_offset
    lda #2
    jsr get_solid_rock_collision_for_object_a
    beq check_for_bottle_pouring_offscreen
    lda #&ff
    sta bottle_pour_animation_step
    lda #spriteid_splash
    sta object_spriteid + objectid_bottle_pour
    jsr play_landing_sound
.check_for_bottle_pouring_offscreen
    ldx #objectid_bottle_pour
    jsr find_left_and_right_of_object
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return4
    ora #0
    bpl stop_bottle_pour_animation
    lda object_right_cell_x
    bpl return4
.stop_bottle_pour_animation
    lda #0
    sta bottle_pour_animation_step
    sta object_spriteid + objectid_bottle_pour
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
; ####                      |         ####
; ###                       |          ###
; ###                       |          ###
; ###                       |          ###
; ###                       |          ###
; #######################   |   ##########
; #######################   |   ##########
; ###                       |          ###
; ###                       S          ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ######                            ######
; ######                            ######
; 
; 
; 
; 
;                     P
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_1_code
    jsr draw_top_and_bottom_rows
; draw 3x15 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (37,2)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 20x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #&14
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x2 rectangle at (30,7)
    ldx #&1e
    lda #7
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,15)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_top_left_and_right_corners
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (26,2) length 9
    ldx #&1a
    ldy #2
    lda #9
    jsr draw_rope
    lda #sprite_op_flags_erase_to_fg_colour
    sta sprite_op_flags
    jsr sprite_op
; draw bucket at (26,10)
    ldy #&0a
    lda #spriteid_bucket
    jsr draw_sprite_a_at_cell_xy
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq try_right_exit
; left from room 1 is room 0
    ldx #0
    ldy current_level
    jmp initialise_level_and_room

.try_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_1_game_update_loop
; right from room 1 is room 2
    ldx #2
    ldy current_level
    jmp initialise_level_and_room

.room_1_update_handler
    lda #1
    sta currently_updating_logic_for_room_index
    ldx #3
    ldy #&0c
    lda #objectid_room_1_fire1
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #objectid_room_1_fire2
    jsr update_brazier_and_fire
    lda #0
    sta drip_is_poison_flag
    lda #&10
    sta drip_start_frame
    lda #&68 ; 'h'
    sta drip_initial_y
; long-winded way of saying: 'lda #$1d'
    lda #&10
    clc
    adc #5
    clc
    adc #&16
    sec
    sbc #&0d
    sec
    sbc #1
    sta drip_timer_limit
    ldx #&d0
    ldy #0
    lda room_1_drip_timer
    jsr update_drip
    sta room_1_drip_timer
    rts

.droplet_animation
    equb spriteid_droplet4
    equb spriteid_droplet3
    equb spriteid_droplet2
    equb spriteid_droplet1
.droplet_full
    equb spriteid_droplet

.update_drip
    sta temp_drip_timer
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq increment_drip_timer
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq new_room
; initialise drip timer for new level
    lda #0
    sta temp_drip_timer
; check_for_being_in_same_room_as_drip
.new_room
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne update_drip_animation_local
; initialise drip
    lda #spriteid_erase_1
    sta object_erase_type + objectid_drip
    lda #&40 ; '@'
    sta object_z_order + objectid_drip
    stx object_x_low + objectid_drip
    sty object_x_high + objectid_drip
.update_drip_animation_local
    jmp update_drip_animation

.return_drip_timer_local
    jmp return_drip_timer

.increment_drip_timer
    inc temp_drip_timer
    lda drip_timer_limit
    clc
    adc #1
    cmp temp_drip_timer
    bne update_drip_animation
    lda #0
    sta temp_drip_timer
.update_drip_animation
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return_drip_timer_local
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_drip
    lda drip_timer_limit
    clc
    adc #1
    sta temp_y
    lda temp_drip_timer
    cmp temp_y
    bcs return_drip_timer_local
    sec
    sbc drip_start_frame
    bcc return_drip_timer_local
    cmp #5
    bcs drip_is_falling
    tay
    lda droplet_animation,y
    sta object_spriteid + objectid_drip
    lda drip_initial_y
    sta object_y_low + objectid_drip
    jmp return_drip_timer

.drip_is_falling
    sec
    sbc #5
    clc
    adc #1
    asl a
    asl a
    asl a
    clc
    adc drip_initial_y
    sta object_y_low + objectid_drip
    lda #spriteid_splash
    sta object_spriteid + objectid_drip
    lda temp_drip_timer
    cmp drip_timer_limit
    bne set_full_droplet
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne return_drip_timer
    jsr play_landing_sound
    jmp return_drip_timer

.set_full_droplet
    lda droplet_full
    sta object_spriteid + objectid_drip
    lda object_y_low + objectid_drip
    sec
    sbc #4
    sta object_y_low + objectid_drip
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne return_drip_timer
; is player holding the empty bottle? (return if not)
    lda object_spriteid + objectid_player_accessory
    cmp #spriteid_empty_bottle_held
    bne return_drip_timer
; is the pouring animation happening? (return if so)
    lda bottle_pour_animation_step
    bne return_drip_timer
; check for bottle and drip collision (return if none)
    ldx #objectid_old_player_accessory
    ldy #objectid_old_drip
    jsr test_for_collision_between_objects_x_and_y
    beq return_drip_timer
; bottle is now full
    lda #spriteid_full_bottle_held
    sta object_spriteid + objectid_player_accessory
    lda #spriteid_full_bottle_menu_item
    sta player_held_object_spriteid
    ldx menu_index_for_extra_items
    sta desired_menu_slots,x
    lda #&ff
    sta save_game_level_k_got_bottle_flag
    lda drip_is_poison_flag
    sta save_game_level_k_poison_in_bottle_flag
; long-winded way of saying: temp_drip_timer -= drip_timer_limit+1
    lda drip_timer_limit
    clc
    adc #1
    sec
    sbc temp_drip_timer
    eor #&ff
    clc
    adc #1
    sta temp_drip_timer
; hide the collected drip
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_drip
.return_drip_timer
    lda temp_drip_timer
    rts

.temp_drip_timer
    equb 0
.drip_start_frame
    equb 0
.drip_is_poison_flag
    equb 0
.drip_initial_y
    equb 0
.drip_timer_limit
    equb 0
.envelope1
    equb 5                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 20                                                           ; change of amplitude per step during attack phase
    equb 246                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 246                                                          ; change of amplitude per step during release phase
    equb 120                                                          ; target of level at end of attack phase
    equb 60                                                           ; target of level at end of decay phase
.sound2
    equw &0010                                                        ; channel
    equw 5                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 2                                                            ; duration
.sound1
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 180                                                          ; pitch
    equw 2                                                            ; duration
.ground_fill_2x2_top_left
    equb %00001000
    equb %00001000
    equb %00010000
    equb %01110000
    equb %10000000
    equb %00000111
    equb %00000100
    equb %00001000
.ground_fill_2x2_top_right
    equb %00001000
    equb %00000100
    equb %00000100
    equb %00000110
    equb %11000001
    equb %00110000
    equb %00010000
    equb %00010000
.ground_fill_2x2_bottom_left
    equb %00001000
    equb %00000100
    equb %00000100
    equb %00000110
    equb %11000001
    equb %00110000
    equb %00010000
    equb %00010000
.ground_fill_2x2_bottom_right
    equb %00001000
    equb %00001000
    equb %00010000
    equb %01110000
    equb %10000000
    equb %00000111
    equb %00000100
    equb %00001000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelK_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelK.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelK"
ENDIF
ENDIF
.pydis_end

save "build/dataK", pydis_start, pydis_end
