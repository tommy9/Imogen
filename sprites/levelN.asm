; Generated from levelN.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 33
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

; Sprite &CC: 24 x 20, offset (0, 14)
sprite_cc_width = 24
sprite_cc_height = 20
sprite_cc_plane_size = 60
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
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

.sprite_cc_sprite_data
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

.sprite_cc
{
    EQUB &00, &0E, 24, 20
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 40 x 30, offset (-19, 26)
sprite_cd_width = 40
sprite_cd_height = 30
sprite_cd_plane_size = 150
sprite_cd_reserved_size = 0
.sprite_cd_mask_data
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
    EQUB %01111011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111000
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
    EQUB %11111101
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
    EQUB %11100000
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11101111
    EQUB %11001111
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000010
    EQUB %11000011
    EQUB %11000011
    EQUB %11000011
    EQUB %11000011
    EQUB %11000011
    EQUB %11000011
    EQUB %11000011
    EQUB %11000011
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
    EQUB %11000011
    EQUB %11100111
    ; Byte column 3, rows top-to-bottom
    EQUB %10111111
    EQUB %10011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10111111
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
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 4, rows top-to-bottom
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
    EQUB %11011110
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00011111
    EQUB %11111111
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000100
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %01111011
    EQUB %00000001
    EQUB %00000100
    EQUB %00000100
    EQUB %00000010
    EQUB %00000001
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
    EQUB %00000010
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111101
    EQUB %00000000
    EQUB %00000010
    EQUB %00000010
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00010000
    EQUB %00110000
    EQUB %00110111
    EQUB %00110110
    EQUB %00100101
    EQUB %00010011
    EQUB %00011000
    EQUB %00010000
    EQUB %00011000
    EQUB %00010000
    EQUB %00011000
    EQUB %00010000
    EQUB %00011000
    EQUB %00010000
    EQUB %00011000
    EQUB %00010000
    EQUB %11011011
    EQUB %11010011
    EQUB %11011011
    EQUB %11010011
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00011000
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
    EQUB %01000000
    EQUB %01100000
    EQUB %01100000
    EQUB %01100000
    EQUB %00100000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01000000
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10111111
    EQUB %00000000
    EQUB %01000000
    EQUB %01000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 4, rows top-to-bottom
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
    EQUB %00100001
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11011110
    EQUB %10000000
    EQUB %00100000
    EQUB %00100000
    EQUB %01000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_cd
{
    EQUB &ED, &1A, 40, 30
    EQUW sprite_cd_mask_data, sprite_cd_sprite_data
}

; Sprite &CE: 7 x 31, offset (0, 25)
sprite_ce_width = 7
sprite_ce_height = 31
sprite_ce_plane_size = 31
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
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
}

.sprite_ce_sprite_data
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
}

.sprite_ce
{
    EQUB &00, &19, 7, 31
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 7 x 6, offset (0, 31)
sprite_cf_width = 7
sprite_cf_height = 6
sprite_cf_plane_size = 6
sprite_cf_reserved_size = 0
.sprite_cf_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %10000011
}

.sprite_cf_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %00000000
}

.sprite_cf
{
    EQUB &00, &1F, 7, 6
    EQUW sprite_cf_mask_data, sprite_cf_sprite_data
}

; Sprite &D0: 0 x 0, offset (0, 0)
sprite_d0_width = 0
sprite_d0_height = 0
sprite_d0_plane_size = 0
sprite_d0_reserved_size = 16
.sprite_d0
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d0_reserved_data SKIP 16

