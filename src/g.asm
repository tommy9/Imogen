INCLUDE "build/swr_boot_config.asm"
swr_runtime_live = swr_renderer_enabled
IF swr_renderer_enabled
INCLUDE "build/swr_assets/bank_exports.asm"
ENDIF
; *************************************************************************************
;
; Imogen disassembly
; by SteveF and TobyLobster, 2023
;
; *************************************************************************************

; *************************************************************************************
;
; Notes:
; ------
; The game has a core engine (file 'g') that deals with drawing sprites, running the toolbar,
; updating objects (including the player animations/state), object collision, loading levels,
; moving between rooms, the collision map, etc.
;
; Each level is loaded as a separate file from disk (or cassette) as needed, and unusually is mostly
; code with some sprite data tacked on the end. The level code takes over control from the engine
; while it is running. (See 'initialise_level_and_room' for the flow control details).
;
; Because there are 16 levels, each with about 4K of code plus data, Imogen is a big game with a
; total of around 58K of code plus 26K of compressed sprites.
;
; The levels are stored in files dataA to dataP, and an epilogue (dataQ) played when the game is
; completed. Each level holds 4 rooms, although this is not a restriction imposed by the engine.
; More or fewer rooms would equally be possible so long as they fit in memory.
;
; Sprite drawing:
;
; The sprite drawing is particularly feature rich and therefore complex. It can draw sprites with
; any pixel width and any height (1-255 pixels) at any pixel position on screen, which is clipped
; properly to the edges of the screen. It draws optionally with a mask. Sprites can also be
; drawn left-right reflected. They can have an offset whenever drawn, to aid with animations.
;
; Sprite data is stored in a compressed format, and drawn directly from the compressed data (not
; decompressed). See 'sprite_op' for details of the compression etc.
;
; While plotting the sprite, the code can also optionally remember the previous contents of the
; screen behind the masked sprite that's being drawn, into a masked compressed sprite area in
; memory. This is so the screen background can be restored later by drawing that sprite.
;
; Objects:
;
; There is support in the core game code for objects. Objects have a current sprite, a position,
; optionally a sprite area for erasing itself, a left-right direction, and a z-order. The game code
; can deal with redrawing multiple overlapping sprites by erasing the sprites on top of a moving
; sprite and redrawing just the sprites that need to be redrawn.
;
; Objects do not store animation data, nor have any physics associated. The individual levels are
; responsible for any animations required. The state machine for an object is usually based around
; the animations the object requires. There is no physics in the game. Gravity for example is
; simulated via animations.
;
; Cheat codes
; -----------
; As well as entering level passwords, there are other codes available:
;
; 'REVIEW-MODE':
;       Enables two more cheat codes:
;           'DUMP' to screen dump to an EPSON printer
;           'EPILOGUE' to show the game's ending
;
; 'TEST-MODE':
;       As above, but also enables:
;           * 'GIMME' to set all levels complete and adds the completion spell to the toolbar
;                     ready to complete the game.
;           * If the menu pointer is on one of the first four items, then SHIFT advances the
;             game one tick (for debugging animations?)
;           * ESCAPE returns to BASIC, but this only works if the appropriate bit is set in ICODATA
;             at startup and bank 12 has sideways RAM active and banked in at startup.
;           * Can enter one letter to skip to that level
;           * Can enter zero characters to restart the game
;           * On the EPILOGUE, holding the up arrow speeds up the scrolling of the text.
;             (noticeable when not much text is on-screen)
;
; 'DEBUG-MODE':
;        As all of the above, but also enables:
;           * The toolbar changes to a magenta background
;           * Entering each level automatically collects the objects required to complete the level
;           * In dataN ('PAVLOV-WAS-HERE'), pressing 'O' starts the dog salivating
;           * In dataK ('DRIPPING-STUFF'), pressing 'G' grows the plant and 'P' poisons it once grown
;
; 'MONO':
;           * Selects a colour scheme suitable for monochrome monitors
;
; 'COLOUR':
;           * Selects a colour scheme suitable for colour monitors (the default)
;
; 'QUIT':
;           * Restarts the game
;
; Memory Map (after the memory gets relocated at initialisation):
; ---------------------------------------------------------------
;
;   0100-012e: object data (object extents etc)
;   0131-0160: code to print transformations left
;   0400-0527: dialog box code
;   0530-07ff: cache of screen memory under the dialog box
;   0950-0ab5: data
;   0ab7-0aff: level utils code
;   0b11-0bec: special 'erase' sprite data (sprites 197, 198, 199: the contents of screen behind sprites)
;   0c00-0c60: collision map
;   1103-3ad4: main code
;   3ad5-4ad3: 'data*' file (level code/data) (it starts as initialisation code before being overwritten by a level)
;   4ad8-5bbf: SPRDATA file (main sprites) OR
;   53c0-578a: AUXCODE file (for password / cheat codes support)
;   5bc0-61ff: screen memory: toolbar
;   6200-7fff: screen memory: main game area
;
; Only during initialisation:
;
;   3c06-4225: initialisation code (which will get overwritten after initialisation by level data)
;   40ff-4318: ICODATA file (contains toolbar sprites only used once to render the toolbar)
;
; The AUXCODE Overlay
; -------------------
; When the user submits a password, the sprite memory is temporarily overwritten by the AUXCODE
; file which contains code to handle password and cheat code recognition (including a screendump
; facility for Epsom printers). Once finished, the SPRDATA is reloaded back into memory so the
; game can continue. Both sets of code/data don't need to reside in memory at the same time,
; so this is a memory saving system known as an overlay.
;
; *************************************************************************************

; Constants
is_level = FALSE
INCLUDE "src/globals.asm"
buffer_sound_channel_0                          = 4
bytes_per_cell                                  = 8
bytes_per_character_row                         = 320
caps_mask                                       = 223
cells_per_character_row                         = 40
collision_map_length                            = 240
colour_black                                    = 0
colour_blue                                     = 4
colour_cyan                                     = 6
colour_green                                    = 2
colour_magenta                                  = 5
colour_red                                      = 1
colour_white                                    = 7
colour_yellow                                   = 3
crtc_cursor_start                               = 10
crtc_interlace_delay                            = 8
crtc_screen_start_high                          = 12
crtc_screen_start_low                           = 13
crtc_vert_displayed                             = 6
crtc_vert_sync_pos                              = 7
inkey_key_escape                                = 143
inkey_key_left                                  = 230
inkey_key_return                                = 182
inkey_key_right                                 = 134
inkey_key_shift                                 = 255
inkey_key_space                                 = 157
inkey_key_x                                     = 189
inkey_key_z                                     = 158
max_filename_len                                = 7
max_objects                                     = 11
menu_slot_count                                 = 17
num_levels                                      = 16
opcode_clc                                      = 24
opcode_lda_imm                                  = 169
opcode_sec                                      = 56
osbyte_close_spool_exec                         = 119
osbyte_flush_buffer                             = 21
osbyte_flush_buffer_class                       = 15
osbyte_inkey                                    = 129
osbyte_opt                                      = 139
osbyte_read_vdu_status                          = 117
osbyte_read_write_escape_break_effect           = 200
osbyte_read_write_first_byte_break_intercept    = 247
osbyte_read_write_second_byte_break_intercept   = 248
osbyte_read_write_third_byte_break_intercept    = 249
osbyte_reset_soft_keys                          = 18
osbyte_select_adc_channels                      = 16
osbyte_set_cursor_editing                       = 4
osbyte_set_printer_ignore                       = 6
osbyte_tv                                       = 144
osbyte_vsync                                    = 19
osfile_load                                     = 255
osfile_read_catalogue_info                      = 5
osfile_save                                     = 0
osword_envelope                                 = 8
osword_read_char                                = 10
osword_sound                                    = 7
rows_per_cell                                   = 8
screen_width_in_pixels                          = 320
screen_width_minus_one                          = 39
vdu_bell                                        = 7
vdu_cr                                          = 13
vdu_define_character                            = 23
vdu_define_text_window                          = 28
vdu_delete                                      = 127
vdu_enable                                      = 6
vdu_goto_xy                                     = 31
vdu_left                                        = 8
vdu_lf                                          = 10
vdu_printer_off                                 = 3
vdu_set_graphics_colour                         = 18
vdu_set_mode                                    = 22
vdu_set_text_colour                             = 17

; Memory locations
error_code_on_brk                                   = &0002
remember_stack_pointer                              = &0003
which_dialog_is_active                              = &0004
characters_entered                                  = &0005
rnd0                                                = &0006
rnd1                                                = &0007
rnd2                                                = &0008
rnd3                                                = &0009
rnd4                                                = &000a
dest_sprite_id                                      = &0014
sprite_op_flags                                     = &0015
sprite_id                                           = &0016
sprite_x_base_low                                   = &0018
sprite_x_base_high                                  = &0019
sprite_y_base_low                                   = &001a
sprite_y_base_high                                  = &001b
sprite_reflect_flag                                 = &001d
valid_direction_pending                             = &0020
old_menu_index                                      = &0025
auto_repeat_counter                                 = &0026
left_right_repeat_direction                         = &0027
left_right_direction                                = &0028
new_menu_index                                      = &0029
space_bar_press_pending                             = &002a
space_bar_pressed                                   = &002b
z_key_pressed_pending                               = &002c
x_key_pressed_pending                               = &002d
current_menu_index                                  = &002e
desired_room_index                                  = &0030
current_level                                       = &0031
currently_loaded_level                              = &0037
bit_mask_for_random_number_limit                    = &0039
temp_sprite_x_offset                                = &003a
temp_sprite_y_offset                                = &003b
width_in_cells                                      = &003c
height_in_cells                                     = &003d
value_to_write_to_collision_map                     = &003e
only_ever_written_to_with_zero                      = &003f
source_sprite_memory_low                            = &0040
source_sprite_memory_high                           = &0041
copy_mode                                           = &0042
print_in_italics_flag                               = &0043
default_collision_map_option                        = &0044
eor_key                                             = &0045
return_key_pressed_pending                          = &0046
current_player_character                            = &0048
temp_value                                          = &0049
saved_x                                             = &004a
temp_coordinate                                     = &004a
height_counter                                      = &004b
l004b                                               = &004b
saved_y                                             = &004b
screen_base_address_high                            = &004c
new_player_character                                = &004d
previous_room_index                                 = &0050
level_before_latest_level_and_room_initialisation   = &0051
player_held_object_spriteid                         = &0052
objectid_to_test                                    = &0053
sprdata_ptr                                         = &0054
temp_rope_length                                    = &0056
temp_sprite_address_low                             = &0058
temp_sprite_address_high                            = &0059
temp_sprite_offset                                  = &005a
developer_mode_sideways_ram_is_set_up_flag          = &005b
displayed_transformations_remaining                 = &005c
initial_level_number_div4                           = &005f
backmost_object_index                               = &0060
osword_read_character_block                         = &0060
backmost_object_z_order                             = &0061
num_active_objects                                  = &0062
temp_active_object_index                            = &0063
temp_object_index                                   = &0064
remember_player_accessory_object_index              = &0065
wall_mask                                           = &0066
l0066                                               = &0066
l0067                                               = &0067
l0068                                               = &0068
address1_low                                        = &0070
animation_address_low                               = &0070
cell_x                                              = &0070
level_data_ptr_low                                  = &0070
menu_item_to_use                                    = &0070
object_left_low                                     = &0070
object_y_delta                                      = &0070
osfile_block_filename_low                           = &0070
screen_address_low                                  = &0070
src_sprite_address_low                              = &0070
address1_high                                       = &0071
animation_address_high                              = &0071
cell_y                                              = &0071
level_data_ptr_high                                 = &0071
menu_has_changed_flag                               = &0071
object_left_high                                    = &0071
osfile_block_filename_high                          = &0071
screen_address_high                                 = &0071
src_sprite_address_high                             = &0071
destination_address_low                             = &0072
l0072                                               = &0072
object_right_low                                    = &0072
object_rope_low                                     = &0072
osfile_block_load_address_low                       = &0072
sprite_screen_address_low                           = &0072
temp_sprite_list_low                                = &0072
width_in_cells_to_write                             = &0072
destination_address_high                            = &0073
height_in_cells_to_write                            = &0073
l0073                                               = &0073
object_right_high                                   = &0073
object_rope_high                                    = &0073
osfile_block_load_address_mid1                      = &0073
sprite_screen_address_high                          = &0073
temp_sprite_list_high                               = &0073
first_cell_in_row_screen_address_low                = &0074
l0074                                               = &0074
object_top_low                                      = &0074
offset_within_byte                                  = &0074
osfile_block_load_address_mid2                      = &0074
sprite_x_pos_low                                    = &0074
temp_spriteid                                       = &0074
first_cell_in_row_screen_address_high               = &0075
l0075                                               = &0075
object_top_high                                     = &0075
offset_within_collision_map                         = &0075
osfile_block_load_address_high                      = &0075
sprite_x_pos_high                                   = &0075
cell_screen_address_low                             = &0076
l0076                                               = &0076
object_bottom_low                                   = &0076
osfile_block_exec_address_low                       = &0076
sprite_y_pos_low                                    = &0076
cell_screen_address_high                            = &0077
l0077                                               = &0077
object_bottom_high                                  = &0077
osfile_block_exec_address_mid1                      = &0077
sprite_y_pos_high                                   = &0077
l0078                                               = &0078
object_left_cell_x                                  = &0078
original_off_screen_address_low                     = &0078
osfile_block_exec_address_mid2                      = &0078
sprite_x_offset_within_byte                         = &0078
byte_offset_within_sprite                           = &0079
l0079                                               = &0079
object_right_cell_x                                 = &0079
original_off_screen_address_high                    = &0079
osfile_block_exec_address_high                      = &0079
l007a                                               = &007a
object_top_cell_y                                   = &007a
off_screen_address_low                              = &007a
osfile_block_start_address_low                      = &007a
temp_y                                              = &007a
l007b                                               = &007b
object_bottom_cell_y                                = &007b
off_screen_address_high                             = &007b
osfile_block_start_address_mid1                     = &007b
sprite_screen_address_for_column_low                = &007b
cell_x_plus_current_cell_within_row                 = &007c
l007c                                               = &007c
object_hit_wall_on_left_result_flag                 = &007c
osfile_block_start_address_mid2                     = &007c
sprite_screen_address_for_column_high               = &007c
current_row                                         = &007d
l007d                                               = &007d
object_hit_wall_on_right_result_flag                = &007d
osfile_block_start_address_high                     = &007d
sprite_data_byte                                    = &007d
dest_sprite_address_low                             = &007e
l007e                                               = &007e
object_hit_ceiling_result_flag                      = &007e
osfile_block_end_address_low                        = &007e
pattern_length_cycle_counter                        = &007e
dest_sprite_address_high                            = &007f
l007f                                               = &007f
object_hit_floor_result_flag                        = &007f
osfile_block_end_address_mid1                       = &007f
adjustment                                          = &0080
cell_based_loop_counter                             = &0080
erase_sprite_byte                                   = &0080
l0080                                               = &0080
object_height_in_cells                              = &0080
object_width_in_cells                               = &0080
osfile_block_end_address_mid2                       = &0080
sprite_addr_low                                     = &0080
l0081                                               = &0081
osfile_block_end_address_high                       = &0081
sprite_addr_high                                    = &0081
sprite_width                                        = &0081
sprite_bit                                          = &0082
sprite_bit_mask                                     = &0083
sprite_y_offset_within_character_row                = &0084
sprite_cell_x_pos                                   = &0085
amount_sprite_is_offscreen_x                        = &0086
num_two_bit_offsets_within_byte                     = &0087
vertical_sprite_position_is_valid_flag              = &0088
romsel_copy                                         = &00f4
interrupt_accumulator                               = &00fc
brk_address_low                                     = &00fd
active_objects_table                                = &0100
frontmost_objects_table                             = &010b
object_dealt_with_flag                              = &0116
l0121                                               = &0121
temp_object_left_cell                               = &0121
x_object_left_low                                   = &0121
l0122                                               = &0122
temp_object_right_cell                              = &0122
x_object_left_high                                  = &0122
x_object_right_low                                  = &0123
x_object_right_high                                 = &0124
x_object_top_low                                    = &0125
x_object_top_high                                   = &0126
x_object_bottom_low                                 = &0127
x_object_bottom_high                                = &0128
old_object_left_low                                 = &0129
old_object_left_high                                = &012a
old_object_right_low                                = &012b
old_object_right_high                               = &012c
old_object_left_cell                                = &012d
old_object_right_cell                               = &012e
l0160                                               = &0160
brkv                                                = &0202
irq1v                                               = &0204
first_byte_break_intercept                          = &0287
l0527                                               = &0527
cache_of_screen_memory_under_dialog                 = &0530
object_x_low                                        = &0950
object_x_low_old                                    = &095b
object_x_high                                       = &0966
object_x_high_old                                   = &0971
object_y_low                                        = &097c
object_y_low_old                                    = &0987
object_y_high                                       = &0992
object_y_high_old                                   = &099d
object_spriteid                                     = &09a8
object_spriteid_old                                 = &09b3
object_direction                                    = &09be
object_direction_old                                = &09c9
object_current_index_in_animation                   = &09d4
current_player_animation                            = &09df
save_game                                           = &09ea
save_game_checksum                                  = &09eb
current_transformations_remaining                   = &09ec
level_progress_table                                = &09ef
level_workspace                                     = &0a6f
level_ordering_table                                = &0a7f
string_input_buffer                                 = &0a90
tile_all_clear_pixels                               = &0aa1
tile_all_set_pixels                                 = &0aa9
old_brkv1                                           = &0ab1
old_brkv2                                           = &0ab3
old_irq1v                                           = &0ab5
l0aff                                               = &0aff
area_to_copy_to_or_from_sideways_ram                = &0b00
sprite_erase_player                                 = &0b11
sprite_erase_player_accessory                       = &0b93
sprite_197                                          = &0bc5
l0c61                                               = &0c61
auxcode                                             = &53c0
check_password                                      = &53c0
toolbar_screen_address                              = &58c0
start_of_screen_memory                              = &5bc0
game_area_screen_address                            = &6200
l8010                                               = &8010
sideways_ram_be00                                   = &be00
sideways_ram_bf00                                   = &bf00
crtc_address_register                               = &fe00
crtc_address_write                                  = &fe01
video_ula_palette                                   = &fe21
romsel                                              = &fe30
system_via_t1c_l                                    = &fe44
system_via_t1c_h                                    = &fe45
system_via_t1l_l                                    = &fe46
system_via_t1l_h                                    = &fe47
system_via_t2c_l                                    = &fe48
system_via_t2c_h                                    = &fe49
system_via_acr                                      = &fe4b
system_via_ifr                                      = &fe4d
system_via_ier                                      = &fe4e
user_via_t1c_l                                      = &fe64
user_via_t1c_h                                      = &fe65
user_via_t2c_l                                      = &fe68
user_via_t2c_h                                      = &fe69
user_via_ier                                        = &fe6e
osfile                                              = &ffdd
oswrch                                              = &ffee
osword                                              = &fff1
osbyte                                              = &fff4
oscli                                               = &fff7

    ; org &1234

    org &1103
.pydis_start

; developer_flags
; 
; The 'developer flags byte' lives in the ICODATA file. When loaded, if bit 6 is set
; then the variable 'developer_flags' is set to this value (after clearing bit 6).
; 
; bit 0: (set in 'TEST-MODE' and 'DEBUG-MODE')
;   Enables:
;   * 'GIMME' to set all levels complete and adds the completion spell to the toolbar
;     ready to complete the game.
;   * If the menu pointer is on one of the first four items, then SHIFT advances the
;     game one tick (for debugging animations?)
;   * ESCAPE returns to BASIC, but this only works if the appropriate bit is set in
;     ICODATA at startup and bank 12 has sideways RAM active and banked in at startup.
;   * Can enter one letter to skip to that level
;   * Can enter zero characters to restart the game
;   * On the EPILOGUE, holding the up arrow speeds up the scrolling of the text.
;     (noticeable when not much text is on-screen)
; 
; bit 1: (set in 'REVIEW-MODE' and 'TEST-MODE' and 'DEBUG-MODE')
;   Enables two more cheat codes:
;   * 'DUMP' to screen dump to an EPSON printer
;   * 'EPILOGUE' to show the game's ending
; 
; bit 2: load ICODATA directly from track 39 on the disc, rather than a regular file.
;   (An option for copy protection presumably)
; bit 3: load game data from drive 2, not drive 0
; bit 4: unused
; bit 5: unused
; bit 6: load value from in ICODATA into developer_flags variable
; bit 7: (set in 'DEBUG-MODE')
;   Enables:
;   * The toolbar changes to a magenta background
;   * Entering a level automatically collects all objects needed to complete it
;   * In dataN ('PAVLOV-WAS-HERE'), pressing 'O' starts the dog salivating
;   * In dataK ('DRIPPING-STUFF'), pressing 'G' grows the plant, 'P' poisons once grown
.developer_flags
    equb 0
.timingA_counter_low
    equb &47
.timingA_counter_high
    equb &11
.timingB_counter_low
    equb &0b
.timingB_counter_high
    equb &1d
.timing_latch_low
    equb &10
.timing_latch_high
    equb &27
.display_initialised_flag
    equb 0
.vertical_sync_amount_for_crtc_register
    equb 0

.start_game
    jsr clear_most_of_save_game
    lda #&ff
    sta current_level
    lda #osbyte_flush_buffer_class
    ldx #0
    jsr osbyte                                                        ; Flush all buffers (X=0)
; Initialise the number of remaining transformations to 150.
    lda #'0'
    sta current_transformations_remaining
    lda #'5'
    sta current_transformations_remaining+1
    lda #'1'
    sta current_transformations_remaining+2
    ldx #0
    ldy level_ordering_table
    cpy #'R'
    bne initialise_level_and_room
; choose a new starting level
    inc initial_level_number_div4
    lda initial_level_number_div4
    and #3
    asl a
    asl a
    adc #first_level_letter
    tay
    jsr convert_section_letter_to_level_filename_letter
; TODO: this is used by e.g. dataA
; *************************************************************************************
; 
; Initialise level and room
; 
; Loads the new level if needed, resets objects and other related variables, and jumps
; to level specific code to execute the room.
; 
; On Entry:
;     X is the room index
;     Y is the level number
; 
; The control flow during gameplay is as follows:
; 
; - 'initialise_level_and_room' performs common setup tasks, including:
;     - loading the level if needed
;     - calling level specific initialisation code ('level_specific_initialisation', as
;       found in the level header) - which is called on every room change.
;     - It finally transfers control to a room-specific subroutine within the
;       loaded level (at address 'level_room_data_table[room]+2' as found in the level
;       header). Let's call this the level room handler.
; 
; - The level room handler does the following:
;     - Room specific initialisation (including drawing the room).
;     - Calls the common 'start_room' routine. 'start_room' calls the
;       'level_specific_update' handler once. This update handler will be called
;       every game tick while in the level. On this specific call, a flag is set to
;       indicate it's being called for the first time in this room
;       ('update_room_first_update_flag').
;       Note the update handler is not room specific.
;     - Runs a game loop until the player leaves the current room. The game loop calls
;       the common 'game_update' routine to keep the game ticking. 'game_update'
;       (among other things) calls the 'level_specific_update' handler, allowing the
;       level to perform custom actions each tick.
;     - When the player leaves the current room, 'initialise_level_and_room' is called
;       to select the new room.
; 
; *************************************************************************************
.initialise_level_and_room
IF swr_renderer_enabled
    JSR swr_invalidate_caches
ENDIF
    lda desired_room_index
    sta previous_room_index
    lda current_level
    sta level_before_latest_level_and_room_initialisation
    stx desired_room_index
    sty current_level
    sty save_game
.level_load_loop
    lda current_level
    cmp currently_loaded_level
    beq level_already_loaded                                          ; if desired level is already loaded, skip forward
; load level in A
    sta data_filename_variable_letter
    lda #<data_filename
    sta osfile_block_filename_low
    lda #>data_filename
    sta osfile_block_filename_high
    ldx #<level_data
    ldy #>level_data
    lda #osfile_load
    jsr osfile_wrapper
    beq level_load_successful                                         ; if load successful, then skip forward
    jsr prompt_user_to_insert_correct_disc
    jmp level_load_loop

.level_load_successful
    lda current_level
    sta currently_loaded_level
.level_already_loaded
    lda #osbyte_flush_buffer_class
    ldx #0
    jsr osbyte                                                        ; Flush all buffers (X=0)
    lda #0
    sta object_spriteid_old
    sta object_spriteid_old + objectid_player_accessory
    ldy #2
.object_reset_loop
    lda #0
    sta object_spriteid,y
    sta object_spriteid_old,y
    sta object_x_low,y
    sta object_x_high,y
    sta object_y_low,y
    sta object_y_high,y
    lda #1
    sta object_direction,y
    lda #&ff
    sta object_erase_type,y
    sta object_z_order,y
    iny
    cpy #max_objects
    bcc object_reset_loop
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq same_level
    lda #0
    sta player_wall_collision_reaction_speed
    sta current_player_character
    sta new_player_character
    sta object_spriteid
    sta player_held_object_spriteid
    sta player_using_object_spriteid
    sta previous_player_using_object_spriteid
    sta object_current_index_in_animation+1
    sta object_spriteid + objectid_player_accessory
    lda #4
    sta current_player_animation
    sta object_current_index_in_animation
    lda #1
    sta object_direction
    lda #0
    ldy #&0f
.clear_level_workspace_loop
    sta level_workspace,y
    dey
    bpl clear_level_workspace_loop
    jsr set_player_position_for_new_room
    lda #<brk_handler
    sta old_brkv2
    lda #>brk_handler
    sta old_brkv2+1
    lda display_initialised_flag
    bne display_initialised
    jsr initialise_display
; Blank the whole screen temporarily. The toolbar is blanked out here since we are
; moving to a different level (we need to redraw it to remove any level specific
; objects obtained). When moving between rooms on the same level the toolbar doesn't
; change, so remains visible.
.display_initialised
    lda #colour_black
    sta toolbar_colour
    sta gameplay_area_colour
    jsr reset_menu_items
    jsr draw_toolbar
    jsr update_displayed_transformations_remaining
.same_level
    jsr set_toolbar_and_gameplay_area_colours
    lda #0
    sta inhibit_monkey_climb_flag
    ldx #3
.clear_sound_priorities_loop1
    sta sound_priority_per_channel_table,x
    dex
    bpl clear_sound_priorities_loop1
    ldx level_specific_initialisation_ptr
    ldy level_specific_initialisation_ptr + 1
    jsr jmp_yx
    lda current_level
    sec
    sbc #first_level_letter
    tax
; level_progress_table has one entry per level:
; 
;     bits 0-2: current room number
;     bit 6: if clear then override regular room number with a cheat room number (there
; are two cheat room numbers!)
;     bit 7: set when the completion spell is obtained
; 
    lda level_progress_table,x
    and #&80
    beq skip_adding_completion_spell_to_toolbar
    lda #spriteid_menu_item_completion_spell
    jsr find_or_create_menu_slot_for_A
.skip_adding_completion_spell_to_toolbar
    lda #collision_map_solid_rock
    sta value_to_write_to_collision_map
    lda #colour_black
    sta copy_mode
    sta gameplay_area_colour
    jsr draw_toolbar
    jsr clear_game_area
; which_dialog_is_active is non-zero when a dialog is active:
; 
;     1: save or load dialog, or section information dialog
;     2: choose filename dialog, or level letters dialog
;     3: which drive dialog
;     4: insert save disk dialog
;   255: blank dialog shown (to be overwritten by one of the above)
; 
    lda #0
    sta which_dialog_is_active
    lda current_level
    sec
    sbc #first_level_letter
    tax
; set current room number in level progress table
    lda level_progress_table,x
    and #%11111000
    ora desired_room_index
    ora #%01000000
    sta level_progress_table,x
; set YX to the address of the room initialisation code, an address found in a table at
; start of the level data offset by twice the room number
    lda desired_room_index
    asl a
    tay
    ldx level_room_data_table,y
    lda level_room_data_table + 1,y
    tay
; add two to the address in YX, to get past the two initial player position bytes
    txa
    clc
    adc #2
    tax
    tya
    adc #0
    tay
; jump to the level specific room handler
    jmp jmp_yx

.data_filename
    equs "data"
.data_filename_variable_letter
    equs "A", &0d

.set_player_position_for_new_room
    lda current_level
    sec
    sbc #first_level_letter
    tax
    lda level_progress_table,x
    and #7
    sta desired_room_index
; the level_progress_table doesn't ever set bit 6, so in reality the following branch
; is never taken.
    lda level_progress_table,x
    and #&40 ; '@'
    bne skip_developer_mode_code1
; set initial room based on the value in the level header
    lda initial_room_index
    sta desired_room_index
    lda developer_flags
    bpl skip_developer_mode_code1
; this is a debugging aid, allowing the level header to temporarily set a different
; start room, as a particular room is being developed/debugged.
    lda initial_room_index_cheat
    sta desired_room_index
; get room data address
.skip_developer_mode_code1
    lda desired_room_index
    asl a
    tay
    lda level_room_data_table,y
    sta level_data_ptr_low
    lda level_room_data_table + 1,y
    sta level_data_ptr_high
; read first byte into X and the second byte into Y. This is the player start position
; in cells
    ldy #0
    lda (level_data_ptr_low),y
    tax
    iny
    lda (level_data_ptr_low),y
    tay
    lda #0
    sta temp_sprite_y_offset
; set player position
    lda #0
    jmp set_object_position_from_cell_xy

; *************************************************************************************
; 
; Start room
; 
; *************************************************************************************
; TODO: This is called from level-specific machine code, e.g. see dataA.asm
.start_room
    lda #&ff
    sta update_room_first_update_flag
; call room update for the first time
    ldx level_specific_update_ptr
    ldy level_specific_update_ptr + 1
    jsr jmp_yx
    lda #0
    sta update_room_first_update_flag
    lda current_level
    cmp level_before_latest_level_and_room_initialisation
    beq return1
; start transformation to the wizard if it's a new level
    lda #spriteid_icodata_wizard
    jsr transform
.return1
    rts

; TODO: This is called from level-specific machine code, e.g. see dataA.asm
; *************************************************************************************
; 
; Game Update
; 
; On Exit:
;     A: 0=player is still within game area
;        1=exit room left
;        2=exit room bottom
;        4=exit room right
;        8=exit room top
; 
; *************************************************************************************
.game_update
    jsr update_objects
; set screen colours (if not already set)
    lda gameplay_area_colour
    bne wait_for_vsync_if_we_have_time
    lda pending_toolbar_colour
    sta toolbar_colour
    lda pending_gameplay_area_colour
    sta gameplay_area_colour
; reset vsync counter
    jsr wait_for_vsync
    lda #0
    sta vsync_counter
    jsr check_menu_keys
    jsr read_player_movement_keys
; wait for vsync (if we can) before making any changes to the menu, to avoid flicker
.wait_for_vsync_if_we_have_time
    lda vsync_counter
    cmp #4
    bcs no_time_to_wait
    jsr wait_for_vsync
.no_time_to_wait
    jsr update_menus
    jsr regulate_time_loop
    jsr read_player_movement_keys
    jsr update_player
; update room
    ldx level_specific_update_ptr
    ldy level_specific_update_ptr + 1
    jsr jmp_yx
    jmp check_for_player_leaving_room

; wait until five vsyncs have elapsed before continuing
.regulate_time_loop
    lda vsync_counter
    cmp #5
    bcc regulate_time_loop
    lda #0
    sta vsync_counter
    rts

.update_room_first_update_flag
    equb 0

; *************************************************************************************
; 
; Get sprite address for sprite A
; 
;     Sprites 0-196: are stored in SPRDATA (or ICODATA if loaded (*))
;     Sprite 197: is stored at $0bc5
;     Sprite 198: is stored at $0b93
;     Sprite 199: is stored at $0b11
;     Sprites 200+: are stored in level data
; 
; (*) The first entry in the ICODATA file is actually not a sprite. It contains:
; 
;       1 byte: developer_flags
;       1 byte: 'R' indicating a random initial level
;     16 bytes: the order of level letters
; 
; See sprite_op for the format of sprites.
; 
; On Entry:
;     A: sprite id
; 
; On Exit:
;     YX: address of sprite
; 
; *************************************************************************************
IF swr_renderer_enabled
.get_address_of_sprite_a
    JMP swr_get_address_of_sprite_a
ELSE
.get_address_of_sprite_a
    ldx #<sprite_erase_player
    ldy #>sprite_erase_player
    cmp #spriteid_erase_player
    beq return2
    ldx #<sprite_erase_player_accessory
    ldy #>sprite_erase_player_accessory
    cmp #spriteid_erase_player_accessory
    beq return2
    ldx #<sprite_197
    ldy #>sprite_197
    cmp #spriteid_erase_sparkles
    beq return2
    ldx sprdata_ptr
    ldy sprdata_ptr + 1
    cmp #200
    bcc get_sprite_address_from_sprite_table
    sbc #200
; The first two bytes of the level data is the offset to the sprite table
    pha                                                               ; remember sprite number
    lda #<level_data
    clc
    adc level_data                                                    ; add offset to sprite table (low)
    tax
    lda #>level_data
    adc level_data + 1                                                ; add offset to sprite table (high)
    tay
    pla                                                               ; recall sprite number
; The sprite table starts with a table of 16 bit addresses, one for each sprite.
; Look up the address of the sprite by reading this table.
; Set YX to point to the base of the sprite.
.get_sprite_address_from_sprite_table
    stx temp_sprite_address_low
    sty temp_sprite_address_high
    asl a
    tay
    lda temp_sprite_address_high
    sta temp_sprite_offset
    adc #0
    sta temp_sprite_address_high
    lda (temp_sprite_address_low),y
    adc temp_sprite_address_low
    tax
    iny
    lda (temp_sprite_address_low),y
    adc temp_sprite_offset
    tay
.return2
    rts

ENDIF

IF swr_renderer_enabled = 0
.power_of_2_table
    equb &01, &02, &04, &08, &10, &20, &40, &80

ENDIF
IF swr_renderer_enabled
INCLUDE "src/swr_sprite_adapter.asm"
INCLUDE "src/swr_renderer_core.asm"
ELSE
swr_invalidate_caches = 0
swr_runtime_bank = 0
.reset_sprite_flags_and_exit
    lda #sprite_op_flags_normal
    sta sprite_op_flags
    lda #1
    sta sprite_reflect_flag
    pla                                                               ; recall A,X,Y
    tay
    pla
    tax
    pla
    rts

