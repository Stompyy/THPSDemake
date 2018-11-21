;----------------------------------------
;;;;;;;---------VARIABLES---------;;;;;;;
;----------------------------------------
;;; CONSTANTS
;----------------------------------------
PPUCTRL     = $2000
PPUMASK     = $2001
PPUSTATUS   = $2002
OAMADDR     = $2003
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

; Flags for konami code. Not currently used sadly...
KONAMI_CHECK_STEP_1 = %00000000
KONAMI_CHECK_STEP_2 = %00000001
KONAMI_CHECK_STEP_3 = %00000011
KONAMI_CHECK_STEP_4 = %00000111
KONAMI_CHECK_STEP_5 = %00001111
KONAMI_CHECK_STEP_6 = %00011111
KONAMI_CHECK_STEP_7 = %00111111
KONAMI_CHECK_STEP_8 = %01111111
KONAMI_CHECK_STEP_9 = %11111111

; Flags for now unused player_state byte
IS_ANIMATING        = %00000001
IS_GROUNDED         = %00000010
IS_FAKIE            = %00000100
IS_PERFORMING_TRICK = %00001000
IS_GRINDING         = %00010000

; For bool checking in a readable way
TRUE                            = 1
FALSE                           = 0

TILE_SIZE                       = 8
PLAYER_TILE_HEIGHT              = 3
PLAYER_PIXEL_HEIGHT             = TILE_SIZE * PLAYER_TILE_HEIGHT 

MOVEMENT_SPEED                  = 1
FLASH_FRAME_CHANGE_TIME         = 10        ; The number of frames for the flashing 'press start' message to take before changing
TRAFFIC_CONE_WIDTH              = 8

SCREEN_BOTTOM_Y                 = 206       ; the player_sprite grounded height
NUMBER_OF_TILES_PER_ROW         = 32

GRIND_HEIGHT                    = SCREEN_BOTTOM_Y - 7   ; Grind height is 1 pixel less than a full grid piece above to allow a slight overlap
                                                        ; for grind sprites (see front wheel on crooked grind)
GRIND_THRESHOLD                 = GRIND_HEIGHT - 6      ; Trigger the grind a bit above the grind height to keep player sprite head level

START_OF_LEDGE_MARKER_SCROLL    = $D9       ; The scroll_x value at which the player_sprite is at the start of the ledge
START_OF_LEDGE_MARKER_PAGE      = 0         ; The scroll_page value at which the player_sprite is at the start of the ledge
END_OF_LEDGE_MARKER_SCROLL      = $D1       ; The scroll_x value at which the player_sprite is at the end of the ledge
END_OF_LEDGE_MARKER_PAGE        = 1         ; The scroll_page value at which the player_sprite is at the end of the ledge

GRAVITY                         = 10        ; In subpixels/frame^2
JUMP_FORCE                      = -400      ; In subpixels/frame
;KONAMI_JUMP_FORCE               = JUMP_FORCE * 2

FRICTION                        = -2
PUSH_FORCE                      = 650       ; In subpixels/frame
BRAKE_FORCE                     = 250       ; In subpixels/frame

NUMBER_OF_TRAFFIC_CONES         = 1
TRAFFIC_CONE_HITBOX_HEIGHT      = 8
TRAFFIC_CONE_HITBOX_WIDTH       = 8

;----------------------------------------
;;; Variables. All get initialised to zero
    .rsset $0000                                ; Start counter at this, then .rs 1 increments
joypad1_state                           .rs 1

current_animation_start_tile            .rs 1
running_tile_count                      .rs 1
target_tile_count                       .rs 1
current_animation_starting_anim_offset  .rs 1   ; 8-bit binary number fine if all animations are less than 255 frames in total
animation_frame_timer                   .rs 1

title_screen_flash_timer                .rs 1   ; The running timer for the "press start" flashing message on the title screen

; Consider having all these single bit bools kept in one player_state byte
player_state                            .rs 1
; 76543210
; |||||||+-- is animating
; ||||||+--- is grounded
; |||||+---- is fakie (riding backwards e.g. after a 180 trick)
; ||||+----- is mid performing trick
; |||+------ is grinding ledge
; ||+-------
; |+-------- 
; +--------- is Konami God mode (jump force increased)
;----------------------------------------
; Have since decided against this. Maintainability and readability are far better using TRUE or FALSE checks
; For completeness, implementation would be:
;   LDA player_state AND #flag == 0                 (if '1-bit' in flag is not present in player_state)
;   LDA player_state ORA #flag STA player_state     (to set the '1-bit' in flag in player_state)
;   LDA player_state SEC SBC #flag                  (to remove the '1-bit' in flag in player_state. Bit should be present before trying to remove)
;----------------------------------------

is_animating                    .rs 1   ; Should animations be updated
is_grounded                     .rs 1   ; Is the player on the ground
is_fakie                        .rs 1   ; Riding backwards e.g. after a 180 trick
is_grinding                     .rs 1   ; Is grinding the ledge
is_performing_trick             .rs 1   ; One trick at a time fellas
;is_konami_god_mode              .rs 1   ; If there was enough time to implement this...

gameStateMachine                .rs 1   ; 0 is title screen
                                        ; 1 is controls screen
                                        ; 2 is pre game
                                        ; 3 is playing game
                                        ; All set as constants above

player_downward_speed           .rs 2   ; In subpixel per frame - 16 bits
player_position_sub             .rs 1   ; in subpixels
delta_Y                         .rs 1   ; The product of the carry flag subpixel calculations

forward_speed                   .rs 2   ; In subpixel per frame - 16 bits
forward_speed_sub               .rs 1   ; in subpixels
delta_X                         .rs 1   ; The product of the carry flag subpixel calculations

scroll_x                        .rs 1   ; The x movement 
scroll_page                     .rs 1   ; the current nametable page

seed                            .rs 2
generate_x                      .rs 1   ; The background column being generated

current_nametable_generating    .rs 1   ; Keeps track of which nametable we are currently generatng a background for
background_load_counter         .rs 1   ; Counters and targets for loading in the title and control screen backgrounds
background_load_target          .rs 1
background_load_current_Y       .rs 1

;konami_code_running_check       .rs 1
;konami_current_press_checked    .rs 1

;----------------------------------------
; Store all sprites together at $0200
    .rsset $0200
sprite_player                   .rs 4 * 6
sprite_traffic_cones            .rs 4 * NUMBER_OF_TRAFFIC_CONES
sprite_text_blanking_box_white  .rs 4 * 5
;----------------------------------------
; Sprite information
    .rsset $0000
SPRITE_Y                        .rs 1
SPRITE_TILE                     .rs 1
SPRITE_ATTRIB                   .rs 1
SPRITE_X                        .rs 1
;----------------------------------------