; *************************************************************************************
;
; Level L: 'WHIP-IT'
;
; Save game variables:
;
;     save_game_level_l_got_whip_progress                        ($0a39):
;               0: untouched
;              1+: using whip
;             $ff: got whip
;
;     save_game_level_l_dog_x                                    ($0a3a):
;             pixel X position of the dog
;
;     save_game_level_l_got_frog_progress                        ($0a3b):
;               0: untouched
;              1+: using frog
;             $ff: got frog
;
;     save_game_level_l_baby_animation                           ($0a3c):
;               0: untouched
;              1+: animation for baby arms
;
;     save_game_level_l_partition_y                              ($0a3d):
;              pixel Y position of the partition
;
;     save_game_level_l_frog_dir:                                ($0a3e):
;               1: looking right
;             $ff: looking left
;
; Solution:
;
;   1. move to the room to the left and retrieve the whip from the ledge
;   2. stand near the dog in the initial room and use the whip to repeatedly
;      send the dog backwards until the rope above is clear to use
;   3. climb the rope and enter the room to the right
;   4. descend halfway down the rope to the left and jump onto the ledge
;           (the frog jumps to the right)
;   5. as the cat jump to the right hand ledge and collect the frog
;   6. return two rooms to the left and stand under the 'speak here' sign
;   7. use the frog to cause the partition to rise.
;   8. collect the spell in the room to the left
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_baby_arms                    = 3
objectid_dog                          = 2
objectid_dog_tail                     = 3
objectid_end_of_partition             = 6
objectid_fire1                        = 3
objectid_fire2                        = 4
objectid_frog                         = 2
objectid_partition                    = 5
objectid_rope_frayed_end              = 4
objectid_sparkles                     = 2
objectid_whip                         = 2
spriteid_arm1                         = 235
spriteid_arm2                         = 236
spriteid_arm3                         = 237
spriteid_arm4                         = 238
spriteid_baby1                        = 232
spriteid_baby2                        = 233
spriteid_baby3                        = 234
spriteid_dog                          = 210
spriteid_dog_cower1                   = 212
spriteid_dog_cower2                   = 213
spriteid_dog_raised                   = 211
spriteid_erase_1                      = 201
spriteid_erase_2                      = 202
spriteid_erase_3                      = 214
spriteid_frog                         = 222
spriteid_frog_leap1                   = 239
spriteid_frog_leap2                   = 240
spriteid_frog_menu_item               = 221
spriteid_frog_speaking                = 223
spriteid_horizontal_short_rope        = 227
spriteid_partition                    = 230
spriteid_partition_end                = 231
spriteid_speak_here_sign              = 224
spriteid_tail1                        = 215
spriteid_tail2                        = 216
spriteid_tail3                        = 217
spriteid_tail4                        = 218
spriteid_tail5                        = 219
spriteid_tail6                        = 220
spriteid_top_left_hook                = 226
spriteid_top_right_hook               = 225
spriteid_vertical_rope                = 228
spriteid_vertical_rope_frayed_end     = 229
spriteid_whip_1                       = 203
spriteid_whip_2                       = 204
spriteid_whip_3                       = 205
spriteid_whip_4                       = 206
spriteid_whip_5                       = 207
spriteid_whip_hook1                   = 208
spriteid_whip_hook2                   = 209
spriteid_whip_menu_item               = 200

; Memory locations
remember_a                                          = &0070
room_exit_direction                                 = &0070
l007a                                               = &007a
l007b                                               = &007b
save_game_level_l_got_whip_progress                 = &0a39
save_game_level_l_dog_x                             = &0a3a
save_game_level_l_got_frog_progress                 = &0a3b
save_game_level_l_baby_animation                    = &0a3c
save_game_level_l_partition_y                       = &0a3d
save_game_level_l_frog_dir                          = &0a3e
dog_animation                                       = &0a6f
dog_animation_step                                  = &0a70
dog_tail_animation_step                             = &0a71
baby_animation_step                                 = &0a72
frog_x                                              = &0a73
frog_y                                              = &0a74
frog_animation                                      = &0a75
frog_animation_step                                 = &0a76
delay_before_ribbit                                 = &0a77
dog_animation_delay                                 = &0a78

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelL_sprite_table - level_data
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
    equb 1
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "WHIP-IT", &0D

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
    beq no_frog
    lda developer_flags
    bpl developer_mode_inactive
; in developer mode. get whip and frog
    lda #&ff
    sta save_game_level_l_got_whip_progress
    sta save_game_level_l_got_frog_progress
.developer_mode_inactive
    lda save_game_level_l_got_whip_progress
    beq no_whip
    lda #spriteid_whip_menu_item
    jsr find_or_create_menu_slot_for_A
