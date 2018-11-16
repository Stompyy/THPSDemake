InitialiseTitleScreen:

    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    ; Write address 3F00 (Background palette) to the PPU
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    LDX #0
.LoadPalette_BackgroundLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #4
    BNE .LoadPalette_BackgroundLoop    
    
    ; PPUCTRL flag. Put PPU into skip 32 mode instead of 1
    LDA #%00000100
    STA PPUCTRL ; Have to restore back to previous values later
    
.InitialGeneration_LoopX:
    JSR GenerateTitleScreenColumn
    LDA generate_x
    CMP #63
    BCC .InitialGeneration_LoopX
    JSR GenerateTitleScreenColumn  ; #63 + 1

   ; CPY 

    RTS
;----------------------------------------

InitialiseGame:

    ; Seed the random number generator
    LDA #$12    ; Arbitary 1234 (non zero value)
    STA seed
    LDA #$34
    STA seed+1

    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    ; Write address 3F00 (Background palette) to the PPU
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR






    LDX #0

.LoadPalette_BackgroundLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #4
    BNE .LoadPalette_BackgroundLoop    





    ; Write address 3F10 (sprite palette) to the PPU next
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR
    
    LDX #4
.LoadPalette_SpriteLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #8
    BNE .LoadPalette_SpriteLoop   

    ; Load the player sprite
    LDX #0
.LoadSprite_Next:
    LDA sprites, X
    STA sprite_player, X
    INX
    CPX #24  ; Just one (8x8 * 6) sprite loading currently. NumSprites * 4
    BNE .LoadSprite_Next

    JSR LoadNewTrafficCone

    ; Load attribute data that each 16 x 16 uses
    LDA #$23        ; Write address $23C0 to PPUADDR register
    STA PPUADDR     ; PPUADDR is big endian for some reason??
    LDA #$C0
    STA PPUADDR

    LDA #%00000000  ; set all to first colour palette
    LDX #64
.LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes_Loop

    ; Load attribute data
    LDA #$27
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%00000000
    LDX #64
.LoadAttributes2_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes2_Loop

    LDA #1
    STA is_grounded
    STA is_title_screen

    
  ;  JSR DrawGameBackground

    JSR NewTitleScreenTime

    JMP background_skip



DrawGameBackground:    
     ; Generate initial level
.InitialGeneration_Loop:
    JSR GenerateColumn
    LDA generate_x
    CMP #63
    BCC .InitialGeneration_Loop
    JSR GenerateColumn  ; #63 + 1




   
background_skip:    


    LDA #%10000000  ; Enable NMI
    STA PPUCTRL

    LDA #%00011000  ; Enable sprites and background
    STA PPUMASK

    LDA #0
    STA PPUSCROLL   ; Set x scroll
    STA PPUSCROLL   ; Set y scroll

    RTS ; End subroutine (returns back to the point it was called)