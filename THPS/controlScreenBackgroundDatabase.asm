controls:
    ; Title
    .db $E0, $E0, $E0, $E0, $E0, $E0, $6A, $6B, $6C, $6D, $E0, $E0, $E0, $E0, $E0, $E0
    .db $E0, $E0, $E0, $E0, $E0, $6E, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    ; On ground                                      In air
    .db $E0, $7A, $7B, $7C, $7D, $7E, $7F, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    .db $E0, $8A, $8B, $8C, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    .db $E0, $9A, $9B, $9C, $9D, $9E, $9F, $E0, $E0, $BA, $BB, $BC, $E0, $E0, $E0, $E0
    .db $E0, $AA, $AB, $AC, $AD, $AE, $AF, $E0, $E0, $CA, $CB, $CC, $CD, $CE, $CF, $E0
    .db $E0, $C0, $C1, $C2, $E0, $E0, $E0, $E0, $E0, $DA, $DB, $DC, $DD, $DE, $DF, $E0
    .db $E0, $D0, $D1, $D2, $D3, $E0, $E0, $E0, $E0, $EA, $EB, $EC, $ED, $EE, $EF, $E0
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $C0, $8D, $8E, $8F, $E0, $E0, $E0
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $D0, $E1, $E2, $E3, $E0, $E0, $E0
    
    ; Grinds
    .db $E0, $E0, $E0, $E0, $BD, $BE, $BF, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $C4, $C5, $C6, $C7, $C8, $C9, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $D4, $D5, $D6, $D7, $D8, $D9, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E4, $E5, $E6, $E7, $E8, $E9, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0 
stillframes_showcase:    
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $04, $05, $E0, $04, $05, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $06, $07, $08, $09, $E0, $E0, $E0, $E0, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $04, $05, $E0, $14, $15, $E0, $14, $15, $E0, $66, $67, $E0, $60, $61, $E0, $16, $17, $18, $19, $0A, $0B, $E0, $E0, $E0 
    .db $E0, $E0, $5A, $01, $E0, $02, $03, $E0, $14, $15, $E0, $44, $45, $E0, $54, $55, $E0, $76, $77, $E0, $70, $71, $E0, $36, $37, $46, $47, $1A, $1B, $0C, $0D, $E0 
    .db $E0, $E0, $10, $11, $E0, $12, $13, $E0, $34, $35, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $86, $87, $E0, $80, $81, $E0, $E0, $E0, $E0, $E0, $56, $57, $1C, $1D, $E0 
    .db $E0, $E0, $20, $21, $E0, $22, $23, $E0, $E0, $E0, $E0, $E0, $E0, $F1, $E0, $E0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $E0, $E0, $E0, $E0, $E0, $E0, $2C, $2D, $E0 
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
                                                                            ; "A : Play"
    .db $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $C0, $97, $98, $99, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
;------------------------------------------
ENVELOPE_WIDTH      = 8     ; The width of the surrounding envelope sections
                            ; 2 * ENVELOPE_WIDTH + IMAGE_WIDTH = 32 (full width of screen in tiles)
IMAGE_WIDTH         = 16