.no_whip
    lda save_game_level_l_got_frog_progress
    beq no_frog
    lda #spriteid_frog_menu_item
    jsr find_or_create_menu_slot_for_A
; set rock tile
.no_frog
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
    jsr update_whip
    jsr room_2_update_handler
    jsr update_frog_speaking
    jsr room_1_update_handler
    jsr room_3_update_handler
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
    jmp copy_rectangle_of_memory_to_screen

.remember_y
    equb 0
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
; ###                ###               ###
; ###                ###               ###
; ###                ###               ###
; ###                ###               ###
; ###                ###               ###
; ########################################
; ########################################
; ###      |                           ###
; ###      |                           ###
; ###      |                           ###
; ###      |                           ###
; ###      |          S             #S####
; ###      |                        ######
; ######   |
; ######   |
; ###      |
; ###      |
; ###      |
; ###                               ######
; ###                 P          #########
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_0_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x20 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x13 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&0d
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (19,2)
    ldx #&13
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 34x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #&22 ; '"'
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,15)
    ldy #&0f
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,13)
    ldx #&22 ; '"'
    ldy #&0d
    jsr copy_rectangle_of_memory_to_screen
; draw 6x2 rectangle at (34,20)
    ldy #&14
    lda #6
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (31,21)
    ldx #&1f
    iny
    lda #3
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw ball at (20,13)
    ldx #&14
    ldy #&0d
    lda #spriteid_ball
    jsr draw_sprite_a_at_cell_xy
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
; draw rope at (9,9) length 11
    ldx #9
    ldy #9
    lda #&0b
    jsr draw_rope
; draw frog at (35,13)
    ldx #&23 ; '#'
    lda #8
    sta temp_sprite_x_offset
    ldy #&0d
    lda #&f9
    sta temp_sprite_y_offset
    lda #&ff
    sta sprite_reflect_flag
    lda #spriteid_frog
    jsr draw_sprite_a_at_cell_xy
    jsr start_room
.room_0_game_update_loop
    jsr game_update
    and #exit_room_right
    beq room_0_game_update_loop
; right of room 0 is room 1
    ldx #1
.goto_new_room
    ldy current_level
    jmp initialise_level_and_room

.room_0_update_handler
    lda #0
    sta currently_updating_logic_for_room_index
    ldx #&14
    ldy #&0d
    lda #objectid_fire1
    jsr update_brazier_and_fire
    inx
    lda #objectid_fire2
    jsr update_brazier_and_fire
    ldx #4
    stx temp_sprite_x_offset
    ldy #&0f
    lda #objectid_sparkles
    jmp update_level_completion

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 26                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ########################################
; ########################################
; ###                ###               ###
; ###                ###               ###
; ###                ###               ###
; ###                ###               ###
; ###                ###               ###
; ### ########### ########################
; ### ########### ########################
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      S                    |      S##
; ###                           |      ###
; ###                           |      ###
;                               |   ######
;                               |   ######
;                               |
;                               |
;                               |
; ###################
; ######################    P
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_1_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x13 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0d
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (19,2)
    ldx #&13
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (4,7)
    ldx #4
    ldy #7
    lda #&0b
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 21x2 rectangle at (16,7)
    ldx #&10
    lda #&15
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,15)
    ldx #&22 ; '"'
    ldy #&0f
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 19x2 rectangle at (0,20)
    ldx #0
    ldy #&14
    lda #&13
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x1 rectangle at (19,21)
    ldx #&13
    iny
    lda #3
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw whip hook2 at (37,12)
    ldx #&25 ; '%'
    ldy #&0c
    lda #spriteid_whip_hook2
    jsr draw_sprite_a_at_cell_xy
; draw rope at (30,9) length 11
    ldx #&1e
    ldy #9
    lda #&0b
    jsr draw_rope
; draw rope at (9,9) length 4
    ldx #9
    lda #4
    jsr draw_rope
; draw speak here sign at (9,12)
    ldy #&0c
    lda #spriteid_speak_here_sign
    jsr draw_sprite_a_at_cell_xy
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_1_check_right_exit
    ldx #0
    jmp goto_new_room

.room_1_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_1_game_update_loop
    ldx #2
    jmp goto_new_room

.baby_arm_animations
    equb 0
.baby_arm_static_animation
    equb spriteid_arm2,             0
    equb &ff
.baby_arm_pre_pulling_animation
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb spriteid_arm2,             0
    equb &ff
.baby_arm_pulling_rope_animation
    equb spriteid_arm3,             0
    equb spriteid_arm3,             0
    equb spriteid_arm2,           &fc
    equb spriteid_arm4,           &fc
    equb spriteid_arm4,             0
    equb &ff

; check for first update in room (branch if so)
.room_1_update_handler
    lda update_room_first_update_flag
    bne initialise_room_1
    jmp update_room_1

