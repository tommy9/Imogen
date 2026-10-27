; Generated from levelP.txt by tools/convert_sprites.py. Do not edit.
; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.
; Rows within each byte column are TOP-TO-BOTTOM, as in test.6502.
; Draw bottom-to-top by reading each column from height-1 down to zero.
; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.
; Composite: screen = (screen AND mask) OR pixels.
; Last byte column is padded with transparent pixels to a multiple of eight.
; Include ONE level file at the caller's chosen ORG; no animation data is inferred.

sprite_first_id = &C8
sprite_count = 22
sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer

.level_sprite_data_start
; Sprite &C8: 11 x 11, offset (-1, 5)
sprite_c8_width = 11
sprite_c8_height = 11
sprite_c8_plane_size = 22
sprite_c8_reserved_size = 0
.mask_data ; first drawable sprite, for the existing renderer test
.sprite_c8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00001110
    EQUB %00001110
    EQUB %00001110
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
}

.sprite_data ; first drawable sprite, for the existing renderer test
.sprite_c8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00011111
    EQUB %00111111
    EQUB %01110001
    EQUB %01100000
    EQUB %01100000
    EQUB %01100000
    EQUB %01110001
    EQUB %00111111
    EQUB %00011111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_c8
{
    EQUB &FF, &05, 11, 11
    EQUW sprite_c8_mask_data, sprite_c8_sprite_data
}

; Sprite &C9: 11 x 11, offset (4, 14)
sprite_c9_width = 11
sprite_c9_height = 11
sprite_c9_plane_size = 22
sprite_c9_reserved_size = 0
.sprite_c9_mask_data
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

.sprite_c9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %10000000
    EQUB %00011111
    EQUB %00111111
    EQUB %01110001
    EQUB %01100000
    EQUB %01100000
    EQUB %01100000
    EQUB %01110001
    EQUB %00111111
    EQUB %00011111
    EQUB %10000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00100000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00100000
}

.sprite_c9
{
    EQUB &04, &0E, 11, 11
    EQUW sprite_c9_mask_data, sprite_c9_sprite_data
}

; Sprite &CA: 0 x 0, offset (0, 0)
sprite_ca_width = 0
sprite_ca_height = 0
sprite_ca_plane_size = 0
sprite_ca_reserved_size = 36
.sprite_ca
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}
; Legacy scratch capacity only; new screen backups need runtime dimensions.
.sprite_ca_reserved_data SKIP 36

; Sprite &CB: 19 x 9, offset (-3, 7)
sprite_cb_width = 19
sprite_cb_height = 9
sprite_cb_plane_size = 27
sprite_cb_reserved_size = 0
.sprite_cb_mask_data
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

.sprite_cb_sprite_data
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

.sprite_cb
{
    EQUB &FD, &07, 19, 9
    EQUW sprite_cb_mask_data, sprite_cb_sprite_data
}

; Sprite &CC: 18 x 9, offset (-8, 7)
sprite_cc_width = 18
sprite_cc_height = 9
sprite_cc_plane_size = 27
sprite_cc_reserved_size = 0
.sprite_cc_mask_data
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

.sprite_cc_sprite_data
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

.sprite_cc
{
    EQUB &F8, &07, 18, 9
    EQUW sprite_cc_mask_data, sprite_cc_sprite_data
}

; Sprite &CD: 8 x 4, offset (0, 5)
sprite_cd_width = 8
sprite_cd_height = 4
sprite_cd_plane_size = 4
sprite_cd_reserved_size = 0
.sprite_cd_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_cd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01110111
    EQUB %11101110
    EQUB %00000000
}

.sprite_cd
{
    EQUB &00, &05, 8, 4
    EQUW sprite_cd_mask_data, sprite_cd_sprite_data
}

; Sprite &CE: 5 x 8, offset (1, 7)
sprite_ce_width = 5
sprite_ce_height = 8
sprite_ce_plane_size = 8
sprite_ce_reserved_size = 0
.sprite_ce_mask_data
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

