; Generated from levelL.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 41
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 15 x 9, offset (2, 13)
sprite_c8_width = 15
sprite_c8_height = 9
sprite_c8_plane_size = 18
sprite_c8_reserved_size = 0
.mask_data ; first drawable sprite, for the existing renderer test
.sprite_c8_mask_data
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
    ; Byte column 1, rows top-to-bottom
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

.sprite_data ; first drawable sprite, for the existing renderer test
.sprite_c8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01010100
    EQUB %10101000
    EQUB %01010011
    EQUB %10000100
    EQUB %00011001
    EQUB %00111010
    EQUB %01110001
    EQUB %01100010
    EQUB %00000101
    ; Byte column 1, rows top-to-bottom
    EQUB %00000100
    EQUB %11100010
    EQUB %00011000
    EQUB %00000100
    EQUB %01010100
    EQUB %10100100
    EQUB %01001000
    EQUB %10100010
    EQUB %01010100
}

.sprite_c8
{
    EQUB &02, &0D, 15, 9
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 0 x 0, offset (0, 0)
sprite_c9_width = 0
sprite_c9_height = 0
sprite_c9_plane_size = 0
sprite_c9_reserved_size = 76
.sprite_c9
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_c9_reserved_data SKIP 76

; Sprite &CA: 0 x 0, offset (0, 0)
sprite_ca_width = 0
sprite_ca_height = 0
sprite_ca_plane_size = 0
sprite_ca_reserved_size = 26
.sprite_ca
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_ca_reserved_data SKIP 26

; Sprite &CB: 9 x 10, offset (-2, 7)
sprite_cb_width = 9
sprite_cb_height = 10
sprite_cb_plane_size = 20
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111001
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000001
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %10111111
    ; Byte column 1, rows top-to-bottom
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
}

.sprite_cb_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000110
    EQUB %00101001
    EQUB %01100001
    EQUB %00011110
    EQUB %01000000
    EQUB %01000000
    EQUB %01000000
    EQUB %01000000
    EQUB %00000000
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
}

.sprite_cb
{
    EQUB &FE, &07, 9, 10
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 15 x 9, offset (-2, 4)
sprite_cc_width = 15
sprite_cc_height = 9
sprite_cc_plane_size = 18
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
    EQUB %11000011
    EQUB %10000011
    EQUB %00000111
    EQUB %00001111
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %00011111
    EQUB %00000111
    EQUB %00000011
    EQUB %11100001
    EQUB %11110001
    EQUB %11110001
    EQUB %11100011
    EQUB %11110111
    EQUB %11111111
}

.sprite_cc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00000100
    EQUB %00011000
    EQUB %00111000
    EQUB %01110000
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %00011000
    EQUB %00000100
    EQUB %00000100
    EQUB %00000100
    EQUB %00001000
    EQUB %00000000
    EQUB %00000000
}

.sprite_cc
{
    EQUB &FE, &04, 15, 9
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 16 x 12, offset (-2, 4)
sprite_cd_width = 16
sprite_cd_height = 12
sprite_cd_plane_size = 24
sprite_cd_reserved_size = 0
.sprite_cd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000011
    EQUB %00000111
    EQUB %00001111
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111101
    EQUB %11111000
    EQUB %11111000
    EQUB %11110001
    EQUB %10000001
    EQUB %00000011
    EQUB %00001111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_cd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000111
    EQUB %00011000
    EQUB %00111000
    EQUB %01110000
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000010
    EQUB %00000010
    EQUB %00000100
    EQUB %00001100
    EQUB %01110000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_cd
{
    EQUB &FE, &04, 16, 12
    EQUW sprite_cd_mask_data, sprite_cd_sprite_data
}

; Sprite &CE: 18 x 7, offset (-2, 4)
sprite_ce_width = 18
sprite_ce_height = 7
sprite_ce_plane_size = 21
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000011
    EQUB %00000111
    EQUB %00001111
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %00011111
    EQUB %00000000
    EQUB %00000000
    EQUB %11100000
    EQUB %11111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_ce_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00011000
    EQUB %00111000
    EQUB %01110000
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11100000
    EQUB %00011111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_ce
{
    EQUB &FE, &04, 18, 7
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 10 x 12, offset (-2, 9)
sprite_cf_width = 10
sprite_cf_height = 12
sprite_cf_plane_size = 24
sprite_cf_reserved_size = 0
.sprite_cf_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111001
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000110
    EQUB %00001110
    EQUB %10011110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
}

.sprite_cf_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000110
    EQUB %00011001
    EQUB %00111001
    EQUB %01110000
    EQUB %01100000
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
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
}

