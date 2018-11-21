;----------------------------------------
;;;;;;;-------TITLE-SCREENS-------;;;;;;;
;----------------------------------------
LoadTitleScreen:
    LDA #%00010000          ; Look at second sprite sheet
    STA PPUCTRL
    LDA PPUSTATUS           ; Reset the PPU high/low latch
    LDA #$20                ; Set the PPUADDR to load into the first nametable
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    
    LDX #0                  ; Fill the first 4 rows with blank tiles
    LDA #0
.FillFirstRows:
    STA PPUDATA
    INX
    CPX #NUMBER_OF_TILES_PER_ROW * 4
    BNE .FillFirstRows

; For each subsequent row, load 8 blank tiles + 16 from the database, then 8 final blank tiles (=32)
; This will fit the 32 tile wide display, and centre the title screen image
Title_NextRow:
    LDX #0
    LDA #0
.FillLeftBlank:             ; Load 8 tiles of blank first
    STA PPUDATA
    INX
    CPX #ENVELOPE_WIDTH
    BNE .FillLeftBlank

    ; Calculate the target tile count for this row (current + 16)
    LDA background_load_counter
    CLC
    ADC #IMAGE_WIDTH
    STA background_load_target

    ; from the current to the target, load into PPUDATA
    LDX background_load_counter
.loadNext_Loop:
    STX PPUDATA
    INX
    CPX background_load_target
    BNE .loadNext_Loop

    STX background_load_counter     ; Update the counter for the next row

    LDX #0
    LDA #0
.FillRightBlank:                    ; Load the final 8 tiles of blank
    STA PPUDATA
    INX
    CPX #ENVELOPE_WIDTH
    BNE .FillRightBlank

    INC background_load_current_Y   ; Increment the row counter.

    ; Check to see if we have loaded all 16 rows of the title screen image database
    LDY background_load_current_Y
    CPY #IMAGE_WIDTH
    BNE Title_NextRow               ; Else Load in another row

    ; Finally fill out the last 14 rows with blank tiles
    ; Plenty of time still with initialisation so no problem in spreading over two loops
    LDA #0
    LDX #0
.FillLastRows1:
    STA PPUDATA
    INX
    CPX #NUMBER_OF_TILES_PER_ROW * 7
    BNE .FillLastRows1

    LDX #0
.FillLastRows2:
    STA PPUDATA
    INX
    CPX #NUMBER_OF_TILES_PER_ROW * 7
    BNE .FillLastRows2

; Next load in the controls screen
    LDA #$24                        ; Set the PPUADDR to load into the second nametable
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    LDX #0
    LDA #0
    STA background_load_counter     ; Reset the variables
    STA background_load_current_Y
.Controls_FillFirstRow:             ; Fill the first rows with blank tiles
    STA PPUDATA
    INX
    CPX #NUMBER_OF_TILES_PER_ROW * 4
    BNE .Controls_FillFirstRow

Controls_NextRow:
    LDX #0
    LDA #0
.FillLeftBlank:             ; Load 8 tiles of blank first
    STA PPUDATA
    INX
    CPX #ENVELOPE_WIDTH
    BNE .FillLeftBlank

    ; Calculate the target tile count for this row (current + 16)
    LDA background_load_counter
    CLC
    ADC #16
    STA background_load_target

    ; from the current to the target, load into PPUDATA
    LDX background_load_counter
.loadNext_Loop: 
    LDA controls, X
    STA PPUDATA
    INX
    CPX background_load_target
    BNE .loadNext_Loop

    STX background_load_counter     ; Update the counter for the next row
    
    LDX #0
    LDA #0
.FillRightBlank:                    ; Load the final 8 tiles of blank
    STA PPUDATA
    INX
    CPX #ENVELOPE_WIDTH
    BNE .FillRightBlank

    INC background_load_current_Y   ; Increment the row counter.

    ; Check to see if we have loaded all 16 rows of the title screen image database
    LDY background_load_current_Y
    CPY #IMAGE_WIDTH
    BNE Controls_NextRow            ; Else Load in another row

    ; Lastly for the control screen, load in the 4 rows of the database of the showcase
    ; It's just a set of anim frames nicely placed. (flip nosegrind, BS flip out)
    LDX #0
.FillUnderStillframesShowcase:
    LDA stillframes_showcase, X
    STA PPUDATA
    INX
    CPX #NUMBER_OF_TILES_PER_ROW * 7
    BNE .FillUnderStillframesShowcase

    LDX #0
    LDA #0
.FillOutLastSection:                ; Fill in the last 3 rows with blank tiles
    STA PPUDATA
    INX
    CPX #NUMBER_OF_TILES_PER_ROW * 3
    BNE .FillOutLastSection

    ; Set PPUCTRL register back to allow nmi update
    LDA scroll_page
    ORA #%10000000
    STA PPUCTRL
    RTS