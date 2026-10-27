; Active two-contribution/cached-mask renderer from ImogenSprite/test.6502.
; Extracted 2026-10-13. Writable, non-reentrant NMOS 6502 code.
; Inputs use the Phase 1 zero-page assignment; all other state is resident RAM.
; Logical viewports: game 0..191 at &6200; toolbar 24..63 at &5800.
swr_sprite_op_flags = swr_zp_sprite_op_flags
swr_sprite_reflect_flag = swr_zp_sprite_reflect_flag
swr_screen_base_address_high = swr_zp_screen_base_address_high
swr_src_sprite_address_low = swr_zp_src_sprite_address_low
swr_src_sprite_address_high = swr_zp_src_sprite_address_high
swr_sprite_screen_address_low = swr_zp_sprite_screen_address_low
swr_sprite_screen_address_high = swr_zp_sprite_screen_address_high
swr_sprite_x_pos_low = swr_zp_sprite_x_pos_low
swr_sprite_x_pos_high = swr_zp_sprite_x_pos_high
swr_sprite_y_pos_low = swr_zp_sprite_y_pos_low
swr_sprite_y_pos_high = swr_zp_sprite_y_pos_high
swr_sprite_width = swr_zp_sprite_width
swr_sprite_height = swr_zp_sprite_height
swr_sprite_y_offset_within_character_row = swr_zp_sprite_y_offset_within_character_row
swr_sprite_screen_address_for_column_low = swr_zp_sprite_screen_address_for_column_low
swr_sprite_screen_address_for_column_high = swr_zp_sprite_screen_address_for_column_high
swr_sprite_data_byte = swr_zp_sprite_data_byte
swr_backup_sprite_address_low = swr_zp_backup_sprite_address_low
swr_backup_sprite_address_high = swr_zp_backup_sprite_address_high
swr_src_mask_address_low = swr_zp_src_mask_address_low
swr_src_mask_address_high = swr_zp_src_mask_address_high
swr_cached_mask_address_low = swr_zp_cached_mask_address_low
swr_cached_mask_address_high = swr_zp_cached_mask_address_high
swr_original_screen_byte = swr_zp_original_screen_byte
swr_mask_data_byte = swr_zp_mask_data_byte
swr_temp = swr_zp_temp
swr_temp_y = swr_zp_temp_y
swr_translate_masks = swr_normal_translate_masks
swr_sprite_op_flags_erase_to_bg_colour = 2
swr_sprite_op_flags_erase_to_fg_colour = 4
.swr_viewport_first EQUB 0
.swr_viewport_end EQUB 192
.swr_calc_screen_address
{
    ; Clipping has already produced visible, unsigned screen coordinates.
    .^swr_calc_screen_address_from_clipped_bounds
    ; Use the original game's addressing: round Y to its character row.
    LDA #0
    STA swr_sprite_screen_address_high
    LDA swr_clipped_bottom_y
    AND #%11111000
    ; Then multiply by eight and store in ($72)
    ASL a
    ROL swr_sprite_screen_address_high
    ASL a
    ROL swr_sprite_screen_address_high
    ASL a
    ROL swr_sprite_screen_address_high
    STA swr_sprite_screen_address_low
    ; Multiply by four
    ldx swr_sprite_screen_address_high
    ASL a
    ROL swr_sprite_screen_address_high
    ASL a
    ROL swr_sprite_screen_address_high
    ; Add eight times the x position as a character row
    LDA swr_clipped_x_low
    AND #%11111000
    CLC
    ADC swr_sprite_screen_address_low
    STA swr_sprite_screen_address_low
    STA swr_sprite_screen_address_for_column_low
    ; Add high byte including X
    TXA
    ADC swr_sprite_screen_address_high
    CLC
    ADC swr_clipped_x_high
    CLC
    ADC swr_screen_base_address_high
    STA swr_sprite_screen_address_high
    STA swr_sprite_screen_address_for_column_high
    .swr_end
    RTS
}

