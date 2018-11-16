NMI:        ; Non maskable interrupt

    LDA is_title_screen
    CMP #1
    BNE PlayGame

    ; Set PPUCTRL register
    LDA scroll_page
    ORA #%10010000
    STA PPUCTRL

    RTI     ; Return from interrupt
    
PlayGame:
; TempShould only do this next part once!!!
    JSR DrawGameBackground

; Scroll - Do this first as heavy, to avoid potential flickering as screen iss already being rendered at end
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

;Controls
    ; Initialise controller 1
    LDA #1
    STA JOYPAD1
    LDA #0
    STA JOYPAD1
    LDX #0
    STX joypad1_state   ; set to 0

ReadController:
    ;a(d key) b(f key) select start up down left right
    LDA JOYPAD1
    LSR A
    ROL joypad1_state
    INX                     ; Increment count
    CPX #8                  ; Compare X to 8
    BNE ReadController      ; If not equal, return to function start

    ; React to Left button
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ ReadLeft_Done
    LDA is_animating        ; If already animating skip to the end
    CMP #1
    BEQ ReadLeft_Done
    LDA is_grounded
    CMP #1
    BEQ .DoTrick_Brake
    ; Else do BSFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_BSFLIP, #TOTAL_ANIM_TILES_BSFLIP
    LDA #1
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
    CMP #1
    BEQ ReadRight_Done
    LDA is_grounded
    CMP #1
    BEQ .DoTrick_Push
    ; Else do KICKFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_KICKFLIP, #TOTAL_ANIM_TILES_KICKFLIP
    LDA #1
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
    CMP #1
    BEQ ReadUp_Done
    LDA is_grounded
    CMP #1
    BEQ .DoTrick_NoseManual
    ; Else do POPSHUV if !is_grounded
    Animation_SetUp #ANIM_OFFSET_POPSHUV, #TOTAL_ANIM_TILES_POPSHUV
    LDA #1
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
    CMP #1
    BEQ ReadDown_Done
    LDA is_grounded
    CMP #1
    BEQ .DoTrick_Manual
    ; Else do TREFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_TREFLIP, #TOTAL_ANIM_TILES_TREFLIP
    LDA #1
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
    CMP #1
    BEQ ReadA_Done
    LDA is_grounded
    CMP #0
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
    LDA #0
    STA is_grounded
    JMP ReadA_Done
.DoTrick_BS180:
    Animation_SetUp #ANIM_OFFSET_BS180, #TOTAL_ANIM_TILES_BS180
    LDA #1
    ;STA is_performing_trick ; disable to let player slide the trick around in last second without falling
    STA is_fakie    ; To tell the landing animation which anim to use
ReadA_Done:

    ; React to B button
    LDA joypad1_state
    AND #BUTTON_B
    BEQ ReadB_Done
    LDA is_animating
    CMP #1
    BEQ ReadB_Done
    LDA is_grounded
    CMP #0
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
    LDA #0
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
    CMP #0
    BEQ .SkipAnimUpdate
    JSR UpdateAnimation
.SkipAnimUpdate

    LDA is_grounded
    CMP #1
    BNE .SkipPlayerForceGroundedPosition
    Player_Set_Position #SCREEN_BOTTOM_Y    ; Have to force the Y pos sometimes? gravity stuff
.SkipPlayerForceGroundedPosition    

SkipThis:

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
