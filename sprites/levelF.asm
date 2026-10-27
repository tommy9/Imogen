; Generated from levelF.txt by tools/convert_sprites.py. Do not edit.
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
    EQUB %10101101
    EQUB %00101110
    EQUB %01100000
    EQUB %01000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_c8
{
    EQUB &FD, &07, 19, 9
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 17 x 10, offset (-8, 8)
sprite_c9_width = 17
sprite_c9_height = 10
sprite_c9_plane_size = 30
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
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000110
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11111110
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
}

.sprite_c9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000000
    EQUB %00000001
    EQUB %11101101
    EQUB %01110101
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01100000
    EQUB %01110000
    EQUB %10100001
    EQUB %10011011
    EQUB %00111000
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
}

.sprite_c9
{
    EQUB &F8, &08, 17, 10
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
    EQUB %11101110
    EQUB %01110111
    EQUB %00000000
}

.sprite_ca
{
    EQUB &00, &05, 8, 4
    EQUW sprite_ca_mask_data, sprite_ca_sprite_data
}

; Sprite &CB: 5 x 4, offset (1, 3)
sprite_cb_width = 5
sprite_cb_height = 4
sprite_cb_plane_size = 4
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
{
    ; Byte column 0, rows top-to-bottom
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
}

.sprite_cb
{
    EQUB &01, &03, 5, 4
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 5 x 8, offset (1, 7)
sprite_cc_width = 5
sprite_cc_height = 8
sprite_cc_plane_size = 8
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
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

.sprite_cc_sprite_data
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

.sprite_cc
{
    EQUB &01, &07, 5, 8
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

; Sprite &CE: 7 x 48, offset (0, 39)
sprite_ce_width = 7
sprite_ce_height = 48
sprite_ce_plane_size = 48
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10000011
    EQUB %10000011
    EQUB %10000011
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
    EQUB %10000011
}

.sprite_ce_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00110000
    EQUB %00101000
    EQUB %00011000
    EQUB %00111000
    EQUB %00110000
    EQUB %00101000
    EQUB %01000100
    EQUB %01111100
    EQUB %00000000
    EQUB %01111100
    EQUB %01110100
    EQUB %01110100
    EQUB %01010100
    EQUB %01010100
    EQUB %01011100
    EQUB %01011100
    EQUB %01011100
    EQUB %01101100
    EQUB %01101100
    EQUB %01101100
    EQUB %01101100
    EQUB %01101100
    EQUB %01011100
    EQUB %01010100
    EQUB %01011100
    EQUB %01011100
    EQUB %01010100
    EQUB %01110100
    EQUB %01110100
    EQUB %01010100
    EQUB %01010100
    EQUB %01011100
    EQUB %01011100
    EQUB %01011100
    EQUB %01010100
    EQUB %01110100
    EQUB %01110100
    EQUB %01010100
    EQUB %01110100
    EQUB %01101100
    EQUB %01101100
    EQUB %01101100
    EQUB %01101100
    EQUB %01101100
    EQUB %01111100
    EQUB %01110100
    EQUB %01111100
    EQUB %00000000
}

.sprite_ce
{
    EQUB &00, &27, 7, 48
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

; Sprite &D0: 24 x 20, offset (0, 14)
sprite_d0_width = 24
sprite_d0_height = 20
sprite_d0_plane_size = 60
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111000
    EQUB %11111110
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
    ; Byte column 2, rows top-to-bottom
    EQUB %01111111
    EQUB %00011111
    EQUB %00000111
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
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00011111
    EQUB %01111111
}

.sprite_d0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
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
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
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
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111011
    EQUB %11101101
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11111000
    EQUB %11110100
    EQUB %11111100
    EQUB %11111010
    EQUB %11111010
    EQUB %11111100
    EQUB %11111010
    EQUB %11111100
    EQUB %11111010
    EQUB %11110100
    EQUB %11111010
    EQUB %11101100
    EQUB %11110100
    EQUB %11011000
    EQUB %01100000
    EQUB %10000000
    EQUB %00000000
}