; *************************************************************************************
; 
; Sprite Plotting
; 
; Plots or erases a sprite, optionally with a mask, optionally reflected about a
; vertical axis. Sprites can be any pixel width and height, can be drawn at any pixel
; position (including partially offscreen), and have an offset in X and Y pixels
; whenever drawn, to help run animations.
; 
; Sprites are stored in a compressed format, as detailed below.
; 
; While plotting the sprite, the code can also optionally remember the previous
; contents of the screen behind the sprite that's being drawn into a compressed sprite
; area in memory (the 'destination sprite'). This is so the screen background can be
; restored later by drawing the destination sprite.
; 
; Conventionally, sprite characters are authored looking to the right.
; 
; On Entry:
;                  sprite_id: id of the sprite to plot
;     sprite_x_base_low/high: X coordinate of sprite to plot (pixels)
;     sprite_y_base_low/high: Y coordinate of sprite to plot (pixels)
; 
;            sprite_op_flags: These bits are mutually exclusive. If bit is set:
; 
;                             bit 0: also copy the screen into sprite 'dest_sprite_id'
;                             bit 1: erase the sprite from the screen (using mask)
;                             bit 2: write to the screen without a mask
;                             bits 3-7: unused
; 
;        sprite_reflect_flag: bit 7: draw sprite reflected ('looking left')
; 
; On Exit:
;     Preserves A,X,Y
; 
; Notes:
; 
; Sprites are stored after a sprite table that hold the two byte offset to the sprite
; data itself.
; Each sprite stores a four byte header, containing:
; 
;     <signed byte>   offset x to start drawing the sprite relative to sprite_x_base
;     <signed byte>   offset y to start drawing the sprite relative to sprite_y_base
;     <unsigned byte> width of sprite in pixels
;     <unsigned byte> height of sprite in pixels
; 
; Sprite pixels are then stored in the following bytes, starting with the bottom left
; pixel and moving up the sprite. Columns are stored from left to right.
; 
; Each pixel is encoded in two bits:
; 
;     00 - draw the background colour (colour 0)
;     01 - draw the foreground colour (colour 1)
;     10 - don't draw a pixel (it is a masked pixel)
;     11 - finish the current column and start the next column
; 
; The behaviour of '11' shows that this is a compression scheme, where columns can
; finish early if they have no set pixels at the top of the sprite.
; 
; *************************************************************************************
.sprite_op
    pha                                                               ; remember A,X,Y
    txa
    pha
    tya
    pha
    lda sprite_id
    jsr get_address_of_sprite_a
    stx src_sprite_address_low
    sty src_sprite_address_high
    lda sprite_op_flags
    and #sprite_op_flags_copy_screen
    beq skip_copying_sprite_header_to_destination_sprite              ; check flags to see if we are copying to another sprite
; get destination sprite address
    lda dest_sprite_id
    jsr get_address_of_sprite_a
    stx dest_sprite_address_low
    sty dest_sprite_address_high
; copy the first four bytes from source sprite to destination sprite (the header)
    ldy #3
.copy_sprite_header_loop
    lda (src_sprite_address_low),y
    sta (dest_sprite_address_low),y
    dey
    bpl copy_sprite_header_loop
    sty erase_sprite_byte                                             ; Y=255
; add the x and y offset in the sprite header to the sprite position
.skip_copying_sprite_header_to_destination_sprite
    ldy #0
    lda (src_sprite_address_low),y                                    ; read byte 0 of sprite, a start x offset
    ldx sprite_reflect_flag
    bpl skip_inverting_x_offset
    eor #&ff
.skip_inverting_x_offset
    ldx #0
    ora #0                                                            ; set flags based on A
    bpl non_negative_offset_in_x
    dex
.non_negative_offset_in_x
    clc
    adc sprite_x_base_low
    sta sprite_x_pos_low
    txa
    adc sprite_x_base_high
    sta sprite_x_pos_high
    ldx #0
    iny                                                               ; Y=1
    lda (src_sprite_address_low),y                                    ; read byte 1 of sprite, a start y offset
    bpl non_negative_offset_in_y
    dex
.non_negative_offset_in_y
    clc
    adc sprite_y_base_low
    sta sprite_y_pos_low
    txa
    adc sprite_y_base_high
    sta sprite_y_pos_high
    iny                                                               ; Y=2
    lda (src_sprite_address_low),y                                    ; read sprite width in pixels - 1
    sta sprite_width
    ldy #4
    lda (src_sprite_address_low),y                                    ; read the first byte of sprite data
    sta sprite_data_byte
    sty byte_offset_within_sprite
    lda #4
    sta num_two_bit_offsets_within_byte
    jsr clamp_and_clip_x
; Take the Y position and round down to the previous character row
    lda sprite_y_pos_high
    sta sprite_screen_address_high
    lda sprite_y_pos_low
    and #&f8
; Then multiply by eight and store in ($72)
    asl a
    rol sprite_screen_address_high
    asl a
    rol sprite_screen_address_high
    asl a
    rol sprite_screen_address_high
    sta sprite_screen_address_low
; Multiply by four
    ldx sprite_screen_address_high
    asl a
    rol sprite_screen_address_high
    asl a
    rol sprite_screen_address_high
; Add eight times the x position as a character row
    lda sprite_x_pos_low
    and #&f8
    clc
    adc sprite_screen_address_low
    sta sprite_screen_address_low
; Add high byte including X
    sta sprite_screen_address_for_column_low
    txa
    adc sprite_screen_address_high
    clc
    adc sprite_x_pos_high
    bpl not_out_of_range
    jmp reset_sprite_flags_and_exit

.not_out_of_range
    clc
    adc screen_base_address_high
    sta sprite_screen_address_high
    sta sprite_screen_address_for_column_high
; set Y to the horizontal offset within byte (0-7) of the sprite X position
    lda sprite_x_pos_low
    and #7
    eor #7
    tay
; set the vertical offset within a character row (0-7) of the sprite Y position
    lda sprite_y_pos_low
    and #7
    sta sprite_y_offset_within_character_row
; load X and check flags to see if we are copying the mask to a destination sprite
    ldx num_two_bit_offsets_within_byte
    lda sprite_op_flags
    and #sprite_op_flags_copy_screen
    beq sprite_op_without_copying_mask
    jmp draw_sprite

.sprite_op_without_copying_mask
    lda sprite_op_flags
    and #sprite_op_flags_erase_to_fg_colour OR sprite_op_flags_erase_to_bg_colour
    beq skip3
    and #sprite_op_flags_erase_to_fg_colour
    bne erase_sprite_to_fg_colour
; Bit 1 of sprite_op_flags is set (but not bit 2).
; This erases the sprite from the screen, setting pixels to the background colour.
; This self-modifies code
    lda #opcode_clc
    sta smc_sprite_opcode
; Write JMP and_byte_with_mask_and_write_to_screen2
    lda #opcode_jmp
    sta smc_sprite_opcode+1
    lda #<and_byte_with_mask_and_write_to_screen2
    sta smc_sprite_opcode+2
    lda #>and_byte_with_mask_and_write_to_screen2
    sta smc_sprite_opcode+3
    bne skip3                                                         ; ALWAYS branch

; Write 'SEC; SEC'
.erase_sprite_to_fg_colour
    lda #opcode_sec
    sta smc_sprite_opcode
    sta smc_sprite_opcode+1
.skip3
    jmp draw_sprite2

; *************************************************************************************
; 
; Regular sprite routines
; 
; *************************************************************************************
.out_of_bounds_vertically2
    asl sprite_data_byte
    clc
    jmp move_up_to_next_pixel_row2

.record_that_we_are_out_of_screen_range_vertically2
    lda #0
    sta vertical_sprite_position_is_valid_flag
    jmp y_coordinate_is_within_character_row2

.write_one_pixel_to_the_screen2
    lda vertical_sprite_position_is_valid_flag
    beq out_of_bounds_vertically2
    lda (sprite_screen_address_low),y
    asl sprite_data_byte                                              ; Put drawing info into carry (1=fg, 0=bg)
.smc_sprite_opcode
; ALTERNATIVE 1: Used for writing background colour to the screen. Don't care about pixel value, just write the background colour
    ; clc
    ; jmp and_byte_with_mask_and_write_to_screen2
; ALTERNATIVE 2: Used for writing foreground colour to the screen. Don't care about pixel value, just write the foreground colour
    ; sec
    ; sec
    ; ora sprite_bit
; ALTERANTIVE 3: Use the actual pixel value to determine whether to write the foreground or background colour
    bcc and_byte_with_mask_and_write_to_screen2                       ; Draw background colour by setting pixel block = pixel block AND NOT sprite_bit (i.e. sprite_bit_mask)
    ora sprite_bit                                                    ; Fall through to draw foreground colour by setting pixel block = pixel block OR sprite_bit
; Fixed code
    sta (sprite_screen_address_low),y
    dey
    bpl y_coordinate_is_within_character_row2
    ldy #7
    lda sprite_screen_address_low
    sbc #&40 ; '@'
    jmp move_up_to_previous_character_row2

.and_byte_with_mask_and_write_to_screen2
    and sprite_bit_mask
    sta (sprite_screen_address_low),y
.move_up_to_next_pixel_row2
    dey
    bpl y_coordinate_is_within_character_row2
    ldy #7
    lda sprite_screen_address_low
    sbc #&3f ; '?'
.move_up_to_previous_character_row2
    sta sprite_screen_address_low
    lda sprite_screen_address_high
    sbc #1
    sta sprite_screen_address_high
.check_within_vertical_range2
    sta vertical_sprite_position_is_valid_flag
    cmp #&80
    bcs record_that_we_are_out_of_screen_range_vertically2
    cmp screen_base_address_high
    bcc record_that_we_are_out_of_screen_range_vertically2
.y_coordinate_is_within_character_row2
    dex
    bpl byte_not_finished_yet2
    sty temp_y
    inc byte_offset_within_sprite
    ldy byte_offset_within_sprite
    lda (src_sprite_address_low),y
    sta sprite_data_byte
    ldx #3
    ldy temp_y
.byte_not_finished_yet2
    asl sprite_data_byte
    bcc write_one_pixel_to_the_screen2
    asl sprite_data_byte
    bcc move_up_to_next_pixel_row2
    dec sprite_width
    beq finish_off_sprite2
    lda sprite_screen_address_for_column_high
    sta sprite_screen_address_high
    lda sprite_screen_address_for_column_low
    sta sprite_screen_address_low
    ldy sprite_reflect_flag
    bmi move_to_next_column_while_rendering_reflected_about_y_axis2
    ldy sprite_x_offset_within_byte
    dey
    bpl draw_sprite2
    inc sprite_cell_x_pos
    ldy sprite_cell_x_pos
    cpy #cells_per_character_row
    bcs finish_off_sprite2
    ldy #7
    adc #8
    sta sprite_screen_address_for_column_low
    sta sprite_screen_address_low
    bcc draw_sprite2
    inc sprite_screen_address_for_column_high
    inc sprite_screen_address_high
    jmp draw_sprite2

.move_to_next_column_while_rendering_reflected_about_y_axis2
    ldy sprite_x_offset_within_byte
    iny
    cpy #8
    bcc draw_sprite2
    dec sprite_cell_x_pos
    bmi finish_off_sprite2
    ldy #0
    sbc #8
    sta sprite_screen_address_for_column_low
    sta sprite_screen_address_low
    bcs draw_sprite2
    dec sprite_screen_address_for_column_high
    dec sprite_screen_address_high
.draw_sprite2
    sty sprite_x_offset_within_byte
    lda power_of_2_table,y
    sta sprite_bit
    eor #&ff
    sta sprite_bit_mask
    ldy sprite_y_offset_within_character_row
    lda sprite_screen_address_high
    jmp check_within_vertical_range2

.finish_off_sprite2
    lda #&90                                                          ; restore the original three bytes of code (self-modifying)
    sta smc_sprite_opcode                                             ; 90 10='bcc and_byte_with_mask_and_write_to_screen2'
    lda #&10
    sta smc_sprite_opcode+1
    lda #5                                                            ; 05 82='ora sprite_bit'
    sta smc_sprite_opcode+2
    lda #&82
    sta smc_sprite_opcode+3
    jmp reset_sprite_flags_and_exit

; *************************************************************************************
; 
; Sprite routines that also copy the mask to a destination sprite (similar to code
; above)
; 
; *************************************************************************************
.out_of_bounds_vertically
    asl sprite_data_byte
; shift '10' pair of bits into the 'erase' byte, which means 'don't draw' the pixel
; when erasing
    sec
    rol erase_sprite_byte
    asl erase_sprite_byte
    jmp move_up_to_next_pixel_row

.record_that_we_are_out_of_screen_range_vertically
    lda #0
    sta vertical_sprite_position_is_valid_flag
    jmp y_coordinate_is_within_character_row

.write_one_pixel_to_the_screen
    lda vertical_sprite_position_is_valid_flag
    beq out_of_bounds_vertically
; shift a 0 bit into the 'erase' byte, the first of a pair of bits: 00=draw bg colour,
; 01=draw fg colour. This is used to erase the sprite. Carry is set, since the initial
; value of the 'erase' byte is $ff
    asl erase_sprite_byte
; read byte from screen
    lda (sprite_screen_address_low),y
    bit sprite_bit                                                    ; read the screen pixel into Z
    bne skip1                                                         ; if (screen pixel is set) then branch.
    clc
; at this point carry holds the screen pixel value, which we write to the 'erase' byte
; so we can restore the screen contents later
.skip1
    rol erase_sprite_byte
    asl sprite_data_byte
    bcc and_byte_with_mask_and_write_to_screen
; OR in (set) the appropriate bit and write back to screen memory
    ora sprite_bit
    sta (sprite_screen_address_low),y                                 ; write byte to screen
.move_up_to_next_pixel_row
    dey
    bpl y_coordinate_is_within_character_row
    ldy #7
    lda sprite_screen_address_low
    sbc #<screen_width_in_pixels
    jmp move_up_to_previous_character_row

; AND with the mask to clear the appropriate bit and write the byte back to screen
; memory
.and_byte_with_mask_and_write_to_screen
    and sprite_bit_mask
    sta (sprite_screen_address_low),y                                 ; write byte to screen
    dey
    bpl y_coordinate_is_within_character_row
    ldy #7
    lda sprite_screen_address_low
    sbc #<(screen_width_in_pixels-1)
.move_up_to_previous_character_row
    sta sprite_screen_address_low
    lda sprite_screen_address_high
    sbc #>(screen_width_in_pixels-1)
    sta sprite_screen_address_high
.check_within_vertical_range
    sta vertical_sprite_position_is_valid_flag                        ; check if Y coordinate is above or below the screen area
    cmp #&80                                                          ; $8000 is end of screen memory
    bcs record_that_we_are_out_of_screen_range_vertically
    cmp screen_base_address_high
    bcc record_that_we_are_out_of_screen_range_vertically
.y_coordinate_is_within_character_row
    dex
    bpl byte_not_finished_yet
    sty temp_y
; copy 'erase' byte to destination
    ldy byte_offset_within_sprite
    lda erase_sprite_byte
    sta (dest_sprite_address_low),y
    iny
    sty byte_offset_within_sprite
; load next source byte from sprite
    lda (src_sprite_address_low),y
    sta sprite_data_byte
; set 'erase' byte to 255
    stx erase_sprite_byte
    ldx #3                                                            ; reset loop counter
    ldy temp_y
.byte_not_finished_yet
    asl sprite_data_byte                                              ; check top bit
    bcc write_one_pixel_to_the_screen                                 ; if (sprite bit is clear) then branch (to write pixel to screen)
    rol erase_sprite_byte                                             ; add set bit to 'erase' byte
    asl sprite_data_byte                                              ; get next bit
    bcs found_second_bit_set                                          ; if bit set then branch
; 'rol'-in a clear bit to the 'erase' byte. Now the 'erase' byte has a 10 pair of bits,
; which is the code for 'don't draw'. This makes sense as this is a pixel we didn't
; draw.
    rol erase_sprite_byte
    dey
; if still in same character row, then branch back
    bpl y_coordinate_is_within_character_row
    ldy #7
; move up to previous character row
    lda sprite_screen_address_low
    sbc #<screen_width_in_pixels
    jmp move_up_to_previous_character_row

; add set bit to 'erase' byte. Now the 'erase' byte has a 11 pair of bits, meaning the
; end of the column.
.found_second_bit_set
    rol erase_sprite_byte
    dec sprite_width                                                  ; check if we are done
    beq finish_off_sprite
; reset sprite address
    lda sprite_screen_address_for_column_high
    sta sprite_screen_address_high
    lda sprite_screen_address_for_column_low
    sta sprite_screen_address_low
    ldy sprite_reflect_flag
    bmi move_to_next_column_while_rendering_reflected_about_y_axis
; move to next column
    ldy sprite_x_offset_within_byte
    dey
    bpl draw_sprite
    inc sprite_cell_x_pos
    ldy sprite_cell_x_pos
; if we reach the right hand edge of the screen then we are done
    cpy #cells_per_character_row
    bcs finish_off_sprite
; move sprite addresses on by eight to get to next cell column
    ldy #7                                                            ; reset to start of (i.e. bit 7 of) next byte
    adc #8
    sta sprite_screen_address_for_column_low
    sta sprite_screen_address_low
    bcc draw_sprite
    inc sprite_screen_address_for_column_high
    inc sprite_screen_address_high
    jmp draw_sprite

.move_to_next_column_while_rendering_reflected_about_y_axis
    ldy sprite_x_offset_within_byte                                   ; move within byte to next bit
    iny
    cpy #8
    bcc draw_sprite
    dec sprite_cell_x_pos
    bmi finish_off_sprite
    ldy #0
    sbc #8
    sta sprite_screen_address_for_column_low
    sta sprite_screen_address_low
    bcs draw_sprite
    dec sprite_screen_address_for_column_high
    dec sprite_screen_address_high
