; *************************************************************************************
;
; Level H: 'APPLESOURCE'
;
; Save game variables:
;
;     save_game_level_h_rail_rope_x_cell            ($0a1a):
;             $0c: left side position
;         $0d-$1a: rope is moving between left and right
;             $1b: right side position
;
;     save_game_level_h_rail_rope_current_dir       ($0a1b):
;               0: not moving
;               1: moving right
;             $ff: moving left
;
;     save_game_level_h_current_fruit_animation     ($0a1c):
;               0: not started
;               1: initial idle animation
;               4: fall sideways 1
;             $0d: stopped
;             $10: moving sideways
;             $13: fall sideways 2
;             $1a: fall straight down
;
;     save_game_level_h_fruit_animation_step        ($0a1d):
;         $00-$1c: animation index for the current fruit step
;
;     save_game_level_h_fruit_x_low                 ($0a1e):
;     save_game_level_h_fruit_x_high                ($0a1f):
;               pixel X position for fruit
;
;     save_game_level_h_fruit_y_low                 ($0a20):
;     save_game_level_h_fruit_y_high                ($0a21):
;               pixel Y position for fruit
;
;     save_game_level_h_fruit_room                  ($0a22):
;            $0-3: room the fruit is in
;
;     save_game_level_h_current_fruit_direction     ($0a23):
;         $ff/1/0: direction of fruit ($ff=left, $0,=none, $1=right)
;
; Solution:
;
;   1. move to the room on the right, climb the rope pointing left.
;   2. Jump at the point the rabbit turns away, and climb the flower.
;   3. Wait for the rabbit to go past, and continue into the room to the left.
;   4. Up the rope, knock the fruit to the right at the top center of the room
;       (The fruit falls into the room below)
;   5. Push the fruit to the right and follow it.
;       (The fruit falls)
;   6. Push the fruit to the left and follow it.
;   7. Use the cat to climb the fruit and use the monkey to climb the 'this way' rope,
;      and out of the room to the left.
;   8. Climb the leftmost rope, and jump onto (and hold) the rail rope to the other side.
;   9. Jump off the ropes to the right, then reverse direction and ride the rail back
;      to get to the spell.
;
; *************************************************************************************

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
objectid_fruit                        = 2
objectid_rabbit                       = 3
objectid_rail_rope_end                = 3
objectid_spell                        = 5
spriteid_boulder                      = 206
spriteid_cache1                       = 203
spriteid_cache2                       = 205
spriteid_fruit                        = 208
spriteid_horizontal_rail              = 200
spriteid_leaf                         = 214
spriteid_long_rope_end                = 204
spriteid_missing                      = 212
spriteid_rabbit_push                  = 219
spriteid_rabbit_sit                   = 218
spriteid_rabbit_walk_1                = 215
spriteid_rabbit_walk_2                = 216
spriteid_rabbit_walk_3                = 217
spriteid_rail_left_corner             = 201
spriteid_rail_right_corner            = 202
spriteid_stalk_bottom                 = 211
spriteid_stalk_middle                 = 210
spriteid_stalk_top                    = 209
spriteid_table                        = 207
spriteid_way_out                      = 213

; Memory locations
movement_low                                        = &0070
room_exit_direction                                 = &0070
movement_high                                       = &0071
object_left_cell_x                                  = &0078
object_right_cell_x                                 = &0079
object_top_cell_y                                   = &007a
save_game_level_h_rail_rope_x_cell                  = &0a1a
save_game_level_h_rail_rope_current_dir             = &0a1b
save_game_level_h_current_fruit_animation           = &0a1c
save_game_level_h_fruit_animation_step              = &0a1d
save_game_level_h_fruit_x_low                       = &0a1e
save_game_level_h_fruit_x_high                      = &0a1f
save_game_level_h_fruit_y_low                       = &0a20
save_game_level_h_fruit_y_high                      = &0a21
save_game_level_h_fruit_room                        = &0a22
save_game_level_h_current_fruit_direction           = &0a23
fruit_timer                                         = &0a6f
rabbit_sprite_animation                             = &0a70
rabbit_sprite_animation_step                        = &0a71
rabbit_x                                            = &0a72
rabbit_direction                                    = &0a73
rabbit_speed                                        = &0a74
l0a75                                               = &0a75

org level_data_load_address

; *************************************************************************************
; 
; Level header
; 
; *************************************************************************************
.level_data
.pydis_start
    IF swr_renderer_enabled
    EQUW levelH_sprite_table - level_data
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
    encode "APPLESOURCE", &0D

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
    beq developer_mode_inactive
    lda developer_flags
    bpl developer_mode_inactive
.developer_mode_inactive
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
    jsr update_rabbit_puzzle
    jsr update_fruit_puzzle
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
; ####     |                    |     ####
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |
; ###      |                    |
; ###      |                    |
; ###      |                    |
; ###      |                    |
; #######  |      ########      |  #######
; #######  |      ########      |  #######
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###                                  ###
; ###                                  ###
; ###OOO                            OOO###
; ###OOO              P             OOO###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x9 rectangle at (37,13)
    ldy #&0d
    lda #9
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (33,13)
    ldx #&21 ; '!'
    lda #4
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (3,13)
    ldx #3
    jsr copy_rectangle_of_memory_to_screen
