NewTitleScreenTime:

;; 32 x 30

    LDA #%00010000  ; Look at second sprite sheet
    STA PPUCTRL

    ; Fill the first row with 0
    LDX #0
    LDA #0
.FillFirstRow:
    STA PPUDATA
    INX
    CPX #32
    BNE .FillFirstRow


    ; Main loop
NextRow:

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
    BNE NextRow
    
    
    LDA #%10010000
    STA PPUCTRL

    RTS


Show_TitleScreen:

    JSR NewTitleScreenTime

    RTI