; *************************************************************************************
;
; Level N: 'PAVLOV-WAS-HERE'
;
; Save game variables:
;
;     save_game_level_n_partition_y                              ($0a4a):
;             $40: partition is up
;         $41-$5f: partition is between up and down
;             $60: partition is down
;
;     save_game_level_n_dog_head_animation                       ($0a4b):
;               1: regular animation
;             $30: drooling with drip
;             $34: ending drooling
;
;     save_game_level_n_got_clanger                              ($0a4c):
;               0: no
;             $ff: got clanger
;
;     save_game_level_n_bell_animation                           ($0a4d):
;               1: stopped
;               4: move sideways
;               7: fall sideways
;             $14: fall down
;
;     save_game_level_n_bell_animation_step                      ($0a4e):
;             animation step for the above animation
;
;     save_game_level_n_bell_x_low                               ($0a4f):
;     save_game_level_n_bell_x_high                              ($0a50):
;     save_game_level_n_bell_y_low                               ($0a51):
;     save_game_level_n_bell_y_high                              ($0a52):
;             position of the bell within the room
;
;     save_game_level_n_bell_room                                ($0a53):
;             room number containing the bell
;
;     save_game_level_n_bell_direction                           ($0a54):
;               0: stationary
;               1: moving right
;             $ff: moving left
;
; Solution:
;
;   1. Climb the left rope to the top and exit to the left room
;   2. Collect the clanger and return to the rope
;   3. Descend halfway down the rope and jump off to push the bell off the ledge
;   4. Push the bell to the room to the right
;   5. Use the clanger on the bell to ring it, causing the dog to drool into the umbrella
;       (The partition raises)
;   6. Collect the spell
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
inkey_key_o                           = 201
objectid_bell                         = 2
objectid_clanger                      = 4
objectid_clanger_end                  = 3
objectid_dog_head                     = 9
objectid_dog_tail                     = 8
objectid_drip                         = 7
objectid_fire1                        = 4
objectid_fire2                        = 5
objectid_partition                    = 5
objectid_partition_end                = 4
objectid_sparkles                     = 6
objectid_umbrella                     = 10
spriteid_bell                         = 225
spriteid_boulder                      = 204
spriteid_clanger                      = 223
spriteid_clanger2                     = 232
spriteid_clanger_end                  = 231
spriteid_clanger_menu_item            = 224
spriteid_dog_body                     = 209
spriteid_dog_head                     = 212
spriteid_dog_head_drooling            = 213
spriteid_droplet1                     = 217
spriteid_droplet2                     = 216
spriteid_droplet3                     = 215
spriteid_droplet4                     = 214
spriteid_erase1                       = 208
spriteid_erase2                       = 210
spriteid_erase3                       = 211
spriteid_erase4                       = 226
spriteid_erase5                       = 229
spriteid_holding_clanger              = 230
spriteid_horizontal_rope              = 202
spriteid_left_hook                    = 200
spriteid_partition                    = 206
spriteid_partition_end                = 207
spriteid_right_hook                   = 201
spriteid_rope                         = 203
spriteid_rope_end1                    = 218
spriteid_tail1                        = 219
spriteid_tail2                        = 220
spriteid_tail3                        = 221
spriteid_tail4                        = 222
spriteid_umbrella                     = 205
spriteid_using_clanger                = 227
spriteid_using_clanger_end            = 228

; Memory locations
room_exit_direction                                 = &0070
temp_x                                              = &0070
temp_y                                              = &0070
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
save_game_level_n_partition_y                       = &0a4a
save_game_level_n_dog_head_animation                = &0a4b
save_game_level_n_got_clanger                       = &0a4c
save_game_level_n_bell_animation                    = &0a4d
save_game_level_n_bell_animation_step               = &0a4e
save_game_level_n_bell_x_low                        = &0a4f
save_game_level_n_bell_x_high                       = &0a50
save_game_level_n_bell_y_low                        = &0a51
save_game_level_n_bell_y_high                       = &0a52
save_game_level_n_bell_room                         = &0a53
save_game_level_n_bell_direction                    = &0a54
dog_tail_animation_step                             = &0a6f
dog_head_animation_step                             = &0a70
drip_y_position                                     = &0a71
drip_final_delay                                    = &0a72
fast_forward_bell_counter                           = &0a73
player_is_currently_clanging_the_bell               = &0a74

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelN_sprite_table - level_data
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
    equb 2
.level_room_data_table
    equw room_0_data                                                  ; table of room data/initialisation code
    equw room_1_data
    equw room_2_data
    equw room_3_data

; *************************************************************************************
.level_specific_password
    encode "PAVLOV-WAS-HERE", &0D

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
    sta save_game_level_n_got_clanger