.swr_current_pixel_offset_within_column SKIP 1 ; "x coord (start)"
.swr_bits_consumed_already SKIP 1 ; "data start". Bits of the sprite data byte that have been used already
.swr_pixels_to_draw SKIP 1 ; "bits to write"
.swr_delta_lo SKIP 1 ; 16-bit adjustment for +/- swr_sprite_height to address
.swr_delta_hi SKIP 1

; Prepare the self-modifying row operands directly, before drawing the column.
; Backup columns are screen aligned, left-to-right, swr_visible_height bytes each.
.swr_contribution_state
.swr_part_index SKIP 1 ; byte displacement from contribution 1 operands to part 2
; Source offset exists only during reflected setup, before row scratch is live.
swr_source_column_offset_low = swr_temp
swr_source_column_offset_high = swr_temp_y
.swr_restore_columns SKIP 1
.swr_visible_width SKIP 1
.swr_visible_height SKIP 1
.swr_clip_left_pixels SKIP 1
.swr_clip_top_rows SKIP 1
.swr_clipped_x_low SKIP 1
.swr_clipped_x_high SKIP 1
.swr_clipped_bottom_y SKIP 1
.swr_interval_edges EQUB &FF,&7F,&3F,&1F,&0F,&07,&03,&01,&00

; Bounds use 320 pixels and the selected Y viewport. Input x is the final
; signed left edge (including reflection); y is the signed bottom.
; Carry set means no visible pixel. The source stride remains swr_sprite_height,
; while backup columns contain only swr_visible_height bytes.
.swr_empty_bounds
    SEC
    RTS
.swr_clip_sprite_bounds
{
    LDX swr_sprite_width
    BEQ swr_empty_bounds
    LDY swr_sprite_height
    BEQ swr_empty_bounds
    BMI swr_empty_bounds ; supported height 1..127
    STX swr_visible_width
    STY swr_visible_height
    LDA #0
    STA swr_clip_left_pixels
    STA swr_clip_top_rows
    LDA swr_sprite_x_pos_low
    STA swr_clipped_x_low
    LDA swr_sprite_y_pos_low
    STA swr_clipped_bottom_y

    ; Conservative fully-onscreen shortcut, shared by drawing and restoration.
    ; Require X+width <256; sprites extending into 256..319 use normal bounds.
    ; Both coordinate high bytes must be zero, and the whole height must fit
    ; the selected gameplay/toolbar viewport. No clip fields need adjusting.
    LDA swr_sprite_x_pos_high
    STA swr_clipped_x_high
    ORA swr_sprite_y_pos_high
    BNE swr_slow_bounds
    LDA swr_sprite_x_pos_low
    CLC
    ADC swr_sprite_width
    BCS swr_slow_bounds
    LDA swr_sprite_y_pos_low
    CMP swr_viewport_end
    BCS swr_slow_bounds
    SEC
    SBC swr_viewport_first
    BCC swr_slow_bounds
    ADC #0 ; bottom - first + 1
    CMP swr_sprite_height
    BCC swr_slow_bounds
    JMP swr_bounds_ready

    .swr_slow_bounds

    ; Signed 16-bit left coordinate. A negative position can be visible only
    ; in the -255..-1 range because width is at most 255.
    LDA swr_sprite_x_pos_high
    BMI swr_left_negative
    BEQ swr_left_low_page
    CMP #1
    BEQ swr_right_high_page
    JMP swr_outside
    .swr_right_high_page
    LDA swr_sprite_x_pos_low
    CMP #64
    BCC swr_right_within_page
    JMP swr_outside
    .swr_right_within_page
    LDA #64
    SEC
    SBC swr_sprite_x_pos_low
    JMP swr_limit_right
    .swr_left_low_page
    LDA swr_sprite_x_pos_low
    CMP #65
    BCC swr_x_ready ; 320-x exceeds byte-sized sprite width
    LDA #64
    SEC
    SBC swr_sprite_x_pos_low ; wraps to 320-x
    JMP swr_limit_right
    .swr_left_negative
    CMP #&FF
    BEQ swr_left_high_is_ff
    JMP swr_outside
    .swr_left_high_is_ff
    LDA swr_sprite_x_pos_low
    BNE swr_negative_within_reach
    JMP swr_outside ; -256 cannot overlap a sprite of at most 255 pixels
    .swr_negative_within_reach
    LDA #0
    SEC
    SBC swr_sprite_x_pos_low ; -x, 1..255
    CMP swr_sprite_width
    BCC swr_left_overlaps
    JMP swr_outside
    .swr_left_overlaps
    STA swr_clip_left_pixels
    LDA swr_sprite_width
    SEC
    SBC swr_clip_left_pixels
    STA swr_visible_width
    LDA #0
    STA swr_clipped_x_low
    STA swr_clipped_x_high
    JMP swr_x_ready
    .swr_limit_right
    CMP swr_visible_width
    BCS swr_right_unclipped
    STA swr_visible_width
    .swr_right_unclipped
    .swr_x_ready

    ; Clip signed bottom against the selected logical viewport.
    LDA swr_sprite_y_pos_high
    BMI swr_outside_y
    CMP #2
    BCS swr_outside_y
    LDA swr_sprite_y_pos_low
    SEC
    SBC swr_viewport_end
    STA swr_temp
    LDA swr_sprite_y_pos_high
    SBC #0
    BMI swr_bottom_visible
    BNE swr_outside_y
    LDA swr_temp
    CLC
    ADC #1
    CMP swr_sprite_height
    BCS swr_outside_y
    STA swr_temp
    LDA swr_sprite_height
    SEC
    SBC swr_temp
    STA swr_visible_height
    LDA swr_viewport_end
    SEC
    SBC #1
    STA swr_clipped_bottom_y
    JMP swr_limit_top
    .swr_outside_y
    JMP swr_outside
    .swr_bottom_visible
    .swr_limit_top
    LDA swr_clipped_bottom_y
    SEC
    SBC swr_viewport_first
    BCC swr_outside_y
    ADC #0 ; bottom - first + 1 (SBC left carry set)
    CMP swr_visible_height
    BCS swr_bounds_ready
    STA swr_temp
    LDA swr_visible_height
    SEC
    SBC swr_temp
    STA swr_clip_top_rows
    LDA swr_temp
    STA swr_visible_height
    .swr_bounds_ready

    ; Calculate from bounded clip fields; retain original signed geometry.
    JSR swr_calc_screen_address_from_clipped_bounds
    CLC
    RTS
    .swr_outside
    SEC
    RTS
}