.draw_sprite
    sty sprite_x_offset_within_byte
    lda power_of_2_table,y
    sta sprite_bit                                                    ; store the single bit within a byte we are interested in
    eor #&ff
    sta sprite_bit_mask                                               ; store every other bit in the byte other than the one we are interested in (it's a mask)
    ldy sprite_y_offset_within_character_row
    lda sprite_screen_address_high
    jmp check_within_vertical_range

.finish_off_sprite
    lda erase_sprite_byte
    dex
    bmi write_last_byte_to_destination_sprite
.shift_mask_byte_loop
    asl a
    asl a
    dex
    bpl shift_mask_byte_loop
.write_last_byte_to_destination_sprite
    ldy byte_offset_within_sprite
    sta (dest_sprite_address_low),y
    jmp reset_sprite_flags_and_exit

.clamp_and_clip_x
    ldy sprite_x_pos_high                                             ; exit if X position is 512 or more
    iny
    cpy #3
    bcs pull_values_and_exit_sprite_op_local
    ldy sprite_y_pos_high                                             ; exit if Y position is 512 or more
    iny
    cpy #3
    bcc clamp_x
.pull_values_and_exit_sprite_op_local
    jmp pull_values_and_exit_sprite_op

.clamp_x
    lda sprite_x_pos_low
; calculate cell x position by dividing pixel position by eight
    sta sprite_cell_x_pos
    lda sprite_x_pos_high
    lsr a
    ror sprite_cell_x_pos
    lsr a
    ror sprite_cell_x_pos
    lsr a
    ror sprite_cell_x_pos
; check flags2 (top bit) to see if we should clamp to the right edge
    lda sprite_reflect_flag
    bmi sprite_clamp_x_right
; clamp to left edge
    lda sprite_cell_x_pos
    bmi sprite_clamp_x_left
; if fully off screen to the right, then pull values and return else just return
    cmp #cells_per_character_row
    bcc return3
    jmp pull_values_and_exit_sprite_op

.sprite_clamp_x_left
    lda #0
    sec
    sbc sprite_x_pos_low
    sta amount_sprite_is_offscreen_x
    lda #0
    sta sprite_x_pos_low
    sta sprite_x_pos_high
    sta sprite_cell_x_pos
    jmp sprite_clip_x

.sprite_clamp_x_right
    lda sprite_cell_x_pos
    bmi pull_values_and_exit_sprite_op
    cmp #cells_per_character_row
    bcc return3
    lda sprite_x_pos_low
    sbc #<(screen_width_in_pixels-1)
    sta amount_sprite_is_offscreen_x
; set x position to the right edge (319)
    lda #<(screen_width_in_pixels-1)
    sta sprite_x_pos_low
    lda #>(screen_width_in_pixels-1)
    sta sprite_x_pos_high
    lda #cells_per_character_row-1
    sta sprite_cell_x_pos
.sprite_clip_x
    lda amount_sprite_is_offscreen_x
    cmp sprite_width
    bcs pull_values_and_exit_sprite_op                                ; exit if fully offscreen
    lda sprite_data_byte
    ldx num_two_bit_offsets_within_byte
    ldy byte_offset_within_sprite
.sprite_clip_x_loop
    dex
    bpl read_next_source_pixel
    lda sprite_op_flags
    and #sprite_op_flags_copy_screen
    beq not_copying_to_destination_sprite
    lda erase_sprite_byte
    sta (dest_sprite_address_low),y
    stx erase_sprite_byte                                             ; set dest sprite byte to 255
.not_copying_to_destination_sprite
    iny
    lda (src_sprite_address_low),y
    ldx #3
.read_next_source_pixel
    asl a                                                             ; get top bit
    bcs found_set_bit                                                 ; if set then branch
    rol erase_sprite_byte                                             ; put clear bit into mask
    asl a                                                             ; read next bit
    rol erase_sprite_byte                                             ; put next bit into mask
    jmp sprite_clip_x_loop                                            ; loop back

.found_set_bit
    rol erase_sprite_byte                                             ; put set bit into mask
    asl a                                                             ; get next bit
    bcs found_second_set_bit                                          ; if set then branch
    rol erase_sprite_byte                                             ; put zero bit into mask
    jmp sprite_clip_x_loop                                            ; loop back

.found_second_set_bit
    rol erase_sprite_byte                                             ; put another set bit into mask
    dec sprite_width                                                  ; decrement loop counters
    dec amount_sprite_is_offscreen_x
    bne sprite_clip_x_loop                                            ; jump back if not done
    sta sprite_data_byte
    stx num_two_bit_offsets_within_byte
    sty byte_offset_within_sprite
.return3
    rts

.pull_values_and_exit_sprite_op
    pla
    pla
    jmp reset_sprite_flags_and_exit

; Record the brk error code, but otherwise do nothing - don't return from interrupt,
; just restore the stack pointer and continue (!)
ENDIF

.brk_handler
    ldy #0
    lda (brk_address_low),y
    sta error_code_on_brk
    jmp restore_brk_handler_since_osfile_is_finished

; *************************************************************************************
; 
; OSFILE wrapper
; 
; On Entry:
;      A: OSFILE action:
;         $00 = save
;         $05 = read catalogue
;         $ff = load
;     YX: address of filename
; 
; *************************************************************************************
.osfile_wrapper
    stx osfile_block_load_address_low
    sty osfile_block_load_address_mid1
    ldx #0
    stx osfile_block_load_address_mid2
    stx osfile_block_load_address_high
    stx osfile_block_exec_address_mid2
    stx osfile_block_exec_address_high
    stx osfile_block_start_address_mid2
    stx osfile_block_start_address_high
    stx osfile_block_end_address_mid2
    stx osfile_block_end_address_high
    tay
    beq skip_if_saving
    stx osfile_block_exec_address_low
.skip_if_saving
    ldx #0
    stx error_code_on_brk
    tsx
    stx remember_stack_pointer
    sei
; use our brk_handler (to trap disk errors)
    ldx old_brkv2
    stx brkv
    ldx old_brkv2+1
    stx brkv+1
    cli
    ldx #<(osfile_block_filename_low)
    ldy #>(osfile_block_filename_low)
    jsr osfile
.restore_brk_handler_since_osfile_is_finished
    sei
; reset brk handler to standard one (after disk access finished)
    ldx old_brkv1
    stx brkv
    ldx old_brkv1+1
    stx brkv+1
    cli
; restore stack pointer, since it may have been disrupted by a BRK during OSFILE
    ldx remember_stack_pointer
    txs
    lda error_code_on_brk
    beq no_disk_error
.show_disk_error_dialog_if_display_is_initialised
    lda display_initialised_flag
    beq no_disk_error
; beep and show disk error dialog
    lda #vdu_bell
    jsr oswrch                                                        ; Write character 7
    lda #&12
    sta current_text_width
    jsr show_dialog_box
    lda #&0a
    jsr oswrch                                                        ; Write character 10
    ldx #<disk_error_encrypted_string
    ldy #>disk_error_encrypted_string
    jsr print_encrypted_string_at_yx_centred
    jsr wait_one_second_then_check_keys
    jsr wait_one_second_then_check_keys
.no_disk_error
    jsr check_menu_keys
IF swr_renderer_enabled
    ; MOS/DFS may select a ROM, including on trapped errors. Resume gameplay
    ; with the asset window mapped; avoid writes if it is already selected.
    jsr swr_select_bank
ENDIF
    lda error_code_on_brk
    rts

; 'Disk error[0d]' EOR-encrypted with $cb
.disk_error_encrypted_string
    equb &8f, &a2, &b8, &a0, &eb, &ae, &b9, &b9, &a4, &b9, &c6
.pending_toolbar_colour
    equb 0
.toolbar_colour
    equb 0
.pending_gameplay_area_colour
    equb 0
.gameplay_area_colour
    equb 0
.toolbar_colour_choices
    equb colour_yellow,  colour_green,  colour_white,    colour_red
.use_colour_flag
    equb &ff

; Set the toolbar and gameplay area colours. In mono mode both are white. In colour
; mode the gameplay area is cyan and the toolbar colour is
; toolbar_colour_choices[(level_letter - 'A') & 3].
.set_toolbar_and_gameplay_area_colours
    lda #colour_white
    sta pending_toolbar_colour
    sta pending_gameplay_area_colour
    lda use_colour_flag
    beq return4
    ldy current_level
    jsr convert_level_filename_letter_into_section_letter
    tya
    sec
    sbc #first_level_letter
    and #3
    tax
    lda toolbar_colour_choices,x
    sta pending_toolbar_colour
    lda #colour_cyan
    sta pending_gameplay_area_colour
.return4
    rts

.vsync_counter
    equb 0

.wait_for_vsync
    lda #osbyte_vsync
    jmp osbyte                                                        ; Wait for vertical sync

; wait for vsync timer to help avoid flicker
.wait_for_timer_2_using_yx
    txa
    clc
    adc #&ff
    tya
    adc #0
    eor #&ff
.delay_loop
    cmp system_via_t2c_h
    bcc delay_loop
    rts

.irq1_routine
    pha
    lda interrupt_accumulator
    pha                                                               ; remember A,X,Y
    txa
    pha
    tya
    pha
    jsr if_vsync_elapsed_then_set_toolbar_area_palette
    jsr if_timer1_elapsed_then_set_main_area_palette
    pla                                                               ; recall A,X,Y
    tay
    pla
    tax
    pla
    sta interrupt_accumulator
    pla
    jmp (old_irq1v)

.if_vsync_elapsed_then_set_toolbar_area_palette
    lda #2
    bit system_via_ifr                                                ; check for vsync interrupt
    beq return5
; reset timers
    lda timingA_counter_low
    sta system_via_t1c_l
    lda timingA_counter_high
    sta system_via_t1c_h
    lda timing_latch_low
    sta system_via_t1l_l
    lda timing_latch_high
    sta system_via_t1l_h
    lda #&ff
    sta system_via_t2c_h
    ldx #1
    ldy toolbar_colour
    jsr change_palette_logical_colour_x_to_y
    lda developer_flags
    bpl skip_developer_mode_code2
    ldx #0
    ldy #colour_magenta
    jsr change_palette_logical_colour_x_to_y
.skip_developer_mode_code2
    lda #0
    sta gameplay_area_palette_set
    inc vsync_counter
.return5
    rts

.if_timer1_elapsed_then_set_main_area_palette
    lda #&40 ; '@'
    bit system_via_ifr                                                ; check for timer1 elapsed
    beq return6
    lda gameplay_area_palette_set
    bne return6
    ldx #1
    ldy gameplay_area_colour
    jsr change_palette_logical_colour_x_to_y
    lda developer_flags
    bpl skip_developer_mode_code3
    ldx #0
    ldy #colour_black
    jsr change_palette_logical_colour_x_to_y
.skip_developer_mode_code3
    inc gameplay_area_palette_set
    jsr update_main_keys
    jsr update_space_etc_keys
.return6
    rts

.gameplay_area_palette_set
    equb 0

.change_palette_logical_colour_x_to_y
    txa
    lsr a
    php
    tya
    eor #7
    asl a
    plp
    ror a
    ldx #7
.change_palette_loop
    sta video_ula_palette
    adc #&10
    dex
    bpl change_palette_loop
    rts

.reset_game_because_escape_pressed
    jsr wait_for_vsync
    jsr wait_for_timingB_counter
    jsr reset_code
    jmp initialise_display

; Restore developer snapshots: exit code into &0C00 and the &0B00 page.
; SWR builds use the configured bank and discard restored cache validity.
; The original slot-12 path is retained only for --legacy-only builds.
.reset_code
IF swr_boot_enabled
    PHP
    SEI
    LDA romsel_copy
    PHA
IF swr_renderer_enabled
    LDA swr_runtime_bank
ELSE
    LDA #swr_configured_bank
ENDIF
    STA romsel_copy
    STA romsel
    LDY #0
.copy_from_rom_c_loop
    LDA sideways_ram_be00,Y
    STA initialise_display,Y
IF swr_renderer_enabled
    CPY #17
    BCS swr_skip_adapter_restore
ENDIF
    LDA sideways_ram_bf00,Y
    STA area_to_copy_to_or_from_sideways_ram,Y
.swr_skip_adapter_restore
    INY
    BNE copy_from_rom_c_loop
    PLA
    STA romsel_copy
    STA romsel
    PLP
IF swr_renderer_enabled
    JSR swr_invalidate_caches
ENDIF
    STY first_byte_break_intercept
    RTS
ELSE
    sei
    lda #&0c
    sta romsel                                                        ; select ROM in slot 13
    ldy #0
.copy_from_rom_c_loop
    lda sideways_ram_be00,y
    sta initialise_display,y
    lda sideways_ram_bf00,y
    sta area_to_copy_to_or_from_sideways_ram,y
    iny
    bne copy_from_rom_c_loop
    lda romsel_copy
    sta romsel
    cli
; clear the reset vector
    sty first_byte_break_intercept
    rts

ENDIF

.print_italic
    cmp #'!'
    bcc print_italic_rts
    cmp #&7f
    bcs print_italic_rts
    sta osword_read_character_block
    txa                                                               ; remember X,Y
    pha
    tya
    pha
    lda #osword_read_char
    ldx #<(osword_read_character_block)
    ldy #>(osword_read_character_block)
    jsr osword                                                        ; Read character definition
    lsr osword_read_character_block+1
    lsr osword_read_character_block+2
    asl osword_read_character_block+6
    asl osword_read_character_block+7
    asl osword_read_character_block+8
    lda #vdu_define_character
    jsr oswrch                                                        ; Write character 23
    lda #&ff
    jsr oswrch                                                        ; Write character 255
    ldx #0
.define_character_ff_loop
    lda osword_read_character_block+1,x
    jsr oswrch                                                        ; Write character
    inx
    cpx #8
    bcc define_character_ff_loop
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda #&ff
.print_italic_rts
    jmp oswrch                                                        ; Write character 255

; *************************************************************************************
; 
; Random Number Generator
; 
; On Entry:
;     A must be one less than a power of two, a mask to fill in with random bits
; 
; On Exit:
;     A holds a random number up to the value of A on entry
; 
; *************************************************************************************
.get_random_number_up_to_a
    sta bit_mask_for_random_number_limit                              ; store loop variable, all 1s in the lowest bits
    pha                                                               ; remember mask
.generate_random_bits_loop
    lda rnd2
    lsr a
    lsr a
    lsr a
    eor rnd4
    ror a
    rol rnd0
    rol rnd1
    rol rnd2
    rol rnd3
    rol rnd4
    lsr bit_mask_for_random_number_limit                              ; update loop variable by shifting right
    bne generate_random_bits_loop                                     ; loop back until enough random bits are generated
    pla                                                               ; recall mask
    and rnd0                                                          ; AND the mask with the random bits
    rts

; *************************************************************************************
; 
; Check for player leaving room
; 
; On Exit:
;     A: 0=player is still within game area
;        1=exit room left
;        2=exit room bottom
;        4=exit room right
;        8=exit room top
; 
; *************************************************************************************
.check_for_player_leaving_room
    lda object_x_high
    bmi increase_player_x_coordinate_to_enter_next_room
    beq get_delta_y
    lda object_x_low
    cmp #&40 ; '@'
    bcs decrease_player_x_coordinate_to_enter_next_room
.get_delta_y
    lda object_y_low
    sec
    sbc object_y_low_old
    beq return_with_a_zero
    lda object_y_high
    sbc object_y_high_old
    sta object_y_delta
    ldx #0
    jsr find_top_and_bottom_of_object
; Find the average of object_true_bottom and object_bottom and convert to a cell Y
; value. Use this value to test if the player is off screen.
    lda object_top_low
    clc
    adc object_bottom_low
    sta object_top_cell_y
    lda object_top_high
    adc object_bottom_high
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    lda object_top_cell_y
    bmi increase_player_y_coordinate_to_enter_next_room
    cmp #game_area_height_cells
    bcs decrease_player_y_coordinate_to_enter_next_room
.return_with_a_zero
    lda #0
    rts

; If the player is off the left of the game play area, this is called. It increases the
; X coordinate by 320 pixels. It does the same for object one, the player's accessory
; object. Returns with A=1.
.increase_player_x_coordinate_to_enter_next_room
    ldx #1                                                            ; object index (and loop counter)
; add one screen amount to the X coordinate
.add_to_player_x_loop
    lda object_x_low,x
    clc
    adc #&40 ; '@'
    sta object_x_low,x
    lda #1
    sta object_x_high,x
    dex
    bpl add_to_player_x_loop
    lda #1
    rts

; If the player is off the right of the game play area, this is called. It decreases
; the X coordinate by 320 pixels. It does the same for object one, the player's
; accessory object. Returns with A=4.
.decrease_player_x_coordinate_to_enter_next_room
    ldx #1                                                            ; object index (and loop counter)
.subtract_from_player_x_loop
    lda object_x_low,x
    sec
    sbc #&40 ; '@'
    sta object_x_low,x
    lda #0
    sbc #0
    sta object_x_high,x
    dex
    bpl subtract_from_player_x_loop
    lda #4
    rts

; If the player is off the top of the game play area, this is called. It increases the
; Y coordinate by 192 pixels = 24*8 pixels. Does the same for object one, the player's
; accessory object. Returns with A=8.
.increase_player_y_coordinate_to_enter_next_room
    lda object_y_delta
; return if the player is moving in the correct direction (down) to get back on screen
    bpl return_with_a_zero
    ldx #1                                                            ; object index (and loop counter)
.add_to_player_y_loop
    lda object_y_low,x
    clc
    adc #&c0
    sta object_y_low,x
    lda #0
    sta object_y_high,x
    dex
    bpl add_to_player_y_loop
    lda #8
    rts

; If the player is off the bottom of the game play area, this is called. It reduces the
; Y coordinate by 192 pixels = 24*8 pixels. Does the same for object one, the player's
; accessory object. Returns with A=2.
.decrease_player_y_coordinate_to_enter_next_room
    lda object_y_delta
; return if the player is moving in the correct direction (up) to get back on screen
    bmi return_with_a_zero
    ldx #1                                                            ; object index (and loop counter)
.subtract_from_player_y_loop
    lda object_y_low,x
    sec
    sbc #&c0
    sta object_y_low,x
    dex
    bpl subtract_from_player_y_loop
    lda #2
    rts

; use the value stored in the X,Y registers as an address to jump to
.jmp_yx
    stx jmp_instruction+1
    sty jmp_instruction+2
.jmp_instruction
    jmp 0

IF swr_renderer_enabled = 0
.load_sprdata
    lda #<sprdata_filename
    sta osfile_block_filename_low
    lda #>sprdata_filename
    sta osfile_block_filename_high
    ldx sprdata_ptr
    ldy sprdata_ptr + 1
    lda #osfile_load
    jmp osfile_wrapper

.sprdata_filename
    equs "sprdata", &0d

; TODO: this is used by e.g. dataA
; *************************************************************************************
; 
; Initialise or update a brazier and associated fire.
; 
; On the first update, two objects are initialised, the brazier and the fire. It
; chooses a direction based on whether a wall is to the left or right. It sets a random
; initial animation state then draws them.
; On subsequent updates, the fire animation is advanced.
; 
; On Entry:
;     A: object index for brazier
;     X,Y: cell coordinates of brazier
; On Exit:
;     A,X,Y are preserved
; 
; *************************************************************************************
ENDIF
.update_brazier_and_fire
    sta fire_object_index
    txa                                                               ; remember X,Y
    pha
    tya
    pha
    lda update_room_first_update_flag
    beq not_first_update
; initialise brazier and fire, if not changing rooms
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne done_with_brazier_and_fire
; work out direction to draw brazier (left or right)
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    beq brazier_position_already_blocked_so_look_left
; block positions and draw brazier
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    iny
    lda #spriteid_brazier
    jsr draw_sprite_a_at_cell_xy
    dey
; increment object index past the brazier to be the fire
    inx
    lda fire_object_index
; set the fire object position
    jsr set_object_position_from_cell_xy
; fire looks right
    lda #1
    bne set_fire_direction                                            ; ALWAYS branch
.brazier_position_already_blocked_so_look_left
    dex
; make the brazier solid
    lda #collision_map_solid_rock
    jsr write_a_single_value_to_cell_in_collision_map
    inx
; draw brazier reflected to look left
    lda #&ff
    sta sprite_reflect_flag
    iny
    lda #spriteid_brazier
    jsr draw_sprite_a_at_cell_xy
    dey
    dex
; set fire object position
    lda fire_object_index
    jsr set_object_position_from_cell_xy
; fire looks left
    lda #&ff
.set_fire_direction
    ldx fire_object_index
    sta object_direction,x
    lda #7
    jsr get_random_number_up_to_a
    sta object_current_index_in_animation,x
.done_with_brazier_and_fire
    jmp set_fire_sprite_to_use

.not_first_update
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne set_fire_sprite_to_use
    ldx fire_object_index
    inc object_current_index_in_animation,x
.set_fire_sprite_to_use
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne return_with_result
    ldx fire_object_index
    lda object_current_index_in_animation,x
    and #7
    clc
    adc #spriteid_fire1
    sta object_spriteid,x
.return_with_result
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda fire_object_index
    rts

.fire_object_index
    equb 0

; *************************************************************************************
; 
; Update the level completion detection
; 
; Checks for colliding with the level completion spell collectable, adds the spell to
; the toolbar, and shows diamonds or sparkles as needed.
; 
; On Entry:
;     A: objectid of the spell collectable
;     (X,Y): cell position of the spell collectable
; 
; *************************************************************************************
; TODO: this is used by e.g. dataA
.update_level_completion
    sta remember_obj_index                                            ; remember inputs
    stx remember_cell_x
    sty remember_cell_y
; update diamond sprite to use
    inc diamond_sprite_index
    lda diamond_sprite_index
    and #7
    tay
; set diamond sprite to use
    lda diamond_sprite_cycle,y
    sta collectable_spriteids
    sta collectable_being_used_spriteids
; set toolbar sprite to use for diamond spell
    lda #spriteid_menu_item_completion_spell
    sta toolbar_collectable_spriteids
; early out if room has just changed
    lda desired_room_index
    cmp currently_updating_logic_for_room_index
    bne reset_offsets_and_exit
    lda update_room_first_update_flag
    bne skip_adding_level_completion_spell
; test for collision with spell collectable
    ldx remember_obj_index
    ldy #objectid_old_player
    jsr test_for_collision_between_objects_x_and_y
    beq skip_adding_level_completion_spell
; collided with level completion collectable, so mark level as completed
    lda current_level
    sec
    sbc #first_level_letter
    tay
; got completion spell
    lda level_progress_table,y
    ora #&80
    sta level_progress_table,y
; add level completion spell to toolbar
    lda #spriteid_menu_item_completion_spell
    jsr find_or_create_menu_slot_for_A
.skip_adding_level_completion_spell
    ldx remember_obj_index
    lda #spriteid_erase_sparkles
    sta object_erase_type,x
    lda #spriteid_one_pixel_masked_out
    sta object_spriteid,x
; exit if level is completed
    lda current_level
    sec
    sbc #first_level_letter
    tay
    lda level_progress_table,y
    and #&80
    bne reset_offsets_and_exit
    lda #1
    sta object_direction,x
    lda diamond_sprite_index
    and #7
    tay
    cpy #5
    bcc show_sparkles
; reverse direction of animation
    lda #&ff
    sta object_direction,x
    inc temp_sprite_x_offset
    tya
    sbc #8
    eor #&ff
    sec
.show_sparkles
    adc #spriteid_sparkles1
    sta object_spriteid,x
; A=object index
    txa
    ldx remember_cell_x
    ldy remember_cell_y
    jsr set_object_position_from_cell_xy
.reset_offsets_and_exit
    lda #0
    sta temp_sprite_x_offset
    sta temp_sprite_y_offset
    lda remember_obj_index
    ldx remember_cell_x
    ldy remember_cell_y
    rts

.remember_obj_index
    equb 0
.remember_cell_x
    equb 0
.remember_cell_y
    equb 0
.diamond_sprite_index
    equb 0
.diamond_sprite_cycle
    equb spriteid_diamond1
    equb spriteid_diamond2
    equb spriteid_diamond3
    equb spriteid_diamond4
    equb spriteid_diamond5
    equb spriteid_diamond4
    equb spriteid_diamond3
    equb spriteid_diamond2
.currently_updating_logic_for_room_index
    equb 0

; *************************************************************************************
; 
; Copy one or more tiles from off screen memory to a rectangular area of cells on
; screen. A 'tile' here means a bitmap of 8x8 pixels stored in eight bytes of memory.
; 
; On Entry:
;     X and Y registers specify top left cell
;     width_in_cells_to_write: width of rectangle (in cells)
;     height_in_cells_to_write: height of rectangle (in cells)
;     source_sprite_memory: source address data to copy to screen (top left)
;     copy_mode:
;         0: 2x2 pattern
;         1: simple copy
;         power of two: choose random tile offsets less than the power of two
;         negative: strip off top bit for length of tile offsets to cycle around
;     value_to_write_to_collision_map: if non-negative, write the value into the
; collision map using the same rectangle of cells
; 
; *************************************************************************************
.copy_rectangle_of_memory_to_screen
    pha
    sty current_row
    jsr clip_cells_to_write_to_collision_map
    jsr get_screen_address_from_cell_xy
    lda cell_screen_address_low
    sta first_cell_in_row_screen_address_low
    lda cell_screen_address_high
    sta first_cell_in_row_screen_address_high
    ldx source_sprite_memory_low
    ldy source_sprite_memory_high
    stx original_off_screen_address_low
    sty original_off_screen_address_high
    stx off_screen_address_low
    sty off_screen_address_high
    clc
    lda #0
    sta pattern_length_cycle_counter
.row_copy_loop
    ldx width_in_cells_to_write
    lda cell_x
    sta cell_x_plus_current_cell_within_row
.cell_copy_loop
    ldy #7
; Choose the pattern based on copy_mode
    lda copy_mode
    beq two_by_two_alternating_pattern
    bmi negative_copy_mode
    cmp #1
    clc
    beq copy_one_tile_loop
    sbc #0                                                            ; Subtract 1; note C cleared before beq
    jsr get_random_number_up_to_a
    jmp get_final_off_screen_tile_address

; strip off top bit, subtract one and compare with pattern_length_counter
.negative_copy_mode
    and #&7f
    sec
    sbc #1
    cmp pattern_length_cycle_counter
    lda pattern_length_cycle_counter
    inc pattern_length_cycle_counter
    bcs get_final_off_screen_tile_address
    lda #0
    sta pattern_length_cycle_counter
    jmp get_final_off_screen_tile_address

; Set A=%(low bit of current_row)(low bit of current column), giving a 2x2 alternating
; pattern.
.two_by_two_alternating_pattern
    lda cell_x_plus_current_cell_within_row
    lsr a
    lda current_row
    rol a
    and #3
; The value in A at this point is the offset from the first tile to use. We multiply
; this by eight to get the offset of the memory address of the tile (each tile being
; eight bytes), and add to the original tile address to get the final address of the
; tile we want to use.
; (The code uses the bottom two bits of off_screen_address_high to temporarily store
; the high bits of the offset. These two bits are then extracted and added to the
; original address to get the final address).
.get_final_off_screen_tile_address
    asl a
    asl a
    rol off_screen_address_high
    asl a
    rol off_screen_address_high
    clc
    adc original_off_screen_address_low
    sta off_screen_address_low
    lda off_screen_address_high
    and #3
    adc original_off_screen_address_high
    sta off_screen_address_high
.copy_one_tile_loop
    lda (off_screen_address_low),y
    sta (cell_screen_address_low),y
    dey
    bpl copy_one_tile_loop
    inc cell_x_plus_current_cell_within_row
    dex                                                               ; X was initialised with width_in_cells_to_write
    beq all_cells_in_row_copied
    lda cell_screen_address_low
    adc #8
    sta cell_screen_address_low
    bcc cell_copy_loop
    inc cell_screen_address_high
    clc
    bcc cell_copy_loop                                                ; ALWAYS branch
.all_cells_in_row_copied
    inc current_row
    dec height_in_cells_to_write
    beq now_write_to_collision_map
; Advance first_cell_in_row_screen_address by one row and reset cell_screen_address
    lda first_cell_in_row_screen_address_low
    adc #<(cells_per_character_row * rows_per_cell)                   ; C is clear because beq above not taken
    sta first_cell_in_row_screen_address_low
    sta cell_screen_address_low
    lda first_cell_in_row_screen_address_high
    adc #>(cells_per_character_row * rows_per_cell)
    sta first_cell_in_row_screen_address_high
    sta cell_screen_address_high
    bcc row_copy_loop                                                 ; ALWAYS branch
.now_write_to_collision_map
    ldx cell_x
    ldy cell_y
    lda value_to_write_to_collision_map
    bmi skip_writing_to_collision_map
    jsr write_value_to_a_rectangle_of_cells_in_collision_map
.skip_writing_to_collision_map
    pla
    rts

; cell_screen_address = screen_base_address + Y*$140 + X*8
.get_screen_address_from_cell_xy
    lda #0
    sta cell_screen_address_low
    sty cell_screen_address_high
    tya
    lsr a
    ror cell_screen_address_low
    lsr a
    ror cell_screen_address_low
    adc cell_screen_address_high
    tay
    txa
    asl a
    asl a
    asl a
    bcc skip_high_byte2
    iny
    clc
.skip_high_byte2
    adc cell_screen_address_low
    sta cell_screen_address_low
    tya
    adc screen_base_address_high
    ldy cell_screen_address_high
    sta cell_screen_address_high
    rts

.draw_right_facing_wall_local
    jmp draw_right_facing_wall

.draw_left_wall_local
    jmp draw_left_wall

; TODO: This is called from level-specific machine code, e.g. see dataA.asm
; *************************************************************************************
; 
; Once the rocks of the room have been drawn, this function carves the floor, wall and
; ceiling tiles into the rock.
; 
; *************************************************************************************
.draw_floor_walls_and_ceiling_around_solid_rock
    lda #collision_map_solid_rock
    sta default_collision_map_option
; Y is loop counter over cell rows
    ldy #game_area_height_cells - 1
; X is loop counter over cell columns
.draw_rows_loop
    ldx #screen_width_minus_one
.draw_columns_loop
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    bne next_cell_over
    inx
    jsr read_collision_map_value_for_xy
    dex
    cmp #collision_map_solid_rock
    bne draw_right_facing_wall_local
    dex
    jsr read_collision_map_value_for_xy
    inx
    cmp #collision_map_solid_rock
    bne draw_left_wall_local
    dey
    jsr read_collision_map_value_for_xy
    iny
    cmp #collision_map_solid_rock
    bne draw_floor
    iny
    jsr read_collision_map_value_for_xy
    dey
    cmp #collision_map_solid_rock
    bne draw_ceiling
.next_cell_over
    dex
    bpl draw_columns_loop
    dey
    bpl draw_rows_loop
    rts

; *************************************************************************************
; 
; Draw floor
; 
; On Entry:
;     (X,Y): cell coordinates
; 
; *************************************************************************************
.draw_floor
    sty cell_y                                                        ; remember Y
    dey
    jsr get_screen_address_from_cell_xy
; find tile index based on the cellX: tile index=(cellX AND 3)*2
    txa
    and #3
    asl a
    asl a
    asl a
    asl a
; add address of first floor tile
    clc
    adc #<tile_floor0_top
    sta off_screen_address_low
    lda #0
    adc #>tile_floor0_top
    sta off_screen_address_high
; copy tile lower six rows to screen
    ldy #7
.draw_floor_top_loop
    lda (off_screen_address_low),y
    sta (cell_screen_address_low),y
    dey
    cpy #2
    bcs draw_floor_top_loop
; off_screen_address += bytes_per_cell
    lda off_screen_address_low
    clc
    adc #<bytes_per_cell
    sta off_screen_address_low
    lda off_screen_address_high
    adc #>bytes_per_cell
    sta off_screen_address_high
    lda cell_screen_address_low
; cell_screen_address += bytes_per_character_row
    clc
    adc #<bytes_per_character_row
    sta cell_screen_address_low
    lda cell_screen_address_high
    adc #>bytes_per_character_row
    sta cell_screen_address_high

; copy tile upper 6 rows to screen
    ldy #5
.draw_floor_bottom_loop
    lda (off_screen_address_low),y
    sta (cell_screen_address_low),y
    dey
    bpl draw_floor_bottom_loop
; restore Y
    ldy cell_y
    jmp next_cell_over

; *************************************************************************************
; 
; Draw ceiling
; 
; On Entry:
;     (X,Y): cell coordinates
; 
; *************************************************************************************
.draw_ceiling
    jsr get_screen_address_from_cell_xy
    txa
    and #3
    asl a
    asl a
    asl a
    clc
    adc #<tile_ceiling0
    sta off_screen_address_low
    lda #0
    adc #>tile_ceiling0
    sta off_screen_address_high
    sty cell_y
    ldy #7
.copy_ceiling_tile_loop
    lda (off_screen_address_low),y
    sta (cell_screen_address_low),y
    dey
    cpy #2
    bcs copy_ceiling_tile_loop
    ldy cell_y
    jmp next_cell_over

; *************************************************************************************
; 
; Draw right facing wall, including corner pieces. Entry at .draw_right_facing_wall
; Draw left facing wall, including corner pieces. Entry at .draw_left_wall
; 
; On Entry:
; (X,Y): cell coordinates
; 
; *************************************************************************************
.draw_right_facing_wall
    lda #%11000000
    sta wall_mask
    jmp find_spriteid
.draw_left_wall
    lda #%00000011
    sta wall_mask
.find_spriteid
    jsr find_corner_spriteid
    beq normal_wall_not_corner
; draw corner sprite
    bit wall_mask
    bvc is_left_wall1
    lda #&ff
    sta sprite_reflect_flag
    lda sprite_id
    inx
    jsr draw_sprite_a_at_cell_xy
    dex
    jmp continue1
.is_left_wall1
    jsr draw_sprite_a_at_cell_xy
.continue1
    jmp move_up_and_across_to_check_if_wall_continues
; no corner found, so the cell Y position is used to determine the tile to use
.normal_wall_not_corner
    tya
; find the tile to use based on tile base address + (cellY and 3)*8
    and #3
    asl a
    asl a
    asl a
    bit wall_mask
    bvc use_left_wall
    adc #(tile_wall_right0 - tile_wall_left0)
.use_left_wall
    adc #<tile_wall_left0
    sta off_screen_address_low
    lda #0
    adc #>tile_wall_left0
    sta off_screen_address_high
    ldy #7
.copy_wall_tile_loop
    lda (cell_screen_address_low),y
; just copy six pixels
    and wall_mask
    ora (off_screen_address_low),y
    sta (cell_screen_address_low),y
    dey
    bpl copy_wall_tile_loop
    ldy cell_y
.move_up_and_across_to_check_if_wall_continues
    bit wall_mask
    bvc is_left_wall2
    inx
    jmp continue2
.is_left_wall2
    dex
.continue2
    dey
    bmi not_top_corner
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    bne not_top_corner
    bit wall_mask
    bvc is_left_wall3
    lda #&ff
    sta sprite_reflect_flag
    lda #spriteid_corner_top_right
    jsr draw_sprite_a_at_cell_xy
    jmp continue3
.is_left_wall3
    lda #spriteid_corner_top_right
    inx
    jsr draw_sprite_a_at_cell_xy
    dex
.continue3
.not_top_corner
    iny
    iny
    cpy #game_area_height_cells
    bcs finished_wall
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    bne finished_wall
; draw final corner
    bit wall_mask
    bvc is_left_wall4
    lda #&ff
    sta sprite_reflect_flag
    lda #spriteid_corner_bottom_right
    jsr draw_sprite_a_at_cell_xy
    jmp continue4
.is_left_wall4
    lda #spriteid_corner_bottom_right
    inx
    jsr draw_sprite_a_at_cell_xy
    dex
.continue4
.finished_wall
    bit wall_mask
    bvc is_left_wall5
    dex
    jmp continue5
.is_left_wall5
    inx
.continue5
    dey
    jmp next_cell_over

.find_corner_spriteid
    lda #spriteid_corner_top_left
    sta sprite_id
    dey
    jsr read_collision_map_value_for_xy
    iny
    cmp #collision_map_solid_rock
    bne return_with_result1
    lda #spriteid_corner_bottom_left
    sta sprite_id
    iny
    jsr read_collision_map_value_for_xy
    dey
    cmp #collision_map_solid_rock
.found_corner_spriteid
    bne return_with_result1
    sty cell_y
    jsr get_screen_address_from_cell_xy
    lda #spriteid_one_pixel_masked_out
    sta sprite_id
.return_with_result1
    lda sprite_id
    rts

.tile_floor0_top
    equb %00000000
    equb %00000000
    equb %00000000
    equb %11111111
    equb %10110111
    equb %11111111
    equb %11111101
    equb %11101111
.tile_floor0_bottom
    equb %00000000
    equb %11111111
    equb %11111101
    equb %11011111
    equb %11110011
    equb %00000000
    equb %00000000
    equb %00000000
.tile_floor1_top
    equb %00000000
    equb %00000000
    equb %00001100
    equb %11110011
    equb %10111111
    equb %11111101
    equb %11101111
    equb %11111111
.tile_floor1_bottom
    equb %00000000
    equb %11111111
    equb %11111011
    equb %10111111
    equb %11111111
    equb %00000000
    equb %00000000
    equb %00000000
.tile_floor2_top
    equb %00000000
    equb %00000000
    equb %00000000
    equb %11111111
    equb %10111101
    equb %11111111
    equb %11011111
    equb %11111011
.tile_floor2_bottom
    equb %00000100
    equb %11101111
    equb %11111111
    equb %11011011
    equb %11111111
    equb %00000000
    equb %00000000
    equb %00000000
.tile_floor3_top
    equb %00000000
    equb %00000000
    equb %00100000
    equb %11011111
    equb %11110111
    equb %10111101
    equb %11101111
    equb %11111111
.tile_floor3_bottom
    equb %00000010
    equb %11111101
    equb %10111111
    equb %11111011
    equb %11101111
    equb %00000000
    equb %00000000
    equb %00000000
.tile_ceiling0
    equb %00000000
    equb %00000000
    equb %00000000
    equb %11011111
    equb %11111101
    equb %10111111
    equb %11110111
    equb %00001000
.tile_ceiling1
    equb %00000000
    equb %00000000
    equb %00000000
    equb %11111111
    equb %11111011
    equb %11011111
    equb %11110111
    equb %00000000
.tile_ceiling2
    equb %00000000
    equb %00000000
    equb %00000000
    equb %10111111
    equb %11110111
    equb %11011111
    equb %11111001
    equb %00000110
.tile_ceiling3
    equb %00000000
    equb %00000000
    equb %00000000
    equb %11101111
    equb %11111011
    equb %10111111
    equb %11111111
    equb %00000000
.tile_wall_left0
    equb %01111000
    equb %01011000
    equb %01110000
    equb %01110000
    equb %01011000
    equb %01111000
    equb %01101000
    equb %01111000
.tile_wall_left1
    equb %01111000
    equb %01101000
    equb %01111000
    equb %01011000
    equb %01111000
    equb %10111000
    equb %01101000
    equb %01111000
.tile_wall_left2
    equb %01111000
    equb %01011000
    equb %01111000
    equb %01101000
    equb %01111000
    equb %01110000
    equb %01011000
    equb %01111000
.tile_wall_left3
    equb %01101000
    equb %01111000
    equb %01111000
    equb %10111000
    equb %10101000
    equb %01111000
    equb %01011000
    equb %01111000
.tile_wall_right0
    equb %00011110
    equb %00011010
    equb %00001110
    equb %00001110
    equb %00011010
    equb %00011110
    equb %00010110
    equb %00011110
.tile_wall_right1
    equb %00011110
    equb %00010110
    equb %00011110
    equb %00011010
    equb %00011110
    equb %00011101
    equb %00010110
    equb %00011110
.tile_wall_right2
    equb %00011110
    equb %00011010
    equb %00011110
    equb %00010110
    equb %00011110
    equb %00001110
    equb %00011010
    equb %00011110
.tile_wall_right3
    equb %00010110
    equb %00011110
    equb %00011110
    equb %00011101
    equb %00010101
    equb %00011110
    equb %00011010
    equb %00011110

; TODO: This is called from e.g. data
; *************************************************************************************
; 
; Draw rope
;     The top of the rope is a rope hook, which has collision map value 3 (solid)
;     The rope itself has collision map value 2 (climbable), including the rope end
; 
; On Entry:
;     A: rope length
;     (X,Y): cell coordinates for the top of the rope
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.draw_rope
    sta temp_rope_length
    pha                                                               ; remember A,Y
    tya
    pha
; Don't draw the rope hook if Y is zero
    beq draw_rope_loop
    lda #spriteid_rope_hook
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_solid_rock
    bne write_to_collision_map
.draw_rope_loop
    lda temp_rope_length
    cmp #1
    beq draw_end_of_rope
; cycle through the rope sprites based on Y coordinate
    tya
    and #3
    clc
    adc #spriteid_rope1
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
.write_to_collision_map
    jsr write_a_single_value_to_cell_in_collision_map
    dec temp_rope_length
    iny
    cpy #game_area_height_cells
    bcc draw_rope_loop
    bcs restore_ay_and_return
.draw_end_of_rope
    lda #spriteid_rope_end
    jsr draw_sprite_a_at_cell_xy
    lda #collision_map_rope
    jsr write_a_single_value_to_cell_in_collision_map
.restore_ay_and_return
    pla                                                               ; recall A,Y
    tay
    pla
    rts

; *************************************************************************************
; 
; Clear the game area
; 
; Set all the game area pixels, and clear the collision map
; 
; *************************************************************************************
.clear_game_area
IF swr_renderer_enabled
    JSR swr_invalidate_caches
ENDIF
    lda #0
    tay
.clear_collision_map_loop
    sta collision_map,y
    iny
    cpy #collision_map_length
    bne clear_collision_map_loop
    ldy #<game_area_screen_address
    sty screen_address_low
    ldx #>game_area_screen_address
    stx screen_address_high
    lda #&ff
    ldx #>end_of_screen_memory
.clear_screen_game_area_loop
    sta (screen_address_low),y
    iny
    bne clear_screen_game_area_loop
    inc screen_address_high
    cpx screen_address_high
    bne clear_screen_game_area_loop
    rts

; *************************************************************************************
; 
; Clip the given rectangle of cells to the game area (right and bottom)
; 
; The game area is a grid of 40x24 cells.
; 
; On Entry:
;     X: Left cell X coordinate of rectangle
;     Y: Top cell X coordinate of rectangle
;     width_in_cells: Rectangle width
;     height_in_cells: Rectangle height
; 
; On Exit:
;     width_in_cells_to_write: Clipped rectangle width
;     height_in_cells_to_write: Clipped rectangle height
; 
; *************************************************************************************
.clip_cells_to_write_to_collision_map
    stx cell_x
    sty cell_y
    lda width_in_cells
    sta width_in_cells_to_write
    lda height_in_cells
    sta height_in_cells_to_write
    txa
    clc
    adc width_in_cells
    bcs clip_x
    cmp #game_area_width_cells+1
    bcc clipped_x_ok
.clip_x
    lda #game_area_width_cells
    sbc cell_x
    sta width_in_cells_to_write
.clipped_x_ok
    tya
    clc
    adc height_in_cells
    bcs clip_y
    cmp #game_area_height_cells+1
    bcc return7
.clip_y
    lda #game_area_height_cells
    sbc cell_y
    sta height_in_cells_to_write
.return7
    rts

; *************************************************************************************
; 
; Write a value to a rectangle in the collision map
; 
; On Entry:
;     value_to_write_to_collision_map: Value to write
;     X: Left cell X coordinate of rectangle
;     Y: Top cell X coordinate of rectangle
;     width_in_cells: Rectangle width
;     height_in_cells: Rectangle height
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.write_value_to_a_rectangle_of_cells_in_collision_map
    pha
    lda value_to_write_to_collision_map
    cmp #4
    bcc write_value_to_rectangle_of_collision_map
    jmp pull_and_return

; value is (0-3)
.write_value_to_rectangle_of_collision_map
    sta temp_value
.entry_for_write_a_single_value
    jsr clip_cells_to_write_to_collision_map
; multiply Y by 10 and store in temp_coordinate
    tya                                                               ; Extract method as similar in .write_value_to_a_rectangle_of_cells_in_collision_map and .read_collision_map_value_for_xy
    asl a
    sta temp_coordinate
    asl a
    asl a
    adc temp_coordinate
    sta temp_coordinate
; divide X by 4 and add the Y coordinate, and store in Y, the byte offset in the
; collision map
    txa
    lsr a
    lsr a
    clc
    adc temp_coordinate
    tay
; let X be the offset within the byte for the current cell (0-3)
    txa
    and #3
    eor #3                                                            ; Could remove by reordering the table but complicates code for looping through x
    tax
.write_to_next_column_in_collision_map_loop
    lda height_in_cells_to_write
    sta height_counter
    stx offset_within_byte

; alternative lookup
    lda bitmask_of_bits_to_keep_from_collision_map_table,x            ; find bits that will be kept from the collision map
    eor #&ff                                                          ; invert the bits to get bits to overwrite
    ldx temp_value
    and duplication_table,x                                           ; picks out the bits to write in the correct (masked) position
    ldx offset_within_byte
; store the value to write in the 'offset_within_byte' variable
    sta offset_within_byte
    sty offset_within_collision_map
.write_to_next_row_in_collision_map_loop
    lda collision_map,y                                               ; read from current collision map
    and bitmask_of_bits_to_keep_from_collision_map_table,x            ; mask out the bits for the current cell
    ora offset_within_byte                                            ; OR in the new bits for the cell
    sta collision_map,y                                               ; write the new value back to the collision map
    tya                                                               ; add 10 to Y to move to next row
    adc #10
    tay
    dec height_counter                                                ; loop counter
    bne write_to_next_row_in_collision_map_loop
    ldy offset_within_collision_map
; X is the offset within the byte to write to (0-3)
    dex
    bpl try_next_cell_across
    ldx #3                                                            ; move to next byte
    iny
.try_next_cell_across
    dec width_in_cells_to_write
    bne write_to_next_column_in_collision_map_loop
    lda temp_value
    ldx cell_x
    ldy cell_y
.pull_and_return
    pla
    rts

.duplication_table
    equb %00000000, %01010101, %10101010, %11111111
.bitmask_of_bits_to_keep_from_collision_map_table
    equb %00111111, %11001111, %11110011, %11111100

; TODO: this is used by e.g. dataA
; *************************************************************************************
; 
; Write a value to a single cell in the collision map
; Modified from original to use write to rectangle code (slower but not critical path)
; 
; On Entry:
;     A: Value to write
;     X: Cell X coordinate
;     Y: Cell Y coordinate
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.write_a_single_value_to_cell_in_collision_map
    and #3
    sta temp_value
    pha
; Rope drawing must preserve rectangle dimensions set by the level for later blocks.
    lda width_in_cells
    pha
    lda height_in_cells
    pha
    lda #1
    sta height_in_cells
    sta width_in_cells
    lda temp_value
    jsr write_single_cell_rectangle
    pla
    sta height_in_cells
    pla
    sta width_in_cells
    pla
    rts

.write_single_cell_rectangle
    pha
    jmp entry_for_write_a_single_value

; *************************************************************************************
; 
; Read a two bit value from the collision map at X,Y
; 
; On Entry:
;     (X,Y): cell position to read the collision map
; 
; On Exit:
;     A: holds value 0-3 from the collision map
; 
; *************************************************************************************
.read_collision_map_value_for_xy
    cpx #game_area_width_cells
    bcs outside_game_area
    cpy #game_area_height_cells
    bcs outside_game_area
    stx saved_x
    sty saved_y
; Set temp_value=10*Y
.retry_read_collision_map
    tya
    asl a
    sta temp_value
    asl a
    asl a
    adc temp_value
    sta temp_value
; Set Y=temp_value+X/4
    txa
    lsr a
    lsr a
    clc
    adc temp_value
    tay

    txa
    and #3
    tax
    lda collision_map,y
    jmp right_shift_a_by_2x

.right_shift_a_by_2x_loop
    lsr a
    lsr a
.right_shift_a_by_2x
    dex
    bpl right_shift_a_by_2x_loop
    ldx saved_x
    ldy saved_y
    and #3
.return8
    rts

.outside_game_area
    lda default_collision_map_option
    bpl return8
    stx saved_x
    sty saved_y
; next time, read from leftmost column
    ldx #0
    lda saved_x
    bmi retry_read_collision_map
; next time, read from rightmost column
    ldx #game_area_width_cells-1
    cmp #game_area_width_cells
    bcs retry_read_collision_map
    tax
; next time, read from topmost column
    ldy #0
    lda saved_y
    bmi retry_read_collision_map
; next time, read from bottommost column
    ldy #game_area_height_cells-1
    bne retry_read_collision_map                                      ; ALWAYS branch
; TODO: this is used by e.g. dataA
; *************************************************************************************
; 
; Draw a sprite at a cell position
; 
; On Entry:
;     A: spriteid
;     (X,Y): cell coordinates
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.draw_sprite_a_at_cell_xy
    sta sprite_id
    jsr set_sprite_pixel_position_to_cell_xy_plus_pixel_offset
    jsr sprite_op
    lda sprite_id
    rts

; TODO: This is called from e.g. dataA
; *************************************************************************************
; 
; Draw a sprite at a cell position, and write a rectangle of values into the collision
; map
; 
; On Entry:
;     A: spriteid
;     (X,Y): cell coordinates
;     value_to_write_to_collision_map: value to write
;     width_in_cells: rectangle width
;     height_in_cells: rectangle height
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.draw_sprite_a_at_cell_xy_and_write_to_collision_map
    jsr draw_sprite_a_at_cell_xy
    jmp write_value_to_a_rectangle_of_cells_in_collision_map

; TODO: this is used by e.g. dataA
; *************************************************************************************
; 
; Set object's position based on a cell XY position
; 
; On Entry:
;     A: object index
;     (X,Y): cell coordinates
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.set_object_position_from_cell_xy
    jsr set_sprite_pixel_position_to_cell_xy_plus_pixel_offset
    stx remember_x
    tax
    jsr set_object_position_from_current_sprite_position
    txa
    ldx remember_x
    rts

.remember_x
    equb 0

; *************************************************************************************
; 
; Set object position from sprite coordinates
; 
; On Entry:
;     X: object index
;     (sprite_x_base, sprite_y_base): pixel position to set
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
; TODO: this is used by e.g. dataA
.set_object_position_from_current_sprite_position
    pha
    lda sprite_x_base_low
    sta object_x_low,x
    lda sprite_x_base_high
    sta object_x_high,x
    lda sprite_y_base_low
    sta object_y_low,x
    lda sprite_y_base_high
    sta object_y_high,x
    pla
    rts

; *************************************************************************************
; 
; Set the current sprite position to a cell XY plus a pixel offset
; 
; On Entry:
;     (X,Y): cell coordinates (can be negative)
;     temp_sprite_x_offset: Add pixel offset to the result (then reset to zero on exit)
;     temp_sprite_y_offset: Add pixel offset to the result (then reset to zero on exit)
; 
; On Exit:
;     (sprite_x_base, sprite_y_base): pixel position
;     Preserves A,X,Y
; 
; *************************************************************************************
.set_sprite_pixel_position_to_cell_xy_plus_pixel_offset
    pha                                                               ; remember A,X,Y
    txa
    pha
    tya
    pha
    txa
    asl a
    asl a
    asl a
    sta sprite_x_base_low
    txa
    and #&80
    beq positive_x_cell
    lda #&ff
.positive_x_cell
    rol a
    sta sprite_x_base_high
    ldx #0
    lda temp_sprite_x_offset
    bpl positive_x_pixel
    dex
.positive_x_pixel
    clc
    adc sprite_x_base_low
    sta sprite_x_base_low
    txa
    adc sprite_x_base_high
    sta sprite_x_base_high
    tya
    asl a
    asl a
    asl a
    sta sprite_y_base_low
    tya
    and #&80
    beq positive_y_cell
    lda #&ff
.positive_y_cell
    rol a
    sta sprite_y_base_high
    ldy #0
    lda temp_sprite_y_offset
    bpl positive_y_pixel
    dey
.positive_y_pixel
    clc
    adc sprite_y_base_low
    sta sprite_y_base_low
    tya
    adc sprite_y_base_high
    sta sprite_y_base_high
    lda #0
    sta temp_sprite_x_offset
    sta temp_sprite_y_offset
    pla                                                               ; recall A,X,Y
    tay
    pla
    tax
    pla
    rts

; *************************************************************************************
; 
; Update objects
; 
; Draws and undraws objects, taking into account z-order.
; 
; The z-order values range from $00 at the front, $80 at the midpoint (where the player
; is) and $ff at the back.
; 
; Objects are (a) undrawn from front to back, then (b) redrawn from back to front.
; Objects are not redrawn if their state remains unchanged ('inactive'), unless they
; need to be because there's an active object behind them.
; 
; The algorithm used to do this is:
; 
; 1. Mark all objects as 'not dealt with'
; 2. Find the backmost object that is (a) undealt with (b) has a sprite and (c) has
; changed state ('active').
; 3. If none found (i.e. all that need to be dealt with have been), then update (copy)
; the state of the inactive objects and return.
; 4. Mark the active object as dealt with.
; 5. Append the object to a list of active objects.
; 6. Append any inactive objects that are in front of this active object. Those
; inactive objects are marked as 'dealt with'.
; 7. Goto 4 if more inactive objects were appended to the active list to deal with them
; and append anything in front of them.
; 8. Sort the active objects list from front to back.
; 9. Undraw the active objects (front to back).
; 10. Draw the active objects (back to front).
; 11. Goto 2.
; 
; Object state is stored in 'object_*' memory locations, and the state of the
; previously drawn objects is in 'object_*_old' memory locations.
; 
; *************************************************************************************
.update_objects
    lda player_held_object_spriteid
    pha
    lda #0
    sta player_held_object_spriteid
; mark all objects as 'not dealt with' yet
    lda #0
    tax
.reset_object_dealt_with_flags_loop
    sta object_dealt_with_flag,x
    inx
    cpx #max_objects
    bcc reset_object_dealt_with_flags_loop
; find the object that is at the back
.find_backmost_object_not_dealt_with_yet
    ldx #0
    stx num_active_objects
    stx temp_active_object_index
; initialise the backmost object index to be $ff (nothing found yet), and at the front
; (z-order $00)
    lda #&ff
    sta backmost_object_index
    stx backmost_object_z_order
.find_backmost_object_loop
    lda object_dealt_with_flag,x
    bne try_next_object
; object doesn't count if it has no sprites
    lda object_spriteid,x
    ora object_spriteid_old,x
    beq try_next_object
; check object X z-order against the best so far
    lda object_z_order,x
    cmp backmost_object_z_order
    bcc try_next_object
; found new backmost object, store it's index and z-order
    sta backmost_object_z_order
    stx backmost_object_index
.try_next_object
    inx
    cpx #max_objects
    bcc find_backmost_object_loop
; check if we found a backmost object
    ldx backmost_object_index
    bpl found_backmost_object
; after dealing with all active objects, update the state of the inactive ones
    ldx #max_objects-1
.update_non_active_object_state_loop
    lda object_dealt_with_flag,x
    bne skip_objects_already_dealt_with
    jsr copy_object_state_to_old
.skip_objects_already_dealt_with
    dex
    bpl update_non_active_object_state_loop
; restore the player held object
    pla
    sta player_held_object_spriteid
    rts

.found_backmost_object
    lda #&ff                                                          ; mark object as dealt with
    sta object_dealt_with_flag,x
; Look for active objects. If the object hasn't changed state, move to the next object
    jsr has_object_changed_state
    beq find_backmost_object_not_dealt_with_yet
; append the active object to the active_objects_table
    txa
    ldx num_active_objects
    sta active_objects_table,x
    inc num_active_objects
.process_active_objects_loop
    ldx temp_active_object_index
    ldy active_objects_table,x
    sty backmost_object_index
    lda object_z_order,y
    sta backmost_object_z_order

; this whole next section looks for any inactive objects that (a) are in front of and
; (b) intersect with the latest active object. These are added to the active object
; list too. This determines the drawing order.
    ldx #0
.loop_over_all_objects_x
    txa
; find inactive objects. i.e. if object x is found in the active objects table, skip it
; and try the next object
    ldy #0
.find_object_y_loop
    cmp active_objects_table,y
    beq move_to_next_object_x
    iny
    cpy num_active_objects
    bcc find_object_y_loop
; found an inactive object x. If it's in front of the backmost active object, test it
; for collision
    lda object_z_order,x
    cmp backmost_object_z_order
    bcc test_for_collision
; to resolve equal z orders, look at the index. i.e. if the object x has the same z
; order as the backmost active object and a smaller index, also test for collision.
    bne move_to_next_object_x
    cpx backmost_object_index
    bcs move_to_next_object_x
.test_for_collision
    stx temp_object_index
    txa
    clc
    adc #max_objects
    tax
    ldy backmost_object_index
    jsr test_for_collision_between_objects_x_and_y
    bne found_collision
    tya
    clc
    adc #max_objects
    tay
    jsr test_for_collision_between_objects_x_and_y
    ldx temp_object_index
    ora #0
    beq move_to_next_object_x
.found_collision
    ldx temp_object_index
; mark object x as dealt with
    lda #&ff
    sta object_dealt_with_flag,x
; append to the active objects list
    txa
    ldx num_active_objects
    sta active_objects_table,x
    inc num_active_objects
    tax
.move_to_next_object_x
    inx
    cpx #max_objects
    bcc loop_over_all_objects_x
    inc temp_active_object_index
    lda temp_active_object_index
    cmp num_active_objects
    bcc process_active_objects_loop

; sort active objects, frontmost first
    lda #0
    sta temp_active_object_index
.sort_objects_loop
    lda #&ff
    sta backmost_object_index
    sta backmost_object_z_order

; now find the frontmost of the active objects
    ldx #0
.inner_object_loop
    ldy active_objects_table,x
    bmi move_to_next_active_object
    lda object_z_order,y
    cmp backmost_object_z_order
    bcc found_an_object_further_front
    bne move_to_next_active_object
    cpy backmost_object_index
    bcs move_to_next_active_object
.found_an_object_further_front
    sty backmost_object_index
    sta backmost_object_z_order
    stx temp_object_index
.move_to_next_active_object
    inx
    cpx num_active_objects
    bcc inner_object_loop

; mark object as done
    ldx temp_object_index
    lda #&ff
    sta active_objects_table,x
; record frontmost object in table
    ldx temp_active_object_index
    lda backmost_object_index
    sta frontmost_objects_table,x
    inx
    stx temp_active_object_index
    cpx num_active_objects
    bcc sort_objects_loop

; undraw objects from front to back
IF swr_renderer_enabled
IF swr_frame_alignment_enabled
    jsr swr_align_player_group
ENDIF
ENDIF
    ldy #0
.undraw_loop
    lda frontmost_objects_table,y
    tax
    jsr undraw_object_x
    iny
    cpy num_active_objects
    bcc undraw_loop

; draw objects from back to front (aka 'painters algorithm')
    dey
.draw_loop
    lda frontmost_objects_table,y
    tax
    jsr draw_object_x
    jsr copy_object_state_to_old
    dey
    bpl draw_loop
    jmp find_backmost_object_not_dealt_with_yet

IF swr_renderer_enabled
IF swr_frame_alignment_enabled
INCLUDE "src/swr_frame_alignment.asm"
ENDIF
ENDIF

; *************************************************************************************
; 
; Once an object is drawn to the screen, this remembers the current object state in
; '_old' variables. We use this later to detect whether the object state has changed
; and to undraw if needed.
; 
; On Entry:
;     X: object index
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.copy_object_state_to_old
    pha
    lda object_x_low,x
    sta object_x_low_old,x
    lda object_x_high,x
    sta object_x_high_old,x
    lda object_y_low,x
    sta object_y_low_old,x
    lda object_y_high,x
    sta object_y_high_old,x
    lda object_spriteid,x
    sta object_spriteid_old,x
    lda object_direction,x
    sta object_direction_old,x
    pla
    rts

.has_object_changed_state
    lda #&ff
    pha
    lda object_x_low,x
    cmp object_x_low_old,x
    bne pull_result_and_return
    lda object_x_high,x
    cmp object_x_high_old,x
    bne pull_result_and_return
    lda object_y_low,x
    cmp object_y_low_old,x
    bne pull_result_and_return
    lda object_y_high,x
    cmp object_y_high_old,x
    bne pull_result_and_return
    lda object_spriteid,x
    cmp object_spriteid_old,x
    bne pull_result_and_return
    lda object_direction,x
    cmp object_direction_old,x
    bne pull_result_and_return
    pla
    lda #0
    pha
.pull_result_and_return
    pla
    rts

.undraw_object_x
    tya
    pha
; exit if object is not visible
    lda object_spriteid_old,x
    beq done_drawing_object
; prepare to draw sprite
    lda object_x_low_old,x
    sta sprite_x_base_low
    lda object_x_high_old,x
    sta sprite_x_base_high
    lda object_y_low_old,x
    sta sprite_y_base_low
    lda object_y_high_old,x
    sta sprite_y_base_high
    lda object_direction_old,x
    sta sprite_reflect_flag
; based on object_erase_type:
; 
;     00 means erase to bg colour,
;     ff means erase to fg colour,
;     otherwise erase by drawing an 'erase' spriteid
    lda object_erase_type,x
    beq erase_object_to_bg_colour
    cmp #&ff
    beq erase_object_to_fg_colour
    ldy #sprite_op_flags_normal
    beq draw_or_erase_object                                          ; ALWAYS branch
.erase_object_to_bg_colour
    lda object_spriteid_old,x
    ldy #sprite_op_flags_erase_to_bg_colour
    bne draw_or_erase_object                                          ; ALWAYS branch
.erase_object_to_fg_colour
    lda object_spriteid_old,x
    ldy #sprite_op_flags_erase_to_fg_colour
.draw_or_erase_object
    sta sprite_id
    sty sprite_op_flags
IF swr_renderer_enabled
    STX swr_owner
ENDIF
    jsr sprite_op
.done_drawing_object
    pla
    tay
    rts

.draw_object_x
    lda object_spriteid,x
    beq return9
    lda object_x_low,x
    sta sprite_x_base_low
    lda object_x_high,x
    sta sprite_x_base_high
    lda object_y_low,x
    sta sprite_y_base_low
    lda object_y_high,x
    sta sprite_y_base_high
    lda object_direction,x
    sta sprite_reflect_flag
    lda object_spriteid,x
    sta sprite_id
    lda #sprite_op_flags_normal
    sta sprite_op_flags
; The object_erase_type determines the sprite operation:
; 
;     $00: draw normally
;     $ff: draw normally
;     other value S: copy what's on screen to this destination spriteid (used when
; erasing)
; 
    lda object_erase_type,x
    beq draw_object_sprite
    cmp #&ff
    beq draw_object_sprite
    sta dest_sprite_id
    lda #sprite_op_flags_erase_to_bg_colour OR sprite_op_flags_copy_screen
    sta sprite_op_flags