; Sprite &D1: 27 x 17, offset (-28, -2)
sprite_d1_width = 27
sprite_d1_height = 17
sprite_d1_plane_size = 68
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
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
    EQUB %10000100
    EQUB %11000000
    EQUB %11100000
    EQUB %11110001
    ; Byte column 1, rows top-to-bottom
    EQUB %11110000
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
    EQUB %00010010
    EQUB %00111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000000
    EQUB %00000000
    EQUB %00001000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000111
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
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111110
    EQUB %01111110
    EQUB %00111001
    EQUB %00110001
    EQUB %00011000
    EQUB %00001110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00001111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111101
    EQUB %01111101
    EQUB %10111101
    EQUB %00001100
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111111
    EQUB %11110011
    EQUB %11100011
    EQUB %11100111
    EQUB %11110011
    EQUB %11111011
    EQUB %01111000
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
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d1
{
    EQUB &E4, &FE, 27, 17
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 0 x 0, offset (0, 0)
sprite_d2_width = 0
sprite_d2_height = 0
sprite_d2_plane_size = 0
sprite_d2_reserved_size = 71
.sprite_d2
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d2_reserved_data SKIP 71

; Sprite &D3: 0 x 0, offset (0, 0)
sprite_d3_width = 0
sprite_d3_height = 0
sprite_d3_plane_size = 0
sprite_d3_reserved_size = 16
.sprite_d3
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d3_reserved_data SKIP 16

; Sprite &D4: 18 x 17, offset (-11, -6)
sprite_d4_width = 18
sprite_d4_height = 17
sprite_d4_plane_size = 51
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11100100
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100001
    ; Byte column 1, rows top-to-bottom
    EQUB %11100111
    EQUB %11000011
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
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
    EQUB %01111001
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
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00011011
    EQUB %00111111
    EQUB %00101111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001110
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111110
    EQUB %01111111
    EQUB %00111111
    EQUB %00011110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00011000
    EQUB %00110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11101110
    EQUB %10011111
    EQUB %11011111
    EQUB %10001111
    EQUB %01110111
    EQUB %11111111
    EQUB %11111111
    EQUB %10000110
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
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &F5, &FA, 18, 17
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 18 x 18, offset (-9, -7)
sprite_d5_width = 18
sprite_d5_height = 18
sprite_d5_plane_size = 54
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10001100
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100001
    ; Byte column 1, rows top-to-bottom
    EQUB %11100111
    EQUB %11000011
    EQUB %11000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
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
    EQUB %11101111
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
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01110011
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001110
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111110
    EQUB %01111101
    EQUB %00111111
    EQUB %00011110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00011000
    EQUB %00010000
    EQUB %00110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11101110
    EQUB %10011111
    EQUB %11011111
    EQUB %10001111
    EQUB %00000011
    EQUB %00100101
    EQUB %10110111
    EQUB %11010110
    EQUB %00010000
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
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &F7, &F9, 18, 18
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 4 x 7, offset (1, 6)
sprite_d6_width = 4
sprite_d6_height = 7
sprite_d6_plane_size = 7
sprite_d6_reserved_size = 0
.sprite_d6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10111111
    EQUB %10011111
    EQUB %10011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %10011111
}

.sprite_d6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d6
{
    EQUB &01, &06, 4, 7
    EQUW sprite_d6_mask_data, sprite_d6_sprite_data
}

; Sprite &D7: 4 x 6, offset (1, 5)
sprite_d7_width = 4
sprite_d7_height = 6
sprite_d7_plane_size = 6
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10111111
    EQUB %10011111
    EQUB %10011111
    EQUB %00001111
    EQUB %00001111
    EQUB %10011111
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
}

.sprite_d7
{
    EQUB &01, &05, 4, 6
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 3 x 5, offset (1, 4)
sprite_d8_width = 3
sprite_d8_height = 5
sprite_d8_plane_size = 5
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10111111
    EQUB %10111111
    EQUB %00011111
    EQUB %00011111
    EQUB %10111111
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d8
{
    EQUB &01, &04, 3, 5
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 2 x 3, offset (2, 2)
sprite_d9_width = 2
sprite_d9_height = 3
sprite_d9_plane_size = 3
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d9
{
    EQUB &02, &02, 2, 3
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 7 x 6, offset (0, -3)
sprite_da_width = 7
sprite_da_height = 6
sprite_da_plane_size = 6
sprite_da_reserved_size = 0
.sprite_da_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
}

.sprite_da_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10110010
    EQUB %10101010
    EQUB %10011010
    EQUB %10111010
    EQUB %10110010
    EQUB %00101000
}

.sprite_da
{
    EQUB &00, &FD, 7, 6
    EQUW sprite_da_mask_data, sprite_da_sprite_data
}

; Sprite &DB: 6 x 6, offset (-32, -10)
sprite_db_width = 6
sprite_db_height = 6
sprite_db_plane_size = 6
sprite_db_reserved_size = 0
.sprite_db_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100011
    EQUB %11000011
    EQUB %10000111
    EQUB %10001111
    EQUB %00001111
    EQUB %10011111
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011100
    EQUB %00111000
    EQUB %00110000
    EQUB %01100000
    EQUB %00000000
}