; Input screen address and x coordinate have already been converted to left edge.
; Width is consumed. A/X/Y and the source/backup/working screen pointers are clobbered.
.swr_draw_sprite
{
    JSR swr_clip_sprite_bounds
    BCC swr_initialise_counters
    .swr_empty
    RTS
    .^swr_draw_prepared
    .swr_initialise_counters
    ; Select the operand slots once per sprite. Fixed-colour erases prepare
    ; their mask row directly and never prepare sprite-pixel operands.
    LDA swr_sprite_op_flags
    AND #swr_sprite_op_flags_erase_to_fg_colour OR swr_sprite_op_flags_erase_to_bg_colour
    BEQ swr_prepare_draw_operands
    JSR swr_prepare_erase_colour
    LDA #swr_erase_part_offset
    LDX #swr_erase_part_offset + swr_sprite_address_read_2-swr_sprite_address_read_1
    BNE swr_operand_slots_ready
    .swr_prepare_draw_operands
    LDA #0
    LDX #swr_sprite_address_read_2-swr_sprite_address_read_1
    .swr_operand_slots_ready
    STA swr_first_part+1
    STX swr_second_part+1
    ; Fold the reflection offset and table origin into one immediate per sprite.
    LDA #HI(swr_translate_masks)+7
    STA swr_contribution_shift_base+1
    LDA #0
    STA swr_bits_consumed_already
    BIT swr_sprite_reflect_flag
    BPL swr_source_ready
    LDA #HI(swr_translate_masks)+7+15
    STA swr_contribution_shift_base+1
    LDA #0
    STA swr_source_column_offset_low
    STA swr_source_column_offset_high
    SEC
    SBC swr_sprite_width
    AND #7
    STA swr_bits_consumed_already
    LDA swr_sprite_width
    SEC
    SBC #1
    LSR A: LSR A: LSR A
    TAX
    BEQ swr_source_ready
    ; 16-bit height * ((width-1)/8), including sprites larger than 256 bytes.
    .swr_source_offset_loop
    LDA swr_source_column_offset_low
    CLC
    ADC swr_sprite_height
    STA swr_source_column_offset_low
    LDA swr_source_column_offset_high
    ADC #0
    STA swr_source_column_offset_high
    DEX
    BNE swr_source_offset_loop
    LDA swr_src_sprite_address_low
    CLC
    ADC swr_source_column_offset_low
    STA swr_src_sprite_address_low
    LDA swr_src_sprite_address_high
    ADC swr_source_column_offset_high
    STA swr_src_sprite_address_high
    LDA swr_src_mask_address_low
    CLC
    ADC swr_source_column_offset_low
    STA swr_src_mask_address_low
    LDA swr_src_mask_address_high
    ADC swr_source_column_offset_high
    STA swr_src_mask_address_high
    .swr_source_ready
    ; Keep the original height as the stride when moving between source
    ; columns. The visible height controls only row count and backup stride.
    LDA swr_sprite_height
    LDX #0
    BIT swr_sprite_reflect_flag
    BPL swr_delta_ready
    EOR #&FF
    CLC
    ADC #1
    DEX
    .swr_delta_ready
    STA swr_delta_lo
    STX swr_delta_hi
    ; Advance the source cursor by clipped pixels in drawing order. The
    ; initial phase is nonzero only for a reflected partial source byte.
    LDA swr_bits_consumed_already
    CLC
    ADC swr_clip_left_pixels
    PHA
    AND #7
    STA swr_bits_consumed_already
    PLA
    LSR A: LSR A: LSR A
    TAX
    BEQ swr_source_columns_ready
    .swr_skip_source_column
    LDA swr_src_sprite_address_low
    CLC
    ADC swr_delta_lo
    STA swr_src_sprite_address_low
    LDA swr_src_sprite_address_high
    ADC swr_delta_hi
    STA swr_src_sprite_address_high
    LDA swr_src_mask_address_low
    CLC
    ADC swr_delta_lo
    STA swr_src_mask_address_low
    LDA swr_src_mask_address_high
    ADC swr_delta_hi
    STA swr_src_mask_address_high
    DEX
    BNE swr_skip_source_column
    .swr_source_columns_ready
    ; Top clipping shifts every source column's base by the same row offset.
    LDA swr_src_sprite_address_low
    CLC
    ADC swr_clip_top_rows
    STA swr_src_sprite_address_low
    LDA swr_src_sprite_address_high
    ADC #0
    STA swr_src_sprite_address_high
    LDA swr_src_mask_address_low
    CLC
    ADC swr_clip_top_rows
    STA swr_src_mask_address_low
    LDA swr_src_mask_address_high
    ADC #0
    STA swr_src_mask_address_high
    LDA swr_clipped_x_low
    AND #7
    STA swr_current_pixel_offset_within_column
    LDA swr_clipped_bottom_y
    AND #7
    STA swr_sprite_y_offset_within_character_row

    LDA swr_visible_width
    STA swr_sprite_width
    .swr_column_start
    LDA #0
    STA swr_sprite_adjustment+1 ; start union of both contribution intervals
    .swr_first_part
    LDA #0
    STA swr_part_index
    JSR swr_prepare_screen_contribution
    LDA swr_sprite_width
    BEQ swr_duplicate_part
    LDA swr_current_pixel_offset_within_column
    CMP #8
    BCS swr_duplicate_part
    .swr_second_part
    LDA #swr_sprite_address_read_2 - swr_sprite_address_read_1
    STA swr_part_index
    JSR swr_prepare_screen_contribution
    LDA #0 ; V is the row-kernel single-part flag, independent of slot offset.
    STA swr_part_index
    JMP swr_send_to_drawing_routine
    .swr_duplicate_part
    ; BIT exposes bit 6 as V in each row kernel. Single contributions need no
    ; second source fetch/combine. Two-part indices have bit 6 clear.
    LDA #&40
    STA swr_part_index
    .swr_send_to_drawing_routine
    LDA swr_sprite_op_flags
    AND #swr_sprite_op_flags_erase_to_fg_colour OR swr_sprite_op_flags_erase_to_bg_colour
    BEQ swr_not_fixed_colour
    JSR swr_erase_fixed_colour_double_column
    JMP swr_post_column_updates
    .swr_not_fixed_colour
    LDA swr_sprite_op_flags
    BEQ swr_no_backup
    JSR swr_draw_with_backup_column
    JMP swr_post_column_updates
    .swr_no_backup
    JSR swr_draw_without_backup_double_column
    .swr_post_column_updates
    LDA swr_sprite_width
    BEQ swr_end
    JSR swr_advance_screen_backup_column
    LDA #0
    STA swr_current_pixel_offset_within_column
    JMP swr_column_start
    .swr_end
    RTS
}

