; Generated from levelE.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 24
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 21 x 21, offset (-11, 0)
sprite_c8_width = 21
sprite_c8_height = 21
sprite_c8_plane_size = 63
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
    EQUB %11111101
    EQUB %11011000
    EQUB %10000001
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111100
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11100000
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
    EQUB %10000111
    ; Byte column 2, rows top-to-bottom
    EQUB %01111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
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
    EQUB %00000010
    EQUB %00100100
    EQUB %00010100
    EQUB %00010110
    EQUB %01001011
    EQUB %00110111
    EQUB %00001101
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000110
    EQUB %00000111
    EQUB %00011110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %01110111
    EQUB %00101100
    EQUB %00100010
    EQUB %00100111
    EQUB %01111000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11010000
    EQUB %01110000
    EQUB %11100000
    EQUB %11110000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_c8
{
    EQUB &F5, &00, 21, 21
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 21 x 21, offset (-11, 0)
sprite_c9_width = 21
sprite_c9_height = 21
sprite_c9_plane_size = 63
sprite_c9_reserved_size = 0
.sprite_c9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111101
    EQUB %11011000
    EQUB %10000001
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111100
    EQUB %11111000
    EQUB %11111000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %11111100
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00011111
    EQUB %00111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %01111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00000111
    EQUB %00001111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_c9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000010
    EQUB %00100100
    EQUB %00010100
    EQUB %00010110
    EQUB %01001011
    EQUB %00110111
    EQUB %00001101
    EQUB %00000001
    EQUB %00000000
    EQUB %00000010
    EQUB %00000011
    EQUB %00000100
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000110
    EQUB %00000111
    EQUB %00011110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10111100
    EQUB %01000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11010000
    EQUB %01110000
    EQUB %11100000
    EQUB %11110000
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
    EQUB %00000000
}

.sprite_c9
{
    EQUB &F5, &00, 21, 21
    EQUW sprite_c9_mask_data, sprite_c9_sprite_data
}

; Sprite &CA: 20 x 21, offset (-11, 0)
sprite_ca_width = 20
sprite_ca_height = 21
sprite_ca_plane_size = 63
sprite_ca_reserved_size = 0
.sprite_ca_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111101
    EQUB %11011000
    EQUB %10000001
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111100
    EQUB %11111000
    EQUB %11111000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000011
    EQUB %00011111
    EQUB %00111111
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
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
    EQUB %11111111
}

.sprite_ca_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000010
    EQUB %00100100
    EQUB %00010100
    EQUB %00010110
    EQUB %01001011
    EQUB %00110111
    EQUB %00001101
    EQUB %00000001
    EQUB %00000000
    EQUB %00000010
    EQUB %00000011
    EQUB %00000100
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00101111
    EQUB %00111011
    EQUB %00011111
    EQUB %00111101
    EQUB %00000011
    EQUB %00011101
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10111100
    EQUB %01000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
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
    EQUB %00000000
}

.sprite_ca
{
    EQUB &F5, &00, 20, 21
    EQUW sprite_ca_mask_data, sprite_ca_sprite_data
}

; Sprite &CB: 0 x 0, offset (0, 0)
sprite_cb_width = 0
sprite_cb_height = 0
sprite_cb_plane_size = 0
sprite_cb_reserved_size = 0
.sprite_cb
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &CC: 19 x 20, offset (-9, 0)
sprite_cc_width = 19
sprite_cc_height = 20
sprite_cc_plane_size = 60
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11101111
    EQUB %10000011
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11111110
    EQUB %11111100
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %11110001
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000001
    EQUB %00000011
    EQUB %00011111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00011111
    EQUB %00111111
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

.sprite_cc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00010000
    EQUB %01011100
    EQUB %00101111
    EQUB %01011111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111110
    EQUB %01111011
    EQUB %00111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111100
    EQUB %11100000
    EQUB %11011100
    EQUB %11100000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
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