.sprite_db
{
    EQUB &E0, &F6, 6, 6
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 7 x 6, offset (-33, -12)
sprite_dc_width = 7
sprite_dc_height = 6
sprite_dc_plane_size = 6
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11001111
    EQUB %10000111
    EQUB %00000001
    EQUB %10000001
    EQUB %11100011
    EQUB %11110111
}

.sprite_dc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00110000
    EQUB %01111000
    EQUB %00011110
    EQUB %00001100
    EQUB %00000000
}

.sprite_dc
{
    EQUB &DF, &F4, 7, 6
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 5 x 7, offset (-31, -12)
sprite_dd_width = 5
sprite_dd_height = 7
sprite_dd_plane_size = 7
sprite_dd_reserved_size = 0
.sprite_dd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11001111
    EQUB %10000111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %10001111
    EQUB %11011111
}

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00110000
    EQUB %01100000
    EQUB %01100000
    EQUB %01111000
    EQUB %00110000
    EQUB %00000000
}

.sprite_dd
{
    EQUB &E1, &F4, 5, 7
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
}

; Sprite &DE: 6 x 6, offset (-32, -12)
sprite_de_width = 6
sprite_de_height = 6
sprite_de_plane_size = 6
sprite_de_reserved_size = 0
.sprite_de_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10111111
    EQUB %00001111
    EQUB %00000011
    EQUB %10000011
    EQUB %11000111
    EQUB %11101111
}

.sprite_de_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01000000
    EQUB %01110000
    EQUB %00111100
    EQUB %00011000
    EQUB %00000000
}

.sprite_de
{
    EQUB &E0, &F4, 6, 6
    EQUW sprite_de_mask_data, sprite_de_sprite_data
}

; Sprite &DF: 12 x 12, offset (-2, 4)
sprite_df_width = 12
sprite_df_height = 12
sprite_df_plane_size = 24
sprite_df_reserved_size = 0
.sprite_df_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111100
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000001
    EQUB %10000011
    EQUB %00000111
    EQUB %00001111
    EQUB %10011111
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_df_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000101
    EQUB %00001110
    EQUB %00011100
    EQUB %00111000
    EQUB %01110000
    EQUB %01100000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_df
{
    EQUB &FE, &04, 12, 12
    EQUW sprite_df_mask_data, sprite_df_sprite_data
}

; Sprite &E0: 11 x 11, offset (4, 14)
sprite_e0_width = 11
sprite_e0_height = 11
sprite_e0_plane_size = 22
sprite_e0_reserved_size = 0
.sprite_e0_mask_data
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
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
}

.sprite_e0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10101000
    EQUB %01010011
    EQUB %10100111
    EQUB %01010111
    EQUB %10100111
    EQUB %01001011
    EQUB %10011100
    EQUB %00111001
    EQUB %01110010
    EQUB %01100101
    EQUB %00001010
    ; Byte column 1, rows top-to-bottom
    EQUB %00100000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00100000
    EQUB %01000000
    EQUB %10100000
    EQUB %01000000
    EQUB %10100000
}

.sprite_e0
{
    EQUB &04, &0E, 11, 11
    EQUW sprite_e0_mask_data, sprite_e0_sprite_data
}

; Sprite &E1: 17 x 21, offset (-1, 14)
sprite_e1_width = 17
sprite_e1_height = 21
sprite_e1_plane_size = 63
sprite_e1_reserved_size = 0
.sprite_e1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111100
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000111
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

