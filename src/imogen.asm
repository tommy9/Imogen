; Constants
crtc_cursor_start                       = 10
crtc_interlace_delay                    = 8
crtc_screen_start_high                  = 12
crtc_screen_start_low                   = 13
crtc_vert_displayed                     = 6
crtc_vert_sync_pos                      = 7
game_area_height_cells                  = 24
jmp_indirect_opcode                     = 108
jsr_opcode                              = 32
osbyte_flush_buffer                     = 21
osbyte_opt                              = 139
osbyte_read_write_escape_break_effect   = 200
osbyte_tv                               = 144
osfile                                  = 65501
osword_read_char                        = 10
vdu_disable                             = 21
vdu_goto_xy                             = 31
vdu_set_mode                            = 22

; Memory locations
l0000                   = &0000
l0001                   = &0001
l0002                   = &0002
l0003                   = &0003
l0004                   = &0004
l0005                   = &0005
source_address_low      = &0070
source_address_high     = &0071
destination_address_low = &0072
destination_address_high = &0073
l0074                   = &0074
l0076                   = &0076
l0080                   = &0080
l0081                   = &0081
l0082                   = &0082
l0086                   = &0086
l0087                   = &0087
l0088                   = &0088
load_address            = &3900
screen_start            = &6200
crtc_address_register   = &fe00
crtc_address_write      = &fe01
oswrch                  = &ffee
osword                  = &fff1
osbyte                  = &fff4
oscli                   = &fff7

    org &1200

.relocate_address
.relocate
.pydis_start
    lda #0
    sta source_address_low
    sta destination_address_low
    lda #>relocate_address
    sta source_address_high
    lda #>load_address
    sta destination_address_high
    ldy #0
.relocate_loop
    lda (destination_address_low),y
    sta (source_address_low),y
    iny
    bne relocate_loop
    inc source_address_high
    inc destination_address_high
    lda destination_address_high
; Round up: removing the pause leaves the final page only partially occupied.
    cmp #>(load_address + (pydis_end - pydis_start) + &ff)
    bne relocate_loop
    jmp post_relocate_init

    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.post_relocate_init
    lda #osbyte_opt
    ldx #0
    ldy #0
    jsr osbyte; *OPT 0,0: Reset all options for current filing system
; Redundant LDX/LDY here; drive_0_command is not actually used.
    ldx #<drive_0_command
    ldy #>drive_0_command
; *DIR $
    ldx #<dir_dollar_command
    ldy #>dir_dollar_command
    jsr oscli
; *FX 200,1
    lda #osbyte_read_write_escape_break_effect
    ldx #1
    ldy #0
    jsr osbyte; Write Disable ESCAPE action, set normal BREAK action, value X=1
; Read the user's current vertical shift as set by *TV.
    lda #osbyte_tv
    ldx #0
    ldy #0
    jsr osbyte; *TV 0,0 turn interlace on
    stx source_address_low; X is the previous screen shift setting
    jsr osbyte
; MODE 4
    lda #vdu_set_mode
; Set up a reduced-height mode 4 screen with 24 character lines starting at address
; &6200, respecting the user's current vertical shift as set by *TV.
    jsr oswrch; Write character 22
    lda #4
    jsr oswrch; Write character 4
    lda #crtc_cursor_start
    sta crtc_address_register
    lda #&20
    sta crtc_address_write
    lda #&23
    clc
    adc source_address_low
    sec
    sbc #6
    tax
    lda #crtc_vert_sync_pos
    sta crtc_address_register
    stx crtc_address_write
    lda #crtc_screen_start_low
    sta crtc_address_register
    lda #<(screen_start DIV 8)
    sta crtc_address_write
    lda #crtc_screen_start_high
    sta crtc_address_register
    lda #>(screen_start DIV 8)
    sta crtc_address_write
    lda #crtc_vert_displayed
    sta crtc_address_register
    lda #game_area_height_cells
    sta crtc_address_write
    lda #crtc_interlace_delay
    sta crtc_address_register
    lda #0
    sta crtc_address_write
