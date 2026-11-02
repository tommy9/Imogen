; IMOGEN's zero-page handoff loads this over the finished logo loader at &1200.
; OSFILE stages the whole SWBANK at &2000..&5FFF, below the screen at &6200.
; Finally OSFILE GAME from an eleven-byte zero-page trampoline, as IMOGEN does.
INCLUDE "build/engine_exports.asm"
INCLUDE "build/swr_boot_config.asm"
INCLUDE "build/swr_assets/bank_exports.asm"
ORG &1200
.boot_start
    CLD
    TSX: STX boot_stack
    LDA &F4: STA boot_old_bank
    LDA &0202: STA boot_old_brkv
    LDA &0203: STA boot_old_brkv+1
    PHP: SEI
    LDA #LO(boot_brk): STA &0202
    LDA #HI(boot_brk): STA &0203
    PLP
    LDA #1: STA boot_error
    ; Check length before writing any bank data.
    LDA #5
    LDX #LO(boot_file_block): LDY #HI(boot_file_block)
    JSR &FFDD
    CMP #1
    BEQ boot_file_found
    JMP boot_fail
.boot_file_found
    LDA #3: STA boot_error
    LDA boot_file_block+10
    ORA boot_file_block+12
    ORA boot_file_block+13
    BNE boot_fail_jump
    LDA boot_file_block+11
    CMP #&40
    BEQ boot_size_ok
.boot_fail_jump
    JMP boot_fail
.boot_size_ok
    LDA #2: STA boot_error
    LDA #swr_asset_bank: STA boot_selected_bank
    JSR boot_try_bank
    BCC boot_bank_found
IF swr_bank_auto
    LDA #15: STA boot_scan_bank
.boot_find_bank
    LDA boot_scan_bank
    CMP #swr_asset_bank
    BEQ boot_next_bank
    STA boot_selected_bank
    JSR boot_try_bank
    BCC boot_bank_found
.boot_next_bank
    DEC boot_scan_bank
    BPL boot_find_bank
ENDIF
    JMP boot_fail
.boot_bank_found
    JSR boot_restore_bank
    ; OSFILE uses the supplied main-RAM address when control-block byte 6 is zero.
    ; Clear its high address bytes too: the catalogue may contain &FFFF8000.
    LDY #6
    LDA #0
.boot_set_load_address
    STA boot_file_block,Y
    DEY
    CPY #1
    BNE boot_set_load_address
    LDA #&20: STA boot_file_block+3
    LDA #1: STA boot_error
    LDX #LO(boot_file_block): LDY #HI(boot_file_block)
    LDA #&FF
.boot_load_bank
    JSR &FFDD
    CMP #1
    BEQ boot_bank_loaded
    JMP boot_fail
.boot_bank_loaded
    LDA #4: STA boot_error
    LDA boot_selected_bank: JSR boot_write_bank
    LDA #0: STA &70: STA &72
    LDA #&80: STA &71
    LDA #&20: STA &73
    LDX #64: LDY #0
.boot_copy_page
    LDA (&72),Y
    STA (&70),Y
    CMP (&70),Y
    BEQ boot_byte_ok
    JMP boot_fail
.boot_byte_ok
    INY
    BNE boot_copy_page
    INC &71: INC &73
    DEX
    BNE boot_copy_page
.boot_copy_done
    ; Check format, configured slot and the generated image identity tag.
    ; This compares the stored CRC field only; no full-bank CRC is calculated.
    LDA #5: STA boot_error
    LDY #7
.boot_header_loop
    LDA &8010,Y
    CMP boot_expected_header,Y
    BEQ boot_match_1
    JMP boot_fail
.boot_match_1
    DEY
    BPL boot_header_loop
    LDA #5: STA boot_error
    LDY #3
.boot_identity_loop
    LDA &8034,Y
    CMP boot_expected_crc,Y
    BEQ boot_identity_next
    JMP boot_fail
.boot_identity_next
    DEY
    BPL boot_identity_loop
.boot_verified
    JSR boot_restore_bank
    JSR boot_restore_brkv
    ; GAME overwrites this bootstrap. The return code and control block remain outside the loaded engine.
    LDY #10
.boot_trampoline_loop
    LDA boot_trampoline,Y
    STA &00,Y
    DEY
    BPL boot_trampoline_loop
    LDA boot_selected_bank: STA &04 ; immediate operand after OSFILE returns
    LDA #LO(boot_game_name): STA &70
    LDA #HI(boot_game_name): STA &71
    LDA #&FF: STA &76
    LDX #&70: LDY #0
    JMP &0000
; Probe without committing any bank content. Every modified byte is restored.
; Reject ROM headers and incomplete address decoding before
; loading SWBANK. The independent address-line markers cover all 14 lines.
.boot_try_bank
    LDA boot_selected_bank: JSR boot_write_bank
    LDA &8006: AND #&C0
    BEQ boot_alias_probe
    LDY &8007
    LDA &8000,Y: BNE boot_alias_probe
    INY: LDA &8000,Y: CMP #'(': BNE boot_alias_probe
    INY: LDA &8000,Y: CMP #'C': BNE boot_alias_probe
    INY: LDA &8000,Y: CMP #')': BNE boot_alias_probe
    SEC: RTS