.sprite_cf
{
    EQUB &FE, &09, 10, 12
    EQUW sprite_cf_mask_data, sprite_cf_sprite_data
}

; Sprite &D0: 0 x 0, offset (0, 0)
sprite_d0_width = 0
sprite_d0_height = 0
sprite_d0_plane_size = 0
sprite_d0_reserved_size = 0
.sprite_d0
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &D1: 3 x 5, offset (-2, 3)
sprite_d1_width = 3
sprite_d1_height = 5
sprite_d1_plane_size = 5
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11011111
    EQUB %00011111
    EQUB %11011111
    EQUB %11011111
    EQUB %11011111
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d1
{
    EQUB &FE, &03, 3, 5
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 24 x 19, offset (-14, -2)
sprite_d2_width = 24
sprite_d2_height = 19
sprite_d2_plane_size = 57
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000100
    EQUB %10011100
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111000
    EQUB %11111100
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011100
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %10000001
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11111001
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00011110
    EQUB %00111111
    EQUB %00010111
    EQUB %00111111
    EQUB %01111001
    EQUB %01100001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100011
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11010000
    EQUB %01000000
    EQUB %01000000
    EQUB %01000000
    EQUB %01000000
    EQUB %11000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111000
    EQUB %10111000
    EQUB %01111100
    EQUB %01111100
    EQUB %00111000
    EQUB %00011110
    EQUB %00000010
    EQUB %00010010
    EQUB %00110010
    EQUB %00000110
    EQUB %00000000
}

.sprite_d2
{
    EQUB &F2, &FE, 24, 19
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 24 x 23, offset (-14, -2)
sprite_d3_width = 24
sprite_d3_height = 23
sprite_d3_plane_size = 69
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000001
    EQUB %11100111
    EQUB %10111100
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11110000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000111
    EQUB %11011111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00110000
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
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
    EQUB %01111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %10000001
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11111001
}

.sprite_d3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000111
    EQUB %00001111
    EQUB %00000101
    EQUB %00001111
    EQUB %00011110
    EQUB %00011000
    EQUB %00000000
    EQUB %00000000
    EQUB %01000010
    EQUB %01111110
    EQUB %00000001
    EQUB %00000011
    EQUB %00001111
    EQUB %00111000
    EQUB %00100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %01111000
    EQUB %01111000
    EQUB %01111100
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11011111
    EQUB %11001111
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %10111000
    EQUB %01111100
    EQUB %01111100
    EQUB %00111000
    EQUB %00011110
    EQUB %00000010
    EQUB %00010010
    EQUB %00110010
    EQUB %00000110
    EQUB %00000000
}