; check for level change (branch if not)
.initialise_room_1
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq only_room_changed
    ldy save_game_level_l_baby_animation
    bne check_partition_open_or_closed
    ldy #1
    lda #&78 ; 'x'
    sta save_game_level_l_partition_y
.check_partition_open_or_closed
    cpy #1
    beq store_baby_animation
    ldy #1
    lda #&50 ; 'P'
    sta save_game_level_l_partition_y
.store_baby_animation
    sty save_game_level_l_baby_animation
    sty baby_animation_step
.only_room_changed
    lda desired_room_index
    cmp #1
    beq initialise_room_1_envelope_and_rope
    jmp update_partition_and_rope_local

.initialise_room_1_envelope_and_rope
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    ldx #3
    ldy #2
    lda #spriteid_top_left_hook
    jsr draw_sprite_a_at_cell_xy
    inx
    inx
    lda #spriteid_horizontal_short_rope
.draw_rope_loop0
    jsr draw_sprite_a_at_cell_xy
    inx
    cpx #&0e
    bcc draw_rope_loop0
    inx
    lda #spriteid_top_right_hook
    jsr draw_sprite_a_at_cell_xy
    lda #&78 ; 'x'
    sec
    sbc save_game_level_l_partition_y
    clc
    adc #&4c ; 'L'
    lsr a
    lsr a
    lsr a
    tay
    dey
    lda #spriteid_vertical_rope
.draw_rope_loop1
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_rope_loop1
    lda #4
    jsr set_object_position_from_cell_xy
    lda #spriteid_vertical_rope_frayed_end
    sta object_spriteid + objectid_rope_frayed_end
    lda save_game_level_l_partition_y
    clc
    adc #4
    lsr a
    lsr a
    lsr a
    tay
    dey
    ldx #3
    lda #spriteid_vertical_rope
.draw_rope_loop2
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_rope_loop2
    lda #objectid_partition
    jsr set_object_position_from_cell_xy
    lda #objectid_end_of_partition
    jsr set_object_position_from_cell_xy
    lda #spriteid_partition
    sta object_spriteid + objectid_partition
    lda #&c0
    sta object_z_order + objectid_partition
    lda #spriteid_partition_end
    sta object_spriteid + objectid_end_of_partition
    lda #spriteid_erase_3
    sta object_erase_type + objectid_end_of_partition
    ldx #&10
    ldy #7
    lda #spriteid_baby3
    jsr draw_sprite_a_at_cell_xy
    lda #3
    jsr set_object_position_from_cell_xy
    lda #spriteid_erase_2
    sta object_erase_type + objectid_baby_arms
    lda #&c0
    sta object_z_order + objectid_baby_arms
.update_partition_and_rope_local
    jmp update_partition_and_rope

.update_room_1
    lda baby_animation_step
    clc
    adc #2
    tay
    lda baby_arm_animations,y
    cmp #&ff
    bne check_baby_animation
    ldy save_game_level_l_baby_animation
.check_baby_animation
    lda save_game_level_l_baby_animation
    cmp #baby_arm_static_animation - baby_arm_animations
    bne after_pre_pulling_goto_pulling_animation
    lda save_game_level_l_partition_y
    cmp #&78 ; 'x'
    bne set_baby_animation_step
    lda desired_room_index
    cmp #1
    bne set_baby_animation_step
    lda save_game_level_l_got_frog_progress
    cmp #1
    bne set_baby_animation_step
    lda object_y_low
    cmp #&a0
    bcs set_baby_animation_step
    cmp #&78 ; 'x'
    bcc set_baby_animation_step
; start pulling animation
    ldy #baby_arm_pre_pulling_animation - baby_arm_animations
    sty save_game_level_l_baby_animation
    jmp set_baby_animation_step

.after_pre_pulling_goto_pulling_animation
    cmp #baby_arm_pre_pulling_animation - baby_arm_animations
    bne check_if_we_should_initialise_baby_animation
    cpy save_game_level_l_baby_animation
    bne set_baby_animation_step
    ldy #baby_arm_pulling_rope_animation - baby_arm_animations
    sty save_game_level_l_baby_animation
    jmp set_baby_animation_step

.check_if_we_should_initialise_baby_animation
    cpy save_game_level_l_baby_animation
    bne set_baby_animation_step
    lda save_game_level_l_partition_y
    cmp #&50 ; 'P'
    bne set_baby_animation_step
    ldy #baby_arm_static_animation - baby_arm_animations
    sty save_game_level_l_baby_animation
