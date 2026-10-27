; Generated from levelG.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 18
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 17 x 16, offset (-5, -1)
sprite_c8_width = 17
sprite_c8_height = 16
sprite_c8_plane_size = 48
sprite_c8_reserved_size = 0
.mask_data ; first drawable sprite, for the existing renderer test
.sprite_c8_mask_data
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
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %00001111
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
    EQUB %00000001
    EQUB %00000011
    EQUB %00001111
    EQUB %00011111
    ; Byte column 2, rows top-to-bottom
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
    EQUB %11111111
}

.sprite_data ; first drawable sprite, for the existing renderer test
.sprite_c8_sprite_data
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
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000001
    EQUB %00000111
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11110000
    EQUB %11111100
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111011
    EQUB %11111011
    EQUB %11110010
    EQUB %11100110
    EQUB %11001100
    EQUB %11110000
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
    EQUB %00000000
}

.sprite_c8
{
    EQUB &FB, &FF, 17, 16
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 7 x 15, offset (0, 14)
sprite_c9_width = 7
sprite_c9_height = 15
sprite_c9_plane_size = 15
sprite_c9_reserved_size = 0
.sprite_c9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %11000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %01010011
    EQUB %11010011
    EQUB %10110101
}

.sprite_c9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01100000
    EQUB %00001000
    EQUB %00011000
    EQUB %00111000
    EQUB %00110000
    EQUB %00101000
    EQUB %00011000
    EQUB %00011000
    EQUB %00110000
    EQUB %00101000
    EQUB %00011000
    EQUB %00001000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_c9
{
    EQUB &00, &0E, 7, 15
    EQUW sprite_c9_mask_data, sprite_c9_sprite_data
}

; Sprite &CA: 9 x 15, offset (-1, 7)
sprite_ca_width = 9
sprite_ca_height = 15
sprite_ca_plane_size = 30
sprite_ca_reserved_size = 0
.sprite_ca_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10011111
    EQUB %00000111
    EQUB %10000011
    EQUB %10000001
    EQUB %10000000
    EQUB %10000000
    EQUB %10001000
    EQUB %10001000
    EQUB %10001000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000001
    EQUB %10000011
    EQUB %00000111
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
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

.sprite_ca_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %00111000
    EQUB %00001100
    EQUB %00100110
    EQUB %00100110
    EQUB %00100011
    EQUB %00100011
    EQUB %00100011
    EQUB %00100110
    EQUB %00100110
    EQUB %00001100
    EQUB %00111000
    EQUB %01100000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_ca
{
    EQUB &FF, &07, 9, 15
    EQUW sprite_ca_mask_data, sprite_ca_sprite_data
}

; Sprite &CB: 13 x 15, offset (3, 16)
sprite_cb_width = 13
sprite_cb_height = 15
sprite_cb_plane_size = 30
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
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
    EQUB %00000111
    EQUB %00000111
}

.sprite_cb_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01000001
    EQUB %10101100
    EQUB %01000111
    EQUB %10100001
    EQUB %01010100
    EQUB %00000100
    EQUB %01100000
    EQUB %00111111
    EQUB %01100000
    EQUB %00000100
    EQUB %01010100
    EQUB %10100001
    EQUB %01000111
    EQUB %10101100
    EQUB %01000001
    ; Byte column 1, rows top-to-bottom
    EQUB %01010000
    EQUB %00101000
    EQUB %00010000
    EQUB %10001000
    EQUB %11010000
    EQUB %11001000
    EQUB %00000000
    EQUB %11110000
    EQUB %00000000
    EQUB %11001000
    EQUB %11010000
    EQUB %10001000
    EQUB %00010000
    EQUB %00101000
    EQUB %01010000
}

.sprite_cb
{
    EQUB &03, &10, 13, 15
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 11 x 5, offset (0, 2)
sprite_cc_width = 11
sprite_cc_height = 5
sprite_cc_plane_size = 10
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10011111
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00111111
    EQUB %11111111
}