.sprite_d3
{
    EQUB &F2, &FE, 24, 23
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 26 x 15, offset (-12, -2)
sprite_d4_width = 26
sprite_d4_height = 15
sprite_d4_plane_size = 60
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000100
    EQUB %10011100
    EQUB %11111110
    EQUB %11111100
    EQUB %11110000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111100
    EQUB %11110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011110
    EQUB %00111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %11100111
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
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00011110
    EQUB %00111111
    EQUB %00010111
    EQUB %00111111
    EQUB %01111001
    EQUB %01100001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00001100
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11110000
    EQUB %11111000
    EQUB %00110000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111010
    EQUB %10111011
    EQUB %01111101
    EQUB %01111101
    EQUB %00111100
    EQUB %00001100
    EQUB %00100110
    EQUB %01100110
    EQUB %11001100
    EQUB %00011000
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
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &F4, &FE, 26, 15
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 27 x 14, offset (-13, -2)
sprite_d5_width = 27
sprite_d5_height = 14
sprite_d5_plane_size = 56
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %10000000
    EQUB %00000111
    EQUB %10011111
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %01111100
    EQUB %00110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %11110001
    EQUB %11110000
    EQUB %11111000
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %00011111
    EQUB %00000111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000110
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    ; Byte column 3, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %10111111
    EQUB %11111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    EQUB %00011111
    EQUB %00001011
    EQUB %00011111
    EQUB %00111100
    EQUB %00110000
    EQUB %00000011
    EQUB %00001111
    EQUB %00011000
    EQUB %01100000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000011
    EQUB %00001111
    EQUB %10111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11110100
    EQUB %11111000
    EQUB %01111100
    EQUB %00001100
    EQUB %00000100
    EQUB %00000110
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %11111000
    EQUB %11111101
    EQUB %11111101
    EQUB %01111110
    EQUB %01111110
    EQUB %00111100
    EQUB %00011011
    EQUB %00011001
    EQUB %00110000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000000
    EQUB %01000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &F3, &FE, 27, 14
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 0 x 0, offset (0, 0)
sprite_d6_width = 0
sprite_d6_height = 0
sprite_d6_plane_size = 0
sprite_d6_reserved_size = 13
.sprite_d6
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d6_reserved_data SKIP 13

; Sprite &D7: 6 x 5, offset (8, -9)
sprite_d7_width = 6
sprite_d7_height = 5
sprite_d7_plane_size = 5
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %01100011
    EQUB %01110111
}

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %11110000
    EQUB %00011000
    EQUB %00001000
    EQUB %00000000
}

.sprite_d7
{
    EQUB &08, &F7, 6, 5
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 7 x 5, offset (8, -11)
sprite_d8_width = 7
sprite_d8_height = 5
sprite_d8_plane_size = 5
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000111
    EQUB %10000011
    EQUB %00000001
    EQUB %00011011
    EQUB %00111111
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00111000
    EQUB %01100100
    EQUB %11000000
    EQUB %00000000
}

.sprite_d8
{
    EQUB &08, &F5, 7, 5
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 5 x 6, offset (8, -12)
sprite_d9_width = 5
sprite_d9_height = 6
sprite_d9_plane_size = 6
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11001111
    EQUB %10000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00110000
    EQUB %01100000
    EQUB %01000000
    EQUB %11000000
    EQUB %10000000
}

.sprite_d9
{
    EQUB &08, &F4, 5, 6
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 5 x 6, offset (8, -12)
sprite_da_width = 5
sprite_da_height = 6
sprite_da_plane_size = 6
sprite_da_reserved_size = 0
.sprite_da_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11101111
    EQUB %11000111
    EQUB %11000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
}

.sprite_da_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00010000
    EQUB %00010000
    EQUB %00110000
    EQUB %11100000
    EQUB %10000000
}

.sprite_da
{
    EQUB &08, &F4, 5, 6
    EQUW sprite_da_mask_data, sprite_da_sprite_data
}

; Sprite &DB: 6 x 5, offset (8, -11)
sprite_db_width = 6
sprite_db_height = 5
sprite_db_plane_size = 5
sprite_db_reserved_size = 0
.sprite_db_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110111
    EQUB %11100011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001000
    EQUB %00011000
    EQUB %11110000
    EQUB %00000000
}

.sprite_db
{
    EQUB &08, &F5, 6, 5
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 6 x 5, offset (8, -9)
sprite_dc_width = 6
sprite_dc_height = 5
sprite_dc_plane_size = 5
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000011
    EQUB %01000111
}

.sprite_dc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %01100000
    EQUB %00111000
    EQUB %00000000
}

