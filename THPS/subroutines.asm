;----------------------------------------
;;;;;;;;;----SUBROUTINES----;;;;;;;;;
;----------------------------------------
; Many of these subroutines are single use 'singleton style' lumps of code that would be slightly more efficent
; if written in situ. For the sake of the readability of the main game loop and maintainability, have chosen
; to abstract these out to here.
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
; Again for better readability of main game loop, have abstracted these load sprites out into 'singleton style' subroutines
;----------------------------------------
; Load the player sprite
LoadPlayer:
    LDX #0
.LoadPlayerSprite_Next:
    LDA playerSprite, X
    STA sprite_player, X
    INX
    CPX #PLAYER_SPRITE_DB_LENGTH
    BNE .LoadPlayerSprite_Next  
    RTS
;----------------------------------------
; Load the score sprite
LoadScore:
    LDX #0
.LoadScoreSprite_Next:
    LDA ScoreSprite, X
    STA sprite_score_text, X
    INX
    CPX #SCORE_SPRITE_DB_LENGTH
    BNE .LoadScoreSprite_Next  
    RTS
;----------------------------------------
; Load the traffic cone sprite
LoadTrafficCone:
    LDX #0
.NewCone_Loop:
    LDA trafficConeSprite, X
    STA sprite_traffic_cones, X
    INX
    CPX #LENGTH_OF_ONE_SPRITE
    BNE .NewCone_Loop
    RTS
;----------------------------------------
; Load in the text blanking white rect that is used to make title screen text flash
LoadWhiteTextBlockingBox:
    LDX #0
.LoadBlankSprite_Next:
    LDA whiteBlankBoxSprite, X
    STA sprite_text_blanking_box_white, X
    INX
    CPX #WHITE_BLANK_BOX_DB_LENGTH
    BNE .LoadBlankSprite_Next
    RTS
;----------------------------------------
; Moves the obstacles (just traffic cones currently) to mirror the background scroll
Update_Obstacle_X_Positions:
    LDX #SPRITE_X
    LDY #0
.Update_traffic_cones_Loop:         ; Loop currently not used as only one traffic cone
    LDA sprite_traffic_cones, X     ; Otherwise would loop through for each cone
    SEC
    SBC delta_X                     ; Change the SPRITE_X value to mirror the background scolling
    STA sprite_traffic_cones, X
    INX                             ; X+=4, move to the next cone's SPRITE_X location
    INX
    INX
    INX
    INY                             ; Increment the Y (look at next cone?)
    CPY #NUMBER_OF_TRAFFIC_CONES
    BNE .Update_traffic_cones_Loop
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
    ADC forward_speed+1             ; Add on the player forward speed High value including the important carry flag value
    BMI .UpdateSpeed_ZeroSpeed
    STA delta_X                     ; delta_x is used as a horizontal position for on screen obstacles and background scroll
    RTS
.UpdateSpeed_ZeroSpeed:             ; Zero everything
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
    LDA #0                          ; set player_downward_speed to 0
    STA player_downward_speed
    STA player_downward_speed+1
    LDA is_grounded                 ; Check if player is coming from a (NOT is_grounded) state
    CMP #FALSE
    BEQ UpdatePlayer_SetGroundedAnim    ; If so then set a landing animation
    RTS                             ; else return
UpdatePlayer_SetGroundedAnim:
    LDA #TRUE                       ; Set is_grounded to true
    STA is_grounded
    ; Set land anim between regular, fakie, or fall
    LDA is_performing_trick         ; If is mid performing a trick, then the player falls
    CMP #TRUE
    BEQ .UpdatePlayer_SetFallAnim
    LDA is_fakie                    ; If successful landing, then check if player is backwards (fakie) or not
    CMP #TRUE
    BEQ .UpdatePlayer_SetFakieLandAnim
    Animation_SetUp #ANIM_OFFSET_LAND_REGULAR, #TOTAL_ANIM_TILES_LAND_REGULAR   ; Regular landing
    RTS
