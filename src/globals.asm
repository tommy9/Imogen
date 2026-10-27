; Constants
encryption_key = &CB
MACRO encode plaintext, terminator
    IF LEN(plaintext) > 0
        FOR n, 1, LEN(plaintext)
            EQUB ASC(MID$(plaintext,n,1)) EOR encryption_key
        NEXT
    ENDIF
    EQUB terminator EOR encryption_key
ENDMACRO

; Collision map
collision_map_none = 0
collision_map_unknown = 1
collision_map_rope = 2
collision_map_solid_rock = 3
collision_map_out_of_bounds = 255
; Copy mode
copy_mode_2x2 = 0
copy_mode_simple = 1
copy_mode_random2 = 2
copy_mode_random4 = 4
copy_mode_random8 = 8
copy_mode_random16 = 16
copy_mode_random32 = 32
copy_mode_random64 = 64
; Room exit direction
exit_room_left = 1
exit_room_bottom = 2
exit_room_right = 4
exit_room_top = 8
; Dimensions
game_area_height_cells = 24
game_area_width_cells = 40
; Level letter range
first_level_letter = 65
last_level_letter = 81
; Object collisions
object_collided_left_wall = 1
object_collided_floor = 2
object_collided_right_wall = 4
object_collided_ceiling = 8
; Object IDs
objectid_player = 0
objectid_player_accessory = 1
objectid_old_player = 11
objectid_old_player_accessory = 12
; Op codes
opcode_jmp = 76
; Sprite operations
sprite_op_flags_normal = 0
sprite_op_flags_copy_screen = 1
sprite_op_flags_erase_to_bg_colour = 2
sprite_op_flags_erase_to_fg_colour = 4
; Sprite IDs
spriteid_one_pixel_masked_out = 0
spriteid_icon_background = 1
spriteid_icodata_sound = 2
spriteid_icodata_disc = 3
spriteid_icodata_wizard = 4
spriteid_icodata_cat = 5
spriteid_icodata_monkey = 6
spriteid_icodata_info = 7
spriteid_icodata_password = 8
spriteid_icodata_box = 9
spriteid_rope_end = 10
spriteid_rope_hook = 11
spriteid_cat_walk1 = 12
spriteid_cat_walk2 = 13
spriteid_cat_walk3 = 14
spriteid_cat_walk4 = 15
spriteid_cat_transform1 = 16
spriteid_cat_transform2 = 17
spriteid_cat_tail1 = 18
spriteid_cat_tail2 = 19
spriteid_cat_tail3 = 20
spriteid_cat_tail4 = 21
spriteid_cat_tail5 = 22
spriteid_cat_tail6 = 23
spriteid_cat_tail7 = 24
spriteid_cat_tail8 = 25
spriteid_cat_jump = 26
spriteid_cat1 = 27
spriteid_cat2 = 28
spriteid_pointer_hand = 29
spriteid_fingertip_tile_restoration = 30
spriteid_one_pixel_set = 31
spriteid_circle = 32
spriteid_menu_item_completion_spell = 33
spriteid_sparkles1 = 34
spriteid_sparkles2 = 35
spriteid_sparkles3 = 36
spriteid_sparkles4 = 37
spriteid_sparkles5 = 38
spriteid_diamond1 = 39
spriteid_diamond2 = 40
spriteid_diamond3 = 41
spriteid_diamond4 = 42
spriteid_diamond5 = 43
spriteid_corner_top_left = 44
spriteid_corner_bottom_left = 45
spriteid_corner_bottom_right = 46
spriteid_corner_top_right = 47
spriteid_wizard1 = 48
spriteid_wizard2 = 49
spriteid_wizard3 = 50
spriteid_wizard4 = 51
spriteid_wizard5 = 52
spriteid_wizard_using_object = 53
spriteid_wizard7 = 54
spriteid_wizard_hand = 55
spriteid_wizard_transform1 = 56
spriteid_wizard_transform2 = 57
spriteid_brazier = 58
spriteid_ball = 59
spriteid_fire1 = 60
spriteid_fire2 = 61
spriteid_fire3 = 62
spriteid_fire4 = 63
spriteid_fire5 = 64
spriteid_fire6 = 65
spriteid_fire7 = 66
spriteid_fire8 = 67
spriteid_monkey_transform1 = 68
spriteid_monkey_transform2 = 69
spriteid_monkey_tail1 = 70
spriteid_monkey_tail2 = 71
spriteid_monkey_tail3 = 72
spriteid_monkey_tail4 = 73
spriteid_monkey_tail5 = 74
spriteid_monkey_tail6 = 75
spriteid_monkey_tail7 = 76
spriteid_monkey_tail8 = 77
spriteid_monkey1 = 78
spriteid_monkey2 = 79
spriteid_monkey3 = 80
spriteid_monkey4 = 81
spriteid_monkey5 = 82
spriteid_monkey_climb1 = 83
spriteid_monkey_climb2 = 84
spriteid_rope1 = 85
spriteid_rope2 = 86
spriteid_rope3 = 87
spriteid_rope4 = 88
spriteid_erase_sparkles = 197
spriteid_erase_player_accessory = 198
spriteid_erase_player = 199

; Memory locations defined in g.asm to be referenced from levels or auxcode
; Generated automatically by compile.sh
IF is_level
    INCLUDE "build/engine_exports.asm"
ENDIF