.sprite_dc
{
    EQUB &08, &F7, 6, 5
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 13 x 11, offset (3, 14)
sprite_dd_width = 13
sprite_dd_height = 11
sprite_dd_plane_size = 22
sprite_dd_reserved_size = 0
.sprite_dd_mask_data
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
    ; Byte column 1, rows top-to-bottom
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

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01010000
    EQUB %10101011
    EQUB %01010010
    EQUB %10000111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111001
    EQUB %00111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00010000
    EQUB %10000000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11001000
    EQUB %10010000
    EQUB %10101000
    EQUB %10010000
    EQUB %11001000
    EQUB %00010000
}

.sprite_dd
{
    EQUB &03, &0E, 13, 11
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
}

; Sprite &DE: 13 x 11, offset (-2, 5)
sprite_de_width = 13
sprite_de_height = 11
sprite_de_plane_size = 22
sprite_de_reserved_size = 0
.sprite_de_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11111000
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000001
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00111111
}

.sprite_de_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000010
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111001
    EQUB %00111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %00000000
}

.sprite_de
{
    EQUB &FE, &05, 13, 11
    EQUW sprite_de_mask_data, sprite_de_sprite_data
}

; Sprite &DF: 13 x 11, offset (-2, 5)
sprite_df_width = 13
sprite_df_height = 11
sprite_df_plane_size = 22
sprite_df_reserved_size = 0
.sprite_df_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11111000
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000001
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00111111
}

.sprite_df_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000010
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111001
    EQUB %00111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11110000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %00000000
}

.sprite_df
{
    EQUB &FE, &05, 13, 11
    EQUW sprite_df_mask_data, sprite_df_sprite_data
}

; Sprite &E0: 23 x 17, offset (-8, 15)
sprite_e0_width = 23
sprite_e0_height = 17
sprite_e0_plane_size = 51
sprite_e0_reserved_size = 0
.sprite_e0_mask_data
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
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
}

.sprite_e0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01111111
    EQUB %00000000
    EQUB %01111111
    EQUB %01000100
    EQUB %01011101
    EQUB %01000100
    EQUB %01110101
    EQUB %01000101
    EQUB %01111111
    EQUB %01110101
    EQUB %01110101
    EQUB %01110001
    EQUB %01110101
    EQUB %01110101
    EQUB %01111111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00111000
    EQUB %11000111
    EQUB %00000000
    EQUB %11111111
    EQUB %01000100
    EQUB %01010111
    EQUB %01000100
    EQUB %11011101
    EQUB %11000100
    EQUB %11111111
    EQUB %00010001
    EQUB %01010101
    EQUB %00010001
    EQUB %01110011
    EQUB %00010101
    EQUB %11111111
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11111100
    EQUB %00000000
    EQUB %11111100
    EQUB %01010100
    EQUB %01010100
    EQUB %01000100
    EQUB %01001100
    EQUB %01010100
    EQUB %11111100
    EQUB %00011100
    EQUB %01011100
    EQUB %00011100
    EQUB %01111100
    EQUB %00011100
    EQUB %11111100
    EQUB %00000000
}

.sprite_e0
{
    EQUB &F8, &0F, 23, 17
    EQUW sprite_e0_mask_data, sprite_e0_sprite_data
}

; Sprite &E1: 19 x 9, offset (-8, 7)
sprite_e1_width = 19
sprite_e1_height = 9
sprite_e1_plane_size = 27
sprite_e1_reserved_size = 0
.sprite_e1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11111100
    EQUB %11111110
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11111111
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00011100
    EQUB %00011100
    EQUB %00111110
    EQUB %00001110
    EQUB %00000010
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_e1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %11101110
    EQUB %01110110
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000001
    EQUB %00000000
    EQUB %10000000
    EQUB %10110000
    EQUB %10111000
    EQUB %11010001
    EQUB %01001101
    EQUB %00011100
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_e1
{
    EQUB &F8, &07, 19, 9
    EQUW sprite_e1_mask_data, sprite_e1_sprite_data
}