.set_baby_animation_step
    sty baby_animation_step
    iny
    lda baby_arm_animations,y
    beq update_partition_and_rope
    clc
    adc save_game_level_l_partition_y
    sta save_game_level_l_partition_y
    lda desired_room_index
    cmp #1
    bne update_partition_and_rope
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_rope_frayed_end
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
.update_partition_and_rope
    lda desired_room_index
    cmp #1
    bne return1
    ldy baby_animation_step
    lda baby_arm_animations,y
    sta object_spriteid + objectid_baby_arms
    lda save_game_level_l_partition_y
    sta object_y_low + objectid_partition
    sta object_y_low + objectid_end_of_partition
    lda #&78 ; 'x'
    sec
    sbc save_game_level_l_partition_y
    clc
    adc #&48 ; 'H'
    sta object_y_low + objectid_rope_frayed_end
    ldx #3
    lda save_game_level_l_partition_y
    lsr a
    lsr a
    lsr a
    tay
    lda #1
    sta width_in_cells
    lda #5
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    tya
    clc
    adc height_in_cells
    tay
    sta remember_a
    lda #&14
    sec
    sbc remember_a
    beq return1
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return1
    rts

.whip_animation_table
    equb spriteid_whip_2
    equb spriteid_whip_3
    equb spriteid_whip_4
    equb spriteid_whip_5
    equb spriteid_whip_1

; check for first update in room (branch if not)
.update_whip
    lda update_room_first_update_flag
    beq not_first_update_whip
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq new_room_only
    lda save_game_level_l_got_whip_progress
    beq new_room_only
    lda #&ff
    sta save_game_level_l_got_whip_progress
.new_room_only
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    lda #spriteid_whip_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_whip_1
    sta collectable_spriteids+1
    lda desired_room_index
    cmp #1
    bne update_whip_in_hand_local
    lda save_game_level_l_got_whip_progress
    bne update_whip_in_hand_local
    ldx #&25 ; '%'
    lda #&fe
    sta temp_sprite_x_offset
    ldy #&0c
    lda #objectid_whip
    jsr set_object_position_from_cell_xy
    lda #&ff
    sta object_direction + objectid_whip
    lda #spriteid_erase_1
    sta object_erase_type + objectid_whip
    lda #spriteid_whip_5
    sta object_spriteid + objectid_whip
.update_whip_in_hand_local
    jmp update_whip_in_hand

.not_first_update_whip
    lda save_game_level_l_got_whip_progress
    bne check_if_using_whip
    lda desired_room_index
    cmp #1
    bne return2
; not got whip, but we are in room 1. Check for collision with whip
    ldx #objectid_old_player
    ldy #objectid_whip
    jsr test_for_collision_between_objects_x_and_y
    beq return2
; whip collected
    lda #&ff
    sta save_game_level_l_got_whip_progress
    lda #spriteid_whip_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_whip
    beq return2
.check_if_using_whip
    lda #spriteid_whip_menu_item
    cmp player_using_object_spriteid
    beq using_whip
; not using_whip
    lda #&ff
    sta save_game_level_l_got_whip_progress
    bmi update_whip_in_hand                                           ; ALWAYS branch

.using_whip
    ldy save_game_level_l_got_whip_progress
    cpy #4
    beq update_whip_in_hand
    cpy #&ff
    bne increment_whip_animation
    ldy #0
.increment_whip_animation
    iny
    sty save_game_level_l_got_whip_progress
.update_whip_in_hand
    lda whip_animation_table
    ldy save_game_level_l_got_whip_progress
    cpy #&ff
    beq got_whip_in_hand_sprite
    lda whip_animation_table,y
.got_whip_in_hand_sprite
    sta collectable_being_used_spriteids + 1
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne return2
    cpy #2
    bne return2
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
.return2
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
; ###                ###        |
; ###                ###        |
; ###                ###        |
; ###                ###        |
; ###                ###        |
; ###########################   |   ######
; ###########################   |   ######
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                           ###
; ###      |                           ###
; ######   |   ###########################
; ######   |   ###########################
;          |                           ###
;          |                           ###
;          |                           ###
;                                      ###
;                     P                ###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_2_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x15 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x15 rectangle at (37,7)
    ldx #&25 ; '%'
    ldy #7
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (19,2)
    ldx #&13
    ldy #2
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 24x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #&18
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,7)
    ldx #&22 ; '"'
    lda #3
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,15)
    ldx #3
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 24x2 rectangle at (13,15)
    ldx #&0d
    lda #&18
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (9,9) length 11
    ldx #9
    ldy #9
    lda #&0b
    jsr draw_rope
; draw rope at (30,2) length 11
    ldx #&1e
    ldy #2
    jsr draw_rope
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_left
    beq room_2_check_right_exit
    ldx #1
    jmp goto_new_room

.room_2_check_right_exit
    lda room_exit_direction
    and #exit_room_right
    beq room_2_game_update_loop
    ldx #3
    jmp goto_new_room