.sprite_cc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %00111111
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_cc
{
    EQUB &00, &02, 11, 5
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 0 x 0, offset (0, 0)
sprite_cd_width = 0
sprite_cd_height = 0
sprite_cd_plane_size = 0
sprite_cd_reserved_size = 36
.sprite_cd
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_cd_reserved_data SKIP 36

; Sprite &CE: 24 x 21, offset (0, 14)
sprite_ce_width = 24
sprite_ce_height = 21
sprite_ce_plane_size = 63
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
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

.sprite_ce_sprite_data
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

.sprite_ce
{
    EQUB &00, &0E, 24, 21
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 0 x 0, offset (0, 0)
sprite_cf_width = 0
sprite_cf_height = 0
sprite_cf_plane_size = 0
sprite_cf_reserved_size = 86
.sprite_cf
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_cf_reserved_data SKIP 86

; Sprite &D0: 6 x 11, offset (8, -2)
sprite_d0_width = 6
sprite_d0_height = 11
sprite_d0_plane_size = 11
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
}

.sprite_d0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01100000
    EQUB %00001000
    EQUB %00011000
    EQUB %00111000
    EQUB %00110000
    EQUB %00101000
    EQUB %00011000
    EQUB %10111000
    EQUB %10110000
    EQUB %00101000
    EQUB %11000100
}

.sprite_d0
{
    EQUB &08, &FE, 6, 11
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 7 x 13, offset (8, -2)
sprite_d1_width = 7
sprite_d1_height = 13
sprite_d1_plane_size = 13
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10110101
    EQUB %11010011
    EQUB %01000001
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00001000
    EQUB %00011000
    EQUB %00111000
    EQUB %00110000
    EQUB %00101000
    EQUB %00011000
    EQUB %10111010
    EQUB %10110000
    EQUB %00101010
    EQUB %11000110
}