; Draw immediately; startup already spends time loading and checking the SWR bank.
; Copy the logo to &6840. Both pointers start &80 bytes earlier because Y starts
; at &80; the first iteration copies half a page, followed by seven full pages.
    ldx #8
    ldy #&80
    sty l0074
    lda #<imogen_logo
    sec
    sbc l0074
    sta source_address_low
    lda #>imogen_logo
    sbc #0
    sta source_address_high
    lda #&40
    sec
    sbc l0074
    sta destination_address_low
    lda #&68
    sbc #0
    sta destination_address_high
.copy_loop
    lda (source_address_low),y
    sta (destination_address_low),y
    iny
    bne copy_loop
    inc source_address_high
    inc destination_address_high
    dex
    bne copy_loop
    lda #vdu_goto_xy
    jsr oswrch; Write character 31
    lda #6
    jsr oswrch; Write character 6
    lda #&15
    jsr oswrch; Write character 21
    ldy #0
.print_written_by_string_loop
    lda written_by_string,y
    cmp #&0d
    beq finished_written_by_string
    jsr print_italic
    iny
    jmp print_written_by_string_loop

; PRINT TAB(3,23)
.finished_written_by_string
    lda #vdu_goto_xy
    jsr oswrch
    lda #3
    jsr oswrch
    lda #23
    jsr oswrch
    ldy #0
.print_copyright_string_loop
    lda copyright_string,y
    cmp #&0d
    beq finished_tape_order_prompt_string
    jsr print_italic
    iny
    jmp print_copyright_string_loop

.finished_tape_order_prompt_string
; The MOS keyboard buffer carries a T press through the game loading.
; Discard keys typed before the prompt is shown.
    lda #osbyte_flush_buffer
    ldx #0
    jsr osbyte

; PRINT TAB(3,26)
    lda #vdu_goto_xy
    jsr oswrch
    lda #3
    jsr oswrch
    lda #26
    jsr oswrch
    ldy #0
.print_tape_order_prompt_loop
    lda tape_order_prompt,y
    cmp #&0d
    beq finished_tape_order_prompt
    jsr print_italic
    iny
    bne print_tape_order_prompt_loop
.finished_tape_order_prompt
    lda #vdu_disable
    jsr oswrch; Write character 21
; Obfuscated code to load the 'G' file and transfer control to its execution address,
; relying on the fact that OSFILE &FF will have filled in the execution address at &76
; after loading the file.
; At address zero, write 'JSR osfile:JMP ($76)'
    lda #jsr_opcode
    sta l0000
    lda #<osfile
    sta l0001
    lda #>osfile
    sta l0002
    lda #jmp_indirect_opcode
    sta l0003
    lda #&76
    sta l0004
    lda #0
    sta l0005
; point to filename
    lda #<osfile_load_filename
    sta source_address_low
    lda #>osfile_load_filename
    sta source_address_high
; Set A=&FF for OSFILE to load a file. We also store this at &76, which is byte 6 of
; the control block, telling OSFILE to load at the file's own load address.
    lda #&ff
    sta l0076
    ldx #<source_address_low
    ldy #>source_address_low
    jmp l0000

.print_italic
    cmp #&21
    bcc print_character
    cmp #&7f
    bcs print_character
    sta l0080
    txa
    pha
    tya
    pha
; read character definition
    lda #osword_read_char
    ldx #<(l0080)
    ldy #>(l0080)
    jsr osword; Read character definition
; shift the rows of the character definition to italicise it
    lsr l0081
    lsr l0082
    asl l0086
    asl l0087
    asl l0088
; redefine character 255 to the italicised character
    lda #&17
    jsr oswrch; Write character 23
    lda #&ff
    jsr oswrch; Write character 255
    ldx #0