.dog_animations
    equb 0
.dog_animation_normal
    equb spriteid_dog
    equb   0, &ff,   0
.dog_animation_cower_in_place
    equb spriteid_dog_cower1
    equb 0, 0, 0
.dog_animation_push
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff
    equb spriteid_dog_raised
    equb   0, &ff,   0
.dog_animation_back_up
    equb spriteid_dog_cower1
    equb 0, 0
    equb spriteid_dog_cower1
    equb 0, 0
    equb spriteid_dog_cower1
    equb 0, 0
    equb spriteid_dog_cower1
    equb 0, 0
    equb spriteid_dog_cower2
    equb 2, 0
    equb spriteid_dog_cower2
    equb 0, 0
    equb spriteid_dog_cower2
    equb 0, 0
    equb spriteid_dog_cower1
    equb 2, 0, 0
.dog_tail_animation
    equb spriteid_tail1
    equb spriteid_tail2
    equb spriteid_tail3
    equb spriteid_tail4
    equb spriteid_tail5
    equb spriteid_tail6

; check for first update in room (branch if not)
.room_2_update_handler
    lda update_room_first_update_flag
    beq update_room_2
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_change_only1
    lda #dog_animation_normal - dog_animations
    sta dog_animation
    sta dog_animation_step
    lda save_game_level_l_dog_x
    bne set_initial_dog_x_position
    lda #&68 ; 'h'
.set_initial_dog_x_position
    clc
    adc #2
    and #&fc
    sta save_game_level_l_dog_x
.room_change_only1
    lda desired_room_index
    cmp #2
    bne update_dog_object_local
    lda #spriteid_erase_1
    sta object_erase_type + objectid_dog
    lda #&c0
    sta object_z_order + objectid_dog
    lda #&78 ; 'x'
    sta object_y_low + objectid_dog
    sta object_y_low + objectid_dog_tail
    lda #spriteid_erase_3
    sta object_erase_type + objectid_baby_arms
    lda #&a0
    sta object_z_order + objectid_baby_arms
.update_dog_object_local
    jmp update_dog_object

.update_room_2
    lda dog_animation_step
    clc
    adc #3
    tay
    lda dog_animations,y
    cmp #0                                                            ; redundant instruction
    bne check_for_dog_cowering
    ldy dog_animation
.check_for_dog_cowering
    cpy #dog_animation_cower_in_place - dog_animations
    bne check_for_dog_backing_up
; while cowering, wait until timeout and then return to normal
    dec dog_animation_delay
    bpl check_for_player_using_whip
    ldy #dog_animation_normal - dog_animations
    sty dog_animation
.check_for_dog_backing_up
    lda dog_animation
    cmp #dog_animation_back_up - dog_animations
    bne check_for_player_using_whip
    cpy dog_animation
    bne check_player_dog_collisions
    ldy #dog_animation_cower_in_place - dog_animations
    sty dog_animation
    lda #9
    sta dog_animation_delay
.check_for_player_using_whip
    lda desired_room_index
    cmp #2
    bne check_player_dog_collisions
    lda #spriteid_whip_menu_item
    cmp previous_player_using_object_spriteid
    bne check_player_dog_collisions
    lda object_spriteid_old + objectid_player_accessory
    cmp #spriteid_whip_1
    beq check_player_dog_collisions
    lda #8
    sta temp_right_offset
    ldx #objectid_old_player_accessory
    sty remember_y
    ldy #objectid_dog
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    tax
    beq check_player_dog_collisions
    lda save_game_level_l_dog_x
    cmp #&8c
    bcc dog_backs_up
    ldy #dog_animation_cower_in_place - dog_animations
    sty dog_animation
    lda #9
    sta dog_animation_delay
    bpl check_player_dog_collisions                                   ; ALWAYS branch

.dog_backs_up
    ldy #dog_animation_back_up - dog_animations
    sty dog_animation
.check_player_dog_collisions
    lda desired_room_index
    cmp #2
    bne increment_dog_animation
    lda player_held_object_spriteid
    sta remember_player_held_sprite
    lda #spriteid_whip_menu_item
    cmp player_using_object_spriteid
    bne check_dog_player_collision
    lda #0
    sta player_held_object_spriteid
.check_dog_player_collision
    ldx #objectid_player
    sty remember_y
    ldy #objectid_dog
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    ldx remember_player_held_sprite
    stx player_held_object_spriteid
    tax
    bne dog_pushes_player
    lda #4
    cmp current_player_character
    beq increment_dog_animation
    ldx #objectid_player_accessory
    ldy #objectid_dog
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    tax
    beq increment_dog_animation
.dog_pushes_player
    lda #&fa
    sta player_wall_collision_reaction_speed
    ldy #dog_animation_push - dog_animations
    lda #dog_animation_normal - dog_animations
    sta dog_animation
