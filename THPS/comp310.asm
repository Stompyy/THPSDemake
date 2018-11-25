    .inesprg 1   ; 1 x bank of 16KB PRG code
    .ineschr 1   ; 1 x bank of 8KB CHR data
    .inesmap 0   ; mapper 0 = NROM, no bank swapping
    .inesmir 1   ; background mirroring
    
    .bank 0
    .org $C000
;------------------------------------------
; Files to include
    INCLUDE "animationDatabase.asm"
    INCLUDE "spriteDatabase.asm"
    INCLUDE "controlScreenBackgroundDatabase.asm"

    INCLUDE "palettes.asm"

    INCLUDE "macros.asm"
    INCLUDE "subroutines.asm"
    INCLUDE "variables.asm"
    INCLUDE "stateMachine.asm"

    INCLUDE "titleScreen.asm"
    INCLUDE "controls.asm"
    INCLUDE "initialisation.asm"
    INCLUDE "animation.asm"
    INCLUDE "NMI.asm"
    INCLUDE "marchingSquares.asm"
;------------------------------------------
; 2270 CPU cycles per frame

RESET:
    SEI             ; disable (ignore) IRQs
    CLD             ; disable decimal mode
    LDX #$40
    STX $4017       ; disable APU frame IRQ
    LDX #$FF
    TXS             ; Set up stack
    INX             ; now X = 0
    STX PPUCTRL     ; disable NMI
    STX PPUMASK     ; disable rendering
    STX $4010       ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; If the user presses Reset during vblank, the PPU may reset
    ; with the vblank flag still true. This has about a 1 in 13
    ; chance of happening on NTSC or  2 in 9 on PAL. Clear the
    ; flag now so the vblankwait1 loop sees an actual vblank.
    BIT PPUSTATUS

vblankwait1:       ; First wait for vblank to make sure PPU is ready
    BIT PPUSTATUS
    BPL vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS. Conveniently, X is still 0.
    TXA

clrmem:
    LDA #$0
    STA $000, x
    STA $100, x
    STA $300, x
    STA $400, x
    STA $500, x
    STA $600, x
    STA $700, x   ; Remove this if you are storing reset-persistant data

    ; We skipped $200, x on purpose. Usually RAM page 2 is used for the
    ; display list to be copied to OAM. OAM needs to be initialised to
    ; $EF-$FF, not 0, or you'll get a bunch of garbage playerSprites at (0, 0).

    LDA #$FF
    STA $200, x     ; Reserved for the playerSprites

    INX
    BNE clrmem
  
    ; Other things you can do between vblank waits are set up audio 
    ; or set up other mapper registers.

vblankwait2:        ; Second wait for vblank, PPU is ready after this
    BIT PPUSTATUS
    BPL vblankwait2

    JSR InitialiseGame

; Enter an infinite loop
Forever:
    JMP Forever     ; Jump back to Forever, infinite loop
;----------------------------------------
    .bank 1
    .org $FFFA      ; First of the three vectors starts here
    .dw NMI         ; When an NMI happens (once per frame if enabled) the processor will jump to the label NMI:
    .dw RESET       ; When the processor first turns on or is reset, it will jump to the label RESET:
    .dw 0           ; (Audio) External interrupt IRQ is not used in this tutorial
;----------------------------------------
    .bank 2
    .org $0000
    .incbin "SpriteSheet/THPS.chr"