; Engine-facing adapter. Include bank_exports.asm before this module.
; Bank must already be loaded and verified by the bootstrap.
; Callers set owner for each copy/restore. Exit consumes it (&FF = no owner).
; Namespace 0 = common/active level, 1 = icons. Level table is an absolute word.
; Live game keeps the asset bank selected. Isolated module retains caller-bank ABI.
swr_owner = &0BED
swr_namespace = &0BEE
swr_level_table = &0BEF
swr_saved_bank = &0BF1
IF swr_runtime_live
.swr_runtime_bank EQUB swr_asset_bank ; patched by the final GAME handoff
ENDIF
swr_canonical_id = &0BF2
swr_kind = &0BF3
swr_descriptor = &0BF4
swr_header = &0BF5
swr_status = &0BFD
swr_used = &0BFE

; Status: 0 success/empty; 1 invalid ID; 2 no owner; 3 non-cache destination;
; 4 insufficient capacity; 5 stale/mismatched restore; 6 unknown viewport.
.swr_select_bank
IF swr_runtime_live
    LDA swr_runtime_bank
    CMP &F4
    BNE swr_write_bank
.swr_bank_selected
    RTS
ELSE
    LDA &F4
    STA swr_saved_bank
    LDA #swr_asset_bank
ENDIF
.swr_write_bank
    PHP
    SEI
    STA &F4
    STA &FE30
    PLP
    RTS
.swr_return_bank
IF swr_runtime_live
    RTS
ELSE
    LDA swr_saved_bank
    JMP swr_write_bank
ENDIF

; A = ID. Returns class/canonical ID and record pointer in the original lookup workspace &58/59.
; Invalid IDs cannot dereference an index. Globals 197..199 are runtime caches.
.swr_resolve
{
    STA swr_canonical_id
    CMP #197
    BCC ordinary
    CMP #200
    BCS level
    LDA #2
    STA swr_kind
    RTS
    .ordinary
    LDX swr_namespace
    BNE icons
    CMP #swr_common_count
    BCS invalid
    TAX
    LDA #LO(swr_common_kinds): STA swr_packed_kind_read+1
    LDA swr_common_canonical_ids,X
    STA swr_canonical_id
    LDA #LO(swr_common_table): STA &58
    LDA #HI(swr_common_table): STA &59
    JMP record
    .icons
    CMP #0
    BEQ invalid ; metadata uses the public lookup entry, never drawing
    SEC
    SBC #swr_icon_first_id
    CMP #swr_icon_count
    BCS invalid
    TAX
    LDA #LO(swr_icon_kinds): STA swr_packed_kind_read+1
    LDA swr_icon_canonical_ids,X
    STA swr_canonical_id
    LDA #LO(swr_icon_table): STA &58
    LDA #HI(swr_icon_table): STA &59
    .record
    TXA: PHA
    JSR swr_read_packed_kind
    PLA: TAX
    TXA: ASL A: TAY
    LDA (&58),Y: TAX
    INY
    LDA (&58),Y: STA &59
    STX &58
    RTS
    .invalid
    LDA #1: STA swr_status
    LDA #0: STA swr_kind
    RTS
    .level
    SEC
    SBC #200
    STA &86
    LDA swr_level_table: STA &58
    LDA swr_level_table+1: STA &59
    ORA &58
    BEQ invalid
    ; Count is at table-2, reached without relying on low-byte alignment.
    LDA &58
    SEC
    SBC #2
    STA &58
    BCS count_ready
    DEC &59
    .count_ready
    LDY #0
    LDA (&58),Y
    CMP &86
    BEQ invalid
    BCC invalid
    STA &87
    LDA &58
    CLC
    ADC #2
    STA &58
    BCC table_ready
    INC &59
    .table_ready
    ; kinds follow 2*count index bytes; canonical IDs follow the kinds.
    LDA &87: ASL A
    CLC: ADC &86: TAY
    LDA (&58),Y: STA swr_kind
    TYA: CLC: ADC &87: TAY
    LDA (&58),Y: STA swr_canonical_id
    LDA &86: ASL A: TAY
    LDA (&58),Y: TAX
    INY
    LDA (&58),Y: STA &59
    STX &58
    RTS
}
.swr_read_header
{
    LDY #7
    .loop
    LDA (&58),Y
    STA swr_header,Y
    DEY
    BPL loop
    RTS
}
; Live collision lookup returns native record/metadata pointers in YX; valid
; headers are not copied. Bank remains selected across reads and game IRQs.
; Cache/invalid IDs return an immutable zero header in main RAM.
; The isolated module retains its stable copied-header, caller-bank interface.
.swr_get_address_of_sprite_a
{
    PHA
    JSR swr_select_bank
    PLA
    LDX #0: STX swr_status
    CMP #0
    BNE sprite
    LDX swr_namespace
    BEQ sprite
IF swr_runtime_live
    LDX #LO(swr_metadata)
    LDY #HI(swr_metadata)
    RTS
ELSE
    LDY #17
    .metadata_loop
    LDA swr_metadata,Y
    STA swr_metadata_view,Y
    DEY
    BPL metadata_loop
    JSR swr_return_bank
    LDX #LO(swr_metadata_view)
    LDY #HI(swr_metadata_view)
    RTS
ENDIF
    .sprite
    JSR swr_resolve
    LDA swr_kind
    CMP #1
    BNE zero_header
IF swr_runtime_live
    LDX &58
    LDY &59
    RTS
    .zero_header
    LDX #LO(swr_zero_header)
    LDY #HI(swr_zero_header)
    RTS
ELSE
    JSR swr_read_header
    JMP return
    .zero_header
    LDA #0: LDY #7
    .zero_loop
    STA swr_header,Y
    DEY
    BPL zero_loop
    .return
    JSR swr_return_bank
    LDX #LO(swr_header)
    LDY #HI(swr_header)
    RTS
ENDIF
}
IF swr_runtime_live
.swr_zero_header EQUB 0,0,0,0,0,0,0,0
ELSE
.swr_metadata_view SKIP 18
ENDIF

