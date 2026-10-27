; Player-group alignment. Called after sorting, before any erase.
; Align every group containing the body (owner 0) or accessory/tail (owner 1).
; They need not overlap, and the tail can animate while the body is unchanged.
; A/X may change; Y is untouched. IRQs, object state and painter order are unchanged.
.swr_align_player_group
    ldx num_active_objects
.swr_find_player_in_group
    dex
    bmi swr_frame_alignment_exit
    lda frontmost_objects_table,x
    cmp #2
    bcs swr_find_player_in_group
; Don't extend an update already approaching its five-VSYNC pacing threshold.
    lda vsync_counter
    cmp #4
    bcs swr_frame_alignment_exit
; T2 is reset by the existing VSYNC IRQ. Wait for a two-high-byte window.
; If we have missed it, the next VSYNC resets T2 and opens another window.
.swr_wait_for_frame_phase
    lda system_via_t2c_h
    cmp #swr_frame_alignment_phase + 2
    bcs swr_wait_for_frame_phase
    cmp #swr_frame_alignment_phase
    bcc swr_wait_for_frame_phase
.swr_frame_alignment_exit
    rts