.swr_prepare_screen_contribution
{
    LDA #8
    SEC
    SBC swr_current_pixel_offset_within_column
    STA swr_pixels_available_in_column
    LDA #8
    SEC
    SBC swr_bits_consumed_already
    CMP swr_pixels_available_in_column
    BCC swr_source_interval_smaller
    LDA swr_pixels_available_in_column
    .swr_source_interval_smaller
    CMP swr_sprite_width
    BCC swr_interval_ready
    LDA swr_sprite_width
    .swr_interval_ready
    STA swr_pixels_to_draw
    LDX swr_part_index
    CPX #swr_erase_part_offset
    BCS swr_prepare_mask_pointer
    LDA swr_src_sprite_address_low: STA swr_sprite_address_read_1+1,X
    LDA swr_src_sprite_address_high: STA swr_sprite_address_read_1+2,X
    .swr_prepare_mask_pointer
    LDA swr_src_mask_address_low: STA swr_mask_address_read_1+1,X
    LDA swr_src_mask_address_high: STA swr_mask_address_read_1+2,X
    ; Signed p-b wraps in A; adding the patched origin gives the table page.
    LDA swr_current_pixel_offset_within_column
    SEC
    SBC swr_bits_consumed_already
    CLC
    .^swr_contribution_shift_base: ADC #HI(swr_translate_masks)+7
    CPX #swr_erase_part_offset
    BCS swr_prepare_mask_shift
    STA swr_shift_table_sprite_1+2,X
    .swr_prepare_mask_shift
    STA swr_shift_table_mask_1+2,X
    LDY swr_current_pixel_offset_within_column
    LDA swr_interval_edges,Y
    STA swr_temp
    TYA
    CLC
    ADC swr_pixels_to_draw
    STA swr_current_pixel_offset_within_column
    TAY
    LDA swr_interval_edges,Y
    EOR swr_temp
    ORA swr_sprite_adjustment+1
    STA swr_sprite_adjustment+1
    EOR #&FF
    STA swr_mask_adjustment+1
    LDA swr_sprite_width
    SEC
    SBC swr_pixels_to_draw
    STA swr_sprite_width
    LDA swr_bits_consumed_already
    CLC
    ADC swr_pixels_to_draw
    STA swr_bits_consumed_already
    CMP #8
    BNE swr_done
    LDA swr_sprite_width
    BEQ swr_done
    LDA #0
    STA swr_bits_consumed_already
    ; Advance only the planes used by this operation. Backup never follows
    ; source reflection. Fixed-colour erases consume no sprite-pixel bytes.
    LDX swr_part_index
    CPX #swr_erase_part_offset
    BCS swr_advance_mask_source
    LDA swr_src_sprite_address_low
    CLC
    ADC swr_delta_lo
    STA swr_src_sprite_address_low
    LDA swr_src_sprite_address_high
    ADC swr_delta_hi
    STA swr_src_sprite_address_high
    .swr_advance_mask_source
    LDA swr_src_mask_address_low
    CLC
    ADC swr_delta_lo
    STA swr_src_mask_address_low
    LDA swr_src_mask_address_high
    ADC swr_delta_hi
    STA swr_src_mask_address_high
    .swr_done
    RTS
}

