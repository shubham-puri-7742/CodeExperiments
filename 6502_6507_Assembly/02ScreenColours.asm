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
    ; CLEAN_START     ; cleans the memory. Uncomment to see an infinite loop in action

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN PROGRAM
; Display a yellow background
; Colours ref: https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #$fe        ; load the colour into A (fe = NTSC yellow colour)
    sta COLUBK      ; store the colour (from A) into the background colour register ($09)

    jmp Start       ; goto Start - uncomment to see the infinite loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CLOSING BOILERPLATE CODE
; fill ROM to exactly 4KB
; The ROM must be filled to FFFF
; FFFC to FFFF should contain the address to go to whenever the program is reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; reset vector at (~force goto) FFFC (where the system looks to reset the program)
    .word Start ; .word adds two bytes from the Start address (Start = memory position = 2 bytes)
    .word Start ; interrupt vector (necessary for the 6502) @ $FFFE (unused in the Atari VCS)