.sprite_ce_sprite_data
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

.sprite_ce
{
    EQUB &01, &07, 5, 8
    EQUW sprite_ce_mask_data, sprite_ce_sprite_data
}

; Sprite &CF: 16 x 15, offset (-6, 14)
sprite_cf_width = 16
sprite_cf_height = 15
sprite_cf_plane_size = 30
sprite_cf_reserved_size = 0
.sprite_cf_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10001111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000001
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11111000
    ; Byte column 1, rows top-to-bottom
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %10000001
    EQUB %11000001
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %10000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000111
    EQUB %00011111
}

.sprite_cf_sprite_data
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
    EQUB %01110000
    EQUB %01110000
    EQUB %01111000
    EQUB %00111110
    EQUB %00011111
    EQUB %00000111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %01111000
    EQUB %00111100
    EQUB %00011100
    EQUB %00001110
    EQUB %00001110
    EQUB %00001110
    EQUB %00011110
    EQUB %01111100
    EQUB %11111000
    EQUB %11100000
    EQUB %00000000
}

.sprite_cf
{
    EQUB &FA, &0E, 16, 15
    EQUW sprite_cf_mask_data, sprite_cf_sprite_data
}

; Sprite &D0: 16 x 19, offset (-6, 18)
sprite_d0_width = 16
sprite_d0_height = 19
sprite_d0_plane_size = 38
sprite_d0_reserved_size = 0
.sprite_d0_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10001111
    EQUB %00000100
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %11111000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00000111
    EQUB %00000011
    EQUB %10000001
    EQUB %11000001
    EQUB %11100000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
}

.sprite_d0_sprite_data
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
    EQUB %01110000
    EQUB %01110011
    EQUB %01110111
    EQUB %00101110
    EQUB %00001101
    EQUB %00001101
    EQUB %00001100
    EQUB %00001110
    EQUB %00000111
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11110000
    EQUB %01111000
    EQUB %00111100
    EQUB %00011100
    EQUB %00001110
    EQUB %00001110
    EQUB %11101110
    EQUB %10011110
    EQUB %01111100
    EQUB %11111000
    EQUB %11100000
    EQUB %00011000
    EQUB %00111000
    EQUB %11110000
    EQUB %11100000
    EQUB %00000000
}

.sprite_d0
{
    EQUB &FA, &12, 16, 19
    EQUW sprite_d0_mask_data, sprite_d0_sprite_data
}

; Sprite &D1: 5 x 4, offset (1, -1)
sprite_d1_width = 5
sprite_d1_height = 4
sprite_d1_plane_size = 4
sprite_d1_reserved_size = 0
.sprite_d1_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
}

.sprite_d1_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %01100000
    EQUB %01010000
    EQUB %00110000
    EQUB %01110000
}

.sprite_d1
{
    EQUB &01, &FF, 5, 4
    EQUW sprite_d1_mask_data, sprite_d1_sprite_data
}

; Sprite &D2: 24 x 20, offset (0, 14)
sprite_d2_width = 24
sprite_d2_height = 20
sprite_d2_plane_size = 60
sprite_d2_reserved_size = 0
.sprite_d2_mask_data
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

.sprite_d2_sprite_data
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

.sprite_d2
{
    EQUB &00, &0E, 24, 20
    EQUW sprite_d2_mask_data, sprite_d2_sprite_data
}

; Sprite &D3: 8 x 4, offset (0, 7)
sprite_d3_width = 8
sprite_d3_height = 4
sprite_d3_plane_size = 4
sprite_d3_reserved_size = 0
.sprite_d3_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d3_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %11111111
    EQUB %11111111
    EQUB %00000000
}

.sprite_d3
{
    EQUB &00, &07, 8, 4
    EQUW sprite_d3_mask_data, sprite_d3_sprite_data
}

