    .inesprg 1   ; 1 x bank of 16KB PRG code
    .ineschr 1   ; 1 x bank of 8KB CHR data
    .inesmap 0   ; mapper 0 = NROM, no bank swapping
    .inesmir 1   ; background mirroring
    
    .bank 0
    .org $C000
;------------------------------------------
PPUCTRL     = $2000
PPUMASK     = $2001
PPUSTATUS   = $2002
OAMADDR     = $2003     ; Objective attribute memory
OAMDATA     = $2004
PPUSCROLL   = $2005
PPUADDR     = $2006
PPUDATA     = $2007
OAMDMA      = $4014
JOYPAD1     = $4016
JOYPAD2     = $4017

BUTTON_A        = %10000000
BUTTON_B        = %01000000
BUTTON_SELECT   = %00100000
BUTTON_START    = %00010000
BUTTON_UP       = %00001000
BUTTON_DOWN     = %00000100
BUTTON_LEFT     = %00000010
BUTTON_RIGHT    = %00000001

MOVEMENT_SPEED              = 1
ANIM_FRAME_CHANGE_TIME      = 8

TOTAL_ANIM_TILES_IDLE       = 6 * 1
TOTAL_ANIM_TILES_PUSH       = 6 * 3
TOTAL_ANIM_TILES_OLLIE      = 6 * 2
TOTAL_ANIM_TILES_NOLLIE     = 6 * 2
TOTAL_ANIM_TILES_INAIR      = 6 * 1
TOTAL_ANIM_TILES_KICKFLIP   = 6 * 4
TOTAL_ANIM_TILES_BSFLIP     = 6 * 4
TOTAL_ANIM_TILES_TREFLIP    = 6 * 4
TOTAL_ANIM_TILES_POPSHUV    = 6 * 4
TOTAL_ANIM_TILES_BS180      = 6 * 3
TOTAL_ANIM_TILES_FALL       = 6 * 4
TOTAL_ANIM_TILES_5050       = 6 * 1
TOTAL_ANIM_TILES_50         = 6 * 1
TOTAL_ANIM_TILES_CROOKED    = 6 * 1
TOTAL_ANIM_TILES_NOSEGRIND  = 6 * 1
TOTAL_ANIM_TILES_BLUNTSLIDE = 6 * 1
TOTAL_ANIM_TILES_BRAKE      = 6 * 1
TOTAL_ANIM_TILES_LAND_REGULAR = 6 * 2
TOTAL_ANIM_TILES_LAND_FAKIE = 6 * 2 
; 254 bit max count of 42*6 tiles
; Either work around this with 16-bit
; Or work off frames not tiles prob best

; Offset of tile information into the animations .db
ANIM_OFFSET_IDLE        = 0
ANIM_OFFSET_PUSH        = ANIM_OFFSET_IDLE       + TOTAL_ANIM_TILES_IDLE
ANIM_OFFSET_OLLIE       = ANIM_OFFSET_PUSH       + TOTAL_ANIM_TILES_PUSH
ANIM_OFFSET_NOLLIE      = ANIM_OFFSET_OLLIE      + TOTAL_ANIM_TILES_OLLIE
ANIM_OFFSET_INAIR       = ANIM_OFFSET_NOLLIE     + TOTAL_ANIM_TILES_NOLLIE
ANIM_OFFSET_KICKFLIP    = ANIM_OFFSET_INAIR      + TOTAL_ANIM_TILES_INAIR
ANIM_OFFSET_BSFLIP      = ANIM_OFFSET_KICKFLIP   + TOTAL_ANIM_TILES_KICKFLIP
ANIM_OFFSET_TREFLIP     = ANIM_OFFSET_BSFLIP     + TOTAL_ANIM_TILES_BSFLIP
ANIM_OFFSET_POPSHUV     = ANIM_OFFSET_TREFLIP    + TOTAL_ANIM_TILES_TREFLIP
ANIM_OFFSET_BS180       = ANIM_OFFSET_POPSHUV    + TOTAL_ANIM_TILES_POPSHUV
ANIM_OFFSET_FALL        = ANIM_OFFSET_BS180      + TOTAL_ANIM_TILES_BS180
ANIM_OFFSET_5050        = ANIM_OFFSET_FALL       + TOTAL_ANIM_TILES_FALL
ANIM_OFFSET_50          = ANIM_OFFSET_5050       + TOTAL_ANIM_TILES_5050
ANIM_OFFSET_CROOKED     = ANIM_OFFSET_50         + TOTAL_ANIM_TILES_50
ANIM_OFFSET_NOSEGRIND   = ANIM_OFFSET_CROOKED    + TOTAL_ANIM_TILES_CROOKED
ANIM_OFFSET_BLUNTSLIDE  = ANIM_OFFSET_NOSEGRIND  + TOTAL_ANIM_TILES_NOSEGRIND
ANIM_OFFSET_BRAKE       = ANIM_OFFSET_BLUNTSLIDE + TOTAL_ANIM_TILES_BLUNTSLIDE
ANIM_OFFSET_LAND_REGULAR = ANIM_OFFSET_BRAKE      + TOTAL_ANIM_TILES_BRAKE
ANIM_OFFSET_LAND_FAKIE  = ANIM_OFFSET_LAND_REGULAR + TOTAL_ANIM_TILES_LAND_REGULAR

