; Heavily optimized to try and get the single-pixel scrolling done before the
; beam to avoid flicker. 
; Code was too big to fit in memory on load, so unpacks unrolled code after load.
; The high-memory layouts below supply the templates and addresses for
; generate_scroll_code, which creates the repeated code at entry.
;
; *************************************************************************************
;
; Level Q: 'EPILOGUE'
;
; Shows a scrolling message to tie in with the back story of Imogen (see 'encoded_message'),
; then displays a copyright message (see copyright_message) and 'The End' in large letters
; (a bitmap). At this point an infinite loop is entered. The player must reset the machine.
;
; The character definitions are embedded (an italic version of the standard BBC characters).
;
; Developer mode retains the optional up-arrow pause. The unused restart
; path and development BASIC fragment have been removed from this variant.
;
; *************************************************************************************

; Supporting macros
; *****************
; Emit byte offsets of non-space character columns, relative to x=32.
; MID$ indexes from 1, so column (index-1) becomes offset (index-1)*8.
; &FF terminates the list; the counted copy loop does not read it.
MACRO copy_columns text
    ASSERT LEN(text) <= 25
    IF LEN(text) > 0 ; BeebAsm FOR runs once even when the end is below the start.
        FOR index, 1, LEN(text)
            IF ASC(MID$(text, index, 1)) <> &20
                EQUB (index-1)*8
            ENDIF
        NEXT
    ENDIF
    EQUB &FF
ENDMACRO

; Encode a line with a selectable final byte: CR between lines, NUL at end.
MACRO ending_encode text, terminator
    IF LEN(text) > 0 ; BeebAsm FOR runs once even when the end is below the start.
        FOR index, 1, LEN(text)
            EQUB ASC(MID$(text, index, 1)) EOR &CB
        NEXT
    ENDIF
    EQUB terminator EOR &CB
ENDMACRO

; Constants
INCLUDE "build/swr_boot_config.asm"
is_level = TRUE
INCLUDE "src/globals.asm"
colour_white                    = 7
inkey_key_escape                = 143
inkey_up_cursor                 = 198
osbyte_flush_buffer_class       = 15

; Memory locations
current_menu_index                                  = &002e
sprdata_ptr                                         = &0054
bitmap_address_low                                  = &0070
filename_address_low                                = &0070
message_address_low                                 = &0070
screen_address_low                                  = &0070
bitmap_address_high                                 = &0071
filename_address_high                               = &0071
l0071                                               = &0071
message_address_high                                = &0071
screen_address_high                                 = &0071
l0072                                               = &0072
message_offset_low                                  = &0072
screen_address1_low                                 = &0072
l0073                                               = &0073
screen_address1_high                                = &0073
screen_y_offset_within_cell                         = &0073
l0074                                               = &0074
l0075                                               = &0075
l0076                                               = &0076
l0077                                               = &0077
l0078                                               = &0078
l0079                                               = &0079
l007a                                               = &007a
l007b                                               = &007b
character_definition_low                            = &007c
character_definition_high                           = &007d
l0ab1                                               = &0ab1
l0ab2                                               = &0ab2
oswrch                                              = &ffee
osbyte                                              = &fff4

org level_data_load_address

.level_data
.pydis_start
IF swr_renderer_enabled
    EQUW 0 ; no sprite directory in the direct bitmap/text epilogue
ELSE
    equw &0c3b
ENDIF
.level_specific_initialisation_ptr
    equw level_specific_update_ptr

.level_specific_update_ptr
    pla
    pla
.level_specific_password_ptr
    jsr wait_for_vsync
    jsr wait_for_vsync
    jsr clear_screen
; Generate after clearing: a relocated workspace can extend into &5B80..&5BBF,
; which clear_screen also erases before the visible screen at &5BC0.
    jsr generate_scroll_code
; make toolbar palette white so all text appears white
    lda #colour_white
    sta toolbar_colour
    sta gameplay_area_colour
; wait 2 seconds
    lda #100
    jsr wait_for_a_vsyncs
; start the scrolling message
    lda #7
    sta screen_y_offset_within_cell
    lda #&20 ; ' '
    sta l0074
    lda #&80
    sta l0075
    lda #<encoded_message
    sta stream_message_low
    lda #>encoded_message
    sta stream_message_high
    lda #0
    sta stream_phase
    sta copy_line_number
    lda #<712
    sta stream_remaining
    lda #>712
    sta stream_remaining+1
    jsr copy_prepare_update
    jsr wait_for_vsync
.display_full_message_loop
    lda #0
    sta vsync_counter
    jsr check_for_escape_pressed_in_developer_mode
    jsr scroll_copy
    jsr stream_bottom_row
    jmp end_of_message

.end_of_message
    lda stream_remaining
    bne stream_decrement_low
    dec stream_remaining+1
.stream_decrement_low
    dec stream_remaining
    lda stream_remaining
    ora stream_remaining+1
    beq copy_the_end_bitmap_to_screen
.move_up_one_pixel
    lda screen_y_offset_within_cell
    sec
    sbc #1
    and #7
    sta screen_y_offset_within_cell
    bcs check_for_up_arrow_in_developer_mode
; move up one character row
    lda l0074
    sec
    sbc #&40 ; '@'
    sta l0074
    lda l0075
    sbc #1
    sta l0075
.check_for_up_arrow_in_developer_mode
    jsr copy_prepare_update
    lda developer_flags
    and #1
    beq wait_four_vsyncs_loop
    ldx #inkey_up_cursor
    jsr negative_inkey
    bne display_full_message_loop_local
; wait until four vsyncs have passed and repeat
.wait_four_vsyncs_loop
    lda vsync_counter
    cmp #4
    bcc wait_four_vsyncs_loop
.display_full_message_loop_local
    jmp display_full_message_loop

.copy_the_end_bitmap_to_screen
    lda #50
    jsr wait_for_a_vsyncs
; Decode the small ending bitmap directly to its final screen address.
    lda #<the_end_bitmap
    sta &70
    lda #>the_end_bitmap
    sta &71
    lda #&80
    sta &72
    lda #&69
    sta &73
    ldy #0
.ending_rle_run
    lda (&70),y
    tax
    iny
    lda (&70),y
    ldy #0
.ending_rle_byte
    sta (&72),y
    inc &72
    bne ending_rle_next
    inc &73
.ending_rle_next
    dex
    bne ending_rle_byte
    lda &70
    clc
    adc #2
    sta &70
    bcc ending_rle_source_ready
    inc &71
.ending_rle_source_ready
    lda &72
    cmp #&40
    bne ending_rle_run
    lda &73
    cmp #&6d
    bne ending_rle_run
; clear text and graphics windows
    lda #&1a
    jsr oswrch                                                        ; Write character 26
; change background colour to black (logical colour 0)
    lda #&11
    jsr oswrch                                                        ; Write character 17
    lda #&80
    jsr oswrch                                                        ; Write character 128
; change foreground colour to white (logical colour 1)
    lda #&11
    jsr oswrch                                                        ; Write character 17
    lda #1
    jsr oswrch                                                        ; Write character 1
; set cursor position to (3, 20)
    lda #&1f
    jsr oswrch                                                        ; Write character 31
    lda #3
    jsr oswrch                                                        ; Write character 3
    lda #&14
    jsr oswrch                                                        ; Write character 20
; show copyright message
    ldx #<copyright_message
    ldy #>copyright_message
    jsr print_encrypted_string_at_yx
; set text window to (left, bottom, right, top) = (1, 31, 39, 9)
    lda #&1c
    jsr oswrch                                                        ; Write character 28
    lda #1
    jsr oswrch                                                        ; Write character 1
    lda #&1f
    jsr oswrch                                                        ; Write character 31
    lda #&27 ; '''
    jsr oswrch                                                        ; Write character 39
    lda #9
    jsr oswrch                                                        ; Write character 9
; reset background colour to logical colour 1
    lda #&11
    jsr oswrch                                                        ; Write character 17
    lda #&81
    jsr oswrch                                                        ; Write character 129
; reset foreground colour to logical colour 0
    lda #&11
    jsr oswrch                                                        ; Write character 17
    lda #0
    jsr oswrch                                                        ; Write character 0
    jmp the_end_loop

; 'Copyright Micro Power Limited 1986[0d]' EOR-encrypted with $cb
.copyright_message
    encode "Copyright Micro Power Limited 1986", &0D

.clear_screen
IF swr_renderer_enabled
    LDA #0: STA &0BEF: STA &0BF0: STA &0BEE
    JSR swr_invalidate_caches
ENDIF
    lda #0
    sta screen_address_low
    lda #&5b ; '['
    sta screen_address_high
    lda #0
    ldx #&80
    ldy #&c0
.clear_screen_loop
    sta (screen_address_low),y
    iny
    bne clear_screen_loop
    inc screen_address_high
    cpx screen_address_high
    bne clear_screen_loop
    rts

.check_for_escape_pressed_in_developer_mode
    lda developer_mode_sideways_ram_is_set_up_flag
    beq return1
    lda developer_flags
    and #1
    beq return1
    ldx #inkey_key_escape
    jsr negative_inkey
    beq return1
; reset game
    pla
    pla
    jmp reset_game_because_escape_pressed

.return1
    rts

.character_definitions
; Font subset copied from the original dataQ.asm character_definitions.
; Keep only non-space glyphs actually used by the message.
; Suffixes are decimal ASCII codes (65 = A).
; Each glyph retains its eight original bytes: top-to-bottom pixel rows,
; bit 7 at the left. Spaces are handled by the renderer without a glyph.
.ending_glyph_44 ; ASCII 44: ","
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00110000
    EQUB %00110000
    EQUB %01100000
.ending_glyph_46 ; ASCII 46: "."
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00110000
    EQUB %00110000
    EQUB %00000000
.ending_glyph_65 ; ASCII 65: "A"
    EQUB %00011110
    EQUB %00110011
    EQUB %01100110
    EQUB %01111110
    EQUB %01100110
    EQUB %11001100
    EQUB %11001100
    EQUB %00000000
.ending_glyph_69 ; ASCII 69: "E"
    EQUB %00111111
    EQUB %00110000
    EQUB %01100000
    EQUB %01111100
    EQUB %01100000
    EQUB %11000000
    EQUB %11111100
    EQUB %00000000
.ending_glyph_73 ; ASCII 73: "I"
    EQUB %00111111
    EQUB %00001100
    EQUB %00011000
    EQUB %00011000
    EQUB %00011000
    EQUB %00110000
    EQUB %11111100
    EQUB %00000000
.ending_glyph_97 ; ASCII 97: "a"
    EQUB %00000000
    EQUB %00000000
    EQUB %00111100
    EQUB %00000110
    EQUB %00111110
    EQUB %11001100
    EQUB %01111100
    EQUB %00000000
.ending_glyph_98 ; ASCII 98: "b"
    EQUB %00110000
    EQUB %00110000
    EQUB %01111100
    EQUB %01100110
    EQUB %01100110
    EQUB %11001100
    EQUB %11111000
    EQUB %00000000
.ending_glyph_99 ; ASCII 99: "c"
    EQUB %00000000
    EQUB %00000000
    EQUB %00111100
    EQUB %01100110
    EQUB %01100000
    EQUB %11001100
    EQUB %01111000
    EQUB %00000000
