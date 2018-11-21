;----------------------------------------
;;;;;;;---------------------------;;;;;;;
;----------------------------------------
UpdateGame:
    ; Update the joypad1_state
    JSR Check_Controls

    ; Scroll - Do this first as heavy, to avoid potential flickering as screen is already being rendered at end
    LDA scroll_x
    CLC
    ADC delta_X
    STA scroll_x
    STA PPUSCROLL           ; x scroll
    BCC .Scroll_NoWrap      ; If carry flag is set so has overflowed over 255

    ; scroll_x has wrapped, so switch scroll_page
    LDA scroll_page
    EOR #1                  ; Excusive or (if ==1 then =0, else if ==0 then =1)
    STA scroll_page
    ORA #%10000000          ; Or inclusive, sets NMI scrolling
    STA PPUCTRL

.Scroll_NoWrap:
    LDA #0
    STA PPUSCROLL           ; y scroll

    ; If is grinding, then skip past the standard controls
    LDA is_grinding
    CMP #FALSE
    BEQ .Controls_Parse
    JMP ReadControls_Done

.Controls_Parse:
    ; React to B button
    LDA joypad1_state
    AND #BUTTON_B
    BEQ ReadB_Done
    LDA is_animating        ; Check if is animating
    CMP #TRUE
    BEQ ReadB_Done
    LDA is_grounded
    CMP #TRUE
    BEQ .B_pressed_grounded
    JMP WaitingForGrind
.B_pressed_grounded:
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

    ; React to Left button
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ ReadLeft_Done
    LDA is_animating        ; Check if is animating
    CMP #TRUE
    BEQ ReadLeft_Done
    LDA is_grounded
    CMP #TRUE
    BEQ .DoTrick_Brake
    ; Else do BSFLIP if !is_grounded
    Animation_SetUp #ANIM_OFFSET_BSFLIP, #TOTAL_ANIM_TILES_BSFLIP
    LDA #TRUE
    STA is_performing_trick
    STA is_fakie                ; To tell the landing animation which anim to use
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
    LDA is_animating        ; Check if is animating
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
    LDA is_animating        ; Check if is animating
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
    LDA is_animating        ; Check if is animating
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
    BEQ ReadControls_Done
    LDA is_animating        ; Check if is animating
    CMP #TRUE
    BEQ ReadControls_Done
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
    JMP ReadControls_Done
.DoTrick_BS180:
    Animation_SetUp #ANIM_OFFSET_BS180, #TOTAL_ANIM_TILES_BS180
    LDA #TRUE
    ;STA is_performing_trick ; disable to let player slide the trick around in last second without falling
    STA is_fakie                ; To tell the landing animation which anim to use
    
ReadControls_Done:

    ; Check collision with traffic cones
    CheckCollisionWithCone sprite_player+SPRITE_X, sprite_player+SPRITE_Y, #PLAYER_PIXEL_HEIGHT, #20, #2, #2, NoCollisionWithCone 
    ; If collided, then set fall anim
    Animation_SetUp #ANIM_OFFSET_FALL, #TOTAL_ANIM_TILES_FALL
NoCollisionWithCone:

    LDA is_grinding
    CMP #FALSE
    BEQ WaitingForGrind

    JSR Grind_CheckForEndOfLedge

WaitingForGrind:

    LDA is_grinding
    CMP #TRUE
    BEQ .SkipGravityAndSpeed
    JSR Update_Gravity
    JSR Update_Speed
    JMP .GrindChecksDone
.SkipGravityAndSpeed:

    LDA joypad1_state           ; Check for ollie off the ledge
    AND #BUTTON_A
    BEQ .GrindChecksDone
    LDA #FALSE
    STA is_grinding
    ; Set up the OLLIE animation
    Animation_SetUp #ANIM_OFFSET_OLLIE, #TOTAL_ANIM_TILES_OLLIE
    ; Ollie (set player downward speed to jump force)
    LDA #LOW(JUMP_FORCE)
    STA player_downward_speed
    LDA #HIGH(JUMP_FORCE)
    STA player_downward_speed + 1

.GrindChecksDone:

    JSR Update_Obstacle_X_Positions

    LDA is_grounded
    CMP #FALSE
    BEQ .CheckForGrind
    JMP .PlayerNotGrindingLedge
.CheckForGrind:
    LDA player_downward_speed+1     ; Limit triggering grinding to when falling
    BMI .JumpToPlayerNotGrindingLedge
    LDA joypad1_state
    AND #BUTTON_B
    BEQ .JumpToPlayerNotGrindingLedge
    LDA sprite_player + SPRITE_Y    ; Get the current vertical position of the first tile
    CLC
    ADC #PLAYER_PIXEL_HEIGHT        ; Y offset of three tiles to find the bottom.y of player
    CLC
    CMP #GRIND_THRESHOLD            ; Compare to threshold height
    BNE .JumpToPlayerNotGrindingLedge

    LDA scroll_page
    CMP #0                          ; are we on the first nametable page or not?
    BNE .CheckSecondPageLedgePlacement
    LDA scroll_x
    CLC
    CMP #START_OF_LEDGE_MARKER_SCROLL
    BCC .JumpToPlayerNotGrindingLedge
    JMP .ChooseGrind

.CheckSecondPageLedgePlacement:
    LDA scroll_x
    CLC
    CMP #END_OF_LEDGE_MARKER_SCROLL
    BCS .JumpToPlayerNotGrindingLedge
    JMP .ChooseGrind

.JumpToPlayerNotGrindingLedge
    JMP .PlayerNotGrindingLedge

.ChooseGrind:
    LDA #TRUE
    STA is_grinding
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ .GrindNotBluntslide
    Animation_SetUp #ANIM_OFFSET_BLUNTSLIDE, #TOTAL_ANIM_TILES_BLUNTSLIDE
    JMP .PlayerSetGrindHeight
.GrindNotBluntslide:    
    LDA joypad1_state
    AND #BUTTON_RIGHT
    BEQ .GrindNotCrooked
    Animation_SetUp #ANIM_OFFSET_CROOKED, #TOTAL_ANIM_TILES_CROOKED
    JMP .PlayerSetGrindHeight
.GrindNotCrooked:    
    LDA joypad1_state
    AND #BUTTON_UP
    BEQ .GrindNotNosegrind
    Animation_SetUp #ANIM_OFFSET_NOSEGRIND, #TOTAL_ANIM_TILES_NOSEGRIND
    JMP .PlayerSetGrindHeight
.GrindNotNosegrind:    
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ .PlayerNotSpecialGrind
    Animation_SetUp #ANIM_OFFSET_50, #TOTAL_ANIM_TILES_50
    JMP .PlayerSetGrindHeight
.PlayerNotSpecialGrind:
    Animation_SetUp #ANIM_OFFSET_5050, #TOTAL_ANIM_TILES_5050
.PlayerSetGrindHeight:
    Player_Set_Y_Position #GRIND_HEIGHT
    JMP .SkipGravityAndSpeed
.PlayerNotGrindingLedge:

    LDA is_animating                        ; Check if is animating
    CMP #FALSE
    BEQ .SkipAnimUpdate
    JSR UpdateAnimation
.SkipAnimUpdate

    LDA is_grounded
    CMP #TRUE
    BNE .SkipPlayerForceGroundedPosition
    Player_Set_Y_Position #SCREEN_BOTTOM_Y  ; Have to force the Y pos sometimes. gravity stuff
.SkipPlayerForceGroundedPosition:
    RTS