.draw_object_sprite
IF swr_renderer_enabled
    STX swr_owner
ENDIF
    jsr sprite_op
; return if not the player accessory object
    cpx #objectid_player_accessory
    bne return9
; return if current player character is not the wizard
    lda current_player_character
    cmp #spriteid_icodata_wizard
    bne return9
; special wizard processing - if the player is carrying an accessory object, draw the
; wizard's hand in front of that
    stx remember_player_accessory_object_index
    ldx #objectid_player
; check if player state has changed
    jsr has_object_changed_state
    ldx remember_player_accessory_object_index
    ora #0
    beq player_state_unchanged
; make sure the player has been dealt with first
    lda object_dealt_with_flag
    beq return9
.player_state_unchanged
    lda object_direction,x
    sta sprite_reflect_flag
    lda #sprite_op_flags_normal
    sta sprite_op_flags
    lda #spriteid_wizard_hand
    sta sprite_id
    jsr sprite_op
.return9
    rts

.set_player_spriteid_and_offset_from_animation_table
    stx animation_address_low                                         ; store YX as animation table address
    sty animation_address_high
; load byte at offset A from table, the spriteid
    tay
    lda (animation_address_low),y
    sta object_spriteid
; check if we should add offset x
    iny
    lda player_wall_collision_reaction_speed
    bne skip8
; load next byte from table, the X offset
    lda (animation_address_low),y
; invert offset if direction is reversed
    ldx object_direction
    bpl add_movement_in_direction_to_player
; invert A if direction is left
    eor #&ff
    clc
    adc #1
; add offset in X to player position
.add_movement_in_direction_to_player
    ldx #0
    ora #0
    bpl skip7
    dex
.skip7
    clc
    adc object_x_low
    sta object_x_low
    txa
    adc object_x_high
    sta object_x_high
.skip8
    iny
; load next byte from table, the Y offset
    ldx #0
    lda (animation_address_low),y
    bpl skip9
    dex
; add offset in Y to player position
.skip9
    clc
    adc object_y_low
    sta object_y_low
    txa
    adc object_y_high
    sta object_y_high
    rts

; *************************************************************************************
; 
; Update player accessory object animation
; 
; The player is object zero, and can have an associated 'accessory' object at index
; one. This is often a tail, but otherwise can be an object the wizard is carrying
; (e.g. the whip)
; 
; On Entry:
;                     A: if top bit clear, it's a spriteid
;                        if top bit set, lower 7 bits are the offset into sprite array
;                    YX: Address of main sprite list
;     animation_address: accessory sprite list
; 
; *************************************************************************************
.update_player_accessory_object_animation
    stx temp_sprite_list_low
    sty temp_sprite_list_high
    ldy #0
    ora #0
    bpl store_accessory_object_state
    and #&7f
    tay
    lda (animation_address_low),y
    cpy #&7f
    bne store_accessory_object_state
; check for end of animation (loop if needed)
    ldy object_current_index_in_animation+1
    iny
    lda (animation_address_low),y
    bne store_accessory_object_state
    ldy #0
    lda (animation_address_low),y
.store_accessory_object_state
    sty object_current_index_in_animation+1
    sta object_spriteid + objectid_player_accessory
    lda object_direction
    sta object_direction + objectid_player_accessory
    lda object_spriteid
; add animation XY offset to player object position (inverted if looking left)
    jsr find_sprite_xy_offset_from_spriteid
    txa
    ldx object_direction
    bpl skip_invert_a
    eor #&ff
    clc
    adc #1
.skip_invert_a
    ldx #0
    ora #0
    bpl skip_decrement_high_byte1
    dex
.skip_decrement_high_byte1
    clc
    adc object_x_low
    sta object_x_low + objectid_player_accessory
    txa
    adc object_x_high
    sta object_x_high + objectid_player_accessory
    ldx #0
    tya
    bpl skip_decrement_high_byte2
    dex
.skip_decrement_high_byte2
    clc
    adc object_y_low
    sta object_y_low + objectid_player_accessory
    txa
    adc object_y_high
    sta object_y_high + objectid_player_accessory
    rts

; *************************************************************************************
; 
; Find the offset X,Y for a sprite in a list
; 
; On Entry:
;     A: spriteid to search for
;     temp_animation: address of list to search
; 
; On Exit:
;     X: X pixel offset from animation
;     Y: Y pixel offset from animation
; 
; *************************************************************************************
.find_sprite_xy_offset_from_spriteid
    sta temp_spriteid
    ldy #0
    beq start_search                                                  ; ALWAYS branch
.list_search_loop
    cmp temp_spriteid
    beq found_entry_in_list
    iny
    iny
    iny
.start_search
    lda (temp_sprite_list_low),y
    bne list_search_loop
    ldx #0
    ldy #0
    rts

.found_entry_in_list
    iny
    lda (temp_sprite_list_low),y
    tax
    iny
    lda (temp_sprite_list_low),y
    tay
    rts

; *************************************************************************************
; 
; Update player
; 
; *************************************************************************************
.update_player
    lda current_player_character
    beq update_mid_transformation_local
    cmp #spriteid_icodata_wizard
    beq update_wizard_local
    cmp #spriteid_icodata_cat
    beq update_cat_local
    cmp #spriteid_icodata_monkey
    beq update_monkey_local
.jmp_for_update_extra_player_character
    jmp return10                                                      ; could just 'rts'? But maybe the bird modifies this code...?

.update_mid_transformation_local
    jmp update_mid_transformation

.update_wizard_local
    jmp update_wizard

.update_cat_local
    jmp update_cat

.update_monkey_local
    jmp update_monkey

.return10
    rts

.transform_out_animation
    equb 0

; *************************************************************************************
; 
; Set the base animation address for the current player type and handle any transform
; in/out
; 
; On Entry:
;     XY: Address of start of animation data for the current player type
;     A: Offset into animation data to read (usually three for the next animation step,
; since each animation step takes three bytes)
; 
; On Exit:
;     Y: set to the current offset of player animation
;     A: (for zero flag) $FF if transform in/out is in progress, $00 otherwise
; 
; *************************************************************************************
.set_base_animation_address_and_handle_transform_in_out
    stx animation_address_low
    sty animation_address_high
; read next entry in animation
    clc
    adc object_current_index_in_animation
    tay
    lda (animation_address_low),y
; branch if not at the end of the animation
    bne not_at_end_of_animation
; restart the animation
    ldy current_player_animation
; check for 'transform in' animation
.not_at_end_of_animation
    lda current_player_animation
    bne not_the_transform_in_animation
    tya
    bne transforming
    jsr start_of_transform_in_animation
; check for 'transform out' animation
.not_the_transform_in_animation
    lda current_player_animation
    cmp transform_out_animation
    bne not_transforming_out
    cpy current_player_animation
    bne transforming
; start the 'transform in' animation, having finished the 'transform out'
    lda #0
    sta current_player_animation
    sta object_current_index_in_animation
    sta current_player_character
; stack shenanigans: remove the latest return address from the stack to restart the
; calling function
    pla
    pla
    jmp update_player

.not_transforming_out
    lda current_player_character
    cmp new_player_character
    beq not_transforming
; start 'transform out' animation
    ldy transform_out_animation
    sty current_player_animation
.transforming
    lda #&ff
    rts

.not_transforming
    lda #0
    rts

; *************************************************************************************
; 
; Transform the player into a new form.
; 
; On Entry:
;     A: spriteid of player character to transform into
; 
; *************************************************************************************
.transform
    sta new_player_character
    lda #0
    sta player_wall_collision_reaction_speed
    sta player_held_object_spriteid
; if the current menu item is to the left of the player characters, then we have just
; loaded a level or something, so don't play the transform sounds.
    lda new_menu_index
    cmp menu_index_for_first_player_character
    bcc return11
; play transform sounds with priority
    lda #&ff
    ldx #<sound_data2
    ldy #>sound_data2
    jsr play_sound_yx
    ldx #<sound_data3
    ldy #>sound_data3
    jsr play_sound_yx
.return11
    rts

.start_of_transform_in_animation
    lda #osbyte_flush_buffer
    ldx #buffer_sound_channel_0
    jsr osbyte                                                        ; Flush sound channel 0 (X=4)
    lda #0
    sta sound_priority_per_channel_table
    sta sound_priority_per_channel_table + 1
    sta player_wall_collision_reaction_speed
    rts

.handle_player_landing_sound
    lda object_spriteid
    and object_spriteid_old
    beq return12
    lda #2
    sta temp_bottom_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    beq return12
; wall collision found. if player was moving down at the time, we have hit the floor
    lda object_y_low_old
    sec
    sbc object_y_low
    beq player_y_is_unchanged
    lda object_y_high_old
    sbc object_y_high
    bmi has_landed
    bpl return12                                                      ; ALWAYS branch
; check for player collision with floor
.player_y_is_unchanged
    lda object_room_collision_flags
    and #object_collided_floor
    beq return12
    lda #2
    sta temp_bottom_offset
    lda #objectid_old_player
    jsr get_solid_rock_collision_for_object_a
    bne return12
.has_landed
    jsr play_landing_sound
.return12
    rts

; TODO: this is used by e.g. dataA
.play_landing_sound
    pha                                                               ; remember A,X,Y
    txa
    pha
    tya
    pha
    lda #0
    ldx #<sound_landing1
    ldy #>sound_landing1
    jsr play_sound_yx
    ldx #<sound_landing2
    ldy #>sound_landing2
    jsr play_sound_yx
    pla                                                               ; recall A,X,Y
    tay
    pla
    tax
    pla
    rts

; *************************************************************************************
; 
; Check for player hitting the floor and deal with it.
; Check for player being pushed, and update if so.
; 
; On Exit:
;     A and flags: $00 if no collision is happening
;                  $80 if player is hitting a wall (left or right)
;                  otherwise it's a signed byte for the velocity while being pushed.
;     Preserves X,Y
; 
; *************************************************************************************
.update_player_hitting_floor_or_pushed
    txa                                                               ; remember X,Y
    pha
    tya
    pha
    lda #objectid_player
    jsr update_object_hitting_floor
; if (no player collision) then branch (return)
    lda player_wall_collision_reaction_speed
    beq recall_registers_and_return1
; if (player hit wall) then branch
    cmp #&80
    beq if_player_hit_wall_and_floor_then_clear_wall_collision_flag
; player is being pushed.
; check direction of push.
    lda player_wall_collision_reaction_speed
    bmi player_being_pushed_left
; player being pushed right
    inc temp_right_offset
    ldy #0
    beq check_for_collision_while_player_is_being_pushed              ; ALWAYS branch

.player_being_pushed_left
    dec temp_left_offset
    ldy #&ff
.check_for_collision_while_player_is_being_pushed
    lda #1
    sta temp_bottom_offset
; if no player-rock collision, then branch
    lda #objectid_player
    jsr get_solid_rock_collision_for_object_a
    beq push_continues_no_collision
; mark as a regular wall collision (no longer pushed)
    lda #&80
    sta player_wall_collision_reaction_speed
    bne if_player_hit_wall_and_floor_then_clear_wall_collision_flag   ; ALWAYS branch

.push_continues_no_collision
    lda object_has_hit_floor_flag
    beq move_player_because_of_push
    lda #0
    sta current_player_animation
.move_player_because_of_push
    ldx #1
.push_player_and_accessory_object_loop
    lda player_wall_collision_reaction_speed
    clc
    adc object_x_low,x
    sta object_x_low,x
    tya
    adc object_x_high,x
    sta object_x_high,x
    dex
    bpl push_player_and_accessory_object_loop
; if no collision, or a push, branch (return)
.if_player_hit_wall_and_floor_then_clear_wall_collision_flag
    lda player_wall_collision_reaction_speed
    cmp #&80
    bne recall_registers_and_return1
; if not hit floor, then branch
    lda object_has_hit_floor_flag
    beq recall_registers_and_return1
    lda #0
    sta player_wall_collision_reaction_speed
.recall_registers_and_return1
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda player_wall_collision_reaction_speed
    rts

.player_wall_collision_reaction_speed
    equb 0

; *************************************************************************************
; 
; Find the left and right extents of the object
; 
; Returns both the left and right Y coordinate of the object (found using the object
; position, sprite offset, current sprite width, and object direction).
; It also returns cell based versions of these two coordinates.
; 
; As input, pixel based 'temporary' offsets can be added to the result. 'Temporary'
; because they are zeroed on exit.
; 
; On Entry:
;                        X: the object index to look at
;         temp_left_offset: offset to add to result (zeroed on exit)
;        temp_right_offset: offset to add to result (zeroed on exit)
; 
; On Exit:
;              object_left: Set to object's position X + sprite offset
;             object_right: Set to object's position X + sprite offset + sprite width
;       object_left_cell_x: Cell X for object_left
;      object_right_cell_x: Cell X for object_right
;      Preserves X
; 
; *************************************************************************************
.find_left_and_right_of_object
    txa
; remember object index
    pha
    lda object_spriteid,x
; get address of current sprite for object
    jsr get_address_of_sprite_a
    stx sprite_addr_low
    sty sprite_addr_high
; recall object index
    pla
    tax
; read the sprite's X offset
    ldy #0
    lda (sprite_addr_low),y
; add sprite Y offset to object position (or if looking left, subtract the sprite Y
; offset), then store in object_left.
    ldy object_direction,x
    bpl got_signed_offset_in_a_so_sign_extend_to_y
    eor #&ff
.got_signed_offset_in_a_so_sign_extend_to_y
    ldy #0
    ora #0
    bpl add_ya_to_object_x_position
    dey
.add_ya_to_object_x_position
    clc                                                               ; update address1 based on sprite offset
    adc object_x_low,x
    sta object_left_low
    tya
    adc object_x_high,x
    sta object_left_high
; get sprite width
    ldy #2
    lda (sprite_addr_low),y
; add sprite width-1 to address1 if looking right, or subtract if looking left storing
; result in object_right
    sec
    sbc #1
    ldy object_direction,x
    bmi subtract_sprite_width
    clc
    adc object_left_low
    sta object_right_low
    lda #0
    adc object_left_high
    sta object_right_high
    jmp add_temporary_offsets

; subtract sprite width
.subtract_sprite_width
    sta object_right_high
    lda object_left_low
    sta object_right_low
    sec
    sbc object_right_high
    sta object_left_low
    lda object_left_high
    sta object_right_high
    sbc #0
    sta object_left_high
.add_temporary_offsets
    ldy #0
; add temporary left offset to object left position
    lda temp_left_offset
    bpl add_ya_to_object_left
    dey
.add_ya_to_object_left
    clc
    adc object_left_low
    sta object_left_low
    sta object_left_cell_x
    tya
    adc object_left_high
    sta object_left_high
; divide by eight to get cell left position
    lsr a
    ror object_left_cell_x
    lsr a
    ror object_left_cell_x
    lsr a
    ror object_left_cell_x
    ldy #0
; add temporary right offset to object right position
    lda temp_right_offset
    bpl add_ya_to_object_right
    dey
.add_ya_to_object_right
    clc
    adc object_right_low
    sta object_right_low
    sta object_right_cell_x
    tya
    adc object_right_high
    sta object_right_high
; divide by eight to get cell right position
    lsr a
    ror object_right_cell_x
    lsr a
    ror object_right_cell_x
    lsr a
    ror object_right_cell_x
    lda #0
    sta temp_left_offset
    sta temp_right_offset
    rts

.temp_left_offset
    equb 0
.temp_right_offset
    equb 0

; *************************************************************************************
; 
; Find the top and bottom extents of the object
; 
; Returns both the top and bottom Y coordinate of the object (found using the object
; position, sprite offset and current sprite height).
; It also returns cell based versions of these two coordinates.
; 
; As input, pixel based 'temporary' offsets can be added to the result. 'Temporary'
; because they are zeroed on exit.
; 
; On Entry:
;                        X: the object index to look at
;          temp_top_offset: offset to add to result (zeroed on exit)
;       temp_bottom_offset: offset to add to result (zeroed on exit)
; 
; On Exit:
;               object_top: Set to object's position Y + sprite offset - sprite height
;            object_bottom: Set to object's position Y + sprite offset
;        object_top_cell_y: Cell Y for object_top
;     object_bottom_cell_y: Cell Y for object_bottom
; 
; *************************************************************************************
.find_top_and_bottom_of_object
    txa
; remember object index
    pha
; get address of current sprite for object
    lda object_spriteid,x
    jsr get_address_of_sprite_a
    stx sprite_addr_low
    sty sprite_addr_high
; recall object index
    pla
    tax
; get sprite Y offset
    ldy #1
    lda (sprite_addr_low),y
; add sprite Y offset to object position, store in object_bottom
    ldy #0
    ora #0
    bpl add_ya_to_object_bottom1
    dey
.add_ya_to_object_bottom1
    clc
    adc object_y_low,x
    sta object_bottom_low
    tya
    adc object_y_high,x
    sta object_bottom_high
; read sprite height
    ldy #3
    lda (sprite_addr_low),y
; store sprite height minus one
    sec
    sbc #1
    sta object_top_low
; subtract (sprite height Y minus one) to get object_top
    lda object_bottom_low
    sec
    sbc object_top_low
    sta object_top_low
    lda object_bottom_high
    sbc #0
    sta object_top_high
    ldy #0
; add temporary signed offset to object_top
    lda temp_top_offset
    bpl add_ya_to_object_top
    dey
.add_ya_to_object_top
    clc
    adc object_top_low
    sta object_top_low
    sta object_top_cell_y
    tya
    adc object_top_high
    sta object_top_high
; divide the bottom pixel coordinate by eight to get the cell Y
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    ldy #0
; add temporary signed offset to object_bottom
    lda temp_bottom_offset
    bpl add_ya_to_object_bottom2
    dey
.add_ya_to_object_bottom2
    clc
    adc object_bottom_low
    sta object_bottom_low
    sta object_bottom_cell_y
    tya
    adc object_bottom_high
    sta object_bottom_high
; divide the bottom pixel coordinate by eight to get the cell Y
    lsr a
    ror object_bottom_cell_y
    lsr a
    ror object_bottom_cell_y
    lsr a
    ror object_bottom_cell_y
; zero the temporary offsets
    lda #0
    sta temp_top_offset
    sta temp_bottom_offset
    rts

.temp_top_offset
    equb 0
.temp_bottom_offset
    equb 0

.adjust_left_or_right_extent_due_to_holding_an_object
    cpx #objectid_player                                              ; Look for X=0 or X=11
    beq got_a_player_object
    cpx #objectid_old_player
    bne return_zeroing_offsets
; if (player is not holding an object) then return
.got_a_player_object
    lda player_held_object_spriteid
    beq return_zeroing_offsets
; get spriteid of object being held
    inx
    lda object_spriteid,x
    dex
; if (object being held has no sprite) then return
    ora #0
    beq return_zeroing_offsets
    inx
; remember old object_left and object_right coordinates (four bytes)
    ldy #3
.copy_coordinates_loop
    lda object_left_low,y
    sta old_object_left_low,y
    dey
    bpl copy_coordinates_loop
; remember old left and right cell coordinates
    lda object_left_cell_x
    sta old_object_left_cell
    lda object_right_cell_x
    sta old_object_right_cell
; get held object's left/right extents
    jsr find_left_and_right_of_object
    lda object_direction,x
    bpl looking_right
; looking left. If held object's left is larger than the old left, then use the old
; coordinates
    lda object_left_low
    sec
    sbc old_object_left_low
    lda object_left_high
    sbc old_object_left_high
    bpl reset_old_values_back_into_object_left_and_right
; use the held object's left coordinate
    lda object_left_low
    sta old_object_left_low
    lda object_left_high
    sta old_object_left_high
    lda object_left_cell_x
    sta old_object_left_cell
    jmp reset_old_values_back_into_object_left_and_right

; looking right. If held object's right is smaller or equal to the old right, then use
; the old coordinates
.looking_right
    lda old_object_right_low
    sec
    sbc object_right_low
    lda old_object_right_high
    sbc object_right_high
    bpl reset_old_values_back_into_object_left_and_right
; use the held object's right coordinate
    lda object_right_low
    sta old_object_right_low
    lda object_right_high
    sta old_object_right_high
    lda object_right_cell_x
    sta old_object_right_cell
.reset_old_values_back_into_object_left_and_right
    ldy #3
.reset_coordinates_loop
    lda old_object_left_low,y
    sta object_left_low,y
    dey
    bpl reset_coordinates_loop
    lda old_object_left_cell
    sta object_left_cell_x
    lda old_object_right_cell
    sta object_right_cell_x
    dex
.return_zeroing_offsets
    lda #0
    sta temp_left_offset
    sta temp_right_offset
    rts

; remember temp_left and right offsets, since we will use them again to find the
; attached object's left/right extents
.find_left_and_right_of_object_including_held_object
    lda temp_left_offset
    pha
    lda temp_right_offset
    pha
    jsr find_left_and_right_of_object
    pla
    sta temp_right_offset
    pla
    sta temp_left_offset
    jmp adjust_left_or_right_extent_due_to_holding_an_object

; *************************************************************************************
.update_object_a_solid_rock_collision
    sta objectid_to_test
    tax
; clear collision flags
    lda #0
    sta object_room_collision_flags,x
; anything outside the game area returns collision map value $ff
    lda #&ff
    sta default_collision_map_option
; raise from the floor one pixel
    lda #1
    sta temp_bottom_offset
; find extents of object and check for wall collisions
    ldx objectid_to_test
    jsr find_left_and_right_of_object_including_held_object
    lda objectid_to_test
    clc
    adc #max_objects
    tax
    jsr find_top_and_bottom_of_object
    jsr check_for_object_intersecting_wall_left_or_right
; if (no collisions left or right) then branch
    lda object_hit_wall_on_left_result_flag
    ora object_hit_wall_on_right_result_flag
    beq check_top_and_bottom_for_collisions
    lda objectid_to_test
    clc
    adc #max_objects
    tax
    jsr find_left_and_right_of_object_including_held_object
.check_top_and_bottom_for_collisions
    lda #1
    sta temp_bottom_offset
    ldx objectid_to_test
    jsr find_top_and_bottom_of_object
    jsr check_for_object_intersecting_floor_or_ceiling
    jsr update_floor_or_ceiling_collision
    lda object_hit_wall_on_left_result_flag
    ora object_hit_wall_on_right_result_flag
    beq finished_collision_update
; handle wall collision
    lda #1
    sta temp_bottom_offset
    ldx objectid_to_test
    jsr find_left_and_right_of_object_including_held_object
    jsr find_top_and_bottom_of_object
    jsr check_for_object_intersecting_wall_left_or_right
    jsr handle_left_right_wall_collision
.finished_collision_update
    lda objectid_to_test
    bne return13
; player specific update
    jsr update_player_accessory_including_toolbar
    jsr handle_player_landing_sound
.return13
    rts

; *************************************************************************************
; 
; Check for object intersecting wall to the left or right
; 
; On Entry:
;     The cell based extents of the object have been worked out previously:
;           object_left_cell_x
;          object_right_cell_x
;            object_top_cell_y
;         object_bottom_cell_y
; 
; On Exit:
;      object_hit_wall_on_left_result_flag: Flag set ($ff) if object is intersecting
; wall on the left side of the object
;     object_hit_wall_on_right_result_flag: Flag set ($ff) if intersecting wall on the
; right side of the object
; 
; *************************************************************************************
.check_for_object_intersecting_wall_left_or_right
    lda #&ff
    sta object_hit_wall_on_left_result_flag
; store objects's cell height
    ldx object_left_cell_x
    ldy object_bottom_cell_y
    tya
    sec
    sbc object_top_cell_y
    sta object_height_in_cells
; look at collision map at each cell up the object's height, looking for a solid wall
.loop_up_object_cells_looking_for_solid_wall
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    beq found_wall_on_objects_left_side
    dey
    dec object_height_in_cells
    bpl loop_up_object_cells_looking_for_solid_wall
; mark that no collision was found on the left side
    inc object_hit_wall_on_left_result_flag
.found_wall_on_objects_left_side
    lda #&ff
    sta object_hit_wall_on_right_result_flag
; store object's cell height (again)
    ldx object_right_cell_x
    ldy object_bottom_cell_y
    tya
    sec
    sbc object_top_cell_y
    sta object_height_in_cells
; look at collision map at each cell up the object's height, looking for a solid wall
.read_cells_in_column_loop
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    beq return14
    dey
    dec object_height_in_cells
    bpl read_cells_in_column_loop
; mark that no collision was found on the right side
    inc object_hit_wall_on_right_result_flag
.return14
    rts

; *************************************************************************************
; 
; If colliding with a wall, line up next to the wall instead of going through it.
; 
; On Entry:
;     objectid_to_test: object index to test
; 
; *************************************************************************************
.handle_left_right_wall_collision
    ldx objectid_to_test
    lda object_hit_wall_on_left_result_flag
    cmp object_hit_wall_on_right_result_flag
    beq return15
    bcc object_has_hit_wall_on_right_side
; object has hit wall on left side. Adjust object position to align with the cell next
; to the wall.
    lda object_left_low
    and #7
    sta adjustment
    lda #8
    sec
    sbc adjustment
    clc
    adc object_x_low,x
    sta object_x_low,x
    lda #0
    adc object_x_high,x
    sta object_x_high,x
; mark object has collided with left wall
    lda object_room_collision_flags,x
    ora #object_collided_left_wall
    sta object_room_collision_flags,x
    jmp return15

; object has hit wall on right side. Adjust object position to align with the cell next
; to the wall.
.object_has_hit_wall_on_right_side
    lda object_right_low
    and #7
    clc
    adc #1
    sta adjustment
    lda object_x_low,x
    sec
    sbc adjustment
    sta object_x_low,x
    lda object_x_high,x
    sbc #0
    sta object_x_high,x
; mark object has collided with right wall
    lda object_room_collision_flags,x
    ora #object_collided_right_wall
    sta object_room_collision_flags,x
.return15
    rts

; *************************************************************************************
; 
; Check for object intersecting floor or ceiling of the room
; 
; On Entry:
;     The cell based extents of the object have been worked out previously:
;           object_left_cell_x
;          object_right_cell_x
;            object_top_cell_y
;         object_bottom_cell_y
; 
; On Exit:
;       object_hit_floor_result_flag: $ff if hit, $00 otherwise
;     object_hit_ceiling_result_flag: $ff if hit, $00 otherwise
; 
; *************************************************************************************
.check_for_object_intersecting_floor_or_ceiling
    lda #&ff
    sta object_hit_ceiling_result_flag
