; CLEAN MEMORY
; Fills every memory register with 0s
; basically resets the memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OPENING BOILERPLATE CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    processor 6502  ; define the processor

    ; includes
    include "vcs.h"
    include "macro.h"

    seg code        ; segment of code
    org $F000       ; origin of the code in memory ($F000) - $ = hex (# = literal (decimal for nums), % = binary)

; Program start
Start:
    CLEAN_START     ; cleans the memory. Uncomment to see an infinite loop in action

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN PROGRAM
; Display a rainbow(ish) pattern on the screen
; Colours ref: https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NextFrame:
    lda #2      ; %00000010 (the corresponding bit activates VSYNC and VBLANK - see bwlow)
    sta VBLANK  ; activate VBLANK
    sta VSYNC   ; activate VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3 VSYNC lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    sta WSYNC   ; scanline 1
    sta WSYNC   ; scanline 2
    sta WSYNC   ; scanline 3

    lda #0      ; 0 => for disabling VSYNC
    sta VSYNC   ; turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 37 VBLANK lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #37     ; counter for 37 scanlines

VBlankLoop:
    sta WSYNC       ; hit WSYNC and wait for the next scanline
    dex             ; x--
    bne VBlankLoop  ; if x != 0, goto VBlankLoop

    lda #0      ; 0 => for disabling VBLANK
    sta VBLANK  ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 VISIBLE SCANLINES (kernel)
; The real stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #192

KernelLoop:
    stx COLUBK      ; BGColour = x (surprisingly beautiful); most of the colour palette really
    sta WSYNC       ; hit WSYNC and wait for the next scanline
    dex             ; x--
    bne KernelLoop  ; if x != 0, goto KernelLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 30 OVERSCAN lines 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #29     ; %00000010 to activate VBLANK
    sta VBLANK  ; activate VBLANK

    ldx #30     ; counter for 30 scanlines

OverscanLoop:
    sta WSYNC       ; hit WSYNC and wait for the next scanline
    dex             ; x--
    bne OverscanLoop; if x != 0, goto VBlankLoop

    jmp NextFrame   ; goto NextFrame (basically a rendering loop)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CLOSING BOILERPLATE CODE
; fill ROM to exactly 4KB
; The ROM must be filled to FFFF
; FFFC to FFFF should contain the address to go to whenever the program is reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; reset vector at (~force goto) FFFC (where the system looks to reset the program)
    .word Start ; .word adds two bytes from the Start address (Start = memory position = 2 bytes)
    .word Start ; interrupt vector (necessary for the 6502) @ $FFFE (unused in the Atari VCS)