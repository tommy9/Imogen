; Generated from levelA.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 23
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 24 x 20, offset (-16, 0)
sprite_c8_width = 24
sprite_c8_height = 20
sprite_c8_plane_size = 60
sprite_c8_reserved_size = 0
.mask_data ; first drawable sprite, for the existing renderer test
.sprite_c8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10011100
    EQUB %00000000
    EQUB %10000000
    EQUB %11000001
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111000
    EQUB %11110000
    EQUB %11110000
    EQUB %11111000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01110000
    EQUB %11111100
    ; Byte column 2, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
}

.sprite_data ; first drawable sprite, for the existing renderer test
.sprite_c8_sprite_data
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01100011
    EQUB %00111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000110
    EQUB %00000111
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00001110
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %11111111
    EQUB %10001111
    EQUB %00000011
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11010000
    EQUB %01110000
    EQUB %11111000
    EQUB %11111000
    EQUB %01111100
    EQUB %10001100
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %10110000
    EQUB %10000110
    EQUB %11110000
    EQUB %00000000
}

.sprite_c8
{
    EQUB &F0, &00, 24, 20
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 8 x 5, offset (0, -5)
sprite_c9_width = 8
sprite_c9_height = 5
sprite_c9_plane_size = 5
sprite_c9_reserved_size = 0
.sprite_c9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111001
    EQUB %10011000
    EQUB %00001000
    EQUB %00001101
    EQUB %11011111
}

.sprite_c9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000110
    EQUB %11100010
    EQUB %00100000
    EQUB %00000000
}

.sprite_c9
{
    EQUB &00, &FB, 8, 5
    EQUW sprite_c9_mask_data, sprite_c9_sprite_data
}

; Sprite &CA: 9 x 6, offset (0, -6)
sprite_ca_width = 9
sprite_ca_height = 6
sprite_ca_plane_size = 12
sprite_ca_reserved_size = 0
.sprite_ca_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11101110
    EQUB %11000100
    EQUB %00000000
    EQUB %00000000
    EQUB %00011001
    EQUB %10111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_ca_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010001
    EQUB %00110011
    EQUB %11100110
    EQUB %11000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_ca
{
    EQUB &00, &FA, 9, 6
    EQUW sprite_ca_mask_data, sprite_ca_sprite_data
}

; Sprite &CB: 14 x 13, offset (-7, 0)
sprite_cb_width = 14
sprite_cb_height = 13
sprite_cb_plane_size = 26
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11100000
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
    EQUB %01111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %01111111
}

.sprite_cb_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
}

.sprite_cb
{
    EQUB &F9, &00, 14, 13
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 0 x 0, offset (0, 0)
sprite_cc_width = 0
sprite_cc_height = 0
sprite_cc_plane_size = 0
sprite_cc_reserved_size = 136
.sprite_cc
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_cc_reserved_data SKIP 136

; Sprite &CD: 0 x 0, offset (0, 0)
sprite_cd_width = 0
sprite_cd_height = 0
sprite_cd_plane_size = 0
sprite_cd_reserved_size = 16
.sprite_cd
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_cd_reserved_data SKIP 16

; Sprite &CE: 0 x 0, offset (0, 0)
sprite_ce_width = 0
sprite_ce_height = 0
sprite_ce_plane_size = 0
sprite_ce_reserved_size = 16
.sprite_ce
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_ce_reserved_data SKIP 16

; Sprite &CF: 24 x 10, offset (-1, 3)
sprite_cf_width = 24
sprite_cf_height = 10
sprite_cf_plane_size = 30
sprite_cf_reserved_size = 0
.sprite_cf_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
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
    ; Byte column 2, rows top-to-bottom
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
}

.sprite_cf_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01111111
    EQUB %01111111
    EQUB %01111000
    EQUB %01100111
    EQUB %01111111
    EQUB %00000010
    EQUB %01111101
    EQUB %01111111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11111111
    EQUB %11000011
    EQUB %11111100
    EQUB %00011111
    EQUB %11111101
    EQUB %00000010
    EQUB %11111111
    EQUB %10111111
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11111110
    EQUB %11000110
    EQUB %01111110
    EQUB %11100110
    EQUB %11111110
    EQUB %00000000
    EQUB %11011110
    EQUB %11111110
    EQUB %00000000
}

.sprite_cf
{
    EQUB &FF, &03, 24, 10
    EQUW sprite_cf_mask_data, sprite_cf_sprite_data
}