; draw 8x2 rectangle at (16,13)
    ldx #&10
    lda #8
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw boulder at (3,20) of size (3x2)
    ldx #2
    stx height_in_cells
    inx
    stx width_in_cells
    ldy #&14
    lda #spriteid_boulder
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw table at (34,20) of size (3x2)
    ldx #&22 ; '"'
    lda #spriteid_table
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (9,2) length 16
    ldx #9
    ldy #2
    lda #&10
    jsr draw_rope
; draw rope at (30,2) length 16
    ldx #&1e
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
    ldx #&25 ; '%'
    ldy #5
    lda #4
    jsr update_brazier_and_fire
    ldx #5
    ldy #&0d
    lda #objectid_spell
    jsr update_level_completion
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne room_0_first_update
    jmp check_if_player_is_on_room_0_rope

; check for level change (branch if not)
.room_0_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq rail_rope_not_moving
; initiailise new level
    ldx #<envelope1
    ldy #>envelope1
    jsr define_envelope
    lda save_game_level_h_rail_rope_x_cell
    beq set_rail_rope_to_initial_position
    lda save_game_level_h_rail_rope_current_dir
    beq rail_rope_not_moving
    bpl set_rail_rope_to_far_right
; set rail rope to far left
    lda #&0c
    sta save_game_level_h_rail_rope_x_cell
    jmp stop_rail_rope

.set_rail_rope_to_far_right
    lda #&1b
    sta save_game_level_h_rail_rope_x_cell
    jmp stop_rail_rope

.set_rail_rope_to_initial_position
    lda #&0c
    sta save_game_level_h_rail_rope_x_cell
.stop_rail_rope
    lda #0
    sta save_game_level_h_rail_rope_current_dir
; check for being in room 0, and branch otherwise
.rail_rope_not_moving
    lda desired_room_index
    cmp #0
    bne set_rail_rope_object_position_and_collision_map_local1
; in room 0. set rail collision
    ldx #&0c
    ldy #2
    lda #&10
    sta width_in_cells
    lda #1
    sta height_in_cells
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
; draw rail itself, with corners
    iny
    lda #spriteid_rail_left_corner
    jsr draw_sprite_a_at_cell_xy
    inx
    lda #spriteid_horizontal_rail
.draw_rail_loop
    jsr draw_sprite_a_at_cell_xy
    inx
    cpx #&1b
    bcc draw_rail_loop
    lda #spriteid_rail_right_corner
    jsr draw_sprite_a_at_cell_xy
; draw end of rope on the rail
    lda #spriteid_long_rope_end
    sta object_spriteid + objectid_rail_rope_end
    lda #spriteid_cache1
    sta object_erase_type + objectid_rail_rope_end
.set_rail_rope_object_position_and_collision_map_local1
    jmp set_rail_rope_object_position_and_collision_map

.check_if_player_is_on_room_0_rope
    lda #0
    sta player_is_on_room_0_rope_flag
    lda desired_room_index
    cmp #0
    bne check_rope_direction
    lda current_player_character
    cmp #spriteid_icodata_monkey
    bne check_rope_direction
    ldx #objectid_player
    ldy #objectid_rail_rope_end
    jsr test_for_collision_between_objects_x_and_y
    beq check_rope_direction
    lda current_player_animation
    cmp #monkey_climb_animation - monkey_base_animation
    beq player_is_on_rope
    cmp #monkey_climb_idle_animation - monkey_base_animation
    beq player_is_on_rope
    cmp #monkey_climb_down_animation - monkey_base_animation
    bne check_rope_direction
.player_is_on_rope
    dec player_is_on_room_0_rope_flag
.check_rope_direction
    lda save_game_level_h_rail_rope_current_dir
    bne update_rail_x_position
; check if player is on the rope
    lda player_is_on_room_0_rope_flag
    beq set_rail_rope_object_position_and_collision_map_local
; is the rail rope to the left? branch if not
    lda save_game_level_h_rail_rope_x_cell
    cmp #&0c
    bne rail_rope_not_left
; if the player is looking left, then branch
    lda object_direction
    bmi set_rail_rope_object_position_and_collision_map_local
; start moving the rail rope right
    inc save_game_level_h_rail_rope_current_dir
    jmp update_rail_x_position

; if the player is looking right, then branch
.rail_rope_not_left
    lda object_direction
    bpl set_rail_rope_object_position_and_collision_map_local
; start moving the rail rope left
    dec save_game_level_h_rail_rope_current_dir
    jmp update_rail_x_position

.set_rail_rope_object_position_and_collision_map_local
    jmp set_rail_rope_object_position_and_collision_map

; add direction to cell x
.update_rail_x_position
    lda save_game_level_h_rail_rope_x_cell
    clc
    adc save_game_level_h_rail_rope_current_dir
    sta save_game_level_h_rail_rope_x_cell
; check if the player is on the rope, branch if not
    lda player_is_on_room_0_rope_flag
    beq update_rail_moving_sound
