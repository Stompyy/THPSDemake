;----------------------------------------
;;;;;;;----------SPRITES----------;;;;;;;
;----------------------------------------
    ; y,  tile,  attrib, x
trafficConeSprite:
    .db $C7, $F1, $00, $EE
;----------------------------------------
playerSprite:
    ; Player idle as default
    .db $00, $5A, $00, $20
    .db $00, $01, $00, $28
    .db $00, $10, $00, $20
    .db $00, $11, $00, $28
    .db $00, $20, $00, $20
    .db $00, $21, $00, $28
;----------------------------------------
whiteBlankBoxSprite:
    ; Blocks the 'press start' message on the title screen to make it flash
    .db $5A, $38, $01, $70
    .db $5A, $38, $01, $78
    .db $5A, $38, $01, $80
    .db $5A, $38, $01, $88
    .db $5A, $38, $01, $90
;----------------------------------------
ScoreSprite:
    ; First three are the text "Score: ", Last sprite is the number default zero $F6
    .db $50, $F3, $00, $70
    .db $50, $F4, $00, $78
    .db $50, $F5, $00, $80
    .db $50, $F6, $00, $88
;----------------------------------------
numberSprites:
    ;   0    1    2    3    4    5    6    7    8    9
    .db $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
;----------------------------------------
; Lengths declared to refer to when looping through the sprite values
TRAFFIC_CONE_DB_LENGTH      = 4
PLAYER_SPRITE_DB_LENGTH     = 24
WHITE_BLANK_BOX_DB_LENGTH   = 20
SCORE_SPRITE_DB_LENGTH      = 20

LENGTH_OF_ONE_SPRITE        = 4
;----------------------------------------