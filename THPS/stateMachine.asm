;----------------------------------------
;;;;;;;-------STATE-MACHINE-------;;;;;;;
;----------------------------------------
GAMESTATE_TITLE             = 0
GAMESTATE_CONTROLS          = 1
GAMESTATE_PREGAME           = 2
GAMESTATE_PLAY              = 3
;----------------------------------------
CheckStateMachine:
    ; Check the gameStateMachine and jump to the appropriate code that governs that state
    ; Do GAMESTATE_PLAY first as most likely.
    LDA gameStateMachine
    CMP #GAMESTATE_PLAY
    BNE .gamestate_notPlaying
    JMP NMI_State_PlayGame              ; Playing the game
.gamestate_notPlaying:
    CMP #GAMESTATE_CONTROLS
    BNE .gamestate_notControlScreen
    JMP NMI_State_ControlScreen         ; In control screen
.gamestate_notControlScreen:
    CMP #GAMESTATE_PREGAME
    BNE .gameState_notPregame
    JMP NMI_State_PreGame               ; In pregame
.gameState_notPregame:
    JMP NMI_State_TitleScreen           ; Else continue to show title screen that was loaded in on initialisation
;----------------------------------------
; Executable when state machine is in the title screen
NMI_State_TitleScreen:
; In Title screen controls
    ; React to start button
    JSR Check_Controls
    LDA joypad1_state
    AND #BUTTON_START
    BNE .InitControlScreen
    JMP NMI_ShowTitleScreen
.InitControlScreen:
    ; One time init of the first nametable's game background generator
    ; When we look at the control screen (second nametable), we start to generate the game background
    ; first we generate the background for the nametable for which we are NOT currently looking at ($20)
    LDA #0
    STA generate_x
    LDA #$20                            ; The address of the first nametable
    STA current_nametable_generating    ; Store the nametable address for which we are curently generating
                                        ; We use the generate_x to step through the second part of the PPUADDR when generating the background
    
    ; Seed the random number generator
    LDX title_screen_flash_timer        ; Use the current value of the title_screen_flash_timer for different seeds each session
    STX seed
    INX                                 ; Ensures a non zero seed
    STA seed+1

    JSR Title_RemoveWhiteBox            ; Remove the white text flashing box

    LDA #GAMESTATE_CONTROLS             ; Change the state machine
    STA gameStateMachine
    JMP NMI_ShowControlsPage
;----------------------------------------
; Executable when state machine is in the controls screen
NMI_State_ControlScreen:
    ; Check if new column needs to be generated before allowing controls to exit this state
    ; We do this sequentially a column at a time. Any more than about 6 columns generated in 
    ; one NMI update will overload the PPU and cause garbage to be displayed.
    ; The player is expected to spend much more than 32 frames in each state, so we take
    ; advantage of this time to do this generation gradually and safely
    LDX generate_x ;background_load_counter
    CPX #NUMBER_OF_TILES_PER_ROW
    BEQ .CheckForControls               ; Nametable is fully loaded so check for exit controls
    JSR GenerateGameBackground_Column   ; Generate a new background column
    JMP NMI_ShowControlsPage            ; Continue to show the control screen
; Check for an A button press (this is indicated in the control screen to continue)
.CheckForControls:
    JSR Check_Controls
    LDA joypad1_state
    AND #BUTTON_A
    BNE .A_button_pressed
    JMP NMI_ShowControlsPage
.A_button_pressed:
    LDA #$24                            ; Set the second nametable to load in
    STA current_nametable_generating
    LDA #0
    STA generate_x
    LDA #GAMESTATE_PREGAME
    STA gameStateMachine

    ; Load attribute data that each 16 x 16 uses
    LDA #$23                            ; Write address $23C0 (first nametable attribute table) to PPUADDR register
    STA PPUADDR
    LDA #$C0
    CLC
    ADC #48                             ; Offset into the attribute table by 6 * rows of 8 (Only need to change the floor section)
    STA PPUADDR

    LDA #%01010101                      ; set all (attribute table) to the second colour palette
    LDX #16                             ; last 2 * rows of 8
.LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes_Loop

    ; Load attribute data
    LDA #$27                            ; Write address $27C0 (second nametable attribute table) to PPUADDR register
    STA PPUADDR
    LDA #$C0
    CLC
    ADC #48                             ; Offset into the attribute table by 6 * rows of 8 (again, don't need to change the sky palette)
    STA PPUADDR

    LDA #%01011010                      ; Upper 2 blocks in attribute box set to third palette for the ledge
    LDX #8                              ; 1 * row of 8
.LoadAttributes2_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes2_Loop

    LDA #%01010101                      ; set all attributes to the second colour palette
    LDX #8                              ; 1 * row of 8
.LoadAttributes3_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes3_Loop

    JMP NMI_ShowPreGame
;----------------------------------------
; Executable when state machine is in the PreGame state
NMI_State_PreGame:
    ; Load in the second nametable of game background
    LDX generate_x                          ; Check if finished loading in nametable
    CPX #NUMBER_OF_TILES_PER_ROW
    BNE .MoreColumnsNeeded                  ; load in another column
    JMP InitGame                            ; else initialise game for play
.MoreColumnsNeeded:                     
    JSR GenerateGameBackground_ColumnWithLedge
    JMP NMI_ShowPreGame
;----------------------------------------
; When finished loading in game background, load in game sprites and update the game state machine
InitGame:
    ; Load in game sprites
    JSR LoadPlayer
    JSR LoadScore
    JSR LoadTrafficCone

    ; Change the gameState to Play
    LDA #GAMESTATE_PLAY
    STA gameStateMachine
    JMP NMI_State_PlayGame
;----------------------------------------