.sprite_cc
{
    EQUB &F7, &00, 19, 20
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 18 x 18, offset (-9, 0)
sprite_cd_width = 18
sprite_cd_height = 18
sprite_cd_plane_size = 54
sprite_cd_reserved_size = 0
.sprite_cd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11101110
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %11000011
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
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
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
    EQUB %00010001
    EQUB %00111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00111100
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111101
    EQUB %11110111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111000
    EQUB %11101110
    EQUB %11110000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
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

.sprite_cd
{
    EQUB &F7, &00, 18, 18
    EQUW sprite_cd_mask_data, sprite_cd_sprite_data
}

; Sprite &CE: 7 x 5, offset (-5, -9)
sprite_ce_width = 7
sprite_ce_height = 5
sprite_ce_plane_size = 5
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10001111
    EQUB %00000111
    EQUB %10000011
    EQUB %11000001
    EQUB %11000011
}

.sprite_ce_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01110000
    EQUB %00111000
    EQUB %00011100
    EQUB %00011100
}

.sprite_ce
{
    EQUB &FB, &F7, 7, 5
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 7 x 4, offset (-5, -8)
sprite_cf_width = 7
sprite_cf_height = 4
sprite_cf_plane_size = 4
sprite_cf_reserved_size = 0
.sprite_cf_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000011
    EQUB %10000001
    EQUB %00000011
    EQUB %10000111
}

.sprite_cf_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00111100
    EQUB %01111000
    EQUB %00000000
}

.sprite_cf
{
    EQUB &FB, &F8, 7, 4
    EQUW sprite_cf_mask_data, sprite_cf_sprite_data
}

; Sprite &D0: 7 x 6, offset (-5, -6)
sprite_d0_width = 7
sprite_d0_height = 6
sprite_d0_plane_size = 6
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111001
    EQUB %11100001
    EQUB %11000001
    EQUB %10000001
    EQUB %00000011
    EQUB %10001111
}

.sprite_d0_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000110
    EQUB %00011110
    EQUB %00111100
    EQUB %01110000
    EQUB %00000000
}

.sprite_d0
{
    EQUB &FB, &FA, 7, 6
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 11 x 11, offset (4, 14)
sprite_d1_width = 11
sprite_d1_height = 11
sprite_d1_plane_size = 22
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
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

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10100000
    EQUB %00001110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111101
    EQUB %00111111
    EQUB %10011011
    EQUB %01011100
    EQUB %10000000
    ; Byte column 1, rows top-to-bottom
    EQUB %10100000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %01000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000000
    EQUB %00000000
    EQUB %10100000
}