.developer_mode_inactive1
    lda save_game_level_n_got_clanger
    beq set_rock_tiles
    lda #spriteid_clanger_menu_item
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
    jsr room_1_update_handler
    jsr update_dog_umbrella_puzzle
    jsr room_0_update_handler
    lda #0
    sta player_is_currently_clanging_the_bell
    jsr room_2_update_handler
    jsr room_3_update_handler
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
; ####                             #######
; ###                              #######
; ###                              #######
; ###                              #######
; ###                              #######
; ###########                      #######
; ###########                      #######
; ###                              #######
; ###                              #######
; ###                              #######
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###                                  ###
; ###        ####                #########
; ###        ####                #########
;                             ############
;                             ############
;                          ###############
;                     P    ###############
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
; draw 3x16 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&10
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x10 rectangle at (33,2)
    ldx #&21 ; '!'
    lda #&ff
    sta width_in_cells
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x4 rectangle at (37,12)
    ldx #&25 ; '%'
    ldy #&0c
    lda #4
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (31,16)
    ldx #&1f
    ldy #&10
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (28,18)
    ldx #&1c
    ldy #&12
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (25,20)
    ldx #&19
    ldy #&14
    jsr copy_rectangle_of_memory_to_screen
; draw 8x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #8
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (11,16)
    ldx #&0b
    ldy #&10
    lda #4
    sta width_in_cells
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
.room_0_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_0_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.dog_head_animations
    equb 0
.dog_head_normal_animation
    equb spriteid_dog_head
    equb 0, 0
    equb &ff
.dog_head_drooling_animation
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb spriteid_dog_head_drooling
    equb spriteid_droplet1,                 0
    equb spriteid_dog_head_drooling
    equb spriteid_droplet2,                 0
    equb spriteid_dog_head_drooling
    equb spriteid_droplet3,                 0
    equb spriteid_dog_head_drooling
    equb spriteid_droplet4,                 0
    equb spriteid_dog_head_drooling
    equb spriteid_droplet4,                 2
    equb spriteid_dog_head_drooling
    equb spriteid_droplet4,                 4
    equb &ff
.dog_head_drooling_held_animation
    equb spriteid_dog_head_drooling
    equb spriteid_droplet4,                 8
    equb &ff
.dog_head_drooling_final_animation
    equb spriteid_dog_head_drooling
    equb 0, 0
    equb &ff
.dog_tail_animation
    equb spriteid_tail1
    equb spriteid_tail2
    equb spriteid_tail3
    equb spriteid_tail4
    equb &ff

.room_0_update_handler
    lda #0
    sta currently_updating_logic_for_room_index
; level completion code
    ldx #&23 ; '#'
    ldy #&10
    lda #objectid_sparkles
    jsr update_level_completion
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_0_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_changed_only
; initialise dog and drip
    lda #dog_head_normal_animation - dog_head_animations
    sta save_game_level_n_dog_head_animation
    sta dog_head_animation_step
    lda #&30 ; '0'
    sta drip_y_position
.room_changed_only
    lda desired_room_index
    cmp #0                                                            ; redundant instruction
    bne update_dog_head_and_drip_objects_local
; draw dog body
    ldx #&0b
    ldy #7
    lda #spriteid_dog_body
    jsr draw_sprite_a_at_cell_xy
; initialise dog tail object
    lda #objectid_dog_tail
    jsr set_object_position_from_cell_xy
    lda #&c0
    sta object_z_order + objectid_dog_tail
; initialise dog head object
    lda #objectid_dog_head
    jsr set_object_position_from_cell_xy
    lda #spriteid_erase2
    sta object_erase_type + objectid_dog_head
    lda #&c0
    sta object_z_order + objectid_dog_head
; initialise drip
    lda #&58 ; 'X'
    sta object_x_low + objectid_drip
    lda #spriteid_erase3
    sta object_erase_type + objectid_drip
    lda #&a0
    sta object_z_order + objectid_drip
.update_dog_head_and_drip_objects_local
    jmp update_dog_head_and_drip_objects

.room_0_not_first_update
    lda dog_head_animation_step
    clc
    adc #3
    tay
    lda dog_head_animations,y
    cmp #&ff
    bne got_dog_head_animation_step_in_y
    ldy save_game_level_n_dog_head_animation
; check for regular dog animation
.got_dog_head_animation_step_in_y
    lda save_game_level_n_dog_head_animation
    cmp #dog_head_normal_animation - dog_head_animations
    beq doing_normal_animation
; check for drooling dog animation
    cmp #dog_head_drooling_held_animation - dog_head_animations
    beq update_drip
; check for end of drooling animation
    cmp #dog_head_drooling_final_animation - dog_head_animations
    beq end_of_drooling
; could be 'lda #$ac:sec:sbc:save_game_level_n_partition_y' without adding $4c
; afterwards?
.update_drip
    lda #&60 ; '`'
    sec
    sbc save_game_level_n_partition_y
    clc
    adc #&4c ; 'L'
    cmp drip_y_position
    bcs set_dog_head_animation_step
    lda desired_room_index
    cmp #0
    bne set_end_of_dog_drooling
    jsr play_landing_sound
.set_end_of_dog_drooling
    ldy #dog_head_drooling_final_animation - dog_head_animations
    sty save_game_level_n_dog_head_animation
    lda #&30 ; '0'
    sta drip_y_position
    lda #&14
    sta drip_final_delay
    lda save_game_level_n_partition_y
    cmp #&60 ; '`'
    bne set_dog_head_animation_step
    lda #&18
    sta drip_final_delay