.ending_glyph_100 ; ASCII 100: "d"
    EQUB %00000011
    EQUB %00000011
    EQUB %00111110
    EQUB %01100110
    EQUB %01100110
    EQUB %11001100
    EQUB %01111100
    EQUB %00000000
.ending_glyph_101 ; ASCII 101: "e"
    EQUB %00000000
    EQUB %00000000
    EQUB %00111100
    EQUB %01100110
    EQUB %01111110
    EQUB %11000000
    EQUB %01111000
    EQUB %00000000
.ending_glyph_102 ; ASCII 102: "f"
    EQUB %00001110
    EQUB %00011000
    EQUB %00110000
    EQUB %01111100
    EQUB %00110000
    EQUB %01100000
    EQUB %01100000
    EQUB %00000000
.ending_glyph_103 ; ASCII 103: "g"
    EQUB %00000000
    EQUB %00000000
    EQUB %00111110
    EQUB %01100110
    EQUB %01100110
    EQUB %01111100
    EQUB %00001100
    EQUB %01111000
.ending_glyph_104 ; ASCII 104: "h"
    EQUB %00110000
    EQUB %00110000
    EQUB %01111100
    EQUB %01100110
    EQUB %01100110
    EQUB %11001100
    EQUB %11001100
    EQUB %00000000
.ending_glyph_105 ; ASCII 105: "i"
    EQUB %00001100
    EQUB %00000000
    EQUB %00111000
    EQUB %00011000
    EQUB %00011000
    EQUB %00110000
    EQUB %01111000
    EQUB %00000000
.ending_glyph_107 ; ASCII 107: "k"
    EQUB %00110000
    EQUB %00110000
    EQUB %01100110
    EQUB %01101100
    EQUB %01111000
    EQUB %11011000
    EQUB %11001100
    EQUB %00000000
.ending_glyph_108 ; ASCII 108: "l"
    EQUB %00011100
    EQUB %00001100
    EQUB %00011000
    EQUB %00011000
    EQUB %00011000
    EQUB %00110000
    EQUB %01111000
    EQUB %00000000
.ending_glyph_109 ; ASCII 109: "m"
    EQUB %00000000
    EQUB %00000000
    EQUB %00110110
    EQUB %01111111
    EQUB %01101011
    EQUB %11010110
    EQUB %11000110
    EQUB %00000000
.ending_glyph_110 ; ASCII 110: "n"
    EQUB %00000000
    EQUB %00000000
    EQUB %01111100
    EQUB %01100110
    EQUB %01100110
    EQUB %11001100
    EQUB %11001100
    EQUB %00000000
.ending_glyph_111 ; ASCII 111: "o"
    EQUB %00000000
    EQUB %00000000
    EQUB %00111100
    EQUB %01100110
    EQUB %01100110
    EQUB %11001100
    EQUB %01111000
    EQUB %00000000
.ending_glyph_112 ; ASCII 112: "p"
    EQUB %00000000
    EQUB %00000000
    EQUB %01111100
    EQUB %01100110
    EQUB %01100110
    EQUB %11111000
    EQUB %11000000
    EQUB %11000000
.ending_glyph_114 ; ASCII 114: "r"
    EQUB %00000000
    EQUB %00000000
    EQUB %01101100
    EQUB %01110110
    EQUB %01100000
    EQUB %11000000
    EQUB %11000000
    EQUB %00000000
.ending_glyph_115 ; ASCII 115: "s"
    EQUB %00000000
    EQUB %00000000
    EQUB %00111110
    EQUB %01100000
    EQUB %00111100
    EQUB %00001100
    EQUB %11111000
    EQUB %00000000
.ending_glyph_116 ; ASCII 116: "t"
    EQUB %00011000
    EQUB %00011000
    EQUB %01111100
    EQUB %00110000
    EQUB %00110000
    EQUB %01100000
    EQUB %00111000
    EQUB %00000000
.ending_glyph_117 ; ASCII 117: "u"
    EQUB %00000000
    EQUB %00000000
    EQUB %01100110
    EQUB %01100110
    EQUB %01100110
    EQUB %11001100
    EQUB %01111100
    EQUB %00000000
.ending_glyph_118 ; ASCII 118: "v"
    EQUB %00000000
    EQUB %00000000
    EQUB %01100110
    EQUB %01100110
    EQUB %01100110
    EQUB %01111000
    EQUB %00110000
    EQUB %00000000
.ending_glyph_119 ; ASCII 119: "w"
    EQUB %00000000
    EQUB %00000000
    EQUB %01100011
    EQUB %01101011
    EQUB %01101011
    EQUB %11111110
    EQUB %01101100
    EQUB %00000000
.ending_glyph_121 ; ASCII 121: "y"
    EQUB %00000000
    EQUB %00000000
    EQUB %01100110
    EQUB %01100110
    EQUB %01100110
    EQUB %01111100
    EQUB %00001100
    EQUB %01111000
.ending_glyph_122 ; ASCII 122: "z"
    EQUB %00000000
    EQUB %00000000
    EQUB %01111110
    EQUB %00001100
    EQUB %00011000
    EQUB %01100000
    EQUB %11111100
    EQUB %00000000

; Ending message
ending_line_0 = "    At that moment there "
ending_line_1 = "came a deafening crack "
ending_line_2 = "and the mountain split "
ending_line_3 = "and crumbled.  And as the"
ending_line_4 = "townspeople came running "
ending_line_5 = "from their homes, they "
ending_line_6 = "saw a dishevelled figure "
ending_line_7 = "emerge from the rubble of"
ending_line_8 = "the cavern.  "
ending_line_9 = ""
ending_line_10 = "    Although generations "
ending_line_11 = "had elapsed since the "
ending_line_12 = "imprisonment of Imogen, "
ending_line_13 = "his tale had passed into "
ending_line_14 = "legend, and the people "
ending_line_15 = "knew at once that it was "
ending_line_16 = "truly he who had returned"
ending_line_17 = "to their midst.  "
ending_line_18 = ""
ending_line_19 = "    All trace of the "
ending_line_20 = "insanity had gone, and "
ending_line_21 = "while the citizens of "
ending_line_22 = "Egmain cheered and sang, "
ending_line_23 = "the spell of freedom, its"
ending_line_24 = "purpose fulfilled, soared"
ending_line_25 = "into the night sky and "
ending_line_26 = "became a comet to "
ending_line_27 = "celebrate for the rest of"
ending_line_28 = "time the recovery of the "
ending_line_29 = "wizard whom men call "
ending_line_30 = "Imogen.  "

; The renderer retains the original XOR-&CB format and line terminators.
.encoded_message
    ending_encode ending_line_0, &0D
    ending_encode ending_line_1, &0D
    ending_encode ending_line_2, &0D
    ending_encode ending_line_3, &0D
    ending_encode ending_line_4, &0D
    ending_encode ending_line_5, &0D
    ending_encode ending_line_6, &0D
    ending_encode ending_line_7, &0D
    ending_encode ending_line_8, &0D
    ending_encode ending_line_9, &0D
    ending_encode ending_line_10, &0D
    ending_encode ending_line_11, &0D
    ending_encode ending_line_12, &0D
    ending_encode ending_line_13, &0D
    ending_encode ending_line_14, &0D
    ending_encode ending_line_15, &0D
    ending_encode ending_line_16, &0D
    ending_encode ending_line_17, &0D
    ending_encode ending_line_18, &0D
    ending_encode ending_line_19, &0D
    ending_encode ending_line_20, &0D
    ending_encode ending_line_21, &0D
    ending_encode ending_line_22, &0D
    ending_encode ending_line_23, &0D
    ending_encode ending_line_24, &0D
    ending_encode ending_line_25, &0D
    ending_encode ending_line_26, &0D
    ending_encode ending_line_27, &0D
    ending_encode ending_line_28, &0D
    ending_encode ending_line_29, &0D
    ending_encode ending_line_30, &00

.the_end_loop
    jmp the_end_loop

; Wait for the requested number of VSYNC ticks before displaying THE END.
.wait_for_a_vsyncs
    ldx #0
    stx vsync_counter
.wait_loop
    cmp vsync_counter
    bcs wait_loop
    rts

.the_end_bitmap
; Encoded from the original 960-byte the_end_bitmap in dataQ.asm, using
; tools/generate_epilogue.mjs::generatedCopy, in screen memory order.
; RLE consists of (count, value) byte pairs: emit count copies of value.
; Greedily merge consecutive equal bytes, splitting runs at 255; counts
; are 1..255. There is no header or terminator: the decoder stops after
; writing [&6980,&6D40). 221 pairs occupy 442 bytes.
; The original bitmap remains in dataQ.asm as the uncompressed reference.
    EQUB 72,0
    EQUB 2,1
    EQUB 3,3
    EQUB 1,7
    EQUB 2,6
    EQUB 2,255
    EQUB 1,231
    EQUB 1,199
    EQUB 2,7
    EQUB 2,15
    EQUB 2,255
    EQUB 1,199
    EQUB 4,131
    EQUB 1,3
    EQUB 2,129
    EQUB 2,128
    EQUB 4,0
    EQUB 2,255
    EQUB 1,124
    EQUB 3,120
    EQUB 1,248
    EQUB 1,240
    EQUB 2,159
    EQUB 4,7
    EQUB 2,15
    EQUB 2,248
    EQUB 1,192
    EQUB 4,128
    EQUB 1,0
    EQUB 2,31
    EQUB 4,7
    EQUB 2,15
    EQUB 2,255
    EQUB 1,192
    EQUB 3,128
    EQUB 1,140
    EQUB 1,28
    EQUB 3,240
    EQUB 1,112
    EQUB 4,96
    EQUB 16,0
    EQUB 2,3
    EQUB 4,0
    EQUB 2,1
    EQUB 2,255
    EQUB 1,248
    EQUB 3,240
    EQUB 1,241
    EQUB 1,227
    EQUB 2,254
    EQUB 1,30
    EQUB 1,14
    EQUB 2,12
    EQUB 2,140
    EQUB 8,0
    EQUB 2,254
    EQUB 3,63
    EQUB 1,127
    EQUB 2,103
    EQUB 2,7
    EQUB 1,0
    EQUB 2,1
    EQUB 2,129
    EQUB 1,131
    EQUB 2,248
    EQUB 1,224
    EQUB 1,192
    EQUB 4,128
    EQUB 2,63
    EQUB 4,15
    EQUB 1,31
    EQUB 1,30
    EQUB 1,252
    EQUB 1,255
    EQUB 1,143
    EQUB 2,7
    EQUB 3,3
    EQUB 2,0
    EQUB 2,128
    EQUB 4,192
    EQUB 152,0
    EQUB 1,15
    EQUB 1,31
    EQUB 3,30
    EQUB 1,62
    EQUB 2,60
    EQUB 9,0
    EQUB 4,1
    EQUB 3,3
    EQUB 2,240
    EQUB 2,255
    EQUB 2,224
    EQUB 2,192
    EQUB 1,15
    EQUB 1,31
    EQUB 2,254
    EQUB 1,30
    EQUB 1,62
    EQUB 2,60
    EQUB 8,0
    EQUB 1,15
    EQUB 3,31
    EQUB 1,30
    EQUB 1,62
    EQUB 2,60
    EQUB 1,28
    EQUB 1,56
    EQUB 2,248
    EQUB 1,56
    EQUB 3,48
    EQUB 24,0
    EQUB 1,1
    EQUB 4,3
    EQUB 3,7
    EQUB 1,227
    EQUB 1,231
    EQUB 2,255
    EQUB 1,199
    EQUB 1,198
    EQUB 2,134
    EQUB 1,128
    EQUB 11,0
    EQUB 3,1
    EQUB 1,3
    EQUB 1,103
    EQUB 1,227
    EQUB 2,195
    EQUB 1,193
    EQUB 2,129
    EQUB 1,128
    EQUB 2,195
    EQUB 1,199
    EQUB 2,230
    EQUB 1,238
    EQUB 2,252
    EQUB 8,0
    EQUB 1,30
    EQUB 1,62
    EQUB 3,60
    EQUB 1,124
    EQUB 2,120
    EQUB 3,3
    EQUB 3,7
    EQUB 2,15
    EQUB 4,192
    EQUB 3,128
    EQUB 150,0
    EQUB 2,7
    EQUB 1,0
    EQUB 1,124
    EQUB 3,120
    EQUB 1,248
    EQUB 2,254
    EQUB 9,0
    EQUB 4,7
    EQUB 1,15
    EQUB 2,127
    EQUB 1,0
    EQUB 1,192
    EQUB 4,128
    EQUB 2,231
    EQUB 1,0
    EQUB 1,124
    EQUB 3,120
    EQUB 1,248
    EQUB 2,254
    EQUB 6,0
    EQUB 2,7
    EQUB 1,0
    EQUB 1,124
    EQUB 3,120
    EQUB 1,248
    EQUB 2,255
    EQUB 1,0
    EQUB 1,3
    EQUB 2,7
    EQUB 1,14
    EQUB 1,62
    EQUB 2,252
    EQUB 25,0
    EQUB 4,15
    EQUB 1,31
    EQUB 2,255
    EQUB 1,0
    EQUB 1,128
    EQUB 2,0
    EQUB 1,1
    EQUB 1,7
    EQUB 2,255
    EQUB 1,0
    EQUB 1,96
    EQUB 2,224
    EQUB 2,192
    EQUB 2,128
    EQUB 1,0
    EQUB 3,3
    EQUB 2,7
    EQUB 2,63
    EQUB 6,0
    EQUB 2,192
    EQUB 1,0
    EQUB 2,252
    EQUB 3,120
    EQUB 2,48
    EQUB 5,0
    EQUB 1,1
    EQUB 2,15
    EQUB 1,0
    EQUB 1,248
    EQUB 3,240
    EQUB 1,241
    EQUB 2,255
    EQUB 1,0
    EQUB 1,31
    EQUB 1,30
    EQUB 1,62
    EQUB 1,124
    EQUB 1,248
    EQUB 1,240
    EQUB 1,128
    EQUB 81,0