SCREEN_BOTTOM_Y             = 204   ; 224, 240 PAL
GRAVITY                     = 10     ; In subpixels/frame^2
JUMP_FORCE                  = -(1 * 256 + 128)  ; In subpixels/frame

;----------------------------------------
;;; All get initialised to zero
    .rsset $0000        ; Start counter at this, then .rs 1 increments
joypad1_state                   .rs 1
jump_y_momentum                 .rs 1
literal_jump_momentum           .rs 1

current_animation_start_tile    .rs 1
running_tile_count              .rs 1
target_tile_count               .rs 1
current_animation_starting_anim_offset  .rs 1   ; 8-bit binary number fine if all animations are less than 255 frames in total
animation_frame_timer           .rs 1
is_animating                    .rs 1
is_grounded                     .rs 1
is_fakie                        .rs 1
player_downward_speed           .rs 2   ; In subpixel per frame - 16 bits
player_position_sub             .rs 1   ; in subpixels
delta_Y                         .rs 1   ; The product of the carry flag subpixel calculations

    .rsset $0200
sprite_player       .rs 4 * 6

    .rsset $0000
SPRITE_Y            .rs 1
SPRITE_TILE         .rs 1
SPRITE_ATTRIB       .rs 1
SPRITE_X            .rs 1
;----------------------------------------

; 2270 CPU cycles per frame

RESET:
    SEI          ; disable (ignore) IRQs
    CLD          ; disable decimal mode
    LDX #$40
    STX $4017    ; disable APU frame IRQ
    LDX #$FF
    TXS          ; Set up stack
    INX          ; now X = 0
    STX PPUCTRL    ; disable NMI
    STX PPUMASK    ; disable rendering
    STX $4010    ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; If the user presses Reset during vblank, the PPU may reset
    ; with the vblank flag still true. This has about a 1 in 13
    ; chance of happening on NTSC or  2 in 9 on PAL. Clear the
    ; flag now so the vblankwait1 loop sees an actual vblank.
    BIT PPUSTATUS

vblankwait1:       ; First wait for vblank to make sure PPU is ready
    BIT PPUSTATUS
    BPL vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS. Conveniently, X is still 0.
    TXA

clrmem:
    LDA #$0
    STA $000, x
    STA $100, x
    STA $300, x
    STA $400, x
    STA $500, x
    STA $600, x
    STA $700, x   ; Remove this if you are storing reset-persistant data

    ; We skipped $200, x on purpose. Usually RAM page 2 is used for the
    ; display list to be copied to OAM. OAM needs to be initialised to
    ; $EF-$FF, not 0, or you'll get a bunch of garbage sprites at (0, 0).

    LDA #$FF
    STA $200, x     ; Reserved for the sprites

    INX
    BNE clrmem
  
    ; Other things you can do between vblank waits are set up audio 
    ; or set up other mapper registers.
   

vblankwait2:      ; Second wait for vblank, PPU is ready after this
    BIT PPUSTATUS
    BPL vblankwait2

    ; End of initialisation code

    JSR InitialiseGame


    LDA #%10000000  ; Enable NMI
    STA PPUCTRL

    LDA #%00011000  ; Enable sprites and background
    STA PPUMASK

    LDA #0
    STA PPUSCROLL   ; Set x scroll
    STA PPUSCROLL   ; Set y scroll