; move partition down 4 pixels
    lda save_game_level_n_partition_y
    sec
    sbc #4
    sta save_game_level_n_partition_y
    jmp set_dog_head_animation_step

.end_of_drooling
    dec drip_final_delay
    bne doing_normal_animation
    ldy #dog_head_normal_animation - dog_head_animations
    sty save_game_level_n_dog_head_animation
.doing_normal_animation
    lda desired_room_index
    cmp #0                                                            ; redundant instruction
    bne set_dog_head_animation_step
    lda player_is_currently_clanging_the_bell
    bne start_dog_drooling
    lda developer_flags
    bpl set_dog_head_animation_step
    ldx #inkey_key_o
    sty remember_y
    jsr negative_inkey
    ldy remember_y
    ora #0
    beq set_dog_head_animation_step
.start_dog_drooling
    ldy #dog_head_drooling_animation - dog_head_animations
    lda #dog_head_drooling_held_animation - dog_head_animations
    sta save_game_level_n_dog_head_animation
.set_dog_head_animation_step
    sty dog_head_animation_step
    iny
    iny
    lda dog_head_animations,y
    clc
    adc drip_y_position
    sta drip_y_position
    ldy dog_tail_animation_step
    iny
    lda dog_tail_animation,y
    cmp #&ff
    bne got_dog_tail_animation_step_in_y
    ldy #0
.got_dog_tail_animation_step_in_y
    sty dog_tail_animation_step
    ldy dog_head_animation_step
    lda dog_head_animations,y
    cmp #spriteid_dog_head_drooling
    beq update_dog_head_and_drip_objects
    lda #0
    sta dog_tail_animation_step
.update_dog_head_and_drip_objects
    lda desired_room_index
    cmp #0
    bne return1
    ldy dog_head_animation_step
    lda dog_head_animations,y
    sta object_spriteid + objectid_dog_head
    iny
    lda dog_head_animations,y
    sta object_spriteid + objectid_drip
    lda drip_y_position
    sta object_y_low + objectid_drip
    ldy dog_tail_animation_step
    lda dog_tail_animation,y
    sta object_spriteid + objectid_dog_tail
.return1
    rts

.remember_y
    equb 0

; check for first update in room (branch if so)
.update_dog_umbrella_puzzle
    lda update_room_first_update_flag
    bne initialise_room_0
    jmp update_room_0

; check for level change (branch if not)
.initialise_room_0
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq initialise_rope_system
    lda save_game_level_n_partition_y
    beq check_to_see_if_partition_should_be_up_or_down
    cmp #&60 ; '`'
    bne set_partition_up
.check_to_see_if_partition_should_be_up_or_down
    lda save_game_level_n_dog_head_animation
    beq set_partition_down
    cmp #dog_head_normal_animation - dog_head_animations
    beq set_partition_down
.set_partition_up
    lda #&40 ; '@'
    sta save_game_level_n_partition_y
    bne initialise_rope_system                                        ; ALWAYS branch

.set_partition_down
    lda #&60 ; '`'
    sta save_game_level_n_partition_y
.initialise_rope_system
    lda desired_room_index
    cmp #0                                                            ; redundant instruction
    bne update_partition_and_umbrella_local
    ldx #&20 ; ' '
    ldy #2
    lda #spriteid_right_hook
    jsr draw_sprite_a_at_cell_xy
    dex
    dex
    lda #spriteid_horizontal_rope
.draw_horizontal_rope_loop
    jsr draw_sprite_a_at_cell_xy
    dex
    cpx #&0f
    bcs draw_horizontal_rope_loop
    dex
    lda #spriteid_left_hook
    jsr draw_sprite_a_at_cell_xy
    lda #&60 ; '`'
    sec
    sbc save_game_level_n_partition_y
    clc
    adc #&40 ; '@'
    lsr a
    lsr a
    lsr a
    tay
    lda #spriteid_rope
.draw_vertical_rope1_loop
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_vertical_rope1_loop
    lda #&0a
    jsr set_object_position_from_cell_xy
    lda #spriteid_umbrella
    sta object_spriteid + objectid_umbrella
    lda save_game_level_n_partition_y
    sec
    sbc #4
    lsr a
    lsr a
    lsr a
    tay
    ldx #&20 ; ' '
    lda #spriteid_rope
.draw_vertical_rope2_loop
    jsr draw_sprite_a_at_cell_xy
    dey
    cpy #3
    bcs draw_vertical_rope2_loop
; initialise fire
    lda #objectid_fire1
    jsr set_object_position_from_cell_xy
    lda #objectid_fire2
    jsr set_object_position_from_cell_xy
; initialise partition
    lda #spriteid_partition
    sta object_spriteid + objectid_partition_end
    lda #&c0
    sta object_z_order + objectid_partition_end
    lda #spriteid_partition_end
    sta object_spriteid + objectid_partition
    lda #spriteid_erase1
    sta object_erase_type + objectid_partition
.update_partition_and_umbrella_local
    jmp update_partition_and_umbrella

.update_room_0
    lda desired_room_index
    cmp #0                                                            ; redundant instruction
    bne update_partition_and_umbrella
; branch if partition is fully down
    lda save_game_level_n_partition_y
    cmp #&60 ; '`'
    beq update_partition_and_umbrella
