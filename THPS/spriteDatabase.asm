;----------------------------------------
;;;;;;;----------SPRITES----------;;;;;;;
;----------------------------------------
    ; y,  tile,  attrib, x
obstacle_offscreen_traffic_cone_info:
    .db $C7, $F1, $00, $EE
;----------------------------------------
playerSpritesDB:
    ; Player idle
    .db $00, $5A, $00, $20
    .db $00, $01, $00, $28
    .db $00, $10, $00, $20
    .db $00, $11, $00, $28
    .db $00, $20, $00, $20
    .db $00, $21, $00, $28
;----------------------------------------
whiteBlankBoxDB:
; Blocks the 'press start' message on the title screen to make it flash
    .db $5A, $38, $01, $70
    .db $5A, $38, $01, $78
    .db $5A, $38, $01, $80
    .db $5A, $38, $01, $88
    .db $5A, $38, $01, $90
;----------------------------------------
TRAFFIC_CONE_DB_LENGTH      = 4
PLAYER_SPRITE_DB_LENGTH     = 24
WHITE_BLANK_BOX_DB_LENGTH   = 20
LENGTH_OF_ONE_SPRITE        = 4
;----------------------------------------