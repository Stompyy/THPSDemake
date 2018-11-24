;----------------------------------------
;;;;;;;----ANIMATIONS-DATABASE----;;;;;;;
;----------------------------------------
; Tile addresses
animations:
    ; Idle:
    .db $5A, $01, $10, $11, $20, $21
    ; Push:
    .db $30, $31, $40, $41, $50, $51
    .db $32, $33, $42, $43, $52, $53
    .db $5A, $01, $10, $11, $20, $21
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
    ; BSideflip:
    .db $06, $07, $16, $17, $36, $37
    .db $08, $09, $18, $19, $46, $47
    .db $0A, $0B, $1A, $1B, $56, $57
    .db $0A, $0B, $1A, $1B, $2A, $2B
    ; Treflip:
    .db $04, $05, $14, $15, $38, $39
    .db $04, $05, $14, $15, $48, $49
    .db $04, $05, $14, $15, $58, $59
    .db $04, $05, $14, $15, $24, $25
    ; Popshuv:
    .db $04, $05, $14, $15, $3A, $3B
    .db $04, $05, $14, $15, $4A, $4B
    .db $04, $05, $14, $15, $3A, $3B
    .db $04, $05, $14, $15, $24, $25
    ; BS180:
    .db $06, $07, $16, $17, $26, $27
    .db $08, $09, $18, $19, $28, $29
    .db $0A, $0B, $1A, $1B, $2A, $2B
    ; Fall:
    .db $90, $91, $A0, $A1, $B0, $B1
    .db $92, $93, $A2, $A3, $B2, $B3
    .db $94, $95, $A4, $A5, $B4, $B5
    .db $96, $96, $A6, $A7, $B6, $B7

    ; 5050:
    .db $3C, $3D, $4C, $4D, $5C, $5D
    ; 50:
    .db $62, $63, $72, $73, $82, $83
    ; Crooked:
    .db $64, $65, $74, $75, $84, $85
    ; Nosegrind:
    .db $66, $67, $76, $77, $86, $87
    ; Bluntslide:
    .db $68, $69, $78, $79, $88, $89

    ; Brake
    .db $3E, $3F, $4E, $4F, $5E, $5F
    ; Land regular
    .db $3C, $3D, $4C, $4D, $5C, $5D
    .db $5A, $01, $10, $11, $20, $21
    ; Land fakie
    .db $0C, $0D, $1C, $1D, $2C, $2D
    .db $0E, $0F, $1E, $1F, $2E, $2F
    .db $30, $31, $40, $41, $50, $51
    .db $32, $33, $42, $43, $52, $53
    .db $5A, $01, $10, $11, $20, $21
    
;------------------------------------------
; Total tiles for each animation
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
;------------------------------------------
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
ANIM_OFFSET_LAND_REGULAR = ANIM_OFFSET_BRAKE     + TOTAL_ANIM_TILES_BRAKE
ANIM_OFFSET_LAND_FAKIE  = ANIM_OFFSET_LAND_REGULAR + TOTAL_ANIM_TILES_LAND_REGULAR
;------------------------------------------