; branch if partition is fully up
    cmp #&40 ; '@'
    beq set_partition_down_and_umbrella_up
; umbrella and partition are moving
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_umbrella
    lda #&60 ; '`'
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    jmp update_partition_and_umbrella

.set_partition_down_and_umbrella_up
    lda object_y_low + objectid_partition_end
    cmp save_game_level_n_partition_y
    beq update_partition_and_umbrella
; move umbrella
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid_old + objectid_umbrella
    lda #&60 ; '`'
    jsr update_sound_priorities
    jsr play_landing_sound
.update_partition_and_umbrella
    lda desired_room_index
    cmp #0
    bne check_for_moving_partition_up
; set partition y position
    lda save_game_level_n_partition_y
    sta object_y_low + objectid_partition_end
    sta object_y_low + objectid_partition
; set umbrella y position
    lda #&60 ; '`'
    sec
    sbc save_game_level_n_partition_y
    clc
    adc #&44 ; 'D'
    sta object_y_low + objectid_umbrella
; update collision map at partition
    ldx #&20 ; ' '
    lda save_game_level_n_partition_y
    lsr a
    lsr a
    lsr a
    tay
    lda #1
    sta width_in_cells
    lda #4
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq check_for_changing_partition_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.check_for_changing_partition_collision_map
    tya
    clc
    adc height_in_cells
    tay
    sta temp_y
    lda #&10
    sec
    sbc temp_y
    beq check_for_moving_partition_up
    sta height_in_cells
    lda #collision_map_none
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq check_for_moving_partition_up
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
; check for first update in room (branch if so)
.check_for_moving_partition_up
    lda update_room_first_update_flag
    bne return2
; if partition is fully down, then return
    lda save_game_level_n_partition_y
    cmp #&60 ; '`'
    beq return2
; if partition is fully up, then return
    cmp #&40 ; '@'
    beq return2
; move partition up
    sec
    sbc #4
    sta save_game_level_n_partition_y
.return2
    rts

.update_sound_priorities
    cmp sound_priority_per_channel_table
    bcc return3
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
.return3
    rts

; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 20                                                           ; initial player X cell
    equb 21                                                           ; initial player Y cell

; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###########   |   ####   |   ###########
; ###########   |   ####   |   ###########
; ###     ###   |          |   ###     ###
; ###           |          |           ###
; ###           |          |           ###
; ###           |          |           ###
; ###           |          |           ###
; ###           |          |           ###
; ###           |          |           ###
; ###           |          |           ###
; ###           |          |           ###
; ###
; ###
; ###OOO         OOO  P
; ###OOO         OOO####
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 3x22 rectangle at (0,0)
.room_1_code
    ldx #0
    ldy #0
    lda #3
    sta width_in_cells
    lda #&16
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x18 rectangle at (37,0)
    ldx #&25 ; '%'
    lda #&12
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x18 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (8,0)
    ldx #8
    ldy #0
    lda #3
    sta width_in_cells
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (29,0)
    ldx #&1d
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (3,7)
    ldx #3
    ldy #7
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (32,7)
    ldx #&20 ; ' '
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (18,7)
    ldx #&12
    dec width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (18,21)
    ldy #&15
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (15,20) of size (3x2)
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    ldx #&0f
    ldy #&14
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw boulder at (3,20) of size (3x2)
    ldx #3
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (14,0) length 18
    ldx #&0e
    ldy #0
    lda #&12
    jsr draw_rope
; draw rope at (25,0) length 18
    ldx #&19
    jsr draw_rope
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_top
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

.room_1_update_handler
    lda #1
    sta currently_updating_logic_for_room_index
; update brazier fires
    ldx #3
    ldy #&0e
    lda #objectid_fire1
    jsr update_brazier_and_fire
    ldx #&25 ; '%'
    lda #objectid_fire2
    jmp update_brazier_and_fire

.draw_3x2_boulder_to_screen
    ldx #3
    ldy #2
    lda #1
    sta width_in_cells
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    ldx #&24 ; '$'
    jmp copy_rectangle_of_memory_to_screen

.draw_bell
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #&fc
    sta temp_sprite_x_offset
    lda #spriteid_bell
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    lda #spriteid_rope_end1
    jmp draw_sprite_a_at_cell_xy

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 27                                                           ; initial player X cell
    equb 15                                                           ; initial player Y cell

; ########################################
; ########################################
; ####          |       |    |    |   ####
; ###           |       |    |    |    ###
; ###           |       |    |    |    ###
; ###           |       |    |    |    ###
; ###           |       S    S    S    ###
; ###           |       O    O    O    ###
; ###           |                      ###
; ###           |                      ###
;               |                      ###
;               |                      ###
;               |                      ###
;               |                   OOO###
;               |            P      OOO###
; ###########   |   ######################
; ###########   |   ######################
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
; ###     ###   |          |   ###     ###
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
; draw 255x22 rectangle at (37,2)
    ldx #&25 ; '%'
    ldy #2
    lda #&16
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (0,2)
    ldx #0
    lda #3
    sta width_in_cells
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (0,15)
    ldy #&0f
    inc height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (8,15)
    ldx #8
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (29,15)
    ldx #&1d
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (3,15)
    ldx #3
    lda #5
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 5x2 rectangle at (32,15)
    ldx #&20 ; ' '
    jsr copy_rectangle_of_memory_to_screen