.swr_advance_screen_backup_column
{
    LDA swr_backup_sprite_address_low
    CLC
    ADC swr_visible_height
    STA swr_backup_sprite_address_low
    LDA swr_backup_sprite_address_high
    ADC #0
    STA swr_backup_sprite_address_high
    LDA swr_cached_mask_address_low
    CLC
    ADC swr_visible_height
    STA swr_cached_mask_address_low
    LDA swr_cached_mask_address_high
    ADC #0
    STA swr_cached_mask_address_high
    LDA swr_sprite_screen_address_for_column_low
    CLC
    ADC #8
    STA swr_sprite_screen_address_for_column_low
    STA swr_sprite_screen_address_low
    LDA swr_sprite_screen_address_for_column_high
    ADC #0
    STA swr_sprite_screen_address_for_column_high
    STA swr_sprite_screen_address_high
    RTS
}

; Cached restore contract: reload original width/height, signed left-edge x,
; signed bottom y, screen base, background base and cached-mask base. Call
; swr_calc_screen_address_from_left_edge then this entry. Source pointers,
; reflection and operation flags are ignored; no sprite/table bank is needed.
; Both planes have identical screen-aligned layout: visible columns left to
; right, swr_visible_height rows top to bottom. Preserve-mask 1 means keep current.
; Keep both planes unchanged until undraw, and invalidate after screen rebuild.
; A/X/Y, width, backup/cache/screen pointers and scratch are clobbered.
; Non-reentrant, writable code. Invalid/offscreen calls access neither plane.
.swr_restore_sprite_background
{
    JSR swr_clip_sprite_bounds
    BCS swr_empty
    LDA swr_visible_width
    LSR A: LSR A: LSR A
    STA swr_restore_columns
    LDA swr_visible_width
    AND #7
    STA swr_temp
    LDA swr_clipped_x_low
    AND #7
    CLC
    ADC swr_temp
    CLC
    ADC #7
    LSR A: LSR A: LSR A
    CLC
    ADC swr_restore_columns
    STA swr_restore_columns
    LDA swr_clipped_bottom_y
    AND #7
    STA swr_sprite_y_offset_within_character_row
    .swr_column_start
    LDA swr_backup_sprite_address_low: STA swr_backup_read+1
    LDA swr_backup_sprite_address_high: STA swr_backup_read+2
    LDA swr_cached_mask_address_low: STA swr_cached_mask_read+1
    LDA swr_cached_mask_address_high: STA swr_cached_mask_read+2
    LDX swr_visible_height
    DEX
    LDY swr_sprite_y_offset_within_character_row
    .swr_row
    ; saved XOR ((current XOR saved) AND preserve_mask)
    ; One read of each plane and one current-screen read/write.
    .swr_backup_read: LDA &FFFF,X
    STA swr_original_screen_byte
    EOR (swr_sprite_screen_address_low),Y
    .swr_cached_mask_read: AND &FFFF,X
    EOR swr_original_screen_byte
    STA (swr_sprite_screen_address_low),Y
    DEX
    BMI swr_column_done
    DEY
    BPL swr_row
    LDA swr_sprite_screen_address_low
    SEC
    SBC #LO(320)
    STA swr_sprite_screen_address_low
    LDA swr_sprite_screen_address_high
    SBC #HI(320)
    STA swr_sprite_screen_address_high
    LDY #7
    JMP swr_row
    .swr_column_done
    DEC swr_restore_columns
    BEQ swr_empty
    JSR swr_advance_screen_backup_column
    JMP swr_column_start
    .swr_empty
    RTS
}


