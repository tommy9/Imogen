; Generated from levelM.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 29
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 19 x 9, offset (-3, 7)
sprite_c8_width = 19
sprite_c8_height = 9
sprite_c8_plane_size = 27
sprite_c8_reserved_size = 0
.mask_data ; first drawable sprite, for the existing renderer test
.sprite_c8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %10001111
    EQUB %10001110
    EQUB %10001000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %10001111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00011111
    EQUB %00111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %11111111
    EQUB %11111111
}

.sprite_data ; first drawable sprite, for the existing renderer test
.sprite_c8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %00000000
    EQUB %00100000
    EQUB %00100001
    EQUB %00100111
    EQUB %00110100
    EQUB %00010011
    EQUB %00000111
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %00000000
    EQUB %00100000
    EQUB %10101110
    EQUB %00101101
    EQUB %01100000
    EQUB %01000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11100000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_c8
{
    EQUB &FD, &07, 19, 9
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 18 x 9, offset (-8, 7)
sprite_c9_width = 18
sprite_c9_height = 9
sprite_c9_plane_size = 27
sprite_c9_reserved_size = 0
.sprite_c9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11111110
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111000
    EQUB %00111000
    EQUB %01111100
    EQUB %00011100
    EQUB %00000100
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    ; Byte column 2, rows top-to-bottom
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_c9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000000
    EQUB %00000001
    EQUB %01110101
    EQUB %11101101
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000000
    EQUB %00000001
    EQUB %01100001
    EQUB %00111001
    EQUB %10100011
    EQUB %10011010
    EQUB %00111000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_c9
{
    EQUB &F8, &07, 18, 9
    EQUW sprite_c9_mask_data, sprite_c9_sprite_data
}

; Sprite &CA: 8 x 4, offset (0, 5)
sprite_ca_width = 8
sprite_ca_height = 4
sprite_ca_plane_size = 4
sprite_ca_reserved_size = 0
.sprite_ca_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_ca_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01110111
    EQUB %11101110
    EQUB %00000000
}

.sprite_ca
{
    EQUB &00, &05, 8, 4
    EQUW sprite_ca_mask_data, sprite_ca_sprite_data
}

; Sprite &CB: 5 x 8, offset (1, 7)
sprite_cb_width = 5
sprite_cb_height = 8
sprite_cb_plane_size = 8
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
}

.sprite_cb_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01100000
    EQUB %01010000
    EQUB %00110000
    EQUB %01110000
    EQUB %01100000
    EQUB %01010000
    EQUB %00110000
    EQUB %01110000
}

.sprite_cb
{
    EQUB &01, &07, 5, 8
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 5 x 4, offset (1, 3)
sprite_cc_width = 5
sprite_cc_height = 4
sprite_cc_plane_size = 4
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
}

.sprite_cc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01100000
    EQUB %01010000
    EQUB %00110000
    EQUB %01110000
}

.sprite_cc
{
    EQUB &01, &03, 5, 4
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 7 x 16, offset (0, 15)
sprite_cd_width = 7
sprite_cd_height = 16
sprite_cd_plane_size = 16
sprite_cd_reserved_size = 0
.sprite_cd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
}

.sprite_cd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10110010
    EQUB %10101010
    EQUB %10011010
    EQUB %10111010
    EQUB %10001010
    EQUB %01010010
    EQUB %11010010
    EQUB %10110100
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
}

.sprite_cd
{
    EQUB &00, &0F, 7, 16
    EQUW sprite_cd_mask_data, sprite_cd_sprite_data
}

; Sprite &CE: 23 x 21, offset (0, 14)
sprite_ce_width = 23
sprite_ce_height = 21
sprite_ce_plane_size = 63
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00111111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00011111
}

.sprite_ce_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01001111
    EQUB %01110000
    EQUB %01100111
    EQUB %01110111
    EQUB %01110011
    EQUB %01111011
    EQUB %00110011
    EQUB %00111011
    EQUB %01110011
    EQUB %01110111
    EQUB %01100111
    EQUB %01110111
    EQUB %01110011
    EQUB %00111011
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00000000
    EQUB %00111001
    EQUB %10111101
    EQUB %00110011
    EQUB %10111011
    EQUB %10011001
    EQUB %11011101
    EQUB %10011001
    EQUB %11011101
    EQUB %00111001
    EQUB %10111101
    EQUB %00111001
    EQUB %10111101
    EQUB %00111001
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
    EQUB %00011100
    EQUB %10011000
    EQUB %11011100
    EQUB %10011000
    EQUB %11011100
    EQUB %10011000
    EQUB %11011100
    EQUB %10011000
    EQUB %11101100
    EQUB %11001000
    EQUB %11101100
    EQUB %10011000
    EQUB %11011000
    EQUB %10000000
    EQUB %00000000
}