.print_italic_loop
    lda l0081,x
    jsr oswrch; Write character
    inx
    cpx #8
    bcc print_italic_loop
    pla
    tay
    pla
    tax
    lda #&ff
.print_character
    jmp oswrch; Write character 255

.drive_0_command
    equs "DRIVE 0"
    equb &0d
.dir_dollar_command
    equs "DIR $"
    equb &0d

.osfile_load_filename
    equs "G", &0d
.written_by_string
    equs "Written by Michael St Aubyn"
    equb &0d
.copyright_string
    equs "Copyright Micro Power Limited 1986"
    equb &0d
.tape_order_prompt
    equs "Press T to use the tape level order"
    equb &0d

.imogen_logo
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   1,   1,   1,   0,   0,   0,   0,   0, &ff, &ff, &ff, &1f
    equb &0f, &0f, &1f, &1f, &ff, &ff, &ff, &fc, &f0, &e0, &e0, &e0
    equb &c0, &c0, &c0,   0,   0,   0,   0,   0,   1,   1,   1,   0
    equb   0,   0,   0,   0, &ff, &ff, &ff, &1f, &0f, &1f, &1f, &1f
    equb &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   1,   1,   3,   7,   7
    equb &7f, &ff, &ff, &ff, &ff, &fe, &fe, &fe, &fc, &fc, &fc, &c0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   1,   3,   7,   1, &0f, &3f, &7f
    equb &ff, &fc, &fc, &f8, &ff, &ff, &ff, &c1,   0,   0,   0,   0
    equb &c0, &f0, &f8, &fc, &fe, &7e, &7f, &3f,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   1,   0,   3, &0f, &1f
    equb &3f, &7f, &ff, &fe, &7f, &ff, &ff, &f0, &c0,   0,   0,   0
    equb &f0, &fc, &fe, &3f, &0f,   7,   3,   1, &38, &78, &78, &f8
    equb &f8, &f0, &f0, &f0,   0,   0,   0,   0,   0,   0,   0,   0
    equb &0f, &0f, &0f,   0,   0,   0,   0,   0, &ff, &ff, &ff, &ff
    equb &7f, &7f, &ff, &ff, &ff, &ff, &ff, &e0, &80,   0,   0,   0
    equb &ff, &ff, &ff, &0f,   3,   1,   1,   0, &f8, &f8, &f8, &f8
    equb &f8, &f0, &f0, &f0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0, &ff, &ff, &ff, &0f
    equb   7, &0f, &0f, &0e, &f8, &f8, &fc, &fc, &fc, &fe, &fe, &fe
    equb   0,   0,   0,   0,   0,   0,   0,   0, &3f, &3f, &3f,   3
    equb   1,   1,   1,   1, &ff, &ff, &ff, &fc, &f0, &e0, &c0, &c0
    equb &80, &80, &80,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &1f, &3f, &3f, &3f, &3f, &7f, &7f, &7f
    equb &c0, &c0, &c0, &80, &80, &80, &80,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb &1f, &3f, &3f, &3f, &7f, &7b, &73, &f3, &f0, &f8, &f8, &f8
    equb &f8, &f8, &f8, &f8,   0,   0,   0,   0,   0,   0,   0,   0
    equb &0f, &1f, &1f, &3f, &3f, &7f, &ff, &f7, &fc, &fc, &fc, &f8
    equb &f8, &f8, &f8, &f0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   7, &0f, &1f, &1f
    equb &3f, &3f, &7f, &7f, &f0, &f0, &e0, &c0, &c0, &80, &80, &80
    equb   0,   0,   0,   0,   0,   0,   0,   0, &3f, &3f, &3f, &3f
    equb &3f, &3f, &3f, &3f,   0, &80, &80, &80, &80, &80, &80, &80
    equb   0,   0,   0,   0,   0,   0,   0,   0,   1,   3,   7,   7
    equb &0f, &0f, &1f, &1f, &fc, &fc, &f8, &f0, &f0, &e0, &e0, &e0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   1,   0,   0,   0
    equb   0,   0,   0,   0, &f0, &f0, &f0, &e0, &e0, &e0, &e0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1
    equb   1,   3,   3,   3, &fe, &fe, &fe, &fc, &fc, &fc, &fc, &f8
    equb   0,   0,   0,   0,   3,   7,   7, &0f,   0,   0,   0,   0
    equb &80, &80, &80, &80, &f0, &f0, &f0, &e0, &e0, &e0, &e0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &0e, &1e, &1e, &1c, &3c, &3c, &38, &78
    equb &ff, &ff, &7f, &7f, &7f, &3f, &3f, &3f,   0,   0,   0, &80
    equb &80, &80, &c0, &c0,   3,   3,   3,   7,   7,   7, &0f, &0f
    equb &c0, &c0, &80, &80, &80,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1,   3
    equb &ff, &ff, &fe, &fe, &fe, &fe, &fc, &fc,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   1,   1,   1,   3,   3, &f3, &e3, &e3, &e3
    equb &e3, &c3, &c3, &c3, &f8, &f8, &f8, &f8, &f8, &f8, &f8, &f8
    equb   1,   1,   3,   7,   7, &0f, &0f, &1e, &ef, &ef, &cf, &cf
    equb &9f, &1f, &1f, &3f, &f0, &f0, &e0, &e0, &e0, &e0, &c0, &c0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   1,   1,   1,   1, &7f, &ff, &ff, &fe, &fe, &fe, &fc, &fc
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &3f, &3f, &7f, &7f, &7f, &7f, &ff, &ff
    equb &80, &80, &80, &80,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &1f, &3f, &3f, &3f, &7f, &7f, &7f, &7f
    equb &c0, &c0, &c0, &80, &80, &80,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   7,   7,   7,   7, &0f, &0f, &0f, &1f
    equb &f8, &f8, &f0, &f0, &ff, &ff, &ff, &e0, &0f, &1f, &3f, &ff
    equb &fe, &fe, &fe, &fe,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1
    equb &78, &70, &70, &f0, &f0, &e0, &e0, &e0, &1f, &1f, &1f, &0f
    equb &0f, &0f,   7,   7, &c0, &e0, &e0, &e0, &f0, &f0, &f0, &f8
    equb &0e, &0e, &1e, &1e, &1c, &3c, &3c, &38,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   3,   3,   3,   7,   7,   7, &0f, &0f, &fc, &f8, &f8, &f8
    equb &f8, &f0, &f0, &f0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   3,   7,   7,   7
    equb   7, &0f, &0f, &0e, &83, &83, &83,   3,   3,   3,   3,   1
    equb &f8, &f8, &f8, &fc, &fc, &fd, &fd, &ff, &3e, &3c, &78, &f8
    equb &f0, &e0, &e0, &c0, &3f, &3f, &3f, &7f, &7f, &7f, &ff, &ff
    equb &c0, &80, &80, &80, &80,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   3,   3,   3,   3,   3,   3,   3,   3
    equb &fc, &fc, &f8, &f8, &f8, &f8, &f8, &f8,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   1,   1,   1,   3,   3,   7
    equb &fe, &fe, &fe, &fe, &fc, &fc, &fc, &f8,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb &ff, &ff, &fe, &fe, &fe, &fe, &fe, &fe,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0, &3f, &3f, &3f,   3
    equb   0,   0,   0,   0, &ff, &ff, &ff, &ff,   0,   0,   0,   0
    equb &f8, &f8, &f8, &80,   0,   0,   0,   0,   0,   0,   0,   0
    equb &1f, &1f, &1f, &3f, &3f, &3f, &7f, &7f, &e0, &c0, &c0, &c0
    equb &c0, &80, &80, &80, &7c, &3c, &3c, &3c, &38, &38, &38,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   1,   3,   3,   3,   3,   7,   7,   7, &c0, &c0, &c0, &80
    equb &80, &80, &80,   0,   7,   3,   3,   3,   1,   1,   1,   0
    equb &f8, &f8, &fc, &fc, &fc, &fe, &fe, &ff, &38, &78, &78, &70
    equb &f0, &f0, &e0, &e0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0, &0f, &0f, &1f, &1f
    equb &1f, &3f, &3f, &3f, &e0, &e0, &e0, &e0, &c0, &c0, &c0, &80
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &1e, &1e, &1c, &3c, &3c, &38, &38, &78
    equb   1,   1,   1,   1,   1,   1,   1,   1, &ff, &ff, &ff, &ff
    equb &fe, &fe, &fc, &f8, &c0, &80,   1,   1,   1,   3,   3,   3
    equb &fe, &fe, &fe, &fe, &fc, &fc, &fc, &f8,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   3,   3,   3,   3,   1,   1,   1,   0, &f8, &f8, &f8, &f8
    equb &f8, &fc, &fc, &fe,   0,   0,   0,   0,   0,   0,   0,   0
    equb   7, &0f, &0f, &1f, &1f, &3f, &7f, &7f, &f8, &f0, &f0, &e0
    equb &c0, &c0, &80,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0, &fe, &fe, &fe, &fe
    equb &7e, &7f, &7f, &3f,   0,   0,   0,   0,   0,   0,   0, &80
    equb   1,   3,   3,   7,   7, &0f, &1f, &1f, &fe, &fc, &f8, &f0
    equb &f0, &e0, &e0, &c0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   1,   1,   1, &7f, &7f, &ff, &ff
    equb &fe, &fe, &fe, &fc,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   1,   1,   3, &0f, &38, &78, &78, &f8
    equb &f0, &f0, &e0, &e0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0, &0f, &0f, &0e, &1e
    equb &1e, &1c, &1c, &3c,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0, &ff, &ff, &7f, &7f
    equb &7f, &3f, &3f, &3f, &e0, &c0, &c0, &c0, &c0, &80, &80, &80
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   1, &1f, &1f
    equb &1f,   0,   0,   0, &7f, &ff, &ff, &ff, &ff,   0,   0,   0
    equb &80, &c0, &fc, &fc, &fc,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   1, &1f, &1f, &1f,   0,   0,   0
    equb &78, &fe, &ff, &ff, &ff,   0,   0,   0,   1,   1, &c1, &c1
    equb &c1,   0,   0,   0, &f8, &f0, &e1, &e1, &c1,   0,   0,   0
    equb   7, &1f, &ff, &ff, &ff,   0,   0,   0, &f8, &fc, &ff, &ff
    equb &ff,   0,   0,   0,   0,   0, &c0, &c0, &c0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &fe, &7f, &3f, &0f,   3,   0,   0,   0
    equb   0,   3, &ff, &ff, &ff,   0,   0,   0, &fe, &fc, &f8, &e0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &3f, &1f, &0f,   3,   0,   0,   0,   0
    equb &c0, &f0, &ff, &ff, &7f,   0,   0,   0, &3f, &ff, &fe, &f8
    equb &c0,   0,   0,   0, &80,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   3, &0f, &ff, &ff
    equb &ff,   0,   0,   0, &fc, &fe, &ff, &ff, &ff,   0,   0,   0
    equb   0,   1, &ff, &ff, &ff,   0,   0,   0, &1f, &ff, &ff, &ff
    equb &ff,   0,   0,   0, &e0, &c0, &c0, &80, &80,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, &0f, &0f
    equb &0f,   0,   0,   0, &3c, &ff, &ff, &ff, &ff,   0,   0,   0
    equb   0,   0, &e0, &e0, &e0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0, &1f, &1f, &1f, &0e, &0e,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
    equb   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
; unused?
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    equb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.pydis_end

save "build/imogen", pydis_start, pydis_end