; Sprite &D4: 12 x 9, offset (4, 7)
sprite_d4_width = 12
sprite_d4_height = 9
sprite_d4_plane_size = 18
sprite_d4_reserved_size = 0
.sprite_d4_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000011
    EQUB %00000011
    EQUB %10000111
    EQUB %10000111
    EQUB %10000111
    EQUB %10000000
    EQUB %11000000
    EQUB %11100000
    EQUB %11110000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
    EQUB %00001111
}

.sprite_d4_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %01110000
    EQUB %00000000
    EQUB %00110000
    EQUB %00110000
    EQUB %00111000
    EQUB %00011111
    EQUB %00001111
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11110000
    EQUB %11110000
    EQUB %00000000
}

.sprite_d4
{
    EQUB &04, &07, 12, 9
    EQUW sprite_d4_mask_data, sprite_d4_sprite_data
}

; Sprite &D5: 11 x 9, offset (0, 7)
sprite_d5_width = 11
sprite_d5_height = 9
sprite_d5_plane_size = 18
sprite_d5_reserved_size = 0
.sprite_d5_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    ; Byte column 1, rows top-to-bottom
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d5_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000011
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000011
    EQUB %11111111
    EQUB %11111110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_d5
{
    EQUB &00, &07, 11, 9
    EQUW sprite_d5_mask_data, sprite_d5_sprite_data
}

; Sprite &D6: 17 x 37, offset (-5, 39)
sprite_d6_width = 17
sprite_d6_height = 37
sprite_d6_plane_size = 111
sprite_d6_reserved_size = 0
.sprite_d6_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111110
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111100
    EQUB %11111000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %10000001
    EQUB %10000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11100001
    ; Byte column 1, rows top-to-bottom
    EQUB %00111111
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
    EQUB %00001111
    EQUB %00000011
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %10000001
    EQUB %10000001
    EQUB %11000011
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
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
}

.sprite_d6_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000001
    EQUB %00000001
    EQUB %00000001
    EQUB %00000000
    EQUB %00000010
    EQUB %00010101
    EQUB %00101010
    EQUB %00010101
    EQUB %00101010
    EQUB %01010100
    EQUB %00101000
    EQUB %01010100
    EQUB %00101000
    EQUB %00010100
    EQUB %00111110
    EQUB %00011110
    EQUB %00011110
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %01000000
    EQUB %00000000
    EQUB %10100000
    EQUB %01010100
    EQUB %10101010
    EQUB %01010100
    EQUB %00101010
    EQUB %00010101
    EQUB %00001010
    EQUB %00010101
    EQUB %00001010
    EQUB %00010100
    EQUB %00111110
    EQUB %00111100
    EQUB %00111100
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
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
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
    EQUB &FB, &27, 17, 37
    EQUW sprite_d6_mask_data, sprite_d6_sprite_data
}

; Sprite &D7: 5 x 4, offset (1, 7)
sprite_d7_width = 5
sprite_d7_height = 4
sprite_d7_plane_size = 4
sprite_d7_reserved_size = 0
.sprite_d7_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
}

.sprite_d7_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %11111000
    EQUB %11111000
    EQUB %00000000
}

.sprite_d7
{
    EQUB &01, &07, 5, 4
    EQUW sprite_d7_mask_data, sprite_d7_sprite_data
}

; Sprite &D8: 30 x 13, offset (-19, -1)
sprite_d8_width = 30
sprite_d8_height = 13
sprite_d8_plane_size = 52
sprite_d8_reserved_size = 0
.sprite_d8_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %10111111
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %11000111
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11110000
    EQUB %11000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %11000000
    EQUB %11111111
    ; Byte column 2, rows top-to-bottom
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
    EQUB %00111000
    EQUB %11111110
    ; Byte column 3, rows top-to-bottom
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00000111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00011111
    EQUB %00000111
    EQUB %00000011
    EQUB %00000111
    EQUB %00001111
    EQUB %00011111
}