; draw 11x2 rectangle at (18,15)
    ldx #&12
    lda #&0b
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_3x2_boulder_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (14,2) length 255
    ldx #&0e
    ldy #2
    lda #&ff
    jsr draw_rope
; draw rope at (25,17) length 255
    ldx #&19
    ldy #&11
    jsr draw_rope
; draw rope at (22,2) length 5
    ldx #&16
    ldy #2
    lda #5
    jsr draw_rope
; draw rope at (27,2) length 5
    ldx #&1b
    jsr draw_rope
; draw rope at (32,2) length 5
    ldx #&20 ; ' '
    jsr draw_rope
; draw boulder at (34,13) of size (3x2)
    ldx #&22 ; '"'
    ldy #&0d
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    ldy #6
    ldx #&16
    jsr draw_bell
; draw clanger end at (22,6)
    lda #spriteid_clanger_end
    jsr draw_sprite_a_at_cell_xy
    ldx #&1b
    jsr draw_bell
; draw clanger end at (27,6)
    lda #spriteid_clanger_end
    jsr draw_sprite_a_at_cell_xy
    ldx #&20 ; ' '
    jsr draw_bell
; draw clanger end at (32,6)
    lda #spriteid_clanger_end
    jsr draw_sprite_a_at_cell_xy
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
    beq room_2_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.bell_animations
    equb 0
.bell_stopped_animation
    equb 0, 0
    equb &80
.bell_move_sideways_animation
    equb 8, 0
    equb &80
.bell_fall_sideways_animation
    equb 8, 2
    equb 8, 2
    equb 8, 4
    equb 8, 4
    equb 8, 6
    equb 8, 6
    equb &80
.bell_fall_animation
    equb 0, 8
    equb &80

; odd that this function mostly updates the bell normally in room 1, but also the
; braziers in room 2
.room_2_update_handler
    lda #2
    sta currently_updating_logic_for_room_index
    ldx #3
    ldy #6
    lda #objectid_fire1
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq room_2_not_first_update
; initialise envelopes
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq room_change_only
; initialise bell position in room 1
    lda save_game_level_n_bell_animation
    cmp #bell_stopped_animation - bell_animations
    beq room_change_only
    dec fast_forward_bell_counter
    ora #0
    bne room_change_only
    inc fast_forward_bell_counter
; initialise bell in room 1
    lda #1
    sta save_game_level_n_bell_room
    lda #&98
    sta save_game_level_n_bell_x_low
    lda #0
    sta save_game_level_n_bell_x_high
    lda #&28 ; '('
    sta save_game_level_n_bell_y_low
    lda #0
    sta save_game_level_n_bell_y_high
    lda #bell_stopped_animation - bell_animations
    sta save_game_level_n_bell_animation
    sta save_game_level_n_bell_animation_step
.room_change_only
    lda #spriteid_erase4
    sta object_erase_type + objectid_bell
    lda #&c0
    sta object_z_order + objectid_bell
    lda desired_room_index
    cmp save_game_level_n_bell_room
    bne initialise_bell_collision_map
    jsr set_bell_object
.fast_forward_bell_animation
    lda desired_room_index
    cmp save_game_level_n_bell_room
    bne initialise_bell_collision_map
    lda fast_forward_bell_counter
    beq initialise_bell_collision_map
    cmp #&ff
    beq more_fast_forwarding_needed
    dec fast_forward_bell_counter
.more_fast_forwarding_needed
    jsr update_bell
    jmp fast_forward_bell_animation

.initialise_bell_collision_map
    lda #collision_map_solid_rock
    jsr write_bell_to_collision_map
    jmp return4

.room_2_not_first_update
    lda desired_room_index
    cmp save_game_level_n_bell_room
    beq bell_in_room
; update fast forward counter when bell is not in the room
    lda fast_forward_bell_counter
    bmi return4_local
    inc fast_forward_bell_counter
.return4_local
    jmp return4

.bell_in_room
    lda #&40 ; '@'
    jsr update_sound_priorities
    jsr update_bell
    lda desired_room_index
    cmp save_game_level_n_bell_room
    beq update_bell_if_falling_sideways
; start counting the number of ticks the bell is off screen
    lda #0
    sta fast_forward_bell_counter
    jmp return4

.update_bell_if_falling_sideways
    lda save_game_level_n_bell_animation
    cmp #bell_fall_sideways_animation - bell_animations
    bne update_bell_if_moving_sideways
    lda save_game_level_n_bell_direction
    bpl adjust_collision_check_when_moving_right
    jmp check_for_bell_room_collision

.adjust_collision_check_when_moving_right
    inc temp_right_offset
    inc temp_left_offset
.check_for_bell_room_collision
    lda #1
    sta temp_bottom_offset
    lda #objectid_bell
    jsr get_solid_rock_collision_for_object_a
    bne play_landing_sound_local
    rts