; End of initialisation code

; Enter an infinite loop
Forever:
    JMP Forever     ; Jump back to Forever, infinite loop

;----------------------------------------
InitialiseGame:

    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    ; Write address 3F00 (Background palette) to the PPU
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    LDX #0

LoadPalette_BackgroundLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #4
    BNE LoadPalette_BackgroundLoop    

    ; Write address 3F10 (sprite palette) to the PPU next
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR
    
    LDX #4
LoadPalette_SpriteLoop:
    LDA palettes, X
    STA PPUDATA
    INX
    CPX #8
    BNE LoadPalette_SpriteLoop   

    ; Load the player sprite
    LDX #0
.LoadSprite_Next:
    LDA sprites, X
    STA sprite_player, X
    INX
    CPX #24  ; Just one (8x8 * 6) sprite loading currently. NumSprites * 4
    BNE .LoadSprite_Next

    ; Load attribute data that each 16 x 16 uses
    LDA #$23        ; Write address $23C0 to PPUADDR register
    STA PPUADDR     ; PPUADDR is big endian for some reason??
    LDA #$C0
    STA PPUADDR

    LDA #%00000000  ; set all to first colour palette
    LDX #64
LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE LoadAttributes_Loop

    ; Load attribute data
    LDA #$27
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%00000000
    LDX #64
LoadAttributes2_Loop:
    STA PPUDATA
    DEX
    BNE LoadAttributes2_Loop

    LDA #1
    STA is_grounded

    RTS ; End subroutine (returns back to the point it was called)

;----------------------------------------
;;;;;;;----MACROS----;;;;;;
;----------------------------------------
Player_Move .macro
; @Param \1 move amount
; @Param \2 move axis
    LDX #20
.MoveEachTile_loop:
    LDA sprite_player + \1, X
    CLC
    ADC \2
    STA sprite_player + \1, X
    SEC
    DEX
    DEX
    DEX
    DEX
    BMI .done
    JMP .MoveEachTile_loop
.done
    .endm
;----------------------------------------
Animation_SetUp .macro
; @Param \1 Anim offset into animation .db memory
; @Param \2 Total anim tiles for that anim sequence
    LDA #1
    STA is_animating
    LDA \1
    STA current_animation_starting_anim_offset
    CLC
    ADC \2                  ; Set the end point
    STA target_tile_count
    LDA #0                  ; Set the animation timer as zero
    STA animation_frame_timer
    STA running_tile_count
    .endm
;----------------------------------------
Player_Set_Position .macro
; @Param \1 move amount
; @Param \2 move axis
    LDX #20
    LDY #16
.MoveEachTile_loop2:
    TYA
    
    CLC
    ADC \2
    STA sprite_player + \1, X
    SEC
    DEX
    DEX
    DEX
    DEX
    STA sprite_player + \1, X
    SEC

    DEX
    DEX
    DEX
    DEX

    DEY
    DEY
    DEY
    DEY
    DEY
    DEY
    DEY
    DEY

    BMI .done2
    JMP .MoveEachTile_loop2
.done2
    .endm
;----------------------------------------

NMI:        ; Non maskable interrupt

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
    LDA is_animating
    AND 0
    BNE ReadLeft_Done
    ; Set up the BSFLIP animation
    Animation_SetUp #ANIM_OFFSET_BSFLIP, #TOTAL_ANIM_TILES_BSFLIP
    LDA #1
    STA is_fakie    ; To tell use the landing animation
    Player_Move SPRITE_X, #-MOVEMENT_SPEED
ReadLeft_Done:

    ; React to Right button
    LDA joypad1_state
    AND #BUTTON_RIGHT
    BEQ ReadRight_Done
    LDA is_animating
    AND 0
    BNE ReadRight_Done
    ; Set up the KICKFLIP animation
    Animation_SetUp #ANIM_OFFSET_KICKFLIP, #TOTAL_ANIM_TILES_KICKFLIP
    Player_Move SPRITE_X, #MOVEMENT_SPEED