.increment_dog_animation
    sty dog_animation_step
    iny
    lda dog_animations,y
    clc
    adc save_game_level_l_dog_x
    sta save_game_level_l_dog_x
    iny
    lda dog_animations,y
    cmp #&ff
    beq increment_dog_tail_animation
    lda #&ff
    sta dog_tail_animation_step
    bmi update_dog_object
.increment_dog_tail_animation
    inc dog_tail_animation_step
    lda dog_tail_animation_step
    cmp #6
    bcc update_dog_object
    lda #0
    sta dog_tail_animation_step
.update_dog_object
    lda desired_room_index
    cmp #2
    bne return3
    ldy dog_animation_step
    lda dog_animations,y
    sta object_spriteid + objectid_dog
    lda save_game_level_l_dog_x
    asl a
    sta object_x_low + objectid_dog
    sta object_x_low + objectid_dog_tail
    lda #0
    rol a
    sta object_x_high + objectid_dog
    sta object_x_high + objectid_dog_tail
    iny
    iny
    lda dog_animations,y
    cmp #&ff
    bne store_dog_tail_sprite
    ldy dog_tail_animation_step
    lda dog_tail_animation,y
.store_dog_tail_sprite
    sta object_spriteid + objectid_dog_tail
.return3
    rts

.remember_player_held_sprite
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
;          |                    |      ###
;          |                    |      ###
;          |                    |      ###
;          |                    |      ###
;          |                    |      ###
; ######   |   ##############   |   ######
; ######   |   ##############   |   ######
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |   ###        ###   |      ###
; ###      |   ###        ###   |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###                                  ###
; ###                 P                ###
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
.room_3_code
    jsr draw_top_and_bottom_rows_of_rock
; draw 3x15 rectangle at (0,7)
    ldy #7
    lda #3
    sta width_in_cells
    lda #&0f
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x20 rectangle at (37,2)
    ldx #&25 ; '%'
    ldy #2
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (34,7)
    ldx #&22 ; '"'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (13,15)
    ldx #&0d
    ldy #&0f
    jsr copy_rectangle_of_memory_to_screen
; draw 3x2 rectangle at (24,15)
    ldx #&18
    jsr copy_rectangle_of_memory_to_screen
; draw 14x2 rectangle at (13,7)
    ldx #&0d
    ldy #7
    lda #&0e
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (9,2) length 18
    ldx #9
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (30,2) length 18
    ldx #&1e
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_3_game_update_loop
    ldx #2
    jmp goto_new_room

.frog_animations
    equb 0
.frog_idle_animation
    equb spriteid_frog
    equb 0, 0
    equb &ff
.frog_speaking_animation
    equb spriteid_frog_speaking
    equb 0, 0
    equb spriteid_frog_speaking
    equb 0, 0
    equb spriteid_frog_speaking
    equb 0, 0
    equb spriteid_frog_speaking
    equb 0, 0
    equb &ff
.frog_leap_animation
    equb spriteid_frog_leap1
    equb   8, &f6
    equb spriteid_frog_leap1
    equb   8, &fb
    equb spriteid_frog_leap1
    equb   8, &fc
    equb spriteid_frog_leap1
    equb   8, &fe
    equb spriteid_frog_leap1
    equb   8, &ff
    equb spriteid_frog_leap1
    equb 8, 0
    equb spriteid_frog_leap2
    equb 8, 1
    equb spriteid_frog_leap2
    equb 8, 2
    equb spriteid_frog_leap2
    equb 8, 4
    equb spriteid_frog_leap2
    equb 8, 5
    equb spriteid_frog_leap2
    equb   8, &0a
    equb &ff

.room_3_update_handler
    lda #3
    sta currently_updating_logic_for_room_index
    ldx #3
    ldy #&0c
    lda #objectid_fire1
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #objectid_fire2
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_3_not_first_update
; initialise frog
    lda save_game_level_l_got_frog_progress
    bne update_frog_object_local
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_change_only2
    ldx #&74 ; 't'
    ldy #&ff
    lda save_game_level_l_frog_dir
    beq store_frog_position_and_direction
    bmi store_frog_position_and_direction
    ldx #&cc
    ldy #1
.store_frog_position_and_direction
    stx frog_x
    sty save_game_level_l_frog_dir
    lda #&76 ; 'v'
    sta frog_y
    lda #frog_idle_animation - frog_animations
    sta frog_animation
    sta frog_animation_step
    jsr get_delay_before_next_ribbit
.room_change_only2
    lda desired_room_index
    cmp #3
    bne update_frog_object_local
    lda #spriteid_erase_1
    sta object_erase_type + objectid_frog
.update_frog_object_local
    jmp update_frog_object