.swr_draw_with_backup_column
{
    LDA swr_backup_sprite_address_low: STA swr_backup_address_write+1
    LDA swr_backup_sprite_address_high: STA swr_backup_address_write+2
    LDA swr_cached_mask_address_low: STA swr_cached_mask_write+1
    LDA swr_cached_mask_address_high: STA swr_cached_mask_write+2
    BIT swr_part_index
    LDX swr_visible_height
    DEX
    LDY swr_sprite_y_offset_within_character_row
    .swr_y_coordinate_is_within_character_row
    STY swr_temp_y
    LDA (swr_sprite_screen_address_low),Y
    STA swr_original_screen_byte
    .swr_backup_address_write: STA &FFFF,X

    ; Row loads/logical operations preserve V. Restore it after the screen
    ; address subtraction at each character-row boundary; IRQs preserve it.
    .^swr_sprite_address_read_1: LDY &FFFF,X
    .^swr_shift_table_sprite_1: LDA &FF00,Y
    BVS swr_sprite_adjustment
    STA swr_sprite_data_byte
    .^swr_sprite_address_read_2: LDY &FFFF,X
    .^swr_shift_table_sprite_2: LDA &FF00,Y
    AND swr_sprite_data_byte
    .^swr_sprite_adjustment: AND #&FF
    STA swr_sprite_data_byte

    .^swr_mask_address_read_1: LDY &FFFF,X
    .^swr_shift_table_mask_1: LDA &FF00,Y
    BVS swr_mask_adjustment
    STA swr_mask_data_byte
    .^swr_mask_address_read_2: LDY &FFFF,X
    .^swr_shift_table_mask_2: LDA &FF00,Y
    AND swr_mask_data_byte
    .^swr_mask_adjustment: ORA #0
    .swr_cached_mask_write: STA &FFFF,X
    AND swr_original_screen_byte
    ORA swr_sprite_data_byte
    LDY swr_temp_y
    STA (swr_sprite_screen_address_low),Y
    .swr_check_column_finished
    DEX
    BMI swr_exit ; height <=127: only the exhausted counter is negative
    DEY
    BPL swr_y_coordinate_is_within_character_row
    LDA swr_sprite_screen_address_low
    SEC
    SBC #LO(320)
    STA swr_sprite_screen_address_low
    LDA swr_sprite_screen_address_high
    SBC #HI(320)
    STA swr_sprite_screen_address_high
    LDY #7
    BIT swr_part_index
    JMP swr_y_coordinate_is_within_character_row
    .swr_exit
    RTS
}

