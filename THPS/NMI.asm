NMI:        ; Non maskable interrupt

    JSR CheckControls

    LDA gameStateMachine
    CMP #GAMESTATE_PLAY
    BNE .InMenus1
    JMP PlayGame
.InMenus1:
    CMP #GAMESTATE_CONTROLS
    BNE .InMenus2
    JMP NMI_ShowControlScreen
.InMenus2:
    CMP #GAMESTATE_PREGAME
    BNE .InMenus3
    JMP NMI_PreGame
.InMenus3:
    ; Else continue to show title screen that was loaded in on initialisation

; In Title screen controls
    ; React to A or B button
    LDA joypad1_state
    AND #BUTTON_START
    BNE .InitControlScreen
    JMP NMI_ShowTitleScreen
.InitControlScreen:

    ; One time init of the game background generator
    LDA #0
    STA generate_x
    STA title_screen_load_counter
    LDA #$20
    STA current_nametable_generating
    LDA #GAMESTATE_CONTROLS
    STA gameStateMachine

; Check if new column needs to be generated before allowing controls to exit
NMI_ShowControlScreen:
    LDX title_screen_load_counter
    CPX #32
    BEQ .CheckForControls


    INX
    STX title_screen_load_counter
    JSR GenerateGameBackgroundColumn
    JMP NMI_ShowControlsPage

; .LoadInPlayerSprite:
;     ; Load the player sprite
;     LDX #0
; .LoadPlayerSprite_Next:
;     LDA playerSpritesDB, X
;     STA sprite_player, X
;     INX
;     CPX #24  ; Just one (8x8 * 6) sprite loading currently. NumSprites * 4
;     BNE .LoadPlayerSprite_Next  

;     ; Copy sprite data to the PPU
;     LDA #0
;     STA OAMADDR
;     LDA #$02    ; Location of the sprite? In memory
;     STA OAMDMA

;     INC title_screen_load_counter

.CheckForControls:
    LDA joypad1_state
    AND #BUTTON_A
    BEQ NMI_ShowControlsPage
    LDA #$24                            ; Set the second nametable to load in
    STA current_nametable_generating
    LDA #0
    STA generate_x
    STA title_screen_load_counter
    LDA #GAMESTATE_PREGAME
    STA gameStateMachine

    ; Load attribute data that each 16 x 16 uses
    LDA #$23        ; Write address $23C0 to PPUADDR register
    STA PPUADDR     ; PPUADDR is big endian for some reason??
    LDA #$C0
    CLC
    ADC #46         ; Only bother changing the floor bit
    STA PPUADDR

    LDA #%01010101  ; set all (attribute table?) to first colour palette
    LDX #18
.LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes_Loop

    ; Load attribute data
    LDA #$27
    STA PPUADDR
    LDA #$C0
    CLC
    ADC #48
    STA PPUADDR

    LDA #%01010000  ; For the ledge palette
    LDX #8
.LoadAttributes2_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes2_Loop

    LDA #%01010101
    LDX #8
.LoadAttributes3_Loop:
    STA PPUDATA
    DEX
    BNE .LoadAttributes3_Loop

    JMP Render_PreGame

NMI_ShowControlsPage:
    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%10000001
    STA PPUCTRL
    RTI     ; Return from interrupt

NMI_ShowTitleScreen:
    JSR Title_FlashMessage
    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%10011000  ; Second page for sprites and background
    STA PPUCTRL
    RTI     ; Return from interrupt

NMI_PreGame:

    LDX title_screen_load_counter
    CPX #32
    BEQ StartGame
    
    INX
    STX title_screen_load_counter
    JSR GenerateGameBackgroundColumnWithLedge

    ; This Messes up the second nametable generation...
    ; Copy sprite data to the PPU
    ;LDA #0
    ;STA OAMADDR
    ;LDA #$02    ; Location of the sprite? In memory
    ;STA OAMDMA