.sprite_d1
{
    EQUB &04, &0E, 11, 11
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 9 x 10, offset (-1, 5)
sprite_d2_width = 9
sprite_d2_height = 10
sprite_d2_plane_size = 20
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100011
    EQUB %11000001
    EQUB %10000000
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
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d2_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011100
    EQUB %00111110
    EQUB %00111110
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
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

.sprite_d2
{
    EQUB &FF, &05, 9, 10
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 9 x 10, offset (5, 14)
sprite_d3_width = 9
sprite_d3_height = 10
sprite_d3_plane_size = 20
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
    ; Byte column 1, rows top-to-bottom
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
    EQUB %10000000
    EQUB %00011100
    EQUB %10111110
    EQUB %00111110
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
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
}

.sprite_d3
{
    EQUB &05, &0E, 9, 10
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 24 x 14, offset (0, 7)
sprite_d4_width = 24
sprite_d4_height = 14
sprite_d4_plane_size = 42
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111100
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
    ; Byte column 2, rows top-to-bottom
    EQUB %00011111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00111111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00111000
    EQUB %01010000
    EQUB %01011100
    EQUB %00110111
    EQUB %01001010
    EQUB %00110001
    EQUB %00100111
    EQUB %00011100
    EQUB %00000001
    EQUB %00001110
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11111111
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11011110
    EQUB %01100011
    EQUB %00011110
    EQUB %11100000
    EQUB %00011111
    EQUB %11110001
    EQUB %00001100
    EQUB %11110111
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %00011100
    EQUB %00001010
    EQUB %00111100
    EQUB %11101010
    EQUB %10100110
    EQUB %00011100
    EQUB %11110000
    EQUB %00001000
    EQUB %11101000
    EQUB %00110000
    EQUB %11000000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &00, &07, 24, 14
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 0 x 0, offset (0, 0)
sprite_d5_width = 0
sprite_d5_height = 0
sprite_d5_plane_size = 0
sprite_d5_reserved_size = 0
.sprite_d5
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &D6: 0 x 0, offset (0, 0)
sprite_d6_width = 0
sprite_d6_height = 0
sprite_d6_plane_size = 0
sprite_d6_reserved_size = 26
.sprite_d6
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_d6_reserved_data SKIP 26

; Sprite &D7: 11 x 8, offset (-5, 3)
sprite_d7_width = 11
sprite_d7_height = 8
sprite_d7_plane_size = 16
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
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
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00111110
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d7
{
    EQUB &FB, &03, 11, 8
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 9 x 10, offset (-3, 4)
sprite_d8_width = 9
sprite_d8_height = 10
sprite_d8_plane_size = 20
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000001
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %11000001
    EQUB %11100011
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00111110
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
    EQUB %00111110
    EQUB %00011100
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

.sprite_d8
{
    EQUB &FD, &04, 9, 10
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 11 x 8, offset (-5, 3)
sprite_d9_width = 11
sprite_d9_height = 8
sprite_d9_plane_size = 16
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
}

.sprite_d9
{
    EQUB &FB, &03, 11, 8
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 9 x 10, offset (-3, 4)
sprite_da_width = 9
sprite_da_height = 10
sprite_da_plane_size = 20
sprite_da_reserved_size = 0
.sprite_da_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100011
    EQUB %11000001
    EQUB %10000000
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
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_da_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011100
    EQUB %00111110
    EQUB %00111110
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111110
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

.sprite_da
{
    EQUB &FD, &04, 9, 10
    EQUW sprite_da_mask_data, sprite_da_sprite_data
}

; Sprite &DB: 14 x 16, offset (-3, 14)
sprite_db_width = 14
sprite_db_height = 16
sprite_db_plane_size = 32
sprite_db_reserved_size = 0
.sprite_db_mask_data
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11101000
    EQUB %11101000
    EQUB %11001000
    EQUB %11011000
    EQUB %00110000
    EQUB %11100000
    EQUB %00000000
}

.sprite_db
{
    EQUB &FD, &0E, 14, 16
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 15 x 15, offset (-5, 14)
sprite_dc_width = 15
sprite_dc_height = 15
sprite_dc_plane_size = 30
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100001
    EQUB %11000000
    EQUB %10000000
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
    EQUB %11110000
    EQUB %11111000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000011
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00011111
}

.sprite_dc_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %11110100
    EQUB %11110100
    EQUB %11100100
    EQUB %11001100
    EQUB %10111000
    EQUB %11100000
    EQUB %00000000
}

.sprite_dc
{
    EQUB &FB, &0E, 15, 15
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 18 x 12, offset (-1, 6)
sprite_dd_width = 18
sprite_dd_height = 12
sprite_dd_plane_size = 36
sprite_dd_reserved_size = 0
.sprite_dd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11110000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11110000
    EQUB %11111110
    ; Byte column 1, rows top-to-bottom
    EQUB %00000011
    EQUB %00000000
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
    ; Byte column 2, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00001111
    EQUB %00000001
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11111100
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111110
    EQUB %11111100
    EQUB %11111001
    EQUB %11100111
    EQUB %11111100
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_dd
{
    EQUB &FF, &06, 18, 12
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
}

; Sprite &DE: 0 x 0, offset (0, 0)
sprite_de_width = 0
sprite_de_height = 0
sprite_de_plane_size = 0
sprite_de_reserved_size = 56
.sprite_de
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_de_reserved_data SKIP 56

; Sprite &DF: 0 x 0, offset (0, 0)
sprite_df_width = 0
sprite_df_height = 0
sprite_df_plane_size = 0
sprite_df_reserved_size = 11
.sprite_df
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_df_reserved_data SKIP 11

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
}
.level_sprite_data_end