.update_bell_if_moving_sideways
    lda save_game_level_n_bell_animation
    cmp #bell_move_sideways_animation - bell_animations
    bne check_collision_if_falling
    inc temp_right_offset
    lda #2
    jsr get_solid_rock_collision_for_object_a
    bne play_landing_sound_local
; play bell sliding sound
    lda #&40 ; '@'
    ldx #<sound1
    ldy #>sound1
    jmp play_sound_yx

.play_landing_sound_local
    jmp play_landing_sound

.check_collision_if_falling
    cmp #bell_fall_animation - bell_animations
    bne write_static_bell_to_collision_map
; check for collision with ground
    inc temp_left_offset
    lda #2
    sta temp_bottom_offset
    lda #2
    jsr get_solid_rock_collision_for_object_a
    beq return4
; bell hit rock
    lda #0
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    rts

.write_static_bell_to_collision_map
    lda #collision_map_solid_rock
    jsr write_bell_to_collision_map
.return4
    rts

.store_bell_animation_step_local
    jmp store_bell_animation_step

.update_bell
    lda save_game_level_n_bell_animation_step
    clc
    adc #2
    tay
    lda bell_animations,y
    cmp #&80
    bne got_bell_animation_step_in_y
    ldy save_game_level_n_bell_animation
.got_bell_animation_step_in_y
    lda save_game_level_n_bell_animation
    cmp #bell_stopped_animation - bell_animations
    bne bell_is_moving
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne store_bell_animation_step_local
; check for player bell collision (branch if none)
    dec temp_left_offset
    ldx #objectid_player
    sty remember_y1
    ldy #objectid_bell
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y1
    ora #0
    beq store_bell_animation_step_local
; we have a collision. Check the player is below the bell?
    lda object_y_low
    sec
    sbc save_game_level_n_bell_y_low
    lda object_y_high
    sbc save_game_level_n_bell_y_high
    bmi store_bell_animation_step_local
; find left or right direction of impact
    ldx #1
    lda object_room_collision_flags
    and #object_collided_right_wall
    bne got_direction_in_x
    ldx #&ff
    lda object_room_collision_flags
    and #object_collided_left_wall
    beq store_bell_animation_step_local
.got_direction_in_x
    stx save_game_level_n_bell_direction
; bell is about to move. clear it from the collision map
    lda #collision_map_none
    jsr write_bell_to_collision_map
    lda #spriteid_clanger_menu_item
    cmp player_using_object_spriteid
    bne set_bell_moving_sideways
; clanging bell, not moving it
    lda #0
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    lda #&ff
    sta player_is_currently_clanging_the_bell
.set_bell_moving_sideways
    ldy #bell_move_sideways_animation - bell_animations
    sty save_game_level_n_bell_animation
.bell_is_moving
    lda save_game_level_n_bell_animation
    cmp #bell_move_sideways_animation - bell_animations
    bne check_if_bell_is_falling_sideways
    lda save_game_level_n_bell_direction
    bmi check_bell_falling_rock_collision
    inc temp_right_offset
    inc temp_left_offset
    jmp check_bell_falling_rock_collision                             ; redundant instruction

.check_bell_falling_rock_collision
    lda #objectid_bell
    jsr get_solid_rock_collision_for_object_a
    bne stop_bell
    lda save_game_level_n_bell_direction
    bmi set_bell_moving_right
    lda #9
    sta temp_left_offset
    bne check_bell_moving_rock_collision
.set_bell_moving_right
    lda #&f8
    sta temp_right_offset
.check_bell_moving_rock_collision
    lda #2
    sta temp_bottom_offset
    lda #3
    sta temp_default_collision_map_option
    lda #objectid_bell
    jsr get_solid_rock_collision_for_object_a
    bne store_bell_animation_step
; set bell falling sideways
    ldy #bell_fall_sideways_animation - bell_animations
    sty save_game_level_n_bell_animation
    jmp store_bell_animation_step

.check_if_bell_is_falling_sideways
    lda save_game_level_n_bell_animation
    cmp #bell_fall_sideways_animation - bell_animations
    bne check_if_falling_straight_down
; check if at end of animation (looped)
    cpy save_game_level_n_bell_animation
    bne store_bell_animation_step
; set bell falling straight down
    ldy #bell_fall_animation - bell_animations
    sty save_game_level_n_bell_animation
.check_if_falling_straight_down
    lda save_game_level_n_bell_animation
    cmp #bell_fall_animation - bell_animations
    bne store_bell_animation_step
; bell is falling straight down
    inc temp_left_offset
    lda #2
    sta temp_bottom_offset
    lda #objectid_bell
    jsr get_solid_rock_collision_for_object_a
    beq store_bell_animation_step
.stop_bell
    lda #0
    sta fast_forward_bell_counter
    ldy #bell_stopped_animation - bell_animations
    sty save_game_level_n_bell_animation
.store_bell_animation_step
    sty save_game_level_n_bell_animation_step
    lda bell_animations,y
    ldx save_game_level_n_bell_direction
    bpl sign_extend_a_to_ax
    eor #&ff
    clc
    adc #1
.sign_extend_a_to_ax
    ldx #0
    ora #0
    bpl add_animation_offsets_to_position
    dex