; multiply the direction by eight, and sign extend using x as the high byte
    ldx #0
    lda save_game_level_h_rail_rope_current_dir
    asl a
    asl a
    asl a
    sta movement_low
    bpl sign_extended
    dex
.sign_extended
    stx movement_high
; add to the player x position
    lda object_x_low
    clc
    adc movement_low
    sta object_x_low
    lda object_x_high
    adc movement_high
    sta object_x_high
; add to the player accessory x position
    lda object_x_low + objectid_player_accessory
    clc
    adc movement_low
    sta object_x_low + objectid_player_accessory
    lda object_x_high + objectid_player_accessory
    adc movement_high
    sta object_x_high + objectid_player_accessory
; branch if rail rope is at either end
.update_rail_moving_sound
    lda save_game_level_h_rail_rope_x_cell
    cmp #&0c
    beq rail_at_either_end
    cmp #&1b
    beq rail_at_either_end
; branch if not in room zero
    lda desired_room_index
    cmp #0
    bne set_rail_rope_object_position_and_collision_map
; make rail movement sound
    lda #&40 ; '@'
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    jmp set_rail_rope_object_position_and_collision_map

.rail_at_either_end
    lda #0
    sta save_game_level_h_rail_rope_current_dir
    lda desired_room_index
    cmp #0
    bne set_rail_rope_object_position_and_collision_map
; reset sound priorities
    lda sound_priority_per_channel_table
    cmp #&41 ; 'A'
    bcs end_of_move_sound
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
.end_of_move_sound
    jsr play_landing_sound
; the following tests are redundant. branch if player is not on rope
    lda player_is_on_room_0_rope_flag
    beq set_rail_rope_object_position_and_collision_map
    lda #6                                                            ; redundant instruction
; this test is redundant. branch if player is looking right
    lda object_direction
    bpl set_rail_rope_object_position_and_collision_map
; this is redundant. player is on rope and looking left
    lda #&fa
; branch if not in room zero
.set_rail_rope_object_position_and_collision_map
    lda desired_room_index
    cmp #0
    bne return1
; position the rail rope
    ldx save_game_level_h_rail_rope_x_cell
    ldy #3
    lda #objectid_rail_rope_end
    jsr set_object_position_from_cell_xy
; write to the collision map
    lda #1
    sta width_in_cells
    lda #2
    sta height_in_cells
    lda #collision_map_rope
    sta value_to_write_to_collision_map
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return1
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
; write zero to either side of the rail rope
    lda #collision_map_none
    sta value_to_write_to_collision_map
    dex
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
    inx
    inx
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return1
    rts

.player_is_on_room_0_rope_flag
    equb 0
; *************************************************************************************
; 
; Room 1 initialisation and game loop
; 
; *************************************************************************************
.room_1_data
    equb 20                                                           ; initial player X cell
    equb 22                                                           ; initial player Y cell

; ############################  |  #######
; ############################  |  #######
; ####     |     #####          |     ####
; ###      |      ###           |      ###
; ###      |      ###           |      ###
; ###      |      ###           |      ###
; ###      |      ###           |      ###
; ###      S      ###           |      ###
;          |      ###           |
;          |      ###           |
;          |      ###           |
;          |      ###
;          |      #######
; #######  |  ############################
; #######  |  ############################
; ###      |
; ###      |
; ###      |
; ###
; ###
; ###
; ###                 P
; ########################################
; ########################################
; draw rectangles of ground fill rock with a 2x2 pattern. Also writes to the collision
; map.
; draw 28x2 rectangle at (0,0)
.room_1_code
    ldx #0
    ldy #0
    lda #&1c
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 28x2 rectangle at (33,0)
    ldx #&21 ; '!'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (0,2)
    ldx #0
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 5x1 rectangle at (15,2)
    ldx #&0f
    inc width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (0,3)
    ldx #0
    iny
    lda #3
    sta width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (37,3)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x10 rectangle at (16,3)
    ldx #&10
    lda #&0a
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (19,12)
    ldx #&13
    ldy #&0c
    lda #4
    sta width_in_cells
    lda #1
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x2 rectangle at (0,13)
    ldx #0
    ldy #&0d
    lda #7
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (12,13)
    ldx #&0c
    lda #&ff
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 255x2 rectangle at (0,22)
    ldx #0
    ldy #&16
    jsr copy_rectangle_of_memory_to_screen
; draw 3x7 rectangle at (0,15)
    ldy #&0f
    lda #3
    sta width_in_cells
    lda #7
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (9,2) length 16
    ldx #9
    ldy #2
    lda #&10
    jsr draw_rope
; draw rope at (30,0) length 11
    ldx #&1e
    ldy #0
    lda #&0b
    jsr draw_rope
    ldx #9
    ldy #6
    lda #3
    jsr write_a_single_value_to_cell_in_collision_map
; draw way out at (9,7)
    iny
    lda #spriteid_way_out
    jsr draw_sprite_a_at_cell_xy
    jsr start_room
.room_1_game_update_loop
    jsr game_update
    sta room_exit_direction
    and #exit_room_top
    beq room_1_check_left_exit
    ldx #3
    ldy current_level
    jmp initialise_level_and_room