Render_PreGame:
    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL

    LDA #%10000000
    STA PPUCTRL
    RTI     ; Return from interrupt

StartGame:
    ; Load the player sprite
    LDX #0
.LoadPlayerSprite_Next:
    LDA playerSpritesDB, X
    STA sprite_player, X
    INX
    CPX #24  ; Just one (8x8 * 6) sprite loading. NumSprites * 4
    BNE .LoadPlayerSprite_Next  

    LDA #GAMESTATE_PLAY
    STA gameStateMachine
    
PlayGame:

; Scroll - Do this first as heavy, to avoid potential flickering as screen is already being rendered at end
    LDA scroll_x
    CLC
    ADC delta_X
    STA scroll_x
    STA PPUSCROLL       ; x scroll
    BCC Scroll_NoWrap   ; If carry flag is set so has overflowed over 255

    ; scroll_x has wrapped, so switch scroll_page
    LDA scroll_page
    EOR #1  ; ExcusiveOr (if ==1 then =0, else if ==0 then =1)
    STA scroll_page
    ORA #%10000000      ; orIn, sets the normal PPUCTRL value set in init that allows NMI scrolling
    STA PPUCTRL

Scroll_NoWrap:
    LDA #0
    STA PPUSCROLL   ; y scroll

    ; Chwck if a column of background needs to be generated
    LDA scroll_x
    AND #7          ; Wipe out everything from the 8 bit onwards
                    ; if zero flag set, then generate
    BNE Scroll_NoGenerate   ; else skip

    ;JSR GenerateColumn
Scroll_NoGenerate:

    ; React to Left button
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ ReadLeft_Done
    LDA is_animating        ; If already animating skip to the end
    CMP #TRUE
    BEQ ReadLeft_Done
    LDA is_grounded
    CMP #TRUE
    BEQ .DoTrick_Brake
    ; Else do BSFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_BSFLIP, #TOTAL_ANIM_TILES_BSFLIP
    LDA #TRUE
    STA is_performing_trick
    STA is_fakie    ; To tell the landing animation which anim to use
    JMP ReadLeft_Done
.DoTrick_Brake
    Animation_SetUp #ANIM_OFFSET_BRAKE, #TOTAL_ANIM_TILES_BRAKE
    LDA #LOW(BRAKE_FORCE)
    STA forward_speed
    LDA #HIGH(BRAKE_FORCE)
    STA forward_speed+1
ReadLeft_Done:

    ; React to Right button
    LDA joypad1_state
    AND #BUTTON_RIGHT
    BEQ ReadRight_Done
    LDA is_animating
    CMP #TRUE
    BEQ ReadRight_Done
    LDA is_grounded
    CMP #TRUE
    BEQ .DoTrick_Push
    ; Else do KICKFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_KICKFLIP, #TOTAL_ANIM_TILES_KICKFLIP
    LDA #TRUE
    STA is_performing_trick
    JMP ReadRight_Done
.DoTrick_Push:
    Animation_SetUp #ANIM_OFFSET_PUSH, #TOTAL_ANIM_TILES_PUSH
    LDA #LOW(PUSH_FORCE)
    STA forward_speed
    LDA #HIGH(PUSH_FORCE)
    STA forward_speed+1
ReadRight_Done:

    ; React to Up button
    LDA joypad1_state
    AND #BUTTON_UP
    BEQ ReadUp_Done
    LDA is_animating
    CMP #TRUE
    BEQ ReadUp_Done
    LDA is_grounded
    CMP #TRUE
    BEQ .DoTrick_NoseManual
    ; Else do POPSHUV if !is_grounded
    Animation_SetUp #ANIM_OFFSET_POPSHUV, #TOTAL_ANIM_TILES_POPSHUV
    LDA #TRUE
    STA is_performing_trick
    JMP ReadUp_Done
.DoTrick_NoseManual:
    Animation_SetUp #ANIM_OFFSET_NOSEGRIND, #TOTAL_ANIM_TILES_NOSEGRIND