; start at top right
    ldy object_top_cell_y
; get object width in cells
    ldx object_right_cell_x
    txa
    sec
    sbc object_left_cell_x
    sta object_width_in_cells
; loop from top right to top left looking for a solid_rock
.look_for_solid_rock_along_object_top_edge_loop
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    beq found_solid_rock
    dex
    dec object_width_in_cells
    bpl look_for_solid_rock_along_object_top_edge_loop
; no collision with top edge of object
    inc object_hit_ceiling_result_flag
.found_solid_rock
    lda #&ff
    sta object_hit_floor_result_flag
; start at bottom right
    ldy object_bottom_cell_y
; get object width in cells (again)
    ldx object_right_cell_x
    txa
    sec
    sbc object_left_cell_x
    sta object_width_in_cells
.look_for_solid_rock_along_object_bottom_edge_loop
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    beq return16
    dex
    dec object_width_in_cells
    bpl look_for_solid_rock_along_object_bottom_edge_loop
; no collision with bottom edge of object
    inc object_hit_floor_result_flag
.return16
    rts

; *************************************************************************************
.update_floor_or_ceiling_collision
    ldx objectid_to_test
    lda object_hit_ceiling_result_flag
    cmp object_hit_floor_result_flag
    beq return17
    bcc object_has_hit_floor
; object has hit ceiling. Adjust object position to align with the cell below the
; ceiling.
    lda object_top_low
    and #7
    sta adjustment
    lda #8
    sec
    sbc adjustment
    clc
    adc object_y_low,x
    sta object_y_low,x
    lda #0
    adc object_y_high,x
    sta object_y_high,x
; mark object has collided with ceiling
    lda object_room_collision_flags,x
    ora #object_collided_ceiling
    sta object_room_collision_flags,x
    jmp return17

; object has hit floor. Adjust object position to align with the cell above the floor.
.object_has_hit_floor
    lda object_bottom_low
    and #7
    clc
    adc #1
    sta adjustment
    lda object_y_low,x
    sec
    sbc adjustment
    sta object_y_low,x
    lda object_y_high,x
    sbc #0
    sta object_y_high,x
; mark object has collided with floor
    lda object_room_collision_flags,x
    ora #object_collided_floor
    sta object_room_collision_flags,x
.return17
    rts

; *************************************************************************************
; 
; Check if the object is hitting the floor, and if so, deal with it
; 
; On Entry:
;     A: object id to test
; 
; On Exit:
;     object_has_hit_floor_flag and A and flags: $ff if player/object hit floor,
;                                                $00 otherwise.
;         object_just_fallen_off_edge_direction: $ff if player/object is off left edge,
;                                                $01 if off right edge,
;                                                $00 otherwise.
;        object_just_fallen_centrally_direction: $ff if player/object is off the centre
; left,
;                                                $01 if off the centre right,
;                                                $00 otherwise.
; 
; *************************************************************************************
.update_object_hitting_floor
    sta objectid_to_test
    txa                                                               ; remember X,Y
    pha
    tya
    pha
; check collision of object with room
    ldx objectid_to_test
    jsr find_left_and_right_of_object_including_held_object
    lda #2
    sta temp_bottom_offset
    jsr find_top_and_bottom_of_object
; don't write values to the collision map
    lda #&ff
    sta default_collision_map_option
; have we hit the floor?
    jsr check_for_object_intersecting_floor_or_ceiling
; clear 'just fallen off' table
    lda #0
    sta object_just_fallen_off_edge_direction
    sta object_just_fallen_centrally_direction
; if (object hit floor) then branch
    lda object_hit_floor_result_flag
    sta object_has_hit_floor_flag
    bne object_hit_floor
    jmp recall_registers_and_return2

.object_hit_floor
    lda object_left_cell_x
    sta temp_object_left_cell
    lda object_right_cell_x
    sta temp_object_right_cell
    ldx objectid_to_test
; find the left/right extents of object without the accessory object
    jsr find_left_and_right_of_object
; add one to the right pixel extent
    lda object_right_low
    clc
    adc #1
    sta object_right_low
    lda object_right_high
    adc #0
    sta object_right_high
; sum the left and right extents
    lda object_left_low
    clc
    adc object_right_low
    sta sum_of_left_and_right_extents_low
    lda object_left_high
    adc object_right_high
    sta sum_of_left_and_right_extents_high
; restore original left right cells
    lda temp_object_left_cell
    sta object_left_cell_x
    lda temp_object_right_cell
    sta object_right_cell_x
