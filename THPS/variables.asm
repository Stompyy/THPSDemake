
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

KONAMI_CHECK_STEP_1 = %00000000
KONAMI_CHECK_STEP_2 = %00000001
KONAMI_CHECK_STEP_3 = %00000011
KONAMI_CHECK_STEP_4 = %00000111
KONAMI_CHECK_STEP_5 = %00001111
KONAMI_CHECK_STEP_6 = %00011111
KONAMI_CHECK_STEP_7 = %00111111
KONAMI_CHECK_STEP_8 = %01111111
KONAMI_CHECK_STEP_9 = %11111111

IS_ANIMATING        = %00000001
IS_GROUNDED         = %00000010
IS_FAKIE            = %00000100
IS_PERFORMING_TRICK = %00001000

TRUE                = 1
FALSE               = 0

MOVEMENT_SPEED              = 1
ANIM_FRAME_CHANGE_TIME      = 8
TRAFFIC_CONE_WIDTH          = 8

SCREEN_BOTTOM_Y             = 206   ; 224, 240 PAL
GRIND_HEIGHT                = SCREEN_BOTTOM_Y - 7
GRIND_THRESHOLD             = GRIND_HEIGHT - 6  ; trigger the grind a bit above the grind height to keep player sprite head level

START_OF_LEDGE_MARKER_SCROLL    = $D9
START_OF_LEDGE_MARKER_PAGE      = 0
END_OF_LEDGE_MARKER_SCROLL      = $D1
END_OF_LEDGE_MARKER_PAGE        = 1


GRAVITY                     = 10     ; In subpixels/frame^2
JUMP_FORCE                  = -(1 * 256 + 128)  ; In subpixels/frame
KONAMI_JUMP_FORCE           = -(2 * 256 + 128)

FRICTION                    = -2
PUSH_FORCE                  = 2 * 256 + 128  ; In subpixels/frame
BRAKE_FORCE                 = 1 * 256; + 128  ; In subpixels/frame

NUMBER_OF_TRAFFIC_CONES     = 2
TRAFFIC_CONE_HITBOX_HEIGHT  = 8
TRAFFIC_CONE_HITBOX_WIDTH   = 8

NUMBER_OF_LEDGE_BLOCKS      = 10

GAMESTATE_TITLE             = 0
GAMESTATE_CONTROLS          = 1
GAMESTATE_PREGAME           = 2
GAMESTATE_PLAY              = 3

;----------------------------------------
;;; All get initialised to zero
    .rsset $0000        ; Start counter at this, then .rs 1 increments
joypad1_state                   .rs 1

current_animation_start_tile    .rs 1
running_tile_count              .rs 1
target_tile_count               .rs 1
current_animation_starting_anim_offset  .rs 1   ; 8-bit binary number fine if all animations are less than 255 frames in total
animation_frame_timer           .rs 1

; Consider having all these single bit bools kept in one player_state byte.
; Can use AND or CMP >= (or combination) to check is_grounded etc
player_state                    .rs 1
; 76543210
; |||||||+-- is animating
; ||||||+--- is grounded
; |||||+---- is fakie (riding backwards e.g. after a 180 trick)
; ||||+----- is mid performing trick
; |||+------ is grinding ledge
; ||+-------
; |+-------- is Konami God mode (jump force increased)
; +---------

is_animating                    .rs 1
is_grounded                     .rs 1
is_fakie                        .rs 1
is_grinding                     .rs 1
is_performing_trick             .rs 1
is_konami_god_mode              .rs 1
is_title_screen                 .rs 1
gameStateMachine                .rs 1   ; 0 is title screen
                                        ; 1 is controls screen
                                        ; 2 is playing game

player_downward_speed           .rs 2   ; In subpixel per frame - 16 bits
player_position_sub             .rs 1   ; in subpixels
delta_Y                         .rs 1   ; The product of the carry flag subpixel calculations

forward_speed                   .rs 2   ; In subpixel per frame - 16 bits
forward_speed_sub               .rs 1   ; in subpixels
delta_X                         .rs 1   ; The product of the carry flag subpixel calculations

scroll_x                        .rs 1
scroll_page                     .rs 1

seed                            .rs 2
generate_x                      .rs 1   ; which column to generate next
                                        ; could be any of 63  
generate_counter                .rs 1
generate_length_length          .rs 1

title_screen_load_counter       .rs 1
title_screen_load_target        .rs 1
title_screen_load_current_Y     .rs 1

konami_code_running_check       .rs 1
konami_current_press_checked    .rs 1

generate_game_background_row_counter .rs 1
should_generate_game_background .rs 1
current_nametable_generating    .rs 1

title_screen_flash_timer        .rs 1

    .rsset $0200
sprite_player                   .rs 4 * 6
sprite_traffic_cones            .rs 4 * NUMBER_OF_TRAFFIC_CONES
sprite_text_blanking_box_white  .rs 4 * 5
sprite_ledge                    .rs 4 * NUMBER_OF_LEDGE_BLOCKS

    .rsset $0000
SPRITE_Y            .rs 1
SPRITE_TILE         .rs 1
SPRITE_ATTRIB       .rs 1
SPRITE_X            .rs 1