ReadUp_Done:

    ; React to Down button
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ ReadDown_Done
    LDA is_animating
    CMP #TRUE
    BEQ ReadDown_Done
    LDA is_grounded
    CMP #TRUE
    BEQ .DoTrick_Manual
    ; Else do TREFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_TREFLIP, #TOTAL_ANIM_TILES_TREFLIP
    LDA #TRUE
    STA is_performing_trick
    JMP ReadDown_Done
.DoTrick_Manual:
    Animation_SetUp #ANIM_OFFSET_50, #TOTAL_ANIM_TILES_50
ReadDown_Done:

    ; React to A button
    LDA joypad1_state
    AND #BUTTON_A
    BEQ ReadA_Done
    LDA is_animating
    CMP #TRUE
    BEQ ReadA_Done
    LDA is_grounded
    CMP #FALSE
    BEQ .DoTrick_BS180
    ; Set up the OLLIE animation
    Animation_SetUp #ANIM_OFFSET_OLLIE, #TOTAL_ANIM_TILES_OLLIE
    ; Ollie (set player downward speed to jump force)
    LDA #LOW(JUMP_FORCE)
    STA player_downward_speed
    LDA #HIGH(JUMP_FORCE)
    STA player_downward_speed + 1
    ; Move off the ground to allow forces
    Player_Move SPRITE_Y, #-2   ; 2 is enough to disengage from is_grounded check, 1 is immediately discounted by gravity
    ; Change bool
    LDA #FALSE
    STA is_grounded
    JMP ReadA_Done
.DoTrick_BS180:
    Animation_SetUp #ANIM_OFFSET_BS180, #TOTAL_ANIM_TILES_BS180
    LDA #TRUE
    ;STA is_performing_trick ; disable to let player slide the trick around in last second without falling
    STA is_fakie    ; To tell the landing animation which anim to use
ReadA_Done:

    ; React to B button
    LDA joypad1_state
    AND #BUTTON_B
    BEQ ReadB_Done
    LDA is_animating
    CMP #TRUE
    BEQ ReadB_Done
    LDA is_grounded
    CMP #FALSE
    BEQ ReadB_Done
    ; Set up the NOLLIE animation
    Animation_SetUp #ANIM_OFFSET_NOLLIE, #TOTAL_ANIM_TILES_NOLLIE
    ; Ollie (set player downward speed to jump force)
    LDA #LOW(JUMP_FORCE)
    STA player_downward_speed
    LDA #HIGH(JUMP_FORCE)
    STA player_downward_speed + 1
    ; Move off the ground to allow forces
    Player_Move SPRITE_Y, #-2
    ; Change bool
    LDA #FALSE
    STA is_grounded
ReadB_Done:

;ReadControls_Done:

    CheckCollisionWithCone sprite_player+SPRITE_X, sprite_player+SPRITE_Y, #24, #24, #2, #2, NoCollisionWithCone 

    Animation_SetUp #ANIM_OFFSET_FALL, #TOTAL_ANIM_TILES_FALL

NoCollisionWithCone:

    JSR UpdateSpeed

    JSR UpdateGravity

    JSR UpdateObstaclePositions

    LDA is_animating
    CMP #FALSE
    BEQ .SkipAnimUpdate
    JSR UpdateAnimation
.SkipAnimUpdate

    LDA is_grounded
    CMP #TRUE
    BNE .SkipPlayerForceGroundedPosition
    Player_Set_Position #SCREEN_BOTTOM_Y    ; Have to force the Y pos sometimes? gravity stuff
.SkipPlayerForceGroundedPosition:    

NMI_End:

    ; Copy sprite data to the PPU
    LDA #0
    STA OAMADDR
    LDA #$02    ; Location of the sprite? In memory
    STA OAMDMA

    ; Set PPUCTRL register
    LDA scroll_page
    ORA #%10000000
    STA PPUCTRL

    RTI     ; Return from interrupt
