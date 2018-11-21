;----------------------------------------
;;;;;;;;;----SUBROUTINES----;;;;;;;;;
;----------------------------------------

;----------------------------------------
; Populates the joypad1_state with the currently pressed buttons
Check_Controls:
    ; Initialise controller 1
    LDA #1              ; Flash the controller with 0 and 1 to get a reading
    STA JOYPAD1
    LDA #0
    STA JOYPAD1
    ; Initialise to %00000000
    LDX #0
    STX joypad1_state

.ReadController:
    ;a(d key) b(f key) select start up down left right
    LDA JOYPAD1
    LSR A
    ROL joypad1_state
    INX                         ; Increment count
    CPX #8                      ; Compare X to 8
    BNE .ReadController         ; If not equal, return to function start

    ; joypad1_state now holds 8 * 0 or 1 bit values that reflect the current pressed buttons state
    ; in the order a, b, select, start, up, down, left, right
    RTS
;----------------------------------------
Load_New_Traffic_Cone:
    LDX #0
.NewCone_Loop:
    LDA obstacle_offscreen_traffic_cone_info, X
    STA sprite_traffic_cones, X
    INX
    CPX #LENGTH_OF_ONE_SPRITE
    BNE .NewCone_Loop
    RTS
;----------------------------------------
Update_Obstacle_X_Positions:
    LDX #SPRITE_X
    LDY #0
.Update_traffic_cones_Loop:
    LDA sprite_traffic_cones, X
    SEC
    SBC delta_X
    STA sprite_traffic_cones, X
    INX
    INX
    INX
    INX
    INY
    CPY #NUMBER_OF_TRAFFIC_CONES
    BNE .Update_traffic_cones_End
.Update_traffic_cones_End:
    RTS
;----------------------------------------
Update_Speed:
    ; First update 16 bit forward_speed
    LDA forward_speed
    CLC
    ADC #LOW(FRICTION)              ; Just get the low 8 bits of the 16 bit binary value
    STA forward_speed
    LDA forward_speed+1             ; Gets the next .rs slot along to return the high 8 bits
    ADC #HIGH(FRICTION)             ; NB: don't clear the carry flag! 16-bit carry over
    STA forward_speed+1

    ; Second, update forward_speed_sub (pixel Position)
    LDA forward_speed_sub
    CLC
    ADC forward_speed               ; (the low byte)
    STA forward_speed_sub
    LDA #0                          ; Start with an empty register
    ADC forward_speed+1             ; Add on the player downward speed High value including the important carry flag value
    BMI .UpdateSpeed_ZeroSpeed
    STA delta_X                     ; To use as a parameter in the following macros call
    RTS
.UpdateSpeed_ZeroSpeed:
    LDA #0
    STA delta_X
    STA forward_speed
    STA forward_speed+1
.UpdateSpeed_End:
    RTS
;----------------------------------------
Update_Gravity:
    LDA sprite_player + SPRITE_Y    ; Get the current vertical position of the first tile
    CLC
    ADC #PLAYER_PIXEL_HEIGHT        ; Y offset of three tiles to find the bottom.y of player
    CLC
    CMP #SCREEN_BOTTOM_Y            ; Compare to floor height
    BCS UpdatePlayer_Grounded

    ; Update player sprite
    ; First update 16 bit player_downward _speed
    LDA player_downward_speed
    CLC
    ADC #LOW(GRAVITY)               ; Just get the low 8 bits of the 16 bit binary value
    STA player_downward_speed
    LDA player_downward_speed+1     ; Gets the next .rs slot along to return the high 8 bits
    ADC #HIGH(GRAVITY)              ; NB: don't clear the carry flag! 16-bit carry over
    STA player_downward_speed+1

    ; Second, update player_position_sub (pixel Position)
    LDA player_position_sub
    CLC
    ADC player_downward_speed       ; (the low byte)
    STA player_position_sub
    LDA #0                          ; Start with an empty register
    ADC player_downward_speed+1     ; Add on the player downward speed High value including the important carry flag value
    STA delta_Y                     ; To use as a parameter in the following macros call

    Player_Move SPRITE_Y, delta_Y   ; Move sprite
    RTS

UpdatePlayer_Grounded:    
    LDA #0                          ; set player_speed to 0
    STA player_downward_speed
    STA player_downward_speed+1
    LDA is_grounded
    CMP #FALSE
    BEQ UpdatePlayer_SetGroundedAnim
    RTS
UpdatePlayer_SetGroundedAnim:
    LDA #TRUE
    STA is_grounded
    ; Set land anim between regular, fakie, or fall
    LDA is_performing_trick
    CMP #TRUE
    BEQ .UpdatePlayer_SetFallAnim
    LDA is_fakie
    CMP #TRUE
    BEQ .UpdatePlayer_SetFakieLandAnim
    Animation_SetUp #ANIM_OFFSET_LAND_REGULAR, #TOTAL_ANIM_TILES_LAND_REGULAR
    RTS