.copy_line_number
    EQUB 0
.copy_empty_columns
    EQUB &ff
; Sparse column lists are assembled directly from the same strings as
; encoded_message. Suffixes are zero-based message line numbers.
.copy_line_0
    copy_columns ending_line_0
.copy_line_0_end
.copy_line_1
    copy_columns ending_line_1
.copy_line_1_end
.copy_line_2
    copy_columns ending_line_2
.copy_line_2_end
.copy_line_3
    copy_columns ending_line_3
.copy_line_3_end
.copy_line_4
    copy_columns ending_line_4
.copy_line_4_end
.copy_line_5
    copy_columns ending_line_5
.copy_line_5_end
.copy_line_6
    copy_columns ending_line_6
.copy_line_6_end
.copy_line_7
    copy_columns ending_line_7
.copy_line_7_end
.copy_line_8
    copy_columns ending_line_8
.copy_line_8_end
.copy_line_9
    copy_columns ending_line_9
.copy_line_9_end
.copy_line_10
    copy_columns ending_line_10
.copy_line_10_end
.copy_line_11
    copy_columns ending_line_11
.copy_line_11_end
.copy_line_12
    copy_columns ending_line_12
.copy_line_12_end
.copy_line_13
    copy_columns ending_line_13
.copy_line_13_end
.copy_line_14
    copy_columns ending_line_14
.copy_line_14_end
.copy_line_15
    copy_columns ending_line_15
.copy_line_15_end
.copy_line_16
    copy_columns ending_line_16
.copy_line_16_end
.copy_line_17
    copy_columns ending_line_17
.copy_line_17_end
.copy_line_18
    copy_columns ending_line_18
.copy_line_18_end
.copy_line_19
    copy_columns ending_line_19
.copy_line_19_end
.copy_line_20
    copy_columns ending_line_20
.copy_line_20_end
.copy_line_21
    copy_columns ending_line_21
.copy_line_21_end
.copy_line_22
    copy_columns ending_line_22
.copy_line_22_end
.copy_line_23
    copy_columns ending_line_23
.copy_line_23_end
.copy_line_24
    copy_columns ending_line_24
.copy_line_24_end
.copy_line_25
    copy_columns ending_line_25
.copy_line_25_end
.copy_line_26
    copy_columns ending_line_26
.copy_line_26_end
.copy_line_27
    copy_columns ending_line_27
.copy_line_27_end
.copy_line_28
    copy_columns ending_line_28
.copy_line_28_end
.copy_line_29
    copy_columns ending_line_29
.copy_line_29_end
.copy_line_30
    copy_columns ending_line_30
.copy_line_30_end
; Counts and pointers have 14 empty padding entries at each end.
; List size includes the sentinel, so count-1 = end-start-2.
; For an empty list this is -1 (&FF), skipped by the kernel's BMI.
.copy_columns_count
    FOR padding, 1, 14
        EQUB &FF
    NEXT
    EQUB (copy_line_0_end-copy_line_0-2) AND &FF
    EQUB (copy_line_1_end-copy_line_1-2) AND &FF
    EQUB (copy_line_2_end-copy_line_2-2) AND &FF
    EQUB (copy_line_3_end-copy_line_3-2) AND &FF
    EQUB (copy_line_4_end-copy_line_4-2) AND &FF
    EQUB (copy_line_5_end-copy_line_5-2) AND &FF
    EQUB (copy_line_6_end-copy_line_6-2) AND &FF
    EQUB (copy_line_7_end-copy_line_7-2) AND &FF
    EQUB (copy_line_8_end-copy_line_8-2) AND &FF
    EQUB (copy_line_9_end-copy_line_9-2) AND &FF
    EQUB (copy_line_10_end-copy_line_10-2) AND &FF
    EQUB (copy_line_11_end-copy_line_11-2) AND &FF
    EQUB (copy_line_12_end-copy_line_12-2) AND &FF
    EQUB (copy_line_13_end-copy_line_13-2) AND &FF
    EQUB (copy_line_14_end-copy_line_14-2) AND &FF
    EQUB (copy_line_15_end-copy_line_15-2) AND &FF
    EQUB (copy_line_16_end-copy_line_16-2) AND &FF
    EQUB (copy_line_17_end-copy_line_17-2) AND &FF
    EQUB (copy_line_18_end-copy_line_18-2) AND &FF
    EQUB (copy_line_19_end-copy_line_19-2) AND &FF
    EQUB (copy_line_20_end-copy_line_20-2) AND &FF
    EQUB (copy_line_21_end-copy_line_21-2) AND &FF
    EQUB (copy_line_22_end-copy_line_22-2) AND &FF
    EQUB (copy_line_23_end-copy_line_23-2) AND &FF
    EQUB (copy_line_24_end-copy_line_24-2) AND &FF
    EQUB (copy_line_25_end-copy_line_25-2) AND &FF
    EQUB (copy_line_26_end-copy_line_26-2) AND &FF
    EQUB (copy_line_27_end-copy_line_27-2) AND &FF
    EQUB (copy_line_28_end-copy_line_28-2) AND &FF
    EQUB (copy_line_29_end-copy_line_29-2) AND &FF
    EQUB (copy_line_30_end-copy_line_30-2) AND &FF
    FOR padding, 1, 14
        EQUB &FF
    NEXT
.copy_columns_low
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_line_0
    EQUB <copy_line_1
    EQUB <copy_line_2
    EQUB <copy_line_3
    EQUB <copy_line_4
    EQUB <copy_line_5
    EQUB <copy_line_6
    EQUB <copy_line_7
    EQUB <copy_line_8
    EQUB <copy_line_9
    EQUB <copy_line_10
    EQUB <copy_line_11
    EQUB <copy_line_12
    EQUB <copy_line_13
    EQUB <copy_line_14
    EQUB <copy_line_15
    EQUB <copy_line_16
    EQUB <copy_line_17
    EQUB <copy_line_18
    EQUB <copy_line_19
    EQUB <copy_line_20
    EQUB <copy_line_21
    EQUB <copy_line_22
    EQUB <copy_line_23
    EQUB <copy_line_24
    EQUB <copy_line_25
    EQUB <copy_line_26
    EQUB <copy_line_27
    EQUB <copy_line_28
    EQUB <copy_line_29
    EQUB <copy_line_30
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
    EQUB <copy_empty_columns
.copy_columns_high
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_line_0
    EQUB >copy_line_1
    EQUB >copy_line_2
    EQUB >copy_line_3
    EQUB >copy_line_4
    EQUB >copy_line_5
    EQUB >copy_line_6
    EQUB >copy_line_7
    EQUB >copy_line_8
    EQUB >copy_line_9
    EQUB >copy_line_10
    EQUB >copy_line_11
    EQUB >copy_line_12
    EQUB >copy_line_13
    EQUB >copy_line_14
    EQUB >copy_line_15
    EQUB >copy_line_16
    EQUB >copy_line_17
    EQUB >copy_line_18
    EQUB >copy_line_19
    EQUB >copy_line_20
    EQUB >copy_line_21
    EQUB >copy_line_22
    EQUB >copy_line_23
    EQUB >copy_line_24
    EQUB >copy_line_25
    EQUB >copy_line_26
    EQUB >copy_line_27
    EQUB >copy_line_28
    EQUB >copy_line_29
    EQUB >copy_line_30
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
    EQUB >copy_empty_columns
.copy_kernel_low
    EQUB <(copy_pixel_0_0)
    EQUB <(copy_pixel_1_0)
    EQUB <(copy_pixel_2_0)
    EQUB <(copy_pixel_3_0)
    EQUB <(copy_pixel_4_0)
    EQUB <(copy_pixel_5_0)
    EQUB <(copy_pixel_6_0)
    EQUB <(copy_pixel_7_0)
    EQUB <(copy_pixel_8_0)
    EQUB <(copy_pixel_9_0)
    EQUB <(copy_pixel_10_0)
    EQUB <(copy_pixel_11_0)
    EQUB <(copy_pixel_12_0)
    EQUB <(copy_pixel_13_0)
    EQUB <(copy_pixel_14_0)
    EQUB <(copy_pixel_15_0)
    EQUB <(copy_pixel_16_0)
    EQUB <(copy_pixel_17_0)
    EQUB <(copy_pixel_18_0)
    EQUB <(copy_pixel_19_0)
    EQUB <(copy_pixel_20_0)
    EQUB <(copy_pixel_21_0)
    EQUB <(copy_pixel_22_0)
    EQUB <(copy_pixel_23_0)
    EQUB <(copy_pixel_24_0)
    EQUB <(copy_pixel_25_0)
    EQUB <(copy_pixel_26_0)
    EQUB <(copy_pixel_27_0)
