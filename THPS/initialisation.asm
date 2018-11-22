;----------------------------------------
;;;;;;;-------INITIALISATION------;;;;;;;
;----------------------------------------
InitialiseGame:
    ; Clear out the sprite data if returning from a reset
    LDA #0
    STA OAMADDR
    LDA #0
    STA OAMDMA

    ; Reset the PPU high/low latch
    LDA PPUSTATUS

;----------------------------------------
; Palettes
;----------------------------------------
    ; Write address 3F00 (Background palette) to the PPU
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    ; Load all the palettes into the background palette location
    LDX #0
.LoadPalette_BackgroundLoop:
    LDA background_palettes, X
    STA PPUDATA
    INX
    CPX #BACKGROUND_PALETTES_LENGTH
    BNE .LoadPalette_BackgroundLoop    

    ; Write address 3F10 (sprite palette) to the PPU next
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR
    ; Load all the palettes into the background palette location
    LDX #0
.LoadPalette_SpriteLoop:
    LDA sprite_palettes, X
    STA PPUDATA
    INX
    CPX #SPRITE_PALETTES_LENGTH
    BNE .LoadPalette_SpriteLoop   

;----------------------------------------
; Sprites
;----------------------------------------
    ; Load in the text blanking white rect that is used to make text flash
    JSR LoadWhiteTextBlockingBox

    ; Copy sprite data to the PPU
    ; Just for the white box currently
    LDA #0
    STA OAMADDR
    LDA #$02    ; Location of the sprites In memory
    STA OAMDMA

;----------------------------------------
; Attribute data tables
;----------------------------------------
    ; Load attribute data that each 16 x 16 uses
    LDA #$23        ; First nametable attribute table
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%00000000  ; set all to first colour palette
    LDX #64
.LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes_Loop

    LDA #$27        ; Second nametable attribute table
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%00000000  ; set all to first colour palette
    LDX #64
.LoadAttributes2_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes2_Loop

;----------------------------------------
; Bools
;----------------------------------------
    ; The default starting state for the player
    LDA #TRUE
    STA is_grounded
    
;----------------------------------------
; State machine
;----------------------------------------
    ; Initalise state machine to the title screen
    LDA #GAMESTATE_TITLE
    STA gameStateMachine

;----------------------------------------
; Backgrounds
;----------------------------------------
    ; Load in the first two backgrounds
    JSR LoadTitleScreen 
    
    ; Enable sprites and background
    LDA #%00011000  
    STA PPUMASK

    ; Before rendering, set the scrolls to zero
    LDA #0
    STA PPUSCROLL   ; Set x scroll
    STA PPUSCROLL   ; Set y scroll

    RTS