;----------------------------------------
;;;;;;;--------ANIMATIONS --------;;;;;;;
;----------------------------------------
ANIM_FRAME_CHANGE_TIME      = 8
;----------------------------------------
; Check the timer to see if new animation tileset needed
UpdateAnimation:
    LDX animation_frame_timer
    CPX #ANIM_FRAME_CHANGE_TIME
    BNE .NoNewAnimNeeded
    ; Change tile to next one in the database
    JSR LoadNextPlayerSprite
    LDA #0                          ; Reset the timer
    STA animation_frame_timer
    JMP .SkipIncrement
.NoNewAnimNeeded:
    INC animation_frame_timer       ; Increment the timer
.SkipIncrement:
    RTS
;----------------------------------------
; Just change the tile data
LoadNextPlayerSprite:
    LDX current_animation_starting_anim_offset
    LDY #SPRITE_TILE                ; Load in the offset
.LoadTile_Next:
    LDA animations, X               ; load in the next tile from the .db
    STA sprite_player, Y
    INX                             ; Increment the running tile count for the anim
    CPY #PLAYER_SPRITE_DB_LENGTH - LENGTH_OF_ONE_SPRITE + SPRITE_TILE             ; Check if it has just done the last tile 
    BEQ .anim_frameComplete
    INY                             ; move to the next tile descriptor in the sprite
    INY
    INY
    INY
    JMP .LoadTile_Next
.anim_frameComplete
    CPX target_tile_count           ; Check if we've reached the end of the anim sequence
    BNE .skipReset
    LDA #FALSE                      ; If equal, then set is_animating to false
    STA is_animating
    STA is_performing_trick
    RTS
.skipReset
    STX current_animation_starting_anim_offset  ; Update the running count for the next frame
    RTS
;----------------------------------------