; CLEAN MEMORY
; Fills every memory register with 0s
; basically resets the memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OPENING BOILERPLATE CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    processor 6502  ; define the processor
    seg code        ; segment of code
    org $F000       ; origin of the code in memory ($F000) - $ = hex (# = literal (decimal for nums), % = binary)

; Program start
Start:
    sei             ; disable interrupts
    cld             ; clear (disable) the binary-coded decimal (BCD) mode
    ldx #$FF        ; load the literal $FF into X
    txs             ; transfer the contents of X to S (the stack pointer register)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN PROGRAM
; Clear the Zero Page region ($FF to $00)
; (the entire TIA register space & RAM)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #0          ; A = 0
    ldx #$FF        ; X = $FF (initialise the loop)
    sta $FF         ; *($FF) = A (= 0) => prevents the off-by-one error (see the loop)

MemLoop:
    dex             ; x-- (might set the Z(ero) flag)
    sta $0,X        ; *(0 + X) = A (= 0)
    bne MemLoop     ; if A != 0, goto MemLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CLOSING BOILERPLATE CODE
; fill ROM to exactly 4KB
; The ROM must be filled to FFFF
; FFFC to FFFF should contain the address to go to whenever the program is reset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; reset vector at (~force goto) FFFC (where the system looks to reset the program)
    .word Start ; .word adds two bytes from the Start address (Start = memory position = 2 bytes)
    .word Start ; interrupt vector (necessary for the 6502) @ $FFFE (unused in the Atari VCS)