.add_animation_offsets_to_position
    clc
    adc save_game_level_n_bell_x_low
    sta save_game_level_n_bell_x_low
    txa
    adc save_game_level_n_bell_x_high
    sta save_game_level_n_bell_x_high
    iny
    lda bell_animations,y
    clc
    adc save_game_level_n_bell_y_low
    sta save_game_level_n_bell_y_low
    lda #0
    adc save_game_level_n_bell_y_high
    sta save_game_level_n_bell_y_high
    jsr set_bell_object
; get extents of bell object
    ldx #objectid_bell
    jsr find_left_and_right_of_object
    jsr find_top_and_bottom_of_object
; check if bell is moving sideways (return if not)
    lda save_game_level_n_bell_animation
    cmp #bell_move_sideways_animation - bell_animations
    bne return5
; check if bell has moved offscreen, into the next room
    lda save_game_level_n_bell_direction
    bmi move_bell_left_one_room_if_needed
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return5
; move ball right one room
    lda save_game_level_n_bell_x_low
    sec
    sbc #&40 ; '@'
    sta save_game_level_n_bell_x_low
    lda #0
    sbc #0
    sta save_game_level_n_bell_x_high
    dec save_game_level_n_bell_room
    jmp hide_bell

.move_bell_left_one_room_if_needed
    lda object_right_cell_x
    bpl return5
    lda save_game_level_n_bell_x_low
    clc
    adc #&40 ; '@'
    sta save_game_level_n_bell_x_low
    lda #1
    sta save_game_level_n_bell_x_high
    inc save_game_level_n_bell_room
    jmp hide_bell                                                     ; redundant instruction

.hide_bell
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_bell
.return5
    rts

.remember_y1
    equb 0

.set_bell_object
    lda save_game_level_n_bell_x_low
    sta object_x_low + objectid_bell
    lda save_game_level_n_bell_x_high
    sta object_x_high + objectid_bell
    lda save_game_level_n_bell_y_low
    sta object_y_low + objectid_bell
    lda save_game_level_n_bell_y_high
    sta object_y_high + objectid_bell
    lda #spriteid_bell
    sta object_spriteid + objectid_bell
    rts

.write_bell_to_collision_map
    sta value_to_write_to_collision_map
    ora #0
    beq validated_the_write
    lda save_game_level_n_bell_animation
    cmp #bell_stopped_animation - bell_animations
    bne return6
.validated_the_write
    lda desired_room_index
    cmp save_game_level_n_bell_room
    bne return6
    lda save_game_level_n_bell_x_high
    lsr a
    sta temp_x
    lda save_game_level_n_bell_x_low
    ror a
    lsr temp_x
    ror a
    lsr temp_x
    ror a
    tax
    lda save_game_level_n_bell_y_high
    lsr a
    sta temp_x
    lda save_game_level_n_bell_y_low
    ror a
    lsr temp_x
    ror a
    lsr temp_x
    ror a
    tay
    lda #2
    sta width_in_cells
    sta height_in_cells
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return6
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return6
    rts

; *************************************************************************************
; 
; Room 3 initialisation and game loop
; 
; *************************************************************************************
.room_3_data
    equb 12                                                           ; initial player X cell
    equb 15                                                           ; initial player Y cell

; ########################################
; ########################################
; ####   |    |    |       |          ####
; ###    |    |    |       |           ###
; ###    |    |    |       |           ###
; ###    |    |    |       |           ###
; ###    S    S    S       |           ###
; ###    O    O    O       |           ###
; ###                      |           ###
; ###                      |           ###
; ###                      |
; ###                      |
; ###                      |
; ###OOO                   |
; ###OOO      P            |
; ######################   |   ###########
; ######################   |   ###########
; ###                      |           ###
; ###                      |           ###
; ###                      |           ###
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
; draw 3x20 rectangle at (0,2)
    ldy #2
    lda #3
    sta width_in_cells
    lda #&14
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x8 rectangle at (37,2)
    ldx #&25 ; '%'
    lda #8
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (37,15)
    ldy #&0f
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 19x2 rectangle at (3,15)
    ldx #3
    lda #&13
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 8x2 rectangle at (29,15)
    ldx #&1d
    lda #8
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
    jsr draw_3x2_boulder_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (25,2) length 18
    ldx #&19
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (7,2) length 5
    ldx #7
    lda #5
    jsr draw_rope
; draw rope at (12,2) length 5
    ldx #&0c
    jsr draw_rope
; draw rope at (17,2) length 5
    ldx #&11
    jsr draw_rope
; draw boulder at (3,13) of size (3x2)
    ldx #3
    ldy #&0d
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
    ldy #6
    ldx #7
    jsr draw_bell
    ldx #&0c
    jsr draw_bell
; draw clanger end at (12,6)
    lda #spriteid_clanger_end
    jsr draw_sprite_a_at_cell_xy
    ldx #&11
    jsr draw_bell
; draw clanger end at (17,6)
    lda #spriteid_clanger_end
    jsr draw_sprite_a_at_cell_xy
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
    ldx #&25 ; '%'
    ldy #6
    lda #objectid_fire2
    jsr update_brazier_and_fire
; check for first update in room (branch if not)
    lda update_room_first_update_flag
    beq update_clanger