.sprite_d1
{
    EQUB &08, &FE, 7, 13
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 7 x 13, offset (9, 7)
sprite_d2_width = 7
sprite_d2_height = 13
sprite_d2_plane_size = 13
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
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
    EQUB %11000001
    EQUB %10100001
    EQUB %11101001
    EQUB %11011011
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10001110
    EQUB %01110000
    EQUB %01100010
    EQUB %01011000
    EQUB %10111100
    EQUB %00011000
    EQUB %11000100
    EQUB %10011100
    EQUB %00011100
    EQUB %00000100
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d2
{
    EQUB &09, &07, 7, 13
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 23 x 23, offset (-8, 3)
sprite_d3_width = 23
sprite_d3_height = 23
sprite_d3_plane_size = 69
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111100
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000001
    EQUB %00000100
    EQUB %10001000
    EQUB %11110000
    EQUB %10010000
    EQUB %00001000
    EQUB %10000000
    EQUB %10000100
    EQUB %11000010
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111100
    EQUB %11111000
    EQUB %11111100
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %10011111
    EQUB %00001111
    EQUB %00001110
    EQUB %00011110
    EQUB %00011110
    EQUB %00100010
    EQUB %01000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %10000100
    EQUB %01001000
    EQUB %00110000
    EQUB %00010000
    EQUB %00111001
    EQUB %00111111
    EQUB %01111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %10000001
    EQUB %01000001
    EQUB %00100001
    EQUB %00010011
    EQUB %00111111
    EQUB %01100111
    EQUB %10000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111110
    EQUB %00111000
    EQUB %01110000
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %01100011
    EQUB %00110011
    EQUB %00110001
    EQUB %00011000
    EQUB %00011100
    EQUB %00001111
    EQUB %00000011
    EQUB %00000000
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00011100
    EQUB %00111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %01111000
    EQUB %00110000
    EQUB %00000011
    EQUB %10000111
    EQUB %11000110
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %01111000
    EQUB %01111000
    EQUB %00111100
    EQUB %00011100
    EQUB %10001100
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00011000
    EQUB %01110000
    EQUB %11110000
    EQUB %11100000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d3
{
    EQUB &F8, &03, 23, 23
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 16 x 21, offset (-7, 21)
sprite_d4_width = 16
sprite_d4_height = 21
sprite_d4_plane_size = 42
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11100000
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
    EQUB %11111000
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %10001111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001110
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01110111
    EQUB %01110111
    EQUB %01111001
    EQUB %01111110
    EQUB %00111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111000
    EQUB %11101000
    EQUB %10111100
    EQUB %11110100
    EQUB %01001100
    EQUB %10011000
    EQUB %11110000
    EQUB %11000010
    EQUB %11101010
    EQUB %10011000
    EQUB %11110000
    EQUB %11100000
    EQUB %00000010
    EQUB %10001010
    EQUB %11011000
    EQUB %11111000
    EQUB %01110000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &F9, &15, 16, 21
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 18 x 21, offset (-7, 21)
sprite_d5_width = 18
sprite_d5_height = 21
sprite_d5_plane_size = 63
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11100000
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
    EQUB %11111000
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000010
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000010
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %10001111
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
    EQUB %01111111
    EQUB %00111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001011
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01110111
    EQUB %01110111
    EQUB %01111001
    EQUB %01111110
    EQUB %00111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11110000
    EQUB %01011000
    EQUB %01011000
    EQUB %11111100
    EQUB %11111100
    EQUB %10111100
    EQUB %11111000
    EQUB %11110000
    EQUB %11000001
    EQUB %11011111
    EQUB %10000001
    EQUB %11110000
    EQUB %11100000
    EQUB %00000010
    EQUB %10001010
    EQUB %11011000
    EQUB %11111000
    EQUB %01110000
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
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &F9, &15, 18, 21
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 16 x 22, offset (-6, 22)
sprite_d6_width = 16
sprite_d6_height = 22
sprite_d6_plane_size = 44
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
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
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
    EQUB %00110011
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %01000111
    EQUB %11111111
}

.sprite_d6_sprite_data
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
    EQUB %00001111
    EQUB %00111110
    EQUB %01111110
    EQUB %01110000
    EQUB %01111110
    EQUB %00110010
    EQUB %00001101
    EQUB %00111111
    EQUB %00011111
    EQUB %00001110
    EQUB %00000111
    EQUB %00000111
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
    EQUB %10000000
    EQUB %00001100
    EQUB %11111000
    EQUB %00001100
    EQUB %11110000
    EQUB %10110000
    EQUB %11110000
    EQUB %11100000
    EQUB %00010110
    EQUB %11011100
    EQUB %10111000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d6
{
    EQUB &FA, &16, 16, 22
    EQUW sprite_d6_mask_data, sprite_d6_sprite_data
}

; Sprite &D7: 26 x 17, offset (-17, -1)
sprite_d7_width = 26
sprite_d7_height = 17
sprite_d7_plane_size = 68
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
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
    EQUB %11111101
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
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
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
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

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB %00000010
    EQUB %00000011
    EQUB %00000001
    EQUB %00000101
    EQUB %00001101
    EQUB %10001001
    EQUB %11000110
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
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01100000
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

.sprite_d7
{
    EQUB &EF, &FF, 26, 17
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 24 x 22, offset (0, 15)
sprite_d8_width = 24
sprite_d8_height = 22
sprite_d8_plane_size = 66
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110000
    EQUB %11000000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
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
    EQUB %00111000
    ; Byte column 2, rows top-to-bottom
    EQUB %00001111
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01101011
    EQUB %01101101
    EQUB %01001001
    EQUB %00001000
    EQUB %00001100
    EQUB %00001100
    EQUB %00001001
    EQUB %00011001
    EQUB %00011001
    EQUB %00111001
    EQUB %00110011
    EQUB %00110011
    EQUB %00110011
    EQUB %00110011
    EQUB %00010011
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00001000
    EQUB %10001000
    EQUB %10001000
    EQUB %10001100
    EQUB %10011100
    EQUB %10011100
    EQUB %10010100
    EQUB %10110110
    EQUB %00100110
    EQUB %00100111
    EQUB %01101111
    EQUB %01001101
    EQUB %11000100
    EQUB %11000100
    EQUB %10000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11110000
    EQUB %11111100
    EQUB %11111100
    EQUB %11111110
    EQUB %11101110
    EQUB %10011110
    EQUB %10001100
    EQUB %10000100
    EQUB %11000100
    EQUB %11100100
    EQUB %01100100
    EQUB %01101100
    EQUB %01101000
    EQUB %01101000
    EQUB %00111000
    EQUB %00011000
    EQUB %10011100
    EQUB %11001100
    EQUB %11001000
    EQUB %11000000
    EQUB %00000000
}

.sprite_d8
{
    EQUB &00, &0F, 24, 22
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 19 x 21, offset (-7, 21)
sprite_d9_width = 19
sprite_d9_height = 21
sprite_d9_plane_size = 63
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11100000
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
    EQUB %11111000
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000010
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %10001111
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
    EQUB %00111111
    EQUB %00011111
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
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001110
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111011
    EQUB %01111100
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111000
    EQUB %11101000
    EQUB %10111100
    EQUB %11110100
    EQUB %00001100
    EQUB %11111000
    EQUB %11110000
    EQUB %11000001
    EQUB %10100111
    EQUB %11011110
    EQUB %11111100
    EQUB %11110000
    EQUB %00000010
    EQUB %10001010
    EQUB %11011000
    EQUB %11111000
    EQUB %01110000
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
    EQUB %00000000
}

.sprite_d9
{
    EQUB &F9, &15, 19, 21
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
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
}
.level_sprite_data_end