; Sprite &E2: 17 x 10, offset (-1, 8)
sprite_e2_width = 17
sprite_e2_height = 10
sprite_e2_plane_size = 30
sprite_e2_reserved_size = 0
.sprite_e2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111100
    EQUB %11110000
    EQUB %00110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_e2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00000110
    EQUB %01001000
    EQUB %01100110
    EQUB %00001110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %00000000
    EQUB %01000000
    EQUB %01010111
    EQUB %11011011
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_e2
{
    EQUB &FF, &08, 17, 10
    EQUW sprite_e2_mask_data, sprite_e2_sprite_data
}

; Sprite &E3: 8 x 4, offset (0, 5)
sprite_e3_width = 8
sprite_e3_height = 4
sprite_e3_plane_size = 4
sprite_e3_reserved_size = 0
.sprite_e3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_e3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %11101110
    EQUB %01110111
    EQUB %00000000
}

.sprite_e3
{
    EQUB &00, &05, 8, 4
    EQUW sprite_e3_mask_data, sprite_e3_sprite_data
}

; Sprite &E4: 5 x 8, offset (2, 7)
sprite_e4_width = 5
sprite_e4_height = 8
sprite_e4_plane_size = 8
sprite_e4_reserved_size = 0
.sprite_e4_mask_data
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

.sprite_e4_sprite_data
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

.sprite_e4
{
    EQUB &02, &07, 5, 8
    EQUW sprite_e4_mask_data, sprite_e4_sprite_data
}

; Sprite &E5: 7 x 8, offset (1, 7)
sprite_e5_width = 7
sprite_e5_height = 8
sprite_e5_plane_size = 8
sprite_e5_reserved_size = 0
.sprite_e5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
}

.sprite_e5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00110000
    EQUB %10101010
    EQUB %10011010
    EQUB %10111010
    EQUB %10001010
    EQUB %01010010
    EQUB %11010010
    EQUB %10110100
}

.sprite_e5
{
    EQUB &01, &07, 7, 8
    EQUW sprite_e5_mask_data, sprite_e5_sprite_data
}

; Sprite &E6: 7 x 39, offset (1, 33)
sprite_e6_width = 7
sprite_e6_height = 39
sprite_e6_plane_size = 39
sprite_e6_reserved_size = 0
.sprite_e6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01111101
    EQUB %01111101
    EQUB %01111101
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
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
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %10000001
    EQUB %10000001
    EQUB %00000001
    EQUB %00000001
}

.sprite_e6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01000100
    EQUB %01111100
    EQUB %00000000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010000
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %00010100
    EQUB %00101000
    EQUB %01010100
}

.sprite_e6
{
    EQUB &01, &21, 7, 39
    EQUW sprite_e6_mask_data, sprite_e6_sprite_data
}

; Sprite &E7: 7 x 6, offset (1, 39)
sprite_e7_width = 7
sprite_e7_height = 6
sprite_e7_plane_size = 6
sprite_e7_reserved_size = 0
.sprite_e7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %10000011
}

.sprite_e7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %00000000
}

.sprite_e7
{
    EQUB &01, &27, 7, 6
    EQUW sprite_e7_mask_data, sprite_e7_sprite_data
}

; Sprite &E8: 0 x 0, offset (0, 0)
sprite_e8_width = 0
sprite_e8_height = 0
sprite_e8_plane_size = 0
sprite_e8_reserved_size = 0
.sprite_e8
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &E9: 0 x 0, offset (0, 0)
sprite_e9_width = 0
sprite_e9_height = 0
sprite_e9_plane_size = 0
sprite_e9_reserved_size = 0
.sprite_e9
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &EA: 14 x 22, offset (-1, -2)
sprite_ea_width = 14
sprite_ea_height = 22
sprite_ea_plane_size = 44
sprite_ea_reserved_size = 0
.sprite_ea_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
}

.sprite_ea_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00001111
    EQUB %00001011
    EQUB %00011110
    EQUB %00010111
    EQUB %00011001
    EQUB %00001100
    EQUB %00010111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01101111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00000001
    EQUB %00011100
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %10111000
    EQUB %01110000
    EQUB %11100000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %00000000
}

.sprite_ea
{
    EQUB &FF, &FE, 14, 22
    EQUW sprite_ea_mask_data, sprite_ea_sprite_data
}