.room_3_not_first_update
    lda save_game_level_l_got_frog_progress
    bne update_frog_object_local
    lda frog_animation_step
    clc
    adc #3
    tay
    lda frog_animations,y
    cmp #&ff
    bne check_player_frog_collision_for_collection
    ldy frog_animation
.check_player_frog_collision_for_collection
    lda desired_room_index
    cmp #3
    bne check_for_frog_leaping
    ldx #objectid_old_player
    sty remember_y
    ldy #objectid_frog
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    tax
    beq check_for_frog_leaping
    lda #spriteid_frog_menu_item
    jsr find_or_create_menu_slot_for_A
    lda #&ff
    sta save_game_level_l_got_frog_progress
    bmi set_frog_animation_step
.check_for_frog_leaping
    lda frog_animation
    cmp #frog_leap_animation - frog_animations
    bne check_for_frog_idle
    cpy frog_animation
    bne set_frog_animation_step
.set_frog_idle
    ldy #frog_idle_animation - frog_animations
    sty frog_animation
    jsr get_delay_before_next_ribbit
.check_for_frog_idle
    lda frog_animation
    cmp #frog_idle_animation - frog_animations
    bne check_for_frog_speaking
    lda desired_room_index
    cmp #3
    bne update_delay_between_ribbits
    ldx #&0b
    sty remember_y
    jsr find_top_and_bottom_of_object
    ldy remember_y
    lda l007b
    cmp #9
    bcc update_delay_between_ribbits
    lda l007a
    cmp #&0f
    bcs update_delay_between_ribbits
; get difference between player and frog x
    lda object_x_low_old
    sec
    sbc frog_x
    lda object_x_high_old
    sbc #0
    tax
    lda save_game_level_l_frog_dir
    bpl frog_direction_right
    txa
    bpl update_delay_between_ribbits
    bmi flip_frog_direction                                           ; ALWAYS branch

.frog_direction_right
    txa
    bmi update_delay_between_ribbits
.flip_frog_direction
    lda save_game_level_l_frog_dir
    eor #&fe
    sta save_game_level_l_frog_dir
; set frog leaping
    ldy #frog_leap_animation - frog_animations
    sty frog_animation
    bpl set_frog_animation_step
.update_delay_between_ribbits
    dec delay_before_ribbit
    bne set_frog_animation_step
    lda desired_room_index
    cmp #3
    bne set_frog_speaking
    jsr play_ribbit_sound
.set_frog_speaking
    ldy #frog_speaking_animation - frog_animations
    sty frog_animation
    bpl set_frog_animation_step
.check_for_frog_speaking
    cpy #frog_speaking_animation - frog_animations
    beq set_frog_idle
.set_frog_animation_step
    sty frog_animation_step
    iny
    lda frog_animations,y
    clc
    ldx save_game_level_l_frog_dir
    bpl update_frog_x
    eor #&ff
    sec
.update_frog_x
    adc frog_x
    sta frog_x
    iny
    lda frog_animations,y
    clc
    adc frog_y
    sta frog_y
.update_frog_object
    lda desired_room_index
    cmp #3
    bne return4
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_frog
    lda save_game_level_l_got_frog_progress
    bne return4
    lda save_game_level_l_frog_dir
    sta object_direction + objectid_frog
    lda frog_x
    sta object_x_low + objectid_frog
    lda frog_y
    sta object_y_low + objectid_frog
    ldy frog_animation_step
    lda frog_animations,y
    sta object_spriteid + objectid_frog
    cmp #spriteid_frog
    beq calculate_frog_offset_based_on_frog_direction
    cmp #spriteid_frog_speaking
    bne return4
.calculate_frog_offset_based_on_frog_direction
    lda #&fc
    ldx save_game_level_l_frog_dir
    bpl move_frog
    lda #4
.move_frog
    clc
    adc object_x_low + objectid_frog
    sta object_x_low + objectid_frog
    lda #&fb
    clc
    adc object_y_low + objectid_frog
    sta object_y_low + objectid_frog
.return4
    rts

.get_delay_before_next_ribbit
    lda #&1f
    jsr get_random_number_up_to_a
    clc
    adc #&14
    sta delay_before_ribbit
    rts

.frog_animation_table
    equb spriteid_frog_speaking
    equb spriteid_frog_speaking
    equb spriteid_frog_speaking
    equb spriteid_frog_speaking
    equb spriteid_frog

; check for first update in room (branch if not)
.update_frog_speaking
    lda update_room_first_update_flag
    beq update_frog_collectable
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_frog_collectable
    lda save_game_level_l_got_frog_progress
    beq initialise_frog_collectable
    lda #&ff
    sta save_game_level_l_got_frog_progress