.room_1_check_left_exit
    lda room_exit_direction
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
    ldx #&25 ; '%'
    ldy #5
    lda #3
    jsr update_brazier_and_fire
    rts

; *************************************************************************************
; 
; Room 2 initialisation and game loop
; 
; *************************************************************************************
.room_2_data
    equb 20                                                           ; initial player X cell
    equb 21                                                           ; initial player Y cell

; ########################################
; ########################################
; ####     |  ################  |     ####
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
;          |                    |      ###
;          |                    |      ###
;          |                    |      ###
;                               |      ###
;                               |      ###
; #######     ################  |  #######
; #######     ################  |  #######
;                               |      ###
;                               |      ###
;                               |      ###
;                               |      ###
;                               |      ###
;                     P                ###
;             ################         ###
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x5 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #5
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (37,3)
    ldx #&25 ; '%'
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 7x2 rectangle at (0,13)
    ldx #0
    ldy #&0d
    lda #7
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,13)
    ldx #&0c
    lda #&10
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (33,13)
    ldx #&21 ; '!'
    lda #4
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x1 rectangle at (12,2)
    ldx #&0c
    ldy #2
    lda #&10
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x1 rectangle at (12,21)
    ldy #&15
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw rope at (9,2) length 9
    ldx #9
    ldy #2
    lda #9
    jsr draw_rope
; draw rope at (30,2) length 18
    ldx #&1e
    lda #&12
    jsr draw_rope
    jsr start_room
.room_2_game_update_loop
    jsr game_update
    and #exit_room_left
    beq room_2_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

.rabbit_sprites_base
    equb 0
.rabbit_walk_sprites
    equb spriteid_rabbit_walk_1
    equb spriteid_rabbit_walk_2
    equb spriteid_rabbit_walk_3
    equb spriteid_rabbit_sit
    equb &ff
.rabbit_sit_sprites
    equb spriteid_rabbit_sit
    equb &ff
.rabbit_push_sprites
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb spriteid_rabbit_push
    equb &ff

; check for first update in room (branch if not)
.update_rabbit_puzzle
    lda update_room_first_update_flag
    beq update_rabbit_not_first_update
; check for level change (branch if not)
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq new_room_only1
; new level
    lda #rabbit_sit_sprites  - rabbit_sprites_base
    sta rabbit_sprite_animation
    sta rabbit_sprite_animation_step
    lda #0
    sta l0a75
    lda #&80
    sta rabbit_x
    lda #1
    sta rabbit_direction
    sta rabbit_speed
.new_room_only1
    ldx #<envelope2
    ldy #>envelope2
    jsr define_envelope
    lda desired_room_index
    cmp #2
    bne update_rabbit_object_local
    ldx #&14
    ldy #&0d
    lda #7
    jsr draw_plant_a_at_cell_xy_and_add_to_collision_map
    lda #spriteid_cache2
    sta object_erase_type + objectid_rabbit
    lda #&66 ; 'f'
    sta object_y_low + objectid_rabbit
.update_rabbit_object_local
    jmp update_rabbit_object

.update_rabbit_not_first_update
    lda rabbit_sprite_animation_step
    clc
    adc #1
    tay
    lda rabbit_sprites_base,y
    cmp #&ff
    bne got_animation_step_y
    ldy rabbit_sprite_animation
.got_animation_step_y
    lda desired_room_index
    cmp #2
    bne rabbit_animation
; in room 2
    ldx #objectid_rabbit
    sty remember_y
    ldy #objectid_player
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y
    ora #0
    beq rabbit_animation
    ldy #rabbit_push_sprites - rabbit_sprites_base
    lda #rabbit_sit_sprites  - rabbit_sprites_base
    sta rabbit_sprite_animation
    lda #&0c
    sta l0a75
    lda object_x_low
    cmp object_x_low + objectid_rabbit
    bcc player_bounces_off_the_rabbit_to_the_left
    lda #6
    sta player_wall_collision_reaction_speed
    lda #1
    sta rabbit_direction
    bne update_rabbit_animation_step_local                            ; ALWAYS branch

.player_bounces_off_the_rabbit_to_the_left
    lda #&fa
    sta player_wall_collision_reaction_speed
    lda #&ff
    sta rabbit_direction
.update_rabbit_animation_step_local
    jmp update_rabbit_animation_step

.rabbit_animation
    lda rabbit_sprite_animation
    cmp #rabbit_sit_sprites  - rabbit_sprites_base
    bne rabbit_is_hopping_along
    dec l0a75
    bpl update_rabbit_animation_step_local
    ldy #rabbit_walk_sprites - rabbit_sprites_base
    sty rabbit_sprite_animation
    lda rabbit_speed
    sta rabbit_direction
    lda rabbit_x
    cmp #&70 ; 'p'
    beq reverse_direction
    cmp #&d0
    bne rabbit_is_hopping_along
.reverse_direction
    lda rabbit_speed
    eor #&fe
    sta rabbit_speed
    sta rabbit_direction
