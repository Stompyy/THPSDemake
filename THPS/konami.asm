
;----------------------------------------
; Konami_CheckForButton .macro
;     ; @Param \1 Binary value of button pressed
;     ; A register already contains joypad1_state value
;     LDA joypad1_state
;     CMP \1
;     BNE .Konami_NotPressed
;     SEC                                 ; Set the carry flag to #1
;     ROL A                                ; Bit shift left and set bit 7 as the carry flag value #1
;     STA konami_code_running_check
; .Konami_NotPressed:
;     .endm


;----------------------------------------
; CheckKonamiCode:
;     LDA joypad1_state                   ; If no button presed then set bool as false
;     CMP #0
;     BEQ Konami_NoKeyPressed
;     LDA konami_code_running_check       ; Check for winstate first
;     CMP #KONAMI_CHECK_STEP_9
;     BEQ Konami_CheckForBAStart
;     LDA konami_current_press_checked    ; If current press checked then skip
;     CMP #1
;     BEQ Konami_End
;     LDA #1                              ; Else check current press, Set the skip bool
;     STA konami_current_press_checked
    
; ; Konami_CheckForButton .macro
; ;     ; @Param \1 Biinary value of button pressed
; ;     ; A register already contains joypad1_state value
; ;     LDA joypad1_state
; ;     CMP \1
; ;     BNE .Konami_NotPressed
; ;     LDA konami_code_running_check
; ;     SEC                                 ; Set the carry flag to #1
; ;     ROL A                                ; Bit shift left and set bit 7 as the carry flag value #1
; ;     STA konami_code_running_check
; ; .Konami_NotPressed:
; ;     .endm

;     LDA konami_code_running_check
;     CLC
    
;     CMP #KONAMI_CHECK_STEP_1                   ; Else Check each code in turn
;     BNE Konami_CheckStep2
;     LDA joypad1_state
;     CMP #BUTTON_UP
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC                                 ; Set the carry flag to #1
;     ROL A                                ; Bit shift left and set bit 7 as the carry flag value #1
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep2:
;     CMP #KONAMI_CHECK_STEP_2
;     BNE Konami_CheckStep3
;     LDA joypad1_state
;     CMP #BUTTON_UP
;     ;BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep3:
;     CMP #KONAMI_CHECK_STEP_3
;     BNE Konami_CheckStep4
;     LDA joypad1_state
;     CMP #BUTTON_DOWN
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep4:
;     CMP #KONAMI_CHECK_STEP_4
;     BNE Konami_CheckStep5
;     LDA joypad1_state
;     CMP #BUTTON_DOWN
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep5:
;     CMP #KONAMI_CHECK_STEP_5
;     BNE Konami_CheckStep6
;     LDA joypad1_state
;     CMP #BUTTON_LEFT
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep6:
;     CMP #KONAMI_CHECK_STEP_6
;     BNE Konami_CheckStep7
;     LDA joypad1_state
;     CMP #BUTTON_RIGHT
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep7:
;     CMP #KONAMI_CHECK_STEP_7
;     BNE Konami_CheckStep8
;     LDA joypad1_state
;     CMP #BUTTON_LEFT
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
; Konami_CheckStep8:
;     CMP #KONAMI_CHECK_STEP_8
;     BNE Konami_WrongKeyPressed
;     LDA joypad1_state
;     CMP #BUTTON_RIGHT
;     BNE Konami_WrongKeyPressed
;     LDA konami_code_running_check
;     SEC  
;     ROL A
;     STX konami_code_running_check
;     JMP Konami_End
;     ; Else correct key not pressed so zero out the running check
; Konami_WrongKeyPressed:
;     LDA #0
;     STA konami_code_running_check
;     RTS
; Konami_NoKeyPressed:
;     LDA #0
;     STA konami_current_press_checked
;     RTS
; Konami_DoCheat:
;     ; Play a sound maybe?
;     ; Do some cheat effect
;     LDA #1
;     STA is_konami_god_mode              ; Need to implement this
; Konami_End:
;     RTS
; Konami_CheckForBAStart:
;     LDA joypad1_state                   ; Check for full winstate first
;     CMP #%11010000
;     BEQ Konami_DoCheat
;     CMP BUTTON_B                        ; If one of the final combo is pressed then ignore and end
;     BEQ Konami_End
;     CMP BUTTON_A
;     BEQ Konami_End
;     CMP BUTTON_START
;     BEQ Konami_End
;     JMP Konami_WrongKeyPressed