.sprite_ce
{
    EQUB &00, &0E, 23, 21
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 0 x 0, offset (0, 0)
sprite_cf_width = 0
sprite_cf_height = 0
sprite_cf_plane_size = 0
sprite_cf_reserved_size = 123
.sprite_cf
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_cf_reserved_data SKIP 123

; Sprite &D0: 18 x 6, offset (-8, -2)
sprite_d0_width = 18
sprite_d0_height = 6
sprite_d0_plane_size = 18
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10010001
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000000
    EQUB %10011001
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01111111
    EQUB %01011111
    EQUB %00011001
    EQUB %01101110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %10000000
    EQUB %11101111
    EQUB %11110000
    EQUB %11001100
    EQUB %01100110
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d0
{
    EQUB &F8, &FE, 18, 6
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 18 x 6, offset (-8, -2)
sprite_d1_width = 18
sprite_d1_height = 6
sprite_d1_plane_size = 18
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000111
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00000011
    EQUB %11110111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01111111
    EQUB %01111111
    EQUB %00110111
    EQUB %00111000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %10000000
    EQUB %11101111
    EQUB %11110000
    EQUB %01111000
    EQUB %00001000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d1
{
    EQUB &F8, &FE, 18, 6
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 18 x 6, offset (-8, -2)
sprite_d2_width = 18
sprite_d2_height = 6
sprite_d2_plane_size = 18
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000000
    EQUB %11111001
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00111111
    EQUB %01111111
    EQUB %01011100
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %10000000
    EQUB %11101111
    EQUB %11110000
    EQUB %01111100
    EQUB %00000110
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d2
{
    EQUB &F8, &FE, 18, 6
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 18 x 6, offset (-8, -2)
sprite_d3_width = 18
sprite_d3_height = 6
sprite_d3_plane_size = 18
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000110
    EQUB %10111111
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %11100111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01111111
    EQUB %00111101
    EQUB %01111001
    EQUB %01000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %10000000
    EQUB %11110111
    EQUB %11110000
    EQUB %10110100
    EQUB %00011000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d3
{
    EQUB &F8, &FE, 18, 6
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 0 x 0, offset (0, 0)
sprite_d4_width = 0
sprite_d4_height = 0
sprite_d4_plane_size = 0
sprite_d4_reserved_size = 50
.sprite_d4
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d4_reserved_data SKIP 50

; Sprite &D5: 14 x 10, offset (-7, -2)
sprite_d5_width = 14
sprite_d5_height = 10
sprite_d5_plane_size = 20
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00000010
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10100000
    EQUB %01010000
    EQUB %10101000
    EQUB %01010000
    EQUB %10100000
    EQUB %01010000
    EQUB %10000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &F9, &FE, 14, 10
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 14 x 8, offset (-7, -2)
sprite_d6_width = 14
sprite_d6_height = 8
sprite_d6_plane_size = 16
sprite_d6_reserved_size = 0
.sprite_d6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
}

.sprite_d6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01000000
    EQUB %10100000
    EQUB %01010000
    EQUB %10100000
    EQUB %01010000
    EQUB %10101000
    EQUB %00000000
}

.sprite_d6
{
    EQUB &F9, &FE, 14, 8
    EQUW sprite_d6_mask_data, sprite_d6_sprite_data
}

; Sprite &D7: 17 x 13, offset (-8, -2)
sprite_d7_width = 17
sprite_d7_height = 13
sprite_d7_plane_size = 39
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000111
    EQUB %10111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11001111
    EQUB %10000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000011
    EQUB %11100111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000111
    EQUB %00011110
    EQUB %00111101
    EQUB %00111101
    EQUB %01111110
    EQUB %01111111
    EQUB %00111101
    EQUB %01111000
    EQUB %01000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00110000
    EQUB %00110110
    EQUB %01111110
    EQUB %10111111
    EQUB %11101111
    EQUB %11111111
    EQUB %11111110
    EQUB %00111000
    EQUB %11000000
    EQUB %11110100
    EQUB %00011000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d7
{
    EQUB &F8, &FE, 17, 13
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 8 x 9, offset (6, 13)
sprite_d8_width = 8
sprite_d8_height = 9
sprite_d8_plane_size = 9
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01000001
    EQUB %10011010
    EQUB %00011001
    EQUB %00111100
    EQUB %01111110
    EQUB %01111110
    EQUB %01111110
    EQUB %00111100
    EQUB %00000001
}

.sprite_d8
{
    EQUB &06, &0D, 8, 9
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 8 x 9, offset (-1, 3)
sprite_d9_width = 8
sprite_d9_height = 9
sprite_d9_plane_size = 9
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100111
    EQUB %11000011
    EQUB %11000011
    EQUB %10000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000001
    EQUB %11000011
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011000
    EQUB %00011000
    EQUB %00111100
    EQUB %01111110
    EQUB %01111110
    EQUB %01111110
    EQUB %00111100
    EQUB %00000000
}

.sprite_d9
{
    EQUB &FF, &03, 8, 9
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 0 x 0, offset (0, 0)
sprite_da_width = 0
sprite_da_height = 0
sprite_da_plane_size = 0
sprite_da_reserved_size = 16
.sprite_da
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_da_reserved_data SKIP 16

; Sprite &DB: 28 x 19, offset (-3, 18)
sprite_db_width = 28
sprite_db_height = 19
sprite_db_plane_size = 76
sprite_db_reserved_size = 0
.sprite_db_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    ; Byte column 1, rows top-to-bottom
    EQUB %11110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %01111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
    EQUB %11111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %01111111
    EQUB %00000000
    EQUB %01111111
    EQUB %01000001
    EQUB %01110111
    EQUB %01110111
    EQUB %01110111
    EQUB %10110111
    EQUB %01111111
    EQUB %01111111
    EQUB %01000110
    EQUB %01011010
    EQUB %01000110
    EQUB %01011010
    EQUB %01000111
    EQUB %01111111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000110
    EQUB %00000101
    EQUB %11111000
    EQUB %00000000
    EQUB %11111111
    EQUB %01101011
    EQUB %01101011
    EQUB %01101011
    EQUB %01101011
    EQUB %10011000
    EQUB %11111111
    EQUB %11111111
    EQUB %11010111
    EQUB %11010111
    EQUB %11010111
    EQUB %11010111
    EQUB %00110000
    EQUB %11111111
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %11111110
    EQUB %00000000
    EQUB %11111111
    EQUB %11000100
    EQUB %11101101
    EQUB %11101100
    EQUB %11101101
    EQUB %01000101
    EQUB %11111111
    EQUB %11111111
    EQUB %10001110
    EQUB %10110101
    EQUB %10001100
    EQUB %10110111
    EQUB %10001100
    EQUB %11111111
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11100000
    EQUB %00000000
    EQUB %11100000
    EQUB %01100000
    EQUB %10100000
    EQUB %01100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %00100000
    EQUB %11100000
    EQUB %00100000
    EQUB %10100000
    EQUB %01100000
    EQUB %11100000
    EQUB %00000000
}

.sprite_db
{
    EQUB &FD, &12, 28, 19
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 9 x 10, offset (-1, 1)
sprite_dc_width = 9
sprite_dc_height = 10
sprite_dc_plane_size = 20
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100011
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000001
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_dc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010100
    EQUB %00101010
    EQUB %01010001
    EQUB %00101010
    EQUB %01010001
    EQUB %10101010
    EQUB %11000001
    EQUB %01011001
    EQUB %00010100
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_dc
{
    EQUB &FF, &01, 9, 10
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 5 x 8, offset (1, 7)
sprite_dd_width = 5
sprite_dd_height = 8
sprite_dd_plane_size = 8
sprite_dd_reserved_size = 0
.sprite_dd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
}

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01100000
    EQUB %01010000
    EQUB %01100000
    EQUB %01010000
    EQUB %01100000
    EQUB %01010000
    EQUB %01100000
    EQUB %01010000
}

.sprite_dd
{
    EQUB &01, &07, 5, 8
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
}

; Sprite &DE: 17 x 18, offset (-5, -1)
sprite_de_width = 17
sprite_de_height = 18
sprite_de_plane_size = 54
sprite_de_reserved_size = 0
.sprite_de_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111000
    ; Byte column 1, rows top-to-bottom
    EQUB %01100111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00001111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_de_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000101
    EQUB %00001010
    EQUB %00010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00000010
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00010000
    EQUB %10001000
    EQUB %00010100
    EQUB %10101010
    EQUB %00010100
    EQUB %10001010
    EQUB %01010100
    EQUB %10101010
    EQUB %01000101
    EQUB %10101010
    EQUB %01000101
    EQUB %10001010
    EQUB %01010100
    EQUB %10001010
    EQUB %00010100
    EQUB %00100000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_de
{
    EQUB &FB, &FF, 17, 18
    EQUW sprite_de_mask_data, sprite_de_sprite_data
}

; Sprite &DF: 15 x 15, offset (-4, -1)
sprite_df_width = 15
sprite_df_height = 15
sprite_df_plane_size = 30
sprite_df_reserved_size = 0
.sprite_df_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
}

.sprite_df_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000101
    EQUB %00001010
    EQUB %00010101
    EQUB %00001010
    EQUB %00010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00001010
    EQUB %00000101
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00100000
    EQUB %01010000
    EQUB %10101000
    EQUB %00010000
    EQUB %10001000
    EQUB %01010100
    EQUB %10001000
    EQUB %00010100
    EQUB %10101000
    EQUB %00010000
    EQUB %00000000
    EQUB %01000000
    EQUB %00000000
}

.sprite_df
{
    EQUB &FC, &FF, 15, 15
    EQUW sprite_df_mask_data, sprite_df_sprite_data
}

; Sprite &E0: 11 x 11, offset (-2, -1)
sprite_e0_width = 11
sprite_e0_height = 11
sprite_e0_plane_size = 22
sprite_e0_reserved_size = 0
.sprite_e0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100110
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_e0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010001
    EQUB %00101000
    EQUB %00010101
    EQUB %00101010
    EQUB %01010100
    EQUB %00101010
    EQUB %01010100
    EQUB %00101000
    EQUB %00010101
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %01000000
    EQUB %10000000
    EQUB %01000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_e0
{
    EQUB &FE, &FF, 11, 11
    EQUW sprite_e0_mask_data, sprite_e0_sprite_data
}

; Sprite &E1: 0 x 0, offset (0, 0)
sprite_e1_width = 0
sprite_e1_height = 0
sprite_e1_plane_size = 0
sprite_e1_reserved_size = 0
.sprite_e1
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &E2: 7 x 9, offset (0, -2)
sprite_e2_width = 7
sprite_e2_height = 9
sprite_e2_plane_size = 9
sprite_e2_reserved_size = 0
.sprite_e2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10000011
    EQUB %10000011
    EQUB %00000001
    EQUB %00000001
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %11000111
}