.boot_alias_probe
    ; Several BBC boards alias complete 16K sockets across ROMSEL numbers.
    ; Those views are safe: they share the ROM header and all bank contents.
    ; Probe only the selected window; empty other sockets may return open bus.
    LDA &BE00: STA boot_probe_saved
    LDA #&55: STA &BE00: CMP &BE00
    BNE boot_alias_failed
    LDA #&AA: STA &BE00: CMP &BE00
    BNE boot_alias_failed
    LDA boot_probe_saved: STA &BE00
    LDX #72
.boot_address_save
    JSR boot_probe_pointer
    LDA (&70),Y: STA boot_address_original,X
    DEX: BPL boot_address_save
    LDX #72
.boot_address_write
    JSR boot_probe_pointer
    TXA: EOR #&55: STA (&70),Y
    DEX: BPL boot_address_write
    LDA #0: STA boot_probe_result
    LDX #72
.boot_address_check
    JSR boot_probe_pointer
    TXA: EOR #&55: CMP (&70),Y
    BEQ boot_address_next
    INC boot_probe_result
.boot_address_next
    DEX: BPL boot_address_check
    LDX #72
.boot_address_restore
    JSR boot_probe_pointer
    LDA boot_address_original,X: STA (&70),Y
    DEX: BPL boot_address_restore
    LDA boot_probe_result
    BNE boot_probe_reject
    CLC: RTS
.boot_alias_failed
    LDA boot_probe_saved: STA &BE00
.boot_probe_reject
    SEC: RTS
.boot_probe_pointer
    LDA boot_probe_low,X: STA &70
    LDA boot_probe_high,X: STA &71
    LDY #0
    RTS
.boot_probe_low
    FOR page,0,63: EQUB 0: NEXT
    EQUB 1,2,4,8,16,32,64,128,255
.boot_probe_high
    FOR page,0,63: EQUB &80+page: NEXT
    FOR byte,0,8: EQUB &80: NEXT
.boot_probe_saved SKIP 1
.boot_address_original SKIP 73
.boot_probe_result SKIP 1
.boot_selected_bank SKIP 1
.boot_scan_bank SKIP 1
.boot_write_bank
    PHP: SEI
    STA &F4: STA &FE30
    PLP
    RTS
.boot_restore_bank
    LDA boot_old_bank
    JMP boot_write_bank
.boot_restore_brkv
    PHP: SEI
    LDA boot_old_brkv: STA &0202
    LDA boot_old_brkv+1: STA &0203
    PLP
    RTS
.boot_brk
    ; MOS file errors abandon its frames and our partial transfer.
    LDX boot_stack: TXS
    LDA #1: STA boot_error
.boot_fail
    JSR boot_restore_bank
    JSR boot_restore_brkv
    LDA #6: JSR &FFEE ; logo loader disabled text output
    LDA boot_error: ASL A: TAX
    LDA boot_messages,X: STA &70
    LDA boot_messages+1,X: STA &71
    LDY #0
.boot_print_error
    LDA (&70),Y
    BEQ boot_failure_stop
    JSR &FFEE
    INY
    BNE boot_print_error
.boot_failure_stop
    BRK
    EQUB &FF
    EQUS "SWR startup stopped"
    EQUB 0
.boot_messages
    EQUW boot_io_error,boot_io_error,boot_ram_error,boot_size_error,boot_readback_error,boot_slot_error
.boot_io_error EQUS 13,10,"SWR: Cannot read SWBANK",13,10,0
.boot_ram_error EQUS 13,10,"SWR: No free independent writable 16K RAM bank",13,10,0
.boot_size_error EQUS 13,10,"SWR: SWBANK must be 16384 bytes",13,10,0
.boot_readback_error EQUS 13,10,"SWR: Bank write/readback failed",13,10,0
.boot_slot_error EQUS 13,10,"SWR: Wrong SWBANK format, slot or image",13,10,0
.boot_expected_header EQUS "IMS2"
    EQUB 2,8,swr_asset_bank,1
.boot_expected_crc
INCLUDE "build/bootstrap/bootstrap_crc.asm"
.boot_trampoline JSR &FFDD
    LDA #0 ; patched to the verified slot; MOS uses &0BF1 during final load
    STA swr_live_bank_address
    JMP (&0076)
.boot_bank_name EQUS "SWBANK",13
.boot_game_name EQUS "GAME",13
.boot_file_block EQUW boot_bank_name
    SKIP 16
.boot_old_brkv SKIP 2
.boot_old_bank SKIP 1
.boot_stack SKIP 1
.boot_error SKIP 1
.boot_end
ASSERT boot_end <= &2000 ; whole-bank staging must not overwrite the bootstrap
SAVE "build/bootstrap/bootstrap", boot_start, boot_end