.sprite_e1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000110
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01001111
    EQUB %01110000
    EQUB %00111111
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11000000
    EQUB %01000000
    EQUB %11000000
    EQUB %00110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11110100
    EQUB %11111100
    EQUB %11110110
    EQUB %11110110
    EQUB %11111011
    EQUB %11111110
    EQUB %11111001
    EQUB %00000111
    EQUB %11111110
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

.sprite_e1
{
    EQUB &FF, &0E, 17, 21
    EQUW sprite_e1_mask_data, sprite_e1_sprite_data
}

; Sprite &E2: 0 x 0, offset (0, 0)
sprite_e2_width = 0
sprite_e2_height = 0
sprite_e2_plane_size = 0
sprite_e2_reserved_size = 71
.sprite_e2
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_e2_reserved_data SKIP 71

; Sprite &E3: 12 x 10, offset (-2, 4)
sprite_e3_width = 12
sprite_e3_height = 10
sprite_e3_plane_size = 20
sprite_e3_reserved_size = 0
.sprite_e3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11010000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %00111111
    ; Byte column 1, rows top-to-bottom
    EQUB %10001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %10001111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_e3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000010
    EQUB %00101111
    EQUB %01101100
    EQUB %00010000
    EQUB %01000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01110000
    EQUB %11110000
    EQUB %11110000
    EQUB %11110000
    EQUB %01110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_e3
{
    EQUB &FE, &04, 12, 10
    EQUW sprite_e3_mask_data, sprite_e3_sprite_data
}

; Sprite &E4: 2 x 5, offset (10, 0)
sprite_e4_width = 2
sprite_e4_height = 5
sprite_e4_plane_size = 5
sprite_e4_reserved_size = 0
.sprite_e4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
}

.sprite_e4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
}

.sprite_e4
{
    EQUB &0A, &00, 2, 5
    EQUW sprite_e4_mask_data, sprite_e4_sprite_data
}

; Sprite &E5: 0 x 0, offset (0, 0)
sprite_e5_width = 0
sprite_e5_height = 0
sprite_e5_plane_size = 0
sprite_e5_reserved_size = 3
.sprite_e5
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_e5_reserved_data SKIP 3

; Sprite &E6: 14 x 10, offset (-2, 4)
sprite_e6_width = 14
sprite_e6_height = 10
sprite_e6_plane_size = 20
sprite_e6_reserved_size = 0
.sprite_e6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11010000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %00111111
    ; Byte column 1, rows top-to-bottom
    EQUB %10001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %10001111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_e6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000010
    EQUB %00101111
    EQUB %01101100
    EQUB %00010000
    EQUB %01000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %01110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_e6
{
    EQUB &FE, &04, 14, 10
    EQUW sprite_e6_mask_data, sprite_e6_sprite_data
}

; Sprite &E7: 5 x 2, offset (1, 16)
sprite_e7_width = 5
sprite_e7_height = 2
sprite_e7_plane_size = 2
sprite_e7_reserved_size = 0
.sprite_e7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %10001111
}

.sprite_e7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01110000
    EQUB %00000000
}

.sprite_e7
{
    EQUB &01, &10, 5, 2
    EQUW sprite_e7_mask_data, sprite_e7_sprite_data
}

; Sprite &E8: 12 x 12, offset (0, -2)
sprite_e8_width = 12
sprite_e8_height = 12
sprite_e8_plane_size = 24
sprite_e8_reserved_size = 0
.sprite_e8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10011111
    EQUB %00001111
    EQUB %00000111
    EQUB %10000011
    EQUB %11000001
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
}

.sprite_e8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %01110000
    EQUB %00111000
    EQUB %00011100
    EQUB %00001110
    EQUB %00000101
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %00000000
}

.sprite_e8
{
    EQUB &00, &FE, 12, 12
    EQUW sprite_e8_mask_data, sprite_e8_sprite_data
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
}
.level_sprite_data_end
