; Constants
is_level = TRUE
INCLUDE "src/globals.asm"
fixed_eor_key                                  = 203
osbyte_flush_buffer_class                      = 15
osbyte_read_write_escape_break_effect          = 200
osbyte_read_write_first_byte_break_intercept   = 247
vdu_cr                                         = 13
vdu_lf                                         = 10

; Memory locations
characters_entered                                  = &0005
game_area_screen_address_high                       = &004c
screen_address_low                                  = &0070
screen_address_high                                 = &0071
counter                                             = &0072
screendump_data_byte                                = &0073
invert_screen_dump_flag                             = &0074
show_dialog_box                                     = &040a
remove_dialog                                       = &0453
object_y_high_old                                   = &099d
object_direction_old                                = &09c9
level_progress_table                                = &09ef
string_input_buffer                                 = &0a90
level_data                                          = level_data_load_address
level_specific_initialisation_ptr                   = level_data + 2
level_specific_update_ptr                           = level_specific_initialisation_ptr + 2
level_specific_password_ptr                         = level_specific_update_ptr + 2
initial_room_index                                  = level_specific_password_ptr + 2
initial_room_index_cheat                            = initial_room_index + 1
level_room_data_table                               = initial_room_index_cheat + 1
oswrch                                              = &ffee
osbyte                                              = &fff4

org &53c0

; Check a password entered by the user at string_buffer against the list of EOR-
; encrypted paswords at password_ptr_table and invoke the corresponding handler if a
; match is found. Otherwise generate an error.
.auxcode
.check_password
.pydis_start
    ldy #0
    sty characters_entered
    sty counter
    lda #<password_ptr_table
    sta screen_address_low
    lda #>password_ptr_table
    sta screen_address_high
.check_password_loop
    lda (screen_address_low),y
    eor #&cb
    cmp string_input_buffer,y
    bne this_entry_doesnt_match
    iny
    cmp #vdu_cr
    bne check_password_loop
    lda (screen_address_low),y
    tax
    iny
    lda (screen_address_low),y
    tay
; At this point we have the level pointer for the successfully matched password in YX
    lda counter
    pha
    txa
    pha
    tya
    pha
    jsr show_dialog_box
    lda #&0a
    jsr oswrch                                                        ; Write character 10
    ldx #<accepted_encrypted_string
    ldy #>accepted_encrypted_string
    jsr print_encrypted_string_at_yx_centred
    jsr wait_one_second_then_check_keys
    jsr remove_dialog
    pla
    tay
    pla
    tax
    pla
    jmp jmp_yx

.accepted_encrypted_string
    encode "Accepted", &0D

.skip_rest_of_entry
    lda (screen_address_low),y
    eor #fixed_eor_key
.this_entry_doesnt_match
    iny
    cmp #vdu_cr
    bne skip_rest_of_entry
    iny
    tya
    adc screen_address_low                                            ; effectively adds l0070+1 as cmp # above set Z and thus C: TODO: correct?
    sta screen_address_low
    lda screen_address_high
    adc #0
    sta screen_address_high
    inc counter
    ldy #0
    lda (screen_address_low),y
    eor #fixed_eor_key
    bne check_password_loop
; None of the passwords in the table matched.
    jsr show_dialog_box
    lda #vdu_lf
    jsr oswrch                                                        ; Write character 10
    ldx #<unknown_encrypted_string
    ldy #>unknown_encrypted_string
    jsr print_encrypted_string_at_yx_centred
    jsr wait_one_second_then_check_keys
    lda #0
    jmp return1

.unknown_encrypted_string
    encode "Unknown", &0D

.return1
    rts

