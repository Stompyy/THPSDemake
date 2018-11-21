;----------------------------------------
;;;;;;;-----------MACROS----------;;;;;;;
;----------------------------------------
Player_Move .macro
; parameters: 
; @Param \1 move amount
; @Param \2 move axis
; Loop through each tile, altering the move axis by the move amount
    LDX #PLAYER_SPRITE_DB_LENGTH - LENGTH_OF_ONE_SPRITE     ; Start the offset at the start of the last sprite
.MoveEachTile_loop:
    LDA sprite_player + \1, X
    CLC
    ADC \2
    STA sprite_player + \1, X
    SEC
    DEX                     ; Step to the next tile
    DEX
    DEX
    DEX
    BMI .done               ; If X falls below 0 then the minus flag will be set
    JMP .MoveEachTile_loop  ; Else repeat for next tile
.done
    .endm
;----------------------------------------
; Courtesy of the live coding instruction videos supplied with the course materials
CheckCollisionWithCone .macro  
; parameters: 
; \1 object_x
; \2 object_y,
; \3 object_hitbox_x
; \4 object_hitbox_y,
; \5 object_hitbox_w
; \6 object_hitbox_h
; \7 no_collision_label

; If there is a collision, execution continues immediately after this macro
; Else, jump to no_collision_label

    LDA sprite_traffic_cones + SPRITE_X
    .if \3 > 0
    SEC
    SBC \3    ; Adjust for the bullet image position
                            ; within the sprite, from the sprite's 
                            ; origin at the top left (x, y)
    .endif
    SEC
    SBC \5 + 1
    CMP \1
    BCS \7

    CLC 
    ADC \5 + 1 + TRAFFIC_CONE_HITBOX_WIDTH 
            ; Reverses the minus from before and adds 8 again
            ; Takes advantage of Value already in Accumulator
    CMP \1
    BCC \7

    LDA sprite_traffic_cones + SPRITE_Y
    .if \4 > 0
    SEC
    SBC \4
    .endif
    SEC
    SBC \6 + 1
    CMP \2
    BCS \7

    CLC
    ADC \6 + 1 + TRAFFIC_CONE_HITBOX_HEIGHT
    CMP \2
    BCC \7
    .endm
;----------------------------------------
Animation_SetUp .macro
; parameters: 
; @Param \1 Anim offset into animation .db memory
; @Param \2 Total anim tiles for that anim sequence
    LDA #TRUE
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
Player_Set_Y_Position .macro
; parameters: 
; @Param \1 Y position
    LDX #0
    LDY #0
    LDA \1
    SEC
    SBC #PLAYER_PIXEL_HEIGHT - 1    ; We start at the top of the player_sprite. -1 to align the sprite with the floor tile
.MoveEachTile_loop\@:               ; This \@ symbol is replaced with a individual marker to allow multiple replications of the macro without cross calling labels
    STA sprite_player + SPRITE_Y, X ; Overwrite the value for each tile + SPRITE_Y
    INX                             ; X+=4 to look at the tile to the side of the previous one
    INX
    INX
    INX
    STA sprite_player + SPRITE_Y, X ; Overwrite the value for this tile + SPRITE_Y as well
    CPY #PLAYER_TILE_HEIGHT - 1     ; Have we just looked at the last row? Starting tile + 2 tiles = 3 tiles tall
    BEQ .done\@
    CLC
    ADC #TILE_SIZE
    INX                             ; X+=4 to look at the next tile
    INX
    INX
    INX
    INY                             ; Increment the tile height count
    JMP .MoveEachTile_loop\@
.done\@:
    .endm
;----------------------------------------