.rabbit_is_hopping_along
    lda rabbit_sprite_animation
    cmp #rabbit_walk_sprites - rabbit_sprites_base
    bne update_rabbit_animation_step
    cpy #fruit_fall_sideways_animation1 - fruit_animation_base
    bne move_rabbit
    lda desired_room_index
    cmp #2
    bne move_rabbit
    sty remember_y
    lda #0
    ldx #<sound2
    ldy #>sound2
    jsr play_sound_yx
    ldx #<sound3
    ldy #>sound3
    jsr play_sound_yx
    ldx #<sound4
    ldy #>sound4
    jsr play_sound_yx
    ldy remember_y
.move_rabbit
    lda rabbit_speed
    asl a
    asl a
    clc
    adc rabbit_x
    sta rabbit_x
    cmp #&70 ; 'p'
    beq rabbit_at_end_of_walking
    cmp #&d0
    bne update_rabbit_animation_step
.rabbit_at_end_of_walking
    ldy #rabbit_sit_sprites - rabbit_sprites_base
    sty rabbit_sprite_animation
    lda #fruit_fall_sideways_animation1 - fruit_animation_base
    sta l0a75
.update_rabbit_animation_step
    sty rabbit_sprite_animation_step
.update_rabbit_object
    lda desired_room_index
    cmp #2
    bne return2
; in room 2. set rabbit object
    ldy rabbit_sprite_animation_step
    lda rabbit_sprites_base,y
    sta object_spriteid + objectid_rabbit
    lda rabbit_x
    sta object_x_low + objectid_rabbit
    lda rabbit_direction
    sta object_direction + objectid_rabbit
.return2
    rts

.remember_y
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
; ####     |  ################  |     ####
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###OOO   |                    |      ###
; ###OOO   |                    |      ###
; #######  |  ################  |  #######
; #######  |  ################  |  #######
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###      |                    |      ###
; ###                           |   OOO###
; #######             P         |   OOO###
; ############################  |  #######
; ############################  |  #######
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
; draw 4x1 rectangle at (0,2)
    ldy #2
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (36,2)
    ldx #&24 ; '$'
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (0,3)
    ldx #0
    iny
    dec width_in_cells
    lda #&13
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 3x19 rectangle at (37,3)
    ldx #&25 ; '%'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (3,13)
    ldx #3
    ldy #&0d
    lda #4
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 4x2 rectangle at (33,13)
    ldx #&21 ; '!'
    jsr copy_rectangle_of_memory_to_screen
; draw 16x2 rectangle at (12,13)
    ldx #&0c
    lda #&10
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 28x2 rectangle at (0,22)
    ldx #0
    ldy #&16
    lda #&1c
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 28x2 rectangle at (33,22)
    ldx #&21 ; '!'
    jsr copy_rectangle_of_memory_to_screen
; draw 4x1 rectangle at (3,21)
    ldx #3
    dey
    lda #4
    sta width_in_cells
    dec height_in_cells
    jsr copy_rectangle_of_memory_to_screen
; draw 16x1 rectangle at (12,2)
    ldx #&0c
    ldy #2
    lda #&10
    sta width_in_cells
    jsr copy_rectangle_of_memory_to_screen
; carve the floor, walls and ceiling into the rock
    jsr draw_floor_walls_and_ceiling_around_solid_rock
; draw fruit at (3,11) of size (3x2)
    ldx #2
    stx height_in_cells
    inx
    stx width_in_cells
    ldy #&0b
    lda #spriteid_fruit
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw fruit at (34,20) of size (3x2)
    ldx #&22 ; '"'
    ldy #&14
    jsr draw_sprite_a_at_cell_xy_and_write_to_collision_map
; draw rope at (9,2) length 18
    ldx #9
    ldy #2
    lda #&12
    jsr draw_rope
; draw rope at (30,2) length 255
    ldx #&1e
    lda #&ff
    jsr draw_rope
    jsr start_room
.room_3_game_update_loop
    jsr game_update
    and #exit_room_bottom
    beq room_3_game_update_loop
    ldx #1
    ldy current_level
    jmp initialise_level_and_room

; (x,y) fruit offsets for animation
.fruit_animation_base
    equb 0
.fruit_initial_idle_animation
    equb 0, 0
    equb &80
.fruit_fall_sideways_animation1
    equb 8, 2
    equb 8, 2
    equb 4, 4
    equb 4, 4
    equb &80
.fruit_stopped_animation
    equb 0, 0
    equb &80
.fruit_sideways_animation
    equb 8, 0
    equb &80
.fruit_fall_sideways_animation2
    equb 8, 2
    equb 8, 2
    equb 8, 4
    equb &80
.fruit_fall_straight_down_animation
    equb 0, 8
    equb &80

; check for first update in room (branch if so)
.update_fruit_puzzle
    lda update_room_first_update_flag
    bne update_fruit_first_update
    jmp update_fruit_timer