.UpdatePlayer_SetFakieLandAnim:   
    LDA #FALSE                      ; Reset is_fakie bool to false
    STA is_fakie
    Animation_SetUp #ANIM_OFFSET_LAND_FAKIE, #TOTAL_ANIM_TILES_LAND_FAKIE       ; Fakie landing
    RTS
.UpdatePlayer_SetFallAnim:
    Animation_SetUp #ANIM_OFFSET_FALL, #TOTAL_ANIM_TILES_FALL                   ; Unsuccessful landing = fall
    JSR ResetScore                  ; Set score to zero
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
; Generates a column of background tiles in the appropriate memory position for the first nametable (no ledge)
GenerateGameBackground_Column:
    LDA #%00000100      ; Put PPU into skip 32 mode instead of 1
    STA PPUCTRL         ; Have to restore back to previous values later

    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    LDA current_nametable_generating
    STA PPUADDR
    LDA generate_x
    STA PPUADDR

    LDA #$00            ; Load in one row of blank to account for PAL displays
    STA PPUDATA

    LDA #MAX_CLOUD_PROBABILITY  ; initialise the cloud probability to max value
    STA cloud_probability

    LDY #8              ; Use Y reg here as GetRandomTile clobbers X register
                        ; Any more than 10 will take up too many CPU cycles
.GenerateRandomClouds:  ; Load four tiles of randomly generated cloud tiles
    JSR GetRandomTile   ; Places the tile into the X register
    STX PPUDATA
    DEY
    BNE .GenerateRandomClouds

    LDX #17             ; 30 rows = 1 blank + 8 clouds + 17 sky + 1 floor + 3 bricks underground
    LDA #$00            ; Location of an empty tile in the sprite sheet
.GenerateEmptyTile:
    STA PPUDATA
    DEX
    BNE .GenerateEmptyTile
    LDA #$F0            ; Load one tile of floor
    STA PPUDATA
    LDX #3              ; Load three tiles of underground
    LDA #$F2            ; Underground tile location
.GenerateBricks:        ; Fill last 3 rows with brick tiles
    STA PPUDATA
    DEX
    BNE .GenerateBricks

    INC generate_x      ; Increment the counter/memory offset manager

    LDA #0              ; Have to force the scrolls back to #0 after generation
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%00000000      ; Set back to normal skip mode
    STA PPUCTRL
    RTS
;----------------------------------------
; Generates a column of background tiles in the appropriate memory position for the second nametable (with ledge)
GenerateGameBackground_ColumnWithLedge:
    ; PPUCTRL flag. 
    LDA #%00000100      ; Put PPU into skip 32 mode instead of 1
    STA PPUCTRL         ; Have to restore back to previous values later

    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    ; Set the PPUADDR as the preset variable, and offset into by the generate_x that increments with each generation
    LDA current_nametable_generating
    STA PPUADDR
    LDA generate_x
    STA PPUADDR

    LDA #$00            ; Load in one row of blank to account for PAL displays
    STA PPUDATA

    LDA #MAX_CLOUD_PROBABILITY  ; initialise the cloud probability to max value
    STA cloud_probability

    LDY #8              ; Use Y reg here as GetRandomTile clobbers X register
                        ; Any more than 10 will take up too many CPU cycles
                        ; 8 is an effective amount for the desired effect
.GenerateRandomClouds:  ; Load four tiles of randomly generated cloud tiles
    JSR GetRandomTile   ; Places the tile into the X register
    STX PPUDATA
    DEY
    BNE .GenerateRandomClouds

    LDX #16             ; 30 rows = 1 blank + 8 clouds + 16 sky + 1 ledge + 1 floor + 3 bricks underground
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
.GenerateBricks:
    STA PPUDATA
    DEX
    BNE .GenerateBricks
    INC generate_x      ; Increment the counter/memory offset manager
    LDA #0              ; Have to force the scrolls back to #0 after generation
    STA PPUSCROLL
    STA PPUSCROLL
    LDA #%00000000      ; Set back to normal skip mode
    STA PPUCTRL
    RTS