.copy_kernel_high
    EQUB >(copy_pixel_0_0)
    EQUB >(copy_pixel_1_0)
    EQUB >(copy_pixel_2_0)
    EQUB >(copy_pixel_3_0)
    EQUB >(copy_pixel_4_0)
    EQUB >(copy_pixel_5_0)
    EQUB >(copy_pixel_6_0)
    EQUB >(copy_pixel_7_0)
    EQUB >(copy_pixel_8_0)
    EQUB >(copy_pixel_9_0)
    EQUB >(copy_pixel_10_0)
    EQUB >(copy_pixel_11_0)
    EQUB >(copy_pixel_12_0)
    EQUB >(copy_pixel_13_0)
    EQUB >(copy_pixel_14_0)
    EQUB >(copy_pixel_15_0)
    EQUB >(copy_pixel_16_0)
    EQUB >(copy_pixel_17_0)
    EQUB >(copy_pixel_18_0)
    EQUB >(copy_pixel_19_0)
    EQUB >(copy_pixel_20_0)
    EQUB >(copy_pixel_21_0)
    EQUB >(copy_pixel_22_0)
    EQUB >(copy_pixel_23_0)
    EQUB >(copy_pixel_24_0)
    EQUB >(copy_pixel_25_0)
    EQUB >(copy_pixel_26_0)
    EQUB >(copy_pixel_27_0)
.copy_enter_low
    EQUB <(copy_enter_0+1)
    EQUB <(copy_enter_1+1)
    EQUB <(copy_enter_2+1)
    EQUB <(copy_enter_3+1)
    EQUB <(copy_enter_4+1)
    EQUB <(copy_enter_5+1)
    EQUB <(copy_enter_6+1)
    EQUB <(copy_enter_7+1)
    EQUB <(copy_enter_8+1)
    EQUB <(copy_enter_9+1)
    EQUB <(copy_enter_10+1)
    EQUB <(copy_enter_11+1)
    EQUB <(copy_enter_12+1)
    EQUB <(copy_enter_13+1)
    EQUB <(copy_enter_14+1)
    EQUB <(copy_enter_15+1)
    EQUB <(copy_enter_16+1)
    EQUB <(copy_enter_17+1)
    EQUB <(copy_enter_18+1)
    EQUB <(copy_enter_19+1)
    EQUB <(copy_enter_20+1)
    EQUB <(copy_enter_21+1)
    EQUB <(copy_enter_22+1)
    EQUB <(copy_enter_23+1)
    EQUB <(copy_enter_24+1)
    EQUB <(copy_enter_25+1)
    EQUB <(copy_enter_26+1)
    EQUB <(copy_enter_27+1)
.copy_enter_high
    EQUB >(copy_enter_0+1)
    EQUB >(copy_enter_1+1)
    EQUB >(copy_enter_2+1)
    EQUB >(copy_enter_3+1)
    EQUB >(copy_enter_4+1)
    EQUB >(copy_enter_5+1)
    EQUB >(copy_enter_6+1)
    EQUB >(copy_enter_7+1)
    EQUB >(copy_enter_8+1)
    EQUB >(copy_enter_9+1)
    EQUB >(copy_enter_10+1)
    EQUB >(copy_enter_11+1)
    EQUB >(copy_enter_12+1)
    EQUB >(copy_enter_13+1)
    EQUB >(copy_enter_14+1)
    EQUB >(copy_enter_15+1)
    EQUB >(copy_enter_16+1)
    EQUB >(copy_enter_17+1)
    EQUB >(copy_enter_18+1)
    EQUB >(copy_enter_19+1)
    EQUB >(copy_enter_20+1)
    EQUB >(copy_enter_21+1)
    EQUB >(copy_enter_22+1)
    EQUB >(copy_enter_23+1)
    EQUB >(copy_enter_24+1)
    EQUB >(copy_enter_25+1)
    EQUB >(copy_enter_26+1)
    EQUB >(copy_enter_27+1)
.copy_done_low
    EQUB <(copy_done_0)
    EQUB <(copy_done_1)
    EQUB <(copy_done_2)
    EQUB <(copy_done_3)
    EQUB <(copy_done_4)
    EQUB <(copy_done_5)
    EQUB <(copy_done_6)
    EQUB <(copy_done_7)
    EQUB <(copy_done_8)
    EQUB <(copy_done_9)
    EQUB <(copy_done_10)
    EQUB <(copy_done_11)
    EQUB <(copy_done_12)
    EQUB <(copy_done_13)
    EQUB <(copy_done_14)
    EQUB <(copy_done_15)
    EQUB <(copy_done_16)
    EQUB <(copy_done_17)
    EQUB <(copy_done_18)
    EQUB <(copy_done_19)
    EQUB <(copy_done_20)
    EQUB <(copy_done_21)
    EQUB <(copy_done_22)
    EQUB <(copy_done_23)
    EQUB <(copy_done_24)
    EQUB <(copy_done_25)
    EQUB <(copy_done_26)
    EQUB <(copy_done_27)
.copy_done_high
    EQUB >(copy_done_0)
    EQUB >(copy_done_1)
    EQUB >(copy_done_2)
    EQUB >(copy_done_3)
    EQUB >(copy_done_4)
    EQUB >(copy_done_5)
    EQUB >(copy_done_6)
    EQUB >(copy_done_7)
    EQUB >(copy_done_8)
    EQUB >(copy_done_9)
    EQUB >(copy_done_10)
    EQUB >(copy_done_11)
    EQUB >(copy_done_12)
    EQUB >(copy_done_13)
    EQUB >(copy_done_14)
    EQUB >(copy_done_15)
    EQUB >(copy_done_16)
    EQUB >(copy_done_17)
    EQUB >(copy_done_18)
    EQUB >(copy_done_19)
    EQUB >(copy_done_20)
    EQUB >(copy_done_21)
    EQUB >(copy_done_22)
    EQUB >(copy_done_23)
    EQUB >(copy_done_24)
    EQUB >(copy_done_25)
    EQUB >(copy_done_26)
    EQUB >(copy_done_27)
.copy_backup_low
    EQUB <(copy_backup_0)
    EQUB <(copy_backup_1)
    EQUB <(copy_backup_2)
    EQUB <(copy_backup_3)
    EQUB <(copy_backup_4)
    EQUB <(copy_backup_5)
    EQUB <(copy_backup_6)
    EQUB <(copy_backup_7)
    EQUB <(copy_backup_8)
    EQUB <(copy_backup_9)
    EQUB <(copy_backup_10)
    EQUB <(copy_backup_11)
    EQUB <(copy_backup_12)
    EQUB <(copy_backup_13)
    EQUB <(copy_backup_14)
    EQUB <(copy_backup_15)
    EQUB <(copy_backup_16)
    EQUB <(copy_backup_17)
    EQUB <(copy_backup_18)
    EQUB <(copy_backup_19)
    EQUB <(copy_backup_20)
    EQUB <(copy_backup_21)
    EQUB <(copy_backup_22)
    EQUB <(copy_backup_23)
    EQUB <(copy_backup_24)
    EQUB <(copy_backup_25)
    EQUB <(copy_backup_26)
    EQUB <(copy_backup_27)
.copy_backup_high
    EQUB >(copy_backup_0)
    EQUB >(copy_backup_1)
    EQUB >(copy_backup_2)
    EQUB >(copy_backup_3)
    EQUB >(copy_backup_4)
    EQUB >(copy_backup_5)
    EQUB >(copy_backup_6)
    EQUB >(copy_backup_7)
    EQUB >(copy_backup_8)
    EQUB >(copy_backup_9)
    EQUB >(copy_backup_10)
    EQUB >(copy_backup_11)
    EQUB >(copy_backup_12)
    EQUB >(copy_backup_13)
    EQUB >(copy_backup_14)
    EQUB >(copy_backup_15)
    EQUB >(copy_backup_16)
    EQUB >(copy_backup_17)
    EQUB >(copy_backup_18)
    EQUB >(copy_backup_19)
    EQUB >(copy_backup_20)
    EQUB >(copy_backup_21)
    EQUB >(copy_backup_22)
    EQUB >(copy_backup_23)
    EQUB >(copy_backup_24)
    EQUB >(copy_backup_25)
    EQUB >(copy_backup_26)
    EQUB >(copy_backup_27)
.copy_start_0
; Phase tables: suffix 0 = even physical character row, 1 = odd.
; Index is stream_phase (0..15). Values select pixel transfers 0..7:
; start = entry index; end = first excluded index (8 means natural end);
; restore = previously patched index (8 means no instruction to restore).
; These select eight glyph rows plus one clearing row per 16-pixel band.
    EQUB 0,0,0,0,0,0,0,0,7,6,5,4,3,2,1,0
.copy_end_0
    EQUB 8,7,6,5,4,3,2,1,8,8,8,8,8,8,8,8
.copy_restore_0
    EQUB 8,8,7,6,5,4,3,2,1,8,8,8,8,8,8,8
.copy_start_1
    EQUB 7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0
.copy_end_1
    EQUB 8,8,8,8,8,8,8,8,8,7,6,5,4,3,2,1
.copy_restore_1
    EQUB 1,8,8,8,8,8,8,8,8,8,7,6,5,4,3,2

.copy_patch_start
    EQUB 0
.copy_patch_end
    EQUB 0
.copy_patch_restore
    EQUB 0
; Select just the nine raster rows per text line that can change: eight
; glyph rows plus one trailing row to erase. Patch once per scroll step,
; never inside the per-column loop. The readonly backups restore the one
; instruction previously replaced by an early-exit JMP.
.copy_prepare_phase
    ldx #0
.copy_prepare_row
    ldy stream_phase
    txa
    and #1
    beq copy_prepare_even
    lda copy_start_1,y
    sta copy_patch_start
    lda copy_end_1,y
    sta copy_patch_end
    lda copy_restore_1,y
    jmp copy_prepare_common
.copy_prepare_even
    lda copy_start_0,y
    sta copy_patch_start
    lda copy_end_0,y
    sta copy_patch_end
    lda copy_restore_0,y
.copy_prepare_common
    sta copy_patch_restore
    lda copy_kernel_low,x
    sta l007a
    lda copy_kernel_high,x
    sta l007b
    lda copy_patch_restore
    cmp #8
    bcs copy_patch_entry
; Restore the previous prefix's stop instruction (three original bytes).
    asl a
    adc copy_patch_restore
    asl a
    clc
    adc l007a
    sta l0078
    lda l007b
    adc #0
    sta l0079
    lda copy_patch_restore
    asl a
    adc copy_patch_restore
    clc
    adc copy_backup_low,x
    sta character_definition_low
    lda copy_backup_high,x
    adc #0
    sta character_definition_high
    ldy #0
    lda (character_definition_low),y
    sta (l0078),y
    iny
    lda (character_definition_low),y
    sta (l0078),y
    iny
    lda (character_definition_low),y
    sta (l0078),y
.copy_patch_entry
    lda copy_enter_low,x
    sta l0078
    lda copy_enter_high,x
    sta l0079
    lda copy_patch_start
    asl a
    adc copy_patch_start
    asl a
    clc
    adc l007a
    ldy #0
    sta (l0078),y
    lda l007b
    adc #0
    iny
    sta (l0078),y