; Fixed-colour erase uses only the two mask contributions. Zero bits in the
; combined mask are the affected pixels. Common setup patches this row directly.
.swr_erase_fixed_colour_double_column
{
    LDA swr_mask_adjustment+1: STA swr_mask_boundary+1
    BIT swr_part_index
    LDX swr_visible_height
    DEX
    LDY swr_sprite_y_offset_within_character_row
    .swr_row
    STY swr_temp_y
    .^swr_erase_mask_read_1: LDY &FFFF,X
    .^swr_erase_mask_shift_1: LDA &FF00,Y
    BVS swr_mask_boundary
    STA swr_mask_data_byte
    .^swr_erase_mask_read_2: LDY &FFFF,X
    .^swr_erase_mask_shift_2: LDA &FF00,Y
    AND swr_mask_data_byte
    .swr_mask_boundary: ORA #0
    .^swr_erase_invert_mask: EOR #0
    LDY swr_temp_y
    .^swr_erase_combine_screen: AND (swr_sprite_screen_address_low),Y
    STA (swr_sprite_screen_address_low),Y
    DEX
    BMI swr_exit
    DEY
    BPL swr_row
    LDA swr_sprite_screen_address_low
    SEC
    SBC #LO(320)
    STA swr_sprite_screen_address_low
    LDA swr_sprite_screen_address_high
    SBC #HI(320)
    STA swr_sprite_screen_address_high
    LDY #7
    BIT swr_part_index
    JMP swr_row
    .swr_exit
    RTS
}