ReadRight_Done:

    ; React to Up button
    LDA joypad1_state
    AND #BUTTON_UP
    BEQ ReadUp_Done
    LDA is_animating
    AND 0
    BNE ReadUp_Done
    ; Set up the POPSHUV animation
    Animation_SetUp #ANIM_OFFSET_POPSHUV, #TOTAL_ANIM_TILES_POPSHUV
ReadUp_Done:

    ; React to Down button
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ ReadDown_Done
    LDA is_animating
    AND 0
    BNE ReadDown_Done
    ; Set up the TREFLIP animation
    Animation_SetUp #ANIM_OFFSET_TREFLIP, #TOTAL_ANIM_TILES_TREFLIP
ReadDown_Done:

    ; React to A button
    LDA joypad1_state
    AND #BUTTON_A
    BEQ ReadA_Done
    LDA is_animating
    AND 0
    BNE ReadA_Done
    ; Set up the OLLIE animation
    Animation_SetUp #ANIM_OFFSET_OLLIE, #TOTAL_ANIM_TILES_OLLIE
    ; Ollie (set player downward speed to jump force)
    LDA #LOW(JUMP_FORCE)
    STA player_downward_speed
    LDA #HIGH(JUMP_FORCE)
    STA player_downward_speed + 1
    ; Move off the ground to allow forces
    Player_Move SPRITE_Y, #-1
    ; Change bool
    LDA #0
    STA is_grounded
ReadA_Done:

    ; React to B button
    LDA joypad1_state
    AND #BUTTON_B
    BEQ ReadB_Done
    LDA is_animating
    AND 0
    BNE ReadB_Done
    ; Set up the NOLLIE animation
    Animation_SetUp #ANIM_OFFSET_NOLLIE, #TOTAL_ANIM_TILES_NOLLIE
    ; Ollie (set player downward speed to jump force)
    LDA #LOW(JUMP_FORCE)
    STA player_downward_speed
    LDA #HIGH(JUMP_FORCE)
    STA player_downward_speed + 1
    ; Move off the ground to allow forces
    Player_Move SPRITE_Y, #-1
    ; Change bool
    LDA #0
    STA is_grounded
ReadB_Done:

;ReadControls_Done:

    JSR UpdateGravity

    LDA is_animating
    AND #1
    BEQ .SkipAnimUpdate
    JSR UpdateAnimation
.SkipAnimUpdate

    ; Copy sprite data to the PPU
    LDA #0
    STA OAMADDR
    LDA #$02    ; Location of the sprite? In memory
    STA OAMDMA

    RTI     ; Return from interrupt

;----------------------------------------
;;;;;;;;;----SUBROUTINES----;;;;;;;;;
;----------------------------------------
LoadNextPlayerSprite:
; Just change the tile data
    LDX current_animation_starting_anim_offset
    LDY #1   ; Offset of the tile in memory
.LoadTile_Next:
    LDA animations, X ; load in the next tile from the .db
    STA sprite_player, Y
    INX             ; Increment the running tile count for the anim
    CPY #21         ; Check if it has just done the last tile 
    BEQ .anim_frameComplete
    INY             ; move to the next tile descriptor in the sprite
    INY
    INY
    INY
    JMP .LoadTile_Next
.anim_frameComplete
    CPX target_tile_count   ; Check if we've reached the end of the anim sequence
    BNE .skipReset
    LDA #0                  ; If equal, then set is_animating to false
    CLC
    STA is_animating
    RTS
.skipReset
    STX current_animation_starting_anim_offset  ; Update the runniing count for the next frame
    RTS
;----------------------------------------
UpdateAnimation:
; Check the timer to see if new animation tileset needed
    LDX animation_frame_timer
    CPX #ANIM_FRAME_CHANGE_TIME
    BNE .NoNewAnimNeeded
    ; Change tile to next one
    JSR LoadNextPlayerSprite
    ; Reset the timer
    LDA #0
    STA animation_frame_timer
    JMP .SkipIncrement
.NoNewAnimNeeded:
    INX
    STX animation_frame_timer
.SkipIncrement:
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
    AND #1
    BEQ UpdatePlayer_SetGroundedAnim
    RTS
UpdatePlayer_SetGroundedAnim:
    LDA #1
    STA is_grounded

    ; Set land anim between regular, fakie, or fall
    LDA is_animating
    AND #1
    BNE .UpdatePlayer_SetFallAnim
    LDA is_fakie
    AND #1
    BNE .UpdatePlayer_SetFakieLandAnim
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