; Prefix paths end before the unused pixel rows; suffix paths run to end.
    lda copy_patch_end
    cmp #8
    bcs copy_prepare_next
    asl a
    adc copy_patch_end
    asl a
    clc
    adc l007a
    sta l0078
    lda l007b
    adc #0
    sta l0079
    ldy #0
    lda #&4c
    sta (l0078),y
    iny
    lda copy_done_low,x
    sta (l0078),y
    iny
    lda copy_done_high,x
    sta (l0078),y
.copy_prepare_next
    inx
    cpx #28
    beq copy_prepare_finished
    jmp copy_prepare_row
.copy_prepare_finished
    rts
; One-byte offsets into the packed 28-glyph font (224 bytes), indexed by
; ASCII minus 44. This replaces the two full address tables, recovering room
; for the scroll workspace above the larger SWR engine. Gaps are unused codes.
.font_offset
    EQUB ending_glyph_44-character_definitions
    EQUB 0
    EQUB ending_glyph_46-character_definitions
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB ending_glyph_65-character_definitions
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB ending_glyph_69-character_definitions
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB ending_glyph_73-character_definitions
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB 0
    EQUB ending_glyph_97-character_definitions
    EQUB ending_glyph_98-character_definitions
    EQUB ending_glyph_99-character_definitions
    EQUB ending_glyph_100-character_definitions
    EQUB ending_glyph_101-character_definitions
    EQUB ending_glyph_102-character_definitions
    EQUB ending_glyph_103-character_definitions
    EQUB ending_glyph_104-character_definitions
    EQUB ending_glyph_105-character_definitions
    EQUB 0
    EQUB ending_glyph_107-character_definitions
    EQUB ending_glyph_108-character_definitions
    EQUB ending_glyph_109-character_definitions
    EQUB ending_glyph_110-character_definitions
    EQUB ending_glyph_111-character_definitions
    EQUB ending_glyph_112-character_definitions
    EQUB 0
    EQUB ending_glyph_114-character_definitions
    EQUB ending_glyph_115-character_definitions
    EQUB ending_glyph_116-character_definitions
    EQUB ending_glyph_117-character_definitions
    EQUB ending_glyph_118-character_definitions
    EQUB ending_glyph_119-character_definitions
    EQUB 0
    EQUB ending_glyph_121-character_definitions
    EQUB ending_glyph_122-character_definitions
ASSERT P%-font_offset = 79
ASSERT encoded_message-character_definitions <= 256
.stream_message_low
    EQUB 0
.stream_message_high
    EQUB 0
.stream_phase
    EQUB 0
.stream_remaining
    EQUW 0
.stream_bottom_row
    lda stream_message_low
    sta message_address_low
    lda stream_message_high
    sta message_address_high
    lda stream_phase
    cmp #8
    bcs stream_advance_phase
    lda #&e0
    sta l007a
    lda #&7e
    sta l007b
    ldy #0
    sty message_offset_low
.stream_character
    ldy message_offset_low
    lda (message_address_low),y
    eor #&cb
    beq stream_advance_phase
    cmp #&0d
    beq stream_advance_phase
    inc message_offset_low
    cmp #&20
    beq stream_next_column
    sec
    sbc #44
.stream_glyph_entry
    tax
    lda font_offset,x
    clc
    adc #<character_definitions
    sta character_definition_low
    lda #>character_definitions
    adc #0
    sta character_definition_high
    ldy stream_phase
    lda (character_definition_low),y
    ldy #7
    sta (l007a),y
.stream_next_column
    lda l007a
    clc
    adc #8
    sta l007a
    bcc stream_character
    inc l007b
    bne stream_character
.stream_advance_phase
    inc stream_phase
    lda stream_phase
    and #15
    sta stream_phase
    bne stream_return
    inc copy_line_number
; Advance the persistent cursor only once per text line (every 16 steps).
    ldy #0
.stream_find_newline
    lda (message_address_low),y
    eor #&cb
    beq stream_set_cursor
    iny
    cmp #&0d
    bne stream_find_newline
.stream_set_cursor
    tya
    clc
    adc stream_message_low
    sta stream_message_low
    bcc stream_return
    inc stream_message_high
.stream_return
    rts
ASSERT P% <= &5bc0

.copy_prepare_update
    lda stream_phase
    and #7
    bne copy_lines_ready
    jsr copy_configure_lines
.copy_lines_ready
    jsr copy_prepare_phase
.copy_prepare_update_end
    rts

; Startup only. Common level setup has finished using sprites by this point.
; Generate 28 copies of a 61-byte kernel, their row-specific operands,
; the instruction backups, and the alternating 29/25-byte setup routines.
.generate_scroll_code
    lda #0
    sta &74
    lda #<&5d20
    sta &78
    lda #>&5d20
    sta &79
    lda #<copy_configure_lines
    sta generator_config_low
    lda #>copy_configure_lines
    sta generator_config_high
.generate_scroll_row
    ldx &74
    lda copy_kernel_low,x
    sec
    sbc #10
    sta &72
    lda copy_kernel_high,x
    sbc #0
    sta &73
    ldy #0
.generate_kernel_copy
    lda copy_kernel_template,y
    sta (&72),y
    iny
    cpy #61
    bne generate_kernel_copy
    lda copy_kernel_low,x
    sta &70
    lda copy_kernel_high,x
    sta &71
    lda copy_backup_low,x
    sta &7c
    lda copy_backup_high,x
    sta &7d
    ldx #0
.generate_pixel
    ldy #0
    lda #&bd
    sta (&70),y
    cpx #7
    beq generate_cross_row
    lda &78
    clc
    adc #1
    pha
    lda &79
    adc #0
    jmp generate_source
.generate_cross_row
    lda &74
    cmp #27
    bne generate_next_row_source
    lda #&ad
    sta (&70),y
    lda #<copy_zero
    pha
    lda #>copy_zero
    jmp generate_source
.generate_next_row_source
    lda &78
    clc
    adc #&39
    pha
    lda &79
    adc #1
.generate_source
    ldy #2
    sta (&70),y
    pla
    dey
    sta (&70),y
    ldy #4
    lda &78
    sta (&70),y
    iny
    lda &79
    sta (&70),y
    ldy #0
    lda (&70),y
    sta (&7c),y
    iny
    lda (&70),y
    sta (&7c),y
    iny
    lda (&70),y
    sta (&7c),y
    lda &7c
    clc
    adc #3
    sta &7c
    bcc generate_backup_ready
    inc &7d
.generate_backup_ready
    lda &70
    clc
    adc #6
    sta &70
    bcc generate_code_ready
    inc &71
.generate_code_ready
    inc &78
    bne generate_screen_ready
    inc &79
.generate_screen_ready
    inx
    cpx #8
    beq generate_configuration
    jmp generate_pixel
.generate_configuration
    lda generator_config_low
    sta &70
    lda generator_config_high
    sta &71
    lda &74
    and #1
    beq generate_even_configuration
    lda #<copy_config_odd_template
    sta &7c
    lda #>copy_config_odd_template
    sta &7d
    lda #25
    sta &77
    ldx #4
    bne generate_config_copy_begin
.generate_even_configuration
    lda #<copy_config_even_template
    sta &7c
    lda #>copy_config_even_template
    sta &7d
    lda #29
    sta &77
    ldx #0
.generate_config_copy_begin
    ldy #0
.generate_config_copy
    lda (&7c),y
    sta (&70),y
    iny
    cpy &77
    bne generate_config_copy
; X=0 for the even template, 4 for the odd one: its fields are four
; bytes earlier. Pair index increases the immediate line-table index.
    lda &74
    lsr a
    cpx #0
    beq generate_config_index
    clc
    adc #1
.generate_config_index
    pha
    lda #9
    stx &75
    sec
    sbc &75
    tay
    pla
    sta (&70),y
    lda #15
    sec
    sbc &75
    tay
    lda #5
    jsr generate_config_address
    lda #21
    sec
    sbc &75
    tay
    lda #6
    jsr generate_config_address
    lda #27
    sec
    sbc &75
    tay
    lda #1
    jsr generate_config_address
    lda &70
    clc
    adc &77
    sta generator_config_low
    lda &71
    adc #0
    sta generator_config_high
    lda &78
    clc
    adc #&38
    sta &78
    lda &79
    adc #1
    sta &79
    inc &74
    lda &74
    cmp #28
    beq generate_scroll_finished
    jmp generate_scroll_row
.generate_scroll_finished
    lda #&60
    sta scroll_copy_end
    sta copy_configure_row_27+25
    rts
.generate_config_address
    clc
    adc &72
    sta (&70),y
    iny
    lda &73
    adc #0
    sta (&70),y
    rts
.generator_config_low
    EQUB 0
.generator_config_high
    EQUB 0

.copy_zero
    EQUB 0
; Resident templates are populated by the COPYBLOCK directives below.
; Startup copies/patches these into SPRDATA only after level setup is done.
.copy_kernel_template
    SKIP 61
.copy_config_even_template
    SKIP 29
.copy_config_odd_template
    SKIP 25
.pydis_end
ASSERT pydis_end <= scroll_copy
; Everything below is assembled for addresses and template bytes, but is
; outside [pydis_start,pydis_end), so SAVE does not put it in the load file.
; generate_scroll_code creates this workspace at runtime, including backups.
; The SWR engine relocates level_data_load_address, so &4AD8 is only a
; minimum workspace address. Keep generated code above the resident image.
IF P% < &4ad8
    ORG &4ad8
ENDIF
.scroll_copy
.copy_count_0
    ldy #&ff
    bmi copy_next_row_0
.copy_columns_0
    ldx &ffff,y
.copy_enter_0
    jmp copy_pixel_0_0
.copy_pixel_0_0
    lda &5d21,x
    sta &5d20,x
.copy_pixel_0_1
    lda &5d22,x
    sta &5d21,x
.copy_pixel_0_2
    lda &5d23,x
    sta &5d22,x
.copy_pixel_0_3
    lda &5d24,x
    sta &5d23,x
.copy_pixel_0_4
    lda &5d25,x
    sta &5d24,x
.copy_pixel_0_5
    lda &5d26,x
    sta &5d25,x
.copy_pixel_0_6
    lda &5d27,x
    sta &5d26,x
.copy_pixel_0_7
    lda &5e60,x
    sta &5d27,x
.copy_done_0
    dey
    bpl copy_columns_0
.copy_next_row_0
.copy_count_1
    ldy #&ff
    bmi copy_next_row_1
.copy_columns_1
    ldx &ffff,y
.copy_enter_1
    jmp copy_pixel_1_0
.copy_pixel_1_0
    lda &5e61,x
    sta &5e60,x
.copy_pixel_1_1
    lda &5e62,x
    sta &5e61,x
.copy_pixel_1_2
    lda &5e63,x
    sta &5e62,x
.copy_pixel_1_3
    lda &5e64,x
    sta &5e63,x
.copy_pixel_1_4
    lda &5e65,x
    sta &5e64,x
.copy_pixel_1_5
    lda &5e66,x
    sta &5e65,x
.copy_pixel_1_6
    lda &5e67,x
    sta &5e66,x
.copy_pixel_1_7
    lda &5fa0,x
    sta &5e67,x
.copy_done_1
    dey
    bpl copy_columns_1