; set y to be the bottom cell (later we'll get a value from the collision map)
    ldy object_bottom_cell_y
; To see if the object should fall, the idea here is to look at the cell below the
; object, 3/4 of the way to the left. Calculating 3/4 of the way along is done by
; calculating (2L+(L+R))/4 = (3L+R)/4 = (3/4)L + (1/4)R
; the result is rounded, so that we look at two adjacent cells based on the rounding.
; First double the left extent, and add to the sum of left and right extents...
    asl object_left_low
    rol object_left_high
    lda sum_of_left_and_right_extents_low
    clc
    adc object_left_low
    sta object_top_cell_y
    lda sum_of_left_and_right_extents_high
    adc object_left_high
; ...then divide by four...
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    tax
; ...and round the result
    lda object_top_cell_y
    sbc #0
    sta object_top_cell_y
    txa
    sbc #0
    jsr check_for_solid_rock_along_a_row_of_cells1
    bne check_for_solid_rock_under_object_to_right
; object has fallen off the edge to the left
    dec object_just_fallen_off_edge_direction
    bne object_has_fallen_off_either_edge                             ; ALWAYS branch
; solid rock was found three quarters to the left, now check three quarters right.
; This is similar to above code, starting with: Double the right extent, and add to the
; sum of left and right extents...
.check_for_solid_rock_under_object_to_right
    asl object_right_low
    rol object_right_high
    lda sum_of_left_and_right_extents_low
    clc
    adc object_right_low
    sta object_top_cell_y
    lda sum_of_left_and_right_extents_high
    adc object_right_high
; ...then divide by four...
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
; check cells for solid rock
    jsr check_for_solid_rock_along_a_row_of_cells2
    bne recall_registers_and_return2
; object has fallen off the edge to the right
    inc object_just_fallen_off_edge_direction
.object_has_fallen_off_either_edge
    lda objectid_to_test
    beq check_cell_centre_below_player
    cmp #objectid_old_player
    bne recall_registers_and_return2
; divide the sum by two to find the centre position
.check_cell_centre_below_player
    lsr sum_of_left_and_right_extents_high
    ror sum_of_left_and_right_extents_low
; round result
    lda sum_of_left_and_right_extents_low
    sbc #0
    sta object_top_cell_y
    lda sum_of_left_and_right_extents_high
    sbc #0
; check cells for solid rock
    jsr check_for_solid_rock_along_a_row_of_cells1
    bne check_object_supported_to_centre_left
; object fallen more centrally to the left
    dec object_just_fallen_centrally_direction
    bne recall_registers_and_return2
.check_object_supported_to_centre_left
    lda sum_of_left_and_right_extents_low
    sta object_top_cell_y
    lda sum_of_left_and_right_extents_high
; check cells for solid rock
    jsr check_for_solid_rock_along_a_row_of_cells2
    bne recall_registers_and_return2
; object fallen more centrally to the right
    inc object_just_fallen_centrally_direction
.recall_registers_and_return2
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda object_has_hit_floor_flag
    rts

; *************************************************************************************
; 
; Read the collision cells along a row, looking for solid rock anywhere.
; Pixel position is the right extent of the row.
; 
; On Entry:
;     (A, object_top_cell_y): the right extent of the row (pixel X coordinate)
;                          Y: cell Y coordinate to check
;         object_left_cell_x: the left extent of the row (cell X coordinate)
; 
; On Exit:
;     Zero flag: result is non-zero if solid rock found
; 
; *************************************************************************************
; divide the pixel coordinate by eight
.check_for_solid_rock_along_a_row_of_cells1
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
; find width in cells of the row to check (this will be our loop counter)
    ldx object_top_cell_y
    txa
    sec
    sbc object_left_cell_x
    sta cell_based_loop_counter
    jmp cell_row_loop

; *************************************************************************************
; 
; Read the collision cells along a row, looking for solid rock anywhere.
; Pixel position is the left extent of the row.
; 
; On Entry:
;     (A, object_top_cell_y): the left extent of the row (pixel X coordinate)
;                          Y: cell Y coordinate to check
;        object_right_cell_x: the right extent of the row (cell X coordinate)
; 
; On Exit:
;     Zero flag: result is non-zero if solid rock found
; 
; *************************************************************************************
; divide the pixel coordinate by eight
.check_for_solid_rock_along_a_row_of_cells2
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
    lsr a
    ror object_top_cell_y
; find width in cells of the row to check (this will be our loop counter)
    ldx object_right_cell_x
    txa
    sec
    sbc object_top_cell_y
    sta cell_based_loop_counter
.cell_row_loop
    jsr read_collision_map_value_for_xy
    cmp #collision_map_solid_rock
    beq return_with_flags
    dex
    dec cell_based_loop_counter
    bpl cell_row_loop
; no solid rock found
    lda #0
.return_with_flags
    ora #0
    rts

.object_has_hit_floor_flag
    equb 0
.object_just_fallen_off_edge_direction
    equb 0
.object_just_fallen_centrally_direction
    equb 0
.sum_of_left_and_right_extents_low
    equb 0
.sum_of_left_and_right_extents_high
    equb 0

; *************************************************************************************
; 
; Get solid_rock collision flags for object
; 
; On Entry:
;                        A: object index
;         temp_left_offset: offset to add to result (zeroed on exit)
;        temp_right_offset: offset to add to result (zeroed on exit)
;          temp_top_offset: offset to add to result (zeroed on exit)
;       temp_bottom_offset: offset to add to result (zeroed on exit)
; 
; 
; On Exit:
;     A: A=1 means object collided with left wall
;        A=2 means object collided with floor
;        A=4 means object collided with right wall
;        A=8 means object collided with ceiling
;     Flags reflect A on exit.
; 
; *************************************************************************************
; TODO: this is used by e.g. dataA
.get_solid_rock_collision_for_object_a
    sta temp_collision_result
    txa                                                               ; remember X,Y
    pha
    tya
    pha
    ldx temp_collision_result
    jsr find_left_and_right_of_object_including_held_object
    jsr find_top_and_bottom_of_object
    lda temp_default_collision_map_option
    sta default_collision_map_option
    jsr check_for_object_intersecting_wall_left_or_right
    jsr check_for_object_intersecting_floor_or_ceiling
    lda object_hit_wall_on_left_result_flag
    and #1
    sta temp_collision_result
    lda object_hit_wall_on_right_result_flag
    and #4
    ora temp_collision_result
    sta temp_collision_result
    lda object_hit_ceiling_result_flag
    and #8
    ora temp_collision_result
    sta temp_collision_result
    lda object_hit_floor_result_flag
    and #2
    ora temp_collision_result
    sta temp_collision_result
    lda #collision_map_none
    sta temp_default_collision_map_option
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda temp_collision_result
    rts

.temp_default_collision_map_option
    equb collision_map_none

; TODO: this is used by e.g. dataA
; *************************************************************************************
; 
; Test for a collision between two objects
; 
; Calculate if the bounding boxes of the two objects overlap.
; 
; On Entry:
;     X, Y: The object indexes of two objects to test
; 
; On Exit:
;     A: $ff if collision occcurs, else $00
;     flags: reflect value in A
;     Preserves X,Y
; 
; *************************************************************************************
.test_for_collision_between_objects_x_and_y                                                              ; Could introduce caching of extents if know called from main loop only (since loops over all pairs)
    txa                                                               ; remember X,Y
    pha
    tya
    pha
    lda #0
    sta temp_collision_result
; make sure we have sprites for both objects X and Y
    lda object_spriteid,x
    beq return_restoring_registers
    lda object_spriteid,y
    beq return_restoring_registers
    jsr find_top_and_bottom_of_object
; Test the cheaper vertical extents first, before looking up horizontal extents.
; Remember top/bottom for object X (four bytes).
    ldx #3
.copy_vertical_extents_loop
    lda object_top_low,x
    sta x_object_top_low,x
    dex
    bpl copy_vertical_extents_loop
; retrieve index for second object (was in Y on entry), and put in X register
    pla
    pha
    tax
    jsr find_top_and_bottom_of_object
    lda x_object_bottom_low
    sec
    sbc object_top_low
    lda x_object_bottom_high
    sbc object_top_high
    bmi return_restoring_registers
    lda object_bottom_low
    sec
    sbc x_object_top_low
    lda object_bottom_high
    sbc x_object_top_high
    bmi return_restoring_registers
; Vertical overlap: retrieve the first object index below saved Y on the stack.
    tsx
    lda &0102,x
    tax
    jsr find_left_and_right_of_object_including_held_object
    ldx #3
.copy_horizontal_extents_loop
    lda object_left_low,x
    sta x_object_left_low,x
    dex
    bpl copy_horizontal_extents_loop
    pla
    pha
    tax
    jsr find_left_and_right_of_object_including_held_object
    lda x_object_right_low
    sec
    sbc object_left_low
    lda x_object_right_high
    sbc object_left_high
    bmi return_restoring_registers
    lda object_right_low
    sec
    sbc x_object_left_low
    lda object_right_high
    sbc x_object_left_high
    bmi return_restoring_registers
; there is an overlap
    dec temp_collision_result
.return_restoring_registers
    lda #0
    sta temp_top_offset
    sta temp_bottom_offset
    sta temp_right_offset
    sta temp_left_offset
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda temp_collision_result
    rts

.temp_collision_result
    equb 0

.desired_menu_slots
    equb spriteid_icodata_disc
    equb spriteid_icodata_sound
    equb spriteid_icodata_password
    equb spriteid_icodata_info
    equb 0
    equb spriteid_icodata_cat
    equb spriteid_icodata_monkey
    equb spriteid_icodata_wizard
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0

.menu_index_for_first_player_character
    equb 5

; The 'extra' menu items are level specific items after the player character items
.menu_index_for_extra_items
    equb 9

.displayed_menu_slots
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; *************************************************************************************
; 
; Reset menu items to defaults
; 
; *************************************************************************************
.reset_menu_items
    ldx #9                                                            ; set standard set as nine menu items (including separators)
    stx menu_index_for_extra_items
; clear desired slots from slot eight upwards
    dex
    lda #0
.clear_extra_menu_slots_loop
    sta desired_menu_slots,x
    inx
    cpx #&11
    bcc clear_extra_menu_slots_loop
; clear table of level specific collectables
    ldx #3
.clear_collectables_loop
    sta toolbar_collectable_spriteids+1,x
    dex
    bpl clear_collectables_loop
; set new menu position
    lda menu_index_for_first_player_character
    clc
    adc #2
    sta new_menu_index
    rts

.draw_toolbar
    jsr draw_menu_icons
    jmp apply_new_menu_index

; *************************************************************************************
; 
; Update menu items (redrawing them if needed)
; 
; *************************************************************************************
.draw_menu_icons
    ldx #0
; check to see if menu icon has changed since last drawn
.draw_menu_icon_loop
    lda desired_menu_slots,x
    cmp displayed_menu_slots,x
    beq draw_next_menu_slot
; if the current icon to be redrawn shows the hand pointer, we unplot the hand pointer
; first, draw the new icon, then redraw the hand after
    lda #0
    sta redraw_menu_pointer_flag
    cpx current_menu_index
    bne menu_pointer_not_present_on_slot
    dec redraw_menu_pointer_flag
    jsr unplot_menu_pointer
; draw the new menu icon
.menu_pointer_not_present_on_slot
    jsr plot_menu_item
    lda redraw_menu_pointer_flag
    beq draw_next_menu_slot
; If there's a blank under the pointer in the new menu, bump the pointer left until we
; find a non-blank slot.
.find_valid_menu_slot_loop
    ldy new_menu_index
    lda desired_menu_slots,y
    bne new_menu_index_valid
    dec new_menu_index
    bne find_valid_menu_slot_loop
.new_menu_index_valid
    jsr plot_menu_pointer
.draw_next_menu_slot
    inx
    cpx #menu_slot_count
    bcc draw_menu_icon_loop
    rts

.redraw_menu_pointer_flag
    equb 0

.apply_new_menu_index
    lda new_menu_index
    cmp current_menu_index
    beq return18
    jsr unplot_menu_pointer
    jsr plot_menu_pointer
.return18
    rts

; *************************************************************************************
; 
; Unplot Menu Hand Pointer
; 
; *************************************************************************************
.unplot_menu_pointer
    ldx current_menu_index
    bmi no_menu_item_selected
; remember currrent screen base address
    lda screen_base_address_high
    pha
; select toolbar area for drawing
    lda #>toolbar_screen_address
    sta screen_base_address_high
; find position of current menu item
    jsr calculate_sprite_position_for_menu_item
; erase the hand
    lda #spriteid_pointer_hand
    sta sprite_id
    lda #sprite_op_flags_erase_to_bg_colour
    sta sprite_op_flags
    jsr sprite_op
; restore the background tile where the fingertip overlaps the tile
    lda #spriteid_fingertip_tile_restoration
    sta sprite_id
    lda #sprite_op_flags_normal
    sta sprite_op_flags
    jsr sprite_op
; restore original screen base address
    pla
    sta screen_base_address_high
.no_menu_item_selected
    lda #&ff
    sta current_menu_index
    rts

; *************************************************************************************
; 
; Plot Menu Hand Pointer
; 
; *************************************************************************************
.plot_menu_pointer
    ldx new_menu_index
    bmi record_the_new_menu_item
; remember currrent screen base address
    lda screen_base_address_high
    pha
; select toolbar area for drawing
    lda #>toolbar_screen_address
    sta screen_base_address_high
; find position of current menu item
    jsr calculate_sprite_position_for_menu_item
; draw the hand
    lda #spriteid_pointer_hand
    sta sprite_id
    lda #sprite_op_flags_normal
    sta sprite_op_flags
    jsr sprite_op
; restore original screen base address
    pla
    sta screen_base_address_high
.record_the_new_menu_item
    lda new_menu_index
    sta current_menu_index
    rts

.update_menus
    ldx timingA_counter_low
    ldy timingA_counter_high
    jsr wait_for_timer_2_using_yx
    jsr draw_toolbar
    jsr check_menu_keys
    lda developer_mode_sideways_ram_is_set_up_flag
    beq skip_developer_escape_key_handling
    lda developer_flags
    and #1
    beq skip_developer_escape_key_handling
    ldx #inkey_key_escape
    jsr negative_inkey
    beq skip_developer_escape_key_handling
    pla
    pla
    pla
    pla
    jmp reset_game_because_escape_pressed

.skip_developer_escape_key_handling
    lda new_menu_index
    sta old_menu_index
    jsr apply_pending_menu_motion
    lda new_menu_index
    cmp old_menu_index
    beq not_changing_menu_position
    jsr remove_dialog
    jmp no_space_bar_pressed

.not_changing_menu_position
    lda space_flag2
    beq no_space_bar_pressed
    jsr check_for_one_of_first_four_menu_items_chosen
    jsr check_if_player_character_menu_item_chosen
    jsr check_for_extra_menu_item_chosen
.no_space_bar_pressed
    lda new_menu_index
    cmp menu_index_for_first_player_character
    bcs over_a_player_character_or_later_on_menu
    lda old_menu_index
    cmp menu_index_for_first_player_character
    bcc update_menu_with_game_paused
    lda #osbyte_flush_buffer_class
    ldx #0
    jsr osbyte                                                        ; Flush all buffers (X=0)
    ldx #3
    lda #0
.clear_sound_priorities_loop2
    sta sound_priority_per_channel_table,x
    dex
    bpl clear_sound_priorities_loop2
.update_menu_with_game_paused
    jsr wait_for_timingB_counter
    jsr update_password_dialog
    jsr update_disc_menu
    lda developer_flags
    and #1
    beq skip_developer_shift_key_handling
    ldx #inkey_key_shift
    jsr negative_inkey
    bne shift_key_detected
.skip_developer_shift_key_handling
    jsr wait_for_vsync
    jmp update_menus

.shift_key_detected
    jsr read_player_movement_keys
; wait for a bit to slow down the gameplay/animation for debugging purposes
    ldx #&80
    ldy #0
.delay_loop1
    dey
    bne delay_loop1
    dex
    bne delay_loop1
    jmp return19

.over_a_player_character_or_later_on_menu
    lda old_menu_index
    cmp menu_index_for_first_player_character
    bcs return19
    jsr read_player_movement_keys
    jsr update_main_keys
.return19
    rts

.check_for_one_of_first_four_menu_items_chosen
    ldx new_menu_index
    cpx menu_index_for_first_player_character
    bcs return20
    lda desired_menu_slots,x
    cmp #spriteid_icodata_info
    beq show_level_info_dialog_local
    cmp #spriteid_icodata_password
    beq show_password_entry_dialog_local
    cmp #spriteid_icodata_sound
    beq toggle_sound_on_off
    cmp #spriteid_icodata_disc
    beq toggle_load_save_dialog_local
.return20
    rts

.show_level_info_dialog_local
    jmp show_level_info_dialog

.show_password_entry_dialog_local
    jmp show_password_entry_dialog

.toggle_load_save_dialog_local
    jmp toggle_load_save_dialog

.toggle_sound_on_off
    jsr calculate_sprite_position_for_menu_item
    lda sound_enable_flag                                             ; remember current sound flag
    pha
    lda #&ff                                                          ; temporarily enable sound
    sta sound_enable_flag
    lda #0                                                            ; play brief tick sound
    ldx #<sound_data1
    ldy #>sound_data1
    jsr play_sound_yx
    pla                                                               ; recall current sound flag
    eor #&ff                                                          ; toggle current flag
    sta sound_enable_flag                                             ; save new sound flag
    lda #spriteid_one_pixel_set
    sta sprite_id
    lda screen_base_address_high
    pha
    lda #>toolbar_screen_address
    sta screen_base_address_high
    lda #sprite_op_flags_normal
    ldx sound_enable_flag
    bne set_normal_or_erase_mode
    lda #sprite_op_flags_erase_to_bg_colour
.set_normal_or_erase_mode
    sta sprite_op_flags
    jsr sprite_op
    pla
    sta screen_base_address_high
    rts

.check_if_player_character_menu_item_chosen
    ldx new_menu_index                                                ; check menu item is in the player character range
    cpx menu_index_for_first_player_character
    bcc return21
    cpx menu_index_for_extra_items
    bcs return21
; return if transforming-out
    lda current_player_character
    cmp new_player_character
    bne return21
; return if transforming-in
    lda current_player_animation
    beq return21
    lda #0
    sta player_held_object_spriteid
; return if we are already this player character
    lda desired_menu_slots,x
    cmp current_player_character
    beq return21
; reduce number of transformations left and execute transformation
    jsr decrement_current_transformations_remaining
; branch if zero transformations were remaining before attempted decrement
    bcc return21
    jsr update_displayed_transformations_remaining
    jsr transform
.return21
    rts

.check_for_extra_menu_item_chosen
    ldx new_menu_index
    cpx menu_index_for_extra_items
    bcc return22
    lda current_player_character
    cmp #spriteid_icodata_wizard
    bne return22
    cmp new_player_character
    bne return22
    lda current_player_animation
    beq return22
    lda desired_menu_slots,x
    cmp player_held_object_spriteid
    bne skip6
    lda #0
.skip6
    sta player_held_object_spriteid
.return22
    rts

; *************************************************************************************
; 
; Insert a player character menu item into the toolbar
; 
; *************************************************************************************
.insert_character_menu_item_into_toolbar
    sta menu_item_to_use                                              ; remember menu item to insert
; flag that nothing has changed yet
    lda #0
    sta menu_has_changed_flag
; start at first player character, and loop until we reach the extras or we find the
; character
    ldx menu_index_for_first_player_character
.find_existing_item_loop
    lda desired_menu_slots,x
    cmp menu_item_to_use
    beq return_with_flag_set_if_item_inserted
    inx
    cpx menu_index_for_extra_items
    bcc find_existing_item_loop
; shuffle existing items right to make room for the new item
    ldx #menu_slot_count - 1
    lda desired_menu_slots,x
    bne return_with_flag_set_if_item_inserted
.shuffle_menu_items_right_loop
    lda desired_menu_slots-1,x
    sta desired_menu_slots,x
    dex
    cpx menu_index_for_extra_items
    bcs shuffle_menu_items_right_loop
; the start of the 'extra' menu items is now one to the right
    inc menu_index_for_extra_items
; store the new item
    lda menu_item_to_use
    sta desired_menu_slots,x
; flag that the menu has changed
    dec menu_has_changed_flag
.return_with_flag_set_if_item_inserted
    lda menu_has_changed_flag
    rts

; *************************************************************************************
; 
; Find or append menu item onto toolbar
; 
; Find an existing menu slot containing A, or fill the lowest empty slot if one hasn't
; been found yet. Only 'extra' slots are considered after the standard set, and there
; are no gaps beyond this point until the end of the menu.
; 
; On Exit:
;     A=0 if matching slot found or no match found and no empty slot available,
;     A=$ff if empty slot found and filled with the entry value of A.
;     X is the index of the slot.
;     Flags reflect A on exit.
; 
; I am not sure the 'no empty slot and no match' behaviour is terribly sensible, but it
; should never actually happen.
; 
; *************************************************************************************
.find_or_create_menu_slot_for_A
    sta menu_item_to_use
    lda #0
    sta menu_has_changed_flag
    ldx menu_index_for_extra_items
.find_slot_loop
    lda desired_menu_slots,x
    beq empty_slot_found
    cmp menu_item_to_use
    beq matching_slot_found_or_no_empty_slot
    inx
    cpx #menu_slot_count
    bcc find_slot_loop
    bcs matching_slot_found_or_no_empty_slot
.empty_slot_found
    lda menu_item_to_use
    sta desired_menu_slots,x
    dec menu_has_changed_flag
.matching_slot_found_or_no_empty_slot
    lda menu_has_changed_flag
    rts

; *************************************************************************************
; 
; Remove a menu item from the toolbar
; 
; On Entry:
;     A: menu item to remove
; 
; On Exit:
;     Preserves Y
; 
; *************************************************************************************
.remove_item_from_toolbar_menu
    sta menu_item_to_use                                              ; remember item to remove
; flag that nothing has changed yet
    lda #0
    sta menu_has_changed_flag
; set X to the start index for non-standard menu items
    ldx menu_index_for_extra_items
.find_menu_item_loop
    lda desired_menu_slots,x
    cmp menu_item_to_use
    beq shuffle_menu_items_left_loop
    inx
    cpx #menu_slot_count
    bcc find_menu_item_loop
    bcs return_with_flag_set_if_shuffled_left                         ; ALWAYS branch
; shuffle menu items left
.shuffle_menu_items_left_loop
    lda desired_menu_slots+1,x
    sta desired_menu_slots,x
    inx
    cpx #menu_slot_count - 1
    bcc shuffle_menu_items_left_loop
; make final menu slot empty
    lda #0
    sta desired_menu_slots,x
    dec menu_has_changed_flag
.return_with_flag_set_if_shuffled_left
    lda menu_has_changed_flag
    rts

; *************************************************************************************
; 
; Plot menu item
; 
; On Entry:
;     X: index of menu item to plot
; 
; On Exit:
;     Preserves A,X,Y
; 
; *************************************************************************************
.plot_menu_item
    pha                                                               ; remember A,X,Y
    txa
    pha
    tya
    pha
; Save the current screen_base_address_high so we can temporarily set it to $58 to plot
; the menu icon. This just saving the old value because it's tidy/safe. We could just
; do lda #blah:sta screen_base_address_high at the end of this routine.
    lda screen_base_address_high
    pha
    lda #>toolbar_screen_address
    sta screen_base_address_high
    jsr calculate_sprite_position_for_menu_item
    lda #sprite_op_flags_normal
    sta sprite_op_flags
    lda #spriteid_icon_background
    sta sprite_id
    lda desired_menu_slots,x
    sta displayed_menu_slots,x
    bne plot_menu_item_sprites
; erase where menu item used to be
    lda #sprite_op_flags_erase_to_bg_colour
    sta sprite_op_flags
    jsr sprite_op
    jmp restore_variables_and_return

; draw background sprite
.plot_menu_item_sprites
    jsr sprite_op
; draw icon sprite
    sta sprite_id
    jsr sprite_op
.restore_variables_and_return
    pla
    sta screen_base_address_high
    pla                                                               ; recall A,X,Y
    tay
    pla
    tax
    pla
    rts

; *************************************************************************************
; 
; Calculate the position of a menu item
; 
; Calculate the X position of the toolbar menu item: 37 + index*20
; 
; On Entry:
;     X: index of menu index
; On Exit:
;     Preserves X
; 
; *************************************************************************************
.calculate_sprite_position_for_menu_item
    txa
    pha
    lda #37
    sta sprite_y_base_low
    lda #0
    sta sprite_x_base_high
    sta sprite_y_base_high
    lda #0
    cpx #0
    beq finished_multiply
.multiply_x_by_twenty_loop
    clc
    adc #20
    bcc skip_increment_high_byte
    inc sprite_x_base_high
.skip_increment_high_byte
    dex
    bne multiply_x_by_twenty_loop
.finished_multiply
    sta sprite_x_base_low
    pla
    tax
    rts

.apply_pending_menu_motion
    ldx new_menu_index
    lda left_right_flag_pending
    beq no_menu_motion
    bmi menu_left_pending
.menu_right_pending
    inx
    cpx #&11
    bcs no_menu_motion
    lda desired_menu_slots,x
    beq menu_right_pending
    stx new_menu_index
    bne no_menu_motion                                                ; ALWAYS branch
.menu_left_pending
    dex
    bmi no_menu_motion
    lda desired_menu_slots,x
    beq menu_left_pending
    stx new_menu_index
.no_menu_motion
    jmp apply_new_menu_index

; Decrement current_transformations_remaining by one, unless it's already zero. Leading
; digits are handled specially so they turn into spaces rather than zeroes. Carry is
; clear on exit iff the value was zero on entry.
.decrement_current_transformations_remaining
    pha
    lda current_transformations_remaining
    clc
    adc current_transformations_remaining+1
    cmp #' ' + '0'
    clc
    beq decrement_current_transformations_remaining_pla_rts
    dec current_transformations_remaining
    lda current_transformations_remaining
    cmp #'0'
    bcs decrement_current_transformations_remaining_no_borrow
    lda #'9'
    sta current_transformations_remaining
    dec current_transformations_remaining+1
    lda current_transformations_remaining+1
    cmp #'0'
    beq decrement_current_transformations_remaining_middle_digit_now_zero
    bcs decrement_current_transformations_remaining_no_borrow
    lda #'9'
    sta current_transformations_remaining+1
    dec current_transformations_remaining+2
    lda current_transformations_remaining+2
    cmp #'0'
    bne decrement_current_transformations_remaining_no_borrow
    lda #' '
    sta current_transformations_remaining+2
    bne decrement_current_transformations_remaining_no_borrow
.decrement_current_transformations_remaining_middle_digit_now_zero
    lda current_transformations_remaining+2
    cmp #' '
    bne decrement_current_transformations_remaining_no_borrow
    sta current_transformations_remaining+1
.decrement_current_transformations_remaining_no_borrow
    sec
.decrement_current_transformations_remaining_pla_rts
    pla
    rts

; *************************************************************************************
; 
; Animation code
; 
; *************************************************************************************
.wizard_sprite_list
    equb             spriteid_wizard1,     2,   &f8
    equb             spriteid_wizard2,     4,   &f7
    equb             spriteid_wizard3,     2,   &f8
    equb             spriteid_wizard4,     0,   &f7
    equb             spriteid_wizard5,     3,   &f5
    equb             spriteid_wizard7,     2,   &f7
    equb spriteid_wizard_using_object,     4,   &f6
    equb                            0
.wizard_base_animation
.wizard_transform_in_animation
    equb                          0,       0,     0
    equb spriteid_wizard_transform2,       0,     0
    equb spriteid_wizard_transform2,       0,     0
    equb spriteid_wizard_transform1,       0,     0
    equb spriteid_wizard_transform1,       0,     0
    equb           spriteid_wizard5,       0,     0
    equb           spriteid_wizard5,       0,     0
    equb                          0
.wizard_transform_out_animation
    equb           spriteid_wizard5,       0,     0
    equb           spriteid_wizard5,       0,     0
    equb spriteid_wizard_transform1,       0,     0
    equb spriteid_wizard_transform1,       0,     0
    equb spriteid_wizard_transform2,       0,     0
    equb spriteid_wizard_transform2,       0,     0
    equb                          0
.wizard_walk_cycle_animation
    equb spriteid_wizard1,                 4,     0
    equb spriteid_wizard2,                 4,     0
    equb spriteid_wizard3,                 4,     0
    equb spriteid_wizard4,                 4,     0
    equb                0
.wizard_change_direction_animation
    equb spriteid_wizard4,                 0,     0
.wizard_change_direction_animation_last_step
    equb spriteid_wizard4,                 2,     0
    equb                0
.wizard_transition_to_standing_still_animation
    equb spriteid_wizard7,                 4,     0
    equb                0
.wizard_standing_still_animation
    equb spriteid_wizard7,                 0,     0
    equb                0
.wizard_transition_to_transforming_animation
    equb spriteid_wizard_using_object,     0,     0
    equb                                   0
.wizard_jump_animation
    equb spriteid_wizard5,                 6,   &fc
    equb spriteid_wizard5,                 6,   &fd
    equb spriteid_wizard5,                 5,   &fe
    equb spriteid_wizard5,                 5,   &ff
    equb spriteid_wizard5,                 4,     0
    equb                0
.wizard_start_to_fall_animation
    equb spriteid_wizard5,                 4,     1
    equb spriteid_wizard5,                 3,     2
    equb spriteid_wizard5,                 3,     3
    equb spriteid_wizard5,                 2,     4
    equb spriteid_wizard5,                 2,     5
    equb spriteid_wizard5,                 1,     6
    equb                0
.wizard_animation11
    equb spriteid_wizard5,                 4,     2
    equb spriteid_wizard5,                 3,     3
    equb spriteid_wizard5,                 2,     4
    equb spriteid_wizard5,                 1,     5
    equb                0
.wizard_animation12
    equb spriteid_wizard5,               &fc,     2
    equb spriteid_wizard5,               &fd,     3
    equb spriteid_wizard5,               &fe,     4
    equb spriteid_wizard5,               &ff,     5
    equb                0
.wizard_standing_fall_animation
    equb spriteid_wizard5,                 0,     1
    equb spriteid_wizard5,                 0,     2
    equb spriteid_wizard5,                 0,     3
    equb spriteid_wizard5,                 0,     4
    equb spriteid_wizard5,                 0,     5
    equb                0
.wizard_fall_continues_animation
    equb spriteid_wizard5,                 0,     7
    equb                0

.update_wizard
    lda #wizard_transform_out_animation - wizard_base_animation
    sta transform_out_animation
    ldx #<wizard_base_animation
    ldy #>wizard_base_animation
    lda #3
    jsr set_base_animation_address_and_handle_transform_in_out
; branch if transforming
    bne wizard_got_index_in_animation_local
; has the change of direction animation finished?
    cpy #wizard_change_direction_animation_last_step - wizard_base_animation
    bne wizard_not_changing_direction
; toggle player direction
    lda object_direction
    eor #&fe
    sta object_direction
    jmp wizard_got_index_in_animation

.wizard_not_changing_direction
    jsr update_player_hitting_floor_or_pushed
    bne wizard_falling
    lda current_player_animation
    cmp #wizard_jump_animation - wizard_base_animation
    bne wizard_not_jumping
; wizard is jumping
    dec temp_top_offset
; if (collided with room while jumping) then branch (fall)
    lda #0
    jsr get_solid_rock_collision_for_object_a
    bne wizard_start_to_fall
; if (jump animation has looped) then branch (fall)
    cpy #wizard_jump_animation - wizard_base_animation
    beq wizard_start_to_fall
.wizard_got_index_in_animation_local
    jmp wizard_got_index_in_animation

.wizard_start_to_fall
    lda #wizard_fall_continues_animation - wizard_base_animation
    sta current_player_animation
    ldy #wizard_start_to_fall_animation - wizard_base_animation
; if (player has hit floor) then branch
.wizard_not_jumping
    lda object_has_hit_floor_flag
    bne wizard_hits_ground
; Player is not jumping and not on the floor, so must be falling.
; if (not already falling) then branch (start falling)
    lda current_player_animation
    cmp #wizard_fall_continues_animation - wizard_base_animation
    bne wizard_falling
; if (player not hitting left or right wall) then branch (start falling)
    lda #object_collided_right_wall
    ora #object_collided_left_wall                                    ; why not just lda #5?
    and object_room_collision_flags
    beq wizard_falling
    lda #&80
    sta player_wall_collision_reaction_speed
.wizard_falling
    lda #wizard_fall_continues_animation - wizard_base_animation
    cmp current_player_animation
    beq wizard_got_index_in_animation_local
; wizard wasn't falling, but now is. It's a fall from a standing position, like through
; a trapdoor that just opened up beneath you. Also happens when being pushed.
    sta current_player_animation
    ldy #wizard_standing_fall_animation - wizard_base_animation
    jmp wizard_got_index_in_animation

.wizard_hits_ground
    ldx player_move_direction_requested
    beq wizard_standing_still
    lda #wizard_change_direction_animation - wizard_base_animation
    cpx object_direction
    bne wizard_changing_direction_or_jump_requested
    lda #wizard_walk_cycle_animation - wizard_base_animation
    ldx jump_requested
    beq wizard_changing_direction_or_jump_requested
    ldx current_player_animation
    cpx #wizard_fall_continues_animation - wizard_base_animation
    beq wizard_changing_direction_or_jump_requested
    lda #wizard_jump_animation - wizard_base_animation
.wizard_changing_direction_or_jump_requested
    cmp current_player_animation
    beq wizard_check_if_fallen_off_edge
    sta current_player_animation
    tay
    jmp wizard_check_if_fallen_off_edge

.wizard_standing_still
    lda current_player_animation
    ldy #wizard_standing_still_animation - wizard_base_animation
    sty current_player_animation
    cmp #wizard_walk_cycle_animation - wizard_base_animation
    beq wizard_transition_to_standing_still
    cmp #wizard_change_direction_animation - wizard_base_animation
    beq wizard_transition_to_standing_still
    lda jump_requested
    beq wizard_check_if_fallen_off_edge
    lda player_held_object_spriteid
    beq wizard_check_if_fallen_off_edge
    ldy #wizard_transition_to_transforming_animation - wizard_base_animation
    cmp #spriteid_menu_item_completion_spell
    bne wizard_check_if_fallen_off_edge
; transform to nothing (end of level spell)
    lda #spriteid_one_pixel_masked_out
    jsr transform
    jmp update_wizard

; transition from a walk cycle or change of direction animation to standing still
.wizard_transition_to_standing_still
    ldy #wizard_transition_to_standing_still_animation - wizard_base_animation
.wizard_check_if_fallen_off_edge
    ldx #0
; Read the 'player_just_fallen_off_edge_direction' if stationary, or the
; 'player_just_fallen_off_centrally_direction' if moving
    lda player_move_direction_requested
    beq got_index_from_direction_requested
    inx
.got_index_from_direction_requested
    lda object_just_fallen_off_edge_direction,x
    beq wizard_got_index_in_animation
    ldy #wizard_fall_continues_animation - wizard_base_animation
    sty current_player_animation
    ldy #wizard_animation11 - wizard_base_animation
    cmp object_direction
    beq wizard_got_index_in_animation
    ldy #wizard_animation12 - wizard_base_animation
.wizard_got_index_in_animation
    sty object_current_index_in_animation
    lda #0
    sta temp_collision_results
    lda player_held_object_spriteid
    beq wizard_skip_holding_object_handling
; wizard is holding an object
    ldy object_current_index_in_animation
    lda wizard_base_animation,y
    sta object_spriteid
    jsr update_player_accessory_including_toolbar
    lda #objectid_player
    jsr update_object_a_solid_rock_collision
    lda object_room_collision_flags
    sta temp_collision_results
.wizard_skip_holding_object_handling
    lda object_current_index_in_animation
; update sprite for wizard
    ldx #<wizard_base_animation
    ldy #>wizard_base_animation
    jsr set_player_spriteid_and_offset_from_animation_table
    jsr update_player_accessory_including_toolbar
; update collision
    lda #objectid_player
    jsr update_object_a_solid_rock_collision
    lda object_room_collision_flags
    ora temp_collision_results
    sta object_room_collision_flags
; Save the current value of player_using_object at previous_player_using_object
    lda player_using_object_spriteid
    sta previous_player_using_object_spriteid
; Set player_using_object_spriteid to player_held_object_spriteid if player is using an
; object, or zero otherwise.
    ldx #0
; if (the player is not using an item) then branch
    lda object_spriteid
    cmp #spriteid_wizard_using_object
    bne store_object_being_used
    lda player_held_object_spriteid
    tax
.store_object_being_used
    stx player_using_object_spriteid
    rts

.temp_collision_results
    equb 0
.player_using_object_spriteid
    equb 0
.previous_player_using_object_spriteid
    equb 0

.update_player_accessory_including_toolbar
    ldx player_held_object_spriteid
    beq store_object_held_and_return
    ldx #<wizard_sprite_list
    ldy #>wizard_sprite_list
    lda #0
    jsr update_player_accessory_object_animation
    lda player_held_object_spriteid
; find the menu index of the player accessory given its spriteid
    ldy #0
.find_menu_index_given_spriteid_loop
    cmp toolbar_collectable_spriteids,y
    beq found_menu_index
    iny
    cpy #4
    bcc find_menu_index_given_spriteid_loop
; menu index not found, give up
    ldx #0
    beq store_object_held_and_return                                  ; ALWAYS branch
.found_menu_index
    ldx collectable_being_used_spriteids,y
    lda object_spriteid
    cmp #spriteid_wizard_using_object
    beq store_object_held_and_return
    ldx collectable_spriteids,y
.store_object_held_and_return
    stx object_spriteid + objectid_player_accessory
    rts

.toolbar_collectable_spriteids
    equb 0, 0, 0, 0, 0
.collectable_spriteids
    equb 0, 0, 0, 0, 0
.collectable_being_used_spriteids
    equb 0, 0, 0, 0, 0

.cat_tail_spriteids
    equb spriteid_cat_tail1, spriteid_cat_tail2, spriteid_cat_tail3
    equb spriteid_cat_tail4, spriteid_cat_tail5, spriteid_cat_tail6
    equb spriteid_cat_tail7, spriteid_cat_tail8,                  0
.cat_sprite_list
    equb spriteid_cat_walk1,        &f9,   &f6
    equb spriteid_cat_walk2,        &f9,   &f5
    equb spriteid_cat_walk3,        &f9,   &f6
    equb spriteid_cat_walk4,        &f9,   &f5
    equb spriteid_cat_walk4,        &f9,   &f5
    equb      spriteid_cat2,        &f9,   &f5
    equb  spriteid_cat_jump,        &f9,   &f6
    equb                  0
.cat_base_animation
.cat_transform_in_animation
    equb 0, 0, 0
    equb spriteid_cat_transform2,     0,     0
    equb spriteid_cat_transform2,     0,     0
    equb spriteid_cat_transform1,     0,     0
    equb spriteid_cat_transform1,     0,     0
    equb      spriteid_cat_walk4,     0,     0
    equb      spriteid_cat_walk4,     0,     0
    equb 0
.cat_transform_out_animation
    equb      spriteid_cat_walk4,     0,     0
    equb spriteid_cat_transform1,     0,     0
    equb spriteid_cat_transform1,     0,     0
    equb spriteid_cat_transform2,     0,     0
    equb spriteid_cat_transform2,     0,     0
    equb                       0
.cat_walk_cycle_animation
    equb spriteid_cat_walk1,          4,     0
    equb spriteid_cat_walk2,          4,     0
    equb spriteid_cat_walk3,          4,     0
    equb spriteid_cat_walk4,          4,     0
    equb                  0
.cat_change_direction_animation
    equb spriteid_cat_walk4,          0,     0
.cat_change_direction_animation_last_step
    equb spriteid_cat_walk4,          2,     0
    equb                  0
.cat_transition_to_standing_still_animation
    equb spriteid_cat2,               4,     0
    equb                              0
.cat_standing_still_animation
    equb spriteid_cat2,               0,     0
    equb                              0
.cat_jump_animation
    equb spriteid_cat_jump,           6,   &fb
    equb spriteid_cat_jump,           6,   &fc
    equb spriteid_cat_jump,           5,   &fc
    equb spriteid_cat_jump,           5,   &fd
    equb spriteid_cat_jump,           5,   &fe
    equb spriteid_cat_jump,           5,   &ff
    equb                 0
.cat_jump_apex_animation
    equb spriteid_cat_jump,           5,     0
    equb spriteid_cat_jump,           5,     0
    equb                 0
.cat_start_to_fall_animation
    equb spriteid_cat_walk4,          5,     1
    equb spriteid_cat_walk4,          5,     2
    equb spriteid_cat_walk4,          4,     3
    equb spriteid_cat_walk4,          4,     4
    equb spriteid_cat_walk4,          4,     4
    equb spriteid_cat_walk4,          4,     5
    equb spriteid_cat_walk4,          3,     5
    equb spriteid_cat_walk4,          3,     5
    equb spriteid_cat_walk4,          2,     6
    equb spriteid_cat_walk4,          2,     6
    equb spriteid_cat_walk4,          1,     6
    equb spriteid_cat_walk4,          1,     6
    equb                  0
.cat_animation11
    equb spriteid_cat_walk4,          4,     2
    equb spriteid_cat_walk4,          3,     3
    equb spriteid_cat_walk4,          2,     4
    equb spriteid_cat_walk4,          1,     5
    equb                  0
.cat_animation12
    equb spriteid_cat_walk4,        &fc,     2
    equb spriteid_cat_walk4,        &fd,     3
    equb spriteid_cat_walk4,        &fe,     4
    equb spriteid_cat_walk4,        &ff,     5
    equb                  0
.cat_standing_fall_animation
    equb spriteid_cat_walk4,          0,     1
    equb spriteid_cat_walk4,          0,     2
    equb spriteid_cat_walk4,          0,     3
    equb spriteid_cat_walk4,          0,     4
    equb spriteid_cat_walk4,          0,     5
    equb                  0
.cat_fall_animation
    equb spriteid_cat_walk4,          0,     7
    equb                  0

.update_cat
    lda #cat_transform_out_animation - cat_base_animation
    sta transform_out_animation
    ldx #<cat_base_animation
    ldy #>cat_base_animation
    lda #3
    jsr set_base_animation_address_and_handle_transform_in_out
    bne cat_got_index_in_animation_local
    cpy #cat_change_direction_animation_last_step - cat_base_animation
    bne cat_not_changing_direction
; toggle player direction
    lda object_direction
    eor #&fe
    sta object_direction
    jmp cat_got_index_in_animation

.cat_not_changing_direction
    jsr update_player_hitting_floor_or_pushed
    bne cat_falling
    lda current_player_animation
    cmp #cat_jump_animation - cat_base_animation
    bne cat_not_jumping
; cat is jumping
    dec temp_top_offset
; if (collided with room while jumping) then branch (fall)
    lda #0
    jsr get_solid_rock_collision_for_object_a
    bne cat_start_to_fall
; if (jump animation has looped) then branch (fall)
    cpy #cat_jump_animation - cat_base_animation
    bne cat_got_index_in_animation_local
    lda player_move_direction_requested
    cmp object_direction
    bne cat_start_to_fall
    ldy #cat_jump_apex_animation - cat_base_animation
    sty current_player_animation
.cat_got_index_in_animation_local
    jmp cat_got_index_in_animation

.cat_not_jumping
    cmp #cat_jump_apex_animation - cat_base_animation
    bne cat_check_for_hitting_floor
    dec temp_top_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    bne cat_start_to_fall
    cpy #cat_jump_apex_animation - cat_base_animation
    bne cat_got_index_in_animation_local
.cat_start_to_fall
    lda #cat_fall_animation - cat_base_animation
    sta current_player_animation
    ldy #cat_start_to_fall_animation - cat_base_animation
; if (player has hit floor) then branch
.cat_check_for_hitting_floor
    lda object_has_hit_floor_flag
    bne cat_hits_ground
    lda current_player_animation
    cmp #cat_fall_animation - cat_base_animation
    bne cat_falling
; check player for collision with left or right wall
    lda #object_collided_right_wall
    ora #object_collided_left_wall                                    ; why not just lda #5?
    and object_room_collision_flags
    beq cat_falling
    lda #&80
    sta player_wall_collision_reaction_speed
.cat_falling
    lda #cat_fall_animation - cat_base_animation
    cmp current_player_animation
    beq cat_got_index_in_animation_local
; cat wasn't falling, but now is. It's a fall from a standing position, like through a
; trapdoor that just opened up beneath you. Also happens when being pushed.
    sta current_player_animation
    ldy #cat_standing_fall_animation - cat_base_animation
    jmp cat_got_index_in_animation

.cat_hits_ground
    ldx player_move_direction_requested
    beq cat_standing_still
    lda #cat_change_direction_animation - cat_base_animation
    cpx object_direction
    bne cat_changing_direction_or_jump_requested
    lda #cat_walk_cycle_animation - cat_base_animation
    ldx jump_requested
    beq cat_changing_direction_or_jump_requested
    lda #cat_jump_animation - cat_base_animation
.cat_changing_direction_or_jump_requested
    cmp current_player_animation
    beq cat_check_if_fallen_off_edge
    sta current_player_animation
    tay
    jmp cat_check_if_fallen_off_edge

.cat_standing_still
    lda current_player_animation
    cmp #cat_standing_still_animation - cat_base_animation
    beq cat_check_if_fallen_off_edge
    ldy #cat_standing_still_animation - cat_base_animation
    sty current_player_animation
    cmp #cat_walk_cycle_animation - cat_base_animation
    beq cat_transition_to_standing_still
    cmp #cat_change_direction_animation - cat_base_animation
    bne cat_check_if_fallen_off_edge
; transition from a walk cycle or change of direction animation to standing still
.cat_transition_to_standing_still
    ldy #cat_transition_to_standing_still_animation - cat_base_animation
.cat_check_if_fallen_off_edge
    ldx #0
; Read the 'player_just_fallen_off_edge_direction' if stationary, or the
; 'player_just_fallen_off_centrally_direction' if moving
    lda player_move_direction_requested
    beq got_direction_index
    inx
.got_direction_index
    lda object_just_fallen_off_edge_direction,x
    beq cat_got_index_in_animation
; cat is falling
    ldy #cat_fall_animation - cat_base_animation
    sty current_player_animation
    ldy #cat_animation11 - cat_base_animation
    cmp object_direction
    beq cat_got_index_in_animation
    ldy #cat_animation12 - cat_base_animation
.cat_got_index_in_animation
    sty object_current_index_in_animation
    tya
    ldx #<cat_base_animation
    ldy #>cat_base_animation
    jsr set_player_spriteid_and_offset_from_animation_table
    lda #objectid_player
    jsr update_object_a_solid_rock_collision
; update cat tail
    lda #<cat_tail_spriteids
    sta address1_low
    lda #>cat_tail_spriteids
    sta address1_high
    lda #&ff
    ldx current_player_animation
    cpx #cat_transform_in_animation - cat_base_animation
    beq cat_transforming_in_or_out
    cpx #cat_transform_out_animation - cat_base_animation
    bne cat_update_tail
; don't draw cat tail while transforming until cat_walk4 sprite reached
.cat_transforming_in_or_out
    lda #0
    ldx object_spriteid
    cpx #spriteid_cat_walk4
    bne cat_update_tail
; top bit set with lower 7 bits = 1, so setting offset 1 into cat_sprite_list
    lda #&81
.cat_update_tail
    ldx #<cat_sprite_list
    ldy #>cat_sprite_list
    jmp update_player_accessory_object_animation

.monkey_tail_spriteids
    equb spriteid_monkey_tail1, spriteid_monkey_tail2
    equb spriteid_monkey_tail3, spriteid_monkey_tail4
    equb spriteid_monkey_tail5, spriteid_monkey_tail6
    equb spriteid_monkey_tail7, spriteid_monkey_tail8
    equb 0
.monkey_sprite_list
    equb spriteid_monkey5,              &f7,      &f9
    equb spriteid_monkey1,              &f7,      &fa
    equb spriteid_monkey2,              &f7,      &f9
    equb spriteid_monkey3,              &f7,      &fa
    equb spriteid_monkey4,              &f7,      &f9
    equb spriteid_monkey4,              &f7,      &f9
    equb spriteid_monkey_climb1,        &f7,      &fa
    equb spriteid_monkey_climb2,        &f8,      &fa
    equb 0
.monkey_base_animation
.monkey_transform_in_animation
    equb 0, 0, 0
    equb spriteid_monkey_transform2,      0,        0
    equb spriteid_monkey_transform2,      0,        0
    equb spriteid_monkey_transform1,      0,        0
    equb spriteid_monkey_transform1,      0,        0
    equb spriteid_monkey4,                0,        0
    equb spriteid_monkey4,                0,        0
    equb 0
.monkey_transform_out_animation
    equb spriteid_monkey4,                0,        0
    equb spriteid_monkey4,                0,        0
    equb spriteid_monkey_transform1,      0,        0
    equb spriteid_monkey_transform1,      0,        0
    equb spriteid_monkey_transform2,      0,        0
    equb spriteid_monkey_transform2,      0,        0
    equb 0
.monkey_walk_cycle_animation
    equb spriteid_monkey1,                4,        0
    equb spriteid_monkey2,                4,        0
    equb spriteid_monkey3,                4,        0
    equb spriteid_monkey4,                4,        0
    equb                0
.monkey_change_direction_animation
    equb spriteid_monkey4,                0,        0
.monkey_change_direction_animation_last_step
    equb spriteid_monkey4,                2,        0
    equb                0
.monkey_animation6
    equb spriteid_monkey5,                4,        0
    equb                0
.monkey_standing_still_animation
    equb spriteid_monkey5,                0,        0
    equb                0
.monkey_climb_idle_animation
    equb spriteid_monkey_climb1,          0,        0
    equb                      0
.monkey_climb_down_animation
    equb spriteid_monkey_climb1,          0,        6
    equb                                  0
.monkey_animation10
    equb spriteid_monkey_climb1,          0,      &fc
    equb                      0
.monkey_climb_animation
    equb spriteid_monkey_climb2,          0,      &fc
    equb spriteid_monkey_climb1,          0,      &fc
    equb                      0
.monkey_animation12
    equb spriteid_monkey4,                7,        0
    equb spriteid_monkey4,                7,        1
    equb spriteid_monkey4,                6,        1
    equb spriteid_monkey4,                6,        2
    equb spriteid_monkey4,                4,        2
    equb spriteid_monkey4,                4,        3
    equb spriteid_monkey4,                3,        4
    equb spriteid_monkey4,                2,        4
    equb spriteid_monkey4,                2,        4
    equb spriteid_monkey4,                1,        5
    equb spriteid_monkey4,                1,        6
    equb                0
.monkey_standing_fall_animation
    equb spriteid_monkey4,                0,      &fc
    equb spriteid_monkey4,                0,      &fd
    equb spriteid_monkey4,                0,      &fe
    equb spriteid_monkey4,                0,      &ff
    equb                0
.monkey_jump_animation
    equb spriteid_monkey4,                6,      &fc
    equb spriteid_monkey4,                6,      &fe
    equb spriteid_monkey4,                5,      &fe
    equb spriteid_monkey4,                5,      &ff
    equb spriteid_monkey4,                4,        0
    equb                0
.monkey_animation15
    equb spriteid_monkey4,                4,        1
    equb spriteid_monkey4,                3,        2
    equb spriteid_monkey4,                3,        3
    equb spriteid_monkey4,                2,        4
    equb spriteid_monkey4,                2,        5
    equb spriteid_monkey4,                1,        6
    equb                0
.monkey_animation16
    equb spriteid_monkey4,                4,        2
    equb spriteid_monkey4,                3,        3
    equb spriteid_monkey4,                2,        4
    equb spriteid_monkey4,                1,        5
    equb                0
.monkey_animation17
    equb spriteid_monkey4,              &fc,        2
    equb spriteid_monkey4,              &fd,        3
    equb spriteid_monkey4,              &fe,        4
    equb spriteid_monkey4,              &ff,        5
    equb                0
.monkey_animation18
    equb spriteid_monkey4,                0,        1
    equb spriteid_monkey4,                0,        2
    equb spriteid_monkey4,                0,        3
    equb spriteid_monkey4,                0,        4
    equb spriteid_monkey4,                0,        5
    equb                0
.monkey_fall_animation
    equb spriteid_monkey4,                0,        7
    equb                0
.inhibit_monkey_climb_flag
    equb 0

.update_monkey
    lda #monkey_transform_out_animation - monkey_base_animation
    sta transform_out_animation
    ldx #<monkey_base_animation
    ldy #>monkey_base_animation
    lda #3
    jsr set_base_animation_address_and_handle_transform_in_out
    bne monkey_got_index_in_animation_local1
    cpy #monkey_change_direction_animation_last_step - monkey_base_animation
    bne monkey_not_changing_direction
; toggle player direction
    lda object_direction
    eor #&fe
    sta object_direction
.monkey_got_index_in_animation_local1
    jmp monkey_got_index_in_animation

.monkey_not_changing_direction
    jsr update_player_hitting_floor_or_pushed
    beq monkey_not_falling
    jmp monkey_falling

.monkey_not_falling
    lda current_player_animation
    cmp #monkey_climb_animation - monkey_base_animation
    beq update_monkey_climbing
    cmp #monkey_climb_down_animation - monkey_base_animation
    beq update_monkey_climbing
    cmp #monkey_climb_idle_animation - monkey_base_animation
    beq update_monkey_climbing
    lda jump_requested
    beq monkey_update_standing_fall
    jsr can_monkey_climb
    beq monkey_update_standing_fall
    lda #monkey_climb_animation - monkey_base_animation
    sta current_player_animation
    ldy #monkey_animation10 - monkey_base_animation
    jmp monkey_got_index_in_animation

.update_monkey_climbing
    ldx #monkey_fall_animation - monkey_base_animation
    jsr can_monkey_climb
    beq monkey_start_falling
    lda jump_requested
    beq monkey_not_jumping
    dec temp_top_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    bne monkey_set_climb_idle
    ldx #monkey_climb_animation - monkey_base_animation
    lda inhibit_monkey_climb_flag
    bne monkey_set_climb_idle
    lda move_left_requested
    ora move_right_requested
    beq monkey_set_animation_x
.monkey_set_climb_idle
    ldx #monkey_climb_idle_animation - monkey_base_animation
    jmp monkey_set_animation_x

.monkey_not_jumping
    ldx #monkey_animation12 - monkey_base_animation
    lda player_move_direction_requested
    cmp object_direction
    beq monkey_start_falling
    ldx #monkey_climb_down_animation - monkey_base_animation
    lda object_has_hit_floor_flag
    beq monkey_set_animation_x
    bne monkey_update_standing_fall                                   ; ALWAYS branch

.monkey_start_falling
    lda #monkey_fall_animation - monkey_base_animation
    sta current_player_animation
    txa
    tay
    jmp monkey_update_standing_fall

.monkey_set_animation_x
    cpx current_player_animation
    beq monkey_got_index_in_animation_local2
    txa
    tay
    sty current_player_animation
.monkey_got_index_in_animation_local2
    jmp monkey_got_index_in_animation

.monkey_update_standing_fall
    lda current_player_animation
    cmp #monkey_standing_fall_animation - monkey_base_animation
    bne monkey_update_jump
    dec temp_top_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    bne monkey_check_if_hit_floor
    cpy #monkey_standing_fall_animation - monkey_base_animation
    beq monkey_check_if_hit_floor
    bne monkey_got_index_in_animation_local2                          ; ALWAYS branch

.monkey_update_jump
    lda current_player_animation
    cmp #monkey_jump_animation - monkey_base_animation
    bne monkey_check_if_hit_floor
    dec temp_top_offset
    lda #0
    jsr get_solid_rock_collision_for_object_a
    bne monkey_fall
    cpy #monkey_jump_animation - monkey_base_animation
    beq monkey_fall
    jmp monkey_got_index_in_animation

.monkey_fall
    lda #monkey_fall_animation - monkey_base_animation
    sta current_player_animation
    ldy #monkey_animation15 - monkey_base_animation
.monkey_check_if_hit_floor
    lda object_has_hit_floor_flag
    bne monkey_check_for_standing_fall
.monkey_falling
    lda #monkey_fall_animation - monkey_base_animation
    cmp current_player_animation
    beq monkey_got_index_in_animation_local2
    ldx current_player_animation
    sta current_player_animation
    ldy #monkey_animation18 - monkey_base_animation
    cpx #monkey_climb_down_animation - monkey_base_animation
    bne monkey_got_index_in_animation_local2
    tay
    jmp monkey_got_index_in_animation

.monkey_check_for_standing_fall
    ldx player_move_direction_requested
    bne monkey_check_change_direction
    lda jump_requested
    beq monkey_set_standing_still
    lda current_player_animation
    cmp #monkey_fall_animation - monkey_base_animation
    beq monkey_set_standing_still
    lda #monkey_standing_fall_animation - monkey_base_animation
    jmp monkey_set_animation

.monkey_check_change_direction
    lda #monkey_change_direction_animation - monkey_base_animation
    cpx object_direction
    bne monkey_set_animation
    lda #monkey_walk_cycle_animation - monkey_base_animation
    ldx jump_requested
    beq monkey_set_animation
    ldx current_player_animation
    cpx #monkey_fall_animation - monkey_base_animation
    beq monkey_set_animation
    lda #monkey_jump_animation - monkey_base_animation
.monkey_set_animation
    cmp current_player_animation
    beq monkey_update_falling_off_edge
    sta current_player_animation
    tay
    jmp monkey_update_falling_off_edge

.monkey_set_standing_still
    lda current_player_animation
    ldy #monkey_standing_still_animation - monkey_base_animation
    sty current_player_animation
    cmp #monkey_walk_cycle_animation - monkey_base_animation
    beq monkey_was_walking_or_changing_direction
    cmp #monkey_change_direction_animation - monkey_base_animation
    bne monkey_update_falling_off_edge
.monkey_was_walking_or_changing_direction
    ldy #monkey_animation6 - monkey_base_animation
    jmp monkey_update_falling_off_edge

.monkey_update_falling_off_edge
    ldx #0
    lda player_move_direction_requested
    beq skip5
    inx
.skip5
    lda object_just_fallen_off_edge_direction,x
    beq monkey_got_index_in_animation
    ldy #monkey_fall_animation - monkey_base_animation
    sty current_player_animation
    ldy #monkey_animation16 - monkey_base_animation
    cmp object_direction
    beq monkey_got_index_in_animation
    ldy #monkey_animation17 - monkey_base_animation
.monkey_got_index_in_animation
    lda #0
    sta inhibit_monkey_climb_flag
    sty object_current_index_in_animation
    tya
    ldx #<monkey_base_animation
    ldy #>monkey_base_animation
    jsr set_player_spriteid_and_offset_from_animation_table
    lda #objectid_player
    jsr update_object_a_solid_rock_collision
; start updating the tail
    lda #<monkey_tail_spriteids
    sta address1_low
    lda #>monkey_tail_spriteids
    sta address1_high
; check for a tail. If the player is transitioning, it may not have a tail.
    lda #&ff
    ldx current_player_animation
    cpx #0
    beq monkey_checking_for_tail
    cpx #monkey_transform_out_animation - monkey_base_animation
    bne monkey_update_tail
.monkey_checking_for_tail
    lda #0
    ldx object_spriteid
    cpx #spriteid_monkey4
    bne monkey_update_tail
; top bit set with lower 7 bits = 7, so setting offset 7 into monkey_sprite_list
    lda #&87
.monkey_update_tail
    ldx #<monkey_sprite_list
    ldy #>monkey_sprite_list
    jmp update_player_accessory_object_animation

; *************************************************************************************
; 
; Can monkey climb?
; 
; Checks the collision map for
; 
; On Exit:
;           A and flags: $ff if monkey can climb, else $00
;        cell_x, cell_y: cell position to climb at (only valid if monkey can climb,
; A=$ff)
; 
; *************************************************************************************
.can_monkey_climb
    txa                                                               ; remember X,Y
    pha
    tya
    pha
; get top and bottom pixel position of player
    ldx #0
    jsr find_top_and_bottom_of_object
; find centre cell (vertically) of object from pixel position: (top+bottom) / 16, i.e.
; (average)/8
    lda object_top_low
    clc
    adc object_bottom_low
    sta cell_y
    lda object_top_high
    adc object_bottom_high
    ror a
    ror cell_y
    lsr a
    ror cell_y
    lsr a
    ror cell_y
    lsr a
    ror cell_y
    ldy cell_y
; read $ff from collision map if out of game area
    lda #&ff
    sta default_collision_map_option
; 5 is the x offset to get to the rope
    lda #5
    sta rope_x_offset
.can_monkey_climb_loop
    lda object_direction
    bmi adjust_position_because_looking_left
    lda object_x_low
    clc
    adc rope_x_offset
    sta cell_x
    and #&f8
    sta object_rope_low
    lda object_x_high
    adc #0
    sta object_rope_high
    jmp divide_by_eight_to_get_cells

.adjust_position_because_looking_left
    lda object_x_low
    sec
    sbc rope_x_offset
    sta cell_x
    and #&f8
    ora #7
    sta object_rope_low
    lda object_x_high
    sbc #0
    sta object_rope_high
.divide_by_eight_to_get_cells
    lsr a
    ror cell_x
    lsr a
    ror cell_x
    lsr a
    ror cell_x
    ldx cell_x
    jsr read_collision_map_value_for_xy
    cmp #collision_map_rope
    beq monkey_can_climb
    lda #2
    cmp rope_x_offset
    beq monkey_cant_climb
    sta rope_x_offset
    jmp can_monkey_climb_loop

; set the player position to the rope position
.monkey_can_climb
    lda object_rope_low
    sta object_x_low
    lda object_rope_high
    sta object_x_high
; return $ff to say we found a rope
    lda #&ff
    bne restore_xy_and_return_a                                       ; ALWAYS branch

; return $00 to say we didn't find a rope
.monkey_cant_climb
    lda #0
.restore_xy_and_return_a
    sta cell_x
    pla                                                               ; recall X,Y
    tay
    pla
    tax
    lda cell_x
    rts

.rope_x_offset
    equb 0

; *************************************************************************************
.toggle_load_save_dialog
    lda #&12
    sta current_text_width
    lda which_dialog_is_active
    bne remove_dialog_local1
.show_load_save_dialog
    jsr show_dialog_box
    lda #1
    sta which_dialog_is_active
    ldx #<press_s_to_save_encrypted_string
    ldy #>press_s_to_save_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr print_2xlf_cr
    ldx #<press_l_to_load_encrypted_string
    ldy #>press_l_to_load_encrypted_string
    jsr print_encrypted_string_at_yx
    jmp flush_input_buffers_and_zero_characters_entered

.remove_dialog_local1
    jmp remove_dialog

; 'Press S to save[0d]' EOR-encrypted with $cb
.press_s_to_save_encrypted_string
    equb &9b, &b9, &ae, &b8, &b8, &eb, &98, &eb, &bf, &a4, &eb, &b8
    equb &aa, &bd, &ae, &c6
; 'Press L to load[0d]' EOR-encrypted with $cb
.press_l_to_load_encrypted_string
    equb &9b, &b9, &ae, &b8, &b8, &eb, &87, &eb, &bf, &a4, &eb, &a7
    equb &a4, &aa, &af, &c6

; *************************************************************************************
.update_disc_menu
    ldy new_menu_index
    lda desired_menu_slots,y
    cmp #spriteid_icodata_disc
    bne return23
    lda which_dialog_is_active
    beq return23
    cmp #1
    beq load_or_save
    cmp #2
    beq get_filename_and_print_drive_number_prompt
    cmp #3
    beq test_for_drive_number_key_press_local
    jmp if_return_pressed_do_load_or_save

.test_for_drive_number_key_press_local
    jmp test_for_drive_number_key_press

.load_or_save
    lda #osfile_save
    sta osfile_action_load_or_save
    jsr inkey_0
    and #caps_mask
    cmp #'S'
    beq ask_for_filename
    cmp #'L'
    bne return23
    dec osfile_action_load_or_save
.ask_for_filename
    jsr show_dialog_box
    lda #2
    sta which_dialog_is_active
    ldx #<enter_filename_encrypted_string
    ldy #>enter_filename_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr print_2xlf_cr
    jsr turn_cursor_on
    jmp flush_input_buffers_and_zero_characters_entered

.return23
    rts

.osfile_action_load_or_save
    equb 0
; 'Enter filename[0d]' EOR-encrypted with $cb
.enter_filename_encrypted_string
    equb &8e, &a5, &bf, &ae, &b9, &eb, &ad, &a2, &a7, &ae, &a5, &aa
    equb &a6, &ae, &c6

.get_filename_and_print_drive_number_prompt
    lda #max_filename_len
    jsr string_input_character
    ldy characters_entered
    beq return23
    ldy #6
.save_leafname_loop
    lda string_input_buffer,y
    sta save_leaf_filename,y
    dey
    bpl save_leafname_loop
    jsr show_dialog_box
    lda #3
    sta which_dialog_is_active
    ldx #<which_drive_encrypted_string
    ldy #>which_drive_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr print_2xlf_cr
    ldx #<press_012_or_3_encrypted_string
    ldy #>press_012_or_3_encrypted_string
    jsr print_encrypted_string_at_yx
    jmp flush_input_buffers_and_zero_characters_entered

; *************************************************************************************
.save_full_filename
    equs ":"
.save_drive_number
    equs "0.I."
.save_leaf_filename
    equs ".......", &0d
; 'Which drive?[0d]' EOR-encrypted with $cb
.which_drive_encrypted_string
    equb &9c, &a3, &a2, &a8, &a3, &eb, &af, &b9, &a2, &bd, &ae, &f4
    equb &c6
; 'Press 0,1,2 or 3[0d]' EOR-encrypted with $cb
.press_012_or_3_encrypted_string
    equb &9b, &b9, &ae, &b8, &b8, &eb, &fb, &e7, &fa, &e7, &f9, &eb
    equb &a4, &b9, &eb, &f8, &c6

.test_for_drive_number_key_press
    jsr inkey_0
    cmp #'4'
    bcs return24
    cmp #'0'
    bcs drive_number_pressed
; check for shifted drive number
    cmp #'$'
    bcs return24
    cmp #'!'
    bcc return24
    adc #&0f
.drive_number_pressed
    sta save_drive_number
    jsr show_dialog_box
    lda #4
    sta which_dialog_is_active
    ldx #<insert_save_disk_encrypted_string
    ldy #>insert_save_disk_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr print_2xlf_cr
    ldx #<and_press_return_encrypted_string
    ldy #>and_press_return_encrypted_string
    jsr print_encrypted_string_at_yx
    jmp flush_input_buffers_and_zero_characters_entered

.return24
    rts

; 'Insert save disk[0d]' EOR-encrypted with $cb
.insert_save_disk_encrypted_string
    equb &82, &a5, &b8, &ae, &b9, &bf, &eb, &b8, &aa, &bd, &ae, &eb
    equb &af, &a2, &b8, &a0, &c6
; 'and press RETURN[0d]' EOR-encrypted with $cb
.and_press_return_encrypted_string
    equb &aa, &a5, &af, &eb, &bb, &b9, &ae, &b8, &b8, &eb, &99, &8e
    equb &9f, &9e, &99, &85, &c6

; *************************************************************************************
.if_return_pressed_do_load_or_save
    jsr inkey_0
    cmp #vdu_cr
    bne return24
    jsr show_dialog_box
    lda #vdu_lf
    jsr oswrch                                                        ; Write character 10
    ldx #<saving_encrypted_string
    ldy #>saving_encrypted_string
; if (saving) then branch forwards
    lda osfile_action_load_or_save
    beq got_encrypted_string_to_show
    ldx #<loading_encrypted_string
    ldy #>loading_encrypted_string
.got_encrypted_string_to_show
    jsr print_encrypted_string_at_yx_centred
    lda #<save_full_filename
    sta address1_low
    lda #>save_full_filename
    sta address1_high
    lda osfile_action_load_or_save
    beq save
    lda #osfile_read_catalogue_info
    jsr osfile_wrapper
    bne show_load_save_dialog_local
    lda osfile_block_start_address_mid1
    ora osfile_block_start_address_mid2
    ora osfile_block_start_address_high
    bne wrong_start_address
    lda osfile_block_start_address_low
    cmp #&85
    beq save_or_validated_load
.wrong_start_address
    jsr show_disk_error_dialog_if_display_is_initialised
.show_load_save_dialog_local
    jmp show_load_save_dialog

.save
    jsr get_checksum_of_save_game_data
    sta save_game_checksum
    ldx #0
    ldy #0
    stx osfile_block_exec_address_low
    stx osfile_block_exec_address_mid1
    lda #<save_game
    sta osfile_block_start_address_low
    lda #>save_game
    sta osfile_block_start_address_mid1
    lda #<level_workspace
    sta osfile_block_end_address_low
    lda #>level_workspace
    sta osfile_block_end_address_mid1
.save_or_validated_load
    ldx #<save_game
    ldy #>save_game
    lda osfile_action_load_or_save
    jsr osfile_wrapper
    bne show_load_save_dialog_local
    jsr get_checksum_of_save_game_data
    cmp save_game_checksum
    beq check_drive_letter
    lda #&ff
    sta save_game
.check_drive_letter
    lda save_drive_number
    sec
    sbc #'0'
    and #1
    bne odd_drive_number
    jsr prompt_user_to_insert_correct_disc
.odd_drive_number
    jsr check_menu_keys
    lda osfile_action_load_or_save
    bne drive_chosen
    jmp remove_dialog

.drive_chosen
    lda #&ff
    sta current_level
    lda save_game
    jmp select_level_a

; 'Saving[0d]' EOR-encrypted with $cb
.saving_encrypted_string
    equb &98, &aa, &bd, &a2, &a5, &ac, &c6
; 'Loading[0d]' EOR-encrypted with $cb
.loading_encrypted_string
    equb &87, &a4, &aa, &af, &a2, &a5, &ac, &c6
; 'Insert game disk[0d]' EOR-encrypted with $cb
.insert_game_disk_encrypted_string
    equb &82, &a5, &b8, &ae, &b9, &bf, &eb, &ac, &aa, &a6, &ae, &eb
    equb &af, &a2, &b8, &a0, &c6

.prompt_user_to_insert_correct_disc
    jsr show_dialog_box
    ldx #<insert_game_disk_encrypted_string
    ldy #>insert_game_disk_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr print_2xlf_cr
    ldx #<and_press_return_encrypted_string
    ldy #>and_press_return_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr flush_input_buffers_and_zero_characters_entered
.wait_for_return
    jsr inkey_0
    cmp #vdu_cr
    bne wait_for_return
    rts

; *************************************************************************************
.show_password_entry_dialog
    lda #&12
    sta current_text_width
    lda which_dialog_is_active
    bne remove_dialog_local3
.show_password_entry_dialog_ready
    jsr show_dialog_box
    ldx #<enter_password_encrypted_string
    ldy #>enter_password_encrypted_string
    jsr print_encrypted_string_at_yx
    jsr print_2xlf_cr
    jsr turn_cursor_on
    jmp flush_input_buffers_and_zero_characters_entered

.remove_dialog_local3
    jmp remove_dialog

; 'Enter password[0d]' EOR-encrypted with $cb
.enter_password_encrypted_string
    equb &8e, &a5, &bf, &ae, &b9, &eb, &bb, &aa, &b8, &b8, &bc, &a4
    equb &b9, &af, &c6

; *************************************************************************************
; 
; Password dialogue update
; 
; *************************************************************************************
.update_password_dialog
    ldy new_menu_index
    lda desired_menu_slots,y
; return if not on the password menu item
    cmp #spriteid_icodata_password
    bne return25
; return if the dialog is not active
    lda which_dialog_is_active
    beq return25
; update string entry (maximum 16 characters)
    lda #16
    jsr string_input_character
; At this point, because of the stack shenanigans in 'string_input_character', the
; input string has been entered
    ldy characters_entered
    beq no_characters_entered
; check for developer flags
    lda developer_flags
    and #1
    beq load_auxdata_loop
; check only one character entered + cr
    cpy #2
    bne load_auxdata_loop
; Look for one letter passwords (level letter)
    lda string_input_buffer
    cmp #first_level_letter
    bcc load_auxdata_loop
    cmp #last_level_letter+1
    bcs load_auxdata_loop
    pha
    jsr remove_dialog
    pla
    jmp select_level_a

.no_characters_entered
    lda developer_flags
    and #1
    beq return25
; remove dialog and restart game
    jsr remove_dialog
    lda #&ff
    jmp select_level_a

.return25
    rts

.load_auxdata_loop
    lda #<auxcode_filename
    sta address1_low
    lda #>auxcode_filename
    sta address1_high
    ldx #<auxcode
    ldy #>auxcode
    lda #osfile_load
    jsr osfile_wrapper
    beq auxcode_loaded_successfully
    jsr prompt_user_to_insert_correct_disc
    jmp load_auxdata_loop

.auxcode_loaded_successfully
    jsr check_password
    sta check_password_level
IF swr_renderer_enabled = 0
.load_sprdata_loop
    jsr load_sprdata
    beq sprdata_loaded_successfully
    jsr prompt_user_to_insert_correct_disc
    jmp load_sprdata_loop

ENDIF
.sprdata_loaded_successfully
    lda check_password_level
    bne select_level_a
    jmp show_password_entry_dialog_ready

.check_password_level
    equb 0

; *************************************************************************************
.select_level_a
    cmp #1
    beq remove_dialog_local2
    cmp current_level
    beq remove_dialog_local2
    tay
    pla
    pla
    pla
    pla
    pla
    pla
    cpy #&ff
    beq start_game_local
    ldx #0
    jmp initialise_level_and_room

.start_game_local
    jmp start_game

.remove_dialog_local2
    jmp remove_dialog

.character_too_low
    jmp character_handled

; *************************************************************************************
; 
; Input a character into a string
; 
; Waits for the minimum time for a key to be pressed.
; 
; If the RETURN key is pressed, the routine ends normally and the input can be
; processed. If another key (or no key) is pressed, the regular return address is
; pulled off the stack and control returns to the next routine up on the stack.
; 
; On Entry:
;     A: maximum length of string
; 
; *************************************************************************************
.string_input_character
    sta max_input_length
    jsr inkey_0
    ldy characters_entered
    cmp #vdu_cr
    beq finished_string_input
    cmp #vdu_delete
    beq delete_pressed
    cmp #'-'
    beq minus_or_equals_key_pressed
    cmp #'='
    beq minus_or_equals_key_pressed
    cmp #'!'
    bcc character_too_low
    cmp #'*'
    bcs check_range_of_characters
; Character is between '!' and '*' i.e. one of the shifted number keys. Add 16 to get
; ASCII number, even if SHIFT LOCK is on
    adc #&10
    bne store_character_if_room_available
.check_range_of_characters
    cmp #'0'
    bcc character_handled
    cmp #'9' + 1
    bcc store_character_if_room_available
    and #caps_mask
    cmp #'A'
    bcc character_handled
    cmp #'Z' + 1
    bcc store_character_if_room_available
    bcs character_handled
.minus_or_equals_key_pressed
    lda #'-'
.store_character_if_room_available
    cpy max_input_length
    bcs character_handled
    iny
    cpy max_input_length
    bne store_character
    jsr turn_cursor_off
.store_character
    dey
    sta string_input_buffer,y
    jsr print_italic
    inc characters_entered
    jmp character_handled

.delete_pressed
    cpy #0
    beq character_handled
    lda #vdu_left
    jsr oswrch                                                        ; Write character 8
    lda #' '
    jsr oswrch                                                        ; Write character 32
    lda #vdu_left
    jsr oswrch                                                        ; Write character 8
    dec characters_entered
    jsr turn_cursor_on
    jmp character_handled

.finished_string_input
    cpy #0
    beq return26
    sta string_input_buffer,y
    inc characters_entered
    jsr turn_cursor_off
    jmp return26

; take the return address off the stack and return to the routine above the callee
.character_handled
    pla
    pla
.return26
    rts

.max_input_length
    equb 0

; *************************************************************************************
.show_level_info_dialog
    lda #&11
    sta current_text_width
    lda which_dialog_is_active
    beq show_section_letter_dialog
    cmp #1
    beq show_level_completion_letters_dialog
    jmp remove_dialog

.show_section_letter_dialog
    jsr show_dialog_box
    lda #1
    sta which_dialog_is_active
    ldx #<section_encrypted_string
    ldy #>section_encrypted_string
    jsr print_encrypted_string_at_yx
    ldy current_level
    jsr convert_level_filename_letter_into_section_letter
    tya
    jsr print_italic
    jsr print_2xlf_cr
    ldx level_specific_password_ptr
    ldy level_specific_password_ptr + 1
    jmp print_encrypted_string_at_yx

; 'Section [0d]' EOR-encrypted with $cb
.section_encrypted_string
    equb &98, &ae, &a8, &bf, &a2, &a4, &a5, &eb, &c6

.show_level_completion_letters_dialog
    jsr show_dialog_box
    lda #2
    sta which_dialog_is_active
    ldx #first_level_letter
.show_level_completion_letters_loop
    txa
    tay
    jsr convert_section_letter_to_level_filename_letter
    tya
    sec
    sbc #first_level_letter
    tay
; check for level completion
    lda level_progress_table,y
    and #&80
    tay
    txa
    cpy #0
    beq got_character_to_print
; print diamond for completed level
    lda #&fe
.got_character_to_print
    jsr print_italic
    cpx #last_level_letter-1
    beq return27
; move forward one character
    lda #9
    jsr oswrch                                                        ; Write character 9
    txa
    inx
; have we reached the end of the first line of letters?
    cmp #first_level_letter + num_levels/2 - 1
    bne show_level_completion_letters_loop
; move to second row of letters
    jsr print_2xlf_cr
    jmp show_level_completion_letters_loop

.return27
    rts

; *************************************************************************************
.print_encrypted_string_at_yx_centred
    stx address1_low
    sty address1_high
    ldy #0
.find_string_length_loop
    lda (address1_low),y
    eor eor_key
    cmp #vdu_cr
    beq string_length_in_y
    iny
    bne find_string_length_loop
.string_length_in_y
    sty address1_low
    lda current_text_width
    sec
    sbc #2
    sbc address1_low
    lsr a
    tay
    beq print_spaces_done
    lda #' '
.print_y_spaces_loop
    jsr oswrch                                                        ; Write character 32
    dey
    bne print_y_spaces_loop
.print_spaces_done
    ldy address1_high
; *************************************************************************************
; 
; Print the EOR-encrypted (with eor_key) CR-terminated string at YX. Print in italics
; iff print_in_italics_flag is non-0.
; 
; *************************************************************************************
.print_encrypted_string_at_yx
    stx address1_low
    sty address1_high
    lda #<print_italic
    sta print_char_target
    lda #>print_italic
    sta print_char_target + 1
    lda print_in_italics_flag
    bne print_char_target_set
    lda #<oswrch
    sta print_char_target
    lda #>oswrch
    sta print_char_target + 1
.print_char_target_set
    ldy #0
.print_char_loop
    lda (address1_low),y
    eor eor_key
    cmp #vdu_cr
    beq print_done
    jsr print_char
    iny
    bne print_char_loop
.print_done
    lda #&cb
    sta eor_key
    rts

; Print the character in A. This is patched at runtime to switch between normal and
; italic text.
.print_char
print_char_target = print_char+1
    jmp oswrch                                                        ; Write character

.print_2xlf_cr
    lda #vdu_lf
    jsr oswrch                                                        ; Write character 10
    jsr oswrch                                                        ; Write character
    lda #vdu_cr
    jmp oswrch                                                        ; Write character 13

.turn_cursor_on
    pha
    lda #&67 ; 'g'
    pha
    bne finish_cursor_on_off                                          ; ALWAYS branch
.turn_cursor_off
    pha
    lda #&20 ; ' '
    pha
.finish_cursor_on_off
    lda #crtc_cursor_start
    sta crtc_address_register
    pla
    sta crtc_address_write
    pla
    rts

.flush_input_buffers_and_zero_characters_entered
    ldx #0
    stx characters_entered
    lda #osbyte_flush_buffer_class
    inx
    jmp osbyte                                                        ; Flush all buffers (X=0), or just input buffers (X non-zero)

.inkey_0
    lda #osbyte_inkey
    ldx #0
    ldy #0
    jsr osbyte                                                        ; Wait for a key press within 0 centiseconds
    tya                                                               ; Y is zero if key pressed; &ff if no key pressed; &1b if ESCAPE pressed
    bne return_with_zero_result
; X is the ASCII value of the key pressed (assuming Y=0)
    txa
    rts

.return_with_zero_result
    lda #0
    rts

.wait_one_second_then_check_keys
    lda #0
    sta vsync_counter
.wait_one_second_loop
    lda vsync_counter
    cmp #50
    bcc wait_one_second_loop
    jmp check_menu_keys

.auxcode_filename
    equs "auxcode", &0d
.sound_data1
    equw &0010                                                        ; channel
    equw 65524                                                        ; amplitude
    equw 2                                                            ; pitch
    equw 1                                                            ; duration
; The envelope definitions get overwritten after initialisation - this is harmless as
; they will have been copied into the OS workspace when they were defined.
.object_erase_type
.envelope_1
    equb 1                                                            ; envelope number
    equb 3                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 3                                                            ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 0                                                            ; change of amplitude per step during release phase
    equb 64                                                           ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound_data3
    equw &0010                                                        ; channel
    equw 1                                                            ; amplitude
    equw 7                                                            ; pitch
    equw 100                                                          ; duration
.object_z_order
.envelope_2
    equb 2                                                            ; envelope number
    equb 134                                                          ; step length (100ths of a second)
    equb 1                                                            ; pitch change per step in section 1
    equb 3                                                            ; pitch change per step in section 2
    equb 5                                                            ; pitch change per step in section 3
    equb 10                                                           ; number of steps in section 1
    equb 10                                                           ; number of steps in section 2
    equb 16                                                           ; number of steps in section 3
    equb 0                                                            ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 0                                                            ; change of amplitude per step during release phase
    equb 0                                                            ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound_data2
    equw &0011                                                        ; channel
    equw 2                                                            ; amplitude
    equw 180                                                          ; pitch
    equw 100                                                          ; duration
; object_room_collision_flags is a per-object table that has:
; 
;     bit 0: object collided with left wall
;     bit 1: object collided with floor
;     bit 2: object collided with right wall
;     bit 3: object collided with ceiling
.object_room_collision_flags
.envelope_3
    equb 3                                                            ; envelope number
    equb 1                                                            ; step length (100ths of a second)
    equb 0                                                            ; pitch change per step in section 1
    equb 0                                                            ; pitch change per step in section 2
    equb 0                                                            ; pitch change per step in section 3
    equb 0                                                            ; number of steps in section 1
    equb 0                                                            ; number of steps in section 2
    equb 0                                                            ; number of steps in section 3
    equb 100                                                          ; change of amplitude per step during attack phase
    equb 0                                                            ; change of amplitude per step during decay phase
    equb 0                                                            ; change of amplitude per step during sustain phase
    equb 248                                                          ; change of amplitude per step during release phase
    equb 126                                                          ; target of level at end of attack phase
    equb 0                                                            ; target of level at end of decay phase
.sound_landing2
    equw &0010                                                        ; channel
    equw 3                                                            ; amplitude
    equw 3                                                            ; pitch
    equw 1                                                            ; duration
.sound_landing1
    equw &0011                                                        ; channel
    equw 0                                                            ; amplitude
    equw 40                                                           ; pitch
    equw 1                                                            ; duration

; *************************************************************************************
; 
; Play a sound
; 
; On Extry:
;     A: Sound priority ($ff always plays, $00 won't if sound already playing is $ff)
;     YX: Address of SOUND block to play (eight bytes)
; 
; On Exit:
;     Preserves A
; 
; *************************************************************************************
.play_sound_yx
    sta remember_a
; remember address1 on stack
    lda address1_low
    pha
    lda address1_high
    pha
; store YX address
    stx address1_low
    sty address1_high
; exit if sound is disabled
    lda sound_enable_flag
    beq finish_play_sound
    ldy #0
    lda (address1_low),y
; If flush is clear, then branch forward to play sound
    and #&f0
    beq no_flush
; Get channel number (0-3) into X
    lda (address1_low),y
    and #3
    tax
; update current sound priority as needed
    lda remember_a
    cmp sound_priority_per_channel_table,x
    bcc finish_play_sound
    sta sound_priority_per_channel_table,x
; if sound channel is 2 or 3, branch forward
    cpx #2
    bcs play_sound
; if (the new sound is the same as the existing sound) then branch to play_sound
    lda address1_low
    cmp address_of_sounds_low_table,x
    bne flush_sound_buffer_X
    lda address1_high
    cmp address_of_sounds_high_table,x
    beq play_sound
; add four to X to get sound buffer number
.flush_sound_buffer_X
    txa
    clc
    adc #4
    tax
    lda #osbyte_flush_buffer
    jsr osbyte                                                        ; Flush specific buffer X
.no_flush
    lda (address1_low),y
    and #3
    tax
; store the address of the new sound in tables
    lda address1_low
    sta address_of_sounds_low_table,x
    lda address1_high
    sta address_of_sounds_high_table,x
.play_sound
    ldx address1_low
    ldy address1_high
    lda #osword_sound
    jsr osword                                                        ; SOUND command
; restore address1 from stack
.finish_play_sound
    pla
    sta address1_high
    pla
    sta address1_low
    lda remember_a
    rts

.define_envelope
    pha
    lda #osword_envelope
    jsr osword                                                        ; ENVELOPE command
    pla
    rts

.sound_enable_flag
    equb &ff
.address_of_sounds_low_table
    equb 0, 0, 0, 0
.address_of_sounds_high_table
    equb 0, 0, 0, 0
.sound_priority_per_channel_table
    equb 0
    equb 0, 0, 0
.remember_a
    equb 0
.mid_transform_sprites_table
    equb spriteid_one_pixel_masked_out
.mid_transform_circle_sprites
    equb spriteid_circle
    equb spriteid_circle
    equb &ff
.mid_transform_sparkles_in
    equb spriteid_one_pixel_masked_out
    equb spriteid_sparkles5
    equb spriteid_sparkles4
    equb spriteid_sparkles3
    equb spriteid_sparkles2
    equb spriteid_sparkles1
    equb &ff
.mid_transform_sparkles_out
    equb spriteid_sparkles1
    equb spriteid_sparkles2
    equb spriteid_sparkles3
    equb spriteid_sparkles4
    equb spriteid_sparkles5
    equb spriteid_one_pixel_masked_out
    equb &ff

; During a transformation, 'object_current_index_in_animation' is the index into the
; sprite array above
.update_mid_transformation
    lda object_current_index_in_animation
    clc
    adc #1
    tay
    lda mid_transform_sprites_table,y
    cmp #&ff
    bne still_playing
    ldy current_player_animation
.still_playing
    lda current_player_animation
    bne check_for_point_of_changing_level
    tya
    bne mid_transform_store_state
    lda new_player_character
    sta current_player_character
    bne got_player_character
    ldy #mid_transform_sparkles_out - mid_transform_sprites_table
    sty current_player_animation
    lda object_y_low
    clc
    adc #2
    sta object_y_low
    jmp mid_transform_store_state

.got_player_character
    lda #0
    sta current_player_animation
    sta object_current_index_in_animation
    jmp update_player

.check_for_point_of_changing_level
    cmp #mid_transform_sparkles_out - mid_transform_sprites_table
    bne check_for_circles_animation
    cpy #mid_transform_sparkles_out - mid_transform_sprites_table
    bne mid_transform_store_state
; this is the point at which we move to the next level. First start the transform_in
; animation
    jsr start_of_transform_in_animation
; stack shenanigans: Remove two addresses from the stack, so we don't fill up the stack
; (taking us back to the stack level that called 'game_update')
    pla
    pla
    pla
    pla
; find the next uncompleted level
    ldy #num_levels-1
.find_uncompleted_level_loop
    lda level_progress_table,y
    and #&80
    beq found_uncompleted_level
    dey
    bpl find_uncompleted_level_loop
    ldy #last_level_letter
    bne found_next_level                                              ; ALWAYS branch

.found_uncompleted_level
    ldy current_level
    jsr convert_level_filename_letter_into_section_letter
    iny
    cpy #last_level_letter
    bcc found_next_level
    ldy #first_level_letter
.found_next_level
    ldx #0
    jsr convert_section_letter_to_level_filename_letter
; start next level
    jmp initialise_level_and_room

.check_for_circles_animation
    cpy #mid_transform_sparkles_in - mid_transform_sprites_table
    bne mid_transform_store_state
    lda #mid_transform_sprites_table - mid_transform_sprites_table
    sta current_player_animation
    ldy #mid_transform_circle_sprites - mid_transform_sprites_table
    lda object_y_low
    sec
    sbc #2
    sta object_y_low
.mid_transform_store_state
    sty object_current_index_in_animation
    lda mid_transform_sprites_table,y
    sta object_spriteid
    rts

.update_main_keys
    ldx #inkey_key_return
    jsr negative_inkey
    ora return_key_pressed_pending
    sta return_key_pressed_pending
    ldx #inkey_key_z
    jsr negative_inkey
    sta z_key_pressed
    ora z_key_pressed_pending
    sta z_key_pressed_pending
    ldx #inkey_key_x
    jsr negative_inkey
    pha
    ora x_key_pressed_pending
    sta x_key_pressed_pending
    pla
    ldx #0
    eor z_key_pressed
    beq store_x_as_valid_direction_pending
    dex
    lda z_key_pressed
    bmi store_x_as_valid_direction_pending
    ldx #1
.store_x_as_valid_direction_pending
    txa
    ora valid_direction_pending
    sta valid_direction_pending
    rts

.update_space_etc_keys
    ldx #inkey_key_space
    jsr negative_inkey
    cmp space_bar_pressed
    sta space_bar_pressed
    bne save_space_bar_state_change_pending
    lda #0
.save_space_bar_state_change_pending
    ora space_bar_press_pending
    sta space_bar_press_pending
; store whether the left cursor key is pressed in 'z_key_pressed'
    ldx #inkey_key_left
    jsr negative_inkey
    sta z_key_pressed
; if the left and right cursor keys are pressed together (or neither), there is no
; valid direction (set A=$00)
    ldx #inkey_key_right
    jsr negative_inkey
    cmp z_key_pressed
    beq no_valid_direction
; set A=$FF if moving left, or $01 if moving right along the toolbar
    lda z_key_pressed
    bmi menu_x_step_in_a
    lda #1
    bpl menu_x_step_in_a                                              ; ALWAYS branch
.no_valid_direction
    lda #0
; This is a manual implementation of an auto-repeat delay, so if you hold down
; left/right a fraction of a second too long it doesn't zip all the way to the left or
; right.
.menu_x_step_in_a
    cmp left_right_repeat_direction
    sta left_right_repeat_direction
; if direction changes, restart the auto-repat delay
    bne restart_auto_repeat_delay
    lda #0
    dec auto_repeat_counter
    bpl remember_direction_pressed
    lda left_right_repeat_direction
.restart_auto_repeat_delay
    ldx auto_repeat_delay
    stx auto_repeat_counter
.remember_direction_pressed
    ora left_right_direction
    sta left_right_direction
    rts

.z_key_pressed
    equb 0
.auto_repeat_delay
    equb &10

.check_menu_keys
    lda space_bar_press_pending
    sta space_flag2
    lda left_right_direction
    sta left_right_flag_pending
    lda #0
    sta space_bar_press_pending
    sta left_right_direction
    rts

.space_flag2
    equb 0
.left_right_flag_pending
    equb 0

.read_player_movement_keys
    lda jump_requested
    sta jump_requested_previous_tick
    lda return_key_pressed_pending
    sta jump_requested
    lda valid_direction_pending
    sta player_move_direction_requested
    lda z_key_pressed_pending
    sta move_left_requested
    lda x_key_pressed_pending
    sta move_right_requested
    lda #0
    sta return_key_pressed_pending
    sta valid_direction_pending
    sta z_key_pressed_pending
    sta x_key_pressed_pending
    rts

.jump_requested
    equb 0
.jump_requested_previous_tick
    equb 0
; $ff for left, $01 for right, $00 for none
.player_move_direction_requested
    equb 0
.move_left_requested
    equb 0
.move_right_requested
    equb 0

.negative_inkey
    ldy #&ff
    lda #osbyte_inkey
    jsr osbyte                                                        ; Read a specific key (or read machine type)
    txa
    rts

; Record structure of start of data files so can find relative to level load address
.level_data
    SKIP 2                          ; offset to sprite data
.level_specific_initialisation_ptr
    SKIP 2                          ; address of level initialisation code
.level_specific_update_ptr
    SKIP 2                          ; address of level update code
.level_specific_password_ptr
    SKIP 2                          ; address of level password
.initial_room_index
    SKIP 1
.initial_room_index_cheat
    SKIP 1
.level_room_data_table

CLEAR level_data, level_room_data_table
ORG level_data

.execution_start
; The loader will have executed VDU 21 to disable VDU output. Record the current
; disable state before re-enabling it, so we can check it later as part of a copy
; protection scheme.
; This initialisation code gets overwritten by level data later on.
    lda #osbyte_read_vdu_status
    jsr osbyte                                                        ; Read VDU status byte

    ; X is VDU status byte:
    ;     bit 0=printer output enabled by a VDU 2
    ;     bit 1=scrolling disabled (cursor editing)
    ;     bit 2=paged scrolling selected
    ;     bit 3=software scrolling selected (text window)
    ;     bit 4=shadow mode selected
    ;     bit 5=text at graphics cursor (VDU 5)
    ;     bit 6=two cursor editing mode
    ;     bit 7=screen disabled via VDU 21
    txa
    and #&80
    sta initial_screen_disabled_flag
    lda #vdu_enable
    jsr oswrch                                                        ; Write character 6

; Relocation 1: Copy 512 bytes of code from &40FF to &400
    lda #<relocation1_high_copy_start
    sta address1_low
    lda #>relocation1_high_copy_start
    sta address1_high
    lda #<wait_for_timingB_counter
    sta destination_address_low
    lda #>wait_for_timingB_counter
    sta destination_address_high
    ldx #2
    beq relocation3                                                  ; branch never taken
    ldy #0
.relocation1_loop
    lda (address1_low),y
    sta (destination_address_low),y
    iny
    bne relocation1_loop
    inc address1_high
    inc destination_address_high
    dex
    bne relocation1_loop

; Relocation 2: Copy &2A00 bytes from &1234 to &1103. This is done more for obfuscation
; than any real requirement - we could have just loaded at &1103 in the first place.
; .relocation2
;     lda #<pydis_start
;     sta address1_low
;     lda #>pydis_start
;     sta address1_high
;     lda #<developer_flags
;     sta destination_address_low
;     lda #>developer_flags
;     sta destination_address_high
;     lda address1_high
;     cmp destination_address_high
;     bne skip4                                                         ; branch always taken
;     lda address1_low
;     cmp destination_address_low
;     beq relocation3
; .skip4
;     ldx #&2a ; '*'
;     beq relocation3                                                   ; branch never taken
;     ldy #0
; .relocation2_loop
;     lda (address1_low),y
;     sta (destination_address_low),y
;     iny
;     bne relocation2_loop
;     inc address1_high
;     inc destination_address_high
;     dex
;     bne relocation2_loop

; Relocation 3: Copy $48 bytes of code from $4088 to $0ab7
.relocation3
    ldx #0
.relocation3_loop
    lda relocation3_high_copy_start,x
    sta clear_most_of_save_game,x
    inx
    cpx #relocation3_high_copy_end - relocation3_high_copy_start
    bcc relocation3_loop

; Relocation 4: Copy $100 bytes of code from $3fcb to $0c00
    ldy #0
.relocation4_loop
    lda relocation4_high_copy_start,y
    sta initialise_display,y
    iny
    bne relocation4_loop

; Relocation 5: Copy $2f bytes of data from $40d0 to $0131
    ldy #0
.relocation5_loop
    lda relocation5_high_copy_start,y
    sta update_displayed_transformations_remaining,y
    iny
    cpy #relocation5_high_copy_end - relocation5_high_copy_start
    bne relocation5_loop
; Relocation finished

    lda developer_flags
    and #8
    beq set_drive_and_directory
    lda #'2'
    sta drive_number
.set_drive_and_directory
    ldx #<(drive_0_command)
    ldy #>(drive_0_command)
    jsr oscli
    ldx #<(dir_dollar_command)
    ldy #>(dir_dollar_command)
    jsr oscli
    lda #osbyte_close_spool_exec
    jsr osbyte                                                        ; Close any *SPOOL and *EXEC files
    lda #osbyte_read_write_escape_break_effect
    ldx #3
    ldy #0
    jsr osbyte                                                        ; Write Disable ESCAPE action, clear memory on BREAK, value X=3
    lda #osbyte_read_write_first_byte_break_intercept
    ldx #0
    ldy #0
    jsr osbyte                                                        ; Write reset intercept code (opcode), value X=0
    lda #osbyte_opt
    ldx #0
    ldy #0
    jsr osbyte                                                        ; *OPT 0,0: Reset all options for current filing system
    lda #osbyte_set_cursor_editing
    ldx #1
    ldy #0
    jsr osbyte                                                        ; Disable cursor editing (edit keys give ASCII 135-139) (X=1)
; remember default brk and irq vectors
    lda brkv
    sta old_brkv1
    sta old_brkv2
    lda brkv+1
    sta old_brkv1+1
    sta old_brkv2+1
    lda irq1v
    sta old_irq1v
    lda irq1v+1
    sta old_irq1v+1
; redefine character 254 as a diamond shape
    lda #vdu_define_character
    jsr oswrch                                                        ; Write character 23
    lda #&fe
    jsr oswrch                                                        ; Write character 254
    ldx #0
.define_character_fe_loop
    lda character_fe_bitmap,x
    jsr oswrch                                                        ; Write character
    inx
    cpx #8
    bcc define_character_fe_loop
    lda #osbyte_set_printer_ignore
    ldx #0
    jsr osbyte                                                        ; Set printer ignore character to X=0
    lda #&fe
    sta currently_loaded_level
    lda #0
    sta which_dialog_is_active
    lda #&ff
    sta current_menu_index
; clear the display of remaining transformations
    lda #' '
    sta displayed_transformations_remaining
    sta displayed_transformations_remaining+1
    sta displayed_transformations_remaining+2
    lda #&cb
    sta eor_key
    lda #&ff
    sta print_in_italics_flag
    lda #sprite_op_flags_normal
    sta temp_sprite_x_offset
    sta temp_sprite_y_offset
    sta sprite_op_flags
    lda #1
    sta sprite_reflect_flag
    lda #osbyte_select_adc_channels
    ldx #0
    jsr osbyte                                                        ; Disable ADC channel sampling (X=0)
; define envelopes
    ldx #<envelope_1
    ldy #>envelope_1
    jsr define_envelope
    ldx #<envelope_2
    ldy #>envelope_2
    jsr define_envelope
    ldx #<envelope_3
    ldy #>envelope_3
    jsr define_envelope
; initialise the 'all clear' and 'all set' tiles
    ldy #7
.init_tiles_loop
    lda #0
    sta tile_all_clear_pixels,y
    lda #&ff
    sta tile_all_set_pixels,y
    dey
    bpl init_tiles_loop
; store special spriteid used for preserving the background behind the player and the
; player's accessory
    lda #spriteid_erase_player
    sta object_erase_type
    lda #spriteid_erase_player_accessory
    sta object_erase_type + objectid_player_accessory
; set z order for the player at the midway point so that objects can appear in front or
; behind the player
    lda #&80
    sta object_z_order
; set z order for the player accessory object as being just in front of the player
    lda #&7f
    sta object_z_order + objectid_player_accessory
; seed random number generation by reading the User VIA timers
    lda user_via_t1c_l
    sta rnd0
    lda user_via_t1c_h
    sta rnd1
    lda user_via_t2c_l
    sta rnd2
    lda user_via_t2c_h
    sta rnd3
    lda #1
    sta rnd4
; set base address for sprite rendering, $6200 is the main game area
    lda #&62 ; 'b'
    sta screen_base_address_high
; Check to see if VDU output was disabled (VDU 21) when we first started to execute,
; before we re-enabled output (VDU 6) ourselves.
; This could be to make the G file self-contained if it's run directly from the command
; line during development, instead of from IMOGEN
    lda initial_screen_disabled_flag
    bne clear_toolbar_part_of_screen
; VDU output wasn't disabled when we started to execute. Change to MODE 4.
    lda #vdu_set_mode
    jsr oswrch                                                        ; Write character 22
    lda #4
    jsr oswrch                                                        ; Write character 4
    jmp define_text_window

; Clear memory from $5b00 to $6200. This clears the toolbar area of the screen. The
; toolbar lives in screen memory from $5bc0 to $6200, so this routine clears a little
; before the start of screen memory, but this is OK as we are just about to load sprite
; data there anyway
.clear_toolbar_part_of_screen
    lda #0                                                            ; set start address to $5b00
    sta address1_low
    tay
    ldx #>start_of_screen_memory
    stx address1_high
    ldx screen_base_address_high
.clear_toolbar_part_of_screen_loop
    sta (address1_low),y
    iny
    bne clear_toolbar_part_of_screen_loop
    inc address1_high
    cpx address1_high
    bne clear_toolbar_part_of_screen_loop
; Define text window that excludes the leftmost column (left 1, bottom 31, right: 39,
; top: 0). This simplifies printing text in dialog boxes.
.define_text_window
    lda #vdu_define_text_window
    jsr oswrch                                                        ; Write character 28
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1f
    jsr oswrch                                                        ; Write character 31
    lda #screen_width_minus_one
    jsr oswrch                                                        ; Write character 39
    lda #0
    jsr oswrch                                                        ; Write character 0
; set background text colour to 1
    lda #vdu_set_text_colour
    jsr oswrch                                                        ; Write character 17
    lda #&81
    jsr oswrch                                                        ; Write character 129
; set foreground text colour to 0
    lda #vdu_set_text_colour
    jsr oswrch                                                        ; Write character 17
    lda #0
    jsr oswrch                                                        ; Write character 0
; set graphics foreground colour to 0
    lda #vdu_set_graphics_colour
    jsr oswrch                                                        ; Write character 18
    lda #0
    jsr oswrch                                                        ; Write character 0
    jsr oswrch                                                        ; Write character
; read *TV shift setting
    ldx #0
    ldy #0
    lda #osbyte_tv
    jsr osbyte                                                        ; *TV 0,0 turn interlace on
; remember *TV shift setting
    stx address1_low                                                  ; X is the previous screen shift setting
    jsr osbyte                                                        ; restore previous *TV setting (since we changed it in the process of reading it)
; Set CRTC registers
    lda #crtc_cursor_start
    sta crtc_address_register
    lda #&20 ; ' '
    sta crtc_address_write
    lda #&0b                                                          ; redundant instruction
    lda #0                                                            ; redundant instruction
; Calculate 35+tv shift and store in vertical_sync_amount_for_crtc_register
    lda #35
    clc
    adc address1_low
    sec
    sbc #1
    sta vertical_sync_amount_for_crtc_register
    sec                                                               ; subtract five
    sbc #5
    tax
    lda #crtc_vert_sync_pos
    sta crtc_address_register
    stx crtc_address_write
    lda #crtc_screen_start_low
    sta crtc_address_register
    lda #&40 ; '@'
    sta crtc_address_write
    lda #crtc_screen_start_high
    sta crtc_address_register
    lda #&0c
    sta crtc_address_write
    lda #crtc_vert_displayed
    sta crtc_address_register
    lda #&18
    sta crtc_address_write
    lda #crtc_interlace_delay
    sta crtc_address_register
    lda #0
    sta crtc_address_write
    asl address1_low                                                  ; Double the *TV shift amount
; Adjust two timing counters depending on the *TV shift amount
    ldy #3                                                            ; Loop counter, goes twice around the loop (Y is decremented twice each time)
.adjust_timing_variable_loop
    lda timingA_counter_low,y
    sec
    sbc address1_low                                                  ; subtract twice the *TV shift amount
    sta timingA_counter_low,y
    dey
    dey
    bpl adjust_timing_variable_loop
IF swr_renderer_enabled
    LDA #1: STA swr_namespace
    LDA #0: STA swr_level_table: STA swr_level_table+1
    LDA #&FF: STA swr_owner
    JSR swr_invalidate_caches
    JMP icodata_read_ok
.drive_0_command
    equs "DRIVE "
.drive_number
    equb '0', &0d
.dir_dollar_command
    equs "DIR $"
    equb &0d

ELSE
; Load sprites
    lda #<sprdata_filename
    sta address1_low
    lda #>sprdata_filename
    sta address1_high
    lda #osfile_read_catalogue_info
    jsr osfile_wrapper
; Load SPRDATA file into memory so it ends just before screen memory at $5bc0.
    lda #<start_of_screen_memory
    sec
    sbc osfile_block_start_address_low
    sta sprdata_ptr
    lda #>start_of_screen_memory
    sbc osfile_block_start_address_mid1
    sta sprdata_ptr + 1
    jsr load_sprdata
; remember where sprite data is loaded
    lda sprdata_ptr
    pha
    lda sprdata_ptr + 1
    pha
; 
; Load ICODATA file into memory at address icodata
; 
; ICODATA contains the standard set of sprites for the toolbar. These are drawn once
; and stay on screen permanently, so the the memory used by ICODATA is reused.
; ICODATA also holds a developer_flags byte and the level ordering details, which is
; copied before being reused.
; 
; ICODATA is loaded at $40ff (overwriting 'block_of_code_to_live_at_0400' which has
; already been moved) where it is used, then overwritten.
; 
    ldx #<icodata
    stx sprdata_ptr
    ldy #>icodata
    sty sprdata_ptr + 1
    lda developer_flags
    and #4
    bne read_icodata_using_osword_7f
    lda #<icodata_filename
    sta address1_low
    lda #>icodata_filename
    sta address1_high
    lda #osfile_load
    jsr osfile_wrapper
    jmp icodata_read_ok

.read_icodata_using_osword_7f
    lda #39                                                           ; seek track 39
    jsr seek_track_a
; write special register 'track' with value 127
    lda #&7f
    jsr set_track_special_register_to_a
; block read three 256 byte sectors into memory at 'icodata'
    lda #&7f
    ldx #<(osword_7f_block_read)
    ldy #>(osword_7f_block_read)
    jsr osword                                                        ; Single track single density FDC command (see https://beebwiki.mdfs.net/OSWORDs)
    lda osword_7f_read_result
    beq read_successful
; read failed, seek track zero and try again
    lda #0
    jsr seek_track_a
    jmp read_icodata_using_osword_7f

; write special register 'track' with value 39
.read_successful
    lda #39
    jsr set_track_special_register_to_a
    jmp icodata_read_ok

.seek_track_a
    sta osword_7f_block_seek_track
    lda #&7f
    ldx #<(osword_7f_block_seek)
    ldy #>(osword_7f_block_seek)
    jmp osword                                                        ; Single track single density FDC command (see https://beebwiki.mdfs.net/OSWORDs)

.set_track_special_register_to_a
    sta osword_7f_block_write_special_register_track
    lda #&7f
    ldx #<(osword_7f_block_write_special_register)
    ldy #>(osword_7f_block_write_special_register)
    jmp osword                                                        ; Single track single density FDC command (see https://beebwiki.mdfs.net/OSWORDs)

.osword_7f_block_seek
    equb 0                                                            ; drive
    equw &ffff,     0                                                 ; data address
    equb 1                                                            ; number of parameters
    equb &69                                                          ; command ($69=seek)
.osword_7f_block_seek_track
    equb 0
.osword_7f_seek_result
    equb 0
.osword_7f_block_write_special_register
    equb 0                                                            ; drive
    equw &ffff,     0                                                 ; data address
    equb 2                                                            ; number of parameters
    equb &7a                                                          ; command ($7a=write special register)
    equb &12                                                          ; special register ($12=track)
.osword_7f_block_write_special_register_track
    equb 0
.osword_7f_write_special_register_result
    equb 0
; TODO: I think the track and sector values in this block are logical tracks and rely
; on the previous step operation, but I'm not sure. I suspect this is done entirely for
; obfuscation and has been converted to file operations in this version, but I haven't
; actually checked that.
.osword_7f_block_read
    equb 0                                                            ; drive
    equw icodata,       0                                             ; data address
    equb 3                                                            ; number of parameters
    equb &53                                                          ; command ($53=read data)
    equb &7f                                                          ; track
    equb &7d                                                          ; sector
    equb &23                                                          ; size+count ($23=3 256 byte sectors)
.osword_7f_read_result
    equb 0
.drive_0_command
    equs "DRIVE "
.drive_number
    equb '0', &0d
.dir_dollar_command
    equs "DIR $"
    equb &0d

ENDIF
.icodata_read_ok
    lda #0                                                            ; Get the address of the first 'sprite' which is actually level ordering data
    jsr get_address_of_sprite_a
    stx address1_low
    sty address1_high
; Copy seventeen bytes of level ordering data into the level_ordering_table
    ldy #17
.copy_level_ordering_table_loop
    lda (address1_low),y
    sta level_ordering_table - 1,y
    dey
    bne copy_level_ordering_table_loop
; read the first byte of the data. If bit 6 is set then set the developer_flags.
    lda (address1_low),y
    and #%01000000
    beq skip_writing_developer_flags
    lda (address1_low),y
    and #%10111111
    sta developer_flags
.skip_writing_developer_flags
    jsr handle_developer_mode_setup
    lda #osbyte_reset_soft_keys
    jsr osbyte                                                        ; Reset function keys
    jsr reset_menu_items
    jsr draw_menu_icons
    lda screen_base_address_high
    pha
    lda #>toolbar_screen_address
    sta screen_base_address_high
    ldx #36
    ldy #6
    lda #spriteid_icodata_box
    jsr draw_sprite_a_at_cell_xy
    pla
    sta screen_base_address_high
IF swr_renderer_enabled
    LDA #0: STA swr_namespace
ELSE
    pla
    sta sprdata_ptr + 1
    pla
    sta sprdata_ptr
ENDIF
; start in one of four random levels
    lda #3
    jsr get_random_number_up_to_a
    sta initial_level_number_div4
    jmp start_game

.icodata_filename
    equs "icodata", &0d
.character_fe_bitmap
    equb %00001000
    equb %00010100
    equb %00100010
    equb %01000001
    equb %00100010
    equb %00010100
    equb %00001000
    equb %00000000
.initial_screen_disabled_flag
    equb 0

.handle_developer_mode_setup
    lda developer_flags
    and #1
    sta developer_mode_sideways_ram_is_set_up_flag
    beq return28
IF swr_boot_enabled
    ; Preserve the exit routine for Escape/BREAK, without touching asset data.
    PHP
    SEI
    LDA romsel_copy
    PHA
IF swr_renderer_enabled
    LDA swr_runtime_bank
ELSE
    LDA #swr_configured_bank
ENDIF
    STA romsel_copy
    STA romsel
    LDY #0
.copy_to_sideways_ram_loop2
    LDA quit_to_basic,Y
    STA sideways_ram_be00,Y
    LDA area_to_copy_to_or_from_sideways_ram,Y
    STA sideways_ram_bf00,Y
    INY
    BNE copy_to_sideways_ram_loop2
    PLA
    STA romsel_copy
    STA romsel
    PLP
ELSE
; The following code assumes there may be a ROM image stored in sideways RAM at $8000.
; It copies 16 bytes of an empty ROM image to the start of sideways RAM. This
; overwrites any existing ROM image held in sideways RAM. Is this some copy protection,
; or a development environment?
    ldy #sideways_rom_image_source_end - sideways_rom_image_source_start - 1
    sei
.copy_to_sideways_ram_loop1
    lda sideways_rom_image_source_start,y
    sta end_of_screen_memory,y
    dey
    bpl copy_to_sideways_ram_loop1
    cli
; Copy 256 bytes from quit_to_basic to $be00, and 256 bytes from $0b00 to $bf00.
    ldy #0
.copy_to_sideways_ram_loop2
    lda quit_to_basic,y
    sta sideways_ram_be00,y
    lda area_to_copy_to_or_from_sideways_ram,y
    sta sideways_ram_bf00,y
    iny
    bne copy_to_sideways_ram_loop2
ENDIF
    lda #osbyte_read_write_escape_break_effect
    ldx #1
    ldy #0
    jsr osbyte                                                        ; Write Disable ESCAPE action, set normal BREAK action, value X=1
; The reset intercept code is set to 'JMP reset_code'
    lda #osbyte_read_write_first_byte_break_intercept
; JMP opcode
    ldx #opcode_jmp
    ldy #0
    jsr osbyte                                                        ; Write reset intercept code (opcode), value X=76
    lda #osbyte_read_write_second_byte_break_intercept
    ldx #<reset_code
    ldy #0
    jsr osbyte                                                        ; Write reset intercept code (operand low), value X=69
    lda #osbyte_read_write_third_byte_break_intercept
    ldx #>reset_code
    ldy #0
    jsr osbyte                                                        ; Write reset intercept code (operand high), value X=24
.return28
    rts

.sideways_rom_image_source_start

    org &8000
.end_of_screen_memory
.sideways_rom_image_dest
    jmp sideways_rom_return                                           ; language entry point

    jmp sideways_rom_return                                           ; service entry point

    equb 0                                                            ; ROM type flag
    equb &0a                                                          ; empty copyright string

.sideways_rom_return
    rts                                                               ; do nothing - return

    equb 0, 0, 0, 0, 0, 0, 0                                          ; unused bytes
    org sideways_rom_image_source_start + (l8010 - end_of_screen_memory)
    copyblock end_of_screen_memory, l8010, sideways_rom_image_source_start
    clear end_of_screen_memory, l8010

.sideways_rom_image_source_end
.relocation4_high_copy_start

    org &0c00
; Initialise display
; 
; 1. Set toolbar and game area colours
; 2. Initialise the system timer to interrupt at the right time to change palettes
; 3. Initialise the irq routine address
; 4. Set the crtc registers
; 
.initialise_display
.collision_map
    lda #&ff
    sta display_initialised_flag
    lda pending_toolbar_colour
    sta toolbar_colour
    lda pending_gameplay_area_colour
    sta gameplay_area_colour
    sei
    lda #&7f
    sta user_via_ier
    lda #&c0
    sta system_via_acr
    lda #&ff
    sta system_via_t2c_l
    lda #&3c ; '<'
    sta system_via_ier
    lda #<irq1_routine
    sta irq1v
    lda #>irq1_routine
    sta irq1v+1
    cli
    jsr wait_for_vsync
    jsr wait_for_vsync
    lda #crtc_vert_sync_pos
    sta crtc_address_register
    lda vertical_sync_amount_for_crtc_register
    sta crtc_address_write
    lda #crtc_screen_start_low
    sta crtc_address_register
    lda #&78 ; 'x'
    sta crtc_address_write
    lda #crtc_screen_start_high
    sta crtc_address_register
    lda #&0b
    sta crtc_address_write
    lda #crtc_vert_displayed
    sta crtc_address_register
    lda #&1d
    sta crtc_address_write
    rts

    org sideways_rom_image_source_end + (l0c61 - initialise_display)
    copyblock initialise_display, l0c61, sideways_rom_image_source_end
    clear initialise_display, l0c61

.quit_to_basic
    sei
    lda old_irq1v
    sta irq1v
    lda old_irq1v+1
    sta irq1v+1
    cli
    lda #vdu_printer_off
    jsr oswrch                                                        ; Write character 3
    lda #vdu_set_mode
    jsr oswrch                                                        ; Write character 22
    lda #7
    jsr oswrch                                                        ; Write character 7
    lda #osbyte_set_cursor_editing
    ldx #0
    ldy #0
    jsr osbyte                                                        ; Enable cursor editing (X=0)
    lda #osbyte_read_write_escape_break_effect
    ldx #0
    ldy #0
    jsr osbyte                                                        ; Write Set normal ESCAPE action, set normal BREAK action, value X=0
    lda #osbyte_flush_buffer_class
    ldx #0
    jsr osbyte                                                        ; Flush all buffers (X=0)
    lda #0
    sta first_byte_break_intercept
    pla
    pla
    lda #'B'
    sta address1_low
    lda #'A'
    sta address1_low + 1
    lda #'S'
    sta address1_low + 2
    lda #'I'
    sta address1_low + 3
    lda #'C'
    sta address1_low + 4
    lda #vdu_cr
    sta address1_low + 5
    ldx #<(address1_low)
    ldy #>(address1_low)
    jmp oscli

.relocation3_high_copy_start

    org &0ab7
; *************************************************************************************
; 
; Clears $80 bytes from 'level_progress_table' to 'level_workspace'. This is almost all
; of the save game area, bar five bytes at the start which contain the level number,
; checksum, and three bytes for the ascii digits of the transformations remaining.
; These are filled in later.
; 
; *************************************************************************************
.clear_most_of_save_game
    lda #0
    tax
.clear_most_of_save_game_data_loop
    sta level_progress_table,x
    inx
    cpx #&80
    bcc clear_most_of_save_game_data_loop
    rts

; *************************************************************************************
.get_checksum_of_save_game_data
    lda #0
    tax
.get_checksum_loop
    eor level_progress_table,x
    inx
    cpx #&80
    bcc get_checksum_loop
    eor save_game
    eor #&ff
    rts

; *************************************************************************************
; 
; Convert a level filename letter into the section letter as shown in-game
; 
; The index within the level_ordering_table determines the letter returned.
; 
; On Entry:
;     Y: letter as seen in the level filename
; 
; On Exit:
;     Y: section letter (as seen in-game)
;     Preserves A, X
; 
; *************************************************************************************
.convert_level_filename_letter_into_section_letter
    cpy #last_level_letter
    beq return29
    pha                                                               ; remember A,X
    txa
    pha
    tya
    ldx #num_levels-1
.find_letter_loop
    cmp level_ordering_table+1,x
    beq found_letter
    dex
    bpl find_letter_loop
.found_letter
    txa
    clc
    adc #first_level_letter
    tay
    pla                                                               ; recall A,X
    tax
    pla
    rts

; *************************************************************************************
; 
; Convert a section letter into the level file letter
; 
; Simple look up.
; 
; On Entry:
;     Y: section letter (as seen in-game)
; 
; On Exit:
;     Y: letter as seen in the level filename
;     Preserves A, X
; 
; *************************************************************************************
.convert_section_letter_to_level_filename_letter
    cpy #last_level_letter
    beq return29
    pha
    tya
    sec
    sbc #first_level_letter
    tay
    lda level_ordering_table+1,y
    tay
    pla
.return29
    rts

    org relocation3_high_copy_start + (l0aff - clear_most_of_save_game)
    copyblock clear_most_of_save_game, l0aff, relocation3_high_copy_start
    clear clear_most_of_save_game, l0aff

.relocation3_high_copy_end
.relocation5_high_copy_start

    org &0131
; Update the transformation count on screen at text position (35-37, 6). This takes
; care to update as few digits on screen as possible, probably to reduce flicker and to
; offset the relatively slow implementation of print_italic.
.update_displayed_transformations_remaining
    pha                                                               ; remember A,X
    txa
    pha
    ldx #2
.digit_loop
    lda current_transformations_remaining,x
    cmp displayed_transformations_remaining,x
    beq digit_unchanged
    sta displayed_transformations_remaining,x
    lda #vdu_goto_xy
    jsr oswrch                                                        ; Write character 31
    txa
    eor #&ff
    sec
    adc #37
    jsr oswrch                                                        ; Write character
    lda #6
    jsr oswrch                                                        ; Write character 6
    lda displayed_transformations_remaining,x
    jsr print_italic
.digit_unchanged
    dex
    cpx #&ff
    bne digit_loop
    pla                                                               ; recall A,X
    tax
    pla
    rts

    org relocation3_high_copy_end + (l0160 - update_displayed_transformations_remaining)
    copyblock update_displayed_transformations_remaining, l0160, relocation3_high_copy_end
    clear update_displayed_transformations_remaining, l0160

.relocation5_high_copy_end
.icodata
.relocation1_high_copy_start

    org &0400
.wait_for_timingB_counter
    ldx timingB_counter_low
    ldy timingB_counter_high
    jmp wait_for_timer_2_using_yx

.current_text_width
    equb &12

.show_dialog_box
    jsr wait_for_timingB_counter
; check if a dialog box is already active
    lda which_dialog_is_active
    beq no_existing_dialog_box_shown
    jsr turn_cursor_off
; Replace dialog box
; Don't write to collision map
    ldx #collision_map_out_of_bounds
    stx value_to_write_to_collision_map
    inx
    stx only_ever_written_to_with_zero
; choose the 'all set' tile
    lda #<tile_all_set_pixels
    sta source_sprite_memory_low
    lda #>tile_all_set_pixels
    sta source_sprite_memory_high
; copy_mode = 1 (simple copy)
    inx
    stx copy_mode
    ldy #1
    lda current_text_width
    sec
    sbc #2
    sta width_in_cells
    lda #3
    sta height_in_cells
    jsr copy_rectangle_of_memory_to_screen
    jmp vdu_goto_0_9

.no_existing_dialog_box_shown
    lda #&ff
    sta which_dialog_is_active
    jsr remember_screen_memory_before_showing_dialog_box
    jsr plot_dialog_box
.vdu_goto_0_9
    lda #vdu_goto_xy
    jsr oswrch                                                        ; Write character 31
    lda #0
    jsr oswrch                                                        ; Write character 0
    lda #9
    jmp oswrch                                                        ; Write character 9

.remove_dialog
    lda which_dialog_is_active
    beq return30
; clear away the active dialog
    jsr wait_for_timingB_counter
    jsr turn_cursor_off
    ldx #collision_map_out_of_bounds
    stx value_to_write_to_collision_map
; copy_mode = 255 (just copy from memory in sequence)
    stx copy_mode
    inx
    stx which_dialog_is_active
    stx only_ever_written_to_with_zero
; copy from offscreen cache of what was underneath the dialog box
    lda #<cache_of_screen_memory_under_dialog
    sta source_sprite_memory_low
    lda #>cache_of_screen_memory_under_dialog
    sta source_sprite_memory_high
    jmp copy_to_rectangle_of_screen_memory_from_offscreen

.return30
    rts

.remember_screen_memory_before_showing_dialog_box
    lda #0                                                            ; set screen addresses
    sta first_cell_in_row_screen_address_low
    sta cell_screen_address_low
    lda screen_base_address_high
    sta first_cell_in_row_screen_address_high
    sta cell_screen_address_high
; set destination address
    lda #<cache_of_screen_memory_under_dialog
    sta off_screen_address_low
    lda #>cache_of_screen_memory_under_dialog
    sta off_screen_address_high
    clc
; set number of rows
    lda #5
    sta height_in_cells_to_write
.copy_row_loop
    ldx current_text_width
.copy_cells_loop
    ldy #7
.copy_cell_loop
    lda (cell_screen_address_low),y
    sta (off_screen_address_low),y
    dey
    bpl copy_cell_loop
; move destination to next cell along
    lda off_screen_address_low
    adc #8
    sta off_screen_address_low
    bcc skip_high_byte1
    inc off_screen_address_high
    clc
.skip_high_byte1
    dex
    beq move_to_next_row
; move source to next cell along
    lda cell_screen_address_low
    adc #8
    sta cell_screen_address_low
    bcc copy_cells_loop
    inc cell_screen_address_high
    clc
    bcc copy_cells_loop
.move_to_next_row
    dec height_in_cells_to_write
    beq return31
; move to next screen row
    lda first_cell_in_row_screen_address_low
    adc #&40 ; '@'
    sta first_cell_in_row_screen_address_low
    sta cell_screen_address_low
    lda first_cell_in_row_screen_address_high
    adc #1
    sta first_cell_in_row_screen_address_high
    sta cell_screen_address_high
    bcc copy_row_loop
.return31
    rts

.plot_dialog_box
    ldx #collision_map_out_of_bounds
    stx value_to_write_to_collision_map
    inx
    stx only_ever_written_to_with_zero
    stx plot_move_x_high
; choose the 'all set' tile
    lda #<tile_all_set_pixels
    sta source_sprite_memory_low
    lda #>tile_all_set_pixels
    sta source_sprite_memory_high
; copy_mode = 1 (simple copy)
    inx
    stx copy_mode
; draw blank background
    jsr copy_to_rectangle_of_screen_memory_from_offscreen
; draw dialog box outline (calculate X plot position based on text width)
    lda current_text_width
    asl a
    asl a
    asl a
    sec
    sbc #1
    asl a
    rol plot_move_x_high
    asl a
    sta plot_move_x_low
    rol plot_move_x_high
    ldy #0
.plot_loop
    lda plot_vdu_bytes,y
    jsr oswrch                                                        ; Write character
    iny
    cpy #18
    bcc plot_loop
    rts

.copy_to_rectangle_of_screen_memory_from_offscreen
    ldx #0
    ldy #0
    lda current_text_width
    sta width_in_cells
    lda #5
    sta height_in_cells
    jmp copy_rectangle_of_memory_to_screen

.plot_vdu_bytes
    equb &19,   4                                                     ; MOVE absolute
.plot_move_x_low
    equb 0
.plot_move_x_high
    equb 0
    equw 764                                                          ; Y coordinate
    equb &19,   1                                                     ; DRAW relative
    equw 0                                                            ; X coordinate
    equw 65380                                                        ; Y coordinate (-156)
    equb &19,   5                                                     ; DRAW absolute
    equw 0                                                            ; X coordinate
    equw 608                                                          ; Y coordinate
    org relocation5_high_copy_end + (l0527 - wait_for_timingB_counter)
    copyblock wait_for_timingB_counter, l0527, relocation5_high_copy_end
    clear wait_for_timingB_counter, l0527

.pydis_end

save "build/g", pydis_start, pydis_end
PRINT "start: ", ~pydis_start, ", end: ", ~pydis_end
PRINT "execution start address: ", ~execution_start
PRINT "bytes used vs original: ", (level_data - &3AD5)
PRINT "ENGINE_EXPORTS_BEGIN"
PRINT "g_load_address = ", ~pydis_start
PRINT "g_execution_address = ", ~execution_start
PRINT "sprite_op_flags                                      = ", ~sprite_op_flags
PRINT "sprite_id                                            = ", ~sprite_id
PRINT "sprite_x_base_low                                    = ", ~sprite_x_base_low
PRINT "sprite_x_base_high                                   = ", ~sprite_x_base_high
PRINT "sprite_y_base_low                                    = ", ~sprite_y_base_low
PRINT "sprite_y_base_high                                   = ", ~sprite_y_base_high
PRINT "sprite_reflect_flag                                  = ", ~sprite_reflect_flag
PRINT "desired_room_index                                   = ", ~desired_room_index
PRINT "current_level                                        = ", ~current_level
PRINT "temp_sprite_x_offset                                 = ", ~temp_sprite_x_offset
PRINT "temp_sprite_y_offset                                 = ", ~temp_sprite_y_offset
PRINT "width_in_cells                                       = ", ~width_in_cells
PRINT "height_in_cells                                      = ", ~height_in_cells
PRINT "value_to_write_to_collision_map                      = ", ~value_to_write_to_collision_map
PRINT "source_sprite_memory_low                             = ", ~source_sprite_memory_low
PRINT "source_sprite_memory_high                            = ", ~source_sprite_memory_high
PRINT "copy_mode                                            = ", ~copy_mode
PRINT "current_player_character                             = ", ~current_player_character
PRINT "previous_room_index                                  = ", ~previous_room_index
PRINT "level_before_latest_level_and_room_initialisation    = ", ~level_before_latest_level_and_room_initialisation
PRINT "player_held_object_spriteid                          = ", ~player_held_object_spriteid
PRINT "developer_mode_sideways_ram_is_set_up_flag           = ", ~developer_mode_sideways_ram_is_set_up_flag
PRINT "object_x_low                                         = ", ~object_x_low
PRINT "object_x_low_old                                     = ", ~object_x_low_old
PRINT "object_x_high                                        = ", ~object_x_high
PRINT "object_x_high_old                                    = ", ~object_x_high_old
PRINT "object_y_low                                         = ", ~object_y_low
PRINT "object_y_low_old                                     = ", ~object_y_low_old
PRINT "object_y_high                                        = ", ~object_y_high
PRINT "object_spriteid                                      = ", ~object_spriteid
PRINT "object_spriteid_old                                  = ", ~object_spriteid_old
PRINT "object_direction                                     = ", ~object_direction
PRINT "current_player_animation                             = ", ~current_player_animation
PRINT "level_workspace                                      = ", ~level_workspace
PRINT "tile_all_set_pixels                                  = ", ~tile_all_set_pixels
PRINT "developer_flags                                      = ", ~developer_flags
PRINT "initialise_level_and_room                            = ", ~initialise_level_and_room
PRINT "start_room                                           = ", ~start_room
PRINT "game_update                                          = ", ~game_update
PRINT "update_room_first_update_flag                        = ", ~update_room_first_update_flag
PRINT "sprite_op                                            = ", ~sprite_op
PRINT "toolbar_colour                                       = ", ~toolbar_colour
PRINT "gameplay_area_colour                                 = ", ~gameplay_area_colour
PRINT "get_random_number_up_to_a                            = ", ~get_random_number_up_to_a
PRINT "update_brazier_and_fire                              = ", ~update_brazier_and_fire
PRINT "update_level_completion                              = ", ~update_level_completion
PRINT "currently_updating_logic_for_room_index              = ", ~currently_updating_logic_for_room_index
PRINT "copy_rectangle_of_memory_to_screen                   = ", ~copy_rectangle_of_memory_to_screen
PRINT "draw_floor_walls_and_ceiling_around_solid_rock       = ", ~draw_floor_walls_and_ceiling_around_solid_rock
PRINT "draw_rope                                            = ", ~draw_rope
PRINT "write_value_to_a_rectangle_of_cells_in_collision_map = ", ~write_value_to_a_rectangle_of_cells_in_collision_map
PRINT "write_a_single_value_to_cell_in_collision_map        = ", ~write_a_single_value_to_cell_in_collision_map
PRINT "read_collision_map_value_for_xy                      = ", ~read_collision_map_value_for_xy
PRINT "draw_sprite_a_at_cell_xy                             = ", ~draw_sprite_a_at_cell_xy
PRINT "draw_sprite_a_at_cell_xy_and_write_to_collision_map  = ", ~draw_sprite_a_at_cell_xy_and_write_to_collision_map
PRINT "set_object_position_from_cell_xy                     = ", ~set_object_position_from_cell_xy
PRINT "set_object_position_from_current_sprite_position     = ", ~set_object_position_from_current_sprite_position
PRINT "copy_object_state_to_old                             = ", ~copy_object_state_to_old
PRINT "jmp_for_update_extra_player_character                = ", ~jmp_for_update_extra_player_character
PRINT "play_landing_sound                                   = ", ~play_landing_sound
PRINT "player_wall_collision_reaction_speed                 = ", ~player_wall_collision_reaction_speed
PRINT "find_left_and_right_of_object                        = ", ~find_left_and_right_of_object
PRINT "temp_left_offset                                     = ", ~temp_left_offset
PRINT "temp_right_offset                                    = ", ~temp_right_offset
PRINT "find_top_and_bottom_of_object                        = ", ~find_top_and_bottom_of_object
PRINT "temp_top_offset                                      = ", ~temp_top_offset
PRINT "temp_bottom_offset                                   = ", ~temp_bottom_offset
PRINT "update_object_a_solid_rock_collision                 = ", ~update_object_a_solid_rock_collision
PRINT "update_object_hitting_floor                          = ", ~update_object_hitting_floor
PRINT "object_has_hit_floor_flag                            = ", ~object_has_hit_floor_flag
PRINT "object_just_fallen_off_edge_direction                = ", ~object_just_fallen_off_edge_direction
PRINT "get_solid_rock_collision_for_object_a                = ", ~get_solid_rock_collision_for_object_a
PRINT "temp_default_collision_map_option                    = ", ~temp_default_collision_map_option
PRINT "test_for_collision_between_objects_x_and_y           = ", ~test_for_collision_between_objects_x_and_y
PRINT "desired_menu_slots                                   = ", ~desired_menu_slots
PRINT "menu_index_for_extra_items                           = ", ~menu_index_for_extra_items
PRINT "insert_character_menu_item_into_toolbar              = ", ~insert_character_menu_item_into_toolbar
PRINT "find_or_create_menu_slot_for_A                       = ", ~find_or_create_menu_slot_for_A
PRINT "remove_item_from_toolbar_menu                        = ", ~remove_item_from_toolbar_menu
PRINT "player_using_object_spriteid                         = ", ~player_using_object_spriteid
PRINT "previous_player_using_object_spriteid                = ", ~previous_player_using_object_spriteid
PRINT "toolbar_collectable_spriteids                        = ", ~toolbar_collectable_spriteids
PRINT "collectable_spriteids                                = ", ~collectable_spriteids
PRINT "collectable_being_used_spriteids                     = ", ~collectable_being_used_spriteids
PRINT "monkey_base_animation                                = ", ~monkey_base_animation
PRINT "monkey_climb_idle_animation                          = ", ~monkey_climb_idle_animation
PRINT "monkey_climb_down_animation                          = ", ~monkey_climb_down_animation
PRINT "monkey_climb_animation                               = ", ~monkey_climb_animation
PRINT "inhibit_monkey_climb_flag                            = ", ~inhibit_monkey_climb_flag
PRINT "object_erase_type                                    = ", ~object_erase_type
PRINT "object_z_order                                       = ", ~object_z_order
PRINT "object_room_collision_flags                          = ", ~object_room_collision_flags
PRINT "play_sound_yx                                        = ", ~play_sound_yx
PRINT "define_envelope                                      = ", ~define_envelope
PRINT "sound_priority_per_channel_table                     = ", ~sound_priority_per_channel_table
PRINT "negative_inkey                                       = ", ~negative_inkey
PRINT "level_data_load_address                              = ", ~level_data
PRINT "set_player_spriteid_and_offset_from_animation_table  = ", ~set_player_spriteid_and_offset_from_animation_table
PRINT "update_player_accessory_object_animation             = ", ~update_player_accessory_object_animation
PRINT "transform_out_animation                              = ", ~transform_out_animation
PRINT "set_base_animation_address_and_handle_transform_in_out = ", ~set_base_animation_address_and_handle_transform_in_out
PRINT "update_player_hitting_floor_or_pushed                = ", ~update_player_hitting_floor_or_pushed
PRINT "jump_requested                                       = ", ~jump_requested
PRINT "player_move_direction_requested                      = ", ~player_move_direction_requested
PRINT "move_left_requested                                  = ", ~move_left_requested
PRINT "move_right_requested                                 = ", ~move_right_requested
PRINT "start_game                                           = ", ~start_game
PRINT "osfile_wrapper                                       = ", ~osfile_wrapper
PRINT "vsync_counter                                        = ", ~vsync_counter
PRINT "wait_for_vsync                                       = ", ~wait_for_vsync
PRINT "reset_game_because_escape_pressed                    = ", ~reset_game_because_escape_pressed
PRINT "displayed_menu_slots                                 = ", ~displayed_menu_slots
PRINT "reset_menu_items                                     = ", ~reset_menu_items
PRINT "draw_menu_icons                                      = ", ~draw_menu_icons
PRINT "prompt_user_to_insert_correct_disc                   = ", ~prompt_user_to_insert_correct_disc
PRINT "print_encrypted_string_at_yx                         = ", ~print_encrypted_string_at_yx
PRINT "inkey_0                                              = ", ~inkey_0
PRINT "pending_toolbar_colour                               = ", ~pending_toolbar_colour
PRINT "pending_gameplay_area_colour                         = ", ~pending_gameplay_area_colour
PRINT "use_colour_flag                                      = ", ~use_colour_flag
PRINT "set_toolbar_and_gameplay_area_colours                = ", ~set_toolbar_and_gameplay_area_colours
PRINT "jmp_yx                                               = ", ~jmp_yx
PRINT "print_encrypted_string_at_yx_centred                 = ", ~print_encrypted_string_at_yx_centred
PRINT "wait_one_second_then_check_keys                      = ", ~wait_one_second_then_check_keys
PRINT "check_menu_keys                                      = ", ~check_menu_keys
PRINT "swr_invalidate_caches = ", ~swr_invalidate_caches
PRINT "swr_live_bank_address = ", ~swr_runtime_bank
PRINT "ENGINE_EXPORTS_END"