;----------------------------------------
palettes:
    .db $31, $3D, $3D, $31  ; Background
    .db $30, $0F, $27, $2C  ; Player sprite

;----------------------------------------

;----------------------------------------

;----------------------------------------

; Tile addresses
animations:
    ; Idle:
    .db $00, $01, $10, $11, $20, $21
    ; Push:
    .db $30, $31, $40, $41, $50, $51
    .db $32, $33, $42, $43, $52, $53
    .db $00, $01, $10, $11, $20, $21
    ; Ollie:
    .db $02, $03, $12, $13, $22, $23
    .db $04, $05, $14, $15, $24, $25
    ; Nollie:
    .db $60, $61, $70, $71, $80, $81
    .db $04, $05, $14, $15, $24, $25
    ; InAir:
    .db $04, $05, $14, $15, $24, $25
    ; kickflip:
    .db $04, $05, $14, $15, $34, $35
    .db $04, $05, $14, $15, $44, $45
    .db $04, $05, $14, $15, $54, $55
    .db $04, $05, $14, $15, $24, $25
    ; BSideflip_1:
    .db $06, $07, $16, $17, $36, $37
    .db $08, $09, $18, $19, $46, $47
    .db $0A, $0B, $1A, $1B, $56, $57
    .db $0A, $0B, $1A, $1B, $2A, $2B
    ;anim_treflip:
    .db $04, $05, $14, $15, $38, $39
    .db $04, $05, $14, $15, $48, $49
    .db $04, $05, $14, $15, $58, $59
    .db $04, $05, $14, $15, $24, $25
    ;anim_popshuv:
    .db $04, $05, $14, $15, $3A, $3B
    .db $04, $05, $14, $15, $4A, $4B
    .db $04, $05, $14, $15, $3A, $3B
    .db $04, $05, $14, $15, $24, $25
    ;anim_Bs180:
    .db $06, $07, $16, $17, $26, $27
    .db $08, $09, $18, $19, $28, $29
    .db $0A, $0B, $1A, $1B, $2A, $2B
    ;anim_Fall:
    .db $90, $91, $A0, $A1, $B0, $B1
    .db $92, $93, $A2, $A3, $B2, $B3
    .db $94, $95, $A4, $A5, $B4, $B5
    .db $96, $97, $A6, $A7, $B6, $B7

    ;anim_5050:
    .db $3C, $3D, $4C, $4D, $5C, $5D
    ;anim_50:
    .db $62, $63, $72, $73, $82, $83
    ;anim_Crooked:
    .db $64, $65, $74, $75, $84, $85
    ;anim_Nosegrind:
    .db $66, $67, $76, $77, $86, $87
    ;anim_Bluntslide:
    .db $68, $69, $78, $79, $88, $89

    ;anim_Brake
    .db $3E, $3F, $4E, $4F, $5E, $5F
    ;anim_land_regular
    .db $3C, $3D, $4C, $4D, $5C, $5D
    .db $00, $01, $10, $11, $20, $21
    ;anim_land_fakie
    .db $0C, $0D, $1C, $1D, $2C, $2D
    .db $0E, $0F, $1E, $1F, $2E, $2F
    .db $30, $31, $40, $41, $50, $51
    .db $32, $33, $42, $43, $52, $53
    .db $00, $01, $10, $11, $20, $21
;----------------------------------------
sprites:    ; y,  tile,  attrib, x
    ; Player idle
    .db $80, $00, $00, $20
    .db $80, $01, $00, $28
    .db $88, $10, $00, $20
    .db $88, $11, $00, $28
    .db $90, $20, $00, $20
    .db $90, $21, $00, $28
;----------------------------------------
    .bank 1
    .org $FFFA      ; First of the three vectors starts here
    .dw NMI         ; When an NMI happens (once per frame if enabled) the processor will jump to the label NMI:
    .dw RESET       ; When the processor first turns on or is reset, it will jump to the label RESET:
    .dw 0           ; (Audio) External interrupt IRQ is not used in this tutorial
;----------------------------------------
    .bank 2
    .org $0000
    .incbin "THPS.chr"