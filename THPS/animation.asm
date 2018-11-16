

;----------------------------------------
LoadNextPlayerSprite:
; Just change the tile data
    LDX current_animation_starting_anim_offset
    LDY #1                  ; Offset of the tile in memory
.LoadTile_Next:
    LDA animations, X       ; load in the next tile from the .db
    STA sprite_player, Y
    INX                     ; Increment the running tile count for the anim
    CPY #21                 ; Check if it has just done the last tile 
    BEQ .anim_frameComplete
    INY                     ; move to the next tile descriptor in the sprite
    INY
    INY
    INY
    JMP .LoadTile_Next
.anim_frameComplete
    CPX target_tile_count   ; Check if we've reached the end of the anim sequence
    BNE .skipReset
    LDA #0                  ; If equal, then set is_animating to false
    STA is_animating
    STA is_performing_trick
    RTS
.skipReset
    STX current_animation_starting_anim_offset  ; Update the running count for the next frame
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