.sprite_e2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00011000
    EQUB %00111000
    EQUB %10110010
    EQUB %10101010
    EQUB %00011000
    EQUB %00111000
    EQUB %00110000
    EQUB %00101000
    EQUB %00000000
}

.sprite_e2
{
    EQUB &00, &FE, 7, 9
    EQUW sprite_e2_mask_data, sprite_e2_sprite_data
}

; Sprite &E3: 5 x 13, offset (1, -2)
sprite_e3_width = 5
sprite_e3_height = 13
sprite_e3_plane_size = 13
sprite_e3_reserved_size = 0
.sprite_e3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
}

.sprite_e3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00110000
    EQUB %01110000
    EQUB %01100000
    EQUB %01010000
    EQUB %00110000
    EQUB %01110000
    EQUB %01100000
    EQUB %01010000
    EQUB %00110000
    EQUB %01110000
    EQUB %01100000
    EQUB %01010000
    EQUB %10001000
}

.sprite_e3
{
    EQUB &01, &FE, 5, 13
    EQUW sprite_e3_mask_data, sprite_e3_sprite_data
}

; Sprite &E4: 20 x 8, offset (-8, -7)
sprite_e4_width = 20
sprite_e4_height = 8
sprite_e4_plane_size = 24
sprite_e4_reserved_size = 0
.sprite_e4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111100
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
}