;----------------------------------------
; Will use the pseudo random number generator to randomly choose an empty tile or a patterned tile based on weighting
; Store that tile address value into the A register
GetRandomTile:
    JSR prng                ; Clobbers X register. Fills A register with an 8 bit random number
    CLC
    CMP cloud_probability  ;#CLOUD_PROBABILITY  ; weighting out of 0-255 of choice to get an empty tile. >= #128 is 0.5 chance of each tile
    BCS .ReturnEmptyTile
    LDX #$6F                ; Location of cloud tile
    JMP .DecreaseProbability
.ReturnEmptyTile:
    LDX #$00                ; Location of empty tile
.DecreaseProbability:       ; Decrease the probability each iteration to blend clouds into background
    LDA cloud_probability
    SEC
    SBC #CLOUD_PROBABILITY_DROP
    STA cloud_probability
    RTS
;----------------------------------------
; Uses the white blanking box sprite to cover and reveal the title screen text, to seem to flash
Title_FlashMessage:
    LDX title_screen_flash_timer                    ; Increment timer
    INX
    CPX #FLASH_FRAME_CHANGE_TIME                    ; Is it time to change visibility?
    BEQ .ChangeVisability
    STX title_screen_flash_timer                    ; Update timer
    RTS
.ChangeVisability:
    LDX #WHITE_BLANK_BOX_DB_LENGTH + SPRITE_ATTRIB  ; Start at the last tile in the white box
.ChangeNextTile:
    LDA sprite_text_blanking_box_white, X
    EOR #%00100000                                  ; Flip the sprite priority to change visibility
    STA sprite_text_blanking_box_white, X
    DEX                                             ; Move to next tile
    DEX
    DEX
    DEX
    BPL .ChangeNextTile
    LDX #0                                          ; Reset the timer
    STX title_screen_flash_timer
    ; Update the sprites (doesn't happen automatically during title screens)
    LDA #0
    STA OAMADDR
    LDA #$02
    STA OAMDMA
    RTS
;----------------------------------------
Title_RemoveWhiteBox:
    LDA #0                                          ; Set the X position as out of the way
    LDX #WHITE_BLANK_BOX_DB_LENGTH + SPRITE_X       ; Start at the last tile in the white box
.ChangeNextTile:
    STA sprite_text_blanking_box_white, X
    DEX
    DEX
    DEX
    DEX
    BPL .ChangeNextTile
    ; Update the sprites (doesn't happen automatically during title screens)
    LDA #0
    STA OAMADDR
    LDA #$02
    STA OAMDMA
    RTS
;----------------------------------------
; Checks the background scroll information to see if the player sprite has reached the end of the ledge
; If so then disengages from the grind (only called when is_grinding == true)
Grind_CheckForEndOfLedge:
    LDA scroll_page                     ; First check if on the right nametable page
    CMP #END_OF_LEDGE_MARKER_PAGE
    BEQ .CheckPosition                  ; If so check position
    RTS                                 ; else, break early return
.CheckPosition:
    LDA scroll_x                        ; Then check if position has overrun the set value
    CLC
    CMP #END_OF_LEDGE_MARKER_SCROLL
    BCS .FallOfEndOfLedge               ; if so then set is_grinding to false
    RTS
.FallOfEndOfLedge:
    LDA #FALSE
    STA is_grinding
    RTS
;----------------------------------------
; Increments the score variable, uses that variable to look up the appropriate sprite for that value
; and changes the number tile to the correct one
IncrementScore:
    LDX score
    CLC
    CPX #MAX_SCORE_NUMBER_BEFORE_WRAP       ; Currently scores go 0-9, then wraps back to zero, I know - if more time would like to have made a proper scoring system
    BCS .setToZero
    INX                                     ; Increment the X reg for sprite offset
    JMP .changeSprite
.setToZero:
    LDX #0                                  ; Set the X reg for sprite offset to zero
.changeSprite:
    STX score                               ; Update the score value
    LDA numberSprites, X                    ; Get the appropriate sprite for that value
    STA sprite_score_number + SPRITE_TILE   ; Update the sprite tile
    RTS
;----------------------------------------
; Sets the score to zero and changes the score sprite tile to be zero
ResetScore:
    LDX #0
    STX score
    LDA numberSprites
    STA sprite_score_number + SPRITE_TILE
    RTS
;----------------------------------------