
;----------------------------------------
;;;;;;;;;----SUBROUTINES----;;;;;;;;;
;----------------------------------------

;----------------------------------------
LoadNewTrafficCone:
    LDX #0
.NewCone_Loop:
    LDA obstacle_offscreen_traffic_cone_info, X
    STA sprite_traffic_cones, X
    INX
    CPX #4
    BNE .NewCone_Loop
    RTS
;----------------------------------------
UpdateObstaclePositions:
    LDX #3
    LDY #1
.Update_Loop:
    LDA sprite_traffic_cones, X
    SEC
    SBC delta_X
    STA sprite_traffic_cones, X
    CLC
    CPY #NUMBER_OF_TRAFFIC_CONES
    BCC .Update_End
    INX
    INX
    INX
    INX
    INY
    JMP .Update_Loop
.Update_End:
    RTS
;----------------------------------------
UpdateSpeed:
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
UpdateGravity:
    LDA sprite_player + SPRITE_Y    ; Get the current vertical position of the first tile
    CLC
    ADC #24                         ; Y offset of three tiles to find the bottom.y of player
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
    CMP #0
    BEQ UpdatePlayer_SetGroundedAnim
    RTS
UpdatePlayer_SetGroundedAnim:
    LDA #1
    STA is_grounded
    ; Set land anim between regular, fakie, or fall
    LDA is_performing_trick
    CMP #1
    BEQ .UpdatePlayer_SetFallAnim
    LDA is_fakie
    CMP #1
    BEQ .UpdatePlayer_SetFakieLandAnim
    Animation_SetUp #ANIM_OFFSET_LAND_REGULAR, #TOTAL_ANIM_TILES_LAND_REGULAR
    RTS
.UpdatePlayer_SetFakieLandAnim:   
    LDA #0
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
	LDX #8     ; iteration count (generates 8 bits)
	LDA seed+0
prng_1:
	ASL A       ; shift the register
	ROL seed+1
	BCC prng_2
	EOR #$2D   ; apply XOR feedback whenever a 1 bit is shifted out
prng_2:
	DEX
	BNE prng_1
	STA seed+0
	CMP #0     ; reload flags
	RTS
;----------------------------------------
GenerateTitleScreenColumn:

    RTS
;----------------------------------------
GenerateColumn:
    ; PPUCTRL flag. Put PPU into skip 32 mode instead of 1
    LDA #%00000100
    STA PPUCTRL ; Have to restore back to previous values later

    ; find most significant byte of PPU address
    ; See video 8, 6:10 for the explanation of which bit to look at
    LDA generate_x
    AND #32     ; The halfway point of 63 potential columns spread over two pages
                ; Accumulator = 0 for nametable $2000, 32 for nametable $2400

    LSR A
    LSR A       ; Bitshift right == divide by 2
    LSR A       ; so  3 times == divide by 8. So accumulator = 0 or 4
    ; No need to CLC as bitshift will have shifted a #0 into it
    ADC #$20    ; A now = $20 or $24
    STA PPUADDR

    ; Find least significant byte of PPU address
    LDA generate_x
    AND #31     ; Gets the 0-32 ... video 8 10:30 ??
    STA PPUADDR

    ; Write the data
    LDA generate_counter
    BNE GenerateColumn_Ledge
    ; Set up new pipe
    JSR prng
    AND #LEDGE_LENGTH_RANDOM_MASK ; wipe out values over, get a value upto 8
    CLC
    ADC #LEDGE_MINIMUM_LENGTH ; gives a value between 4 and 12
    STA generate_length_length
    LDA generate_counter    ; load this back in

;-------

GenerateColumn_Ledge:
    ; pipe is 4 tiles wide so do empty if more than 4
    CMP #4  
    BCS GenerateColumn_Empty

;-------

;     ; Else, generate ledge
;     LDX #25     ; 30 rows
;     LDA #$F2    ; Location of an empty tile in the sprite sheet
; .GenerateEmpty:
;     STA PPUDATA
;     DEX
;     BNE .GenerateEmpty
;     LDX #5
;     LDA #$F0
; .GenerateLedge:
;     STA PPUDATA
;     DEX
;     BNE .GenerateLedge

;-------

GenerateColumn_Empty:
    LDX #26     ; 30 rows
    LDA #$E3    ; Location of an wall tile in the sprite sheet
.GenerateEmpty:
    STA PPUDATA
    DEX
    BNE .GenerateEmpty
    LDA #$F0    ; Floor
    STA PPUDATA
    LDX #3
    LDA #$F2    ; Underground
.GenerateLedge:
    STA PPUDATA
    DEX
    BNE .GenerateLedge

;-------

GenerateColumn_End:
    ; Increment generate_x
    LDA generate_x
    CLC
    ADC #1
    AND #63     ; Wrap back to zero at 64
                ; && comparing will remove binary byte for 64 upwards
                ; video 8 14:30
    STA generate_x
    
    ; Increment generate_counter
    LDA generate_counter
    CLC
    ADC #1
    CMP #LEDGE_DISTANCE
    BCC GenerateColumn_NoCounterWrap
    LDA #0
GenerateColumn_NoCounterWrap:
    STA generate_counter
    RTS