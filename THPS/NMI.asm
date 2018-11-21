;----------------------------------------
;;;;;;;;;----------NMI----------;;;;;;;;;
;----------------------------------------
NMI:
    ; State machine handles everything!
    JMP CheckStateMachine
;----------------------------------------
NMI_ShowTitleScreen:
    JSR Title_FlashMessage
    LDA #0              ; Set scroll positions to zero
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%10011000      ; Second sprite sheet pattern table for sprites and background, first nametable for title screen
    STA PPUCTRL
    RTI
;----------------------------------------
NMI_ShowControlsPage:
    LDA #0              ; Set scroll positions to zero
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%10000001      ; First sprite sheet pattern table for sprites and background, second nametable for control screen
    STA PPUCTRL
    RTI
;----------------------------------------
NMI_ShowPreGame:
    LDA #0              ; Set scroll positions to zero
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%10000000      ; First sprite sheet pattern table for sprites and background, first nametable while second background is generating
    STA PPUCTRL
    RTI
;----------------------------------------
NMI_State_PlayGame:
    ; Main update subroutine
    JSR UpdateGame

    ; Push sprite data every frame in gameplay
    LDA #0
    STA OAMADDR
    LDA #$02            ; Location of the sprites In memory
    STA OAMDMA
    LDA scroll_page
    ORA #%10000000      ; first sprite sheet pattern table for sprites and background
    STA PPUCTRL
    RTI
;----------------------------------------