.sprite_d8_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %01000000
    EQUB %01111111
    EQUB %00111011
    EQUB %00000111
    EQUB %00011111
    EQUB %00111000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    EQUB %00111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %00111111
    EQUB %00000000
    EQUB %00000000
    ; Byte column 2, rows top-to-bottom
    EQUB %00011111
    EQUB %00011111
    EQUB %01111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111111
    EQUB %11111110
    EQUB %11111110
    EQUB %11111111
    EQUB %11101111
    EQUB %11000111
    EQUB %00000001
    EQUB %00000000
    ; Byte column 3, rows top-to-bottom
    EQUB %11110000
    EQUB %11110000
    EQUB %11110000
    EQUB %11110000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %11000000
    EQUB %01100000
    EQUB %10111000
    EQUB %11000000
    EQUB %11100000
    EQUB %00000000
}

.sprite_d8
{
    EQUB &ED, &FF, 30, 13
    EQUW sprite_d8_mask_data, sprite_d8_sprite_data
}

; Sprite &D9: 12 x 6, offset (0, -14)
sprite_d9_width = 12
sprite_d9_height = 6
sprite_d9_plane_size = 12
sprite_d9_reserved_size = 0
.sprite_d9_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %11111111
    EQUB %00011111
    EQUB %00001111
    EQUB %00001111
    EQUB %00011111
    EQUB %00111111
}

.sprite_d9_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00001111
    EQUB %00011110
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %11100000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
}

.sprite_d9
{
    EQUB &00, &F2, 12, 6
    EQUW sprite_d9_mask_data, sprite_d9_sprite_data
}

; Sprite &DA: 0 x 0, offset (0, 0)
sprite_da_width = 0
sprite_da_height = 0
sprite_da_plane_size = 0
sprite_da_reserved_size = 0
.sprite_da
{
    EQUB &00, &00, 0, 0
    EQUW 0, 0 ; no drawable planes
}

; Sprite &DB: 11 x 8, offset (0, -14)
sprite_db_width = 11
sprite_db_height = 8
sprite_db_plane_size = 16
sprite_db_reserved_size = 0
.sprite_db_mask_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11111110
    EQUB %11110000
    EQUB %11100000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %01111111
    EQUB %00111111
    EQUB %00011111
    EQUB %00011111
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
}

.sprite_db_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %00000000
    EQUB %00000001
    EQUB %00001111
    EQUB %00011011
    EQUB %00111111
    EQUB %00111111
    EQUB %01111111
    EQUB %01111111
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %10000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_db
{
    EQUB &00, &F2, 11, 8
    EQUW sprite_db_mask_data, sprite_db_sprite_data
}

; Sprite &DC: 24 x 21, offset (0, 14)
sprite_dc_width = 24
sprite_dc_height = 21
sprite_dc_plane_size = 63
sprite_dc_reserved_size = 0
.sprite_dc_mask_data
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

.sprite_dc_sprite_data
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

.sprite_dc
{
    EQUB &00, &0E, 24, 21
    EQUW sprite_dc_mask_data, sprite_dc_sprite_data
}

; Sprite &DD: 10 x 31, offset (-4, 38)
sprite_dd_width = 10
sprite_dd_height = 31
sprite_dd_plane_size = 62
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
    EQUB %10001000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111000
    EQUB %11111100
    ; Byte column 1, rows top-to-bottom
    EQUB %10111111
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
    EQUB %01111111
}

.sprite_dd_sprite_data
{
    ; Byte column 0, rows top-to-bottom
    EQUB %11000000
    EQUB %11011111
    EQUB %10111110
    EQUB %01111001
    EQUB %01110111
    EQUB %01100111
    EQUB %01110000
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000011
    EQUB %00000000
    ; Byte column 1, rows top-to-bottom
    EQUB %00000000
    EQUB %00000000
    EQUB %01000000
    EQUB %11000000
    EQUB %11000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %10000000
    EQUB %00000000
    EQUB %00000000
}

.sprite_dd
{
    EQUB &FC, &26, 10, 31
    EQUW sprite_dd_mask_data, sprite_dd_sprite_data
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
}
.level_sprite_data_end