; check for level change (branch if not)
.update_fruit_first_update
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq new_room_only2
; new level. initialise fruit
    ldx #<envelope3
    ldy #>envelope3
    jsr define_envelope
    lda #0
    sta fruit_timer
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_stopped_animation - fruit_animation_base
    beq new_room_only2
    cmp #fruit_initial_idle_animation - fruit_animation_base
    beq new_room_only2
    dec fruit_timer
    ora #0
    bne new_room_only2
    inc fruit_timer
    lda #3
    sta save_game_level_h_fruit_room
    lda #&98
    sta save_game_level_h_fruit_x_low
    lda #0
    sta save_game_level_h_fruit_x_high
    lda #&2c ; ','
    sta save_game_level_h_fruit_y_low
    lda #0
    sta save_game_level_h_fruit_y_high
    lda #fruit_initial_idle_animation - fruit_animation_base
    sta save_game_level_h_current_fruit_animation
    sta save_game_level_h_fruit_animation_step
.new_room_only2
    lda desired_room_index
    beq fruit_fully_fast_forwarded
    cmp #3
    bne not_room_3
; draw room 3 plant
    ldx #&14
    ldy #&0d
    lda #6
    jsr draw_plant_a_at_cell_xy_and_add_to_collision_map
.not_room_3
    lda #spriteid_cache1
    sta object_erase_type + objectid_fruit
    lda desired_room_index
    cmp save_game_level_h_fruit_room
    bne fruit_fully_fast_forwarded
    jsr set_fruit_object_position
.fast_forward_fruit_animation_loop
    lda desired_room_index
    cmp save_game_level_h_fruit_room
    bne fruit_fully_fast_forwarded
    lda fruit_timer
    beq fruit_fully_fast_forwarded
    cmp #&ff
    beq fruit_not_done_yet
    dec fruit_timer
.fruit_not_done_yet
    jsr update_fruit_animation
    jmp fast_forward_fruit_animation_loop

.fruit_fully_fast_forwarded
    lda #collision_map_solid_rock
    jsr write_fruit_collision_map
    jmp return3

.update_fruit_timer
    lda desired_room_index
    cmp save_game_level_h_fruit_room
    beq reset_sound_priorities
    lda fruit_timer
    bmi return3_local
    inc fruit_timer
.return3_local
    jmp return3

.reset_sound_priorities
    lda sound_priority_per_channel_table
    cmp #&41 ; 'A'
    bcs continue_updating_fruit
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
.continue_updating_fruit
    jsr update_fruit_animation
    lda desired_room_index
    cmp save_game_level_h_fruit_room
    beq in_fruit_room
    lda #0
    sta fruit_timer
    jmp return3

.in_fruit_room
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_fall_sideways_animation2 - fruit_animation_base
    bne check_for_fruit_falling_sideways1
    lda save_game_level_h_current_fruit_direction
    bpl fruit_falling_right
    dec temp_left_offset
    jmp fruit_falling_left

.fruit_falling_right
    inc temp_right_offset
.fruit_falling_left
    lda #1
    sta temp_bottom_offset
    lda #objectid_fruit
    jsr get_solid_rock_collision_for_object_a
    bne play_landing_sound_local
    jmp return3

.check_for_fruit_falling_sideways1
    lda save_game_level_h_fruit_animation_step
    cmp #fruit_fall_sideways_animation1 - fruit_animation_base
    beq end_of_fall_sound
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_sideways_animation - fruit_animation_base
    bne check_for_fruit_falling_straight_down
; check for left or right fruit-wall collision
    dec temp_left_offset
    inc temp_right_offset
    lda #objectid_fruit
    jsr get_solid_rock_collision_for_object_a
    bne play_landing_sound_local
.end_of_fall_sound
    lda #&40 ; '@'
    ldx #<sound1
    ldy #>sound1
    jsr play_sound_yx
    jmp return3

.play_landing_sound_local
    jmp play_landing_sound

.check_for_fruit_falling_straight_down
    cmp #fruit_fall_straight_down_animation - fruit_animation_base
    bne write_solid_fruit_collision
    lda #2
    sta temp_bottom_offset
    lda #objectid_fruit
    jsr get_solid_rock_collision_for_object_a
    beq return3
; fruit collision sound
    lda #0
    ldx #<sound5
    ldy #>sound5
    jsr play_sound_yx
    ldx #<sound6
    ldy #>sound6
    jmp play_sound_yx

.write_solid_fruit_collision
    lda #collision_map_solid_rock
    jsr write_fruit_collision_map
.return3
    rts

.update_fruit_animation
    lda save_game_level_h_fruit_animation_step
    clc
    adc #2
    tay
    lda fruit_animation_base,y
    cmp #&80
    bne got_fruit_animation_step_y
    ldy save_game_level_h_current_fruit_animation
.got_fruit_animation_step_y
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_initial_idle_animation - fruit_animation_base
    bne check_for_fruit_stopped
    ldx #objectid_player
    sty remember_y2
    ldy #objectid_fruit
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y2
; branch if player and fruit didn't collide
    ora #0
    beq no_player_fruit_collision
    lda #&80
    sta player_wall_collision_reaction_speed
    lda object_direction
    sta save_game_level_h_current_fruit_direction
    ldy #4
    lda #&1a
    sta save_game_level_h_current_fruit_animation
.no_player_fruit_collision
    jmp update_fruit_position