.UpdatePlayer_SetFakieLandAnim:   
    LDA #FALSE
    STA is_fakie
    Animation_SetUp #ANIM_OFFSET_LAND_FAKIE, #TOTAL_ANIM_TILES_LAND_FAKIE
    RTS
.UpdatePlayer_SetFallAnim:
    Animation_SetUp #ANIM_OFFSET_FALL, #TOTAL_ANIM_TILES_FALL
    RTS 
;----------------------------------------
; prng - http://wiki.nesdev.com/w/index.php/Random_number_generator
;
; Returns a random 8-bit number in A (0-255), clobbers (Overwrites) X (0).
;
; Requires a 2-byte value on the zero page called "seed".
; Initialize seed to any value except 0 before the first call to prng.
; (A seed value of 0 will cause prng to always return 0.)
;
; This is a 16-bit Galois linear feedback shift register with polynomial $002D.
; The sequence of numbers it generates will repeat after 65535 calls.
;
; Execution time is an average of 125 cycles (excluding jsr and rts)
prng:
	LDX #8              ; iteration count (generates 8 bits)
	LDA seed+0
prng_1:
	ASL A               ; shift the register
	ROL seed+1
	BCC prng_2
	EOR #$2D            ; apply XOR feedback whenever a 1 bit is shifted out
prng_2:
	DEX
	BNE prng_1
	STA seed+0
	CMP #0              ; reload flags
	RTS
;----------------------------------------
GenerateGameBackground_Column:
    LDA #%00000100      ; Put PPU into skip 32 mode instead of 1
    STA PPUCTRL         ; Have to restore back to previous values later

    LDA current_nametable_generating
    STA PPUADDR
    LDA generate_x
    STA PPUADDR

    LDX #26             ; 30 rows = 26 empty + 1 floor + 3 bricks underground
    LDA #$00            ; Location of an empty tile in the sprite sheet
.GenerateEmptyTile:
    STA PPUDATA
    DEX
    BNE .GenerateEmptyTile
    LDA #$F0            ; Floor
    STA PPUDATA
    LDX #3
    LDA #$F2            ; Underground
    CLC
.GenerateBricks:
    STA PPUDATA
    DEX
    BNE .GenerateBricks

    INC generate_x

    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%00000000
    STA PPUCTRL
    RTS
;----------------------------------------
GenerateGameBackground_ColumnWithLedge:
    ; PPUCTRL flag. 
    LDA #%00000100      ; Put PPU into skip 32 mode instead of 1
    STA PPUCTRL         ; Have to restore back to previous values later

    ; Set the PPUADDR as the preset variable, and offset into by the generate_x that increments with each generation
    LDA current_nametable_generating
    STA PPUADDR
    LDA generate_x
    STA PPUADDR

    LDX #25             ; 30 rows = 25 empty + 1 ledge + 1 floor + 3 bricks underground
    LDA #$00            ; Location of an empty tile in the sprite sheet
.GenerateEmptyTile:
    STA PPUDATA
    DEX
    BNE .GenerateEmptyTile
    LDA #$F0            ; Load one tile of ledge
    STA PPUDATA
    LDA #$F0            ; Load one tile of floor
    STA PPUDATA
    LDX #3              ; Load three tiles of underground
    LDA #$F2            ; Underground tile location
    CLC
.GenerateBricks:
    STA PPUDATA
    DEX
    BNE .GenerateBricks

    INC generate_x

    LDA #0
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%00000000
    STA PPUCTRL
    RTS
;----------------------------------------
Title_FlashMessage:
    LDX title_screen_flash_timer
    INX
    CPX #FLASH_FRAME_CHANGE_TIME
    BEQ .ChangeVisability
    STX title_screen_flash_timer
    RTS
.ChangeVisability:
    LDX #WHITE_BLANK_BOX_DB_LENGTH + SPRITE_ATTRIB
.ChangeNextTile:
    LDA sprite_text_blanking_box_white, X
    EOR #%00100000                  ; Flip the sprite priority to change visibility
    STA sprite_text_blanking_box_white, X
    DEX
    DEX
    DEX
    DEX
    BPL .ChangeNextTile
    LDX #0
    STX title_screen_flash_timer    ; reset the timer
    ; Draw the sprites
    LDA #0
    STA OAMADDR
    LDA #$02
    STA OAMDMA
    RTS
;----------------------------------------
Grind_CheckForEndOfLedge:
    LDA scroll_page
    CMP #END_OF_LEDGE_MARKER_PAGE
    BEQ .CheckPosition
    RTS
.CheckPosition:
    LDA scroll_x
    CLC
    CMP #END_OF_LEDGE_MARKER_SCROLL
    BCS .FallOfEndOfLedge
    RTS
.FallOfEndOfLedge:
    LDA #FALSE
    STA is_grinding
    RTS