.sprite_d0
{
    EQUB &00, &0E, 24, 20
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 0 x 0, offset (0, 0)
sprite_d1_width = 0
sprite_d1_height = 0
sprite_d1_plane_size = 0
sprite_d1_reserved_size = 116
.sprite_d1
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d1_reserved_data SKIP 116

; Sprite &D2: 23 x 17, offset (-12, 0)
sprite_d2_width = 23
sprite_d2_height = 17
sprite_d2_plane_size = 51
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000001
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00100000
    EQUB %11100000
    EQUB %11110000
    EQUB %01100001
    EQUB %11110011
    ; Byte column 2, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %10001111
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00001111
    EQUB %00111111
    EQUB %01111110
    EQUB %01100000
    EQUB %00101100
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000110
    EQUB %00011101
    EQUB %11111101
    EQUB %11111101
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11011111
    EQUB %11000011
    EQUB %00001101
    EQUB %00000110
    EQUB %00000110
    EQUB %00001100
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %00000000
    EQUB %11110000
    EQUB %01010000
    EQUB %11111000
    EQUB %10111100
    EQUB %11001100
    EQUB %01111000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %01110000
    EQUB %00010000
    EQUB %01110000
    EQUB %00000000
}

.sprite_d2
{
    EQUB &F4, &00, 23, 17
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 25 x 18, offset (-13, 0)
sprite_d3_width = 25
sprite_d3_height = 18
sprite_d3_plane_size = 72
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000011
    EQUB %00000110
    EQUB %00000010
    EQUB %10000111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111110
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
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
    EQUB %00000110
    EQUB %00000100
    EQUB %00000000
    EQUB %00000100
    ; Byte column 2, rows top-to-bottom
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00011000
    EQUB %00011000
    EQUB %00011100
    EQUB %00111111
    EQUB %01111111
    ; Byte column 3, rows top-to-bottom
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00110000
    EQUB %01111000
    EQUB %01100000
    EQUB %01111000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000110
    EQUB %00011110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11101011
    EQUB %11110011
    EQUB %11111011
    EQUB %01111001
    EQUB %01110000
    EQUB %11100000
    EQUB %11111011
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %00000000
    EQUB %11111000
    EQUB %10101000
    EQUB %11111100
    EQUB %01011110
    EQUB %01100110
    EQUB %10111100
    EQUB %10000000
    EQUB %10110000
    EQUB %01111110
    EQUB %10000111
    EQUB %11000001
    EQUB %11000011
    EQUB %11000000
    EQUB %10000000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d3
{
    EQUB &F3, &00, 25, 18
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 23 x 17, offset (-12, 0)
sprite_d4_width = 23
sprite_d4_height = 17
sprite_d4_plane_size = 51
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00010000
    EQUB %01111000
    EQUB %11111000
    EQUB %01111100
    EQUB %11111110
    ; Byte column 2, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00101111
    EQUB %01110111
    EQUB %01101111
    EQUB %00101100
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000110
    EQUB %00011101
    EQUB %11111101
    EQUB %11111101
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11110111
    EQUB %10100011
    EQUB %10000100
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %00000000
    EQUB %11110000
    EQUB %01010000
    EQUB %11111000
    EQUB %10111100
    EQUB %11001100
    EQUB %01111000
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11110000
    EQUB %00010000
    EQUB %00110000
    EQUB %11000000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &F4, &00, 23, 17
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 24 x 18, offset (-13, 0)
sprite_d5_width = 24
sprite_d5_height = 18
sprite_d5_plane_size = 54
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000010
    EQUB %00000011
    EQUB %10000111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111110
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00001000
    EQUB %00001000
    EQUB %00001100
    EQUB %00000100
    EQUB %00000000
    EQUB %10000100
    ; Byte column 2, rows top-to-bottom
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00011111
    EQUB %00000111
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00110000
    EQUB %00111001
    EQUB %01111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00111110
    EQUB %01111100
    EQUB %01100000
    EQUB %01111000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000110
    EQUB %00011110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11110111
    EQUB %11100001
    EQUB %00000010
    EQUB %11100001
    EQUB %11100000
    EQUB %01111011
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %00000000
    EQUB %11111000
    EQUB %10101000
    EQUB %11111100
    EQUB %01011110
    EQUB %01100110
    EQUB %10111100
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11111000
    EQUB %00111110
    EQUB %10000010
    EQUB %10000110
    EQUB %10000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &F3, &00, 24, 18
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 22 x 18, offset (-11, 0)
sprite_d6_width = 22
sprite_d6_height = 18
sprite_d6_plane_size = 54
sprite_d6_reserved_size = 0
.sprite_d6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111100
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
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
    EQUB %11110001
    ; Byte column 2, rows top-to-bottom
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %11111111
}

.sprite_d6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
    EQUB %00011111
    EQUB %00001111
    EQUB %00001110
    EQUB %00011100
    EQUB %00011111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00001100
    EQUB %00011011
    EQUB %01111010
    EQUB %11111011
    EQUB %11111101
    EQUB %11111101
    EQUB %11111110
    EQUB %11111110
    EQUB %11101110
    EQUB %11001110
    EQUB %00101110
    EQUB %01100111
    EQUB %11000011
    EQUB %11110011
    EQUB %00001110
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %11100000
    EQUB %10100000
    EQUB %11110000
    EQUB %01111000
    EQUB %10011000
    EQUB %11110000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %01100000
    EQUB %00100000
    EQUB %01100000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d6
{
    EQUB &F5, &00, 22, 18
    EQUW sprite_d6_mask_data, sprite_d6_sprite_data
}

; Sprite &D7: 20 x 22, offset (-7, 2)
sprite_d7_width = 20
sprite_d7_height = 22
sprite_d7_plane_size = 66
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11110011
    EQUB %11100001
    EQUB %11000001
    EQUB %11000011
    EQUB %11000111
    EQUB %11101111
    EQUB %11001111
    EQUB %10000111
    EQUB %00000111
    EQUB %00000111
    EQUB %10000011
    EQUB %11000001
    EQUB %11000001
    EQUB %10000010
    EQUB %10000100
    EQUB %11001000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11100001
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
    EQUB %00000100
    EQUB %00000100
    EQUB %00000110
    EQUB %00001110
    EQUB %00001000
    EQUB %00010000
    EQUB %01110000
    EQUB %11111000
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00001100
    EQUB %00011100
    EQUB %00011000
    EQUB %00010000
    EQUB %00000000
    EQUB %00000000
    EQUB %00110000
    EQUB %01110000
    EQUB %01110000
    EQUB %00111000
    EQUB %00011100
    EQUB %00011100
    EQUB %00111000
    EQUB %00110001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00011110
    EQUB %00110000
    EQUB %00101111
    EQUB %01101010
    EQUB %01101111
    EQUB %01110101
    EQUB %01110110
    EQUB %01111011
    EQUB %01111100
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111011
    EQUB %01110001
    EQUB %01110001
    EQUB %01110000
    EQUB %11100000
    EQUB %11100001
    EQUB %00000101
    EQUB %00000111
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d7
{
    EQUB &F9, &02, 20, 22
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 20 x 26, offset (-7, 5)
sprite_d8_width = 20
sprite_d8_height = 26
sprite_d8_plane_size = 78
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110011
    EQUB %11100001
    EQUB %11000001
    EQUB %11000011
    EQUB %11000111
    EQUB %11101111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11101111
    EQUB %11000111
    EQUB %10000111
    EQUB %00000111
    EQUB %00000111
    EQUB %10000111
    EQUB %10000011
    EQUB %11000001
    EQUB %11000001
    EQUB %10000010
    EQUB %10000100
    EQUB %11001000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11100001
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
    EQUB %00000100
    EQUB %00001110
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00001000
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
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
    EQUB %00001100
    EQUB %00011100
    EQUB %00011000
    EQUB %00010000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00010000
    EQUB %00110000
    EQUB %01110000
    EQUB %01110000
    EQUB %00110000
    EQUB %00111000
    EQUB %00011100
    EQUB %00011100
    EQUB %00111000
    EQUB %00110001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00011110
    EQUB %00110000
    EQUB %00101111
    EQUB %01101010
    EQUB %01101111
    EQUB %01110101
    EQUB %01110110
    EQUB %01111011
    EQUB %01111100
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111011
    EQUB %01110000
    EQUB %01100000
    EQUB %01110001
    EQUB %01110101
    EQUB %01110111
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
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
    EQUB &F9, &05, 20, 26
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 22 x 20, offset (-11, 0)
sprite_d9_width = 22
sprite_d9_height = 20
sprite_d9_plane_size = 60
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000010
    EQUB %10000011
    EQUB %11000111
    ; Byte column 1, rows top-to-bottom
    EQUB %11100001
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
    EQUB %00001110
    EQUB %00001100
    EQUB %00011110
    EQUB %00001111
    EQUB %00011111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
    EQUB %00011110
    EQUB %00111110
    EQUB %01111101
    EQUB %01110000
    EQUB %00111000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00011110
    EQUB %00110000
    EQUB %00101111
    EQUB %01101010
    EQUB %11101111
    EQUB %11110101
    EQUB %11110110
    EQUB %11111011
    EQUB %11111100
    EQUB %11111100
    EQUB %11011111
    EQUB %11001111
    EQUB %10000001
    EQUB %01100000
    EQUB %11100001
    EQUB %11000000
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
    EQUB %11110000
    EQUB %00111000
    EQUB %10001000
    EQUB %11011000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d9
{
    EQUB &F5, &00, 22, 20
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 8 x 11, offset (-3, 6)
sprite_da_width = 8
sprite_da_height = 11
sprite_da_plane_size = 11
sprite_da_reserved_size = 0
.sprite_da_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110011
    EQUB %11100001
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000001
    EQUB %10000001
    EQUB %00000011
    EQUB %00000111
    EQUB %10001111
}

.sprite_da_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001100
    EQUB %00001110
    EQUB %00001110
    EQUB %00001110
    EQUB %00011110
    EQUB %00011100
    EQUB %00111100
    EQUB %01111000
    EQUB %01110000
    EQUB %00000000
}

.sprite_da
{
    EQUB &FD, &06, 8, 11
    EQUW sprite_da_mask_data, sprite_da_sprite_data
}

; Sprite &DB: 8 x 11, offset (6, 14)
sprite_db_width = 8
sprite_db_height = 11
sprite_db_plane_size = 11
sprite_db_reserved_size = 0
.sprite_db_mask_data
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
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10100000
    EQUB %01001100
    EQUB %10101110
    EQUB %01001110
    EQUB %10001110
    EQUB %01011110
    EQUB %10011100
    EQUB %00111101
    EQUB %01111000
    EQUB %01110001
    EQUB %00000010
}

