; Generated from levelJ.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 16
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 9 x 8, offset (0, 3)
sprite_c8_width = 9
sprite_c8_height = 8
sprite_c8_plane_size = 16
sprite_c8_reserved_size = 0
.mask_data ; first drawable sprite, for the existing renderer test
.sprite_c8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000001
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_data ; first drawable sprite, for the existing renderer test
.sprite_c8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00010000
    EQUB %00100000
    EQUB %00100000
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
}

.sprite_c8
{
    EQUB &00, &03, 9, 8
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 0 x 0, offset (0, 0)
sprite_c9_width = 0
sprite_c9_height = 0
sprite_c9_plane_size = 0
sprite_c9_reserved_size = 46
.sprite_c9
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_c9_reserved_data SKIP 46

; Sprite &CA: 11 x 11, offset (4, 14)
sprite_ca_width = 11
sprite_ca_height = 11
sprite_ca_plane_size = 22
sprite_ca_reserved_size = 0
.sprite_ca_mask_data
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

.sprite_ca_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10111111
    EQUB %01100000
    EQUB %11000000
    EQUB %10001000
    EQUB %10010000
    EQUB %10010000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01100000
    EQUB %10111111
    ; Byte column 1, rows top-to-bottom
    EQUB %10100000
    EQUB %11000000
    EQUB %01100000
    EQUB %00100000
    EQUB %00100000
    EQUB %00100000
    EQUB %00100000
    EQUB %00100000
    EQUB %01100000
    EQUB %11000000
    EQUB %10100000
}

.sprite_ca
{
    EQUB &04, &0E, 11, 11
    EQUW sprite_ca_mask_data, sprite_ca_sprite_data
}

; Sprite &CB: 13 x 14, offset (-2, 6)
sprite_cb_width = 13
sprite_cb_height = 14
sprite_cb_plane_size = 28
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %10011100
    EQUB %00000100
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11100001
    EQUB %11000011
    EQUB %11101111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %01101111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %11001111
    EQUB %11111111
    EQUB %11111111
}

