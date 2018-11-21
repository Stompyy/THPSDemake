;----------------------------------------
;;;;;;;----------PALETTES---------;;;;;;;
;----------------------------------------
sprite_palettes:
    .db $30, $0F, $27, $2C  ; Player sprite / Title screens
    .db $0F, $30, $30, $30  ; White text blanking box

background_palettes:
    .db $30, $0F, $27, $2C  ; Player sprite / Title screens
    .db $30, $3D, $2D, $37  ; Background
    .db $0F, $00, $31, $3D  ; Ledge
;----------------------------------------
SPRITE_PALETTES_LENGTH      = 8
BACKGROUND_PALETTES_LENGTH  = 12
;----------------------------------------