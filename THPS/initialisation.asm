
InitialiseGame:

    ; Clear out the sprite data if returning from a reset
    LDA #0
    STA OAMADDR
    LDA #$0
    STA OAMDMA

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

    LDX #0      ; Temp moved to blue palette

.LoadPalette_BackgroundLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #16
    BNE .LoadPalette_BackgroundLoop    





    ; Write address 3F10 (sprite palette) to the PPU next
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR
    
    LDX #0
.LoadPalette_SpriteLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #12
    BNE .LoadPalette_SpriteLoop   

;     ; Load the player sprite
;     LDX #0
; .LoadPlayerSprite_Next:
;     LDA playerSpritesDB, X
;     STA sprite_player, X
;     INX
;     CPX #24  ; Just one (8x8 * 6) sprite loading currently. NumSprites * 4
;     BNE .LoadPlayerSprite_Next

    ; Load in the text blanking white rect that is used to make text flash
    LDX #0
.LoadBlankSprite_Next:
    LDA whiteBlankBoxDB, X
    STA sprite_text_blanking_box_white, X
    INX
    CPX #20
    BNE .LoadBlankSprite_Next

    ; Copy sprite data to the PPU
    LDA #0
    STA OAMADDR
    LDA #$02    ; Location of the sprite? In memory
    STA OAMDMA

    JSR LoadNewTrafficCone
 ;   JSR LoadNewLedge

    ; Load attribute data that each 16 x 16 uses
    LDA #$23        ; Write address $23C0 to PPUADDR register
    STA PPUADDR     ; PPUADDR is big endian for some reason??
    LDA #$C0
    STA PPUADDR

    LDA #%00000000  ; set all (attribute table?) to first colour palette
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

    ; Set the true bools
    LDA #TRUE
    STA is_grounded
    STA is_title_screen
    STA should_generate_game_background

    JSR NewTitleScreenTime

    JMP background_skip



   
background_skip:    
    
    ; Initalise state machine to the title screen
    LDA #GAMESTATE_TITLE
    STA gameStateMachine
    

    LDA #%10000000  ; Enable NMI
    STA PPUCTRL

    LDA #%00011000  ; Enable sprites and background
    STA PPUMASK

    LDA #0
    STA PPUSCROLL   ; Set x scroll
    STA PPUSCROLL   ; Set y scroll

    RTS ; End subroutine (returns back to the point it was called)

NextBGRow:
    ; Check if should load empty or floor
    LDA generate_game_background_row_counter
    CMP #4
    BEQ LoadFloorRow

    ; Load empty
    LDX #0
    LDA #$E0
LoadEmptyRow:
    STA PPUDATA
    INX
    CPX #20
    BNE LoadEmptyRow
    LDX generate_game_background_row_counter
    INX
    STX generate_game_background_row_counter
    JMP NextBGRow

    ; Load floor
LoadFloorRow:
    LDX #0
    LDA #$F0
.LoadFloorRow_Loop:
    STA PPUDATA
    INX
    CPX #32
    BNE .LoadFloorRow_Loop
    LDX generate_game_background_row_counter
    INX
    CPX #20
    BEQ StopGenerating
    STX generate_game_background_row_counter
    JMP LoadFloorRow

StopGenerating:
    LDA #FALSE
    STA should_generate_game_background
  ;  LDA #%1000000
  ;  STA PPUCTRL
    ;RTS
    JMP NMI_ShowTitleScreen