.check_for_fruit_stopped
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_stopped_animation - fruit_animation_base
    bne check_for_fruit_going_sideways
; check for first update in room (branch if so)
    lda update_room_first_update_flag
    bne no_player_fruit_collision
    dec temp_left_offset
    inc temp_right_offset
    ldx #objectid_player
    sty remember_y2
    ldy #objectid_fruit
    jsr test_for_collision_between_objects_x_and_y
    ldy remember_y2
    ora #0
    beq no_player_fruit_collision
    lda object_y_low
    sec
    sbc save_game_level_h_fruit_y_low
    lda object_y_high
    sbc save_game_level_h_fruit_y_high
    bmi no_player_fruit_collision
    ldx #1
    lda object_room_collision_flags
    and #object_collided_right_wall
    bne found_fruit_wall_collision
    ldx #&ff
    lda object_room_collision_flags
    and #object_collided_left_wall
    beq no_player_fruit_collision
.found_fruit_wall_collision
    stx save_game_level_h_current_fruit_direction
    lda #collision_map_none
    jsr write_fruit_collision_map
    ldy #fruit_sideways_animation - fruit_animation_base
    sty save_game_level_h_current_fruit_animation
.check_for_fruit_going_sideways
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_sideways_animation - fruit_animation_base
    bne check_for_fruit_fall_sideways2
    lda save_game_level_h_current_fruit_direction
    bmi fruit_moving_left
    inc temp_right_offset
    jmp check_fruit_rock_collision

.fruit_moving_left
    dec temp_left_offset
.check_fruit_rock_collision
    lda #objectid_fruit
    jsr get_solid_rock_collision_for_object_a
    bne stop_the_fruit
    lda #8
    sta temp_left_offset
    lda #&f8
    sta temp_right_offset
    lda #3
    sta temp_default_collision_map_option
    lda #2
    sta temp_bottom_offset
    lda #2
    jsr get_solid_rock_collision_for_object_a
    bne update_fruit_position
    ldy #fruit_fall_sideways_animation2 - fruit_animation_base
    sty save_game_level_h_current_fruit_animation
    jmp update_fruit_position

.check_for_fruit_fall_sideways2
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_fall_sideways_animation2 - fruit_animation_base
    bne check_for_fruit_falling_straight_down1
    cpy save_game_level_h_current_fruit_animation
    bne update_fruit_position
    ldy #fruit_fall_straight_down_animation - fruit_animation_base
    sty save_game_level_h_current_fruit_animation
.check_for_fruit_falling_straight_down1
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_fall_straight_down_animation - fruit_animation_base
    bne update_fruit_position
    lda #8
    sta temp_left_offset
    lda #&f8
    sta temp_right_offset
    lda #2
    sta temp_bottom_offset
    lda #objectid_fruit
    jsr get_solid_rock_collision_for_object_a
    beq update_fruit_position
.stop_the_fruit
    lda #0
    sta fruit_timer
    ldy #fruit_stopped_animation - fruit_animation_base
    sty save_game_level_h_current_fruit_animation
.update_fruit_position
    sty save_game_level_h_fruit_animation_step
    lda fruit_animation_base,y
    ldx save_game_level_h_current_fruit_direction
    bpl fruit_moving_right
    eor #&ff
    clc
    adc #1
.fruit_moving_right
    ldx #0
    ora #0
    bpl add_to_fruit_x_position
    dex
.add_to_fruit_x_position
    clc
    adc save_game_level_h_fruit_x_low
    sta save_game_level_h_fruit_x_low
    txa
    adc save_game_level_h_fruit_x_high
    sta save_game_level_h_fruit_x_high
    iny
; add offset to fruit y position
    lda fruit_animation_base,y
    clc
    adc save_game_level_h_fruit_y_low
    sta save_game_level_h_fruit_y_low
    lda #0
    adc save_game_level_h_fruit_y_high
    sta save_game_level_h_fruit_y_high
    jsr set_fruit_object_position
    ldx #objectid_fruit
    jsr find_left_and_right_of_object
    jsr find_top_and_bottom_of_object
; move fruit to next room
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_fall_straight_down_animation - fruit_animation_base
    beq check_for_moving_fruit_off_bottom_of_screen
    cmp #fruit_sideways_animation - fruit_animation_base
    bne return4
    lda save_game_level_h_current_fruit_direction
    bmi move_fruit_left_one_room
    lda object_left_cell_x
    cmp #game_area_width_cells
    bcc return4
; subtract 320 pixels from x position
    lda save_game_level_h_fruit_x_low
    sec
    sbc #&40 ; '@'
    sta save_game_level_h_fruit_x_low
    lda #0
    sbc #0
    sta save_game_level_h_fruit_x_high
    inc save_game_level_h_fruit_room
    jmp hide_fruit

.move_fruit_left_one_room
    lda object_right_cell_x
    bpl return4
; add 320 pixels to x position
    lda save_game_level_h_fruit_x_low
    clc
    adc #&40 ; '@'
    sta save_game_level_h_fruit_x_low
    lda #1
    sta save_game_level_h_fruit_x_high
    dec save_game_level_h_fruit_room
    jmp hide_fruit