.copy_next_row_1
.copy_count_2
    ldy #&ff
    bmi copy_next_row_2
.copy_columns_2
    ldx &ffff,y
.copy_enter_2
    jmp copy_pixel_2_0
.copy_pixel_2_0
    lda &5fa1,x
    sta &5fa0,x
.copy_pixel_2_1
    lda &5fa2,x
    sta &5fa1,x
.copy_pixel_2_2
    lda &5fa3,x
    sta &5fa2,x
.copy_pixel_2_3
    lda &5fa4,x
    sta &5fa3,x
.copy_pixel_2_4
    lda &5fa5,x
    sta &5fa4,x
.copy_pixel_2_5
    lda &5fa6,x
    sta &5fa5,x
.copy_pixel_2_6
    lda &5fa7,x
    sta &5fa6,x
.copy_pixel_2_7
    lda &60e0,x
    sta &5fa7,x
.copy_done_2
    dey
    bpl copy_columns_2
.copy_next_row_2
.copy_count_3
    ldy #&ff
    bmi copy_next_row_3
.copy_columns_3
    ldx &ffff,y
.copy_enter_3
    jmp copy_pixel_3_0
.copy_pixel_3_0
    lda &60e1,x
    sta &60e0,x
.copy_pixel_3_1
    lda &60e2,x
    sta &60e1,x
.copy_pixel_3_2
    lda &60e3,x
    sta &60e2,x
.copy_pixel_3_3
    lda &60e4,x
    sta &60e3,x
.copy_pixel_3_4
    lda &60e5,x
    sta &60e4,x
.copy_pixel_3_5
    lda &60e6,x
    sta &60e5,x
.copy_pixel_3_6
    lda &60e7,x
    sta &60e6,x
.copy_pixel_3_7
    lda &6220,x
    sta &60e7,x
.copy_done_3
    dey
    bpl copy_columns_3
.copy_next_row_3
.copy_count_4
    ldy #&ff
    bmi copy_next_row_4
.copy_columns_4
    ldx &ffff,y
.copy_enter_4
    jmp copy_pixel_4_0
.copy_pixel_4_0
    lda &6221,x
    sta &6220,x
.copy_pixel_4_1
    lda &6222,x
    sta &6221,x
.copy_pixel_4_2
    lda &6223,x
    sta &6222,x
.copy_pixel_4_3
    lda &6224,x
    sta &6223,x
.copy_pixel_4_4
    lda &6225,x
    sta &6224,x
.copy_pixel_4_5
    lda &6226,x
    sta &6225,x
.copy_pixel_4_6
    lda &6227,x
    sta &6226,x
.copy_pixel_4_7
    lda &6360,x
    sta &6227,x
.copy_done_4
    dey
    bpl copy_columns_4
.copy_next_row_4
.copy_count_5
    ldy #&ff
    bmi copy_next_row_5
.copy_columns_5
    ldx &ffff,y
.copy_enter_5
    jmp copy_pixel_5_0
.copy_pixel_5_0
    lda &6361,x
    sta &6360,x
.copy_pixel_5_1
    lda &6362,x
    sta &6361,x
.copy_pixel_5_2
    lda &6363,x
    sta &6362,x
.copy_pixel_5_3
    lda &6364,x
    sta &6363,x
.copy_pixel_5_4
    lda &6365,x
    sta &6364,x
.copy_pixel_5_5
    lda &6366,x
    sta &6365,x
.copy_pixel_5_6
    lda &6367,x
    sta &6366,x
.copy_pixel_5_7
    lda &64a0,x
    sta &6367,x
.copy_done_5
    dey
    bpl copy_columns_5
.copy_next_row_5
.copy_count_6
    ldy #&ff
    bmi copy_next_row_6
.copy_columns_6
    ldx &ffff,y
.copy_enter_6
    jmp copy_pixel_6_0
.copy_pixel_6_0
    lda &64a1,x
    sta &64a0,x
.copy_pixel_6_1
    lda &64a2,x
    sta &64a1,x
.copy_pixel_6_2
    lda &64a3,x
    sta &64a2,x
.copy_pixel_6_3
    lda &64a4,x
    sta &64a3,x
.copy_pixel_6_4
    lda &64a5,x
    sta &64a4,x
.copy_pixel_6_5
    lda &64a6,x
    sta &64a5,x
.copy_pixel_6_6
    lda &64a7,x
    sta &64a6,x
.copy_pixel_6_7
    lda &65e0,x
    sta &64a7,x
.copy_done_6
    dey
    bpl copy_columns_6
.copy_next_row_6
.copy_count_7
    ldy #&ff
    bmi copy_next_row_7
.copy_columns_7
    ldx &ffff,y
.copy_enter_7
    jmp copy_pixel_7_0
.copy_pixel_7_0
    lda &65e1,x
    sta &65e0,x
.copy_pixel_7_1
    lda &65e2,x
    sta &65e1,x
.copy_pixel_7_2
    lda &65e3,x
    sta &65e2,x
.copy_pixel_7_3
    lda &65e4,x
    sta &65e3,x
.copy_pixel_7_4
    lda &65e5,x
    sta &65e4,x
.copy_pixel_7_5
    lda &65e6,x
    sta &65e5,x
.copy_pixel_7_6
    lda &65e7,x
    sta &65e6,x
.copy_pixel_7_7
    lda &6720,x
    sta &65e7,x
.copy_done_7
    dey
    bpl copy_columns_7
.copy_next_row_7
.copy_count_8
    ldy #&ff
    bmi copy_next_row_8
.copy_columns_8
    ldx &ffff,y
.copy_enter_8
    jmp copy_pixel_8_0
.copy_pixel_8_0
    lda &6721,x
    sta &6720,x
.copy_pixel_8_1
    lda &6722,x
    sta &6721,x
.copy_pixel_8_2
    lda &6723,x
    sta &6722,x
.copy_pixel_8_3
    lda &6724,x
    sta &6723,x
.copy_pixel_8_4
    lda &6725,x
    sta &6724,x
.copy_pixel_8_5
    lda &6726,x
    sta &6725,x
.copy_pixel_8_6
    lda &6727,x
    sta &6726,x
.copy_pixel_8_7
    lda &6860,x
    sta &6727,x
.copy_done_8
    dey
    bpl copy_columns_8
.copy_next_row_8
.copy_count_9
    ldy #&ff
    bmi copy_next_row_9
.copy_columns_9
    ldx &ffff,y
.copy_enter_9
    jmp copy_pixel_9_0
.copy_pixel_9_0
    lda &6861,x
    sta &6860,x
.copy_pixel_9_1
    lda &6862,x
    sta &6861,x
.copy_pixel_9_2
    lda &6863,x
    sta &6862,x
.copy_pixel_9_3
    lda &6864,x
    sta &6863,x
.copy_pixel_9_4
    lda &6865,x
    sta &6864,x
.copy_pixel_9_5
    lda &6866,x
    sta &6865,x
.copy_pixel_9_6
    lda &6867,x
    sta &6866,x
.copy_pixel_9_7
    lda &69a0,x
    sta &6867,x
.copy_done_9
    dey
    bpl copy_columns_9
.copy_next_row_9
.copy_count_10
    ldy #&ff
    bmi copy_next_row_10
.copy_columns_10
    ldx &ffff,y
.copy_enter_10
    jmp copy_pixel_10_0
.copy_pixel_10_0
    lda &69a1,x
    sta &69a0,x
.copy_pixel_10_1
    lda &69a2,x
    sta &69a1,x
.copy_pixel_10_2
    lda &69a3,x
    sta &69a2,x
.copy_pixel_10_3
    lda &69a4,x
    sta &69a3,x
.copy_pixel_10_4
    lda &69a5,x
    sta &69a4,x
.copy_pixel_10_5
    lda &69a6,x
    sta &69a5,x
.copy_pixel_10_6
    lda &69a7,x
    sta &69a6,x
.copy_pixel_10_7
    lda &6ae0,x
    sta &69a7,x
.copy_done_10
    dey
    bpl copy_columns_10
.copy_next_row_10
.copy_count_11
    ldy #&ff
    bmi copy_next_row_11
.copy_columns_11
    ldx &ffff,y
.copy_enter_11
    jmp copy_pixel_11_0
.copy_pixel_11_0
    lda &6ae1,x
    sta &6ae0,x
.copy_pixel_11_1
    lda &6ae2,x
    sta &6ae1,x
.copy_pixel_11_2
    lda &6ae3,x
    sta &6ae2,x
.copy_pixel_11_3
    lda &6ae4,x
    sta &6ae3,x
.copy_pixel_11_4
    lda &6ae5,x
    sta &6ae4,x
.copy_pixel_11_5
    lda &6ae6,x
    sta &6ae5,x
.copy_pixel_11_6
    lda &6ae7,x
    sta &6ae6,x
.copy_pixel_11_7
    lda &6c20,x
    sta &6ae7,x
.copy_done_11
    dey
    bpl copy_columns_11
.copy_next_row_11
.copy_count_12
    ldy #&ff
    bmi copy_next_row_12
.copy_columns_12
    ldx &ffff,y
.copy_enter_12
    jmp copy_pixel_12_0
.copy_pixel_12_0
    lda &6c21,x
    sta &6c20,x
.copy_pixel_12_1
    lda &6c22,x
    sta &6c21,x
.copy_pixel_12_2
    lda &6c23,x
    sta &6c22,x
.copy_pixel_12_3
    lda &6c24,x
    sta &6c23,x
.copy_pixel_12_4
    lda &6c25,x
    sta &6c24,x
.copy_pixel_12_5
    lda &6c26,x
    sta &6c25,x
.copy_pixel_12_6
    lda &6c27,x
    sta &6c26,x
.copy_pixel_12_7
    lda &6d60,x
    sta &6c27,x
.copy_done_12
    dey
    bpl copy_columns_12
.copy_next_row_12
.copy_count_13
    ldy #&ff
    bmi copy_next_row_13
.copy_columns_13
    ldx &ffff,y
.copy_enter_13
    jmp copy_pixel_13_0
.copy_pixel_13_0
    lda &6d61,x
    sta &6d60,x
.copy_pixel_13_1
    lda &6d62,x
    sta &6d61,x
.copy_pixel_13_2
    lda &6d63,x
    sta &6d62,x
.copy_pixel_13_3
    lda &6d64,x
    sta &6d63,x
.copy_pixel_13_4
    lda &6d65,x
    sta &6d64,x
.copy_pixel_13_5
    lda &6d66,x
    sta &6d65,x
.copy_pixel_13_6
    lda &6d67,x
    sta &6d66,x
.copy_pixel_13_7
    lda &6ea0,x
    sta &6d67,x
.copy_done_13
    dey
    bpl copy_columns_13
.copy_next_row_13
.copy_count_14
    ldy #&ff
    bmi copy_next_row_14
.copy_columns_14
    ldx &ffff,y
.copy_enter_14
    jmp copy_pixel_14_0
.copy_pixel_14_0
    lda &6ea1,x
    sta &6ea0,x
.copy_pixel_14_1
    lda &6ea2,x
    sta &6ea1,x
.copy_pixel_14_2
    lda &6ea3,x
    sta &6ea2,x
.copy_pixel_14_3
    lda &6ea4,x
    sta &6ea3,x