; Sprite &D0: 20 x 23, offset (0, 17)
sprite_d0_width = 20
sprite_d0_height = 23
sprite_d0_plane_size = 69
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11101111
    EQUB %11000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111110
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
}

.sprite_d0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010000
    EQUB %00110100
    EQUB %10110110
    EQUB %00100111
    EQUB %10110101
    EQUB %00101010
    EQUB %00011101
    EQUB %00011110
    EQUB %00001110
    EQUB %00000111
    EQUB %00000011
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
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %01000000
    EQUB %10100000
    EQUB %10100000
    EQUB %01010000
    EQUB %10110100
    EQUB %11011010
    EQUB %11100110
    EQUB %01110111
    EQUB %01111011
    EQUB %00111101
    EQUB %00011110
    EQUB %00001110
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
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
    EQUB %11000000
    EQUB %01100000
    EQUB %10100000
    EQUB %01100000
    EQUB %10100000
    EQUB %11000000
    EQUB %11100000
    EQUB %11000000
    EQUB %00000000
}

.sprite_d0
{
    EQUB &00, &11, 20, 23
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 6 x 28, offset (0, 23)
sprite_d1_width = 6
sprite_d1_height = 28
sprite_d1_plane_size = 28
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %11000111
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00111000
    EQUB %10111000
    EQUB %00111000
    EQUB %10110000
    EQUB %00111000
    EQUB %00000000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00110000
    EQUB %00111000
    EQUB %00111000
    EQUB %00011000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00110000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00111000
    EQUB %00000000
}

.sprite_d1
{
    EQUB &00, &17, 6, 28
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 10 x 15, offset (-1, 7)
sprite_d2_width = 10
sprite_d2_height = 15
sprite_d2_plane_size = 30
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100011
    EQUB %11000001
    EQUB %11100000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100001
    EQUB %11000001
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %10000111
    EQUB %11001111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011100
    EQUB %00000110
    EQUB %00000110
    EQUB %00001110
    EQUB %00001100
    EQUB %00011100
    EQUB %00011000
    EQUB %00111011
    EQUB %00110111
    EQUB %01111111
    EQUB %01111100
    EQUB %01111000
    EQUB %00110000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d2
{
    EQUB &FF, &07, 10, 15
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 10 x 15, offset (5, 16)
sprite_d3_width = 10
sprite_d3_height = 15
sprite_d3_plane_size = 30
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
}

.sprite_d3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01000001
    EQUB %10011100
    EQUB %01000110
    EQUB %10100110
    EQUB %01001110
    EQUB %10001100
    EQUB %01011100
    EQUB %10011000
    EQUB %00111011
    EQUB %00110111
    EQUB %01111111
    EQUB %01111100
    EQUB %01111000
    EQUB %00110010
    EQUB %00000101
    ; Byte column 1, rows top-to-bottom
    EQUB %01000000
    EQUB %10000000
    EQUB %01000000
    EQUB %10000000
    EQUB %01000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %01000000
}

.sprite_d3
{
    EQUB &05, &10, 10, 15
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 9 x 5, offset (-1, -5)
sprite_d4_width = 9
sprite_d4_height = 5
sprite_d4_plane_size = 10
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11011100
    EQUB %10001100
    EQUB %00001110
    EQUB %11011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %01100001
    EQUB %00100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &FF, &FB, 9, 5
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 9 x 5, offset (0, -6)
sprite_d5_width = 9
sprite_d5_height = 5
sprite_d5_plane_size = 10
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11001000
    EQUB %00000000
    EQUB %00001001
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00110110
    EQUB %11100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &00, &FA, 9, 5
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 18 x 21, offset (-9, 0)
sprite_d6_width = 18
sprite_d6_height = 21
sprite_d6_plane_size = 63
sprite_d6_reserved_size = 0
.sprite_d6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100001
    EQUB %11110011
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011100
    EQUB %00001000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %10000011
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
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111101
    EQUB %01110111
    EQUB %00111010
    EQUB %00011100
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011011
    EQUB %00011001
    EQUB %00001110
    EQUB %00000010
    EQUB %00011001
    EQUB %00011101
    EQUB %00011000
    EQUB %00001100
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000000
    EQUB %11100000
    EQUB %10100000
    EQUB %01100000
    EQUB %11000000
    EQUB %10100011
    EQUB %11110110
    EQUB %11111010
    EQUB %11111100
    EQUB %11111100
    EQUB %11101100
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %01100000
    EQUB %01111100
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
    EQUB %10000000
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
}