; Normal drawing uses the same two prepared contributions, without touching
; backup storage. Source and mask tables are patched by the common setup.
.swr_draw_without_backup_double_column
{
    LDA swr_sprite_address_read_1+1: STA swr_sprite_read_1+1
    LDA swr_sprite_address_read_1+2: STA swr_sprite_read_1+2
    LDA swr_sprite_address_read_2+1: STA swr_sprite_read_2+1
    LDA swr_sprite_address_read_2+2: STA swr_sprite_read_2+2
    LDA swr_mask_address_read_1+1: STA swr_mask_read_1+1
    LDA swr_mask_address_read_1+2: STA swr_mask_read_1+2
    LDA swr_mask_address_read_2+1: STA swr_mask_read_2+1
    LDA swr_mask_address_read_2+2: STA swr_mask_read_2+2
    LDA swr_shift_table_sprite_1+2
    STA swr_sprite_shift_1+2
    STA swr_mask_shift_1+2
    LDA swr_shift_table_sprite_2+2
    STA swr_sprite_shift_2+2
    STA swr_mask_shift_2+2
    LDA swr_sprite_adjustment+1: STA swr_sprite_boundary+1
    LDA swr_mask_adjustment+1: STA swr_mask_boundary+1
    BIT swr_part_index
    LDX swr_visible_height
    DEX
    LDY swr_sprite_y_offset_within_character_row
    .swr_row
    STY swr_temp_y
    .swr_sprite_read_1: LDY &FFFF,X
    .swr_sprite_shift_1: LDA &FF00,Y
    BVS swr_sprite_boundary
    STA swr_sprite_data_byte
    .swr_sprite_read_2: LDY &FFFF,X
    .swr_sprite_shift_2: LDA &FF00,Y
    AND swr_sprite_data_byte
    .swr_sprite_boundary: AND #&FF
    STA swr_sprite_data_byte
    .swr_mask_read_1: LDY &FFFF,X
    .swr_mask_shift_1: LDA &FF00,Y
    BVS swr_mask_boundary
    STA swr_mask_data_byte
    .swr_mask_read_2: LDY &FFFF,X
    .swr_mask_shift_2: LDA &FF00,Y
    AND swr_mask_data_byte
    .swr_mask_boundary: ORA #0
    LDY swr_temp_y
    AND (swr_sprite_screen_address_low),Y
    ORA swr_sprite_data_byte
    STA (swr_sprite_screen_address_low),Y
    DEX
    BMI swr_exit
    DEY
    BPL swr_row
    LDA swr_sprite_screen_address_low
    SEC
    SBC #LO(320)
    STA swr_sprite_screen_address_low
    LDA swr_sprite_screen_address_high
    SBC #HI(320)
    STA swr_sprite_screen_address_high
    LDY #7
    BIT swr_part_index
    JMP swr_row
    .swr_exit
    RTS
}

.swr_prepare_erase_colour
{
    LDA swr_sprite_op_flags
    CMP #swr_sprite_op_flags_erase_to_fg_colour
    BEQ swr_foreground
    LDA #0
    STA swr_erase_invert_mask+1
    LDA #&31 ; AND (zp),Y
    STA swr_erase_combine_screen
    RTS
    .swr_foreground
    LDA #&FF
    STA swr_erase_invert_mask+1
    LDA #&11 ; ORA (zp),Y
    STA swr_erase_combine_screen
    RTS
}

; Indexed setup stores use one displacement for every paired operand. Keep
; these assertions if the row body is rearranged: they prevent patching opcodes.
ASSERT swr_mask_address_read_2-swr_mask_address_read_1 = swr_sprite_address_read_2-swr_sprite_address_read_1
ASSERT swr_shift_table_sprite_2-swr_shift_table_sprite_1 = swr_sprite_address_read_2-swr_sprite_address_read_1
ASSERT swr_shift_table_mask_2-swr_shift_table_mask_1 = swr_sprite_address_read_2-swr_sprite_address_read_1
ASSERT ((swr_sprite_address_read_2-swr_sprite_address_read_1) AND &40) = 0


.swr_pixels_available_in_column SKIP 1

swr_erase_part_offset = swr_erase_mask_read_1-swr_mask_address_read_1
ASSERT swr_erase_part_offset > swr_sprite_address_read_2-swr_sprite_address_read_1
ASSERT swr_erase_part_offset+swr_sprite_address_read_2-swr_sprite_address_read_1 <= 255
ASSERT swr_erase_mask_read_2-swr_mask_address_read_2 = swr_erase_part_offset
ASSERT swr_erase_mask_shift_1-swr_shift_table_mask_1 = swr_erase_part_offset
ASSERT swr_erase_mask_shift_2-swr_shift_table_mask_2 = swr_erase_part_offset