.copy_pixel_14_4
    lda &6ea5,x
    sta &6ea4,x
.copy_pixel_14_5
    lda &6ea6,x
    sta &6ea5,x
.copy_pixel_14_6
    lda &6ea7,x
    sta &6ea6,x
.copy_pixel_14_7
    lda &6fe0,x
    sta &6ea7,x
.copy_done_14
    dey
    bpl copy_columns_14
.copy_next_row_14
.copy_count_15
    ldy #&ff
    bmi copy_next_row_15
.copy_columns_15
    ldx &ffff,y
.copy_enter_15
    jmp copy_pixel_15_0
.copy_pixel_15_0
    lda &6fe1,x
    sta &6fe0,x
.copy_pixel_15_1
    lda &6fe2,x
    sta &6fe1,x
.copy_pixel_15_2
    lda &6fe3,x
    sta &6fe2,x
.copy_pixel_15_3
    lda &6fe4,x
    sta &6fe3,x
.copy_pixel_15_4
    lda &6fe5,x
    sta &6fe4,x
.copy_pixel_15_5
    lda &6fe6,x
    sta &6fe5,x
.copy_pixel_15_6
    lda &6fe7,x
    sta &6fe6,x
.copy_pixel_15_7
    lda &7120,x
    sta &6fe7,x
.copy_done_15
    dey
    bpl copy_columns_15
.copy_next_row_15
.copy_count_16
    ldy #&ff
    bmi copy_next_row_16
.copy_columns_16
    ldx &ffff,y
.copy_enter_16
    jmp copy_pixel_16_0
.copy_pixel_16_0
    lda &7121,x
    sta &7120,x
.copy_pixel_16_1
    lda &7122,x
    sta &7121,x
.copy_pixel_16_2
    lda &7123,x
    sta &7122,x
.copy_pixel_16_3
    lda &7124,x
    sta &7123,x
.copy_pixel_16_4
    lda &7125,x
    sta &7124,x
.copy_pixel_16_5
    lda &7126,x
    sta &7125,x
.copy_pixel_16_6
    lda &7127,x
    sta &7126,x
.copy_pixel_16_7
    lda &7260,x
    sta &7127,x
.copy_done_16
    dey
    bpl copy_columns_16
.copy_next_row_16
.copy_count_17
    ldy #&ff
    bmi copy_next_row_17
.copy_columns_17
    ldx &ffff,y
.copy_enter_17
    jmp copy_pixel_17_0
.copy_pixel_17_0
    lda &7261,x
    sta &7260,x
.copy_pixel_17_1
    lda &7262,x
    sta &7261,x
.copy_pixel_17_2
    lda &7263,x
    sta &7262,x
.copy_pixel_17_3
    lda &7264,x
    sta &7263,x
.copy_pixel_17_4
    lda &7265,x
    sta &7264,x
.copy_pixel_17_5
    lda &7266,x
    sta &7265,x
.copy_pixel_17_6
    lda &7267,x
    sta &7266,x
.copy_pixel_17_7
    lda &73a0,x
    sta &7267,x
.copy_done_17
    dey
    bpl copy_columns_17
.copy_next_row_17
.copy_count_18
    ldy #&ff
    bmi copy_next_row_18
.copy_columns_18
    ldx &ffff,y
.copy_enter_18
    jmp copy_pixel_18_0
.copy_pixel_18_0
    lda &73a1,x
    sta &73a0,x
.copy_pixel_18_1
    lda &73a2,x
    sta &73a1,x
.copy_pixel_18_2
    lda &73a3,x
    sta &73a2,x
.copy_pixel_18_3
    lda &73a4,x
    sta &73a3,x
.copy_pixel_18_4
    lda &73a5,x
    sta &73a4,x
.copy_pixel_18_5
    lda &73a6,x
    sta &73a5,x
.copy_pixel_18_6
    lda &73a7,x
    sta &73a6,x
.copy_pixel_18_7
    lda &74e0,x
    sta &73a7,x
.copy_done_18
    dey
    bpl copy_columns_18
.copy_next_row_18
.copy_count_19
    ldy #&ff
    bmi copy_next_row_19
.copy_columns_19
    ldx &ffff,y
.copy_enter_19
    jmp copy_pixel_19_0
.copy_pixel_19_0
    lda &74e1,x
    sta &74e0,x
.copy_pixel_19_1
    lda &74e2,x
    sta &74e1,x
.copy_pixel_19_2
    lda &74e3,x
    sta &74e2,x
.copy_pixel_19_3
    lda &74e4,x
    sta &74e3,x
.copy_pixel_19_4
    lda &74e5,x
    sta &74e4,x
.copy_pixel_19_5
    lda &74e6,x
    sta &74e5,x
.copy_pixel_19_6
    lda &74e7,x
    sta &74e6,x
.copy_pixel_19_7
    lda &7620,x
    sta &74e7,x
.copy_done_19
    dey
    bpl copy_columns_19
.copy_next_row_19
.copy_count_20
    ldy #&ff
    bmi copy_next_row_20
.copy_columns_20
    ldx &ffff,y
.copy_enter_20
    jmp copy_pixel_20_0
.copy_pixel_20_0
    lda &7621,x
    sta &7620,x
.copy_pixel_20_1
    lda &7622,x
    sta &7621,x
.copy_pixel_20_2
    lda &7623,x
    sta &7622,x
.copy_pixel_20_3
    lda &7624,x
    sta &7623,x
.copy_pixel_20_4
    lda &7625,x
    sta &7624,x
.copy_pixel_20_5
    lda &7626,x
    sta &7625,x
.copy_pixel_20_6
    lda &7627,x
    sta &7626,x
.copy_pixel_20_7
    lda &7760,x
    sta &7627,x
.copy_done_20
    dey
    bpl copy_columns_20
.copy_next_row_20
.copy_count_21
    ldy #&ff
    bmi copy_next_row_21
.copy_columns_21
    ldx &ffff,y
.copy_enter_21
    jmp copy_pixel_21_0
.copy_pixel_21_0
    lda &7761,x
    sta &7760,x
.copy_pixel_21_1
    lda &7762,x
    sta &7761,x
.copy_pixel_21_2
    lda &7763,x
    sta &7762,x
.copy_pixel_21_3
    lda &7764,x
    sta &7763,x
.copy_pixel_21_4
    lda &7765,x
    sta &7764,x
.copy_pixel_21_5
    lda &7766,x
    sta &7765,x
.copy_pixel_21_6
    lda &7767,x
    sta &7766,x
.copy_pixel_21_7
    lda &78a0,x
    sta &7767,x
.copy_done_21
    dey
    bpl copy_columns_21
.copy_next_row_21
.copy_count_22
    ldy #&ff
    bmi copy_next_row_22
.copy_columns_22
    ldx &ffff,y
.copy_enter_22
    jmp copy_pixel_22_0
.copy_pixel_22_0
    lda &78a1,x
    sta &78a0,x
.copy_pixel_22_1
    lda &78a2,x
    sta &78a1,x
.copy_pixel_22_2
    lda &78a3,x
    sta &78a2,x
.copy_pixel_22_3
    lda &78a4,x
    sta &78a3,x
.copy_pixel_22_4
    lda &78a5,x
    sta &78a4,x
.copy_pixel_22_5
    lda &78a6,x
    sta &78a5,x
.copy_pixel_22_6
    lda &78a7,x
    sta &78a6,x
.copy_pixel_22_7
    lda &79e0,x
    sta &78a7,x
.copy_done_22
    dey
    bpl copy_columns_22
.copy_next_row_22
.copy_count_23
    ldy #&ff
    bmi copy_next_row_23
.copy_columns_23
    ldx &ffff,y
.copy_enter_23
    jmp copy_pixel_23_0
.copy_pixel_23_0
    lda &79e1,x
    sta &79e0,x
.copy_pixel_23_1
    lda &79e2,x
    sta &79e1,x
.copy_pixel_23_2
    lda &79e3,x
    sta &79e2,x
.copy_pixel_23_3
    lda &79e4,x
    sta &79e3,x
.copy_pixel_23_4
    lda &79e5,x
    sta &79e4,x
.copy_pixel_23_5
    lda &79e6,x
    sta &79e5,x
.copy_pixel_23_6
    lda &79e7,x
    sta &79e6,x
.copy_pixel_23_7
    lda &7b20,x
    sta &79e7,x
.copy_done_23
    dey
    bpl copy_columns_23
.copy_next_row_23
.copy_count_24
    ldy #&ff
    bmi copy_next_row_24
.copy_columns_24
    ldx &ffff,y
.copy_enter_24
    jmp copy_pixel_24_0
.copy_pixel_24_0
    lda &7b21,x
    sta &7b20,x
.copy_pixel_24_1
    lda &7b22,x
    sta &7b21,x
.copy_pixel_24_2
    lda &7b23,x
    sta &7b22,x
.copy_pixel_24_3
    lda &7b24,x
    sta &7b23,x
.copy_pixel_24_4
    lda &7b25,x
    sta &7b24,x
.copy_pixel_24_5
    lda &7b26,x
    sta &7b25,x
.copy_pixel_24_6
    lda &7b27,x
    sta &7b26,x
.copy_pixel_24_7
    lda &7c60,x
    sta &7b27,x
.copy_done_24
    dey
    bpl copy_columns_24
.copy_next_row_24
.copy_count_25
    ldy #&ff
    bmi copy_next_row_25
.copy_columns_25
    ldx &ffff,y
.copy_enter_25
    jmp copy_pixel_25_0
.copy_pixel_25_0
    lda &7c61,x
    sta &7c60,x
.copy_pixel_25_1
    lda &7c62,x
    sta &7c61,x
.copy_pixel_25_2
    lda &7c63,x
    sta &7c62,x
.copy_pixel_25_3
    lda &7c64,x
    sta &7c63,x
.copy_pixel_25_4
    lda &7c65,x
    sta &7c64,x
.copy_pixel_25_5
    lda &7c66,x
    sta &7c65,x
.copy_pixel_25_6
    lda &7c67,x
    sta &7c66,x
.copy_pixel_25_7
    lda &7da0,x
    sta &7c67,x
.copy_done_25
    dey
    bpl copy_columns_25
.copy_next_row_25
.copy_count_26
    ldy #&ff
    bmi copy_next_row_26
.copy_columns_26
    ldx &ffff,y
.copy_enter_26
    jmp copy_pixel_26_0
.copy_pixel_26_0
    lda &7da1,x
    sta &7da0,x
.copy_pixel_26_1
    lda &7da2,x
    sta &7da1,x
.copy_pixel_26_2
    lda &7da3,x
    sta &7da2,x
.copy_pixel_26_3
    lda &7da4,x
    sta &7da3,x
.copy_pixel_26_4
    lda &7da5,x
    sta &7da4,x
.copy_pixel_26_5
    lda &7da6,x
    sta &7da5,x
.copy_pixel_26_6
    lda &7da7,x
    sta &7da6,x
.copy_pixel_26_7
    lda &7ee0,x
    sta &7da7,x
.copy_done_26
    dey
    bpl copy_columns_26
.copy_next_row_26
.copy_count_27
    ldy #&ff
    bmi copy_next_row_27
.copy_columns_27
    ldx &ffff,y
.copy_enter_27
    jmp copy_pixel_27_0