.sprite_cb_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %01100001
    EQUB %00111011
    EQUB %00011110
    EQUB %00010111
    EQUB %00011111
    EQUB %00101111
    EQUB %01111111
    EQUB %00000101
    EQUB %00001110
    EQUB %00001100
    EQUB %00010000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10010000
    EQUB %10110000
    EQUB %11100000
    EQUB %01100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %00110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_cb
{
    EQUB &FE, &06, 13, 14
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 20 x 22, offset (-3, 0)
sprite_cc_width = 20
sprite_cc_height = 22
sprite_cc_plane_size = 66
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
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

.sprite_cc_sprite_data
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
    EQUB %01110111
    EQUB %01110111
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

.sprite_cc
{
    EQUB &FD, &00, 20, 22
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 20 x 26, offset (-3, 3)
sprite_cd_width = 20
sprite_cd_height = 26
sprite_cd_plane_size = 78
sprite_cd_reserved_size = 0
.sprite_cd_mask_data
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

.sprite_cd_sprite_data
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
    EQUB %01110111
    EQUB %01110111
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

.sprite_cd
{
    EQUB &FD, &03, 20, 26
    EQUW sprite_cd_mask_data, sprite_cd_sprite_data
}

; Sprite &CE: 30 x 22, offset (-3, 0)
sprite_ce_width = 30
sprite_ce_height = 22
sprite_ce_plane_size = 88
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
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
    EQUB %00000011
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %01111111
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
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
    EQUB %11111111
    EQUB %11001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00110111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_ce_sprite_data
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
    EQUB %01110111
    EQUB %01110111
    EQUB %01111011
    EQUB %01111100
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111100
    EQUB %01110000
    EQUB %01110000
    EQUB %01110000
    EQUB %11100000
    EQUB %11100000
    EQUB %00000000
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
    EQUB %00000000
    EQUB %11110000
    EQUB %11111111
    EQUB %01111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB %00110000
    EQUB %11111000
    EQUB %11001000
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

.sprite_ce
{
    EQUB &FD, &00, 30, 22
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 0 x 0, offset (0, 0)
sprite_cf_width = 0
sprite_cf_height = 0
sprite_cf_plane_size = 0
sprite_cf_reserved_size = 146
.sprite_cf
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_cf_reserved_data SKIP 146

; Sprite &D0: 9 x 8, offset (0, 0)
sprite_d0_width = 9
sprite_d0_height = 8
sprite_d0_plane_size = 16
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000001
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00010000
    EQUB %00100000
    EQUB %00100000
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
}

.sprite_d0
{
    EQUB &00, &00, 9, 8
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 12 x 12, offset (8, 0)
sprite_d1_width = 12
sprite_d1_height = 12
sprite_d1_plane_size = 24
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111101
    EQUB %11111100
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
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
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000010
    EQUB %00111111
    EQUB %01001111
    EQUB %11000001
    EQUB %10000000
    EQUB %00010000
    EQUB %00100000
    EQUB %00100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %01100000
    EQUB %01100000
    EQUB %01100000
    EQUB %01100000
    EQUB %11000000
    EQUB %00000000
}

.sprite_d1
{
    EQUB &08, &00, 12, 12
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 9 x 13, offset (0, -1)
sprite_d2_width = 9
sprite_d2_height = 13
sprite_d2_plane_size = 26
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10011111
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
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01100000
    EQUB %01011000
    EQUB %01101110
    EQUB %00111101
    EQUB %00001011
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
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
}

.sprite_d2
{
    EQUB &00, &FF, 9, 13
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 9 x 34, offset (0, -8)
sprite_d3_width = 9
sprite_d3_height = 34
sprite_d3_plane_size = 68
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
{
    ; Byte column 0, rows top-to-bottom
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
}

.sprite_d3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010100
    EQUB %00101010
    EQUB %01010101
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
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB &00, &F8, 9, 34
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 25 x 28, offset (4, -10)
sprite_d4_width = 25
sprite_d4_height = 28
sprite_d4_plane_size = 112
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
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
    EQUB %11111110
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %01000001
    EQUB %00000011
    EQUB %00000111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11111000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %10000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
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
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 3, rows top-to-bottom
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
}

.sprite_d4_sprite_data
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
    EQUB %00000001
    EQUB %00000010
    EQUB %00000101
    EQUB %00001010
    EQUB %00010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %01010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00001010
    EQUB %00010100
    EQUB %10001000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000010
    EQUB %00000101
    EQUB %00001010
    EQUB %00010101
    EQUB %00101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010100
    EQUB %10101000
    EQUB %01010000
    EQUB %10100000
    EQUB %01000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %01010100
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010100
    EQUB %10101000
    EQUB %01010000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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

.sprite_d4
{
    EQUB &04, &F6, 25, 28
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 36 x 13, offset (12, -1)
sprite_d5_width = 36
sprite_d5_height = 13
sprite_d5_plane_size = 65
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111100
    EQUB %11111000
    EQUB %11110000
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
    EQUB %00000001
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
    EQUB %10000000
    ; Byte column 4, rows top-to-bottom
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
    EQUB %00011111
    EQUB %00111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000010
    EQUB %00000101
    EQUB %00010010
    EQUB %00110101
    EQUB %00110000
    EQUB %01100101
    EQUB %01001010
    EQUB %01010101
    EQUB %00001010
    EQUB %00010101
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %00011000
    EQUB %01000101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %00000000
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010100
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
    EQUB %00000000
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %00000000
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %10101010
    EQUB %01010101
    EQUB %00000000
    ; Byte column 4, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10100000
    EQUB %00000000
    EQUB %10100000
    EQUB %00000000
    EQUB %00100000
    EQUB %01000000
    EQUB %10100000
    EQUB %01000000
    EQUB %10100000
    EQUB %01000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &0C, &FF, 36, 13
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 0 x 0, offset (0, 0)
sprite_d6_width = 0
sprite_d6_height = 0
sprite_d6_plane_size = 0
sprite_d6_reserved_size = 116
.sprite_d6
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d6_reserved_data SKIP 116

; Sprite &D7: 0 x 0, offset (0, 0)
sprite_d7_width = 0
sprite_d7_height = 0
sprite_d7_plane_size = 0
sprite_d7_reserved_size = 116
.sprite_d7
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d7_reserved_data SKIP 116

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
}
.level_sprite_data_end