.sprite_d6
{
    EQUB &F7, &00, 18, 21
    EQUW sprite_d6_mask_data, sprite_d6_sprite_data
}

; Sprite &D7: 19 x 22, offset (-9, 0)
sprite_d7_width = 19
sprite_d7_height = 22
sprite_d7_plane_size = 66
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000100
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00001000
    EQUB %00111100
    EQUB %00011111
    EQUB %00111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
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
    EQUB %11111111
    EQUB %10111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111101
    EQUB %01110111
    EQUB %00111010
    EQUB %00011100
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011100
    EQUB %00011111
    EQUB %00001100
    EQUB %00000011
    EQUB %00000111
    EQUB %00000011
    EQUB %00000111
    EQUB %00001110
    EQUB %00000111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000000
    EQUB %11100000
    EQUB %10100000
    EQUB %01100000
    EQUB %11000000
    EQUB %10100000
    EQUB %11110000
    EQUB %11111011
    EQUB %01111101
    EQUB %10111100
    EQUB %10101100
    EQUB %01111100
    EQUB %11111010
    EQUB %11110111
    EQUB %00000011
    EQUB %00000000
    EQUB %11000000
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
    EQUB %01000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d7
{
    EQUB &F7, &00, 19, 22
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 18 x 21, offset (-9, 0)
sprite_d8_width = 18
sprite_d8_height = 21
sprite_d8_plane_size = 63
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100001
    EQUB %11110011
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011100
    EQUB %00001000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %10000011
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
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111101
    EQUB %01110111
    EQUB %00111010
    EQUB %00011100
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011011
    EQUB %00011001
    EQUB %00001110
    EQUB %00000010
    EQUB %00011001
    EQUB %00011111
    EQUB %00011000
    EQUB %00001100
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000000
    EQUB %11100000
    EQUB %10100000
    EQUB %01100000
    EQUB %11000000
    EQUB %10100011
    EQUB %11110110
    EQUB %11111010
    EQUB %11111100
    EQUB %11111100
    EQUB %11101100
    EQUB %11111100
    EQUB %11111000
    EQUB %01110000
    EQUB %00000000
    EQUB %01111100
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
    EQUB %10000000
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
}

