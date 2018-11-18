NewTitleScreenTime:
;; 32 x 30
    LDA #%00010000  ; Look at second sprite sheet
    STA PPUCTRL
    
    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    ; Fill the first row with 0
    LDX #0
    LDA #0
.FillFirstRows:
    STA PPUDATA
    INX
    CPX #128
    BNE .FillFirstRows


    ; Main loop
Title_NextRow:

    ; Load 8 tiles of blank first
    LDX #0
    LDA #0
.FillLeftBlank:
    STA PPUDATA
    INX
    CPX #8
    BNE .FillLeftBlank

    ; Work out the target tile count for this row (current + 16)
    LDA title_screen_load_counter
    CLC
    ADC #16
    STA title_screen_load_target

    ; from the current to the target, load into PPUDATA
    LDX title_screen_load_counter
.loadNext_Loop:
    STX PPUDATA
    INX
    CPX title_screen_load_target
    BNE .loadNext_Loop

    STX title_screen_load_counter
    LDX #0
    LDA #0
.FillRightBlank:
    STA PPUDATA
    INX
    CPX #8
    BNE .FillRightBlank

    LDY title_screen_load_current_Y
    INY
    STY title_screen_load_current_Y
    CPY #16
    BNE Title_NextRow
    LDA #%10010000
    STA PPUCTRL

    LDX #0
    LDA #0
.FillLastRows:
    STA PPUDATA
    INX
    CPX #128
    BNE .FillLastRows

    LDX #0
    LDA #0
.FillLastRows1:
    STA PPUDATA
    INX
    CPX #128
    BNE .FillLastRows1

    LDX #0
    LDA #0
.FillLastRows2:
    STA PPUDATA
    INX
    CPX #32
    BNE .FillLastRows2

    JSR LoadInControls

    RTS


Show_TitleScreen:
    JSR NewTitleScreenTime
    RTI

Show_Controls:
    JSR LoadInControls
    RTI

LoadInControls:
;; 32 x 30
    LDA #%00000000  ; Look at first sprite sheet
    STA PPUCTRL

    
    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    LDA #$24
    STA PPUADDR
    LDA #$00
    STA PPUADDR
       ; Fill the first row with empty block
    LDX #0
    ; reset vars
    STX title_screen_load_counter
    STX title_screen_load_current_Y
    LDA #$E0
.Controls_FillFirstRow:
    STA PPUDATA
    INX
    CPX #128
    BNE .Controls_FillFirstRow


    ; Main loop
Controls_NextRow:

    ; Load 8 tiles of blank first
    LDX #0
    LDA #$E0
.FillLeftBlank:
    STA PPUDATA
    INX
    CPX #8
    BNE .FillLeftBlank

    ; Work out the target tile count for this row (current + 16)
    LDA title_screen_load_counter
    CLC
    ADC #16
    STA title_screen_load_target

    ; from the current to the target, load into PPUDATA
    LDX title_screen_load_counter
.loadNext_Loop: 
    LDA controls, X
    STA PPUDATA
    INX
    CPX title_screen_load_target
    BNE .loadNext_Loop

    STX title_screen_load_counter
    LDX #0
    LDA #$E0
.FillRightBlank:
    STA PPUDATA
    INX
    CPX #8
    BNE .FillRightBlank

    LDY title_screen_load_current_Y
    INY
    STY title_screen_load_current_Y
    CPY #16
    BNE Controls_NextRow

    LDX #0
.FillUnderStillframesShowcase:
    LDA stillframes_showcase, X
    STA PPUDATA
    INX
    CPX #192
    BNE .FillUnderStillframesShowcase

    LDX #0
    LDA #$E0
.FillOutLastSection:
    STA PPUDATA
    INX
    CPX #128
    BNE .FillOutLastSection

    LDA #GAMESTATE_CONTROLS
    STA gameStateMachine

    ; Set PPUCTRL register
    LDA scroll_page
    ORA #%10000000
    STA PPUCTRL
    
    RTS


controls: ; Whole image is 16 wide x 14 high = 224
    ; Title
    .db $E0, $E0, $E0, $E0, $E0, $E0, $6A, $6B, $6C, $6D, $E0, $E0, $E0, $E0, $E0, $E0
    .db $E0, $E0, $E0, $E0, $E0, $6E, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    ; On ground                                      In air
    .db $E0, $7A, $7B, $7C, $7D, $7E, $7F, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    .db $E0, $8A, $8B, $8C, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    .db $E0, $9A, $9B, $9C, $9D, $9E, $9F, $E0, $E0, $BA, $BB, $BC, $E0, $E0, $E0, $E0
    .db $E0, $AA, $AB, $AC, $AD, $AE, $AF, $E0, $E0, $CA, $CB, $CC, $CD, $CE, $CF, $E0
    .db $E0, $C0, $C1, $C2, $E0, $E0, $E0, $E0, $E0, $DA, $DB, $DC, $DD, $DE, $DF, $E0
    .db $E0, $D0, $D1, $D2, $D3, $E0, $E0, $E0, $E0, $EA, $EB, $EC, $ED, $EE, $EF, $E0
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $C0, $E1, $E2, $E3, $E0, $E0, $E0
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $D0, $8D, $8E, $8F, $E0, $E0, $E0
    
    ; Grinds
    .db $E0, $E0, $E0, $E0, $BD, $BE, $BF, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $C4, $C5, $C6, $C7, $C8, $C9, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $D4, $D5, $D6, $D7, $D8, $D9, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E4, $E5, $E6, $E7, $E8, $E9, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0 
stillframes_showcase:    
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $04, $05, $E0, $04, $05, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $06, $07, $08, $09, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $04, $05, $E0, $14, $15, $E0, $14, $15, $E0, $66, $67, $E0, $60, $61, $E0, $16, $17, $18, $19, $0A, $0B, $E0, $E0, $E0 
    .db $E0, $E0, $00, $01, $E0, $02, $03, $E0, $14, $15, $E0, $44, $45, $E0, $54, $55, $E0, $76, $77, $E0, $70, $71, $E0, $36, $37, $46, $47, $1A, $1B, $0C, $0D, $E0 
    .db $E0, $E0, $10, $11, $E0, $12, $13, $E0, $34, $35, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $86, $87, $E0, $80, $81, $E0, $E0, $E0, $E0, $E0, $56, $57, $1C, $1D, $E0 
    .db $E0, $E0, $20, $21, $E0, $22, $23, $E0, $E0, $E0, $E0, $E0, $E0, $F1, $E0, $E0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $E0, $E0, $E0, $E0, $E0, $E0, $2C, $2D, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0