.password_ptr_table
    encode "SAXOPHOBIA", &0D
    equw normal_level_handler
    encode "TIME-FLIES", &0D
    equw normal_level_handler
    encode "FIRE-WORKS", &0D
    equw normal_level_handler
    encode "GNU-PROBLEM", &0D
    equw normal_level_handler
    encode "DUCK-EGG-BLUES", &0D
    equw normal_level_handler
    encode "FOLLOW-ME", &0D
    equw normal_level_handler
    encode "BALLOONACY", &0D
    equw normal_level_handler
    encode "APPLESOURCE", &0D
    equw normal_level_handler
    encode "SEE-SWORD", &0D
    equw normal_level_handler
    encode "BABBOONACY", &0D
    equw normal_level_handler
    encode "DRIPPING-STUFF", &0D
    equw normal_level_handler
    encode "WHIP-IT", &0D
    equw normal_level_handler
    encode "HAMSTER-JAM", &0D
    equw normal_level_handler
    encode "PAVLOV-WAS-HERE", &0D
    equw normal_level_handler
    encode "DOWN-AND-OUT", &0D
    equw normal_level_handler
    encode "TENDER-HOOKS", &0D
    equw normal_level_handler
; Some intriguing secret passwords here. The Micro User printed these (See
; https://archive.org/details/micro-user-058/page/n52/mode/1up), but still cool to find
; them for myself. :-)
    encode "EPILOGUE", &0D
    equw epilogue_handler
    encode "DUMP", &0D
    equw dump_handler
    encode "MONO", &0D
    equw mono_handler
    encode "COLOUR", &0D
    equw colour_handler
    encode "QUIT", &0D
    equw quit_handler
    encode "NORMAL-MODE", &0D
    equw normal_mode_handler
    encode "REVIEW-MODE", &0D
    equw review_mode_handler
    encode "TEST-MODE", &0D
    equw test_mode_handler
    encode "DEBUG-MODE", &0D
    equw debug_mode_handler
    encode "GIMME", &0D
    equw gimme_handler
    encode "", &00                                                          ; marks the end of the table

.normal_level_handler
    clc
    adc #first_level_letter
    jmp return1

.epilogue_handler
    ldx #last_level_letter
    lda developer_flags
    and #2
    bne play_epilogue
    ldx #1
.play_epilogue
    txa
    jmp return1

.quit_handler
    lda #&ff
    jmp return1

.normal_mode_handler
    lda #0
    jmp set_developer_flags_and_continue

.review_mode_handler
    lda #2
    jmp set_developer_flags_and_continue

.test_mode_handler
    lda #3
    jmp set_developer_flags_and_continue

.debug_mode_handler
    lda #&83
.set_developer_flags_and_continue
    sta developer_flags
    ldx #0
    ldy #3
    and #1
    beq set_up_break_effects
    lda developer_mode_sideways_ram_is_set_up_flag
    beq set_up_break_effects
    ldx #opcode_jmp
; For break effect: *FX 200,1
    ldy #1
.set_up_break_effects
    tya
    pha
    lda #osbyte_read_write_first_byte_break_intercept
    ldy #0
    jsr osbyte                                                        ; Write reset intercept code (opcode), value X=76
    pla
    tax
    lda #osbyte_read_write_escape_break_effect
    ldy #0
    jsr osbyte                                                        ; Write ESCAPE+BREAK effects
    lda #1
    jmp return1

.mono_handler
    lda #0
    sta use_colour_flag
    jsr set_toolbar_and_gameplay_area_colours
    lda pending_toolbar_colour
    sta toolbar_colour
    lda pending_gameplay_area_colour
    sta gameplay_area_colour
    lda #1
    jmp return1

.colour_handler
    lda #&ff
    sta use_colour_flag
    jsr set_toolbar_and_gameplay_area_colours
    lda pending_toolbar_colour
    sta toolbar_colour
    lda pending_gameplay_area_colour
    sta gameplay_area_colour
    lda #1
    jmp return1

.gimme_handler
    lda developer_flags
    and #1
    beq return_a_one
    ldy #&0f
.mark_all_levels_complete_loop
    lda level_progress_table,y
    ora #&80
    sta level_progress_table,y
    dey
    bpl mark_all_levels_complete_loop
    lda #spriteid_menu_item_completion_spell
    jsr find_or_create_menu_slot_for_A
.return_a_one
    lda #1
    jmp return1

.power_of_2_table
    equb &01, &02, &04, &08, &10, &20, &40, &80