.initialise_frog_collectable
    lda #spriteid_frog_menu_item
    sta toolbar_collectable_spriteids+2
    lda #spriteid_frog
    sta collectable_spriteids+2
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
    ldx #<envelope4
    ldy #>envelope4
    jsr define_envelope
    ldx #<envelope5
    ldy #>envelope5
    jsr define_envelope
    jmp update_frog_collectable_sprite

.update_frog_collectable
    lda save_game_level_l_got_frog_progress
    beq update_frog_collectable_sprite
    lda #spriteid_frog_menu_item
    cmp player_using_object_spriteid
    beq player_using_frog
    lda #&ff
    sta save_game_level_l_got_frog_progress
    bmi update_frog_collectable_sprite
.player_using_frog
    ldy save_game_level_l_got_frog_progress
    cpy #4
    beq update_frog_collectable_sprite
    cpy #&ff
    bne increment_frog_speaking_animation
    ldy #0
.increment_frog_speaking_animation
    iny
    sty save_game_level_l_got_frog_progress
.update_frog_collectable_sprite
    lda frog_animation_table
    ldy save_game_level_l_got_frog_progress
    cpy #&ff
    beq store_frog_collectable_sprite
    lda frog_animation_table,y
.store_frog_collectable_sprite
    sta collectable_being_used_spriteids + 2
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne return5
    dey
    bne return5
    jsr play_ribbit_sound
.return5
    rts

.play_ribbit_sound
    lda #0
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    ldx #<sound5
    ldy #>sound5
    jsr play_sound_yx
    ldx #<sound6
    ldy #>sound6
    jsr play_sound_yx
    ldx #<sound7
    ldy #>sound7
    jmp play_sound_yx

.envelope1
    equb 9                                                            ; envelope number
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
    equw 9                                                            ; amplitude
    equw 4                                                            ; pitch
    equw 4                                                            ; duration
.envelope2
    equb 5                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 60                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 246                                                          ; change of amplitude per step during release phase
    equb 120                                                          ; target of level at end of attack phase
    equb 60                                                           ; target of level at end of decay phase
.sound3
    equw &0010                                                        ; channel
    equw 5                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound2
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 240                                                          ; pitch
    equw 1                                                            ; duration
.envelope5
    equb 6                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 20                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 226                                                          ; change of amplitude per step during release phase
    equb 120                                                          ; target of level at end of attack phase
    equb 60                                                           ; target of level at end of decay phase
.sound5
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 3                                                            ; pitch
    equw 4                                                            ; duration
.envelope3
    equb 7                                                            ; envelope number
    equb 129                                                          ; step length (100ths of a second)
    equb 1                                                            ; pitch change per step in section 1
    equb 4                                                            ; pitch change per step in section 2
    equb 6                                                            ; pitch change per step in section 3
    equb 2                                                            ; number of steps in section 1
    equb 4                                                            ; number of steps in section 2
    equb 8                                                            ; number of steps in section 3
    equb 0                                                            ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 0                                                            ; change of amplitude per step during release phase
    equb 0                                                            ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound4
    equw &0011                                                        ; channel
    equw 7                                                            ; amplitude
    equw 80                                                           ; pitch
    equw 4                                                            ; duration
.sound7
    equw 0                                                            ; channel
    equw 241                                                          ; amplitude
    equw 3                                                            ; pitch
    equw 2                                                            ; duration
.envelope4
    equb 8                                                            ; envelope number
    equb 129                                                          ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 84                                                           ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 5                                                            ; number of steps in section 1
    equb 1                                                            ; number of steps in section 2
    equb 100                                                          ; number of steps in section 3
    equb 0                                                            ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 0                                                            ; change of amplitude per step during release phase
    equb 0                                                            ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound6
    equw 1                                                            ; channel
    equw 8                                                            ; amplitude
    equw 0                                                            ; pitch
    equw 2                                                            ; duration
.ground_fill_2x2_top_left
    equb %00000100
    equb %00001000
    equb %00010000
    equb %00110000
    equb %01001001
    equb %10000110
    equb %00000100
    equb %00001000
.ground_fill_2x2_top_right
    equb %00100000
    equb %00010000
    equb %00001000
    equb %00001100
    equb %10010010
    equb %01100001
    equb %00100000
    equb %00010000
.ground_fill_2x2_bottom_left
    equb %00001000
    equb %00000100
    equb %10000110
    equb %01001001
    equb %00110000
    equb %00010000
    equb %00001000
    equb %00000100
.ground_fill_2x2_bottom_right
    equb %00010000
    equb %00100000
    equb %01100001
    equb %10010010
    equb %00001100
    equb %00001000
    equb %00010000
    equb %00100000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelL_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelL.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelL"
ENDIF
ENDIF
.pydis_end

save "build/dataL", pydis_start, pydis_end