; X may be an arbitrary cell coordinate: owner must be supplied explicitly.
.swr_owner_descriptor
    LDX swr_owner
    CPX #11
    BCS swr_no_owner
    TXA: ASL A: ASL A: STA &86
    ASL A: ASL A: CLC: ADC &86: TAY
    STY swr_descriptor
    CLC
    RTS
.swr_no_owner
    LDA #2: STA swr_status
    SEC
    RTS

; Call before screen/room rebuild, asset-bank replacement or cache reallocation.
; Preserves registers. Storage/capacities are installed by the level loader.
.swr_invalidate_caches
    PHA: TXA: PHA
    LDX #200
.swr_invalidate_loop
    LDA #0
    STA swr_cache_registry+2,X
    TXA: SEC: SBC #20: TAX
    BCS swr_invalidate_loop
    PLA: TAX: PLA
    RTS

IF swr_runtime_live
.sprite_op
ENDIF
.swr_sprite_op
{
    PHA: TXA: PHA: TYA: PHA
    JSR swr_select_bank
    LDA #0: STA swr_status
    ; Every replacement retires the previous capture, even if lookup fails.
    LDA &15: AND #1
    BEQ no_replacement
    JSR swr_owner_descriptor
    BCC replacement_owner
    JMP exit
    .replacement_owner
    LDA #0: STA swr_cache_registry+2,Y
    STA swr_cache_registry+18,Y
    STA swr_cache_registry+19,Y
    .no_replacement
    LDA &4C
    CMP #&58
    BEQ toolbar
    CMP #&62
    BEQ game
    LDA #6: STA swr_status
    JMP exit
    .toolbar
    LDA #24: STA swr_viewport_first
    LDA #64
    BNE viewport_ready
    .game
    LDA #0: STA swr_viewport_first
    LDA #192
    .viewport_ready
    STA swr_viewport_end
IF swr_runtime_live
    ; Toolbar IDs 2..9 are icons; other IDs remain common/active-level assets.
    LDA #0: STA swr_namespace
    LDA &4C: CMP #&58
    BNE common_namespace
    LDA &16: CMP #10
    BCS common_namespace
    CMP #2
    BCC common_namespace
    LDA #1: STA swr_namespace
    .common_namespace
ENDIF
    LDA &16
    JSR swr_resolve
    LDA swr_kind
    CMP #2
    BNE source
    JMP restore
    .source
    CMP #1
    BEQ drawable
    JMP exit
    .drawable
    JSR swr_read_header
    ; Copy has priority, then foreground, then background.
    LDA &15
    AND #1
    BNE mode_ready
    LDA &15
    AND #4
    BNE mode_ready
    LDA &15
    AND #2
    .mode_ready
    STA &15
    ; Signed header offsets. Build final left/bottom once.
    LDA swr_header
    LDX #0
    CMP #&80
    BCC sx_ready
    DEX
    .sx_ready
    BIT &1D
    BMI reflected
    CLC
    ADC &18
    STA &74
    TXA: ADC &19: STA &75
    JMP y_coordinate
    .reflected
    STA &86
    LDA &18: SEC: SBC &86: STA &74
    TXA: EOR #&FF: ADC &19: STA &75 ; complement + carry = signed subtraction
    LDA &74: SEC: SBC swr_header+2: STA &74
    LDA &75: SBC #0: STA &75
    .y_coordinate
    LDA swr_header+1
    LDX #0
    CMP #&80
    BCC sy_ready
    DEX
    .sy_ready
    CLC: ADC &1A: STA &76
    TXA: ADC &1B: STA &77
    LDA swr_header+2: STA &78
    LDA swr_header+3: STA &79
    JSR swr_clip_sprite_bounds
    ; Copy needs its destination classified even for an empty capture.
    PHP
    LDA &15
    CMP #1
    BEQ capture
    PLP
    BCS exit_jump
    JMP draw
    .exit_jump
    JMP exit
    .capture
    ; Owner was validated and the old capture retired before source lookup.
    LDA &14
    JSR swr_resolve
    LDA swr_kind
    CMP #2
    BEQ destination_ready
    PLP
    LDA #3: STA swr_status
    JMP exit
    .destination_ready
    LDY swr_descriptor
    LDA swr_canonical_id: STA swr_cache_registry,Y
    LDA swr_owner: STA swr_cache_registry+1,Y
    PLP
    BCC visible_capture
    LDA #2: STA swr_cache_registry+2,Y
    JMP exit
    .visible_capture
    ; Exact clipped capacity: ceil((phase+visible_width)/8)*visible_height.
    LDA swr_visible_width
    LSR A: LSR A: LSR A
    STA &86
    LDA swr_visible_width: AND #7: STA &87
    LDA swr_clipped_x_low: AND #7
    CLC: ADC &87: ADC #7
    LSR A: LSR A: LSR A
    CLC: ADC &86: TAX
    LDA #0: STA swr_used: STA swr_used+1
    .multiply
    LDA swr_used: CLC: ADC swr_visible_height: STA swr_used
    BCC no_carry
    INC swr_used+1
    .no_carry
    DEX
    BNE multiply
    LDY swr_descriptor
    LDA swr_used+1
    CMP swr_cache_registry+17,Y
    BCC capacity_ready
    BNE insufficient
    LDA swr_used
    CMP swr_cache_registry+16,Y
    BCC capacity_ready
    BEQ capacity_ready
    .insufficient
    LDA #4: STA swr_status
    JMP exit
    .capacity_ready
    JSR swr_check_storage
    BCC storage_checked
    JMP exit
    .storage_checked
    LDX #0
    .save_geometry
    LDA &74,X
    STA swr_cache_registry+4,Y
    INY
    INX
    CPX #6
    BNE save_geometry
    LDY swr_descriptor
    LDA &4C: STA swr_cache_registry+10,Y
    LDA swr_viewport_first: STA swr_cache_registry+11,Y
    LDA swr_used: STA swr_cache_registry+18,Y
    LDA swr_used+1: STA swr_cache_registry+19,Y
    JSR swr_load_planes
    .draw
    LDA swr_header+4: STA &80
    LDA swr_header+5: STA &81
    LDA swr_header+6: STA &70
    LDA swr_header+7: STA &71
    JSR swr_draw_prepared
    LDA &15
    CMP #1
    BNE exit
    LDY swr_descriptor
    LDA #1: STA swr_cache_registry+2,Y
    JMP exit
    .restore
    ; Colour requests on cache IDs cannot replay arbitrary old saved pixels.
    LDA &15
    BNE exit
    JSR swr_owner_descriptor
    BCS exit
    LDA swr_cache_registry,Y
    CMP swr_canonical_id
    BNE stale
    LDA swr_cache_registry+2,Y
    CMP #2
    BEQ retire
    CMP #1
    BNE stale
    LDA swr_cache_registry+10,Y
    CMP &4C
    BNE stale
    JSR swr_check_storage
    BCS exit
    LDX #0
    .load_geometry
    LDA swr_cache_registry+4,Y
    STA &74,X
    INY: INX
    CPX #6
    BNE load_geometry
    LDY swr_descriptor
    JSR swr_load_planes
    JSR swr_restore_sprite_background
    .retire
    LDY swr_descriptor
    LDA #0: STA swr_cache_registry+2,Y
    BEQ exit
    .stale
    LDA #5: STA swr_status
    .exit
IF swr_runtime_live = 0
    JSR swr_return_bank
ENDIF
    LDA #0: STA &15
    LDA #1: STA &1D
    LDA #&FF: STA swr_owner
IF swr_runtime_live
    LDA #0: STA swr_namespace
ENDIF
    PLA: TAY: PLA: TAX: PLA
    RTS
}
.swr_load_planes
    LDA swr_cache_registry+12,Y: STA &7E
    LDA swr_cache_registry+13,Y: STA &7F
    LDA swr_cache_registry+14,Y: STA &82
    LDA swr_cache_registry+15,Y: STA &83
    RTS

; Both saved planes are in main RAM or in the one selected asset bank.
.swr_check_storage
    LDA swr_cache_registry+3,Y
    CMP #&FF
    BEQ swr_storage_ready
IF swr_runtime_live
    CMP swr_runtime_bank
ELSE
    CMP #swr_asset_bank
ENDIF
    BEQ swr_storage_ready
    LDA #5: STA swr_status
    SEC
    RTS
.swr_storage_ready
    CLC
    RTS

ASSERT swr_cache_registry + swr_cache_descriptor_bytes * swr_cache_registry_entries = swr_owner
ASSERT swr_header + 8 = swr_status
ASSERT swr_used + 2 = &0C00

; Common/icon class arrays share the header page; only the low operand changes.
.swr_read_packed_kind
    TXA: LSR A: LSR A: TAY
    TXA: AND #3: TAX
.swr_packed_kind_read
    LDA swr_common_kinds,Y
    CPX #0
    BEQ swr_kind_ready
.swr_kind_shift
    LSR A: LSR A
    DEX
    BNE swr_kind_shift
.swr_kind_ready
    AND #3
    STA swr_kind
    RTS
ASSERT HI(swr_common_kinds) = HI(swr_icon_kinds)