; A screen dump routine for Epson-compatible printers
.dump_handler
    lda developer_flags
    and #2
    bne screen_dump_to_epson_printer
    lda #1
    jmp return1

.screen_dump_to_epson_printer
    lda #2                                                            ; turn on printer output
    jsr oswrch                                                        ; Write character 2
; 'ESC 64': Reset printer to its power up state
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1b
    jsr oswrch                                                        ; Write character 27
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&40 ; '@'
    jsr oswrch                                                        ; Write character 64
; '10': Line feed
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&0a
    jsr oswrch                                                        ; Write character 10
; 'ESC $6C $11': ?
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1b
    jsr oswrch                                                        ; Write character 27
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&6c ; 'l'
    jsr oswrch                                                        ; Write character 108
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&11
    jsr oswrch                                                        ; Write character 17
; 'ESC $41 $08': Set line spacing to 8/72 inch
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1b
    jsr oswrch                                                        ; Write character 27
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&41 ; 'A'
    jsr oswrch                                                        ; Write character 65
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #8
    jsr oswrch                                                        ; Write character 8
; start of screen memory
    lda #&c0
    sta screen_address_low
    lda #&5b ; '['
    sta screen_address_high
    lda #&ff
    sta invert_screen_dump_flag
; 'ESC 42 2A 05 40': Turn on graphics mode, followed by 16389 characters
.turn_on_graphics_mode_for_a_row_of_graphics
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1b
    jsr oswrch                                                        ; Write character 27
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&2a ; '*'
    jsr oswrch                                                        ; Write character 42
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #5
    jsr oswrch                                                        ; Write character 5
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&40 ; '@'
    jsr oswrch                                                        ; Write character 64
    lda #1
    jsr oswrch                                                        ; Write character 1
    jsr oswrch                                                        ; Write character
    lda #&28 ; '('
    sta counter
    bne screendump_character_row_loop
.add_another_row_of_graphics_characters
    clc
    bcc turn_on_graphics_mode_for_a_row_of_graphics
.screendump_character_row_loop
    ldx #7
.eight_bytes_of_screen_dump_loop
    ldy #0
    sty screendump_data_byte
.get_byte_of_screen_data_loop
    asl screendump_data_byte
    lda (screen_address_low),y
    and power_of_2_table,x
    bne skip1
    inc screendump_data_byte
.skip1
    iny
    cpy #8
    bne get_byte_of_screen_data_loop
; write byte of data
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda screendump_data_byte
    eor invert_screen_dump_flag
    jsr oswrch                                                        ; Write character
    dex
    bpl eight_bytes_of_screen_dump_loop
; move screen address on by eight
    clc
    lda screen_address_low
    adc #8
    sta screen_address_low
    bcc skip2
    inc screen_address_high
; when we reach the game area of the screen, stop inverting the output
    lda screen_address_high
    cmp game_area_screen_address_high
    bne skip2
    lda #0
    sta invert_screen_dump_flag
.skip2
    dec counter
    bne screendump_character_row_loop
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&0a
    jsr oswrch                                                        ; Write character 10
    lda screen_address_high
    cmp #&80
    bcc add_another_row_of_graphics_characters
; '10': Line feed
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&0a
    jsr oswrch                                                        ; Write character 10
; 'ESC $40': reset printer
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1b
    jsr oswrch                                                        ; Write character 27
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&40 ; '@'
    jsr oswrch                                                        ; Write character 64
; twelve line feeds
    ldy #&0c
.line_feed_loop
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&0a
    jsr oswrch                                                        ; Write character 10
    dey
    bne line_feed_loop
; beep
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #7
    jsr oswrch                                                        ; Write character 7
; printer off
    lda #3
    jsr oswrch                                                        ; Write character 3
    lda #osbyte_flush_buffer_class
    ldx #1
    jsr osbyte                                                        ; Flush input buffers (X non-zero)
    jsr check_menu_keys
    lda #1
    jmp return1

.pydis_end

save "build/auxcode", pydis_start, pydis_end