; initialise envelopes
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
; initialise clanger
    lda #spriteid_clanger_menu_item
    sta toolbar_collectable_spriteids+1
    lda #spriteid_clanger
    sta collectable_spriteids+1
    lda #spriteid_using_clanger
    sta collectable_being_used_spriteids + 1
    lda #spriteid_erase5
    sta object_erase_type + objectid_clanger_end
    lda #&40 ; '@'
    sta object_z_order + objectid_clanger_end
; branch if player has the clanger in the toolbox but is not holding it
    lda save_game_level_n_got_clanger
    bne got_clanger_so_now_check_if_using_clanger
; branch (return) if not in room 3
    lda desired_room_index
    cmp #3
    bne return7_local
; position the clanger in room 3
    ldx #6
    ldy #&0f
    lda #objectid_clanger
    jsr set_object_position_from_cell_xy
    lda #spriteid_erase2
    sta object_erase_type + objectid_clanger
    lda #spriteid_clanger2
    sta object_spriteid + objectid_clanger
.return7_local
    jmp return7

.update_clanger
    lda save_game_level_n_got_clanger
    bne got_clanger_so_now_check_if_using_clanger
    lda desired_room_index
    cmp #3
    bne return7_local2
    ldx #objectid_old_player
    ldy #4
    jsr test_for_collision_between_objects_x_and_y
    beq return7_local2
    lda #&ff
    sta save_game_level_n_got_clanger
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_clanger
    lda #spriteid_clanger_menu_item
    jsr find_or_create_menu_slot_for_A
.return7_local2
    jmp return7

; hold clanger (only used when it was on the floor)
.got_clanger_so_now_check_if_using_clanger
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_clanger_end
    lda #spriteid_clanger_menu_item
    cmp player_using_object_spriteid
    bne return7_local2
; check if using clanger (return if not)
    lda #spriteid_holding_clanger
    sta object_spriteid + objectid_player_accessory
    lda #objectid_player_accessory
    jsr get_solid_rock_collision_for_object_a
    beq return7_local2
    lda object_y_low
    cmp save_game_level_n_bell_y_low
    bcc check_collision_while_holding_clanger_then_set_using_clanger
    dec temp_right_offset
    ldx #objectid_player_accessory
    ldy #objectid_bell
    jsr test_for_collision_between_objects_x_and_y
    beq check_collision_while_holding_clanger_then_set_using_clanger
; copy the player accessory object to the clanger object
    lda #spriteid_using_clanger
    sta object_spriteid + objectid_player_accessory
    lda object_x_low + objectid_player_accessory
    sta object_x_low + objectid_clanger_end
    lda object_x_high + objectid_player_accessory
    sta object_x_high + objectid_clanger_end
    lda object_y_low + objectid_player_accessory
    sta object_y_low + objectid_clanger_end
    lda object_y_high + objectid_player_accessory
    sta object_y_high + objectid_clanger_end
    lda object_direction + objectid_player_accessory
    sta object_direction + objectid_clanger_end
    lda #spriteid_using_clanger_end
    sta object_spriteid + objectid_clanger_end
    inc temp_right_offset
    dec temp_left_offset
    inc temp_right_offset
    lda #1
    jsr get_solid_rock_collision_for_object_a
    beq return7
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne return7
    lda #spriteid_clanger_menu_item
    cmp previous_player_using_object_spriteid
    beq return7
    lda player_is_currently_clanging_the_bell
    bne return7
    dec player_is_currently_clanging_the_bell
    lda #0
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    jmp return7

.check_collision_while_holding_clanger_then_set_using_clanger
    lda #spriteid_holding_clanger
    sta collectable_being_used_spriteids + 1
    lda #0
    jsr update_object_a_solid_rock_collision
    lda #spriteid_using_clanger
    sta collectable_being_used_spriteids + 1
.return7
    rts

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
.envelope3
    equb 7                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 55                                                           ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 254                                                          ; change of amplitude per step during sustain phase
    equb 252                                                          ; change of amplitude per step during release phase
    equb 110                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound4
    equw 3                                                            ; channel
    equw 7                                                            ; amplitude
    equw 200                                                          ; pitch
    equw 1                                                            ; duration
.ground_fill_2x2_top_left
    equb %10001000
    equb %00001000
    equb %00001111
    equb %00010000
    equb %11100000
    equb %00100000
    equb %00100011
    equb %00100010
.ground_fill_2x2_top_right
    equb %00100011
    equb %00100000
    equb %11100000
    equb %00010000
    equb %00001111
    equb %00001000
    equb %10001000
    equb %10001000
.ground_fill_2x2_bottom_left
    equb %00100011
    equb %00100000
    equb %11100000
    equb %00010000
    equb %00001111
    equb %00001000
    equb %10001000
    equb %10001000
.ground_fill_2x2_bottom_right
    equb %10001000
    equb %00001000
    equb %00001111
    equb %00010000
    equb %11100000
    equb %00100000
    equb %00100011
    equb %00100010
IF swr_renderer_enabled
INCLUDE "build/runtime/levelN_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelN.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelN"
ENDIF
ENDIF
.pydis_end

save "build/dataN", pydis_start, pydis_end