; Sprite &EB: 0 x 0, offset (0, 0)
sprite_eb_width = 0
sprite_eb_height = 0
sprite_eb_plane_size = 0
sprite_eb_reserved_size = 0
.sprite_eb
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &EC: 13 x 6, offset (-4, -8)
sprite_ec_width = 13
sprite_ec_height = 6
sprite_ec_plane_size = 12
sprite_ec_reserved_size = 0
.sprite_ec_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10011111
    EQUB %00000111
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
}

.sprite_ec_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %01111001
    EQUB %00011111
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11110000
    EQUB %11110000
    EQUB %11000000
    EQUB %00000000
}

.sprite_ec
{
    EQUB &FC, &F8, 13, 6
    EQUW sprite_ec_mask_data, sprite_ec_sprite_data
}

; Sprite &ED: 11 x 9, offset (-4, -9)
sprite_ed_width = 11
sprite_ed_height = 9
sprite_ed_plane_size = 18
sprite_ed_reserved_size = 0
.sprite_ed_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10011111
    EQUB %00001111
    EQUB %00001111
    EQUB %10000111
    EQUB %10000001
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00011111
    EQUB %00111111
}

.sprite_ed_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %01100000
    EQUB %00110000
    EQUB %00111000
    EQUB %00011110
    EQUB %00001111
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %00000000
}

.sprite_ed
{
    EQUB &FC, &F7, 11, 9
    EQUW sprite_ed_mask_data, sprite_ed_sprite_data
}

; Sprite &EE: 12 x 6, offset (-3, -6)
sprite_ee_width = 12
sprite_ee_height = 6
sprite_ee_plane_size = 12
sprite_ee_reserved_size = 0
.sprite_ee_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111101
    EQUB %11110000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000011
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %00001111
    EQUB %00011111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_ee_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %01111100
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_ee
{
    EQUB &FD, &FA, 12, 6
    EQUW sprite_ee_mask_data, sprite_ee_sprite_data
}

; Sprite &EF: 16 x 15, offset (-9, 0)
sprite_ef_width = 16
sprite_ef_height = 15
sprite_ef_plane_size = 30
sprite_ef_reserved_size = 0
.sprite_ef_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000011
    EQUB %00000011
    EQUB %00010111
    EQUB %00011111
    EQUB %10111111
    ; Byte column 1, rows top-to-bottom
    EQUB %10001111
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000011
    EQUB %11000011
    EQUB %11100111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_ef_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011100
    EQUB %00110000
    EQUB %01101000
    EQUB %01000000
    EQUB %01000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01110000
    EQUB %01011110
    EQUB %11111110
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %01101100
    EQUB %00110000
    EQUB %00011000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_ef
{
    EQUB &F7, &00, 16, 15
    EQUW sprite_ef_mask_data, sprite_ef_sprite_data
}

; Sprite &F0: 19 x 10, offset (-12, -1)
sprite_f0_width = 19
sprite_f0_height = 10
sprite_f0_plane_size = 30
sprite_f0_reserved_size = 0
.sprite_f0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %10001111
    EQUB %00000011
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11110001
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00010000
    EQUB %11111000
    EQUB %11111100
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_f0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %01110000
    EQUB %00011100
    EQUB %01101111
    EQUB %00010111
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00001011
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11101110
    EQUB %00000110
    EQUB %00000011
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_f0
{
    EQUB &F4, &FF, 19, 10
    EQUW sprite_f0_mask_data, sprite_f0_sprite_data
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
    EQUW sprite_e5 ; &E5
    EQUW sprite_e6 ; &E6
    EQUW sprite_e7 ; &E7
    EQUW sprite_e8 ; &E8
    EQUW sprite_e9 ; &E9
    EQUW sprite_ea ; &EA
    EQUW sprite_eb ; &EB
    EQUW sprite_ec ; &EC
    EQUW sprite_ed ; &ED
    EQUW sprite_ee ; &EE
    EQUW sprite_ef ; &EF
    EQUW sprite_f0 ; &F0
}
.level_sprite_data_end