.check_for_moving_fruit_off_bottom_of_screen
    lda object_top_cell_y
    cmp #game_area_height_cells
    bcc return4
; move fruit up 192 pixels
    lda save_game_level_h_fruit_y_low
    sec
    sbc #&c0
    sta save_game_level_h_fruit_y_low
; set fruit to room 1 as this is the only possible destination room
    lda #1
    sta save_game_level_h_fruit_room
.hide_fruit
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid + objectid_fruit
.return4
    rts

.remember_y2
    equb 0

.set_fruit_object_position
    lda save_game_level_h_fruit_x_low
    sta object_x_low + objectid_fruit
    lda save_game_level_h_fruit_x_high
    sta object_x_high + objectid_fruit
    lda save_game_level_h_fruit_y_low
    sta object_y_low + objectid_fruit
    lda save_game_level_h_fruit_y_high
    sta object_y_high + objectid_fruit
    lda #spriteid_fruit
    sta object_spriteid + objectid_fruit
    rts

.write_fruit_collision_map
    sta value_to_write_to_collision_map
    ora #0
    beq valid_write
; we want to write a non-zero value to the collision map. check the fruit is stopped
; before doing so
    lda save_game_level_h_current_fruit_animation
    cmp #fruit_stopped_animation - fruit_animation_base
    bne return5
; check we are in the same room as the fruit (return if not)
.valid_write
    lda desired_room_index
    cmp save_game_level_h_fruit_room
    bne return5
; calculate the x cell coordinate to write to
    lda save_game_level_h_fruit_x_high
    lsr a
    sta movement_low
    lda save_game_level_h_fruit_x_low
    ror a
    lsr movement_low
    ror a
    lsr movement_low
    ror a
    tax
; calculate the y cell coordinate to write to
    lda save_game_level_h_fruit_y_high
    lsr a
    sta movement_low
    lda save_game_level_h_fruit_y_low
    ror a
    lsr movement_low
    ror a
    lsr movement_low
    ror a
    tay
; fruit is 3x2 cells
    lda #3
    sta width_in_cells
    lda #2
    sta height_in_cells
    jsr read_collision_map_value_for_xy
    cmp value_to_write_to_collision_map
    beq return5
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.return5
    rts

.draw_plant_a_at_cell_xy_and_add_to_collision_map
    sec
    sbc #2
    sta plant_height_loop_counter
    dey
    lda #spriteid_stalk_bottom
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
.draw_plant_loop
    dey
    lda #spriteid_stalk_middle
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dec plant_height_loop_counter
    bne draw_plant_loop
    dey
    lda #spriteid_stalk_top
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
    dey
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    iny
    iny
    lda #spriteid_leaf
    jsr draw_sprite_a_at_cell_xy
    inx
    lda #&ff
    sta temp_sprite_x_offset
    dey
    sta sprite_reflect_flag
    lda #spriteid_leaf
    jmp draw_sprite_a_at_cell_xy

.plant_height_loop_counter
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
.envelope3
    equb 6                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 110                                                          ; change of amplitude per step during attack phase
    equb 255                                                          ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 248                                                          ; change of amplitude per step during release phase
    equb 110                                                          ; target of level at end of attack phase
    equb 55                                                           ; target of level at end of decay phase
.sound6
    equw &0010                                                        ; channel
    equw 6                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound5
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
    equb 40                                                           ; change of amplitude per step during attack phase
    equb 216                                                          ; change of amplitude per step during decay phase
    equb 216                                                          ; change of amplitude per step during sustain phase
    equb 176                                                          ; change of amplitude per step during release phase
    equb 80                                                           ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound4
    equw &0010                                                        ; channel
    equw 7                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 1                                                            ; duration
.sound3
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 190                                                          ; pitch
    equw 1                                                            ; duration
.sound2
    equw &0010                                                        ; channel
    equw 0                                                            ; amplitude
    equw 0                                                            ; pitch
    equw 0                                                            ; duration
.ground_fill_2x2_top_left
    equb %00001000
    equb %00001000
    equb %00010000
    equb %00100011
    equb %11000100
    equb %00001000
    equb %00010000
    equb %00010000
.ground_fill_2x2_top_right
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11000000
    equb %00000011
    equb %00000100
    equb %00001000
    equb %00001000
.ground_fill_2x2_bottom_left
    equb %00010000
    equb %00010000
    equb %00100000
    equb %11000000
    equb %00000011
    equb %00000100
    equb %00001000
    equb %00001000
.ground_fill_2x2_bottom_right
    equb %00001000
    equb %00001000
    equb %00010000
    equb %00100011
    equb %11000100
    equb %00001000
    equb %00010000
    equb %00010000
IF swr_renderer_enabled
INCLUDE "build/runtime/levelH_runtime.asm"
ENDIF
.sprite_data
IF swr_renderer_enabled
INCLUDE "build/swr_assets/includes/levelH.asm"
ELSE
IF swr_measurement = 0
    INCBIN "build/levelH"
ENDIF
ENDIF
.pydis_end

save "build/dataH", pydis_start, pydis_end