.sprite_db
{
    EQUB &06, &0E, 8, 11
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 22 x 28, offset (-10, 27)
sprite_dc_width = 22
sprite_dc_height = 28
sprite_dc_plane_size = 84
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11101100
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %10111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_dc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00001011
    EQUB %00010110
    EQUB %00110110
    EQUB %01101110
    EQUB %01101110
    EQUB %01101110
    EQUB %01101110
    EQUB %01101111
    EQUB %01110111
    EQUB %00110111
    EQUB %00010011
    EQUB %00100101
    EQUB %01110100
    EQUB %01101101
    EQUB %01101110
    EQUB %01101110
    EQUB %01101111
    EQUB %01110111
    EQUB %00110111
    EQUB %00010011
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01000000
    EQUB %01000000
    EQUB %00000000
    EQUB %00100000
    EQUB %10110100
    EQUB %01010110
    EQUB %11011011
    EQUB %11011011
    EQUB %11011011
    EQUB %11101011
    EQUB %11101011
    EQUB %11110011
    EQUB %01110111
    EQUB %00110111
    EQUB %10001111
    EQUB %11011110
    EQUB %11011101
    EQUB %00100001
    EQUB %11101011
    EQUB %11101011
    EQUB %11110111
    EQUB %01111011
    EQUB %00111011
    EQUB %10000110
    EQUB %11011100
    EQUB %11000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %01000000
    EQUB %01100000
    EQUB %10110000
    EQUB %10110000
    EQUB %10110000
    EQUB %10110000
    EQUB %10110000
    EQUB %01110000
    EQUB %01100000
    EQUB %01010000
    EQUB %10111000
    EQUB %10111000
    EQUB %10111000
    EQUB %10111000
    EQUB %10110000
    EQUB %01110000
    EQUB %01100000
    EQUB %01000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_dc
{
    EQUB &F6, &1B, 22, 28
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 14 x 7, offset (-6, 0)
sprite_dd_width = 14
sprite_dd_height = 7
sprite_dd_plane_size = 14
sprite_dd_reserved_size = 0
.sprite_dd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %10001111
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %11100111
    EQUB %10000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %01111111
}

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %01110000
    EQUB %01111111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00011000
    EQUB %01111000
    EQUB %11110000
    EQUB %11100000
    EQUB %10000000
    EQUB %00000000
}

.sprite_dd
{
    EQUB &FA, &00, 14, 7
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
}

; Sprite &DE: 22 x 20, offset (-11, 0)
sprite_de_width = 22
sprite_de_height = 20
sprite_de_plane_size = 60
sprite_de_reserved_size = 0
.sprite_de_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %11100001
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
    EQUB %00001000
    EQUB %00001100
    EQUB %00000000
    EQUB %00001100
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %01000011
    EQUB %00100111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_de_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
    EQUB %00011111
    EQUB %00001111
    EQUB %00001110
    EQUB %00011100
    EQUB %00011111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00011110
    EQUB %00110000
    EQUB %00101111
    EQUB %01101010
    EQUB %11101111
    EQUB %11110111
    EQUB %11110111
    EQUB %11111011
    EQUB %11111100
    EQUB %11111101
    EQUB %11111110
    EQUB %11101110
    EQUB %11000111
    EQUB %00100111
    EQUB %01100011
    EQUB %11000001
    EQUB %11110011
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11110000
    EQUB %01111000
    EQUB %00001000
    EQUB %00011000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_de
{
    EQUB &F5, &00, 22, 20
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