.sprite_d8
{
    EQUB &F7, &00, 18, 21
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 19 x 22, offset (-9, 0)
sprite_d9_width = 19
sprite_d9_height = 22
sprite_d9_plane_size = 66
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11010000
    EQUB %11110000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001100
    EQUB %00001000
    EQUB %00010000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00001000
    EQUB %00111100
    EQUB %00011111
    EQUB %00111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111101
    EQUB %01110111
    EQUB %00111010
    EQUB %00011100
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011011
    EQUB %00010111
    EQUB %01010111
    EQUB %01110111
    EQUB %00100011
    EQUB %00000100
    EQUB %00000111
    EQUB %00001110
    EQUB %00000111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000000
    EQUB %11100000
    EQUB %10100000
    EQUB %01100011
    EQUB %11000110
    EQUB %10101100
    EQUB %11110100
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11101100
    EQUB %11111100
    EQUB %11111110
    EQUB %11110111
    EQUB %00000011
    EQUB %00000000
    EQUB %11000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
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
    EQUB %00000000
    EQUB %01000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d9
{
    EQUB &F7, &00, 19, 22
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 17 x 22, offset (-9, 0)
sprite_da_width = 17
sprite_da_height = 22
sprite_da_plane_size = 66
sprite_da_reserved_size = 0
.sprite_da_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00001001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001111
    EQUB %01111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
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
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_da_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111010
    EQUB %01111010
    EQUB %01111111
    EQUB %01111111
    EQUB %00111101
    EQUB %00011111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011100
    EQUB %00011111
    EQUB %00001100
    EQUB %00000011
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001110
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10100000
    EQUB %11110110
    EQUB %11111011
    EQUB %01111101
    EQUB %10111100
    EQUB %10101100
    EQUB %01111100
    EQUB %11111000
    EQUB %11110000
    EQUB %00000000
    EQUB %01110000
    EQUB %10000000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_da
{
    EQUB &F7, &00, 17, 22
    EQUW sprite_da_mask_data, sprite_da_sprite_data
}

; Sprite &DB: 23 x 22, offset (-13, 0)
sprite_db_width = 23
sprite_db_height = 22
sprite_db_plane_size = 66
sprite_db_reserved_size = 0
.sprite_db_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %11110000
    EQUB %11110000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11001110
    EQUB %10000100
    EQUB %00000000
    EQUB %10000000
    EQUB %11110000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00011111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB %00000000
    EQUB %00000111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11100011
    EQUB %11000001
    EQUB %10000011
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000110
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00110000
    EQUB %01111011
    EQUB %00001111
    EQUB %00000111
    EQUB %00000110
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %11111000
    EQUB %11111100
    EQUB %10101100
    EQUB %11111110
    EQUB %11111010
    EQUB %00000110
    EQUB %11111100
    EQUB %01111010
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01110000
    EQUB %11100111
    EQUB %11111000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00011100
    EQUB %00110000
    EQUB %01100000
    EQUB %01100000
    EQUB %10100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_db
{
    EQUB &F3, &00, 23, 22
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 26 x 14, offset (-17, 1)
sprite_dc_width = 26
sprite_dc_height = 14
sprite_dc_plane_size = 56
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
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
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111001
    EQUB %11110000
    EQUB %01100000
    EQUB %00100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01000000
    EQUB %11100000
    EQUB %11110000
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000110
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00011001
    EQUB %11111111
    ; Byte column 3, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_dc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000111
    EQUB %00011111
    EQUB %00110011
    EQUB %00111111
    EQUB %01110011
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000110
    EQUB %00001100
    EQUB %10001011
    EQUB %11000111
    EQUB %01101111
    EQUB %00111110
    EQUB %01011101
    EQUB %00111101
    EQUB %11111101
    EQUB %10111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11100000
    EQUB %01110000
    EQUB %11111001
    EQUB %01111011
    EQUB %10111010
    EQUB %01111101
    EQUB %01111111
    EQUB %10111111
    EQUB %10100110
    EQUB %00000000
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
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
}

.sprite_dc
{
    EQUB &EF, &01, 26, 14
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 17 x 22, offset (-9, 0)
sprite_dd_width = 17
sprite_dd_height = 22
sprite_dd_plane_size = 66
sprite_dd_reserved_size = 0
.sprite_dd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11010000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001111
    EQUB %01111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
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
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111010
    EQUB %01111111
    EQUB %01111111
    EQUB %00111010
    EQUB %00011100
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011011
    EQUB %00010111
    EQUB %01010111
    EQUB %01110111
    EQUB %00101111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001110
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %01100000
    EQUB %11000000
    EQUB %10100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111101
    EQUB %11111101
    EQUB %11101100
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %00000000
    EQUB %01110000
    EQUB %10000000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_dd
{
    EQUB &F7, &00, 17, 22
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
}

; Sprite &DE: 24 x 21, offset (0, 14)
sprite_de_width = 24
sprite_de_height = 21
sprite_de_plane_size = 63
sprite_de_reserved_size = 0
.sprite_de_mask_data
{
    ; Byte column 0, rows top-to-bottom
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
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000001
    EQUB %11000011
    EQUB %11000011
    EQUB %11100111
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
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %00000001
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
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %10000011
    EQUB %11000011
    EQUB %11000011
    EQUB %11100111
}

.sprite_de_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01111111
    EQUB %01110001
    EQUB %01111111
    EQUB %01100011
    EQUB %01111111
    EQUB %00001000
    EQUB %01110111
    EQUB %01111101
    EQUB %00000000
    EQUB %00010000
    EQUB %00011000
    EQUB %00010010
    EQUB %00011010
    EQUB %00010010
    EQUB %00011010
    EQUB %00010010
    EQUB %00011000
    EQUB %00010000
    EQUB %00011000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11111111
    EQUB %11110000
    EQUB %00111111
    EQUB %11000110
    EQUB %11111111
    EQUB %00000000
    EQUB %11111110
    EQUB %11011111
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
    EQUB %00000000
    EQUB %11111110
    EQUB %11111110
    EQUB %11001110
    EQUB %00111010
    EQUB %11111110
    EQUB %00100000
    EQUB %11011110
    EQUB %11111110
    EQUB %00000000
    EQUB %00010000
    EQUB %00011000
    EQUB %01010000
    EQUB %01011000
    EQUB %01010000
    EQUB %01011000
    EQUB %01010000
    EQUB %00011000
    EQUB %00010000
    EQUB %00011000
    EQUB %00000000
}

.sprite_de
{
    EQUB &00, &0E, 24, 21
    EQUW sprite_de_mask_data, sprite_de_sprite_data
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
}
.level_sprite_data_end