.copy_pixel_27_0
    lda &7ee1,x
    sta &7ee0,x
.copy_pixel_27_1
    lda &7ee2,x
    sta &7ee1,x
.copy_pixel_27_2
    lda &7ee3,x
    sta &7ee2,x
.copy_pixel_27_3
    lda &7ee4,x
    sta &7ee3,x
.copy_pixel_27_4
    lda &7ee5,x
    sta &7ee4,x
.copy_pixel_27_5
    lda &7ee6,x
    sta &7ee5,x
.copy_pixel_27_6
    lda &7ee7,x
    sta &7ee6,x
.copy_pixel_27_7
    lda copy_zero
    sta &7ee7,x
.copy_done_27
    dey
    bpl copy_columns_27
.copy_next_row_27
.scroll_copy_end
    rts
.copy_configure_lines
.copy_configure_row_0
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #0
    tax
    lda copy_columns_low,x
    sta copy_columns_0+1
    lda copy_columns_high,x
    sta copy_columns_0+2
    lda copy_columns_count,x
    sta copy_count_0+1
.copy_configure_row_1
    lda copy_line_number
    clc
    adc #1
    tax
    lda copy_columns_low,x
    sta copy_columns_1+1
    lda copy_columns_high,x
    sta copy_columns_1+2
    lda copy_columns_count,x
    sta copy_count_1+1
.copy_configure_row_2
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #1
    tax
    lda copy_columns_low,x
    sta copy_columns_2+1
    lda copy_columns_high,x
    sta copy_columns_2+2
    lda copy_columns_count,x
    sta copy_count_2+1
.copy_configure_row_3
    lda copy_line_number
    clc
    adc #2
    tax
    lda copy_columns_low,x
    sta copy_columns_3+1
    lda copy_columns_high,x
    sta copy_columns_3+2
    lda copy_columns_count,x
    sta copy_count_3+1
.copy_configure_row_4
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #2
    tax
    lda copy_columns_low,x
    sta copy_columns_4+1
    lda copy_columns_high,x
    sta copy_columns_4+2
    lda copy_columns_count,x
    sta copy_count_4+1
.copy_configure_row_5
    lda copy_line_number
    clc
    adc #3
    tax
    lda copy_columns_low,x
    sta copy_columns_5+1
    lda copy_columns_high,x
    sta copy_columns_5+2
    lda copy_columns_count,x
    sta copy_count_5+1
.copy_configure_row_6
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #3
    tax
    lda copy_columns_low,x
    sta copy_columns_6+1
    lda copy_columns_high,x
    sta copy_columns_6+2
    lda copy_columns_count,x
    sta copy_count_6+1
.copy_configure_row_7
    lda copy_line_number
    clc
    adc #4
    tax
    lda copy_columns_low,x
    sta copy_columns_7+1
    lda copy_columns_high,x
    sta copy_columns_7+2
    lda copy_columns_count,x
    sta copy_count_7+1
.copy_configure_row_8
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #4
    tax
    lda copy_columns_low,x
    sta copy_columns_8+1
    lda copy_columns_high,x
    sta copy_columns_8+2
    lda copy_columns_count,x
    sta copy_count_8+1
.copy_configure_row_9
    lda copy_line_number
    clc
    adc #5
    tax
    lda copy_columns_low,x
    sta copy_columns_9+1
    lda copy_columns_high,x
    sta copy_columns_9+2
    lda copy_columns_count,x
    sta copy_count_9+1
.copy_configure_row_10
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #5
    tax
    lda copy_columns_low,x
    sta copy_columns_10+1
    lda copy_columns_high,x
    sta copy_columns_10+2
    lda copy_columns_count,x
    sta copy_count_10+1
.copy_configure_row_11
    lda copy_line_number
    clc
    adc #6
    tax
    lda copy_columns_low,x
    sta copy_columns_11+1
    lda copy_columns_high,x
    sta copy_columns_11+2
    lda copy_columns_count,x
    sta copy_count_11+1
.copy_configure_row_12
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #6
    tax
    lda copy_columns_low,x
    sta copy_columns_12+1
    lda copy_columns_high,x
    sta copy_columns_12+2
    lda copy_columns_count,x
    sta copy_count_12+1
.copy_configure_row_13
    lda copy_line_number
    clc
    adc #7
    tax
    lda copy_columns_low,x
    sta copy_columns_13+1
    lda copy_columns_high,x
    sta copy_columns_13+2
    lda copy_columns_count,x
    sta copy_count_13+1
.copy_configure_row_14
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #7
    tax
    lda copy_columns_low,x
    sta copy_columns_14+1
    lda copy_columns_high,x
    sta copy_columns_14+2
    lda copy_columns_count,x
    sta copy_count_14+1
.copy_configure_row_15
    lda copy_line_number
    clc
    adc #8
    tax
    lda copy_columns_low,x
    sta copy_columns_15+1
    lda copy_columns_high,x
    sta copy_columns_15+2
    lda copy_columns_count,x
    sta copy_count_15+1
.copy_configure_row_16
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #8
    tax
    lda copy_columns_low,x
    sta copy_columns_16+1
    lda copy_columns_high,x
    sta copy_columns_16+2
    lda copy_columns_count,x
    sta copy_count_16+1
.copy_configure_row_17
    lda copy_line_number
    clc
    adc #9
    tax
    lda copy_columns_low,x
    sta copy_columns_17+1
    lda copy_columns_high,x
    sta copy_columns_17+2
    lda copy_columns_count,x
    sta copy_count_17+1
.copy_configure_row_18
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #9
    tax
    lda copy_columns_low,x
    sta copy_columns_18+1
    lda copy_columns_high,x
    sta copy_columns_18+2
    lda copy_columns_count,x
    sta copy_count_18+1
.copy_configure_row_19
    lda copy_line_number
    clc
    adc #10
    tax
    lda copy_columns_low,x
    sta copy_columns_19+1
    lda copy_columns_high,x
    sta copy_columns_19+2
    lda copy_columns_count,x
    sta copy_count_19+1
.copy_configure_row_20
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #10
    tax
    lda copy_columns_low,x
    sta copy_columns_20+1
    lda copy_columns_high,x
    sta copy_columns_20+2
    lda copy_columns_count,x
    sta copy_count_20+1
.copy_configure_row_21
    lda copy_line_number
    clc
    adc #11
    tax
    lda copy_columns_low,x
    sta copy_columns_21+1
    lda copy_columns_high,x
    sta copy_columns_21+2
    lda copy_columns_count,x
    sta copy_count_21+1
.copy_configure_row_22
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #11
    tax
    lda copy_columns_low,x
    sta copy_columns_22+1
    lda copy_columns_high,x
    sta copy_columns_22+2
    lda copy_columns_count,x
    sta copy_count_22+1
.copy_configure_row_23
    lda copy_line_number
    clc
    adc #12
    tax
    lda copy_columns_low,x
    sta copy_columns_23+1
    lda copy_columns_high,x
    sta copy_columns_23+2
    lda copy_columns_count,x
    sta copy_count_23+1
.copy_configure_row_24
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #12
    tax
    lda copy_columns_low,x
    sta copy_columns_24+1
    lda copy_columns_high,x
    sta copy_columns_24+2
    lda copy_columns_count,x
    sta copy_count_24+1
.copy_configure_row_25
    lda copy_line_number
    clc
    adc #13
    tax
    lda copy_columns_low,x
    sta copy_columns_25+1
    lda copy_columns_high,x
    sta copy_columns_25+2
    lda copy_columns_count,x
    sta copy_count_25+1
.copy_configure_row_26
    ldx stream_phase
    cpx #8
    lda copy_line_number
    adc #13
    tax
    lda copy_columns_low,x
    sta copy_columns_26+1
    lda copy_columns_high,x
    sta copy_columns_26+2
    lda copy_columns_count,x
    sta copy_count_26+1
.copy_configure_row_27
    lda copy_line_number
    clc
    adc #14
    tax
    lda copy_columns_low,x
    sta copy_columns_27+1
    lda copy_columns_high,x
    sta copy_columns_27+2
    lda copy_columns_count,x
    sta copy_count_27+1
    rts
; Address tables for the runtime code and phase patcher.
; Split address tables indexed by physical screen character row (0..27):
; kernel = first pixel LDA; enter = operand of the entry JMP to patch;
; done = column-loop tail (early-exit target); backup = saved LDA triples.
; Emit the eight original LDA triples for one physical character row.
MACRO copy_backup row
    FOR pixel, 0, 6
        EQUB &BD, <(&5D20+row*&140+pixel+1), >(&5D20+row*&140+pixel+1)
    NEXT
    IF row = 27
        EQUB &AD, <copy_zero, >copy_zero
    ELSE
        EQUB &BD, <(&5D20+(row+1)*&140), >(&5D20+(row+1)*&140)
    ENDIF
ENDMACRO

.copy_backup_0
; Runtime-generated instruction backups, not screen pixel backups.
; Each copy_backup_X is 24 bytes: eight original LDA instruction triples,
; in pixel order 0..7, for physical screen character row X (0..27).
; generate_scroll_code writes these from the completed kernels. The phase
; patcher restores a triple before replacing another with an early-exit JMP.
; Normally a triple is &BD, source low, source high (LDA absolute,X).
; Pixels 0..6 read the next scanline in the same character row; pixel 7
; reads the next character row (+&140). Row 27/pixel 7 uses &AD and copy_zero
; (LDA absolute) to clear the bottom, retaining a three-byte instruction.
    copy_backup 0
.copy_backup_1
    copy_backup 1
.copy_backup_2
    copy_backup 2
.copy_backup_3
    copy_backup 3
.copy_backup_4
    copy_backup 4
.copy_backup_5
    copy_backup 5
.copy_backup_6
    copy_backup 6
.copy_backup_7
    copy_backup 7
.copy_backup_8
    copy_backup 8
.copy_backup_9
    copy_backup 9
.copy_backup_10
    copy_backup 10
.copy_backup_11
    copy_backup 11
.copy_backup_12
    copy_backup 12
.copy_backup_13
    copy_backup 13
.copy_backup_14
    copy_backup 14
.copy_backup_15
    copy_backup 15
.copy_backup_16
    copy_backup 16
.copy_backup_17
    copy_backup 17
.copy_backup_18
    copy_backup 18
.copy_backup_19
    copy_backup 19
.copy_backup_20
    copy_backup 20
.copy_backup_21
    copy_backup 21
.copy_backup_22
    copy_backup 22
.copy_backup_23
    copy_backup 23
.copy_backup_24
    copy_backup 24
.copy_backup_25
    copy_backup 25
.copy_backup_26
    copy_backup 26
.copy_backup_27
    copy_backup 27

.generated_workspace_end
ASSERT generated_workspace_end <= &5bc0
ASSERT copy_count_1-copy_count_0 = 61
ASSERT copy_next_row_27-copy_count_27 = 61
ASSERT copy_configure_row_1-copy_configure_row_0 = 29
ASSERT copy_configure_row_2-copy_configure_row_1 = 25
COPYBLOCK copy_count_0, copy_count_1, copy_kernel_template
COPYBLOCK copy_configure_row_0, copy_configure_row_1, copy_config_even_template
COPYBLOCK copy_configure_row_1, copy_configure_row_2, copy_config_odd_template


save "build/dataQ", pydis_start, pydis_end