.sprite_e4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00011011
    EQUB %11011111
    EQUB %11111111
    EQUB %11111101
    EQUB %11111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %01000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
}

.sprite_e4
{
    EQUB &F8, &F9, 20, 8
    EQUW sprite_e4_mask_data, sprite_e4_sprite_data
}

; Index by (sprite ID - sprite_first_id) * 2. Empty/reserved IDs keep their slots.
.sprite_table
{
    EQUW sprite_c8 ; &C8
    EQUW sprite_c9 ; &C9
    EQUW sprite_ca ; &CA
    EQUW sprite_cb ; &CB
    EQUW sprite_cc ; &CC
    EQUW sprite_cd ; &CD
    EQUW sprite_ce ; &CE
    EQUW sprite_cf ; &CF
    EQUW sprite_d0 ; &D0
    EQUW sprite_d1 ; &D1
    EQUW sprite_d2 ; &D2
    EQUW sprite_d3 ; &D3
    EQUW sprite_d4 ; &D4
    EQUW sprite_d5 ; &D5
    EQUW sprite_d6 ; &D6
    EQUW sprite_d7 ; &D7
    EQUW sprite_d8 ; &D8
    EQUW sprite_d9 ; &D9
    EQUW sprite_da ; &DA
    EQUW sprite_db ; &DB
    EQUW sprite_dc ; &DC
    EQUW sprite_dd ; &DD
    EQUW sprite_de ; &DE
    EQUW sprite_df ; &DF
    EQUW sprite_e0 ; &E0
    EQUW sprite_e1 ; &E1
    EQUW sprite_e2 ; &E2
    EQUW sprite_e3 ; &E3
    EQUW sprite_e4 ; &E4
}
.level_sprite_data_end
