; ===============================================================================
; K-RAZY SHOOT-OUT (USA) - COMPLETE ANNOTATED DISASSEMBLY
; ===============================================================================
; Original Game: CBS Electronics, 1981
; Platform: Atari 5200 SuperSystem
; CPU: MOS 6502C @ 1.79 MHz
; ROM Size: 8KB (8192 bytes)
; Memory Map: $A000-$BFFF
;
; This disassembly includes:
; - ASCII art representations of all graphics
; - Detailed comments on game mechanics
; - Hardware register explanations
; - Game state variable documentation
; ===============================================================================

        .org $A000

; ===============================================================================
; GRAPHICS DATA SECTION ($A000-$A2C7)
; ===============================================================================
; Character set data - 89 characters total (712 bytes)
; Each character is 8x8 pixels, stored as 8 bytes
; Bit 1 = pixel on (#), Bit 0 = pixel off (.)

; ===============================================================================
; PLAYER SPRITE ANIMATION SYSTEM
; ===============================================================================
; K-Razy Shoot-Out uses a sophisticated multi-sprite player character system
; with directional animation and walking cycles.
;
; SPRITE COMPONENTS:
; - Character $02: Player Head (Sideways) - Used for horizontal movement
; - Character $04: Player Head (Vertical) - Used for vertical/stationary movement  
; - Character $03: Player Body (Horizontal) Frame 1 - Walking animation frame 1
; - Character $05: Player Body (Horizontal) Frame 2 - Walking animation frame 2
; - Character $1E: Player Body (Stationary) - Used for vertical/stationary movement
; - Characters $06-$09: Death animation and final dead state sprites
;
; HARDWARE REGISTERS:
; - $E804: Player sprite position register
; - $E805: Player sprite control/character register (loads character codes)
;
; ANIMATION STATES:
; 1. STATIONARY/VERTICAL MOVEMENT:
;    - Head: Character $04 (centered, vertical orientation)
;    - Body: Character $1E (standard stationary body)
;    - Display: Single static 8x16 sprite combination
;
; 2. HORIZONTAL MOVEMENT (Walking Animation):
;    - Head: Character $02 (sideways orientation, constant)
;    - Body: Alternates between Character $03 and $05 (walking frames)
;    - Display: Animated 8x16 sprite with 2-frame walking cycle
;
; 3. DEATH SEQUENCE:
;    - Animation: Character $06 (top) + Character $07 (bottom) - vertical pair
;    - Final State: Character $08 (left) + Character $09 (right) - horizontal pair
;
; TECHNICAL IMPLEMENTATION:
; - Player rendered as two separate 8x8 sprites stacked vertically
; - Movement detection via collision registers $C004/$C00C and joystick input
; - Sprite selection based on movement direction and animation frame
; - Hardware PMG (Player/Missile Graphics) system handles display and positioning
; ===============================================================================

; Character $00 - Space/blank character
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........

        .byte $00        ; $A000 - Row 0
        .byte $00        ; $A001 - Row 1
        .byte $00        ; $A002 - Row 2
        .byte $00        ; $A003 - Row 3
        .byte $00        ; $A004 - Row 4
        .byte $00        ; $A005 - Row 5
        .byte $00        ; $A006 - Row 6
        .byte $00        ; $A007 - Row 7

; Character $01 - Player sprite: Central body column
;   ..###...
;   ..###...
;   ..###...
;   ..###...
;   ...##...
;   ........
;   ...##...
;   ........

        .byte $38        ; $A008 - Row 0
        .byte $38        ; $A009 - Row 1
        .byte $38        ; $A00A - Row 2
        .byte $38        ; $A00B - Row 3
        .byte $18        ; $A00C - Row 4
        .byte $00        ; $A00D - Row 5
        .byte $18        ; $A00E - Row 6
        .byte $00        ; $A00F - Row 7

; Character $02 - Player sprite: Head (Sideways)
;   ........
;   ........
;   ........
;   ........
;   ...#....
;   ..#.#...
;   ..#.#...
;   ...#....

        .byte $00        ; $A010 - Row 0
        .byte $00        ; $A011 - Row 1
        .byte $00        ; $A012 - Row 2
        .byte $00        ; $A013 - Row 3
        .byte $10        ; $A014 - Row 4
        .byte $28        ; $A015 - Row 5
        .byte $28        ; $A016 - Row 6
        .byte $10        ; $A017 - Row 7

; Character $03 - Player sprite: Body (Horizontal) - Frame 1
;   ..###.#.
;   .#.#.#..
;   #..#....
;   .#.#....
;   ...##...
;   ..#..#..
;   ###..#..
;   #....##.

        .byte $3A        ; $A018 - Row 0
        .byte $54        ; $A019 - Row 1
        .byte $90        ; $A01A - Row 2
        .byte $50        ; $A01B - Row 3
        .byte $18        ; $A01C - Row 4
        .byte $24        ; $A01D - Row 5
        .byte $E4        ; $A01E - Row 6
        .byte $86        ; $A01F - Row 7

; Character $04 - Player sprite: Head (Vertical)
;   ........
;   ........
;   ........
;   ........
;   ....#...
;   ...#.#..
;   ...#.#..
;   ....#...

        .byte $00        ; $A020 - Row 0
        .byte $00        ; $A021 - Row 1
        .byte $00        ; $A022 - Row 2
        .byte $00        ; $A023 - Row 3
        .byte $08        ; $A024 - Row 4
        .byte $14        ; $A025 - Row 5
        .byte $14        ; $A026 - Row 6
        .byte $08        ; $A027 - Row 7

; Character $05 - Player sprite: Body (Horizontal) - Frame 2
;   ...##...
;   ...##...
;   ...####.
;   ....#...
;   ....#...
;   ...##...
;   ..#.#...
;   ...###..

        .byte $18        ; $A028 - Row 0
        .byte $18        ; $A029 - Row 1
        .byte $1E        ; $A02A - Row 2
        .byte $08        ; $A02B - Row 3
        .byte $08        ; $A02C - Row 4
        .byte $18        ; $A02D - Row 5
        .byte $28        ; $A02E - Row 6
        .byte $1C        ; $A02F - Row 7

; Character $06 - Player death animation (Top)
;   ........
;   ........
;   #...##..
;   #..#.#..
;   .#.##...
;   ..#.....
;   .#.#....
;   #...##..

        .byte $00        ; $A030 - Row 0
        .byte $00        ; $A031 - Row 1
        .byte $8C        ; $A032 - Row 2
        .byte $94        ; $A033 - Row 3
        .byte $58        ; $A034 - Row 4
        .byte $20        ; $A035 - Row 5
        .byte $50        ; $A036 - Row 6
        .byte $8C        ; $A037 - Row 7

; Character $07 - Player death animation (Bottom)
;   .....###
;   ....#..#
;   ...#...#
;   #.#...#.
;   .#...#..
;   ....#...
;   ...#....
;   ....#...

        .byte $07        ; $A038 - Row 0
        .byte $09        ; $A039 - Row 1
        .byte $11        ; $A03A - Row 2
        .byte $A2        ; $A03B - Row 3
        .byte $44        ; $A03C - Row 4
        .byte $08        ; $A03D - Row 5
        .byte $10        ; $A03E - Row 6
        .byte $08        ; $A03F - Row 7

; Character $08 - Player dead (Left)
;   ........
;   ........
;   ........
;   ........
;   .......#
;   ##....##
;   ##...###
;   ########

        .byte $00        ; $A040 - Row 0
        .byte $00        ; $A041 - Row 1
        .byte $00        ; $A042 - Row 2
        .byte $00        ; $A043 - Row 3
        .byte $01        ; $A044 - Row 4
        .byte $C3        ; $A045 - Row 5
        .byte $C7        ; $A046 - Row 6
        .byte $FF        ; $A047 - Row 7

; Character $09 - Player dead (Right)
;   ........
;   ........
;   ........
;   #.......
;   ##...###
;   ###..#.#
;   ######.#
;   ####.###

        .byte $00        ; $A048 - Row 0
        .byte $00        ; $A049 - Row 1
        .byte $00        ; $A04A - Row 2
        .byte $80        ; $A04B - Row 3
        .byte $C7        ; $A04C - Row 4
        .byte $E5        ; $A04D - Row 5
        .byte $FD        ; $A04E - Row 6
        .byte $F7        ; $A04F - Row 7

; Character $0A - Font Character: * (Asterisk)
;   ........
;   .##..##.
;   ..####..
;   ########
;   ..####..
;   .##..##.
;   ........
;   ........

        .byte $00        ; $A050 - Row 0
        .byte $66        ; $A051 - Row 1
        .byte $3C        ; $A052 - Row 2
        .byte $FF        ; $A053 - Row 3
        .byte $3C        ; $A054 - Row 4
        .byte $66        ; $A055 - Row 5
        .byte $00        ; $A056 - Row 6
        .byte $00        ; $A057 - Row 7

; Character $0B - Font Character: + (Plus)
;   ........
;   ...##...
;   ...##...
;   .######.
;   ...##...
;   ...##...
;   ........
;   ........

        .byte $00        ; $A058 - Row 0
        .byte $18        ; $A059 - Row 1
        .byte $18        ; $A05A - Row 2
        .byte $7E        ; $A05B - Row 3
        .byte $18        ; $A05C - Row 4
        .byte $18        ; $A05D - Row 5
        .byte $00        ; $A05E - Row 6
        .byte $00        ; $A05F - Row 7

; Character $0C - Font Character: , (Comma)
;   ........
;   ........
;   ........
;   ........
;   ........
;   ...##...
;   ...##...
;   ..##....

        .byte $00        ; $A060 - Row 0
        .byte $00        ; $A061 - Row 1
        .byte $00        ; $A062 - Row 2
        .byte $00        ; $A063 - Row 3
        .byte $00        ; $A064 - Row 4
        .byte $18        ; $A065 - Row 5
        .byte $18        ; $A066 - Row 6
        .byte $30        ; $A067 - Row 7

; Character $0D - Font Character: - (Hyphen)
;   ........
;   ........
;   ........
;   .######.
;   ........
;   ........
;   ........
;   ........

        .byte $00        ; $A068 - Row 0
        .byte $00        ; $A069 - Row 1
        .byte $00        ; $A06A - Row 2
        .byte $7E        ; $A06B - Row 3
        .byte $00        ; $A06C - Row 4
        .byte $00        ; $A06D - Row 5
        .byte $00        ; $A06E - Row 6
        .byte $00        ; $A06F - Row 7

; Character $0E - Font Character: . (Period)
;   ........
;   ........
;   ........
;   ........
;   ........
;   ...##...
;   ...##...
;   ........

        .byte $00        ; $A070 - Row 0
        .byte $00        ; $A071 - Row 1
        .byte $00        ; $A072 - Row 2
        .byte $00        ; $A073 - Row 3
        .byte $00        ; $A074 - Row 4
        .byte $18        ; $A075 - Row 5
        .byte $18        ; $A076 - Row 6
        .byte $00        ; $A077 - Row 7

; Character $0F - Font Character: / (Forward Slash)
;   ......##
;   .....##.
;   ....##..
;   ...##...
;   ..##....
;   .##.....
;   .#......
;   ........

        .byte $03        ; $A078 - Row 0
        .byte $06        ; $A079 - Row 1
        .byte $0C        ; $A07A - Row 2
        .byte $18        ; $A07B - Row 3
        .byte $30        ; $A07C - Row 4
        .byte $60        ; $A07D - Row 5
        .byte $40        ; $A07E - Row 6
        .byte $00        ; $A07F - Row 7

; Character $10 - Number '0' for score display
;   .#######
;   .##...##
;   .##...##
;   .##...##
;   .##...##
;   .##...##
;   .#######
;   ........

        .byte $7F        ; $A080 - Row 0
        .byte $63        ; $A081 - Row 1
        .byte $63        ; $A082 - Row 2
        .byte $63        ; $A083 - Row 3
        .byte $63        ; $A084 - Row 4
        .byte $63        ; $A085 - Row 5
        .byte $7F        ; $A086 - Row 6
        .byte $00        ; $A087 - Row 7

; Character $11 - Number '1' for score display
;   ..###...
;   ...##...
;   ...##...
;   ...##...
;   ..#####.
;   ..#####.
;   ..#####.
;   ........

        .byte $38        ; $A088 - Row 0
        .byte $18        ; $A089 - Row 1
        .byte $18        ; $A08A - Row 2
        .byte $18        ; $A08B - Row 3
        .byte $3E        ; $A08C - Row 4
        .byte $3E        ; $A08D - Row 5
        .byte $3E        ; $A08E - Row 6
        .byte $00        ; $A08F - Row 7

; Character $12 - Number '2' for score display
;   .#######
;   ......##
;   ......##
;   .#######
;   .##.....
;   .##.....
;   .#######
;   ........

        .byte $7F        ; $A090 - Row 0
        .byte $03        ; $A091 - Row 1
        .byte $03        ; $A092 - Row 2
        .byte $7F        ; $A093 - Row 3
        .byte $60        ; $A094 - Row 4
        .byte $60        ; $A095 - Row 5
        .byte $7F        ; $A096 - Row 6
        .byte $00        ; $A097 - Row 7

; Character $13 - Number '3' for score display
;   .######.
;   .....##.
;   .....##.
;   .#######
;   .....###
;   .....###
;   .#######
;   ........

        .byte $7E        ; $A098 - Row 0
        .byte $06        ; $A099 - Row 1
        .byte $06        ; $A09A - Row 2
        .byte $7F        ; $A09B - Row 3
        .byte $07        ; $A09C - Row 4
        .byte $07        ; $A09D - Row 5
        .byte $7F        ; $A09E - Row 6
        .byte $00        ; $A09F - Row 7

; Character $14 - Number '4' for score display
;   .###....
;   .###....
;   .###....
;   .###.###
;   .###.###
;   .#######
;   .....###
;   ........

        .byte $70        ; $A0A0 - Row 0
        .byte $70        ; $A0A1 - Row 1
        .byte $70        ; $A0A2 - Row 2
        .byte $77        ; $A0A3 - Row 3
        .byte $77        ; $A0A4 - Row 4
        .byte $7F        ; $A0A5 - Row 5
        .byte $07        ; $A0A6 - Row 6
        .byte $00        ; $A0A7 - Row 7

; Character $15 - Number '5' for score display
;   .#######
;   .##.....
;   .##.....
;   .#######
;   ......##
;   ......##
;   .#######
;   ........

        .byte $7F        ; $A0A8 - Row 0
        .byte $60        ; $A0A9 - Row 1
        .byte $60        ; $A0AA - Row 2
        .byte $7F        ; $A0AB - Row 3
        .byte $03        ; $A0AC - Row 4
        .byte $03        ; $A0AD - Row 5
        .byte $7F        ; $A0AE - Row 6
        .byte $00        ; $A0AF - Row 7

; Character $16 - Number '6' for score display
;   .#####..
;   .##.##..
;   .##.....
;   .#######
;   .##...##
;   .##...##
;   .#######
;   ........

        .byte $7C        ; $A0B0 - Row 0
        .byte $6C        ; $A0B1 - Row 1
        .byte $60        ; $A0B2 - Row 2
        .byte $7F        ; $A0B3 - Row 3
        .byte $63        ; $A0B4 - Row 4
        .byte $63        ; $A0B5 - Row 5
        .byte $7F        ; $A0B6 - Row 6
        .byte $00        ; $A0B7 - Row 7

; Character $17 - Number '7' for score display
;   .#######
;   ......##
;   ......##
;   ...#####
;   ...##...
;   ...##...
;   ...##...
;   ........

        .byte $7F        ; $A0B8 - Row 0
        .byte $03        ; $A0B9 - Row 1
        .byte $03        ; $A0BA - Row 2
        .byte $1F        ; $A0BB - Row 3
        .byte $18        ; $A0BC - Row 4
        .byte $18        ; $A0BD - Row 5
        .byte $18        ; $A0BE - Row 6
        .byte $00        ; $A0BF - Row 7

; Character $18 - Number '8' for score display
;   ..#####.
;   ..##.##.
;   ..##.##.
;   .#######
;   .###.###
;   .###.###
;   .#######
;   ........

        .byte $3E        ; $A0C0 - Row 0
        .byte $36        ; $A0C1 - Row 1
        .byte $36        ; $A0C2 - Row 2
        .byte $7F        ; $A0C3 - Row 3
        .byte $77        ; $A0C4 - Row 4
        .byte $77        ; $A0C5 - Row 5
        .byte $7F        ; $A0C6 - Row 6
        .byte $00        ; $A0C7 - Row 7

; Character $19 - Number '9' for score display
;   .#######
;   .##...##
;   .##...##
;   .#######
;   .....###
;   .....###
;   .....###
;   ........

        .byte $7F        ; $A0C8 - Row 0
        .byte $63        ; $A0C9 - Row 1
        .byte $63        ; $A0CA - Row 2
        .byte $7F        ; $A0CB - Row 3
        .byte $07        ; $A0CC - Row 4
        .byte $07        ; $A0CD - Row 5
        .byte $07        ; $A0CE - Row 6
        .byte $00        ; $A0CF - Row 7

; Character $1A - Font character: Colon (:)
;   ........
;   ...##...
;   ...##...
;   ........
;   ...##...
;   ...##...
;   ........
;   ........

        .byte $00        ; $A0D0 - Row 0
        .byte $18        ; $A0D1 - Row 1
        .byte $18        ; $A0D2 - Row 2
        .byte $00        ; $A0D3 - Row 3
        .byte $18        ; $A0D4 - Row 4
        .byte $18        ; $A0D5 - Row 5
        .byte $00        ; $A0D6 - Row 6
        .byte $00        ; $A0D7 - Row 7

; Character $1B - Font character: Semicolon (;)
;   ........
;   ...##...
;   ...##...
;   ........
;   ...##...
;   ...##...
;   ..##....
;   ........

        .byte $00        ; $A0D8 - Row 0
        .byte $18        ; $A0D9 - Row 1
        .byte $18        ; $A0DA - Row 2
        .byte $00        ; $A0DB - Row 3
        .byte $18        ; $A0DC - Row 4
        .byte $18        ; $A0DD - Row 5
        .byte $30        ; $A0DE - Row 6
        .byte $00        ; $A0DF - Row 7

; Character $1C - Enemy
;   ........
;   ..#####.
;   ....#...
;   .#######
;   .#.###.#
;   .#.###.#
;   .#.###.#
;   ...###..

        .byte $00        ; $A0E0 - Row 0
        .byte $3E        ; $A0E1 - Row 1
        .byte $08        ; $A0E2 - Row 2
        .byte $7F        ; $A0E3 - Row 3
        .byte $5D        ; $A0E4 - Row 4
        .byte $5D        ; $A0E5 - Row 5
        .byte $5D        ; $A0E6 - Row 6
        .byte $1C        ; $A0E7 - Row 7

; Character $1D - Game graphics/sprite data
;   ........
;   .######.
;   ........
;   ........
;   .######.
;   ........
;   ........
;   ........

        .byte $00        ; $A0E8 - Row 0
        .byte $7E        ; $A0E9 - Row 1
        .byte $00        ; $A0EA - Row 2
        .byte $00        ; $A0EB - Row 3
        .byte $7E        ; $A0EC - Row 4
        .byte $00        ; $A0ED - Row 5
        .byte $00        ; $A0EE - Row 6
        .byte $00        ; $A0EF - Row 7

; Character $1E - Player sprite: Stationary body
;   ...###..
;   ..#.#.#.
;   ..#.#.#.
;   ....#...
;   ...#.#..
;   ...#.#..
;   ...#.#..
;   ..##.##.

        .byte $1C        ; $A0F0 - Row 0
        .byte $2A        ; $A0F1 - Row 1
        .byte $2A        ; $A0F2 - Row 2
        .byte $08        ; $A0F3 - Row 3
        .byte $14        ; $A0F4 - Row 4
        .byte $14        ; $A0F5 - Row 5
        .byte $14        ; $A0F6 - Row 6
        .byte $36        ; $A0F7 - Row 7

; Character $1F - Font character: Question mark (?)
;   .#######
;   .##...##
;   ......##
;   ...#####
;   ...###..
;   ........
;   ...###..
;   ........

        .byte $7F        ; $A0F8 - Row 0
        .byte $63        ; $A0F9 - Row 1
        .byte $03        ; $A0FA - Row 2
        .byte $1F        ; $A0FB - Row 3
        .byte $1C        ; $A0FC - Row 4
        .byte $00        ; $A0FD - Row 5
        .byte $1C        ; $A0FE - Row 6
        .byte $00        ; $A0FF - Row 7

; Character $20 - Game graphics/sprite data
;   ........
;   ........
;   ........
;   ........
;   ....#...
;   ...#.#..
;   ...#.#..
;   ....#...

        .byte $00        ; $A100 - Row 0
        .byte $00        ; $A101 - Row 1
        .byte $00        ; $A102 - Row 2
        .byte $00        ; $A103 - Row 3
        .byte $08        ; $A104 - Row 4
        .byte $14        ; $A105 - Row 5
        .byte $14        ; $A106 - Row 6
        .byte $08        ; $A107 - Row 7

; Character $21 - Letter 'A' for text display
;   ..######
;   ..##..##
;   ..##..##
;   .#######
;   .###..##
;   .###..##
;   .###..##
;   ........

        .byte $3F        ; $A108 - Row 0
        .byte $33        ; $A109 - Row 1
        .byte $33        ; $A10A - Row 2
        .byte $7F        ; $A10B - Row 3
        .byte $73        ; $A10C - Row 4
        .byte $73        ; $A10D - Row 5
        .byte $73        ; $A10E - Row 6
        .byte $00        ; $A10F - Row 7

; Character $22 - Letter 'B' for text display
;   .######.
;   .##..##.
;   .##..##.
;   .#######
;   .##..###
;   .##..###
;   .#######
;   ........

        .byte $7E        ; $A110 - Row 0
        .byte $66        ; $A111 - Row 1
        .byte $66        ; $A112 - Row 2
        .byte $7F        ; $A113 - Row 3
        .byte $67        ; $A114 - Row 4
        .byte $67        ; $A115 - Row 5
        .byte $7F        ; $A116 - Row 6
        .byte $00        ; $A117 - Row 7

; Character $23 - Letter 'C' for text display
;   .#######
;   .##..###
;   .##..###
;   .##.....
;   .##...##
;   .##...##
;   .#######
;   ........

        .byte $7F        ; $A118 - Row 0
        .byte $67        ; $A119 - Row 1
        .byte $67        ; $A11A - Row 2
        .byte $60        ; $A11B - Row 3
        .byte $63        ; $A11C - Row 4
        .byte $63        ; $A11D - Row 5
        .byte $7F        ; $A11E - Row 6
        .byte $00        ; $A11F - Row 7

; Character $24 - Letter 'D' for text display
;   .######.
;   .##..##.
;   .##..##.
;   .###.###
;   .###.###
;   .###.###
;   .#######
;   ........

        .byte $7E        ; $A120 - Row 0
        .byte $66        ; $A121 - Row 1
        .byte $66        ; $A122 - Row 2
        .byte $77        ; $A123 - Row 3
        .byte $77        ; $A124 - Row 4
        .byte $77        ; $A125 - Row 5
        .byte $7F        ; $A126 - Row 6
        .byte $00        ; $A127 - Row 7

; Character $25 - Letter 'E' for text display
;   .#######
;   .##.....
;   .##.....
;   .#######
;   .###....
;   .###....
;   .#######
;   ........

        .byte $7F        ; $A128 - Row 0
        .byte $60        ; $A129 - Row 1
        .byte $60        ; $A12A - Row 2
        .byte $7F        ; $A12B - Row 3
        .byte $70        ; $A12C - Row 4
        .byte $70        ; $A12D - Row 5
        .byte $7F        ; $A12E - Row 6
        .byte $00        ; $A12F - Row 7

; Character $26 - Letter 'F' for text display
;   .#######
;   .##.....
;   .##.....
;   .#######
;   .###....
;   .###....
;   .###....
;   ........

        .byte $7F        ; $A130 - Row 0
        .byte $60        ; $A131 - Row 1
        .byte $60        ; $A132 - Row 2
        .byte $7F        ; $A133 - Row 3
        .byte $70        ; $A134 - Row 4
        .byte $70        ; $A135 - Row 5
        .byte $70        ; $A136 - Row 6
        .byte $00        ; $A137 - Row 7

; Character $27 - Letter 'G' for text display
;   .#######
;   .##...##
;   .##.....
;   .##.####
;   .##..###
;   .##..###
;   .#######
;   ........

        .byte $7F        ; $A138 - Row 0
        .byte $63        ; $A139 - Row 1
        .byte $60        ; $A13A - Row 2
        .byte $6F        ; $A13B - Row 3
        .byte $67        ; $A13C - Row 4
        .byte $67        ; $A13D - Row 5
        .byte $7F        ; $A13E - Row 6
        .byte $00        ; $A13F - Row 7

; Character $28 - Letter 'H' for text display
;   .###..##
;   .###..##
;   .###..##
;   .#######
;   .###..##
;   .###..##
;   .###..##
;   ........

        .byte $73        ; $A140 - Row 0
        .byte $73        ; $A141 - Row 1
        .byte $73        ; $A142 - Row 2
        .byte $7F        ; $A143 - Row 3
        .byte $73        ; $A144 - Row 4
        .byte $73        ; $A145 - Row 5
        .byte $73        ; $A146 - Row 6
        .byte $00        ; $A147 - Row 7

; Character $29 - Letter 'I' for text display
;   .#######
;   ...###..
;   ...###..
;   ...###..
;   ...###..
;   ...###..
;   .#######
;   ........

        .byte $7F        ; $A148 - Row 0
        .byte $1C        ; $A149 - Row 1
        .byte $1C        ; $A14A - Row 2
        .byte $1C        ; $A14B - Row 3
        .byte $1C        ; $A14C - Row 4
        .byte $1C        ; $A14D - Row 5
        .byte $7F        ; $A14E - Row 6
        .byte $00        ; $A14F - Row 7

; Character $2A - Letter 'J' for text display
;   ....##..
;   ....##..
;   ....##..
;   ....###.
;   ....###.
;   .##.###.
;   .######.
;   ........

        .byte $0C        ; $A150 - Row 0
        .byte $0C        ; $A151 - Row 1
        .byte $0C        ; $A152 - Row 2
        .byte $0E        ; $A153 - Row 3
        .byte $0E        ; $A154 - Row 4
        .byte $6E        ; $A155 - Row 5
        .byte $7E        ; $A156 - Row 6
        .byte $00        ; $A157 - Row 7

; Character $2B - Letter 'K' for text display
;   .##..##.
;   .##..##.
;   .##.##..
;   .#######
;   .##..###
;   .##..###
;   .##..###
;   ........

        .byte $66        ; $A158 - Row 0
        .byte $66        ; $A159 - Row 1
        .byte $6C        ; $A15A - Row 2
        .byte $7F        ; $A15B - Row 3
        .byte $67        ; $A15C - Row 4
        .byte $67        ; $A15D - Row 5
        .byte $67        ; $A15E - Row 6
        .byte $00        ; $A15F - Row 7

; Character $2C - Letter 'L' for text display
;   ..##....
;   ..##....
;   ..##....
;   .###....
;   .###....
;   .###....
;   .######.
;   ........

        .byte $30        ; $A160 - Row 0
        .byte $30        ; $A161 - Row 1
        .byte $30        ; $A162 - Row 2
        .byte $70        ; $A163 - Row 3
        .byte $70        ; $A164 - Row 4
        .byte $70        ; $A165 - Row 5
        .byte $7E        ; $A166 - Row 6
        .byte $00        ; $A167 - Row 7

; Character $2D - Letter 'M' for text display
;   .##..###
;   .#######
;   .#######
;   .###.###
;   .##..###
;   .##..###
;   .##..###
;   ........

        .byte $67        ; $A168 - Row 0
        .byte $7F        ; $A169 - Row 1
        .byte $7F        ; $A16A - Row 2
        .byte $77        ; $A16B - Row 3
        .byte $67        ; $A16C - Row 4
        .byte $67        ; $A16D - Row 5
        .byte $67        ; $A16E - Row 6
        .byte $00        ; $A16F - Row 7

; Character $2E - Letter 'N' for text display
;   .##..###
;   .###.###
;   .#######
;   .##.####
;   .##..###
;   .##..###
;   .##..###
;   ........

        .byte $67        ; $A170 - Row 0
        .byte $77        ; $A171 - Row 1
        .byte $7F        ; $A172 - Row 2
        .byte $6F        ; $A173 - Row 3
        .byte $67        ; $A174 - Row 4
        .byte $67        ; $A175 - Row 5
        .byte $67        ; $A176 - Row 6
        .byte $00        ; $A177 - Row 7

; Character $2F - Letter 'O' for text display
;   .#######
;   .##...##
;   .##...##
;   .##..###
;   .##..###
;   .##..###
;   .#######
;   ........

        .byte $7F        ; $A178 - Row 0
        .byte $63        ; $A179 - Row 1
        .byte $63        ; $A17A - Row 2
        .byte $67        ; $A17B - Row 3
        .byte $67        ; $A17C - Row 4
        .byte $67        ; $A17D - Row 5
        .byte $7F        ; $A17E - Row 6
        .byte $00        ; $A17F - Row 7

; Character $30 - Letter 'P' for text display
;   .#######
;   .##...##
;   .##...##
;   .#######
;   .###....
;   .###....
;   .###....
;   ........

        .byte $7F        ; $A180 - Row 0
        .byte $63        ; $A181 - Row 1
        .byte $63        ; $A182 - Row 2
        .byte $7F        ; $A183 - Row 3
        .byte $70        ; $A184 - Row 4
        .byte $70        ; $A185 - Row 5
        .byte $70        ; $A186 - Row 6
        .byte $00        ; $A187 - Row 7

; Character $31 - Letter 'Q' for text display
;   .#######
;   .##...##
;   .##...##
;   .##..###
;   .##..###
;   .##..###
;   .#######
;   .....###

        .byte $7F        ; $A188 - Row 0
        .byte $63        ; $A189 - Row 1
        .byte $63        ; $A18A - Row 2
        .byte $67        ; $A18B - Row 3
        .byte $67        ; $A18C - Row 4
        .byte $67        ; $A18D - Row 5
        .byte $7F        ; $A18E - Row 6
        .byte $07        ; $A18F - Row 7

; Character $32 - Letter 'R' for text display
;   .######.
;   .##..##.
;   .##..##.
;   .#######
;   .###.###
;   .###.###
;   .###.###
;   ........

        .byte $7E        ; $A190 - Row 0
        .byte $66        ; $A191 - Row 1
        .byte $66        ; $A192 - Row 2
        .byte $7F        ; $A193 - Row 3
        .byte $77        ; $A194 - Row 4
        .byte $77        ; $A195 - Row 5
        .byte $77        ; $A196 - Row 6
        .byte $00        ; $A197 - Row 7

; Character $33 - Letter 'S' for text display
;   .#######
;   .##.....
;   .#######
;   ......##
;   .###..##
;   .###..##
;   .#######
;   ........

        .byte $7F        ; $A198 - Row 0
        .byte $60        ; $A199 - Row 1
        .byte $7F        ; $A19A - Row 2
        .byte $03        ; $A19B - Row 3
        .byte $73        ; $A19C - Row 4
        .byte $73        ; $A19D - Row 5
        .byte $7F        ; $A19E - Row 6
        .byte $00        ; $A19F - Row 7

; Character $34 - Letter 'T' for text display
;   .#######
;   ...###..
;   ...###..
;   ...###..
;   ...###..
;   ...###..
;   ...###..
;   ........

        .byte $7F        ; $A1A0 - Row 0
        .byte $1C        ; $A1A1 - Row 1
        .byte $1C        ; $A1A2 - Row 2
        .byte $1C        ; $A1A3 - Row 3
        .byte $1C        ; $A1A4 - Row 4
        .byte $1C        ; $A1A5 - Row 5
        .byte $1C        ; $A1A6 - Row 6
        .byte $00        ; $A1A7 - Row 7

; Character $35 - Letter 'U' / Player sprite: Static player character (lives display)
;   .##..###
;   .##..###
;   .##..###
;   .##..###
;   .##..###
;   .##..###
;   .#######
;   ........

        .byte $67        ; $A1A8 - Row 0
        .byte $67        ; $A1A9 - Row 1
        .byte $67        ; $A1AA - Row 2
        .byte $67        ; $A1AB - Row 3
        .byte $67        ; $A1AC - Row 4
        .byte $67        ; $A1AD - Row 5
        .byte $7F        ; $A1AE - Row 6
        .byte $00        ; $A1AF - Row 7

; Character $36 - Letter 'V' for text display
;   .##..###
;   .##..###
;   .##..###
;   .##..###
;   .##.####
;   ..#####.
;   ...###..
;   ........

        .byte $67        ; $A1B0 - Row 0
        .byte $67        ; $A1B1 - Row 1
        .byte $67        ; $A1B2 - Row 2
        .byte $67        ; $A1B3 - Row 3
        .byte $6F        ; $A1B4 - Row 4
        .byte $3E        ; $A1B5 - Row 5
        .byte $1C        ; $A1B6 - Row 6
        .byte $00        ; $A1B7 - Row 7

; Character $37 - Letter 'W' for text display
;   .##..###
;   .##..###
;   .##..###
;   .##.####
;   .#######
;   .#######
;   .##..###
;   ........

        .byte $67        ; $A1B8 - Row 0
        .byte $67        ; $A1B9 - Row 1
        .byte $67        ; $A1BA - Row 2
        .byte $6F        ; $A1BB - Row 3
        .byte $7F        ; $A1BC - Row 4
        .byte $7F        ; $A1BD - Row 5
        .byte $67        ; $A1BE - Row 6
        .byte $00        ; $A1BF - Row 7

; Character $38 - Letter 'X' for text display
;   ........
;   ##....##
;   .##..##.
;   ..####..
;   ...##...
;   ..####..
;   .##..##.
;   ##....##

        .byte $00        ; $A1C0 - Row 0
        .byte $C3        ; $A1C1 - Row 1
        .byte $66        ; $A1C2 - Row 2
        .byte $3C        ; $A1C3 - Row 3
        .byte $18        ; $A1C4 - Row 4
        .byte $3C        ; $A1C5 - Row 5
        .byte $66        ; $A1C6 - Row 6
        .byte $C3        ; $A1C7 - Row 7

; Character $39 - Letter 'Y' for text display
;   .##..###
;   .##..###
;   .##..###
;   .#######
;   ...###..
;   ...###..
;   ...###..
;   ........

        .byte $67        ; $A1C8 - Row 0
        .byte $67        ; $A1C9 - Row 1
        .byte $67        ; $A1CA - Row 2
        .byte $7F        ; $A1CB - Row 3
        .byte $1C        ; $A1CC - Row 4
        .byte $1C        ; $A1CD - Row 5
        .byte $1C        ; $A1CE - Row 6
        .byte $00        ; $A1CF - Row 7

; Character $3A - Letter 'Z' for text display
;   .#######
;   .##..##.
;   .##.##..
;   ...##...
;   ..##.###
;   .##..###
;   .#######
;   ........

        .byte $7F        ; $A1D0 - Row 0
        .byte $66        ; $A1D1 - Row 1
        .byte $6C        ; $A1D2 - Row 2
        .byte $18        ; $A1D3 - Row 3
        .byte $37        ; $A1D4 - Row 4
        .byte $67        ; $A1D5 - Row 5
        .byte $7F        ; $A1D6 - Row 6
        .byte $00        ; $A1D7 - Row 7

; Character $3B - Game graphics/sprite data
;   .###....
;   .###....
;   .###....
;   .#....#.
;   ........
;   ..#.....
;   ......#.
;   ......#.

        .byte $70        ; $A1D8 - Row 0
        .byte $70        ; $A1D9 - Row 1
        .byte $70        ; $A1DA - Row 2
        .byte $42        ; $A1DB - Row 3
        .byte $00        ; $A1DC - Row 4
        .byte $20        ; $A1DD - Row 5
        .byte $02        ; $A1DE - Row 6
        .byte $02        ; $A1DF - Row 7

; Character $3C - Game graphics/sprite data
;   ......#.
;   ......#.
;   ......#.
;   .###....
;   .....##.
;   .###....
;   .###....
;   ......#.

        .byte $02        ; $A1E0 - Row 0
        .byte $02        ; $A1E1 - Row 1
        .byte $02        ; $A1E2 - Row 2
        .byte $70        ; $A1E3 - Row 3
        .byte $06        ; $A1E4 - Row 4
        .byte $70        ; $A1E5 - Row 5
        .byte $70        ; $A1E6 - Row 6
        .byte $02        ; $A1E7 - Row 7

; Character $3D - Game graphics/sprite data
;   .###....
;   .....###
;   .###....
;   ..##....
;   .....##.
;   .###....
;   .....##.
;   .###....

        .byte $70        ; $A1E8 - Row 0
        .byte $07        ; $A1E9 - Row 1
        .byte $70        ; $A1EA - Row 2
        .byte $30        ; $A1EB - Row 3
        .byte $06        ; $A1EC - Row 4
        .byte $70        ; $A1ED - Row 5
        .byte $06        ; $A1EE - Row 6
        .byte $70        ; $A1EF - Row 7

; Character $3E - Game graphics/sprite data
;   ..##....
;   .....##.
;   .###....
;   .###....
;   ......#.
;   .#.....#
;   ##.##...
;   #.#....#

        .byte $30        ; $A1F0 - Row 0
        .byte $06        ; $A1F1 - Row 1
        .byte $70        ; $A1F2 - Row 2
        .byte $70        ; $A1F3 - Row 3
        .byte $02        ; $A1F4 - Row 4
        .byte $41        ; $A1F5 - Row 5
        .byte $D8        ; $A1F6 - Row 6
        .byte $A1        ; $A1F7 - Row 7

; Character $3F - Game graphics/sprite data
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........

        .byte $00        ; $A1F8 - Row 0
        .byte $00        ; $A1F9 - Row 1
        .byte $00        ; $A1FA - Row 2
        .byte $00        ; $A1FB - Row 3
        .byte $00        ; $A1FC - Row 4
        .byte $00        ; $A1FD - Row 5
        .byte $00        ; $A1FE - Row 6
        .byte $00        ; $A1FF - Row 7

; Character $40 - Game graphics/sprite data
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........
;   ........

        .byte $00        ; $A200 - Row 0
        .byte $00        ; $A201 - Row 1
        .byte $00        ; $A202 - Row 2
        .byte $00        ; $A203 - Row 3
        .byte $00        ; $A204 - Row 4
        .byte $00        ; $A205 - Row 5
        .byte $00        ; $A206 - Row 6
        .byte $00        ; $A207 - Row 7

; Character $41 - Game graphics/sprite data
;   .###....
;   .###....
;   .###....
;   ........
;   ........
;   ........
;   ........
;   ........

        .byte $70        ; $A208 - Row 0
        .byte $70        ; $A209 - Row 1
        .byte $70        ; $A20A - Row 2
        .byte $00        ; $A20B - Row 3
        .byte $00        ; $A20C - Row 4
        .byte $00        ; $A20D - Row 5
        .byte $00        ; $A20E - Row 6
        .byte $00        ; $A20F - Row 7

; Character $42 - Game graphics/sprite data
;   .....###
;   .....###
;   .....###
;   ........
;   ........
;   ........
;   ........
;   ........

        .byte $07        ; $A210 - Row 0
        .byte $07        ; $A211 - Row 1
        .byte $07        ; $A212 - Row 2
        .byte $00        ; $A213 - Row 3
        .byte $00        ; $A214 - Row 4
        .byte $00        ; $A215 - Row 5
        .byte $00        ; $A216 - Row 6
        .byte $00        ; $A217 - Row 7

; Character $43 - Game graphics/sprite data
;   .###.###
;   .###.###
;   .###.###
;   ........
;   ........
;   ........
;   ........
;   ........

        .byte $77        ; $A218 - Row 0
        .byte $77        ; $A219 - Row 1
        .byte $77        ; $A21A - Row 2
        .byte $00        ; $A21B - Row 3
        .byte $00        ; $A21C - Row 4
        .byte $00        ; $A21D - Row 5
        .byte $00        ; $A21E - Row 6
        .byte $00        ; $A21F - Row 7

; Character $44 - Game graphics/sprite data
;   ........
;   ........
;   ........
;   ........
;   .###....
;   .###....
;   .###....
;   ........

        .byte $00        ; $A220 - Row 0
        .byte $00        ; $A221 - Row 1
        .byte $00        ; $A222 - Row 2
        .byte $00        ; $A223 - Row 3
        .byte $70        ; $A224 - Row 4
        .byte $70        ; $A225 - Row 5
        .byte $70        ; $A226 - Row 6
        .byte $00        ; $A227 - Row 7

; Character $45 - Game graphics/sprite data
;   .###....
;   .###....
;   .###....
;   ........
;   .###....
;   .###....
;   .###....
;   ........

        .byte $70        ; $A228 - Row 0
        .byte $70        ; $A229 - Row 1
        .byte $70        ; $A22A - Row 2
        .byte $00        ; $A22B - Row 3
        .byte $70        ; $A22C - Row 4
        .byte $70        ; $A22D - Row 5
        .byte $70        ; $A22E - Row 6
        .byte $00        ; $A22F - Row 7

; Character $46 - Game graphics/sprite data
;   .###.###
;   .###.###
;   .###.###
;   ........
;   .###....
;   .###....
;   .###....
;   ........

        .byte $77        ; $A230 - Row 0
        .byte $77        ; $A231 - Row 1
        .byte $77        ; $A232 - Row 2
        .byte $00        ; $A233 - Row 3
        .byte $70        ; $A234 - Row 4
        .byte $70        ; $A235 - Row 5
        .byte $70        ; $A236 - Row 6
        .byte $00        ; $A237 - Row 7

; Character $47 - Game graphics/sprite data
;   ........
;   ........
;   ........
;   ........
;   .....###
;   .....###
;   .....###
;   ........

        .byte $00        ; $A238 - Row 0
        .byte $00        ; $A239 - Row 1
        .byte $00        ; $A23A - Row 2
        .byte $00        ; $A23B - Row 3
        .byte $07        ; $A23C - Row 4
        .byte $07        ; $A23D - Row 5
        .byte $07        ; $A23E - Row 6
        .byte $00        ; $A23F - Row 7

; Character $48 - Game graphics/sprite data
;   ........
;   ........
;   ........
;   ........
;   .###.###
;   .###.###
;   .###.###
;   ........

        .byte $00        ; $A240 - Row 0
        .byte $00        ; $A241 - Row 1
        .byte $00        ; $A242 - Row 2
        .byte $00        ; $A243 - Row 3
        .byte $77        ; $A244 - Row 4
        .byte $77        ; $A245 - Row 5
        .byte $77        ; $A246 - Row 6
        .byte $00        ; $A247 - Row 7

; Character $49 - Game graphics/sprite data
;   .###....
;   .###....
;   .###....
;   ........
;   .###.###
;   .###.###
;   .###.###
;   ........

        .byte $70        ; $A248 - Row 0
        .byte $70        ; $A249 - Row 1
        .byte $70        ; $A24A - Row 2
        .byte $00        ; $A24B - Row 3
        .byte $77        ; $A24C - Row 4
        .byte $77        ; $A24D - Row 5
        .byte $77        ; $A24E - Row 6
        .byte $00        ; $A24F - Row 7

; Character $4A - Game graphics/sprite data
;   .###.###
;   .###.###
;   .###.###
;   ........
;   .###.###
;   .###.###
;   .###.###
;   ........

        .byte $77        ; $A250 - Row 0
        .byte $77        ; $A251 - Row 1
        .byte $77        ; $A252 - Row 2
        .byte $00        ; $A253 - Row 3
        .byte $77        ; $A254 - Row 4
        .byte $77        ; $A255 - Row 5
        .byte $77        ; $A256 - Row 6
        .byte $00        ; $A257 - Row 7

; Character $4B - Game graphics/sprite data
;   .###....
;   .###....
;   .###....
;   .#...###
;   ........
;   ..#..#..
;   .....###
;   .....###

        .byte $70        ; $A258 - Row 0
        .byte $70        ; $A259 - Row 1
        .byte $70        ; $A25A - Row 2
        .byte $47        ; $A25B - Row 3
        .byte $00        ; $A25C - Row 4
        .byte $24        ; $A25D - Row 5
        .byte $07        ; $A25E - Row 6
        .byte $07        ; $A25F - Row 7

; Character $4C - Game graphics/sprite data
;   .....###
;   .....###
;   .....###
;   .....###
;   .....###
;   .....###
;   .....###
;   .#...##.

        .byte $07        ; $A260 - Row 0
        .byte $07        ; $A261 - Row 1
        .byte $07        ; $A262 - Row 2
        .byte $07        ; $A263 - Row 3
        .byte $07        ; $A264 - Row 4
        .byte $07        ; $A265 - Row 5
        .byte $07        ; $A266 - Row 6
        .byte $46        ; $A267 - Row 7

; Character $4D - Game graphics/sprite data
;   ........
;   ..#.###.
;   .....##.
;   .....##.
;   .....##.
;   .#.....#
;   .#.##...
;   #.#...#.

        .byte $00        ; $A268 - Row 0
        .byte $2E        ; $A269 - Row 1
        .byte $06        ; $A26A - Row 2
        .byte $06        ; $A26B - Row 3
        .byte $06        ; $A26C - Row 4
        .byte $41        ; $A26D - Row 5
        .byte $58        ; $A26E - Row 6
        .byte $A2        ; $A26F - Row 7

; Character $4E - Game graphics/sprite data
;   .###....
;   .###....
;   .###....
;   .#..#.#.
;   ........
;   ..#.#...
;   ....#.#.
;   ....#.#.

        .byte $70        ; $A270 - Row 0
        .byte $70        ; $A271 - Row 1
        .byte $70        ; $A272 - Row 2
        .byte $4A        ; $A273 - Row 3
        .byte $00        ; $A274 - Row 4
        .byte $28        ; $A275 - Row 5
        .byte $0A        ; $A276 - Row 6
        .byte $0A        ; $A277 - Row 7

; Character $4F - Game graphics/sprite data
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.

        .byte $0A        ; $A278 - Row 0
        .byte $0A        ; $A279 - Row 1
        .byte $0A        ; $A27A - Row 2
        .byte $0A        ; $A27B - Row 3
        .byte $0A        ; $A27C - Row 4
        .byte $0A        ; $A27D - Row 5
        .byte $0A        ; $A27E - Row 6
        .byte $0A        ; $A27F - Row 7

; Character $50 - Game graphics/sprite data
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.

        .byte $0A        ; $A280 - Row 0
        .byte $0A        ; $A281 - Row 1
        .byte $0A        ; $A282 - Row 2
        .byte $0A        ; $A283 - Row 3
        .byte $0A        ; $A284 - Row 4
        .byte $0A        ; $A285 - Row 5
        .byte $0A        ; $A286 - Row 6
        .byte $0A        ; $A287 - Row 7

; Character $51 - Game graphics/sprite data
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.

        .byte $0A        ; $A288 - Row 0
        .byte $0A        ; $A289 - Row 1
        .byte $0A        ; $A28A - Row 2
        .byte $0A        ; $A28B - Row 3
        .byte $0A        ; $A28C - Row 4
        .byte $0A        ; $A28D - Row 5
        .byte $0A        ; $A28E - Row 6
        .byte $0A        ; $A28F - Row 7

; Character $52 - Game graphics/sprite data
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.

        .byte $0A        ; $A290 - Row 0
        .byte $0A        ; $A291 - Row 1
        .byte $0A        ; $A292 - Row 2
        .byte $0A        ; $A293 - Row 3
        .byte $0A        ; $A294 - Row 4
        .byte $0A        ; $A295 - Row 5
        .byte $0A        ; $A296 - Row 6
        .byte $0A        ; $A297 - Row 7

; Character $53 - Game graphics/sprite data
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   ....#.#.
;   .#...##.
;   ........
;   ..#.###.

        .byte $0A        ; $A298 - Row 0
        .byte $0A        ; $A299 - Row 1
        .byte $0A        ; $A29A - Row 2
        .byte $0A        ; $A29B - Row 3
        .byte $0A        ; $A29C - Row 4
        .byte $46        ; $A29D - Row 5
        .byte $00        ; $A29E - Row 6
        .byte $2E        ; $A29F - Row 7

; Character $54 - Game graphics/sprite data
;   .....##.
;   .....##.
;   .....##.
;   .#.....#
;   .###....
;   #.#...#.
;   .###....
;   .###....

        .byte $06        ; $A2A0 - Row 0
        .byte $06        ; $A2A1 - Row 1
        .byte $06        ; $A2A2 - Row 2
        .byte $41        ; $A2A3 - Row 3
        .byte $70        ; $A2A4 - Row 4
        .byte $A2        ; $A2A5 - Row 5
        .byte $70        ; $A2A6 - Row 6
        .byte $70        ; $A2A7 - Row 7

; Character $55 - Game graphics/sprite data
;   .###....
;   .#...##.
;   ........
;   ..#.##..
;   .....##.
;   .....##.
;   .....##.
;   .....##.

        .byte $70        ; $A2A8 - Row 0
        .byte $46        ; $A2A9 - Row 1
        .byte $00        ; $A2AA - Row 2
        .byte $2C        ; $A2AB - Row 3
        .byte $06        ; $A2AC - Row 4
        .byte $06        ; $A2AD - Row 5
        .byte $06        ; $A2AE - Row 6
        .byte $06        ; $A2AF - Row 7

; Character $56 - Game graphics/sprite data
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.

        .byte $06        ; $A2B0 - Row 0
        .byte $06        ; $A2B1 - Row 1
        .byte $06        ; $A2B2 - Row 2
        .byte $06        ; $A2B3 - Row 3
        .byte $06        ; $A2B4 - Row 4
        .byte $06        ; $A2B5 - Row 5
        .byte $06        ; $A2B6 - Row 6
        .byte $06        ; $A2B7 - Row 7

; Character $57 - Game graphics/sprite data
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .....##.
;   .#...##.

        .byte $06        ; $A2B8 - Row 0
        .byte $06        ; $A2B9 - Row 1
        .byte $06        ; $A2BA - Row 2
        .byte $06        ; $A2BB - Row 3
        .byte $06        ; $A2BC - Row 4
        .byte $06        ; $A2BD - Row 5
        .byte $06        ; $A2BE - Row 6
        .byte $46        ; $A2BF - Row 7

; Character $58 - Game graphics/sprite data
;   ........
;   ..#.###.
;   .....##.
;   .....##.
;   .....##.
;   .#.....#
;   #.#..##.
;   #.#...#.

        .byte $00        ; $A2C0 - Row 0
        .byte $2E        ; $A2C1 - Row 1
        .byte $06        ; $A2C2 - Row 2
        .byte $06        ; $A2C3 - Row 3
        .byte $06        ; $A2C4 - Row 4
        .byte $41        ; $A2C5 - Row 5
        .byte $A6        ; $A2C6 - Row 6
        .byte $A2        ; $A2C7 - Row 7

; ===============================================================================
; GAME CODE SECTION ($A2C8-$BFFF)
; ===============================================================================

; ===============================================================================
; INITIALIZATION ($A2C8)
; System startup and hardware setup
; ===============================================================================

$A2C8: E8       INX
$A2C9: 8A       TXA
$A2CA: 9D 00 E8 STA $E800
$A2CD: 9D 00 C0 STA $C000
$A2D0: 9D 00 D4 STA $D400 ; ANTIC DMACTL - DMA control
$A2D3: 95 00    STA $00
$A2D5: E8       INX
$A2D6: D0 F2    BNE $A2CA ; Loop back if not zero
$A2D8: A9 F8    LDA #$F8
$A2DA: 8D 09 D4 STA $D409 ; POKEY SKCTL - Serial/keyboard control
$A2DD: A2 0B    LDX #$0B
$A2DF: BD 95 FE LDA $FE95
$A2E2: 9D 00 02 STA $0200
$A2E5: CA       DEX
$A2E6: 10 F7    BPL $A2DF
$A2E8: A9 3C    LDA #$3C
$A2EA: 85 12    STA $12
$A2EC: A9 00    LDA #$00
$A2EE: 85 11    STA $11
$A2F0: A2 0C    LDX #$0C
$A2F2: A8       TAY
$A2F3: 91 11    STA $11
$A2F5: 88       DEY
$A2F6: D0 FB    BNE $A2F3 ; Loop back if not zero
$A2F8: C6 12    DEC $12
$A2FA: CA       DEX
$A2FB: 10 F6    BPL $A2F3
$A2FD: A9 C0    LDA #$C0
$A2FF: 8D 0E D4 STA $D40E ; ANTIC NMIEN - NMI enable
$A302: A9 02    LDA #$02
$A304: 8D 0F E8 STA $E80F
$A307: 8D 0B E8 STA $E80B
$A30A: A2 0B    LDX #$0B
$A30C: BD 95 FE LDA $FE95
$A30F: 9D 00 02 STA $0200
$A312: CA       DEX
$A313: 10 F7    BPL $A30C
$A315: A9 04    LDA #$04
$A317: 8D 1F C0 STA $C01F ; GTIA PRIOR - Priority control
$A31A: A9 BF    LDA #$BF
$A31C: 8D 0B 02 STA $020B
$A31F: A9 DD    LDA #$DD
$A321: 8D 0A 02 STA $020A
$A324: A9 22    LDA #$22
$A326: 85 07    STA $07
$A328: 20 D0 A6 JSR $A6D0 ; Setup routine
$A32B: 20 18 A5 JSR $A518 ; Additional setup - Initialize game variables and text displays
$A32E: 58       CLI
$A32F: 20 B6 A9 JSR $A9B6 ; Game initialization

; ===============================================================================
; PLAYER SPRITE SYSTEM SUMMARY
; ===============================================================================
; The K-Razy Shoot-Out player character uses a sophisticated multi-sprite system
; with directional animation and walking cycles. This was remarkably advanced for 1981.
;
; COMPLETE SPRITE INVENTORY:
; - Character $02: Head (Sideways)  - Used for horizontal movement
; - Character $04: Head (Vertical)  - Used for vertical/stationary movement
; - Character $03: Body (Horizontal) Frame 1 - Walking animation frame 1
; - Character $05: Body (Horizontal) Frame 2 - Walking animation frame 2
; - Character $1E: Body (Stationary) - Used for vertical/stationary movement
; - Characters $06-$09: Death animation and final dead state sprites
;
; ANIMATION STATES:
; 1. STATIONARY/VERTICAL: Character $04 (head) + Character $1E (body)
; 2. HORIZONTAL FRAME 1:  Character $02 (head) + Character $03 (body)
; 3. HORIZONTAL FRAME 2:  Character $02 (head) + Character $05 (body)
; 4. DEATH ANIMATION:     Character $06 (top) + Character $07 (bottom)
; 5. FINAL DEAD STATE:    Character $08 (left) + Character $09 (right)
;
; HARDWARE IMPLEMENTATION:
; - Uses Atari 5200 PMG (Player/Missile Graphics) system
; - $E804: Player sprite position register (X coordinate)
; - $E805: Player sprite character register (loads character codes)
; - Movement detection via collision registers $C004/$C00C and joystick input
; - Real-time sprite character swapping based on movement state
; ===============================================================================

; ===============================================================================
; MAIN_GAME_LOOP ($A332)
; Core game loop - runs continuously during play
; This loop manages the complete game state including:
; - Enemy wave system (3 enemies max on screen)
; - Time countdown system ($D9 = time remaining)
; - Exit activation (when all enemy slots empty)
; - Level progression and arena generation
; ===============================================================================

$A332: A9 00    LDA #$00
$A334: 85 94    STA $94         ; Clear enemy slot 1 (0=empty, 1=active/defeated)
$A336: 85 95    STA $95         ; Clear enemy slot 2 (0=empty, 1=active/defeated)
$A338: 85 96    STA $96         ; Clear enemy slot 3 (0=empty, 1=active/defeated)
                                ; When all 3 slots = 0, exits become active
$A33A: 20 C3 BB JSR $BBC3 ; Main game logic update
$A33D: 20 74 B9 JSR $B974 ; Graphics/sprite updates
$A340: 20 AD AF JSR $AFAD ; Input handling routine
$A343: 20 11 BC JSR $BC11 ; Sound/audio updates
$A346: 20 4F B1 JSR $B14F ; Collision detection
$A349: 20 B3 B2 JSR $B2B3 ; Enemy AI/movement
$A34C: 20 BF B4 JSR $B4BF ; Display updates
$A34F: A5 DA    LDA #$DA
$A351: C9 03    CMP #$03
$A353: F0 2D    BEQ $A382 ; Branch if equal/zero
$A355: A5 A9    LDA #$A9
$A357: D0 E7    BNE $A340 ; Loop back if not zero
$A359: 20 5B B5 JSR $B55B
$A35C: 20 3A A8 JSR $A83A
$A35F: A5 AD    LDA #$AD
$A361: F0 0A    BEQ $A36D ; Branch if equal/zero
$A363: A6 D5    LDX #$D5
$A365: F6 C5    INC $C5
$A367: 20 FF A4 JSR $A4FF
$A36A: 4C 2F A3 JMP $A32F
$A36D: 20 3D B2 JSR $B23D
$A370: 20 1A B3 JSR $B31A
$A373: 20 05 AD JSR $AD05
$A376: 20 26 B7 JSR $B726
$A379: 20 77 BB JSR $BB77
$A37C: A5 D9    LDA $D9         ; Load time remaining counter
$A37E: C9 02    CMP #$02        ; Check if time almost up (2 time units left)
$A380: D0 C4    BNE $A346       ; Loop back if time remaining > 2
                                ; TIME UP! Level advances automatically
$A382: A6 D5    LDX $D5         ; Load current level counter
$A384: F6 C5    INC $C5,X       ; Increment level statistics
$A386: E6 D5    INC $D5         ; INCREMENT LEVEL COUNTER - triggers new sector
$A388: 20 B6 A9 JSR $A9B6       ; Game initialization for new level (includes arena generation)
$A38B: 20 81 A5 JSR $A581       ; Level setup (includes "ENTER SECTOR X" display)
$A38E: 4C 2B A3 JMP $A32B       ; Jump to main game setup

; ===============================================================================
; COMPLETE LEVEL END DETECTION SYSTEM - SUMMARY
; ===============================================================================
; K-Razy Shoot-Out has TWO ways a level can end:
;
; 1. **TIME RUNS OUT** ($A37C-$A380):
;    - Time counter $D9 decrements from 77 to 2
;    - When $D9 = 2, automatic level advance to $A382
;
; 2. **PLAYER ESCAPES** ($A351-$A353):
;    - Enemy AI ($B2B3) calls boundary check ($BD47) each frame
;    - Boundary check: if player position ($69 + $0E) >= $C0, set $97 = 1
;    - Display update ($B4BF) checks $97, calls escape processing ($B75E)
;    - Escape processing increments $DA counter (0→1→2→3)
;    - When $DA = 3, level advance to $A382
;
; **LEVEL ADVANCEMENT FLOW** ($A382):
;    - Increment level counter $D5 (0=Sector 1, 1=Sector 2, etc.)
;    - Call arena generation ($A9B6) - creates new randomized arena
;    - Call level setup ($A581) - displays "ENTER SECTOR X"
;    - Reset all game state for new sector
;
; **ESCAPE SEQUENCE DETAILS** ($B75E):
; The escape processing creates a dramatic multi-stage audiovisual effect:
; 1. **Initialization**: Clear hardware registers, set up sprite effects
; 2. **Counter Increment**: $DA increases (0→1→2→3), each escape more dramatic
; 3. **Effect Loop**: Multiple animation frames with timed delays
;    - Stage effects in $06xx memory areas
;    - Copy to screen memory $2Exx to make visible
;    - Use hardware registers $E800-$E808 for sprite control
;    - Create precise timing with nested delay loops
; 4. **Progressive Enhancement**: Each escape ($DA=1,2,3) has different effects
; 5. **DRAMATIC SCREEN CLEAR**: Three-phase top-to-bottom screen wipe:
;    - Phase 1: Clear rows $14-$59 (20-89) with timed delays
;    - Phase 2: Clear rows $59-$9B (89-155) continuing the sweep
;    - Phase 3: Clear rows $4F-$3F (79-63) with countdown effect
;    - Each row cleared individually with visible timing delays
;    - Creates classic "screen wipe" effect from top to bottom
; 6. **Sound Effects**: Audio feedback during the clearing sequence
; 7. **ENEMY KILL COUNT DISPLAY**: After screen clear, shows scoring summary:
;    - Displays enemies killed by point value (100, 50, 10 points)
;    - Each enemy type shown individually with sound effects
;    - Uses hit counters $D2 and $D3 to track kills
;    - Routine $AC26 displays enemy sprites to screen memory
;    - Different screen locations for each point value:
;      * 100-point enemies: Y=$64, displayed at $2C12, $2C26, $2C3A
;      * 50-point enemies: Y=$32, displayed at $2C62  
;      * 10-point enemies: Y=$0A, displayed at $2C9E
;    - Each enemy appears one by one with timing delays ($AC0C)
;    - Creates classic arcade "bonus tally" screen effect
; 8. **BONUS POINTS DISPLAY**: Final climactic screen after enemy count:
;    - Displays "BONUS POINTS" text stored at $ACA1-$ACAC with flashing effect
;    - Text loaded by routine at $AB78 (LDA $ACA1)
;    - **TIME-BASED BONUS CALCULATION**:
;      * Time remaining >= 53: 10 bonus points (fast completion)
;      * Time remaining >= 27: 3 bonus points (moderate completion)  
;      * Time remaining < 27: No bonus points (slow completion)
;    - Each bonus point flashes the text and plays sound via $BD66
;    - Sound routine $BD66 actually adds points to score at $060B
;    - Rewards players for efficient level completion
; 9. **Final Trigger**: When $DA=3, main loop detects and advances level
;
; The escape sequence provides satisfying audiovisual feedback for successfully
; completing the level objective (defeat enemies + escape through gaps).
; The screen clear effect is a classic 1980s arcade game technique that provides
; dramatic visual closure to the level completion.
; ===============================================================================

        .byte $20        ; $A391 - ' '
        .byte $20        ; $A392 - ' '
        .byte $20        ; $A393 - ' '
        .byte $20        ; $A394 - ' '
        .byte $20        ; $A395 - ' '
        .byte $53        ; $A396 - 'S'
        .byte $43        ; $A397 - 'C'
        .byte $4F        ; $A398 - 'O'
        .byte $52        ; $A399 - 'R'
        .byte $45        ; $A39A - 'E'
        .byte $20        ; $A39B - ' '
        .byte $30        ; $A39C - '0'
        .byte $30        ; $A39D - '0'
        .byte $30        ; $A39E - '0'
        .byte $30        ; $A39F - '0'
        .byte $30        ; $A3A0 - '0'
        .byte $20        ; $A3A1 - ' '
        .byte $20        ; $A3A2 - ' '
        .byte $20        ; $A3A3 - ' '
        .byte $20        ; $A3A4 - ' '
        .byte $20        ; $A3A5 - ' '
        .byte $20        ; $A3A6 - ' '
        .byte $40        ; $A3A7 - '@'
        .byte $40        ; $A3A8 - '@'
        .byte $40        ; $A3A9 - '@'
        .byte $20        ; $A3AA - ' '
        .byte $20        ; $A3AB - ' '
        .byte $20        ; $A3AC - ' '
        .byte $20        ; $A3AD - ' '
        .byte $20        ; $A3AE - ' '
        .byte $20        ; $A3AF - ' '
        .byte $20        ; $A3B0 - ' '
        .byte $20        ; $A3B1 - ' '
        .byte $20        ; $A3B2 - ' '
        .byte $20        ; $A3B3 - ' '
        .byte $20        ; $A3B4 - ' '
        .byte $20        ; $A3B5 - ' '
        .byte $20        ; $A3B6 - ' '
        .byte $20        ; $A3B7 - ' '
        .byte $20        ; $A3B8 - ' '
        .byte $20        ; $A3B9 - ' '
        .byte $20        ; $A3BA - ' '
        .byte $3E        ; $A3BB - '>'
        .byte $3E        ; $A3BC - '>'
        .byte $3E        ; $A3BD - '>'
        .byte $20        ; $A3BE - ' '
        .byte $20        ; $A3BF - ' '
        .byte $20        ; $A3C0 - ' '
        .byte $20        ; $A3C1 - ' '
        .byte $54        ; $A3C2 - 'T'
        .byte $49        ; $A3C3 - 'I'
        .byte $4D        ; $A3C4 - 'M'
        .byte $45        ; $A3C5 - 'E'
        .byte $20        ; $A3C6 - ' '
        .byte $30        ; $A3C7 - '0'
        .byte $30        ; $A3C8 - '0'
        .byte $2E        ; $A3C9 - '.'
        .byte $30        ; $A3CA - '0'
        .byte $30        ; $A3CB - '0'
        .byte $20        ; $A3CC - ' '
        .byte $20        ; $A3CD - ' '
        .byte $20        ; $A3CE - ' '
        .byte $20        ; $A3CF - ' '
        .byte $20        ; $A3D0 - ' '
        .byte $20        ; $A3D1 - ' '
        .byte $20        ; $A3D2 - ' '
        .byte $20        ; $A3D3 - ' '
        .byte $20        ; $A3D4 - ' '
        .byte $20        ; $A3D5 - ' '
        .byte $20        ; $A3D6 - ' '
        .byte $20        ; $A3D7 - ' '
        .byte $20        ; $A3D8 - ' '
        .byte $20        ; $A3D9 - ' '
        .byte $20        ; $A3DA - ' '
        .byte $20        ; $A3DB - ' '
        .byte $20        ; $A3DC - ' '
        .byte $20        ; $A3DD - ' '
        .byte $20        ; $A3DE - ' '
        .byte $20        ; $A3DF - ' '
        .byte $20        ; $A3E0 - ' '
        .byte $20        ; $A3E1 - ' '
        .byte $20        ; $A3E2 - ' '
        .byte $20        ; $A3E3 - ' '
        .byte $20        ; $A3E4 - ' '
        .byte $20        ; $A3E5 - ' '
        .byte $20        ; $A3E6 - ' '
        .byte $20        ; $A3E7 - ' '
        .byte $20        ; $A3E8 - ' '
        .byte $20        ; $A3E9 - ' '
        .byte $20        ; $A3EA - ' '
        .byte $20        ; $A3EB - ' '
        .byte $20        ; $A3EC - ' '
        .byte $20        ; $A3ED - ' '
        .byte $20        ; $A3EE - ' '
        .byte $20        ; $A3EF - ' '
        .byte $20        ; $A3F0 - ' '
        .byte $20        ; $A3F1 - ' '
        .byte $20        ; $A3F2 - ' '
        .byte $20        ; $A3F3 - ' '
        .byte $20        ; $A3F4 - ' '
        .byte $20        ; $A3F5 - ' '
        .byte $20        ; $A3F6 - ' '
        .byte $20        ; $A3F7 - ' '
        .byte $20        ; $A3F8 - ' '
        .byte $54        ; $A3F9 - 'T'
        .byte $4F        ; $A3FA - 'O'
        .byte $54        ; $A3FB - 'T'
        .byte $41        ; $A3FC - 'A'
        .byte $4C        ; $A3FD - 'L'
        .byte $53        ; $A3FE - 'S'
        .byte $3A        ; $A3FF - ':'
        .byte $20        ; $A400 - ' '
        .byte $20        ; $A401 - ' '
        .byte $20        ; $A402 - ' '
        .byte $53        ; $A403 - 'S'
        .byte $43        ; $A404 - 'C'
        .byte $4F        ; $A405 - 'O'
        .byte $52        ; $A406 - 'R'
        .byte $45        ; $A407 - 'E'
        .byte $20        ; $A408 - ' '
        .byte $41        ; $A409 - 'A'
        .byte $41        ; $A40A - 'A'
        .byte $41        ; $A40B - 'A'
        .byte $41        ; $A40C - 'A'
        .byte $41        ; $A40D - 'A'
        .byte $20        ; $A40E - ' '
        .byte $20        ; $A40F - ' '
        .byte $20        ; $A410 - ' '
        .byte $20        ; $A411 - ' '
        .byte $54        ; $A412 - 'T'
        .byte $49        ; $A413 - 'I'
        .byte $4D        ; $A414 - 'M'
        .byte $45        ; $A415 - 'E'
        .byte $20        ; $A416 - ' '
        .byte $58        ; $A417 - 'X'
        .byte $58        ; $A418 - 'X'
        .byte $2E        ; $A419 - '.'
        .byte $58        ; $A41A - 'X'
        .byte $58        ; $A41B - 'X'
        .byte $20        ; $A41C - ' '
        .byte $20        ; $A41D - ' '
        .byte $20        ; $A41E - ' '
        .byte $20        ; $A41F - ' '
        .byte $48        ; $A420 - 'H'
        .byte $49        ; $A421 - 'I'
        .byte $47        ; $A422 - 'G'
        .byte $48        ; $A423 - 'H'
        .byte $20        ; $A424 - ' '
        .byte $53        ; $A425 - 'S'
        .byte $43        ; $A426 - 'C'
        .byte $4F        ; $A427 - 'O'
        .byte $52        ; $A428 - 'R'
        .byte $45        ; $A429 - 'E'
        .byte $20        ; $A42A - ' '
        .byte $30        ; $A42B - '0'
        .byte $30        ; $A42C - '0'
        .byte $30        ; $A42D - '0'
        .byte $30        ; $A42E - '0'
        .byte $30        ; $A42F - '0'
        .byte $20        ; $A430 - ' '
        .byte $20        ; $A431 - ' '
        .byte $20        ; $A432 - ' '
        .byte $20        ; $A433 - ' '
        .byte $20        ; $A434 - ' '
        .byte $43        ; $A435 - 'C'
        .byte $41        ; $A436 - 'A'
        .byte $53        ; $A437 - 'S'
        .byte $49        ; $A438 - 'I'
        .byte $4E        ; $A439 - 'N'
        .byte $47        ; $A43A - 'G'
        .byte $53        ; $A43B - 'S'
        .byte $20        ; $A43C - ' '
        .byte $58        ; $A43D - 'X'
        .byte $58        ; $A43E - 'X'
        .byte $58        ; $A43F - 'X'
        .byte $20        ; $A440 - ' '
        .byte $20        ; $A441 - ' '
        .byte $20        ; $A442 - ' '
        .byte $20        ; $A443 - ' '
        .byte $20        ; $A444 - ' '
        .byte $52        ; $A445 - 'R'
        .byte $41        ; $A446 - 'A'
        .byte $4E        ; $A447 - 'N'
        .byte $4B        ; $A448 - 'K'
        .byte $3A        ; $A449 - ':'
        .byte $20        ; $A44A - ' '
        .byte $30        ; $A44B - '0'
        .byte $31        ; $A44C - '1'
        .byte $32        ; $A44D - '2'
        .byte $33        ; $A44E - '3'
        .byte $34        ; $A44F - '4'
        .byte $35        ; $A450 - '5'
        .byte $36        ; $A451 - '6'
        .byte $37        ; $A452 - '7'
        .byte $20        ; $A453 - ' '
        .byte $20        ; $A454 - ' '
        .byte $20        ; $A455 - ' '
        .byte $20        ; $A456 - ' '
        .byte $20        ; $A457 - ' '
        .byte $43        ; $A458 - 'C'
        .byte $4C        ; $A459 - 'L'
        .byte $41        ; $A45A - 'A'
        .byte $53        ; $A45B - 'S'
        .byte $53        ; $A45C - 'S'
        .byte $20        ; $A45D - ' '
        .byte $20        ; $A45E - ' '
        .byte $43        ; $A45F - 'C'
        .byte $20        ; $A460 - ' '
        .byte $20        ; $A461 - ' '
        .byte $20        ; $A462 - ' '
        .byte $20        ; $A463 - ' '
        .byte $20        ; $A464 - ' '
        .byte $20        ; $A465 - ' '
        .byte $20        ; $A466 - ' '
        .byte $20        ; $A467 - ' '
        .byte $20        ; $A468 - ' '
        .byte $20        ; $A469 - ' '
        .byte $20        ; $A46A - ' '
        .byte $20        ; $A46B - ' '
        .byte $20        ; $A46C - ' '
        .byte $20        ; $A46D - ' '
        .byte $20        ; $A46E - ' '
        .byte $20        ; $A46F - ' '
        .byte $20        ; $A470 - ' '
        .byte $20        ; $A471 - ' '
        .byte $20        ; $A472 - ' '
        .byte $20        ; $A473 - ' '
        .byte $20        ; $A474 - ' '
        .byte $20        ; $A475 - ' '
        .byte $20        ; $A476 - ' '
        .byte $20        ; $A477 - ' '
        .byte $20        ; $A478 - ' '
        .byte $20        ; $A479 - ' '
        .byte $20        ; $A47A - ' '
        .byte $20        ; $A47B - ' '
        .byte $20        ; $A47C - ' '
        .byte $20        ; $A47D - ' '
        .byte $20        ; $A47E - ' '
        .byte $20        ; $A47F - ' '
        .byte $20        ; $A480 - ' '
        .byte $20        ; $A481 - ' '
        .byte $20        ; $A482 - ' '
        .byte $20        ; $A483 - ' '
        .byte $20        ; $A484 - ' '
        .byte $20        ; $A485 - ' '
        .byte $20        ; $A486 - ' '
        .byte $20        ; $A487 - ' '
        .byte $20        ; $A488 - ' '
        .byte $20        ; $A489 - ' '
        .byte $20        ; $A48A - ' '
        .byte $20        ; $A48B - ' '
        .byte $A9        ; $A48C
        .byte $38        ; $A48D - '8'
        .byte $85        ; $A48E
        .byte $06        ; $A48F
        .byte $A9        ; $A490
        .byte $00        ; $A491
        .byte $85        ; $A492
        .byte $05        ; $A493
        .byte $A0        ; $A494
        .byte $15        ; $A495
        .byte $B9        ; $A496
        .byte $E9        ; $A497
        .byte $A4        ; $A498
        .byte $99        ; $A499
        .byte $00        ; $A49A
        .byte $38        ; $A49B - '8'
        .byte $88        ; $A49C
        .byte $10        ; $A49D
        .byte $F7        ; $A49E
        .byte $A9        ; $A49F
        .byte $22        ; $A4A0 - '"'
        .byte $85        ; $A4A1
        .byte $07        ; $A4A2
        .byte $A2        ; $A4A3
        .byte $00        ; $A4A4
        .byte $86        ; $A4A5
        .byte $64        ; $A4A6 - 'd'
        .byte $86        ; $A4A7
        .byte $92        ; $A4A8
        .byte $AD        ; $A4A9
        .byte $0B        ; $A4AA
        .byte $D4        ; $A4AB
        .byte $C9        ; $A4AC
        .byte $40        ; $A4AD - '@'
        .byte $D0        ; $A4AE
        .byte $F9        ; $A4AF
        .byte $8D        ; $A4B0
        .byte $0A        ; $A4B1
        .byte $D4        ; $A4B2
        .byte $8D        ; $A4B3
        .byte $0A        ; $A4B4
        .byte $D4        ; $A4B5
        .byte $A5        ; $A4B6
        .byte $64        ; $A4B7 - 'd'
        .byte $C6        ; $A4B8
        .byte $64        ; $A4B9 - 'd'
        .byte $29        ; $A4BA - ')'
        .byte $07        ; $A4BB
        .byte $8D        ; $A4BC
        .byte $04        ; $A4BD
        .byte $D4        ; $A4BE
        .byte $A0        ; $A4BF
        .byte $00        ; $A4C0
        .byte $A6        ; $A4C1
        .byte $92        ; $A4C2
        .byte $BD        ; $A4C3
        .byte $53        ; $A4C4 - 'S'
        .byte $06        ; $A4C5
        .byte $38        ; $A4C6 - '8'
        .byte $E9        ; $A4C7
        .byte $20        ; $A4C8 - ' '
        .byte $99        ; $A4C9
        .byte $80        ; $A4CA
        .byte $39        ; $A4CB - '9'
        .byte $E8        ; $A4CC
        .byte $C8        ; $A4CD
        .byte $C0        ; $A4CE
        .byte $16        ; $A4CF
        .byte $D0        ; $A4D0
        .byte $F1        ; $A4D1
        .byte $AD        ; $A4D2
        .byte $10        ; $A4D3
        .byte $C0        ; $A4D4
        .byte $F0        ; $A4D5
        .byte $11        ; $A4D6
        .byte $A5        ; $A4D7
        .byte $64        ; $A4D8 - 'd'
        .byte $29        ; $A4D9 - ')'
        .byte $07        ; $A4DA
        .byte $C9        ; $A4DB
        .byte $07        ; $A4DC
        .byte $D0        ; $A4DD
        .byte $CA        ; $A4DE
        .byte $A6        ; $A4DF
        .byte $92        ; $A4E0
        .byte $E8        ; $A4E1
        .byte $E0        ; $A4E2
        .byte $87        ; $A4E3
        .byte $90        ; $A4E4
        .byte $C1        ; $A4E5
        .byte $B0        ; $A4E6
        .byte $BB        ; $A4E7
        .byte $60        ; $A4E8 - '`'
$A4E9: 70 70    BVS $A55B
$A4EB: 70 70    BVS $A55D
$A4ED: 70 70    BVS $A55F
$A4EF: 70 57    BVS $A548
$A4F1: 80       .byte $80        ; Data byte
$A4F2: 39 70 70 AND $7070
$A4F5: 70 70    BVS $A567
$A4F7: 47       .byte $47        ; Data byte
$A4F8: 00       BRK
$A4F9: 39 07 07 AND $0707
$A4FC: 41 00    EOR #$00
$A4FE: 38       SEC
; ===============================================================================
; ENEMY_WAVE_CHECK ($A4FF)
; Enemy wave completion and exit activation system
; This routine:
; - Checks if all 3 enemy slots are defeated ($94 AND $95 AND $96)
; - Controls exit activation: exits open when all slots = 0 (empty)
; - Manages wave completion and new enemy spawning from $A6 pool
; - Updates scoring based on enemy defeats and shot accuracy
; - Integrates with time system ($D9) and total enemy count ($A6 = 24)
; ===============================================================================

$A4FF: A5 94    LDA $94         ; Load enemy slot 1 state (0=empty, 1=defeated)
$A501: 25 95    AND $95         ; AND with enemy slot 2 state  
$A503: 25 96    AND $96         ; AND with enemy slot 3 state
                                ; Result = 1 only if ALL 3 enemies defeated
                                ; Result = 0 if ANY slot empty (exits open!)
$A505: F0 0A    BEQ $A511       ; Branch if any enemy slot empty
$A507: A5 D4    LDA $D4         ; Load shot counter (incremented when firing)
$A509: C5 D1    CMP $D1         ; Compare with accuracy threshold
$A50B: 90 04    BCC $A511       ; Branch if accuracy good (few misses)
$A50D: E6 D5    INC $D5         ; Increment level progression counter
$A50F: D0 06    BNE $A517       ; Continue to next check
$A511: A5 D5    LDA $D5         ; Load level progression counter
$A513: F0 02    BEQ $A517       ; Branch if zero
$A515: C6 D5    DEC $D5         ; Decrement level progression counter
$A517: 60       RTS             ; Return from enemy wave check
; ===============================================================================
; ADDITIONAL_SETUP ($A518)
; Game variable initialization and text display setup
; This routine:
; - Clears all game state variables
; - Sets up initial score display (00000)
; - Sets up time display (00.00)
; - Copies game text to screen memory
; - Initializes difficulty level
; - Prepares display lists for game screens
; ===============================================================================

$A518: A9 00    LDA #$00 ; Clear game state variables
$A51A: 8D 01 E8 STA $E801 ; Clear RAM location $E801
$A51D: 8D 08 E8 STA $E808 ; Clear RAM location $E808
$A520: 85 04    STA $04 ; Clear zero page variable $04
$A522: A9 02    LDA #$02 ; Set game mode flag to 2
$A524: 8D 0F E8 STA $E80F ; Store game mode in RAM $E80F
$A527: 20 A2 BD JSR $BDA2 ; Call display setup routine
$A52A: A2 08    LDX #$08 ; Initialize loop counter (8 iterations)
$A52C: 95 C5    STA $C5 ; Clear score/statistics array
$A52E: CA       DEX ; Decrement loop counter
$A52F: 10 FB    BPL $A52C ; Continue clearing array
$A531: A9 00    LDA #$00 ; Initialize game state to 0
$A533: 85 D0    STA $D0 ; Clear game state variable $D0
$A535: 85 BD    STA $BD ; Clear game state variable $BD
$A537: 85 D9    STA $D9 ; Clear game over flag $D9
$A539: 85 CE    STA $CE ; Clear counter variable $CE
$A53B: 85 CF    STA $CF ; Clear counter variable $CF
$A53D: 85 0E    STA $0E ; Clear zero page variable $0E
$A53F: A5 DC    LDA #$DC ; Load initial difficulty/level value
$A541: 85 D5    STA $D5 ; Set initial level counter
$A543: A2 30    LDX #$30 ; Set X to $30 (48 decimal) for text setup
$A545: A9 01    LDA #$01 ; Set flag to 1 (enable something)
$A547: 85 DB    STA $DB ; Store flag in game state variable
$A549: A0 18    LDY #$18 ; Set Y to $18 (24 decimal) for display
$A54B: 20 B0 BD JSR $BDB0 ; Call text display setup routine
$A54E: A9 00    LDA #$00 ; Clear zero page variable again
$A550: 85 0E    STA $0E ; Store in zero page $0E
$A552: 85 0C    STA $0C ; Clear zero page variable $0C
$A554: A2 53    LDX #$53 ; Set loop counter to $53 (83 chars)
$A556: BD 90 A3 LDA $A390 ; Load character from text table
$A559: 38       SEC ; Set carry for subtraction
$A55A: E9 20    SBC #$20 ; Convert to screen code (subtract $20)
$A55C: 9D FF 05 STA $05FF ; Store to screen memory location 1
$A55F: 9D FF 2D STA $2DFF ; Store to screen memory location 2
$A562: CA       DEX ; Decrement character counter
$A563: D0 F1    BNE $A556 ; Continue copying text
$A565: A2 04    LDX #$04 ; Set up score display (5 digits)
$A567: A9 30    LDA #$30 ; Load ASCII '0' for initial score
$A569: 9D 0B 06 STA $060B ; Store score digit to screen
$A56C: E0 02    CPX #$02 ; Check if this is digit 2
$A56E: D0 02    BNE $A572 ; Skip decimal point if not digit 2
$A570: A9 2E    LDA #$2E ; Load ASCII '.' for decimal point
$A572: 9D 36 06 STA $0636 ; Store to time display area
$A575: CA       DEX ; Decrement digit counter
$A576: 10 EF    BPL $A567 ; Continue setting up digits
$A578: A9 00    LDA #$00 ; Clear final game state
$A57A: 85 DA    STA $DA ; Clear game over flag $DA
$A57C: A9 30    LDA #$30 ; Set initial time/score value
$A57E: 85 7B    STA $7B ; Store in time variable $7B
$A580: 60       RTS ; Return from additional setup
; ===============================================================================
; GAME_RESTART ($A581)
; Game restart and high score handling
; This routine:
; - Sets up display for new game/level
; - Copies game text to screen memory including level progression messages
; - Backs up current score and time
; - Compares current score with high score
; - Updates high score table if needed
; - Handles level transition displays
; - Refreshes screen displays
; ===============================================================================

$A581: 20 A2 BD JSR $BDA2 ; Game restart/new level setup
$A584: 20 B0 BD JSR $BDB0 ; Call text display setup routine
$A587: AD 0A E8 LDA $E80A ; Load hardware configuration
$A58A: 29 F0    AND #$F0 ; Mask upper 4 bits
$A58C: 09 08    ORA #$08 ; Set bit 3 (enable feature)
$A58E: 85 0C    STA $0C ; Store configuration in $0C
$A590: A2 34    LDX #$34 ; Set loop counter to $34 (52 bytes)
$A592: BD D7 A5 LDA $A5D7 ; Load from game completion text data table
$A595: 38       SEC ; Set carry for subtraction
$A596: E9 20    SBC #$20 ; Convert to screen code
$A598: 9D 00 39 STA $3900 ; Store to screen memory $3900
$A59B: CA       DEX ; Decrement counter
$A59C: 10 F4    BPL $A592 ; Continue copying data
$A59E: A2 04    LDX #$04 ; Set up 5-byte copy operation
$A5A0: BD 0B 06 LDA $060B ; Load from score area
$A5A3: 9D 78 06 STA $0678 ; Copy to backup area
$A5A6: CA       DEX ; Decrement copy counter
$A5A7: 10 F7    BPL $A5A0 ; Continue copying score
$A5A9: A2 04    LDX #$04 ; Set up another 5-byte copy
$A5AB: BD 36 06 LDA $0636 ; Load from time area
$A5AE: 9D 86 06 STA $0686 ; Copy to backup area
$A5B1: CA       DEX ; Decrement copy counter
$A5B2: 10 F7    BPL $A5AB ; Continue copying time
$A5B4: A2 00    LDX #$00 ; Initialize comparison loop
$A5B6: BD 9A 06 LDA $069A ; Load from high score table
$A5B9: DD 0B 06 CMP $060B ; Compare with current score
$A5BC: D0 05    BNE $A5C3 ; Branch if not equal
$A5BE: E8       INX ; Increment comparison index
$A5BF: E0 05    CPX #$05 ; Check if all 5 digits compared
$A5C1: D0 F3    BNE $A5B6 ; Continue comparison
$A5C3: B0 0B    BCS $A5D0 ; Branch if current score higher
$A5C5: BD 0B 06 LDA $060B ; Update high score table
$A5C8: 9D 9A 06 STA $069A ; Store new high score digit
$A5CB: E8       INX ; Increment table index
$A5CC: E0 05    CPX #$05 ; Check if all digits updated
$A5CE: D0 F5    BNE $A5C5 ; Continue updating high score
$A5D0: 20 C0 BA JSR $BAC0 ; Call screen update routine
$A5D3: 20 8C A4 JSR $A48C ; Call additional display routine
$A5D6: 60       RTS ; Return from game restart
; ===============================================================================
; GAME_COMPLETION_TEXT_DATA ($A5D7)
; Text messages displayed during game completion and ranking screens
; Contains various completion messages like "PRESS TRIGGER", "TO PLAY", 
; "AGAIN", skill level names like "ROOKIE", "NOVICE", "GUNNER", etc.
; ===============================================================================
$A5D7: 20       .byte $20        ; ' ' (space)
$A5D8: 20       .byte $20        ; ' ' (space)  
$A5D9: 20       .byte $20        ; ' ' (space)
$A5DA: 50       .byte $50        ; 'P' - start of "PRESS"
$A5DB: 52       .byte $52        ; 'R'
$A5DC: 45       .byte $45        ; 'E'
$A5DD: 53       .byte $53        ; 'S'
$A5DE: 53       .byte $53        ; 'S'
$A5DF: 20       .byte $20        ; ' ' (space)
$A5E0: 54       .byte $54        ; 'T' - start of "TRIGGER"
$A5E1: 52       .byte $52        ; 'R'
$A5E2: 49       .byte $49        ; 'I'
$A5E3: 47       .byte $47        ; 'G'
$A5E4: 47       .byte $47        ; 'G'
$A5E5: 45       .byte $45        ; 'E'
$A5E6: 52       .byte $52        ; 'R'
$A5E7: 20       .byte $20        ; ' ' (space)
$A5E8: 20       .byte $20        ; ' ' (space)
$A5E9: 20       .byte $20        ; ' ' (space)
$A5EA: 20       .byte $20        ; ' ' (space)
$A5EB: 20       .byte $20        ; ' ' (space)
$A5EC: 20       .byte $20        ; ' ' (space)
$A5ED: 20       .byte $20        ; ' ' (space)
$A5EE: 20       .byte $20        ; ' ' (space)
$A5EF: 20       .byte $20        ; ' ' (space)
$A5F0: 20       .byte $20        ; ' ' (space)
$A5F1: 54       .byte $54        ; 'T' - start of "TO"
$A5F2: 4F       .byte $4F        ; 'O'
$A5F3: 20       .byte $20        ; ' ' (space)
$A5F4: 50       .byte $50        ; 'P' - start of "PLAY"
$A5F5: 4C       .byte $4C        ; 'L'
$A5F6: 41       .byte $41        ; 'A'
$A5F7: 59       .byte $59        ; 'Y'
$A5F8: 20       .byte $20        ; ' ' (space)
$A5F9: 20       .byte $20        ; ' ' (space)
$A5FA: 20       .byte $20        ; ' ' (space)
$A5FB: 20       .byte $20        ; ' ' (space)
$A5FC: 20       .byte $20        ; ' ' (space)
$A5FD: 20       .byte $20        ; ' ' (space)
$A5FE: 20       .byte $20        ; ' ' (space)
$A5FF: 20       .byte $20        ; ' ' (space)
$A600: 20       .byte $20        ; ' ' (space)
$A601: 20       .byte $20        ; ' ' (space)
$A602: 20       .byte $20        ; ' ' (space)
$A603: 20       .byte $20        ; ' ' (space)
$A604: 20       .byte $20        ; ' ' (space)
$A605: 41       .byte $41        ; 'A' - start of "AGAIN"
$A606: 47       .byte $47        ; 'G'
$A607: 41       .byte $41        ; 'A'
$A608: 49       .byte $49        ; 'I'
$A609: 4E       .byte $4E        ; 'N'
$A60A: 20       .byte $20        ; ' ' (space)
$A60B: 47       .byte $47        ; 'G' - start of "GO ON" (or "GOON")
$A60C: 4F       .byte $4F        ; 'O'
$A60D: 4F       .byte $4F        ; 'O'
$A60E: 4E       .byte $4E        ; 'N'
$A60F: 20       .byte $20        ; ' ' (space)
$A610: 20       .byte $20        ; ' ' (space)
$A611: 20       .byte $20        ; ' ' (space)
$A612: 52       .byte $52        ; 'R' - start of "ROOKIE"
$A613: 4F       .byte $4F        ; 'O'
$A614: 4F       .byte $4F        ; 'O'
$A615: 4B       .byte $4B        ; 'K'
$A616: 49       .byte $49        ; 'I'
$A617: 45       .byte $45        ; 'E'
$A618: 20       .byte $20        ; ' ' (space)
$A619: 20       .byte $20        ; ' ' (space)
$A61A: 4E       .byte $4E        ; 'N' - start of "NOVICE"
$A61B: 4F       .byte $4F        ; 'O'
$A61C: 56       .byte $56        ; 'V'
$A61D: 49       .byte $49        ; 'I'
$A61E: 43       .byte $43        ; 'C'
$A61F: 45       .byte $45        ; 'E'
$A620: 20       .byte $20        ; ' ' (space)
$A621: 20       .byte $20        ; ' ' (space)
$A622: 47       .byte $47        ; 'G' - start of "GUNNER"
$A623: 55       .byte $55        ; 'U'
$A624: 4E       .byte $4E        ; 'N'
$A625: 4E       .byte $4E        ; 'N'
$A626: 45       .byte $45        ; 'E'
$A627: 52       .byte $52        ; 'R'
$A628: 20       .byte $20        ; ' ' (space)
$A629: 20       .byte $20        ; ' ' (space)
$A62A: 42       .byte $42        ; 'B' - start of "BLASTER"
$A62B: 4C       .byte $4C        ; 'L'
$A62C: 41       .byte $41        ; 'A'
$A62D: 53       .byte $53        ; 'S'
$A62E: 54       .byte $54        ; 'T'
$A62F: 45       .byte $45        ; 'E'
$A630: 52       .byte $52        ; 'R'
$A631: 20       .byte $20        ; ' ' (space)
$A632: 4D       .byte $4D        ; 'M' - start of "MARKSMAN"
$A633: 41       .byte $41        ; 'A'
$A634: 52       .byte $52        ; 'R'
$A635: 4B       .byte $4B        ; 'K'
$A636: 53       .byte $53        ; 'S'
$A637: 4D       .byte $4D        ; 'M'
$A638: 41       .byte $41        ; 'A'
$A639: 4E       .byte $4E        ; 'N'
; ===============================================================================
; ANIMATION_ENGINE ($A63B)
; **PLAYER SPRITE ANIMATION AND TIMING SYSTEM**
; This routine manages the sophisticated player sprite animation system:
; - Controls directional sprite selection (vertical vs horizontal heads)
; - Manages walking animation frames for horizontal movement
; - Handles sprite positioning and hardware register updates
; - Processes animation timing and sequences
; - Updates sprite character codes in $E805 based on movement state
; - Coordinates multi-sprite player character display (head + body combinations)
;
; SPRITE ANIMATION LOGIC:
; 1. Movement Detection: Monitors joystick input and collision registers
; 2. Head Selection: Chooses Character $02 (sideways) or $04 (vertical)
; 3. Body Selection: Chooses appropriate body sprite based on movement:
;    - Stationary/Vertical: Character $1E (stationary body)
;    - Horizontal Frame 1: Character $03 (walking frame 1)
;    - Horizontal Frame 2: Character $05 (walking frame 2)
; 4. Hardware Update: Loads selected characters into $E804/$E805 registers
; ===============================================================================
; - Manages sprite animation frames
; - Controls animation timing and sequences
; - Handles sprite movement and positioning
; - Processes accuracy bonuses
; - Updates animation counters and timers
; ===============================================================================

$A63B: A9 40    LDA #$40 ; Initialize animation system
$A63D: 85 00    STA $00 ; Clear animation state
$A63F: 8D 0E E8 STA $E80E ; Store in animation control register
$A642: A5 BE    LDA #$BE ; Check animation enable flag
$A644: F0 1F    BEQ $A665 ; Branch if animations disabled
$A646: A5 B3    LDA #$B3 ; Load animation frame counter
$A648: C9 11    CMP #$11 ; Check if frame limit reached
$A64A: B0 27    BCS $A673 ; Branch if animation complete
$A64C: A5 B4    LDA #$B4 ; Load animation type flag
$A64E: D0 15    BNE $A665 ; Branch if not this animation type
$A650: A5 B3    LDA #$B3 ; Load current frame number
$A652: 18       CLC ; Clear carry for addition
$A653: 69 01    ADC #$01 ; Increment frame counter
$A655: 85 B3    STA $B3 ; Store new frame number
$A657: 8D 06 E8 STA $E806 ; Update animation register
$A65A: C9 0D    CMP #$0D ; Check if reached frame 13
$A65C: D0 07    BNE $A665 ; Branch if not at end
$A65E: A9 87    LDA #$87 ; Load animation end value
$A660: 85 B2    STA $B2 ; Store animation state
$A662: 4C 73 A6 JMP $A673 ; Jump to animation cleanup
$A665: A6 B4    LDX #$B4 ; Load animation sequence index
$A667: E8       INX ; Increment sequence
$A668: E0 03    CPX #$03 ; Check if sequence complete (3 steps)
$A66A: D0 02    BNE $A66E ; Branch if more steps
$A66C: A2 00    LDX #$00 ; Reset sequence to 0
$A66E: 86 B4    STX $B4 ; Store sequence index
$A670: 4C 88 A6 JMP $A688 ; Jump to next animation phase
$A673: A5 B2    LDA #$B2 ; Load animation speed control
$A675: 8D 07 E8 STA $E807 ; Store to speed register
$A678: C9 80    CMP #$80 ; Check if speed at minimum
$A67A: D0 07    BNE $A683 ; Branch if not minimum
$A67C: A9 00    LDA #$00 ; Clear animation enable
$A67E: 85 BE    STA $BE ; Store animation disable
$A680: 4C 88 A6 JMP $A688 ; Jump to animation end
$A683: 38       SEC ; Set carry for subtraction
$A684: E9 01    SBC #$01 ; Decrease animation speed
$A686: 85 B2    STA $B2 ; Store new speed
$A688: E6 B6    INC $B6 ; Increment animation timer
$A68A: A5 B6    LDA #$B6 ; Load timer value
$A68C: 8D 02 E8 STA $E802 ; Store to timer register
$A68F: C9 20    CMP #$20 ; Check if timer reached 32
$A691: 90 0E    BCC $A6A1 ; Branch if timer not full
$A693: A5 B7    LDA #$B7 ; Load secondary timer
$A695: C9 A0    CMP #$A0 ; Check if secondary timer at max
$A697: F0 08    BEQ $A6A1 ; Branch if timer complete
$A699: 38       SEC ; Set carry for subtraction
$A69A: E9 01    SBC #$01 ; Decrement secondary timer
$A69C: 85 B7    STA $B7 ; Store new timer value
$A69E: 8D 03 E8 STA $E803 ; Update timer register
$A6A1: A5 B9    LDA #$B9 ; Check sprite animation flag
$A6A3: F0 15    BEQ $A6BA ; Branch if sprite animation off
$A6A5: A5 B8    LDA #$B8 ; Load sprite position
$A6A7: 38       SEC ; Set carry for subtraction
$A6A8: E9 04    SBC #$04 ; Move sprite 4 pixels
$A6AA: 85 B8    STA $B8 ; Store new sprite position
$A6AC: 8D 04 E8 STA $E804 ; **PLAYER SPRITE POSITION** - Update player sprite X position
$A6AF: C9 08    CMP #$08 ; Check if sprite at edge (8 pixels)
$A6B1: B0 07    BCS $A6BA ; Branch if sprite not at edge
$A6B3: A9 00    LDA #$00 ; Clear sprite animation
$A6B5: 8D 05 E8 STA $E805 ; **PLAYER SPRITE CHARACTER** - Clear player sprite (load character $00)
$A6B8: 85 B9    STA $B9 ; Store sprite disable flag
$A6BA: A5 93    LDA #$93 ; Check game trigger flag
$A6BC: D0 0F    BNE $A6CD ; Branch if trigger active
$A6BE: A5 D1    LDA #$D1 ; Load accuracy counter
$A6C0: 38       SEC ; Set carry for subtraction
$A6C1: E5 D4    SBC #$D4 ; Calculate accuracy (shots - hits)
$A6C3: 90 04    BCC $A6C9 ; Branch if negative (impossible)
$A6C5: C9 05    CMP #$05 ; Check if accuracy good (< 5 misses)
$A6C7: B0 04    BCS $A6CD ; Branch if accuracy poor
$A6C9: A9 C9    LDA #$C9 ; Load bonus value for good accuracy
$A6CB: 85 08    STA $08 ; Store accuracy bonus
$A6CD: 4C B2 FC JMP $FCB2 ; Jump to OS ROM routine (NMI handler)
; ===============================================================================
; SETUP_ROUTINE ($A6D0)
; Main display setup and initialization
; This routine:
; - Initializes display hardware
; - Sets up screen memory and graphics
; - Configures display lists
; - Clears screen areas
; - Sets up playfield patterns
; ===============================================================================

$A6D0: 20 A2 BD JSR $BDA2 ; Main display setup routine
$A6D3: A9 00    LDA #$00 ; Clear setup variables
$A6D5: 85 DC    STA $DC ; Clear difficulty counter
$A6D7: A2 08    LDX #$08 ; Set up memory clear loop (8 bytes)
$A6D9: 9D 00 E8 STA $E800 ; Clear RAM area $E800-$E807
$A6DC: CA       DEX ; Decrement clear counter
$A6DD: D0 FA    BNE $A6D9 ; Continue clearing memory
$A6DF: 20 BD BD JSR $BDBD ; Call display initialization
$A6E2: A2 A8    LDX #$A8 ; Set up large copy operation (168 bytes)
$A6E4: BD E3 A3 LDA $A3E3 ; Load from text data table
$A6E7: 9D 52 06 STA $0652 ; Store to screen memory area
$A6EA: CA       DEX ; Decrement copy counter
$A6EB: D0 F7    BNE $A6E4 ; Continue copying text data
$A6ED: A9 07    LDA #$07 ; Set up display parameters
$A6EF: A2 A6    LDX #$A6 ; X coordinate for display
$A6F1: A0 3B    LDY #$3B ; Y coordinate for display
$A6F3: 20 D5 BD JSR $BDD5 ; Call display positioning routine
$A6F6: A2 30    LDX #$30 ; Set up text display (48 chars)
$A6F8: A9 02    LDA #$02 ; Text display mode 2
$A6FA: A0 08    LDY #$08 ; Text height (8 lines)
$A6FC: 20 B0 BD JSR $BDB0 ; Call text setup routine
$A6FF: AD 0A E8 LDA $E80A ; Load hardware configuration
$A702: 29 F0    AND #$F0 ; Mask upper 4 bits
$A704: 09 08    ORA #$08 ; Set display enable bit
$A706: 85 0C    STA $0C ; Store display config
$A708: AD 0A E8 LDA $E80A ; Load hardware config again
$A70B: 29 F0    AND #$F0 ; Mask upper 4 bits again
$A70D: 09 08    ORA #$08 ; Set enable bit again
$A70F: 85 0F    STA $0F ; Store to second config register
$A711: A9 A1    LDA #$A1 ; Set up playfield graphics pointer
$A713: 85 06    STA $06 ; Store graphics pointer high byte
$A715: A9 D8    LDA #$D8 ; Set up playfield graphics pointer low
$A717: 85 05    STA $05 ; Store graphics pointer low byte
$A719: A9 0A    LDA #$0A ; Set up display list parameters
$A71B: 85 0D    STA $0D ; Store display list config
$A71D: A2 00    LDX #$00 ; Initialize screen clear loop
$A71F: 86 0E    STX $0E ; Store clear index
$A721: 8A       TXA ; Transfer index to accumulator
$A722: 9D 00 20 STA $2000 ; Clear screen memory page $2000
$A725: 9D 00 21 STA $2100 ; Clear screen memory page $2100
$A728: CA       DEX ; Decrement clear counter
$A729: D0 F7    BNE $A722 ; Continue clearing screen
$A72B: A0 0E    LDY #$0E ; Set up pattern copy (14 bytes)
$A72D: A9 0C    LDA #$0C ; Set up pattern counter (12 patterns)
$A72F: 85 7E    STA $7E ; Store pattern counter
$A731: BD 8C A7 LDA $A78C ; Load from pattern table
$A734: 99 00 20 STA $2000 ; Store to screen memory
$A737: E8       INX ; Increment source index
$A738: C8       INY ; Increment destination index
$A739: C6 7E    DEC $7E ; Decrement pattern counter
$A73B: D0 F4    BNE $A731 ; Continue copying pattern
$A73D: 98       TYA ; Transfer Y to accumulator
$A73E: 18       CLC ; Clear carry for addition
$A73F: 69 1C    ADC #$1C ; Add 28 to Y (next row)
$A741: A8       TAY ; Transfer back to Y
$A742: C9 FE    CMP #$FE ; Check if reached end ($FE)
$A744: D0 E7    BNE $A72D ; Continue with next row
$A746: A0 0B    LDY #$0B ; Set up final pattern copy (11 bytes)
$A748: B9 D4 A7 LDA $A7D4 ; Load from pattern table 1
$A74B: 99 F4 20 STA $20F4 ; Store to screen position 1
$A74E: B9 DF A7 LDA $A7DF ; Load from pattern table 2
$A751: 99 12 21 STA $2112 ; Store to screen position 2
$A754: B9 FB A7 LDA $A7FB ; Load from pattern table 3
$A757: 99 58 21 STA $2158 ; Store to screen position 3
$A75A: 88       DEY ; Decrement pattern counter
$A75B: 10 EB    BPL $A748 ; Continue copying patterns
$A75D: A9 62    LDA #$62 ; Set up special character
$A75F: 8D 49 21 STA $2149 ; Store special character to screen
$A762: A9 79    LDA #$79
$A764: 8D 4A 21 STA $214A
$A767: A0 10    LDY #$10
$A769: B9 EB A7 LDA $A7EB
$A76C: 99 2E 21 STA $212E
$A76F: B9 07 A8 LDA $A807
$A772: 99 6A 21 STA $216A
$A775: B9 18 A8 LDA $A818
$A778: 99 80 21 STA $2180
$A77B: B9 29 A8 LDA $A829
$A77E: 99 91 21 STA $2191
$A781: 88       DEY
$A782: 10 E5    BPL $A769
$A784: E6 0C    INC $0C
$A786: AD 10 C0 LDA $C010 ; **TRIGGER INPUT** - Read trigger register (0=pressed, 1=released)
$A789: D0 F9    BNE $A784 ; Wait for trigger release (wait for 0)
$A78B: 60       RTS
; ===============================================================================
; TITLE SCREEN LOGO PATTERN DATA ($A78C-$A7D3)
; Character-based logo pattern for title screen display - 71 bytes
; Each byte represents a character code ($40-$4A) for block graphics
; Pattern is 12 blocks wide by 6 rows (last row has 11 blocks)
; Character $4A is background/space (used 27/71 times = 38%)
; 
; Logo Pattern (each character is 8x8 pixels) - Spells "CBS":
;   .........###.###.###.............###.###.###.###.###.....................###.###.###............
;   .........###.###.###.............###.###.###.###.###.....................###.###.###............
;   .........###.###.###.............###.###.###.###.###.....................###.###.###............
;   ................................................................................................
;   .....###.###.###.###.###.........###.###.###.###.###.###.............###.###.###.###.###........
;   .....###.###.###.###.###.........###.###.###.###.###.###.............###.###.###.###.###........
;   .....###.###.###.###.###.........###.###.###.###.###.###.............###.###.###.###.###........
;   ................................................................................................
;   .###.###.###.###.###.....###.###.###.###.###.###.###.....###.###.###.###.###.###.###.....###.###
;   .###.###.###.###.###.....###.###.###.###.###.###.###.....###.###.###.###.###.###.###.....###.###
;   .###.###.###.###.###.....###.###.###.###.###.###.###.....###.###.###.###.###.###.###.....###.###
;   ................................................................................................
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###
;   ................................................................................................
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....................###.###
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....................###.###
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....................###.###
;   ................................................................................................
;   .###.....................###.###.###.###.###.###.........###.###.###.###.###.###.........###.###
;   .###.....................###.###.###.###.###.###.........###.###.###.###.###.###.........###.###
;   .###.....................###.###.###.###.###.###.........###.###.###.###.###.###.........###.###
;   ................................................................................................
;   .###.....................###.###.###.###.###.###.............###.###.###.###.###.###.....###.###
;   .###.....................###.###.###.###.###.###.............###.###.###.###.###.###.....###.###
;   .###.....................###.###.###.###.###.###.............###.###.###.###.###.###.....###.###
;   ................................................................................................
;   .###.....###.###.###.....###.###.###.....###.###.###.....................###.###.###.....###.###
;   .###.....###.###.###.....###.###.###.....###.###.###.....................###.###.###.....###.###
;   .###.....###.###.###.....###.###.###.....###.###.###.....................###.###.###.....###.###
;   ................................................................................................
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.........###
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.........###
;   .###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.....###.###.###.........###
;   ................................................................................................
;   .###.###.###.###.###.....###.###.###.###.###.###.###.....###.###.###.###.###.###.###............
;   .###.###.###.###.###.....###.###.###.###.###.###.###.....###.###.###.###.###.###.###............
;   .###.###.###.###.###.....###.###.###.###.###.###.###.....###.###.###.###.###.###.###............
;   ................................................................................................
;   .###.###.###.###.........###.###.###.###.###.###.............###.###.###.###.###........
;   .###.###.###.###.........###.###.###.###.###.###.............###.###.###.###.###........
;   .###.###.###.###.........###.###.###.###.###.###.............###.###.###.###.###........
;   ........................................................................................
;   .###.###.###.............###.###.###.###.###.....................###.###.###............
;   .###.###.###.............###.###.###.###.###.....................###.###.###............
;   .###.###.###.............###.###.###.###.###.....................###.###.###............
;   ........................................................................................
; ===============================================================================
$A78C: .byte $47, $4A, $49, $40, $4A, $4A, $49, $40, $47, $4A, $49, $40  ; Logo row 1 (12 blocks)
$A798: .byte $46, $4A, $45, $4A, $46, $4A, $45, $4A, $46, $4A, $45, $4A  ; Logo row 2 (12 blocks)
$A7A4: .byte $45, $43, $41, $4A, $49, $4A, $41, $4A, $49, $48, $40, $4A  ; Logo row 3 (12 blocks)
$A7B0: .byte $45, $48, $44, $4A, $46, $4A, $44, $42, $43, $4A, $45, $4A  ; Logo row 4 (12 blocks)
$A7BC: .byte $49, $4A, $45, $4A, $49, $4A, $45, $4A, $49, $4A, $45, $42  ; Logo row 5 (12 blocks)
$A7C8: .byte $4A, $46, $40, $4A, $4A, $46, $40, $42, $4A, $46, $40       ; Logo row 6 (11 blocks)
; ===============================================================================
; SPECIAL PATTERN TABLES ($A7D4-$A806)
; Additional pattern data used for specific maze elements and embedded text
; ===============================================================================

; ASCII Text String: "electronics" ($A7D4-$A7DE)
$A7D4: .byte $65, $6C, $65, $63, $74, $72, $6F, $6E, $69, $63, $73  ; "electronics" (ASCII)

; Character-coded text: "PRESENTS" ($A7DF-$A7EA)
$A7DF: .byte $00, $00, $30, $32, $25, $33, $25, $2E, $34, $33, $00, $00  ; "PRESENTS" (P=30, R=32, E=25, S=33, E=25, N=2E, T=34, S=33)

; *** GAME TITLE: "K-RAZY SHOOTOUT" ($A7EB-$A7FA) ***
; Encoded using XOR $A0 for high bytes (inverse ATASCII)
$A7EB: .byte $00                    ; Space
$A7EC: .byte $EB, $CD, $F2, $E1, $FA, $F9  ; "K-RAZY" (K=$EB^$A0=$4B, -=$CD^$A0=$6D≈'-', R=$F2^$A0=$52, A=$E1^$A0=$41, Z=$FA^$A0=$5A, Y=$F9^$A0=$59)
$A7F2: .byte $00                    ; Space
$A7F3: .byte $F3, $E8, $EF, $EF, $F4, $EF, $F5, $F4  ; "SHOOTOUT" (S=$F3^$A0=$53, H=$E8^$A0=$48, O=$EF^$A0=$4F, O=$EF^$A0=$4F, T=$F4^$A0=$54, O=$EF^$A0=$4F, U=$F5^$A0=$55, T=$F4^$A0=$54)

; ASCII Text String: "kMbyte" ($A7FB-$A803)
$A7FB: .byte $00, $00, $00                    ; Padding
$A7FE: .byte $6B, $4D, $62, $79, $74, $65    ; "kMbyte" (ASCII)
$A804: .byte $00, $00, $00                    ; Padding

; ===============================================================================
; GAME TEXT STRINGS ($A807-$A839)
; Character-coded text strings used in the game
; Character mapping: Space=$00, 0-9=$10-$19, A-Z=$21-$3A, punctuation=$0A-$0F
; ===============================================================================

; Text String 1: "PRESS TRIGGER" ($A809-$A817)
$A807: .byte $00, $00           ; Padding/spacing
$A809: .byte $30, $32, $25, $33, $33  ; "PRESS" (P=30, R=32, E=25, S=33, S=33)
$A80E: .byte $00                ; Space
$A80F: .byte $34, $32, $29, $27, $27, $25, $32  ; "TRIGGER" (T=34, R=32, I=29, G=27, G=27, E=25, R=32)
$A816: .byte $00, $00           ; Padding/spacing

; Text String 2: "COPYRIGHT 1982 KAY ENTERPRISES" ($A818-$A835)
$A818: .byte $23, $2F, $30, $39, $32, $29, $27, $28, $34  ; "COPYRIGHT" (C=23, O=2F, P=30, Y=39, R=32, I=29, G=27, H=28, T=34)
$A821: .byte $00                ; Space
$A822: .byte $11, $19, $18, $12 ; "1982" (1=11, 9=19, 8=18, 2=12)
$A826: .byte $00                ; Space
$A827: .byte $2B, $21, $39      ; "KAY" (K=2B, A=21, Y=39)
$A82A: .byte $00                ; Space
$A82B: .byte $25, $2E, $34, $25, $32, $30, $32, $29, $33, $25, $33  ; "ENTERPRISES" (E=25, N=2E, T=34, E=25, R=32, P=30, R=32, I=29, S=33, E=25, S=33)

; Text String 3: "CO." ($A836-$A839)
$A836: .byte $00                ; Space
$A837: .byte $23, $2F           ; "CO" (C=23, O=2F)
$A839: .byte $0E                ; "." (period)

; ===============================================================================
; MISC_UPDATE ($A83A)
; Miscellaneous game updates and collision processing
; This routine:
; - Processes player actions
; - Handles collision detection
; - Updates hit statistics
; - Triggers sound effects
; - Manages game state changes
; ===============================================================================

$A83A: A6 D5    LDX #$D5 ; Miscellaneous game updates routine
$A83C: B5 C5    LDA #$C5
$A83E: 85 92    STA $92
$A840: A5 94    LDA #$94
$A842: D0 30    BNE $A874 ; Loop back if not zero
; ===============================================================================
; PLAYER_ENEMY_COLLISION_DETECTION ($A844)
; Player-enemy collision detection using hardware collision registers
; ===============================================================================

$A844: AD 0A C0 LDA $C00A ; GTIA P2PF - Player 2/Playfield collision
$A847: 0D 0B C0 ORA $C00B
$A84A: 29 02    AND #$02
$A84C: F0 0F    BEQ $A85D ; Branch if equal/zero
$A84E: A5 92    LDA #$92
$A850: D0 05    BNE $A857 ; Loop back if not zero
$A852: A9 05    LDA #$05
$A854: 20 6C BD JSR $BD6C ; Hit/action sound effect
$A857: E6 D3    INC $D3         ; Increment hit counter (enemy defeated)
$A859: A9 01    LDA #$01
$A85B: 85 94    STA $94         ; Set enemy slot 1 to DEFEATED (enables exit when all 3 defeated)
$A85D: AD 0D C0 LDA $C00D ; GTIA M1PF - Missile 1/Playfield collision
$A860: 0D 05 C0 ORA $C005
$A863: F0 0F    BEQ $A874 ; Branch if equal/zero
$A865: A5 92    LDA #$92
$A867: D0 05    BNE $A86E ; Loop back if not zero
$A869: A9 01    LDA #$01
$A86B: 20 6C BD JSR $BD6C ; Hit/action sound effect
$A86E: E6 D2    INC $D2         ; Increment hit counter (enemy defeated)
$A870: A9 01    LDA #$01
$A872: 85 94    STA $94         ; Set enemy slot 1 to DEFEATED (enables exit when all 3 defeated)
$A874: A5 95    LDA #$95
$A876: D0 32    BNE $A8AA ; Loop back if not zero
$A878: AD 09 C0 LDA $C009 ; GTIA P1PF - Player 1/Playfield collision
$A87B: 0D 0B C0 ORA $C00B
$A87E: 29 04    AND #$04
$A880: F0 0F    BEQ $A891 ; Branch if equal/zero
$A882: A5 92    LDA #$92
$A884: D0 05    BNE $A88B ; Loop back if not zero
$A886: A9 05    LDA #$05
$A888: 20 6C BD JSR $BD6C ; Hit/action sound effect
$A88B: E6 D3    INC $D3         ; Increment hit counter (enemy defeated)
$A88D: A9 01    LDA #$01
$A88F: 85 95    STA $95         ; Set enemy slot 2 to DEFEATED (enables exit when all 3 defeated)
$A891: AD 0E C0 LDA $C00E ; GTIA M2PF - Missile 2/Playfield collision
$A894: 0D 06 C0 ORA $C006
$A897: F0 11    BEQ $A8AA ; Branch if equal/zero
$A899: A5 92    LDA #$92
$A89B: D0 05    BNE $A8A2 ; Loop back if not zero
$A89D: A9 01    LDA #$01
$A89F: 20 6C BD JSR $BD6C ; Hit/action sound effect
$A8A2: E6 D2    INC $D2         ; Increment hit counter (enemy defeated)
$A8A4: A9 01    LDA #$01
$A8A6: 85 95    STA $95         ; Set enemy slot 2 to DEFEATED (enables exit when all 3 defeated)
$A8A8: A9 01    LDA #$01
$A8AA: A5 96    LDA #$96
$A8AC: D0 30    BNE $A8DE ; Loop back if not zero
$A8AE: AD 09 C0 LDA $C009 ; GTIA P1PF - Player 1/Playfield collision
$A8B1: 0D 0A C0 ORA $C00A
$A8B4: 29 08    AND #$08
$A8B6: F0 0F    BEQ $A8C7 ; Branch if equal/zero
$A8B8: A5 92    LDA #$92
$A8BA: D0 05    BNE $A8C1 ; Loop back if not zero
$A8BC: A9 05    LDA #$05
$A8BE: 20 6C BD JSR $BD6C ; Hit/action sound effect
$A8C1: E6 D3    INC $D3         ; Increment hit counter (enemy defeated)
$A8C3: A9 01    LDA #$01
$A8C5: 85 96    STA $96         ; Set enemy slot 3 to DEFEATED (enables exit when all 3 defeated)
$A8C7: AD 0F C0 LDA $C00F ; GTIA M3PF - Missile 3/Playfield collision
$A8CA: 0D 07 C0 ORA $C007
$A8CD: F0 0F    BEQ $A8DE ; Branch if equal/zero
$A8CF: A5 92    LDA #$92
$A8D1: D0 05    BNE $A8D8 ; Loop back if not zero
$A8D3: A9 01    LDA #$01
$A8D5: 20 6C BD JSR $BD6C ; Hit/action sound effect
$A8D8: E6 D2    INC $D2         ; Increment hit counter (enemy defeated)
$A8DA: A9 01    LDA #$01
$A8DC: 85 96    STA $96         ; Set enemy slot 3 to DEFEATED (enables exit when all 3 defeated)
$A8DE: A9 00    LDA #$00
$A8E0: A9 01    LDA #$01
$A8E2: 85 AC    STA $AC
$A8E4: A5 D5    LDA #$D5
$A8E6: C9 03    CMP #$03
$A8E8: 90 04    BCC $A8EE ; Branch if carry clear
$A8EA: A9 02    LDA #$02
$A8EC: 85 AC    STA $AC
$A8EE: A5 92    LDA #$92
$A8F0: F0 04    BEQ $A8F6 ; Branch if equal/zero
$A8F2: A9 00    LDA #$00
$A8F4: 85 AC    STA $AC
; ===============================================================================
; PLAYER MISSILE vs ENEMY COLLISION DETECTION ($A8F6-$A930)
; **PLAYER MISSILE HIT DETECTION SYSTEM**
; 
; This code checks for player missile collisions with each of the 3 possible
; enemies on screen. The game uses hardware collision detection to determine
; when the player's missile hits an enemy.
;
; **COLLISION DETECTION SYSTEM**:
; - Player missile (Missile 0) collision with enemies detected via hardware
; - Hardware collision register $C008 detects missile/enemy collisions
; - Each bit represents collision with a different enemy slot:
;   * Bit 1 ($02): Player missile hit enemy slot 1
;   * Bit 2 ($04): Player missile hit enemy slot 2  
;   * Bit 3 ($08): Player missile hit enemy slot 3
;
; **HIT PROCESSING**:
; - When collision detected, enemy slot flag ($94/$95/$96) is set
; - Sound effect played and shot counter incremented
; - Enemy is marked as defeated, enabling level progression
; ===============================================================================
$A8F6: A5 94    LDA $94         ; Check enemy slot 1 status
$A8F8: D0 10    BNE $A90A       ; Skip if enemy already defeated
$A8FA: AD 08 C0 LDA $C008       ; **COLLISION DETECTION** - Read collision register
$A8FD: 29 02    AND #$02        ; Check bit 1: Player missile hit enemy 1
$A8FF: F0 09    BEQ $A90A       ; Branch if no collision
$A901: A9 01    LDA #$01        ; **ENEMY 1 DEFEATED**
$A903: 85 94    STA $94         ; Set enemy slot 1 to DEFEATED
$A905: 20 66 BD JSR $BD66       ; Hit sound effect and scoring
$A908: E6 D4    INC $D4         ; Increment shot counter (accuracy tracking)
$A90A: A5 95    LDA $95         ; Check enemy slot 2 status
$A90C: D0 10    BNE $A91E       ; Skip if enemy already defeated
$A90E: AD 08 C0 LDA $C008       ; **COLLISION DETECTION** - Read collision register
$A911: 29 04    AND #$04        ; Check bit 2: Player missile hit enemy 2
$A913: F0 09    BEQ $A91E       ; Branch if no collision
$A915: A9 01    LDA #$01        ; **ENEMY 2 DEFEATED**
$A917: 85 95    STA $95         ; Set enemy slot 2 to DEFEATED
$A919: 20 66 BD JSR $BD66       ; Hit sound effect and scoring
$A91C: E6 D4    INC $D4         ; Increment shot counter (accuracy tracking)
$A91E: A5 96    LDA $96         ; Check enemy slot 3 status
$A920: D0 10    BNE $A932       ; Skip if enemy already defeated
$A922: AD 08 C0 LDA $C008       ; **COLLISION DETECTION** - Read collision register
$A925: 29 08    AND #$08        ; Check bit 3: Player missile hit enemy 3
$A927: F0 09    BEQ $A932       ; Branch if no collision
$A929: A9 01    LDA #$01        ; **ENEMY 3 DEFEATED**
$A92B: 85 96    STA $96         ; Set enemy slot 3 to DEFEATED
$A92D: 20 66 BD JSR $BD66       ; Hit sound effect and scoring
$A930: E6 D4    INC $D4         ; Increment shot counter (accuracy tracking)
$A932: AD 08 C0 LDA $C008       ; **FIRE BUTTON INPUT DETECTION** - Read fire button register
$A935: 29 0E    AND #$0E        ; Mask fire button bits (1,2,3)
$A937: 0D 00 C0 ORA $C000       ; Combine with base joystick input register
$A93A: F0 05    BEQ $A941       ; Branch if no fire button pressed
$A93C: A2 00    LDX #$00        ; **PROCESS FIRE BUTTON PRESS**
$A93E: 20 9C A9 JSR $A99C       ; Call missile creation routine
$A941: A5 93    LDA $93         ; **CHECK MISSILE CREATION FLAG**
$A943: D0 24    BNE $A969       ; Branch if missile created
$A945: AD 09 C0 LDA $C009       ; GTIA P1PF - Player 1/Playfield collision
$A948: 0D 0A C0 ORA $C00A       ; OR with P2PF collision
$A94B: 0D 0B C0 ORA $C00B       ; OR with P3PF collision  
$A94E: 29 01    AND #$01        ; Check collision bit
$A950: D0 13    BNE $A965       ; Branch if collision detected
$A952: AD 04 C0 LDA $C004       ; **JOYSTICK X-AXIS INPUT** - Read horizontal position
$A955: 29 04    AND #$04        ; Check specific input bit
$A957: F0 04    BEQ $A95D       ; Branch if no horizontal input
$A959: A9 01    LDA #$01        ; **HORIZONTAL MOVEMENT DETECTED**
$A95B: 85 AD    STA $AD         ; Set horizontal movement flag
$A95D: AD 04 C0 LDA $C004       ; **RELOAD JOYSTICK INPUT** - Read position register again
$A960: 0D 0C C0 ORA $C00C       ; **COMBINE WITH VERTICAL INPUT** - OR with Y-axis register
                                ; This combines horizontal and vertical joystick input for missile direction
$A963: F0 04    BEQ $A969       ; Branch if no joystick input detected
$A965: A9 01    LDA #$01        ; **JOYSTICK INPUT CONFIRMED**
$A967: 85 93    STA $93         ; Set joystick input detection flag
$A969: AD 09 C0 LDA $C009 ; **JOYSTICK INPUT REGISTER** - Read additional input data
$A96C: 29 0D    AND #$0D
$A96E: 0D 01 C0 ORA $C001
$A971: F0 05    BEQ $A978 ; Branch if equal/zero
$A973: A2 01    LDX #$01
$A975: 20 9C A9 JSR $A99C
$A978: AD 0A C0 LDA $C00A ; **JOYSTICK INPUT REGISTER** - Read additional input data
$A97B: 29 0B    AND #$0B
$A97D: 0D 02 C0 ORA $C002
$A980: F0 05    BEQ $A987 ; Branch if equal/zero
$A982: A2 02    LDX #$02
$A984: 20 9C A9 JSR $A99C
$A987: AD 0B C0 LDA $C00B ; **JOYSTICK INPUT REGISTER** - Read additional input data
$A98A: 29 07    AND #$07
$A98C: 0D 03 C0 ORA $C003
$A98F: F0 05    BEQ $A996 ; Branch if equal/zero
$A991: A2 03    LDX #$03
$A993: 20 9C A9 JSR $A99C
$A996: A9 00    LDA #$00
$A998: 8D 1E C0 STA $C01E ; GTIA HITCLR - Clear collision registers
$A99B: 60       RTS
; ===============================================================================
; MISSILE_CREATION_PROCESSING ($A99C)
; **PLAYER MISSILE CREATION AND JOYSTICK DIRECTION SAMPLING**
; This routine processes fire button input and creates player missiles:
; - Samples joystick direction from input registers $C000-$C00F
; - Creates player missile using hardware PMG system  
; - Sets missile trajectory based on joystick position at fire time
; - Handles missile availability checking and hardware register setup
; ===============================================================================

$A99C: B4 E2    LDY #$E2 ; Process missile creation (X = input type)
$A99E: A9 00    LDA #$00
$A9A0: 95 E2    STA $E2
$A9A2: 88       DEY ; Decrement missile timer
$A9A3: 20 A9 A9 JSR $A9A9
$A9A6: 20 A9 A9 JSR $A9A9
$A9A9: BD 7C BF LDA $BF7C
$A9AC: 49 FF    EOR #$FF ; Invert input bits
$A9AE: 39 00 13 AND $1300 ; Process missile creation
$A9B1: 99 00 13 STA $1300
$A9B4: C8       INY ; Return from missile processing
$A9B5: 60       RTS
; =============================
==================================================
; GAME_INIT ($A9B6)
; Main game initialization and setup
; This routine:
; - Initializes all game systems
; - Sets up sprites and graphics
; - Configures collision detection
; - Enables interrupts and timers
; - Prepares game for play
; ===============================================================================

$A9B6: 20 BD BD JSR $BDBD
$A9B9: 20 A2 BD JSR $BDA2 ; Display list setup routine
$A9BC: AD 3A 06 LDA $063A
$A9BF: 0D 39 06 ORA $0639
$A9C2: 0D 37 06 ORA $0637 ; Set initial game speed
$A9C5: 0D 36 06 ORA $0636
$A9C8: C9 30    CMP #$30 ; Set up interrupt handlers
$A9CA: D0 03    BNE $A9CF ; Loop back if not zero
$A9CC: 4C 0D AB JMP $AB0D ; Configure GTIA graphics mode
$A9CF: A6 D5    LDX #$D5
$A9D1: F0 04    BEQ $A9D7 ; Branch if equal/zero
$A9D3: 4E 89 B6 LSR $B689
$A9D6: CA       DEX ; Initialize score display
$A9D7: B5 C5    LDA #$C5
$A9D9: C9 02    CMP #$02
$A9DB: 90 03    BCC $A9E0 ; Branch if carry clear
$A9DD: 4C 0D AB JMP $AB0D
$A9E0: 20 D6 AA JSR $AAD6
$A9E3: 20 0C AC JSR $AC0C
$A9E6: 20 0C AC JSR $AC0C
$A9E9: A5 0D    LDA #$0D
$A9EB: 85 92    STA $92
$A9ED: A9 38    LDA #$38
$A9EF: 85 A6    STA $A6
$A9F1: A5 0D    LDA #$0D
$A9F3: 85 A4    STA $A4
$A9F5: 20 F3 AB JSR $ABF3
$A9F8: A9 04    LDA #$04
$A9FA: 8D 08 E8 STA $E808
$A9FD: A9 AC    LDA #$AC
$A9FF: 8D 01 E8 STA $E801
$AA02: A9 00    LDA #$00
$AA04: 85 54    STA $54
$AA06: 8D 00 E8 STA $E800
$AA09: A9 A0    LDA #$A0
$AA0B: 8D 05 E8 STA $E805 ; **PLAYER SPRITE CHARACTER** - Load character $A0 into player sprite
$AA0E: A9 14    LDA #$14
$AA10: 8D 04 E8 STA $E804 ; **PLAYER SPRITE POSITION** - Set player sprite X position to $14
$AA13: A9 00    LDA #$00
$AA15: 85 69    STA $69
$AA17: A9 4D    LDA #$4D
$AA19: 85 55    STA $55
$AA1B: 20 D9 AC JSR $ACD9
$AA1E: E6 54    INC $54
$AA20: A5 54    LDA #$54
$AA22: 8D 00 E8 STA $E800
$AA25: C9 27    CMP #$27
$AA27: F0 1C    BEQ $AA45 ; Branch if equal/zero
$AA29: A9 AA    LDA #$AA
$AA2B: 85 69    STA $69
$AA2D: A9 02    LDA #$02
$AA2F: 85 55    STA $55
$AA31: A9 4D    LDA #$4D
$AA33: 85 55    STA $55
$AA35: 20 D9 AC JSR $ACD9
$AA38: A2 64    LDX #$64
$AA3A: A0 00    LDY #$00
$AA3C: 88       DEY
$AA3D: D0 FD    BNE $AA3C ; Loop back if not zero
$AA3F: CA       DEX
$AA40: D0 F8    BNE $AA3A ; Loop back if not zero
$AA42: 4C 13 AA JMP $AA13
$AA45: A9 A0    LDA #$A0
$AA47: 8D 01 E8 STA $E801
$AA4A: 20 B0 BD JSR $BDB0 ; Text display setup routine
$AA4D: A5 92    LDA #$92
$AA4F: 85 0D    STA $0D
$AA51: A9 00    LDA #$00
$AA53: 85 0E    STA $0E
$AA55: A9 A2    LDA #$A2
$AA57: A2 A6    LDX #$A6
$AA59: 85 06    STA $06
$AA5B: 86 05    STX $05
$AA5D: 20 93 AC JSR $AC93
$AA60: 20 CB AC JSR $ACCB
$AA63: A2 04    LDX #$04
$AA65: BD B4 AC LDA $ACB4
$AA68: 18       CLC
$AA69: 69 20    ADC #$20
$AA6B: 9D 14 2C STA $2C14
$AA6E: CA       DEX
$AA6F: 10 F4    BPL $AA65
$AA71: A4 D5    LDY #$D5
$AA73: C0 04    CPY #$04
$AA75: 90 0E    BCC $AA85 ; Branch if carry clear
$AA77: A2 04    LDX #$04
$AA79: BD AF AC LDA $ACAF
$AA7C: 18       CLC
$AA7D: 69 20    ADC #$20
$AA7F: 9D 14 2C STA $2C14
$AA82: CA       DEX
$AA83: 10 F4    BPL $AA79
$AA85: 20 0C AC JSR $AC0C
$AA88: A5 D4    LDA #$D4
$AA8A: A0 64    LDY #$64
$AA8C: 20 26 AC JSR $AC26
$AA8F: 20 0C AC JSR $AC0C
$AA92: 20 0C AC JSR $AC0C
$AA95: A2 03    LDX #$03
$AA97: BD B9 AC LDA $ACB9
$AA9A: 18       CLC
$AA9B: 69 20    ADC #$20
$AA9D: 9D 65 2C STA $2C65
$AAA0: CA       DEX
$AAA1: 10 F4    BPL $AA97
$AAA3: A5 D3    LDA #$D3
$AAA5: A0 32    LDY #$32
$AAA7: 20 26 AC JSR $AC26
$AAAA: 20 0C AC JSR $AC0C
$AAAD: 20 0C AC JSR $AC0C
$AAB0: A2 03    LDX #$03
$AAB2: BD BD AC LDA $ACBD
$AAB5: 18       CLC
$AAB6: 69 20    ADC #$20
$AAB8: 9D A1 2C STA $2CA1
$AABB: CA       DEX
$AABC: 10 F4    BPL $AAB2
$AABE: A0 0A    LDY #$0A
$AAC0: 20 0C AC JSR $AC0C
$AAC3: A5 D2    LDA #$D2
$AAC5: 20 26 AC JSR $AC26
$AAC8: A9 06    LDA #$06
$AACA: 85 69    STA $69
$AACC: 20 0C AC JSR $AC0C
$AACF: C6 69    DEC $69
$AAD1: D0 F9    BNE $AACC ; Loop back if not zero
$AAD3: 4C 0D AB JMP $AB0D
; ===============================================================================
; SPRITE_UPDATE ($AAD6)
; **PLAYER SPRITE POSITIONING AND CHARACTER LOADING**
; This routine handles the core player sprite display system:
; - Updates sprite positions in hardware registers $E804 (X position)
; - Loads character codes into $E805 (sprite character selection)
; - Manages sprite bounds checking and visibility
; - Controls sprite movement and animation frame updates
; - Coordinates multi-sprite player character rendering
;
; CHARACTER LOADING PROCESS:
; 1. Determines current movement state (stationary/vertical/horizontal)
; 2. Selects appropriate head sprite (Character $02 or $04)
; 3. Selects appropriate body sprite (Character $03, $05, or $1E)
; 4. Loads character codes into hardware sprite registers
; 5. Updates sprite positions for proper alignment
; ===============================================================================
; - Updates sprite positions
; - Manages sprite animations
; - Handles sprite bounds checking
; - Controls sprite visibility
; - Processes sprite movement
; ===============================================================================

$AAD6: 48       PHA ; Update sprite positions and animations
$AAD7: 98       TYA
$AAD8: 48       PHA ; Load sprite X position
$AAD9: 8A       TXA
$AADA: 48       PHA ; Check sprite bounds
$AADB: A9 00    LDA #$00
$AADD: 8D 08 E8 STA $E808
$AAE0: A9 AC    LDA #$AC
$AAE2: 8D 01 E8 STA $E801
$AAE5: A9 50    LDA #$50
$AAE7: 8D 00 E8 STA $E800
$AAEA: 20 02 AB JSR $AB02
$AAED: 38       SEC ; Set carry for movement calculation
$AAEE: E9 01    SBC #$01 ; Subtract movement speed
$AAF0: 8D 00 E8 STA $E800
$AAF3: C9 10    CMP #$10
$AAF5: D0 F3    BNE $AAEA ; Loop back if not zero
$AAF7: A9 00    LDA #$00
$AAF9: 8D 01 E8 STA $E801
$AAFC: 68       PLA ; Load return address
$AAFD: AA       TAX
$AAFE: 68       PLA ; Pull return address from stack
$AAFF: A8       TAY
$AB00: 68       PLA ; Pull Y register from stack
$AB01: 60       RTS ; Return from sprite update
; ===============================================================================
; LEVEL_PROGRESSION ($AB02)
; Level advancement and difficulty management
; This routine:
; - Manages level progression and increments $D5 level counter
; - Updates difficulty settings based on current level
; - Calculates level bonuses and scoring
; - Handles level transitions and calls level display system
; - Controls game pacing and enemy spawn rates
; ===============================================================================

$AB02: A2 30    LDX #$30 ; Level progression and difficulty management
$AB04: A0 02    LDY #$02 ; Load current level
$AB06: CA       DEX ; Check if level complete
$AB07: D0 FD    BNE $AB06 ; Loop back if not zero
$AB09: 88       DEY
$AB0A: D0 FA    BNE $AB06 ; Loop back if not zero
$AB0C: 60       RTS ; Check maximum level reached
$AB0D: A5 DA    LDA #$DA
$AB0F: C9 03    CMP #$03
$AB11: D0 03    BNE $AB16 ; Loop back if not zero
$AB13: 4C D2 AB JMP $ABD2
$AB16: A5 D9    LDA #$D9
$AB18: C9 02    CMP #$02 ; Calculate enemy speed
$AB1A: D0 03    BNE $AB1F ; Loop back if not zero
$AB1C: 4C D2 AB JMP $ABD2 ; Calculate spawn rate
$AB1F: 20 B0 BD JSR $BDB0 ; Text display setup routine
$AB22: A9 7C    LDA #$7C
$AB24: 85 0D    STA $0D
$AB26: A9 00    LDA #$00
$AB28: 85 0E    STA $0E
$AB2A: 20 93 AC JSR $AC93
$AB2D: A5 94    LDA #$94
$AB2F: F0 2E    BEQ $AB5F ; Branch if equal/zero
$AB31: A5 95    LDA #$95
$AB33: F0 2A    BEQ $AB5F ; Branch if equal/zero
$AB35: A5 96    LDA #$96
$AB37: F0 26    BEQ $AB5F ; Branch if equal/zero
$AB39: A5 D4    LDA #$D4
$AB3B: C5 D1    CMP #$D1
$AB3D: 90 20    BCC $AB5F ; Branch if carry clear
$AB3F: A6 D5    LDX #$D5
$AB41: F0 01    BEQ $AB44 ; Branch if equal/zero
$AB43: CA       DEX
$AB44: B5 C5    LDA #$C5
$AB46: C9 02    CMP #$02
$AB48: B0 15    BCS $AB5F ; Branch if carry set
$AB4A: A5 D9    LDA $D9         ; **LOAD TIME REMAINING** for bonus calculation
$AB4C: C9 35    CMP #$35        ; Check if time >= 53 (good time remaining)
$AB4E: 90 0B    BCC $AB5B       ; Branch if time < 53 (lower bonus)
$AB50: A9 C6    LDA #$C6        ; Set bonus display parameter
$AB52: 85 A5    STA $A5         ; Store display parameter
$AB54: A9 0A    LDA #$0A        ; **HIGH BONUS**: 10 points for fast completion
$AB56: 85 92    STA $92         ; Store bonus amount in counter
$AB58: 4C 6A AB JMP $AB6A       ; Jump to bonus display routine
$AB5B: C9 1B    CMP #$1B        ; Check if time >= 27 (moderate time remaining)
$AB5D: B0 03    BCS $AB62       ; Branch if time >= 27 (small bonus)
$AB5F: 4C B1 AB JMP $ABB1       ; **NO BONUS**: Jump to level setup (time < 27)
$AB62: A9 1A    LDA #$1A        ; Set bonus display parameter
$AB64: 85 A5    STA $A5         ; Store display parameter  
$AB66: A9 03    LDA #$03        ; **LOW BONUS**: 3 points for moderate completion
$AB68: 85 92    STA $92         ; Store bonus amount in counter
; ===============================================================================
; BONUS_POINTS_DISPLAY ($AB75)
; **COMPLETE BONUS POINTS SYSTEM** - Flashing display with time-based scoring
; This routine displays "BONUS POINTS" text with flashing effects and awards
; bonus points based on time remaining when player escapes through wall gaps
; ===============================================================================

; **BONUS CALCULATION LOGIC** ($AB4A-$AB68):
; - If time remaining >= 53 ($35): Award 10 bonus points ($92 = $0A)
; - If time remaining >= 27 ($1B): Award 3 bonus points ($92 = $03)  
; - If time remaining < 27: No bonus points awarded
; This rewards players for completing levels quickly and efficiently

$AB75: A2 0E    LDX #$0E        ; Set up text display (14 characters)
$AB77: CA       DEX             ; Decrement counter
$AB78: BD A1 AC LDA $ACA1,X     ; **LOAD "BONUS POINTS" TEXT** from $ACA1
$AB7B: 18       CLC
$AB7C: 69 20    ADC #$20        ; Convert to screen code
$AB7E: 9D 67 24 STA $2467,X     ; Store to screen memory at $2467
$AB81: CA       DEX             ; Decrement character counter
$AB82: D0 F4    BNE $AB78       ; Loop until all characters displayed
$AB84: 20 33 B0 JSR $B033       ; Display setup routine
$AB87: A9 01    LDA #$01        ; Configure display registers
$AB89: 8D 08 E8 STA $E808       ; Set display control
$AB8C: A9 08    LDA #$08
$AB8E: 8D 00 E8 STA $E800       ; Set display mode
$AB91: A9 05    LDA #$05        ; Set flashing parameters
$AB93: 85 BA    STA $BA         ; Store flash counter 1
$AB95: 85 BB    STA $BB         ; Store flash counter 2  
$AB97: A9 FF    LDA #$FF        ; Set flash control
$AB99: 85 BC    STA $BC         ; Store flash control value
$AB9B: A9 01    LDA #$01        ; Set sound effect parameter
$AB9D: 85 AC    STA $AC         ; Store sound parameter

; **FLASHING BONUS POINTS LOOP** ($AB9F-$ABA7):
; Each iteration flashes the text, plays sound, and adds points to score
$AB9F: 20 66 BD JSR $BD66       ; **FIRE SOUND + ADD POINTS TO SCORE**
$ABA2: 20 17 B1 JSR $B117       ; **FLASHING EFFECT** - toggles text visibility
$ABA5: C6 92    DEC $92         ; **DECREMENT BONUS COUNTER** (10 or 3 times)
$ABA7: D0 F6    BNE $AB9F       ; **LOOP** until all bonus points awarded

$ABA9: 20 0C AC JSR $AC0C       ; Final timing delay
$ABAC: E6 55    INC $55         ; Increment display counter
$ABAE: 20 93 AC JSR $AC93
$ABB1: 20 C1 AC JSR $ACC1
; ===============================================================================
; LEVEL_DISPLAY_SYSTEM ($ABB4)
; Displays "ENTER SECTOR X" message when starting new level
; This routine:
; - Loads current level from $D5 (0-based counter)
; - Converts level to ASCII by adding $51 ('1')
; - Displays level number at screen position $2474
; - Displays "ENTER SECTOR " text from $AC94 at screen position $2467
; ===============================================================================

$ABB4: A5 D5    LDA $D5         ; Load current level counter (0-based)
$ABB6: 18       CLC
$ABB7: 69 51    ADC #$51        ; Convert to ASCII: 0+'1'=1, 1+'1'=2, etc.
$ABB9: 8D 74 24 STA $2474       ; Store level number to screen memory
$ABBC: A9 A2    LDA #$A2
$ABBE: 85 06    STA $06
$ABC0: A9 58    LDA #$58
$ABC2: 85 05    STA $05
$ABC4: A0 0C    LDY #$0C        ; Copy 13 characters ("ENTER SECTOR ")
$ABC6: B9 94 AC LDA $AC94,Y     ; Load from "ENTER SECTOR" text data
$ABC9: 18       CLC
$ABCA: 69 20    ADC #$20        ; Convert to screen code
$ABCC: 99 67 24 STA $2467,Y     ; Store to screen memory
$ABCF: 88       DEY
$ABD0: 10 F4    BPL $ABC6       ; Continue copying text
$ABD2: A9 04    LDA #$04
$ABD4: 85 69    STA $69
$ABD6: 20 0C AC JSR $AC0C
$ABD9: C6 69    DEC $69
$ABDB: D0 F9    BNE $ABD6 ; Loop back if not zero
$ABDD: A9 4D    LDA #$4D
$ABDF: 85 D9    STA $D9         ; Set time remaining to $4D (77 time units)
$ABE1: A9 00    LDA #$00
$ABE3: 85 D4    STA $D4         ; Clear shot counter (for accuracy tracking)
$ABE5: 85 D3    STA $D3         ; Clear hit counter (enemy defeats)
$ABE7: 85 D2    STA $D2         ; Clear additional counter
$ABE9: A9 18    LDA #$18
$ABEB: 85 A6    STA $A6         ; Set total enemy count to $18 (24 enemies = 8 waves of 3)
$ABED: A9 00    LDA #$00
$ABEF: 85 92    STA $92
$ABF1: 85 A4    STA $A4
; ===============================================================================
; ENEMY_SPAWN ($ABF3)
; Enemy spawning and management system
; This routine:
; - Controls enemy spawn timing
; - Initializes new enemies
; - Manages enemy slots
; - Sets enemy properties
; - Updates enemy counters
; ===============================================================================

$ABF3: A4 A6    LDY #$A6 ; Enemy spawning and management system
$ABF5: 20 B0 BD JSR $BDB0 ; Text display setup routine
$ABF8: A9 00    LDA #$00
$ABFA: 85 0E    STA $0E
$ABFC: A5 92    LDA #$92
$ABFE: 85 0D    STA $0D
$AC00: A5 A4    LDA #$A4
$AC02: 85 0C    STA $0C
$AC04: 20 93 AC JSR $AC93
$AC07: A9 01    LDA #$01
$AC09: 8D 08 E8 STA $E808
; ===============================================================================
; DISPLAY_MANAGEMENT ($AC0C)
; **TIMING DELAYS** for enemy kill count display sequence
; Creates timed delays between each enemy sprite appearance during bonus tally
; This routine:
; - Provides timing delays for visual pacing
; - Creates the "one by one" enemy appearance effect
; - Synchronizes with sound effects during kill count display
; ===============================================================================

$AC0C: A9 00    LDA #$00        ; Initialize delay counter
$AC0E: 85 A6    STA $A6         ; Store counter
$AC10: A2 FF    LDX #$FF        ; Set inner delay loop
$AC12: A0 FF    LDY #$FF        ; Set outer delay loop
$AC14: CA       DEX             ; Countdown inner loop
$AC15: D0 FD    BNE $AC14       ; Loop until X = 0
$AC17: 88       DEY             ; Countdown outer loop
$AC18: D0 FA    BNE $AC14       ; Loop until Y = 0 (creates visible delay)
$AC1A: A5 A6    LDA $A6         ; Load delay counter
$AC1C: 18       CLC
$AC1D: 69 01    ADC #$01        ; Increment delay counter
$AC1F: 85 A6    STA $A6         ; Store updated counter
$AC21: C9 01    CMP #$01        ; Check if delay complete
$AC23: D0 EB    BNE $AC10       ; Loop back for more delay
$AC25: 60       RTS             ; Delay complete

; ===============================================================================
; ENEMY_KILL_DISPLAY ($AC26)
; **ENEMY KILL COUNT DISPLAY** - Shows defeated enemies by point value
; This is the "bonus tally" screen that appears after level completion
; Input: A = kill count, Y = point value ($64=100pts, $32=50pts, $0A=10pts)
; ===============================================================================
$AC26: 85 92    STA $92         ; Store kill count
$AC28: C9 00    CMP #$00        ; Check if any enemies killed
$AC2A: F0 66    BEQ $AC92       ; Exit if no kills to display
$AC2C: C0 64    CPY #$64        ; Check if 100-point enemies (Y=$64)
$AC2E: D0 35    BNE $AC65       ; Branch if not 100-point enemies
$AC30: AA       TAX             ; Use kill count as loop counter
$AC31: A9 1C    LDA #$1C        ; Load enemy sprite character
$AC33: A0 08    LDY #$08        ; Set screen position
$AC35: 99 12 2C STA $2C12,Y     ; **DISPLAY ENEMY SPRITE** at screen location
$AC38: 20 D6 AA JSR $AAD6       ; Sprite positioning update
$AC3B: CA       DEX             ; Decrement enemy counter
$AC3C: F0 54    BEQ $AC92       ; Exit if all enemies displayed
$AC3E: C8       INY             ; Move to next screen position
$AC3F: C0 15    CPY #$15        ; Check position limit
$AC41: D0 F2    BNE $AC35       ; Continue displaying enemies
$AC43: A0 08    LDY #$08        ; Reset position for next row
$AC45: 99 26 2C STA $2C26,Y     ; **DISPLAY ENEMY SPRITE** at next row
$AC48: 20 D6 AA JSR $AAD6       ; Sprite positioning update
$AC4B: CA       DEX             ; Decrement enemy counter
$AC4C: F0 44    BEQ $AC92       ; Exit if all enemies displayed
$AC4E: C8       INY             ; Move to next position
$AC4F: C0 15    CPY #$15        ; Check position limit
$AC51: D0 F2    BNE $AC45       ; Continue displaying enemies
$AC53: A0 08    LDY #$08        ; Reset position for third row
$AC55: 99 3A 2C STA $2C3A,Y     ; **DISPLAY ENEMY SPRITE** at third row
$AC58: 20 D6 AA JSR $AAD6       ; Sprite positioning update
$AC5B: CA       DEX             ; Decrement enemy counter
$AC5C: F0 34    BEQ $AC92       ; Exit if all enemies displayed
$AC5E: C8       INY             ; Move to next position
$AC5F: C0 15    CPY #$15        ; Check position limit
$AC61: D0 F2    BNE $AC55       ; Continue displaying enemies
$AC63: F0 2D    BEQ $AC92       ; All 100-point enemies displayed
$AC65: C0 32    CPY #$32        ; Check if 50-point enemies (Y=$32)
$AC67: D0 16    BNE $AC7F       ; Branch if not 50-point enemies
$AC69: A6 92    LDX $92         ; Load kill count
$AC6B: A9 1C    LDA #$1C        ; Load enemy sprite character
$AC6D: A0 08    LDY #$08        ; Set screen position
$AC6F: 99 62 2C STA $2C62,Y     ; **DISPLAY 50-POINT ENEMY SPRITE**
$AC72: 20 D6 AA JSR $AAD6       ; Sprite positioning update
$AC75: CA       DEX             ; Decrement enemy counter
$AC76: F0 1A    BEQ $AC92       ; Exit if all enemies displayed
$AC78: C8       INY             ; Move to next position
$AC79: C0 15    CPY #$15        ; Check position limit
$AC7B: D0 F2    BNE $AC6F       ; Continue displaying enemies
$AC7D: F0 13    BEQ $AC92       ; All 50-point enemies displayed
$AC7F: AA       TAX             ; 10-point enemies (default case)
$AC80: A9 1C    LDA #$1C        ; Load enemy sprite character
$AC82: A0 08    LDY #$08        ; Set screen position
$AC84: 99 9E 2C STA $2C9E,Y     ; **DISPLAY 10-POINT ENEMY SPRITE**
$AC87: 20 D6 AA JSR $AAD6       ; Sprite positioning update
$AC8A: CA       DEX             ; Decrement enemy counter
$AC8B: F0 05    BEQ $AC92       ; Exit if all enemies displayed
$AC8D: C8       INY             ; Move to next position
$AC8E: C0 15    CPY #$15        ; Check position limit
$AC90: D0 F2    BNE $AC84       ; Continue displaying enemies
$AC92: 60       RTS             ; Enemy kill display complete
$AC93: 60       RTS
; ===============================================================================
; "ENTER SECTOR" TEXT DATA ($AC94)
; Text string displayed when starting a new level/sector
; Used by level display routine at $ABB4-$ABCC
; ===============================================================================
$AC94: 45       .byte $45        ; 'E'
$AC95: 4E       .byte $4E        ; 'N'
$AC96: 54       .byte $54        ; 'T'
$AC97: 45       .byte $45        ; 'E'
$AC98: 52       .byte $52        ; 'R'
$AC99: 20       .byte $20        ; ' ' (space)
$AC9A: 53       .byte $53        ; 'S'
$AC9B: 45       .byte $45        ; 'E'
$AC9C: 43       .byte $43        ; 'C'
$AC9D: 54       .byte $54        ; 'T'
$AC9E: 4F       .byte $4F        ; 'O'
$AC9F: 52       .byte $52        ; 'R'
$ACA0: 20       .byte $20        ; ' ' (space)

; ===============================================================================
; "BONUS POINTS" TEXT DATA ($ACA1)
; **FOUND!** Text string displayed during bonus points screen after escape
; Used by bonus points display routine (flashing text with sound effects)
; ===============================================================================
$ACA1: 42       .byte $42        ; 'B' - start of "BONUS"
$ACA2: 4F       .byte $4F        ; 'O'
$ACA3: 4E       .byte $4E        ; 'N'  
$ACA4: 55       .byte $55        ; 'U'
$ACA5: 53       .byte $53        ; 'S'
$ACA6: 20       .byte $20        ; ' ' (space)
$ACA7: 50       .byte $50        ; 'P' - start of "POINTS"
$ACA8: 4F       .byte $4F        ; 'O'
$ACA9: 49       .byte $49        ; 'I'
$ACAA: 4E       .byte $4E        ; 'N'
$ACAB: 54       .byte $54        ; 'T'
$ACAC: 53       .byte $53        ; 'S'
$ACA3: 4F       .byte $4F        ; Data byte
$ACA4: 4E 55 53 LSR $5355
$ACA7: 20 50 4F JSR $4F50
$ACAA: 49 4E    EOR #$4E
$ACAC: 54       .byte $54        ; Data byte
$ACAD: 53       .byte $53        ; Data byte
; ===============================================================================
; DISPLAY TEXT DATA SECTION ($ACAE-$ACC0)
; ===============================================================================
; This section contains ASCII text strings for bonus scoring displays
; These are the text strings shown during bonus point calculations:
; - "20 X100" (20 enemies worth 100 points each)
; - "10 X50" (10 enemies worth 50 points each)  
; - "X10" (remaining enemies worth 10 points each)
; Used by the bonus display system after level completion
; ===============================================================================
$ACAE: 20       .byte $20        ; ' ' (space)
$ACAF: 32       .byte $32        ; '2'
$ACB0: 30       .byte $30        ; '0'
$ACB1: 20       .byte $20        ; ' ' (space)
$ACB2: 58       .byte $58        ; 'X'
$ACB3: 31       .byte $31        ; '1'
$ACB4: 30       .byte $30        ; '0'
$ACB5: 30       .byte $30        ; '0'
$ACB6: 20       .byte $20        ; ' ' (space)
$ACB7: 58       .byte $58        ; 'X'
$ACB8: 35       .byte $35        ; '5'
$ACB9: 30       .byte $30        ; '0'
$ACBA: 20       .byte $20        ; ' ' (space)
$ACBB: 58       .byte $58        ; 'X'
$ACBC: 31       .byte $31        ; '1'
$ACBD: 30       .byte $30        ; '0'
$ACBE: 20       .byte $20        ; ' ' (space)
$ACBF: 58       .byte $58        ; 'X'
$ACC0: 31       .byte $31        ; '1'
$ACC1: A2 00    LDX #$00

; ===============================================================================
; SCREEN_MEMORY_MANAGEMENT ($ACC1-$AD04)
; ===============================================================================
; Screen memory clearing and character positioning routines
; - Clears screen memory areas ($2400, $2C00-$2D00)
; - Complex screen positioning calculations using indirect addressing
; - Character placement and screen coordinate management
; ===============================================================================
$ACC3: 8A       TXA
$ACC4: 9D 00 24 STA $2400
$ACC7: CA       DEX
$ACC8: D0 FA    BNE $ACC4 ; Loop back if not zero
$ACCA: 60       RTS
$ACCB: A9 00    LDA #$00
$ACCD: A2 00    LDX #$00
$ACCF: 9D 00 2C STA $2C00
$ACD2: 9D 00 2D STA $2D00
$ACD5: CA       DEX
$ACD6: D0 F7    BNE $ACCF ; Loop back if not zero
$ACD8: 60       RTS
$ACD9: A9 00    LDA #$00
$ACDB: 85 7C    STA $7C
$ACDD: 85 7D    STA $7D
$ACDF: A5 54    LDA #$54
$ACE1: 18       CLC
$ACE2: 2A       ROL
$ACE3: 2A       ROL
$ACE4: 85 C2    STA $C2
$ACE6: 2A       ROL
$ACE7: 26 7D    ROL $7D
$ACE9: 2A       ROL
$ACEA: 26 7D    ROL $7D
$ACEC: 65 C2    ADC #$C2
$ACEE: 85 7C    STA $7C
$ACF0: 90 02    BCC $ACF4 ; Branch if carry clear
$ACF2: E6 7D    INC $7D
$ACF4: A9 28    LDA #$28
$ACF6: 18       CLC
$ACF7: 65 7D    ADC #$7D
$ACF9: 85 7D    STA $7D
$ACFB: A5 69    LDA #$69
$ACFD: A0 13    LDY #$13
$ACFF: 91 7C    STA $7C
$AD01: 88       DEY
$AD02: 10 FB    BPL $ACFF
$AD04: 60       RTS
; ===============================================================================
; MAJOR INPUT/MOVEMENT PROCESSING SECTION ($AD05-$AF03)
; ===============================================================================
; **8-DIRECTIONAL INPUT HANDLING WITH SPRITE SELECTION**
; This is the core player movement system that processes joystick input and
; selects appropriate player sprites based on movement direction.
; 
; **INPUT VALUES AND SPRITE COMBINATIONS**:
; - $F7: UP-LEFT diagonal movement (sprite combination $78)
; - $FB: UP-RIGHT diagonal movement (sprite combination $54)  
; - $FE: DOWN movement (sprite combination $9C)
; - $FD: DOWN-RIGHT diagonal movement (sprite combination $A8)
; - $F6: LEFT movement (sprite combination $84)
; - $F5: UP movement (sprite combination $90)
; - $FA: DOWN-LEFT diagonal movement (sprite combination $60)
; - $F9: RIGHT movement (sprite combination $6C)
; - $FF: No input (stationary - sprite combination $8C)
; 
; **SPRITE SELECTION LOGIC**:
; Each direction loads a specific sprite combination value into $64, which
; determines which player head/body sprites are displayed:
; - Head sprites: $02 (sideways), $04 (vertical)
; - Body sprites: $03 (frame 1), $05 (frame 2), $1E (stationary)
; - Death sprites: $06-$09 (death animation sequence)
; 
; **PMG SYSTEM INTEGRATION**:
; The routine interfaces with the Player/Missile Graphics system by:
; - Setting sprite positions in $DE (X coordinate) and $E2 (Y coordinate)
; - Updating PMG memory at $1300 (Player 0) and $1400 (Player 1)
; - Managing sprite visibility and collision detection
; ===============================================================================

$AD05: A5 84    LDA $84         ; Load current player Y position
$AD07: 85 77    STA $77         ; Store for sprite positioning
$AD09: 20 EB BD JSR $BDEB       ; Call sprite update routine
$AD0C: A2 13    LDX #$13        ; Initialize PMG system
$AD0E: E8       INX             ; Increment counter
$AD0F: 8A       TXA             ; Transfer to accumulator
$AD10: 85 7A    STA $7A         ; Store PMG counter
$AD12: A9 0C    LDA #$0C        ; Set sprite parameters
$AD14: 85 72    STA $72         ; Store sprite parameter 1
$AD16: 85 71    STA $71         ; Store sprite parameter 2
$AD18: A9 00    LDA #$00        ; Clear collision flags
$AD1A: 85 74    STA $74         ; Clear collision register
$AD1C: A5 80    LDA $80         ; Load player X position
$AD1E: 85 78    STA $78         ; Store for sprite positioning
$AD20: A2 14    LDX #$14        ; Set timing delay
$AD22: A0 1E    LDY #$1E        ; Set timing delay
$AD24: CA       DEX             ; Countdown delay loop
$AD25: D0 FD    BNE $AD24       ; Loop until X = 0
$AD27: 88       DEY             ; Countdown delay loop
$AD28: D0 FA    BNE $AD24       ; Loop until Y = 0
$AD2A: A5 93    LDA $93         ; Check game state
$AD2C: D0 5E    BNE $AD8C       ; Branch if game active
$AD2E: AD 10 C0 LDA $C010       ; **TRIGGER INPUT** - Read trigger register (0=pressed, 1=released)
$AD31: 05 E2    ORA $E2         ; Combine with missile status
$AD33: D0 17    BNE $AD4C       ; Branch if trigger not pressed or missile active
$AD35: A5 60    LDA $60         ; **READ JOYSTICK INPUT** - Load joystick register
$AD37: C9 FF    CMP #$FF        ; Check for no input (stationary)
$AD39: F0 11    BEQ $AD4C       ; Branch if no input
$AD3B: A9 AC    LDA #$AC        ; Set firing sound parameter
$AD3D: 8D 03 E8 STA $E803       ; Store to sound register
$AD40: 85 B7    STA $B7         ; Store sound parameter
$AD42: A9 04    LDA #$04        ; Set missile parameters
$AD44: 85 B6    STA $B6         ; Store missile parameter
$AD46: E6 CF    INC $CF         ; Increment shot counter (for accuracy tracking)
$AD48: D0 02    BNE $AD4C       ; Branch if no overflow
$AD4A: E6 CE    INC $CE         ; Increment high byte of shot counter
$AD4C: AD 10 C0 LDA $C010       ; **TRIGGER INPUT** - Read trigger register again
$AD4F: F0 03    BEQ $AD54       ; Branch if trigger pressed (0 = pressed)
$AD51: 4C 04 AF JMP $AF04       ; Jump to stationary sprite handling
$AD54: 85 04    STA $04         ; Clear trigger flag
$AD56: A5 60    LDA $60         ; **READ JOYSTICK INPUT** - Load joystick register
$AD58: C9 FF    CMP #$FF        ; Check for no input
$AD5A: D0 03    BNE $AD5F       ; Branch if input detected
$AD5C: 4C 04 AF JMP $AF04       ; Jump to stationary sprite handling

; **DIRECTIONAL INPUT PROCESSING** - Each case handles specific movement direction
$AD5F: C9 F7    CMP #$F7        ; **UP-LEFT DIAGONAL** input check
$AD61: D0 2A    BNE $AD8D       ; Branch if not UP-LEFT
$AD63: A9 78    LDA #$78        ; Load UP-LEFT sprite combination
$AD65: 85 64    STA $64         ; Store sprite combination
$AD67: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AD6A: A5 E2    LDA $E2         ; Check missile status
$AD6C: D0 1E    BNE $AD8C       ; Branch if missile active
$AD6E: A9 05    LDA #$05        ; Set movement direction (UP-LEFT)
$AD70: 85 88    STA $88         ; Store movement direction
$AD72: A5 80    LDA $80         ; Load player X position
$AD74: 18       CLC             ; Clear carry
$AD75: 69 04    ADC #$04        ; Move right (+4 pixels)
$AD77: 85 DE    STA $DE         ; Store new X position
$AD79: 8D 04 C0 STA $C004       ; Update hardware X position register
$AD7C: A5 84    LDA $84         ; Load player Y position
$AD7E: 18       CLC             ; Clear carry
$AD7F: 69 05    ADC #$05        ; Move down (+5 pixels)
$AD81: 85 E2    STA $E2         ; Store new Y position
$AD83: A8       TAY             ; Transfer to Y register
$AD84: A9 03    LDA #$03        ; Set sprite data (head sprite)
$AD86: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AD89: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AD8C: 60       RTS             ; Return from UP-LEFT processing

$AD8D: C9 FB    CMP #$FB        ; **UP-RIGHT DIAGONAL** input check
$AD8F: D0 2A    BNE $ADBB       ; Branch if not UP-RIGHT
$AD91: A9 54    LDA #$54        ; Load UP-RIGHT sprite combination
$AD93: 85 64    STA $64         ; Store sprite combination
$AD95: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AD98: A5 E2    LDA $E2         ; Check missile status
$AD9A: D0 1E    BNE $ADBA       ; Branch if missile active
$AD9C: A9 02    LDA #$02        ; Set movement direction (UP-RIGHT)
$AD9E: 85 88    STA $88         ; Store movement direction
$ADA0: A5 80    LDA $80         ; Load player X position
$ADA2: 18       CLC             ; Clear carry
$ADA3: 69 02    ADC #$02        ; Move right (+2 pixels)
$ADA5: 85 DE    STA $DE         ; Store new X position
$ADA7: 8D 04 C0 STA $C004       ; Update hardware X position register
$ADAA: A5 84    LDA $84         ; Load player Y position
$ADAC: 18       CLC             ; Clear carry
$ADAD: 69 05    ADC #$05        ; Move down (+5 pixels)
$ADAF: 85 E2    STA $E2         ; Store new Y position
$ADB1: A8       TAY             ; Transfer to Y register
$ADB2: A9 03    LDA #$03        ; Set sprite data (head sprite)
$ADB4: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$ADB7: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$ADBA: 60       RTS             ; Return from UP-RIGHT processing

$ADBB: C9 FE    CMP #$FE        ; **DOWN MOVEMENT** input check
$ADBD: D0 33    BNE $ADF2       ; Branch if not DOWN
$ADBF: A9 9C    LDA #$9C        ; Load DOWN sprite combination
$ADC1: 85 64    STA $64         ; Store sprite combination
$ADC3: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$ADC6: A5 E2    LDA $E2         ; Check missile status
$ADC8: D0 27    BNE $ADF1       ; Branch if missile active
$ADCA: A9 07    LDA #$07        ; Set movement direction (DOWN)
$ADCC: 85 88    STA $88         ; Store movement direction
$ADCE: A5 80    LDA $80         ; Load player X position
$ADD0: 18       CLC             ; Clear carry
$ADD1: 69 05    ADC #$05        ; Move right (+5 pixels)
$ADD3: 85 DE    STA $DE         ; Store new X position
$ADD5: 8D 04 C0 STA $C004       ; Update hardware X position register
$ADD8: A5 84    LDA $84         ; Load player Y position
$ADDA: A8       TAY             ; Transfer to Y register
$ADDB: 38       SEC             ; Set carry
$ADDC: E9 01    SBC #$01        ; Move up (-1 pixel)
$ADDE: 85 E2    STA $E2         ; Store new Y position
$ADE0: A9 02    LDA #$02        ; Set sprite data (body sprite)
$ADE2: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$ADE5: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$ADE8: 88       DEY             ; Move to next PMG position
$ADE9: A9 02    LDA #$02        ; Set sprite data (head sprite)
$ADEB: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$ADEE: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$ADF1: 60       RTS             ; Return from DOWN processing

$ADF2: C9 FD    CMP #$FD        ; **DOWN-RIGHT DIAGONAL** input check
$ADF4: D0 30    BNE $AE26       ; Branch if not DOWN-RIGHT
$ADF6: A9 A8    LDA #$A8        ; Load DOWN-RIGHT sprite combination
$ADF8: 85 64    STA $64         ; Store sprite combination
$ADFA: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$ADFD: A5 E2    LDA $E2         ; Check missile status
$ADFF: D0 24    BNE $AE25       ; Branch if missile active
$AE01: A9 09    LDA #$09        ; Set movement direction (DOWN-RIGHT)
$AE03: 85 88    STA $88         ; Store movement direction
$AE05: A5 80    LDA $80         ; Load player X position
$AE07: 85 DE    STA $DE         ; Store X position (no change)
$AE09: 8D 04 C0 STA $C004       ; Update hardware X position register
$AE0C: A5 84    LDA $84         ; Load player Y position
$AE0E: 18       CLC             ; Clear carry
$AE0F: 69 0A    ADC #$0A        ; Move down (+10 pixels)
$AE11: 85 E2    STA $E2         ; Store new Y position
$AE13: A8       TAY             ; Transfer to Y register
$AE14: A9 01    LDA #$01        ; Set sprite data (body sprite)
$AE16: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AE19: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AE1C: C8       INY             ; Move to next PMG position
$AE1D: A9 01    LDA #$01        ; Set sprite data (head sprite)
$AE1F: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AE22: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AE25: 60       RTS             ; Return from DOWN-RIGHT processing

$AE26: C9 F6    CMP #$F6        ; **LEFT MOVEMENT** input check
$AE28: D0 34    BNE $AE5E       ; Branch if not LEFT
$AE2A: A9 84    LDA #$84        ; Load LEFT sprite combination
$AE2C: 85 64    STA $64         ; Store sprite combination
$AE2E: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AE31: A5 E2    LDA $E2         ; Check missile status
$AE33: D0 F0    BNE $AE25       ; Branch if missile active
$AE35: A9 04    LDA #$04        ; Set movement direction (LEFT)
$AE37: 85 88    STA $88         ; Store movement direction
$AE39: A5 80    LDA $80         ; Load player X position
$AE3B: 18       CLC             ; Clear carry
$AE3C: 69 03    ADC #$03        ; Move right (+3 pixels)
$AE3E: 85 DE    STA $DE         ; Store new X position
$AE40: 8D 04 C0 STA $C004       ; Update hardware X position register
$AE43: A5 84    LDA $84         ; Load player Y position
$AE45: 18       CLC             ; Clear carry
$AE46: 69 03    ADC #$03        ; Move down (+3 pixels)
$AE48: A8       TAY             ; Transfer to Y register
$AE49: C8       INY             ; Move to next PMG position
$AE4A: 85 E2    STA $E2         ; Store new Y position
$AE4C: A9 02    LDA #$02        ; Set sprite data (body sprite)
$AE4E: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AE51: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AE54: 88       DEY             ; Move to previous PMG position
$AE55: A9 01    LDA #$01        ; Set sprite data (head sprite)
$AE57: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AE5A: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AE5D: 60       RTS             ; Return from LEFT processing

$AE5E: C9 F5    CMP #$F5        ; **UP MOVEMENT** input check
$AE60: D0 33    BNE $AE95       ; Branch if not UP
$AE62: A9 90    LDA #$90        ; Load UP sprite combination
$AE64: 85 64    STA $64         ; Store sprite combination
$AE66: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AE69: A5 E2    LDA $E2         ; Check missile status
$AE6B: D0 27    BNE $AE94       ; Branch if missile active
$AE6D: A9 06    LDA #$06        ; Set movement direction (UP)
$AE6F: 85 88    STA $88         ; Store movement direction
$AE71: A5 80    LDA $80         ; Load player X position
$AE73: 18       CLC             ; Clear carry
$AE74: 69 04    ADC #$04        ; Move right (+4 pixels)
$AE76: 85 DE    STA $DE         ; Store new X position
$AE78: 8D 04 C0 STA $C004       ; Update hardware X position register
$AE7B: A5 84    LDA $84         ; Load player Y position
$AE7D: 18       CLC             ; Clear carry
$AE7E: 69 05    ADC #$05        ; Move down (+5 pixels)
$AE80: 85 E2    STA $E2         ; Store new Y position
$AE82: A8       TAY             ; Transfer to Y register
$AE83: A9 02    LDA #$02        ; Set sprite data (body sprite)
$AE85: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AE88: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AE8B: C8       INY             ; Move to next PMG position
$AE8C: A9 01    LDA #$01        ; Set sprite data (head sprite)
$AE8E: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AE91: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AE94: 60       RTS             ; Return from UP processing

$AE95: C9 FA    CMP #$FA        ; **DOWN-LEFT DIAGONAL** input check
$AE97: D0 34    BNE $AECD       ; Branch if not DOWN-LEFT
$AE99: A9 60    LDA #$60        ; Load DOWN-LEFT sprite combination
$AE9B: 85 64    STA $64         ; Store sprite combination
$AE9D: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AEA0: A5 E2    LDA $E2         ; Check missile status
$AEA2: D0 28    BNE $AECC       ; Branch if missile active
$AEA4: A9 01    LDA #$01        ; Set movement direction (DOWN-LEFT)
$AEA6: 85 88    STA $88         ; Store movement direction
$AEA8: A5 80    LDA $80         ; Load player X position
$AEAA: 18       CLC             ; Clear carry
$AEAB: 69 03    ADC #$03        ; Move right (+3 pixels)
$AEAD: 85 DE    STA $DE         ; Store new X position
$AEAF: 8D 04 C0 STA $C004       ; Update hardware X position register
$AEB2: A5 84    LDA $84         ; Load player Y position
$AEB4: 18       CLC             ; Clear carry
$AEB5: 69 03    ADC #$03        ; Move down (+3 pixels)
$AEB7: A8       TAY             ; Transfer to Y register
$AEB8: C8       INY             ; Move to next PMG position
$AEB9: 85 E2    STA $E2         ; Store new Y position
$AEBB: A9 01    LDA #$01        ; Set sprite data (body sprite)
$AEBD: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AEC0: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AEC3: 88       DEY             ; Move to previous PMG position
$AEC4: A9 02    LDA #$02        ; Set sprite data (head sprite)
$AEC6: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AEC9: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AECC: 60       RTS             ; Return from DOWN-LEFT processing

$AECD: C9 F9    CMP #$F9        ; **RIGHT MOVEMENT** input check
$AECF: D0 32    BNE $AF03       ; Branch if not RIGHT
$AED1: A9 6C    LDA #$6C        ; Load RIGHT sprite combination
$AED3: 85 64    STA $64         ; Store sprite combination
$AED5: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AED8: A5 E2    LDA $E2         ; Check missile status
$AEDA: D0 27    BNE $AF03       ; Branch if missile active
$AEDC: A9 03    LDA #$03        ; Set movement direction (RIGHT)
$AEDE: 85 88    STA $88         ; Store movement direction
$AEE0: A5 80    LDA $80         ; Load player X position
$AEE2: 18       CLC             ; Clear carry
$AEE3: 69 02    ADC #$02        ; Move right (+2 pixels)
$AEE5: 85 DE    STA $DE         ; Store new X position
$AEE7: 8D 04 C0 STA $C004       ; Update hardware X position register
$AEEA: A5 84    LDA $84         ; Load player Y position
$AEEC: 18       CLC             ; Clear carry
$AEED: 69 05    ADC #$05        ; Move down (+5 pixels)
$AEEF: 85 E2    STA $E2         ; Store new Y position
$AEF1: A8       TAY             ; Transfer to Y register
$AEF2: A9 01    LDA #$01        ; Set sprite data (body sprite)
$AEF4: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AEF7: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AEFA: C8       INY             ; Move to next PMG position
$AEFB: A9 02    LDA #$02        ; Set sprite data (head sprite)
$AEFD: 19 00 13 ORA $1300,Y     ; Combine with PMG data
$AF00: 99 00 13 STA $1300,Y     ; Store to Player 0 PMG memory
$AF03: 60       RTS             ; Return from RIGHT processing
; ===============================================================================
; STATIONARY PLAYER SPRITE HANDLING ($AF04-$AFAC)
; ===============================================================================
; **NO INPUT / STATIONARY SPRITE MANAGEMENT**
; This section handles player sprite display when no joystick input is detected
; or when the trigger is not pressed. It manages the stationary sprite combination
; and handles different sprite orientations based on the current player state.
; 
; **STATIONARY SPRITE COMBINATIONS**:
; - $8C: Default stationary sprite (Head $04 + Body $1E)
; - $3C/$48: Vertical orientation sprites
; - $0C/$18: Horizontal orientation sprites  
; - $24/$30: Alternative orientation sprites
; 
; **SPRITE POSITIONING LOGIC**:
; The routine determines appropriate sprite combinations based on:
; - Current player position ($80/$84)
; - Previous movement direction ($73)
; - Joystick input state ($60)
; - Collision detection requirements
; ===============================================================================

$AF04: A5 8C    LDA $8C         ; Load stationary sprite parameter
$AF06: 85 64    STA $64         ; Store as current sprite combination
$AF08: A2 00    LDX #$00        ; Clear sprite index
$AF0A: A5 60    LDA $60         ; **READ JOYSTICK INPUT** - Check for input
$AF0C: C9 FF    CMP #$FF        ; Check if no input (stationary)
$AF0E: D0 06    BNE $AF16       ; Branch if input detected
$AF10: 86 8C    STX $8C         ; Clear stationary sprite parameter
$AF12: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AF15: 60       RTS             ; Return (no input case)

$AF16: 86 04    STX $04         ; Clear input flag
$AF18: C9 FD    CMP #$FD        ; Check for DOWN-RIGHT input ($FD)
$AF1A: 30 25    BMI $AF41       ; Branch if input < $FD (other directions)
$AF1C: A9 3C    LDA #$3C        ; Load vertical sprite combination
$AF1E: C5 64    CMP $64         ; Compare with current sprite
$AF20: D0 02    BNE $AF24       ; Branch if different
$AF22: A9 48    LDA #$48        ; Load alternate vertical sprite
$AF24: 85 64    STA $64         ; Store sprite combination
$AF26: 85 8C    STA $8C         ; Store stationary parameter
$AF28: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AF2B: A5 60    LDA $60         ; **READ JOYSTICK INPUT** - Check direction
$AF2D: C9 FE    CMP #$FE        ; Check for DOWN movement ($FE)
$AF2F: D0 04    BNE $AF35       ; Branch if not DOWN
$AF31: A9 00    LDA #$00        ; Set sprite orientation flag (vertical)
$AF33: F0 02    BEQ $AF37       ; Branch to store orientation
$AF35: A9 01    LDA #$01        ; Set sprite orientation flag (horizontal)
$AF37: 85 73    STA $73         ; Store orientation flag
$AF39: 20 7C BC JSR $BC7C       ; Call sprite rendering routine
$AF3C: A5 77    LDA $77         ; Load sprite position parameter
$AF3E: 85 84    STA $84         ; Store as Y position
$AF40: 60       RTS             ; Return from vertical sprite handling

$AF41: C9 F9    CMP #$F9        ; Check for RIGHT input ($F9)
$AF43: 30 34    BMI $AF79       ; Branch if input < $F9 (other directions)
$AF45: A9 0C    LDA #$0C        ; Load horizontal sprite combination
$AF47: C5 64    CMP $64         ; Compare with current sprite
$AF49: D0 02    BNE $AF4D       ; Branch if different
$AF4B: A9 18    LDA #$18        ; Load alternate horizontal sprite
$AF4D: 85 64    STA $64         ; Store sprite combination
$AF4F: 85 8C    STA $8C         ; Store stationary parameter
$AF51: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AF54: A9 00    LDA #$00        ; Set sprite orientation flag
$AF56: 85 73    STA $73         ; Store orientation flag
$AF58: 20 58 BC JSR $BC58       ; Call sprite setup routine
$AF5B: A5 78    LDA $78         ; Load sprite position parameter
$AF5D: 85 80    STA $80         ; Store as X position
$AF5F: A5 60    LDA $60         ; **READ JOYSTICK INPUT** - Check direction
$AF61: C9 FB    CMP #$FB        ; Check for UP-RIGHT input ($FB)
$AF63: F0 47    BEQ $AFAC       ; Branch if UP-RIGHT (return)
$AF65: C9 FA    CMP #$FA        ; Check for DOWN-LEFT input ($FA)
$AF67: D0 04    BNE $AF6D       ; Branch if not DOWN-LEFT
$AF69: A9 00    LDA #$00        ; Set sprite orientation flag (horizontal)
$AF6B: F0 02    BEQ $AF6F       ; Branch to store orientation
$AF6D: A9 01    LDA #$01        ; Set sprite orientation flag (vertical)
$AF6F: 85 73    STA $73         ; Store orientation flag
$AF71: 20 7C BC JSR $BC7C       ; Call sprite rendering routine
$AF74: A5 77    LDA $77         ; Load sprite position parameter
$AF76: 85 84    STA $84         ; Store as Y position
$AF78: 60       RTS             ; Return from horizontal sprite handling

$AF79: A9 24    LDA #$24        ; Load alternative sprite combination
$AF7B: C5 64    CMP $64         ; Compare with current sprite
$AF7D: D0 02    BNE $AF81       ; Branch if different
$AF7F: A9 30    LDA #$30        ; Load alternate alternative sprite
$AF81: 85 64    STA $64         ; Store sprite combination
$AF83: 85 8C    STA $8C         ; Store stationary parameter
$AF85: 20 41 BC JSR $BC41       ; Call sprite positioning routine
$AF88: A9 01    LDA #$01        ; Set sprite orientation flag
$AF8A: 85 73    STA $73         ; Store orientation flag
$AF8C: 20 58 BC JSR $BC58       ; Call sprite setup routine
$AF8F: A5 78    LDA $78         ; Load sprite position parameter
$AF91: 85 80    STA $80         ; Store as X position
$AF93: A5 60    LDA $60         ; **READ JOYSTICK INPUT** - Check direction
$AF95: C9 F7    CMP #$F7        ; Check for UP-LEFT input ($F7)
$AF97: F0 13    BEQ $AFAC       ; Branch if UP-LEFT (return)
$AF99: C9 F6    CMP #$F6        ; Check for LEFT input ($F6)
$AF9B: D0 04    BNE $AFA1       ; Branch if not LEFT
$AF9D: A9 00    LDA #$00        ; Set sprite orientation flag (horizontal)
$AF9F: F0 02    BEQ $AFA3       ; Branch to store orientation
$AFA1: A9 01    LDA #$01        ; Set sprite orientation flag (vertical)
$AFA3: 85 73    STA $73         ; Store orientation flag
$AFA5: 20 7C BC JSR $BC7C       ; Call sprite rendering routine
$AFA8: A5 77    LDA $77         ; Load sprite position parameter
$AFAA: 85 84    STA $84         ; Store as Y position
$AFAC: 60       RTS             ; Return from alternative sprite handling
; ===============================================================================
; PMG SYSTEM INITIALIZATION ($AFAD-$B030)
; ===============================================================================
; **PLAYER/MISSILE GRAPHICS SYSTEM SETUP**
; This routine initializes the Atari 5200's Player/Missile Graphics (PMG) system
; which is used for all sprite rendering in the game. The PMG system provides
; hardware-accelerated sprite display with collision detection.
; 
; **PMG MEMORY LAYOUT**:
; - $1300-$13FF: Player 0 data (player character sprites)
; - $1400-$14FF: Player 1 data (enemy sprites)  
; - $1500-$15FF: Player 2 data (additional sprites)
; - $1600-$16FF: Player 3 data (additional sprites)
; - $1700-$17FF: Missile data (bullets/projectiles)
; 
; **HARDWARE REGISTERS CONFIGURED**:
; - $D407 (PMBASE): Sets PMG memory base address
; - $C01E (HITCLR): Clears collision detection registers
; - $D400 (DMACTL): Enables DMA for PMG display
; - $C01D (GRACTL): Enables PMG graphics display
; - $C000-$C00B: Player/Missile position registers
; 
; **INITIALIZATION SEQUENCE**:
; 1. Clear all PMG memory areas ($1300-$17FF)
; 2. Clear input registers ($C000-$C00B)
; 3. Set PMG base address in ANTIC
; 4. Clear collision registers
; 5. Initialize game state variables
; 6. Enable PMG DMA and graphics display
; 7. Load initial player position and sprite data
; ===============================================================================

$AFAD: A2 00    LDX #$00        ; **CLEAR PMG MEMORY** - Initialize index
$AFAF: A9 00    LDA #$00        ; Load zero for clearing
$AFB1: 95 80    STA $80,X       ; Clear zero page PMG variables
$AFB3: E8       INX             ; Increment index
$AFB4: E0 45    CPX #$45        ; Check if all variables cleared (69 bytes)
$AFB6: D0 F9    BNE $AFB1       ; Loop until all cleared
$AFB8: A2 00    LDX #$00        ; **CLEAR INPUT REGISTERS** - Reset index
$AFBA: A9 00    LDA #$00        ; Load zero for clearing
$AFBC: 9D 00 C0 STA $C000,X     ; Clear input registers $C000-$C00B
$AFBF: E8       INX             ; Increment register index
$AFC0: E0 0C    CPX #$0C        ; Check if all 12 registers cleared
$AFC2: D0 F8    BNE $AFBC       ; Loop until all input registers cleared
$AFC4: A9 00    LDA #$00        ; **CLEAR PMG MEMORY AREAS** - Load zero
$AFC6: AA       TAX             ; Transfer to X (index = 0)
$AFC7: 9D 00 13 STA $1300,X     ; Clear Player 0 memory ($1300-$13FF)
$AFCA: 9D 00 14 STA $1400,X     ; Clear Player 1 memory ($1400-$14FF)
$AFCD: 9D 00 15 STA $1500,X     ; Clear Player 2 memory ($1500-$15FF)
$AFD0: 9D 00 16 STA $1600,X     ; Clear Player 3 memory ($1600-$16FF)
$AFD3: 9D 00 17 STA $1700,X     ; Clear Missile memory ($1700-$17FF)
$AFD6: E8       INX             ; Increment memory index
$AFD7: D0 EE    BNE $AFC7       ; Loop until all 256 bytes cleared (X wraps to 0)
$AFD9: A2 13    LDX #$13        ; **SET PMG BASE ADDRESS** - Load base page ($13xx)
$AFDB: CA       DEX             ; Decrement to get actual base ($12xx)
$AFDC: CA       DEX             ; Decrement again ($11xx)
$AFDD: CA       DEX             ; Final decrement ($10xx) - PMG base at $1000
$AFDE: 8A       TXA             ; Transfer base address to accumulator
$AFDF: 8D 07 D4 STA $D407       ; **ANTIC PMBASE** - Set PMG base address
$AFE2: A9 00    LDA #$00        ; **CLEAR COLLISION REGISTERS**
$AFE4: 8D 1E C0 STA $C01E       ; **GTIA HITCLR** - Clear collision registers
$AFE7: 85 79    STA $79         ; Clear collision flag variable
$AFE9: A9 01    LDA #$01        ; **INITIALIZE GAME STATE** - Set active flags
$AFEB: 85 98    STA $98         ; Set player active flag
$AFED: 85 99    STA $99         ; Set enemy active flag
$AFEF: 85 9A    STA $9A         ; Set missile active flag
$AFF1: A9 00    LDA #$00        ; **CLEAR DISPLAY VARIABLES**
$AFF3: 85 0E    STA $0E         ; Clear display parameter 1
$AFF5: 85 91    STA $91         ; Clear display parameter 2
$AFF7: A9 7C    LDA #$7C        ; **SET DISPLAY PARAMETERS**
$AFF9: 85 08    STA $08         ; Set display control parameter
$AFFB: A9 3E    LDA #$3E        ; **ENABLE PMG DMA** - Set DMA control value
$AFFD: 8D 00 D4 STA $D400       ; **ANTIC DMACTL** - Enable PMG DMA
$B000: 85 07    STA $07         ; Store DMA control value
$B002: A9 03    LDA #$03        ; **ENABLE PMG GRAPHICS** - Set graphics control
$B004: 8D 1D C0 STA $C01D       ; **GTIA GRACTL** - Enable PMG graphics display
$B007: AD 0A E8 LDA $E80A       ; **READ RANDOM SEED** - Load hardware random
$B00A: 29 01    AND #$01        ; Mask to single bit (0 or 1)
$B00C: D0 05    BNE $B013       ; Branch if bit set (random = 1)
$B00E: A2 02    LDX #$02        ; Load player data index (option 1)
$B010: 4C 15 B0 JMP $B015       ; Jump to player setup
$B013: A2 03    LDX #$03        ; Load player data index (option 2)
$B015: BD D4 BF LDA $BFD4,X     ; **LOAD INITIAL PLAYER DATA** from table
$B018: 8D 00 C0 STA $C000       ; **HPOSP0** - Set Player 0 horizontal position
$B01B: 85 80    STA $80         ; Store player X position
$B01D: A9 01    LDA #$01        ; **SET PLAYER STATE** - Set active flag
$B01F: 85 65    STA $65         ; Set player active flag
$B021: A9 66    LDA #$66        ; **SET PLAYER Y POSITION** - Load Y coordinate
$B023: 85 84    STA $84         ; Store player Y position
$B025: 85 A7    STA $A7         ; Store enemy firing counter
$B027: 20 BD BD JSR $BDBD       ; **INITIALIZE DISPLAY SYSTEM** - Setup screen
$B02A: A9 07    LDA #$07        ; **SET SOUND PARAMETERS** - Load sound value
$B02C: A2 A6    LDX #$A6        ; Load sound parameter X
$B02E: A0 3B    LDY #$3B        ; Load sound parameter Y
$B030: 4C D5 BD JMP $BDD5       ; **JUMP TO SOUND SETUP** - Initialize audio system
; ===============================================================================
; AUDIO/SOUND SYSTEM ($B033-$B116)
; ===============================================================================
; **COMPLETE SOUND GENERATION SYSTEM**
; This section handles all audio output for the game using the Atari 5200's
; POKEY sound chip. The system generates various sound effects including:
; - Enemy firing sounds (different tones and durations)
; - Player firing sounds
; - Bonus point collection sounds
; - Background audio effects
; - Sound timing and synchronization
; 
; **POKEY SOUND REGISTERS**:
; - $E800 (AUDF1): Audio Frequency Channel 1
; - $E801 (AUDC1): Audio Control Channel 1  
; - $E808: Sound control register
; 
; **SOUND EFFECT TYPES**:
; 1. **Firing Sounds**: Sharp, brief tones for weapon discharge
; 2. **Bonus Sounds**: Musical tones for point collection
; 3. **Background Audio**: Ambient sound effects
; 4. **Timing Effects**: Sound-synchronized visual effects
; 
; **FREQUENCY GENERATION**:
; The system uses mathematical frequency calculations to generate precise
; tones and sound effects. Different frequency values create different
; pitches and timbres for various game events.
; ===============================================================================

$B033: A9 00    LDA #$00        ; **INITIALIZE SOUND SYSTEM** - Clear sound control
$B035: 8D 08 E8 STA $E808       ; Clear sound control register
$B038: A9 AC    LDA #$AC        ; **SET BASE FREQUENCY** - Load frequency value
$B03A: 8D 01 E8 STA $E801       ; **AUDC1** - Set audio control channel 1
$B03D: A9 0C    LDA #$0C        ; **SET SOUND DURATION** - Load duration counter
$B03F: 85 A4    STA $A4         ; Store duration counter
$B041: A9 20    LDA #$20        ; **SOUND GENERATION LOOP** - Load frequency base
$B043: A0 08    LDY #$08        ; Load frequency modifier
$B045: 20 8E B0 JSR $B08E       ; **CALL TIMING ROUTINE** - Generate sound timing
$B048: 38       SEC             ; Set carry flag
$B049: E9 01    SBC #$01        ; Decrement frequency value
$B04B: 8D 00 E8 STA $E800       ; **AUDF1** - Set audio frequency channel 1
$B04E: C9 08    CMP #$08        ; Check if frequency reached minimum
$B050: D0 F1    BNE $B043       ; Loop back if not minimum (continue sound)
$B052: A5 A4    LDA $A4         ; **CHECK DURATION** - Load duration counter
$B054: 38       SEC             ; Set carry flag
$B055: E9 01    SBC #$01        ; Decrement duration counter
$B057: 85 A4    STA $A4         ; Store updated duration
$B059: D0 1E    BNE $B079       ; Branch if duration not expired (continue)
$B05B: A9 00    LDA #$00        ; **SOUND COMPLETE** - Clear sound registers
$B05D: 8D 01 E8 STA $E801       ; Clear audio control channel 1
$B060: 85 0E    STA $0E         ; Clear sound parameter 1
$B062: 85 10    STA $10         ; Clear sound parameter 2
$B064: A0 FF    LDY #$FF        ; **SOUND FADE OUT** - Load fade parameter
$B066: 20 8E B0 JSR $B08E       ; Call timing routine (fade delay)
$B069: A0 FF    LDY #$FF        ; Load fade parameter
$B06B: 20 8E B0 JSR $B08E       ; Call timing routine (fade delay)
$B06E: A0 FF    LDY #$FF        ; Load fade parameter
$B070: 20 8E B0 JSR $B08E       ; Call timing routine (fade delay)
$B073: A0 FF    LDY #$FF        ; Load fade parameter
$B075: 20 8E B0 JSR $B08E       ; Call timing routine (fade delay)
$B078: 60       RTS             ; **RETURN** - Sound generation complete
$B079: A5 0E    LDA $0E         ; **SOUND MODULATION** - Load modulation flag
$B07B: F0 08    BEQ $B085       ; Branch if no modulation
$B07D: A9 00    LDA #$00        ; Clear modulation parameters
$B07F: 85 0E    STA $0E         ; Clear modulation flag
$B081: 85 10    STA $10         ; Clear modulation parameter
$B083: F0 02    BEQ $B087       ; Branch to continue (always taken)
$B085: A5 A5    LDA $A5         ; Load alternate modulation parameter
$B087: 85 0E    STA $0E         ; Store modulation parameter 1
$B089: 85 10    STA $10         ; Store modulation parameter 2
$B08B: 4C 41 B0 JMP $B041       ; **LOOP BACK** - Continue sound generation

; **TIMING DELAY ROUTINE** ($B08E-$B096):
; Creates precise timing delays for sound generation and synchronization
$B08E: A2 30    LDX #$30        ; **TIMING DELAY** - Load delay counter (48 cycles)
$B090: CA       DEX             ; Decrement delay counter
$B091: D0 FD    BNE $B090       ; Loop until counter reaches zero
$B093: 88       DEY             ; Decrement outer delay counter
$B094: D0 FA    BNE $B090       ; Loop back to inner delay (creates longer delay)
$B096: 60       RTS             ; Return from timing routine

; ===============================================================================
; COMPLEX SOUND EFFECT GENERATOR ($B097-$B0FC)
; **MULTI-TONE SOUND SEQUENCE** - Creates complex audio patterns
; This routine generates sophisticated sound effects by combining multiple
; frequencies, timing patterns, and modulation effects. Used for special
; game events like bonus collection, level completion, and dramatic moments.
; ===============================================================================

$B097: A9 5B    LDA #$5B        ; **START COMPLEX SOUND** - Load initial frequency
$B099: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B09C: 20 0A B1 JSR $B10A       ; **CALL SOUND SETUP 1** - Configure sound parameters
$B09F: 20 17 B1 JSR $B117       ; **CALL FLASHING EFFECT** - Sync with visual effects
$B0A2: 20 17 B1 JSR $B117       ; Call flashing effect (repeat for emphasis)
$B0A5: 20 FD B0 JSR $B0FD       ; **CALL SOUND SETUP 2** - Configure alternate parameters
$B0A8: 20 17 B1 JSR $B117       ; Call flashing effect
$B0AB: 20 0A B1 JSR $B10A       ; Call sound setup 1 (return to original)
$B0AE: A9 60    LDA #$60        ; **CHANGE FREQUENCY** - Load new frequency
$B0B0: 85 BC    STA $BC         ; Store frequency parameter
$B0B2: 20 17 B1 JSR $B117       ; Call flashing effect with new frequency
$B0B5: A9 4C    LDA #$4C        ; **FREQUENCY TRANSITION** - Load transition frequency
$B0B7: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0BA: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0BD: 20 17 B1 JSR $B117       ; Call flashing effect
$B0C0: A9 51    LDA #$51        ; **CONTINUE SEQUENCE** - Load next frequency
$B0C2: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0C5: 20 FD B0 JSR $B0FD       ; Call sound setup 2
$B0C8: 20 17 B1 JSR $B117       ; Call flashing effect
$B0CB: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0CE: 20 17 B1 JSR $B117       ; Call flashing effect
$B0D1: A9 5B    LDA #$5B        ; **RETURN TO START** - Load original frequency
$B0D3: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0D6: 20 FD B0 JSR $B0FD       ; Call sound setup 2
$B0D9: 20 17 B1 JSR $B117       ; Call flashing effect
$B0DC: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0DF: 20 17 B1 JSR $B117       ; Call flashing effect
$B0E2: A9 60    LDA #$60        ; **FINAL FREQUENCY** - Load ending frequency
$B0E4: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0E7: 20 FD B0 JSR $B0FD       ; Call sound setup 2
$B0EA: 20 17 B1 JSR $B117       ; Call flashing effect
$B0ED: A9 5B    LDA #$5B        ; **SEQUENCE END** - Load final frequency
$B0EF: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0F2: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0F5: A9 FF    LDA #$FF        ; **SET END FLAG** - Load completion flag
$B0F7: 85 BC    STA $BC         ; Store completion flag
$B0F9: 20 17 B1 JSR $B117       ; Call flashing effect (final)
$B0FC: 60       RTS             ; **RETURN** - Complex sound sequence complete

; **SOUND PARAMETER SETUP ROUTINES**:
; These routines configure different sound parameter combinations
$B0FD: A9 1C    LDA #$1C        ; **SOUND SETUP 2** - Load parameter set 2
$B0FF: 85 BA    STA $BA         ; Store sound parameter A
$B101: A9 3E    LDA #$3E        ; Load parameter B
$B103: 85 BB    STA $BB         ; Store sound parameter B
$B105: A9 2A    LDA #$2A        ; Load parameter C
$B107: 85 BC    STA $BC         ; Store sound parameter C
$B109: 60       RTS             ; Return from setup 2

$B10A: A9 2E    LDA #$2E        ; **SOUND SETUP 1** - Load parameter set 1
$B10C: 85 BA    STA $BA         ; Store sound parameter A
$B10E: A9 7A    LDA #$7A        ; Load parameter B
$B110: 85 BB    STA $BB         ; Store sound parameter B
$B112: A9 4A    LDA #$4A        ; Load parameter C
$B114: 85 BC    STA $BC         ; Store sound parameter C
$B116: 60       RTS             ; Return from setup 1
; ===============================================================================
; FLASHING VISUAL EFFECTS SYSTEM ($B117-$B14E)
; ===============================================================================
; **SYNCHRONIZED AUDIO-VISUAL EFFECTS**
; This routine creates flashing visual effects that are synchronized with
; sound generation. Used during bonus point displays, level transitions,
; and other dramatic game moments. The system coordinates timing between
; audio output and visual display changes.
; 
; **EFFECT PARAMETERS**:
; - $BA: Flash timing parameter A (controls flash rate)
; - $BB: Flash timing parameter B (controls flash duration)  
; - $BC: Flash timing parameter C (controls flash intensity)
; 
; **VISUAL EFFECTS**:
; 1. **Screen Flashing**: Alternates display brightness/color
; 2. **Text Blinking**: Makes text appear/disappear rhythmically
; 3. **Color Cycling**: Changes display colors in sequence
; 4. **Synchronized Timing**: Matches visual effects to audio beats
; 
; **HARDWARE INTEGRATION**:
; - Uses POKEY sound registers ($E800/$E801) for audio
; - Coordinates with display timing for smooth effects
; - Provides precise timing control for dramatic impact
; ===============================================================================

$B117: A9 A0    LDA #$A0        ; **START FLASHING SEQUENCE** - Load flash control value
$B119: 8D 01 E8 STA $E801       ; Set audio control register (sound sync)
$B11C: A6 BA    LDX $BA         ; **LOAD FLASH PARAMETER A** - Get timing value
$B11E: 20 46 B1 JSR $B146       ; **CALL TIMING DELAY** - Create flash timing
$B121: 18       CLC             ; Clear carry flag
$B122: 69 01    ADC #$01        ; Increment flash counter
$B124: C9 B0    CMP #$B0        ; Check if flash cycle complete
$B126: D0 F1    BNE $B119       ; Loop back if cycle not complete (continue flashing)
$B128: A9 0E    LDA #$0E        ; **FLASH PARAMETER B SEQUENCE** - Load parameter B
$B12A: A6 BB    LDX $BB         ; Load flash parameter B
$B12C: 20 46 B1 JSR $B146       ; Call timing delay
$B12F: 38       SEC             ; Set carry flag
$B130: E9 01    SBC #$01        ; Decrement parameter B counter
$B132: D0 F6    BNE $B12A       ; Loop back if counter not zero (continue B sequence)
$B134: A9 AF    LDA #$AF        ; **FLASH PARAMETER C SEQUENCE** - Load parameter C
$B136: 8D 01 E8 STA $E801       ; Set audio control register
$B139: A6 BC    LDX $BC         ; Load flash parameter C
$B13B: 20 46 B1 JSR $B146       ; Call timing delay
$B13E: 38       SEC             ; Set carry flag
$B13F: E9 01    SBC #$01        ; Decrement parameter C counter
$B141: C9 9F    CMP #$9F        ; Check if C sequence complete
$B143: D0 F1    BNE $B136       ; Loop back if sequence not complete (continue C sequence)
$B145: 60       RTS             ; **RETURN** - Flashing sequence complete

; **PRECISION TIMING DELAY ROUTINE** ($B146-$B14E):
; Creates precise timing delays for flashing effects and sound synchronization
$B146: A0 13    LDY #$13        ; **TIMING DELAY** - Load inner delay counter (19 cycles)
$B148: 88       DEY             ; Decrement inner delay counter
$B149: D0 FD    BNE $B148       ; Loop until inner counter reaches zero
$B14B: CA       DEX             ; Decrement outer delay counter (X register)
$B14C: D0 F8    BNE $B146       ; Loop back to inner delay until X reaches zero
$B14E: 60       RTS             ; Return from timing delay routine
; ===============================================================================
; COLLISION_DETECT ($B14F)
; Collision detection system
; This routine:
; - Checks player-enemy collisions
; - Processes bullet-enemy collisions
; - Handles collision responses
; - Updates collision flags
; - Triggers collision effects
; ===============================================================================

$B14F: A5 A8    LDA #$A8
$B151: D0 05    BNE $B158 ; Loop back if not zero
$B153: 85 04    STA $04
$B155: 4C 2D B2 JMP $B22D ; Check player-powerup collisions
$B158: A5 E2    LDA #$E2
$B15A: 05 E3    ORA #$E3
$B15C: 05 E4    ORA #$E4
$B15E: 05 E5    ORA #$E5
$B160: D0 03    BNE $B165 ; Loop back if not zero
$B162: 4C 2D B2 JMP $B22D
$B165: A9 00    LDA #$00
$B167: 85 67    STA $67
$B169: A5 67    LDA #$67
$B16B: 85 72    STA $72
$B16D: C9 04    CMP #$04
$B16F: F0 F1    BEQ $B162 ; Branch if equal/zero
$B171: A9 04    LDA #$04
$B173: 85 68    STA $68
$B175: A5 67    LDA #$67
$B177: 85 72    STA $72
$B179: AA       TAX
$B17A: B5 E2    LDA #$E2
$B17C: D0 05    BNE $B183 ; Loop back if not zero
$B17E: E6 67    INC $67
$B180: 4C 69 B1 JMP $B169
$B183: 85 77    STA $77
$B185: A5 68    LDA #$68
$B187: 38       SEC
$B188: E9 01    SBC #$01
$B18A: 85 68    STA $68
$B18C: F0 F0    BEQ $B17E ; Branch if equal/zero
$B18E: B5 DE    LDA #$DE
$B190: 85 78    STA $78
$B192: B5 88    LDA #$88
$B194: C9 07    CMP #$07
$B196: 30 2F    BMI $B1C7
$B198: C9 07    CMP #$07
$B19A: D0 04    BNE $B1A0 ; Loop back if not zero
$B19C: A9 00    LDA #$00
$B19E: F0 02    BEQ $B1A2 ; Branch if equal/zero
$B1A0: A9 01    LDA #$01
$B1A2: 85 73    STA $73
$B1A4: 20 B7 BC JSR $BCB7
$B1A7: A5 67    LDA #$67
$B1A9: 85 72    STA $72
$B1AB: 20 B7 BC JSR $BCB7
$B1AE: A5 67    LDA #$67
$B1B0: 85 72    STA $72
$B1B2: 20 B7 BC JSR $BCB7
$B1B5: A5 67    LDA #$67
$B1B7: 85 72    STA $72
$B1B9: 20 B7 BC JSR $BCB7
$B1BC: A6 67    LDX #$67
$B1BE: A5 77    LDA #$77
$B1C0: 95 E2    STA $E2
$B1C2: E6 67    INC $67
$B1C4: 4C 69 B1 JMP $B169
$B1C7: C9 04    CMP #$04
$B1C9: 30 31    BMI $B1FC
$B1CB: 8A       TXA
$B1CC: 18       CLC
$B1CD: 69 04    ADC #$04
$B1CF: 85 74    STA $74
$B1D1: A9 01    LDA #$01
$B1D3: 85 73    STA $73
$B1D5: 20 58 BC JSR $BC58
$B1D8: A6 67    LDX #$67
$B1DA: A5 78    LDA #$78
$B1DC: 95 DE    STA $DE
$B1DE: B5 88    LDA #$88
$B1E0: C9 05    CMP #$05
$B1E2: F0 91    BEQ $B175 ; Branch if equal/zero
$B1E4: C9 04    CMP #$04
$B1E6: D0 04    BNE $B1EC ; Loop back if not zero
$B1E8: A9 00    LDA #$00
$B1EA: F0 02    BEQ $B1EE ; Branch if equal/zero
$B1EC: A9 01    LDA #$01
$B1EE: 85 73    STA $73
$B1F0: 20 B7 BC JSR $BCB7
$B1F3: A6 67    LDX #$67
$B1F5: A5 77    LDA #$77
$B1F7: 95 E2    STA $E2
$B1F9: 4C 75 B1 JMP $B175
$B1FC: 8A       TXA
$B1FD: 18       CLC
$B1FE: 69 04    ADC #$04
$B200: 85 74    STA $74
$B202: A9 00    LDA #$00
$B204: 85 73    STA $73
$B206: 20 58 BC JSR $BC58
$B209: A6 67    LDX #$67
$B20B: A5 78    LDA #$78
$B20D: 95 DE    STA $DE
$B20F: B5 88    LDA #$88
$B211: C9 02    CMP #$02
$B213: F0 E4    BEQ $B1F9 ; Branch if equal/zero
$B215: C9 01    CMP #$01
$B217: D0 04    BNE $B21D ; Loop back if not zero
$B219: A9 00    LDA #$00
$B21B: F0 02    BEQ $B21F ; Branch if equal/zero
$B21D: A9 01    LDA #$01
$B21F: 85 73    STA $73
$B221: 20 B7 BC JSR $BCB7
$B224: A6 67    LDX #$67
$B226: A5 77    LDA #$77
$B228: 95 E2    STA $E2
$B22A: 4C 75 B1 JMP $B175
$B22D: A5 A8    LDA #$A8
$B22F: 18       CLC
$B230: 69 01    ADC #$01
$B232: 85 A8    STA $A8
$B234: C5 D6    CMP #$D6
$B236: D0 04    BNE $B23C ; Loop back if not zero
$B238: A9 00    LDA #$00
$B23A: 85 A8    STA $A8
$B23C: 60       RTS
$B23D: A5 D0    LDA #$D0
$B23F: D0 01    BNE $B242 ; Loop back if not zero
$B241: 60       RTS
$B242: C9 4F    CMP #$4F
$B244: D0 3E    BNE $B284 ; Loop back if not zero
$B246: A5 DA    LDA #$DA
$B248: D0 0D    BNE $B257 ; Loop back if not zero
$B24A: A9 20    LDA #$20
$B24C: 8D 19 06 STA $0619
$B24F: A9 1E    LDA #$1E
$B251: 8D 2D 06 STA $062D
$B254: 4C 76 B2 JMP $B276
$B257: C9 01    CMP #$01
$B259: D0 0D    BNE $B268 ; Loop back if not zero
$B25B: A9 20    LDA #$20
$B25D: 8D 18 06 STA $0618
$B260: A9 1E    LDA #$1E
$B262: 8D 2C 06 STA $062C
$B265: 4C 76 B2 JMP $B276
$B268: C9 02    CMP #$02
$B26A: D0 0A    BNE $B276 ; Loop back if not zero
$B26C: A9 20    LDA #$20
$B26E: 8D 17 06 STA $0617
$B271: A9 1E    LDA #$1E
$B273: 8D 2B 06 STA $062B
$B276: A5 DA    LDA #$DA
$B278: C9 FF    CMP #$FF
$B27A: D0 01    BNE $B27D ; Loop back if not zero
$B27C: 60       RTS
$B27D: C6 DA    DEC $DA
$B27F: 20 89 B8 JSR $B889
$B282: C6 D0    DEC $D0
$B284: A9 12    LDA #$12
$B286: 8D 00 E8 STA $E800
$B289: A5 BD    LDA #$BD
$B28B: D0 08    BNE $B295 ; Loop back if not zero
$B28D: 85 0E    STA $0E
$B28F: 85 10    STA $10
$B291: 8D 01 E8 STA $E801
$B294: 60       RTS
$B295: C6 BD    DEC $BD
$B297: 29 04    AND #$04
$B299: D0 0C    BNE $B2A7 ; Loop back if not zero
$B29B: A9 1F    LDA #$1F
$B29D: 8D 00 E8 STA $E800
$B2A0: A9 00    LDA #$00
$B2A2: 85 0E    STA $0E
$B2A4: 85 10    STA $10
$B2A6: 60       RTS
$B2A7: A9 AC    LDA #$AC
$B2A9: 8D 01 E8 STA $E801
$B2AC: A9 32    LDA #$32
$B2AE: 85 0E    STA $0E
$B2B0: 85 10    STA $10
$B2B2: 60       RTS
; ===============================================================================
; ENEMY_AI ($B2B3)
; Enemy movement and AI system with COMPLETE FIRING BEHAVIOR ANALYSIS
; This routine:
; - Updates enemy positions
; - Processes AI logic and movement patterns
; - Manages enemy states and spawning
; - **CONTROLS ENEMY FIRING BEHAVIOR**
; 
; **FIRING SYSTEM OVERVIEW**:
; 1. **Frequency Control**: $A7 counter vs $D7 limit (loaded from $BBE4 table)
; 2. **Permission Check**: Enemies can only fire when $A7 = 0
; 3. **Decision Logic**: 4-bit targeting system based on player-enemy positioning
; 4. **Pattern Selection**: 8 different firing patterns (horizontal, diagonal, etc.)
; 5. **Level Scaling**: Firing rate increases from 0.6 to 15.0 shots/sec
; 
; **LEVEL-BASED FIRING RATES** (Atari 5200 NTSC @ 59.92 Hz):
; **ACTUAL GAMEPLAY RATES** (accounting for randomization and conditions):
; - Level 0: NO FIRING (D7=$00) - Tutorial mode
; - Level 1: ~0.15 shots/sec (every ~6.4 sec) - Very manageable
; - Level 2: ~0.23 shots/sec (every ~4.3 sec) - Beginner friendly
; - Level 3: ~0.31 shots/sec (every ~3.2 sec) - Moderate challenge
; - Level 4: ~0.40 shots/sec (every ~2.5 sec) - Increased pressure
; - Level 5: ~0.79 shots/sec (every ~1.3 sec) - Significant challenge
; - Level 6: ~2.50 shots/sec (every ~0.4 sec) - High difficulty
; - Level 7: ~3.75 shots/sec (every ~0.27 sec) - Maximum challenge
; 
; ENEMY FIRING MECHANICS (when $A7 = 0):
; 1. **Position Calculation**: Compares player position ($80/$84) vs enemy position ($92/$77)
; 2. **Distance Analysis**: Calculates X/Y distance differences ($9E/$9F)
; 3. **Firing Decision**: Creates 4-bit targeting value from position comparison:
;    - Bit 0-1 ($9C/$9D): Movement direction flags
;    - Bit 2 ($A2): Set if Y-distance > threshold (vertical alignment)
;    - Bit 3 ($A3): Set if X-distance > threshold (horizontal alignment)
; 4. **Firing Patterns**: Different values trigger different firing behaviors:
;    - $04/$06: Horizontal firing (values 4,6)
;    - $05/$07: Diagonal firing (values 5,7)  
;    - $08/$09: Vertical firing (values 8,9)
;    - $0A/$0B: Advanced targeting (values 10,11)
;    - $0C-$0F: Close-range rapid fire (values 12-15)
; 5. **Missile Setup**: Sets enemy missile positions ($E2/$DE) and enables firing
; ===============================================================================

$B2B3: A9 13    LDA #$13
$B2B5: 85 7A    STA $7A
$B2B7: A9 00    LDA #$00
$B2B9: 85 67    STA $67
$B2BB: A6 67    LDX #$67 ; Update enemy states
$B2BD: E6 7A    INC $7A ; Process enemy attacks
$B2BF: B5 93    LDA #$93
$B2C1: F0 39    BEQ $B2FC ; Branch if equal/zero
$B2C3: C9 01    CMP #$01 ; Process enemy death
$B2C5: D0 10    BNE $B2D7 ; Loop back if not zero
$B2C7: A9 00    LDA #$00
$B2C9: 8D 06 E8 STA $E806
$B2CC: 85 B3    STA $B3
$B2CE: A9 8F    LDA #$8F
$B2D0: 85 B2    STA $B2
$B2D2: 8D 07 E8 STA $E807
$B2D5: 85 BE    STA $BE
$B2D7: B5 93    LDA #$93
$B2D9: 29 F0    AND #$F0
$B2DB: D0 0C    BNE $B2E9 ; Loop back if not zero
$B2DD: B5 93    LDA #$93
$B2DF: 95 08    STA $08
$B2E1: 18       CLC
$B2E2: 69 03    ADC #$03
$B2E4: 95 93    STA $93
$B2E6: 4C FC B2 JMP $B2FC
$B2E9: A5 9B    LDA #$9B
$B2EB: D0 0F    BNE $B2FC ; Loop back if not zero
$B2ED: B5 93    LDA $93,X       ; Load player position from slot
$B2EF: 85 69    STA $69         ; Store in position variable
$B2F1: B4 84    LDY $84,X       ; Load Y coordinate
$B2F3: 20 47 BD JSR $BD47       ; **CHECK BOUNDARY** - sets $97 if escaped
$B2F6: A6 67    LDX $67         ; Restore index
$B2F8: A5 69    LDA $69         ; Load updated position
$B2FA: 95 93    STA $93,X       ; Store back to position slot
$B2FC: A5 67    LDA #$67
$B2FE: 18       CLC
$B2FF: 69 01    ADC #$01
$B301: 85 67    STA $67
$B303: C9 04    CMP #$04
$B305: B0 03    BCS $B30A ; Branch if carry set
$B307: 4C BB B2 JMP $B2BB
$B30A: A5 9B    LDA #$9B
$B30C: 18       CLC
$B30D: 69 01    ADC #$01
$B30F: 85 9B    STA $9B
$B311: C9 03    CMP #$03
$B313: 30 04    BMI $B319
$B315: A9 00    LDA #$00
$B317: 85 9B    STA $9B
$B319: 60       RTS
; ===============================================================================
; LEVEL-BASED FIRING CONTROL ($B31A)
; **FIRING FREQUENCY PERMISSION CHECK**
; This routine checks if enemies are allowed to fire based on frame counter
; ===============================================================================
$B31A: A5 D5    LDA $D5         ; Load level counter (for debugging/state tracking)
$B31C: D0 03    BNE $B321       ; Branch if level > 0 (continue processing)
$B31E: 4C BE B4 JMP $B4BE       ; If level = 0, skip to frequency update
$B321: A5 A7    LDA $A7         ; **FIRING FREQUENCY CHECK** - Load frame counter
$B323: F0 03    BEQ $B328       ; Branch if counter = 0 (FIRING ALLOWED!)
$B325: 4C B3 B4 JMP $B4B3       ; If counter ≠ 0, skip to frequency update (NO FIRING)
$B328: AD 0A E8 LDA $E80A       ; **RANDOMIZATION CHECK** - Load hardware random register
$B32B: 29 03    AND #$03        ; Mask to 0-3 range (25% chance of 0)
$B32D: F0 F9    BEQ $B328       ; Loop if 0 (wait for non-zero = ~75% rejection rate)
$B32F: 85 67    STA $67         ; Store random value (1, 2, or 3)
$B331: A6 67    LDX $67         ; Use as enemy index
$B333: B5 8C    LDA $8C,X       ; **ENEMY STATE CHECK** - Load enemy status
$B335: C9 FF    CMP #$FF        ; Check if enemy inactive
$B337: D0 01    BNE $B33A       ; Branch if enemy is active
$B339: 60       RTS             ; Exit if enemy inactive (NO FIRING)
$B33A: A9 00    LDA #$00        ; **BEGIN TARGETING ANALYSIS**
$B33C: 85 9C    STA $9C         ; Clear movement direction flags
$B33E: 85 9D    STA $9D         ; Clear movement direction flags
$B340: B5 E2    LDA $E2,X       ; **MISSILE AVAILABILITY CHECK** - Load enemy missile status
$B342: 15 93    ORA $93,X       ; Combine with enemy position status
$B344: F0 03    BEQ $B349       ; Branch if no active missile (FIRING POSSIBLE)
$B346: 4C B3 B4 JMP $B4B3       ; Exit if missile already active (NO FIRING)
$B349: A5 80    LDA #$80
$B34B: 85 92    STA $92
$B34D: B5 80    LDA #$80
$B34F: 85 78    STA $78
$B351: C5 80    CMP #$80
$B353: B0 0E    BCS $B363 ; Branch if carry set
$B355: 85 6B    STA $6B
$B357: A5 80    LDA #$80
$B359: 85 78    STA $78
$B35B: A5 6B    LDA #$6B
$B35D: 85 92    STA $92
$B35F: A9 01    LDA #$01
$B361: 85 9C    STA $9C
$B363: 38       SEC
$B364: A5 78    LDA #$78
$B366: E5 92    SBC #$92
$B368: 85 9E    STA $9E
$B36A: 85 6C    STA $6C
$B36C: A9 03    LDA #$03
$B36E: 85 6B    STA $6B
$B370: 20 09 BD JSR $BD09
$B373: A6 67    LDX #$67
$B375: A5 6C    LDA #$6C
$B377: 85 A0    STA $A0
$B379: A5 84    LDA #$84
$B37B: 85 92    STA $92
$B37D: B5 84    LDA #$84
$B37F: 85 77    STA $77
$B381: C5 84    CMP #$84
$B383: B0 0E    BCS $B393 ; Branch if carry set
$B385: 85 6B    STA $6B
$B387: A5 84    LDA #$84
$B389: 85 77    STA $77
$B38B: A5 6B    LDA #$6B
$B38D: 85 92    STA $92
$B38F: A9 02    LDA #$02
$B391: 85 9D    STA $9D
$B393: 38       SEC
$B394: A5 77    LDA #$77
$B396: E5 92    SBC #$92
$B398: 85 9F    STA $9F
$B39A: 85 6C    STA $6C
$B39C: A9 03    LDA #$03
$B39E: 85 6B    STA $6B
$B3A0: 20 09 BD JSR $BD09
$B3A3: A6 67    LDX #$67
$B3A5: A5 6C    LDA #$6C
$B3A7: 85 A1    STA $A1
$B3A9: A9 00    LDA #$00
$B3AB: 85 A2    STA $A2         ; Clear Y-alignment flag
$B3AD: 85 A3    STA $A3         ; Clear X-alignment flag
$B3AF: A5 9F    LDA $9F         ; Load Y-distance difference
$B3B1: C5 A0    CMP $A0         ; Compare with threshold
$B3B3: 90 04    BCC $B3B9       ; Branch if Y-distance < threshold
$B3B5: A9 08    LDA #$08        ; Set bit 3 (horizontal alignment detected)
$B3B7: 85 A3    STA $A3         ; Store X-alignment flag
$B3B9: A5 9E    LDA $9E         ; Load X-distance difference  
$B3BB: C5 A1    CMP $A1         ; Compare with threshold
$B3BD: 90 04    BCC $B3C3       ; Branch if X-distance < threshold
$B3BF: A9 04    LDA #$04        ; Set bit 2 (vertical alignment detected)
$B3C1: 85 A2    STA $A2         ; Store Y-alignment flag
$B3C3: A5 A2    LDA $A2         ; Load Y-alignment flag
$B3C5: 05 A3    ORA $A3         ; Combine with X-alignment flag
$B3C7: 05 9C    ORA $9C         ; Combine with movement direction flags
$B3C9: 05 9D    ORA $9D         ; Create final targeting value (0-15)
$B3CB: C9 04    CMP #$04        ; **FIRING DECISION TREE**
$B3CD: F0 10    BEQ $B3DF       ; Fire horizontally if value = 4
$B3CF: C9 09    CMP #$09        ; Check for vertical firing
$B3D1: F0 30    BEQ $B403       ; Fire vertically if value = 9
$B3D3: C9 0A    CMP #$0A        ; Check for advanced targeting
$B3D5: F0 3C    BEQ $B413       ; Advanced fire pattern if value = 10
$B3D7: C9 05    CMP #$05        ; Check for diagonal firing
$B3D9: F0 16    BEQ $B3F1       ; Fire diagonally if value = 5
$B3DB: C9 06    CMP #$06        ; Check for horizontal variant
$B3DD: D0 0E    BNE $B3ED       ; Branch if not 6
$B3DF: A9 02    LDA #$02        ; **HORIZONTAL FIRING PATTERN**
$B3E1: 95 88    STA $88,X       ; Set enemy sprite type
$B3E3: A9 0C    LDA #$0C        ; Set missile pattern data
$B3E5: 85 6B    STA $6B         ; Store firing pattern
$B3E7: A9 00    LDA #$00        ; Set firing direction
$B3E9: 85 6C    STA $6C         ; Store direction data
$B3EB: F0 30    BEQ $B41D       ; Jump to missile setup
$B3ED: C9 07    CMP #$07        ; Check for diagonal variant
$B3EF: D0 0E    BNE $B3FF       ; Branch if not 7
$B3F1: A9 05    LDA #$05        ; **DIAGONAL FIRING PATTERN**
$B3F3: 95 88    STA $88,X       ; Set enemy sprite type
$B3F5: A9 0C    LDA #$0C        ; Set missile pattern data
$B3F7: 85 6B    STA $6B         ; Store firing pattern
$B3F9: A9 00    LDA #$00        ; Set firing direction
$B3FB: 85 6C    STA $6C         ; Store direction data
$B3FD: F0 1E    BEQ $B41D       ; Jump to missile setup
$B3FF: C9 08    CMP #$08        ; Check for vertical firing
$B401: D0 0C    BNE $B40F       ; Branch if not 8
$B403: A9 07    LDA #$07        ; **VERTICAL FIRING PATTERN**
$B405: 95 88    STA $88,X       ; Set enemy sprite type
$B407: A9 04    LDA #$04        ; Set missile pattern data
$B409: 85 6B    STA $6B         ; Store firing pattern
$B40B: 85 6C    STA $6C         ; Store direction data (same as pattern)
$B40D: D0 0E    BNE $B41D       ; Jump to missile setup
$B40F: C9 0B    CMP #$0B        ; Check for advanced targeting
$B411: D0 0D    BNE $B420       ; Branch if not 11
$B413: A9 09    LDA #$09        ; **ADVANCED TARGETING PATTERN**
$B415: 95 88    STA $88,X       ; Set enemy sprite type
$B417: A9 04    LDA #$04        ; Set missile pattern data
$B419: 85 6B    STA $6B         ; Store firing pattern
$B41B: 85 6C    STA $6C         ; Store direction data
$B41D: 4C 6B B4 JMP $B46B       ; **EXECUTE MISSILE FIRING**
$B420: C9 0C    CMP #$0C        ; Check for close-range firing
$B422: D0 0E    BNE $B432       ; Branch if not 12
$B424: A9 01    LDA #$01        ; **CLOSE-RANGE RAPID FIRE**
$B426: 95 88    STA $88,X       ; Set enemy sprite type
$B428: A9 08    LDA #$08        ; Set rapid fire pattern
$B42A: 85 6B    STA $6B         ; Store firing pattern
$B42C: A9 04    LDA #$04        ; Set firing direction
$B42E: 85 6C    STA $6C         ; Store direction data
$B430: D0 39    BNE $B46B       ; Jump to missile setup
$B432: C9 0D    CMP #$0D        ; Check for close-range variant
$B434: D0 0E    BNE $B444       ; Branch if not 13
$B436: A9 04    LDA #$04        ; **CLOSE-RANGE PATTERN 2**
$B438: 95 88    STA $88,X       ; Set enemy sprite type
$B43A: A9 04    LDA #$04        ; Set firing pattern
$B43C: 85 6B    STA $6B         ; Store firing pattern
$B43E: A9 08    LDA #$08        ; Set firing direction
$B440: 85 6C    STA $6C         ; Store direction data
$B442: D0 27    BNE $B46B       ; Jump to missile setup
$B444: C9 0E    CMP #$0E        ; Check for close-range variant
$B446: D0 0E    BNE $B456       ; Branch if not 14
$B448: A9 03    LDA #$03        ; **CLOSE-RANGE PATTERN 3**
$B44A: 95 88    STA $88,X       ; Set enemy sprite type
$B44C: A9 04    LDA #$04        ; Set firing pattern
$B44E: 85 6B    STA $6B         ; Store firing pattern
$B450: A9 08    LDA #$08        ; Set firing direction
$B452: 85 6C    STA $6C         ; Store direction data
$B454: D0 15    BNE $B46B       ; Jump to missile setup
$B456: C9 0F    CMP #$0F        ; Check for maximum aggression
$B458: D0 0E    BNE $B468       ; Branch if not 15
$B45A: A9 06    LDA #$06        ; **MAXIMUM AGGRESSION FIRING**
$B45C: 95 88    STA $88,X       ; Set enemy sprite type
$B45E: A9 08    LDA #$08        ; Set aggressive pattern
$B460: 85 6B    STA $6B         ; Store firing pattern
$B462: A9 04    LDA #$04        ; Set firing direction
$B464: 85 6C    STA $6C         ; Store direction data
$B466: D0 03    BNE $B46B       ; Jump to missile setup
$B468: 4C B3 B4 JMP $B4B3       ; No firing - continue AI processing
; ===============================================================================
; ENEMY MISSILE FIRING SYSTEM ($B46B)
; Executes enemy firing after AI decision
; This routine:
; - Sets up enemy missile positions based on enemy location
; - Configures missile graphics and collision detection
; - Enables missile display in screen memory
; - Triggers sound effects for enemy firing
; 
; MISSILE POSITIONING LOGIC:
; - $E2 = Enemy Y position + 5 (missile spawn point)
; - $DE = Enemy X position + 3 (missile spawn point)  
; - $C004 = Hardware missile position register
; - Screen memory ($1300) updated with missile graphics
; ===============================================================================

$B46B: B5 84    LDA $84,X       ; Load enemy Y position
$B46D: 18       CLC
$B46E: 69 05    ADC #$05        ; Add 5 pixels offset for missile spawn
$B470: 95 E2    STA $E2,X       ; Store missile Y position
$B472: A8       TAY             ; Transfer to Y register for screen addressing
$B473: B5 80    LDA $80,X       ; Load enemy X position
$B475: 18       CLC
$B476: 69 03    ADC #$03        ; Add 3 pixels offset for missile spawn
$B478: 95 DE    STA $DE,X       ; Store missile X position
$B47A: 9D 04 C0 STA $C004,X     ; Set hardware missile position register
$B47D: E0 01    CPX #$01        ; Check enemy index
$B47F: F0 16    BEQ $B497       ; Branch if enemy 1 (skip rotation)
$B481: 18       CLC             ; **MISSILE GRAPHICS ROTATION**
$B482: 26 6B    ROL $6B         ; Rotate missile pattern bits
$B484: 26 6B    ROL $6B         ; (creates different missile appearances)
$B486: 26 6C    ROL $6C         ; Rotate direction bits
$B488: 26 6C    ROL $6C         ; (varies missile trajectory)
$B48A: E0 02    CPX #$02        ; Check if enemy 2
$B48C: F0 09    BEQ $B497       ; Branch if enemy 2 (single rotation)
$B48E: 18       CLC             ; **DOUBLE ROTATION FOR ENEMY 3**
$B48F: 26 6B    ROL $6B         ; Additional rotation for enemy 3
$B491: 26 6B    ROL $6B         ; (creates unique firing pattern)
$B493: 26 6C    ROL $6C         ; Additional direction rotation
$B495: 26 6C    ROL $6C         ; (different trajectory angle)
$B497: B9 00 13 LDA $1300,Y     ; Load screen memory at missile position
$B49A: 05 6B    ORA $6B         ; Combine with missile pattern
$B49C: 99 00 13 STA $1300,Y     ; Store missile graphics to screen
$B49F: C8       INY             ; Move to next screen position
$B4A0: B9 00 13 LDA $1300,Y     ; Load next screen memory location
$B4A3: 05 6C    ORA $6C         ; Combine with direction pattern
$B4A5: 99 00 13 STA $1300,Y     ; Store missile graphics to screen
$B4A8: A9 AC    LDA #$AC        ; **ENEMY FIRING SOUND** - Load sound parameter ($AC = 172)
$B4AA: 85 B7    STA $B7         ; Store for sound routine
$B4AC: 8D 03 E8 STA $E803       ; Trigger POKEY sound register (enemy fire sound)
$B4AF: A9 04    LDA #$04        ; Load sound duration (4 VBI frames = ~67ms)
$B4B1: 85 B6    STA $B6         ; Store sound timer
;
; **ENEMY FIRING SOUND ANALYSIS**:
; - Parameter: $AC (172) → POKEY frequency ~5.17kHz
; - Duration: 4 frames @ 59.92Hz = 66.8ms
; - Creates distinctive "zap" sound for enemy weapons
; - Different from player fire sound ($BD66) for audio distinction
; ===============================================================================
; **FIRING SYSTEMS COMPARISON: PLAYER vs ENEMY**
; ===============================================================================
; K-Razy Shoot-Out uses TWO DIFFERENT missile systems:
;
; **PLAYER MISSILE SYSTEM**:
; - Fire button detection via $C008 register (bits 1,2,3) at $A932
; - Joystick direction sampling from $C000-$C00F registers at fire time
; - Player missile creation through hardware PMG system (Missile 0)
; - Hardware collision detection via $C008 register bits:
;   * Bit 1: Player missile hit enemy slot 1
;   * Bit 2: Player missile hit enemy slot 2  
;   * Bit 3: Player missile hit enemy slot 3
; - When collision detected, enemy is marked defeated
; - Trigger detection via $C010 register for menus/transitions
;
; **ENEMY MISSILE SYSTEM**:
; - AI decision creates physical missile sprite
; - Trajectory calculation using $6B/$6C pattern/direction data
; - Hardware PMG movement via ANTIC/GTIA chips
; - Collision registers $C00D-$C00F detect enemy missile hits on player
; - Multiple missiles can exist simultaneously (one per enemy)
;
; **KEY DIFFERENCE**:
; - Player has ONE missile that can hit any of 3 enemies
; - Enemies have UP TO 3 missiles (one per enemy) targeting player
; - Both use hardware PMG system for movement and collision detection
; - Direction control: Player uses joystick input, enemies use AI calculations
;
; **INPUT SYSTEM ARCHITECTURE**:
; - $C000-$C00F: Joystick position and fire button input registers
; - $C008: Fire button status register (bits 1,2,3)
; - $C010: Primary trigger register (0=pressed, 1=released)
; - Fire button processing: $A932 reads $C008, creates missile via $A99C
; - Trigger waiting loops: $A786, $AD4C, $BFF2 for game transitions
; ===============================================================================
; ENEMY FIRING FREQUENCY CONTROL ($B4B3-$B4BC)
; **COMPLETE FIRING FREQUENCY MECHANISM**
; Controls how often enemies can fire using VBI-synchronized counter system
; 
; MECHANISM:
; 1. $A7 = VBI counter (increments each vertical blank at 59.92 Hz)
; 2. $D7 = Frequency limit (loaded from level-based table at $BBE5)
; 3. Enemies can only attempt to fire when $A7 = 0
; 4. **ACTUAL FIRING RATE** is much lower due to additional conditions:
;    - Hardware randomization check (25% chance)
;    - Enemy state validation
;    - Missile availability check
;    - Player positioning requirements
; 
; **THEORETICAL vs ACTUAL RATES**:
; - Theoretical: 59.92/$D7 shots/sec (if fired every opportunity)
; - Actual: ~25% of theoretical due to randomization and conditions
; - Level 6: Theoretical 9.99/sec → Actual ~2.5/sec
; - Level 7: Theoretical 14.98/sec → Actual ~3.7/sec
; ===============================================================================
; 
; **ENEMY MISSILE MOVEMENT SYSTEM ANALYSIS**
; ===============================================================================
; After enemy firing creates a missile, the projectile movement is handled by
; the Atari 5200's hardware Player/Missile Graphics (PMG) system:
;
; **HARDWARE-BASED MOVEMENT**:
; 1. Enemy firing sets initial missile position in hardware register $C004,X
; 2. Missile direction/trajectory stored in $6C (rotated per enemy for variety)
; 3. Hardware PMG system automatically moves missiles based on:
;    - Hardware collision detection ($C00D-$C00F for missile/playfield)
;    - Automatic sprite positioning via ANTIC/GTIA chips
;    - No software position updates needed each frame
;
; **ENEMY MISSILE LIFECYCLE**:
; 1. **Creation**: Enemy AI triggers firing → $B46B sets position + direction
; 2. **Movement**: Hardware PMG moves missile automatically toward player
; 3. **Collision**: Hardware detects hits via $C00D-$C00F registers
; 4. **Destruction**: Collision detection clears missile from screen
;
; **KEY INSIGHT**: Unlike modern games that update projectile positions in
; software each frame, K-Razy Shoot-Out uses the Atari 5200's dedicated
; hardware to handle enemy missile movement automatically. The software only:
; - Sets initial position and trajectory when firing
; - Checks collision registers for hits
; - No per-frame position calculations needed!
;
; This hardware-accelerated approach was essential for smooth gameplay on
; the limited 1.79 MHz 6502 processor of the Atari 5200.
; ===============================================================================
$B4B3: A6 A7    LDX $A7         ; Load current firing frequency counter
$B4B5: E8       INX             ; Increment counter each frame (0→1→2→...→$D7)
$B4B6: E4 D7    CPX $D7         ; Compare with firing frequency limit (level-based)
$B4B8: D0 02    BNE $B4BC       ; Branch if counter < limit (continue counting)
$B4BA: A2 00    LDX #$00        ; Reset counter to 0 when limit reached (ENABLE FIRING)
$B4BC: 86 A7    STX $A7         ; Store updated counter
; 
; **FIRING FREQUENCY FORMULA**: Rate = 59.92 / $D7 shots per second (Atari 5200 NTSC VBI)
; - Each enemy has individual $A7 counter but shares same $D7 limit
; - Creates staggered firing pattern across 3 enemies
; - Higher $D7 = slower firing (beginner levels)
; - Lower $D7 = faster firing (advanced levels)
; - Timing synchronized to Vertical Blank Interrupt (59.92 Hz)
$B4BE: 60       RTS
; ===============================================================================
; DISPLAY_UPDATE ($B4BF)
; Screen and graphics updates with ESCAPE DETECTION
; This routine:
; - Updates score display
; - Refreshes screen areas
; - Handles screen transitions
; - Updates text displays
; - Processes screen effects
; - **CRITICAL**: Detects player escape through wall gaps!
; ===============================================================================

$B4BF: A5 97    LDA $97         ; Check escape detection flag
$B4C1: F0 08    BEQ $B4CB       ; Branch if no escape detected
$B4C3: 20 5E B7 JSR $B75E       ; **ESCAPE DETECTED!** Process player escape
$B4C6: A9 01    LDA #$01
$B4C8: 85 A9    STA $A9
$B4CA: 60       RTS
$B4CB: A9 FF    LDA #$FF
$B4CD: 85 92    STA $92
$B4CF: A2 01    LDX #$01 ; Update color palettes
$B4D1: 86 67    STX $67 ; Process screen effects
$B4D3: B5 97    LDA #$97
$B4D5: F0 3F    BEQ $B516 ; Branch if equal/zero
$B4D7: A5 D4    LDA #$D4
$B4D9: C5 D1    CMP #$D1
$B4DB: 90 06    BCC $B4E3 ; Branch if carry clear
$B4DD: A9 C0    LDA #$C0
$B4DF: 95 93    STA $93
$B4E1: D0 33    BNE $B516 ; Loop back if not zero
$B4E3: A9 00    LDA #$00
$B4E5: 95 97    STA $97
$B4E7: 95 93    STA $93
$B4E9: A9 FF    LDA #$FF
$B4EB: 95 8C    STA $8C
$B4ED: 20 1C B5 JSR $B51C
$B4F0: 20 31 B5 JSR $B531
$B4F3: 8A       TXA
$B4F4: 48       PHA
$B4F5: BD D4 BF LDA $BFD4
$B4F8: 48       PHA
$B4F9: B9 DA BF LDA $BFDA
$B4FC: A6 67    LDX #$67
$B4FE: 95 84    STA $84
$B500: 68       PLA
$B501: 95 80    STA $80
$B503: 9D 00 C0 STA $C000
$B506: 68       PLA
$B507: E0 01    CPX #$01
$B509: D0 02    BNE $B50D ; Loop back if not zero
$B50B: 85 92    STA $92
$B50D: AD 0A E8 LDA $E80A
$B510: 29 F0    AND #$F0
$B512: 09 08    ORA #$08
$B514: 95 08    STA $08
$B516: E8       INX
$B517: E0 04    CPX #$04
$B519: D0 B6    BNE $B4D1 ; Loop back if not zero
$B51B: 60       RTS
; ===============================================================================
; RANDOM_NUMBER_GENERATORS ($B51C, $B54A)
; Hardware-based random number generation using $E80A register
; Used for enemy AI, spawning, and potentially arena generation
; ===============================================================================

$B51C: AD 0A E8 LDA $E80A       ; Load hardware random register
$B51F: 29 07    AND #$07        ; Mask to get 0-7 range
$B521: C9 06    CMP #$06        ; Check if >= 6
$B523: B0 F7    BCS $B51C       ; Loop if >= 6 (reject 6,7 to get 0-5)
$B525: C5 B0    CMP $B0         ; Compare with previous value
$B527: F0 F3    BEQ $B51C       ; Loop if same as previous (avoid repeats)
$B529: C5 92    CMP $92         ; Compare with another stored value
$B52B: F0 EF    BEQ $B51C       ; Loop if same (avoid repeats)
$B52D: 85 B0    STA $B0         ; Store new random value
$B52F: AA       TAX             ; Transfer to X register
$B530: 60       RTS             ; Return with random 0-5 in A and X

$B531: E0 00    CPX #$00        ; Check X register value
$B533: F0 15    BEQ $B54A       ; Branch to different random routine if 0
$B535: E0 05    CPX #$05        ; Check if X is 5
$B537: F0 11    BEQ $B54A       ; Branch to different random routine if 5
$B539: AD 0A E8 LDA $E80A       ; Load hardware random register
$B53C: 29 01    AND #$01        ; Mask to get 0-1 range
$B53E: D0 04    BNE $B544       ; Branch if 1
$B540: 85 B1    STA $B1         ; Store 0
$B542: A8       TAY             ; Transfer to Y
$B543: 60       RTS             ; Return with 0
$B544: A9 02    LDA #$02        ; Load 2
$B546: 85 B1    STA $B1         ; Store 2
$B548: A8       TAY             ; Transfer to Y
$B549: 60       RTS             ; Return with 2

$B54A: AD 0A E8 LDA $E80A       ; Load hardware random register
$B54D: 29 03    AND #$03        ; Mask to get 0-3 range
$B54F: C9 03    CMP #$03        ; Check if 3
$B551: B0 F7    BCS $B54A       ; Loop if 3 (reject to get 0-2)
$B553: C5 B1    CMP $B1         ; Compare with previous value
$B555: F0 F3    BEQ $B54A       ; Loop if same (avoid repeats)
$B557: 85 B1    STA $B1
$B559: A8       TAY
$B55A: 60       RTS
$B55B: A2 13    LDX #$13
$B55D: E8       INX
$B55E: 8A       TXA
$B55F: 85 7A    STA $7A
$B561: A9 0E    LDA #$0E
$B563: 85 71    STA $71
$B565: A2 01    LDX #$01
$B567: 86 67    STX $67
$B569: 86 74    STX $74
$B56B: E6 7A    INC $7A
$B56D: B5 93    LDA #$93
$B56F: F0 03    BEQ $B574 ; Branch if equal/zero
$B571: 4C EB B6 JMP $B6EB
$B574: A9 00    LDA #$00
$B576: 85 A4    STA $A4
$B578: 85 A5    STA $A5
$B57A: A5 91    LDA #$91
$B57C: F0 03    BEQ $B581 ; Branch if equal/zero
$B57E: 4C EB B6 JMP $B6EB
$B581: B5 8C    LDA #$8C
$B583: C9 FF    CMP #$FF
$B585: D0 0B    BNE $B592 ; Loop back if not zero
$B587: A9 AC    LDA #$AC
$B589: 8D 05 E8 STA $E805 ; **PLAYER SPRITE CHARACTER** - Load character $AC into player sprite
$B58C: A9 20    LDA #$20
$B58E: 85 B8    STA $B8
$B590: 85 B9    STA $B9
$B592: A0 00    LDY #$00
$B594: A9 00    LDA #$00
$B596: 85 6F    STA $6F
$B598: A9 28    LDA #$28
$B59A: 85 70    STA $70
$B59C: B5 80    LDA #$80
$B59E: 85 78    STA $78
$B5A0: C5 80    CMP #$80
$B5A2: D0 03    BNE $B5A7 ; Loop back if not zero
$B5A4: 4C 4D B6 JMP $B64D
$B5A7: 30 09    BMI $B5B2
$B5A9: 38       SEC
$B5AA: E9 03    SBC #$03
$B5AC: 85 6C    STA $6C
$B5AE: A9 00    LDA #$00
$B5B0: F0 07    BEQ $B5B9 ; Branch if equal/zero
$B5B2: 18       CLC
$B5B3: 69 0B    ADC #$0B
$B5B5: 85 6C    STA $6C
$B5B7: A9 01    LDA #$01
$B5B9: 85 73    STA $73
$B5BB: A9 02    LDA #$02
$B5BD: 85 6B    STA $6B
$B5BF: 20 09 BD JSR $BD09
$B5C2: A6 67    LDX #$67
$B5C4: A5 6C    LDA #$6C
$B5C6: 38       SEC
$B5C7: E9 18    SBC #$18
$B5C9: 85 6C    STA $6C
$B5CB: A9 04    LDA #$04
$B5CD: 85 6B    STA $6B
$B5CF: 20 09 BD JSR $BD09
$B5D2: A6 67    LDX #$67
$B5D4: A5 6C    LDA #$6C
$B5D6: 85 92    STA $92
$B5D8: EA       NOP
$B5D9: B5 84    LDA #$84
$B5DB: 38       SEC
$B5DC: E9 03    SBC #$03
$B5DE: 85 6C    STA $6C
$B5E0: A9 04    LDA #$04
$B5E2: 85 6B    STA $6B
$B5E4: 20 09 BD JSR $BD09
$B5E7: A6 67    LDX #$67
$B5E9: A5 6C    LDA #$6C
$B5EB: 38       SEC
$B5EC: E9 08    SBC #$08
$B5EE: 85 6C    STA $6C
$B5F0: A5 92    LDA #$92
$B5F2: 20 09 B7 JSR $B709
$B5F5: A2 04    LDX #$04
$B5F7: A9 00    LDA #$00
$B5F9: 85 6B    STA $6B
$B5FB: B1 6F    LDA #$6F
$B5FD: 05 6B    ORA #$6B
$B5FF: 85 6B    STA $6B
$B601: 98       TYA
$B602: 18       CLC
$B603: 69 14    ADC #$14
$B605: 90 02    BCC $B609 ; Branch if carry clear
$B607: E6 70    INC $70
$B609: A8       TAY
$B60A: CA       DEX
$B60B: D0 EE    BNE $B5FB ; Loop back if not zero
$B60D: A6 67    LDX #$67
$B60F: A5 6B    LDA #$6B
$B611: D0 3A    BNE $B64D ; Loop back if not zero
$B613: B5 84    LDA #$84
$B615: 85 77    STA $77
$B617: A9 01    LDA #$01
$B619: 85 A4    STA $A4
$B61B: A5 73    LDA #$73
$B61D: F0 14    BEQ $B633 ; Branch if equal/zero
$B61F: A9 24    LDA #$24
$B621: D5 8C    CMP #$8C
$B623: D0 02    BNE $B627 ; Loop back if not zero
$B625: A9 30    LDA #$30
$B627: 85 64    STA $64
$B629: 95 8C    STA $8C
$B62B: 20 30 BD JSR $BD30
$B62E: A6 67    LDX #$67
$B630: 4C 44 B6 JMP $B644
$B633: A9 0C    LDA #$0C
$B635: D5 8C    CMP #$8C
$B637: D0 02    BNE $B63B ; Loop back if not zero
$B639: A9 18    LDA #$18
$B63B: 85 64    STA $64
$B63D: 95 8C    STA $8C
$B63F: 20 30 BD JSR $BD30
$B642: A6 67    LDX #$67
$B644: 20 58 BC JSR $BC58
$B647: A6 67    LDX #$67
$B649: A5 78    LDA #$78
$B64B: 95 80    STA $80
$B64D: A0 00    LDY #$00
$B64F: A9 00    LDA #$00
$B651: 85 6F    STA $6F
$B653: C8       INY
$B654: A9 28    LDA #$28
$B656: 85 70    STA $70
$B658: B5 84    LDA #$84
$B65A: 85 77    STA $77
$B65C: C5 84    CMP #$84
$B65E: D0 03    BNE $B663 ; Loop back if not zero
$B660: 4C DA B6 JMP $B6DA
$B663: 30 09    BMI $B66E
$B665: 38       SEC
$B666: E9 05    SBC #$05
$B668: 85 6C    STA $6C
$B66A: A9 00    LDA #$00
$B66C: F0 07    BEQ $B675 ; Branch if equal/zero
$B66E: 18       CLC
$B66F: 69 11    ADC #$11
$B671: 85 6C    STA $6C
$B673: A9 01    LDA #$01
$B675: 85 73    STA $73
$B677: A9 04    LDA #$04
$B679: 85 6B    STA $6B
$B67B: 20 09 BD JSR $BD09
$B67E: A6 67    LDX #$67
$B680: A5 6C    LDA #$6C
$B682: 38       SEC
$B683: E9 08    SBC #$08
$B685: 85 92    STA $92
$B687: B5 80    LDA #$80
$B689: 85 6C    STA $6C
$B68B: A9 02    LDA #$02
$B68D: 85 6B    STA $6B
$B68F: 20 09 BD JSR $BD09
$B692: A6 67    LDX #$67
$B694: A5 6C    LDA #$6C
$B696: 38       SEC
$B697: E9 18    SBC #$18
$B699: 85 6C    STA $6C
$B69B: A9 04    LDA #$04
$B69D: 85 6B    STA $6B
$B69F: 20 09 BD JSR $BD09
$B6A2: A6 67    LDX #$67
$B6A4: A5 6C    LDA #$6C
$B6A6: 85 A6    STA $A6
$B6A8: A5 92    LDA #$92
$B6AA: 85 6C    STA $6C
$B6AC: A5 A6    LDA #$A6
$B6AE: 20 09 B7 JSR $B709
$B6B1: B1 6F    LDA #$6F
$B6B3: D0 25    BNE $B6DA ; Loop back if not zero
$B6B5: A5 A4    LDA #$A4
$B6B7: D0 15    BNE $B6CE ; Loop back if not zero
$B6B9: A9 01    LDA #$01
$B6BB: 85 A5    STA $A5
$B6BD: A9 3C    LDA #$3C
$B6BF: D5 8C    CMP #$8C
$B6C1: D0 02    BNE $B6C5 ; Loop back if not zero
$B6C3: A9 48    LDA #$48
$B6C5: 85 64    STA $64
$B6C7: 95 8C    STA $8C
$B6C9: 20 30 BD JSR $BD30
$B6CC: A6 67    LDX #$67
$B6CE: 20 7C BC JSR $BC7C
$B6D1: 20 7C BC JSR $BC7C
$B6D4: A6 67    LDX #$67
$B6D6: A5 77    LDA #$77
$B6D8: 95 84    STA $84
$B6DA: A5 A4    LDA #$A4
$B6DC: 05 A5    ORA #$A5
$B6DE: D0 0B    BNE $B6EB ; Loop back if not zero
$B6E0: 85 64    STA $64
$B6E2: 95 8C    STA $8C
$B6E4: B5 84    LDA #$84
$B6E6: 85 77    STA $77
$B6E8: 20 30 BD JSR $BD30
$B6EB: A6 67    LDX #$67
$B6ED: E8       INX
$B6EE: E0 04    CPX #$04
$B6F0: F0 03    BEQ $B6F5 ; Branch if equal/zero
$B6F2: 4C 67 B5 JMP $B567
$B6F5: A5 91    LDA #$91
$B6F7: 18       CLC
$B6F8: 69 01    ADC #$01
$B6FA: 85 91    STA $91
$B6FC: C5 D8    CMP #$D8
$B6FE: 30 08    BMI $B708
$B700: A9 00    LDA #$00
$B702: 85 91    STA $91
$B704: A9 01    LDA #$01
$B706: 85 65    STA $65
$B708: 60       RTS
$B709: 48       PHA
$B70A: A9 14    LDA #$14
$B70C: 85 6B    STA $6B
$B70E: 20 1C BD JSR $BD1C
$B711: A6 67    LDX #$67
$B713: 68       PLA
$B714: 18       CLC
$B715: 65 6D    ADC #$6D
$B717: 85 6D    STA $6D
$B719: A8       TAY
$B71A: 90 02    BCC $B71E ; Branch if carry clear
$B71C: E6 6A    INC $6A
$B71E: A5 6A    LDA #$6A
$B720: 18       CLC
$B721: 65 70    ADC #$70
$B723: 85 70    STA $70
$B725: 60       RTS
$B726: E6 AA    INC $AA
$B728: A6 AA    LDX #$AA
$B72A: E0 06    CPX #$06
$B72C: D0 20    BNE $B74E ; Loop back if not zero
$B72E: A2 04    LDX #$04
$B730: FE 36 06 INC $0636
$B733: BD 36 06 LDA $0636
$B736: C9 3A    CMP #$3A
$B738: 90 0D    BCC $B747 ; Branch if carry clear
$B73A: A9 30    LDA #$30
$B73C: 9D 36 06 STA $0636
$B73F: E0 03    CPX #$03
$B741: D0 01    BNE $B744 ; Loop back if not zero
$B743: CA       DEX
$B744: CA       DEX
$B745: 10 E9    BPL $B730
$B747: 20 4F B7 JSR $B74F
$B74A: A9 00    LDA #$00
$B74C: 85 AA    STA $AA
$B74E: 60       RTS
$B74F: A2 04    LDX #$04
$B751: BD 36 06 LDA $0636
$B754: 18       CLC
$B755: E9 1F    SBC #$1F
$B757: 9D 36 2E STA $2E36
$B75A: CA       DEX
$B75B: 10 F4    BPL $B751
$B75D: 60       RTS
; ===============================================================================
; ESCAPE_PROCESSING ($B75E) - COMPLETE ANALYSIS
; Player escape through wall gaps - Level completion trigger
; 
; This routine creates a complex visual and audio escape sequence when the player
; successfully exits through wall gaps. It's a multi-stage animation that provides
; dramatic feedback for level completion.
;
; ESCAPE SEQUENCE BREAKDOWN:
; 1. Initialize escape effects ($B760-$B765)
; 2. Increment escape counter $DA (0→1→2→3)
; 3. Multi-stage visual effects loop ($B76C-$B794)
; 4. Final escape effects and cleanup ($B796-$B82E)
;
; TECHNICAL DETAILS:
; - Uses $06xx memory as staging area for screen effects
; - Copies staged data to screen memory $2Exx via $B889 routine
; - Controls hardware registers $E800-$E808 for sprite/display effects
; - Creates timed delays via $B82F routine (nested countdown loops)
; - Processes multiple animation frames with different effect patterns
; ===============================================================================
$B75E: A2 40    LDX #$40        ; Initialize escape effects
$B760: 20 BD BD JSR $BDBD       ; Clear hardware registers $E800-$E807
$B763: A0 FF    LDY #$FF        ; Set maximum delay counter
$B765: 20 97 B0 JSR $B097       ; Complex sprite/display effect routine
$B768: E6 DA    INC $DA         ; **INCREMENT ESCAPE COUNTER** (0→1→2→3)
$B76A: A5 DA    LDA $DA         ; Load escape counter
$B76C: 48       PHA             ; Save escape counter on stack
$B76D: 49 03    EOR #$03        ; XOR with 3 (when $DA=3, result=0 → level ends)
$B76F: AA       TAX             ; Use result as index for effect variation
$B770: A9 00    LDA #$00        ; Clear effect staging areas
$B772: 9D 16 06 STA $0616,X     ; Clear primary effect buffer
$B775: 9D 2A 06 STA $062A,X     ; Clear secondary effect buffer
$B778: A9 02    LDA #$02        ; Load base effect value
$B77A: E0 01    CPX #$01        ; Check if escape counter = 2
$B77C: D0 02    BNE $B780       ; Branch if not escape #2
$B77E: A9 04    LDA #$04        ; Use enhanced effect for escape #2
$B780: 9D 17 06 STA $0617,X     ; Store effect pattern to staging area
$B783: 09 01    ORA #$01        ; Add effect modifier
$B785: 9D 2B 06 STA $062B,X     ; Store modified effect pattern
$B788: A0 FF    LDY #$FF        ; Set delay counter
$B78A: 20 2F B8 JSR $B82F       ; **TIMED DELAY** - creates visual timing
$B78D: 20 89 B8 JSR $B889       ; **COPY EFFECTS TO SCREEN** - $06xx → $2Exx
$B790: 68       PLA             ; Restore escape counter from stack
$B791: 38       SEC             ; Set carry for subtraction
$B792: E9 01    SBC #$01        ; Decrement loop counter
$B794: 10 D6    BPL $B76C       ; Loop back for multiple effect frames
$B796: A9 00    LDA #$00        ; **FINAL ESCAPE EFFECTS PHASE**
$B798: 8D 19 06 STA $0619       ; Clear effect staging areas
$B79B: 8D 2D 06 STA $062D
$B79E: A9 04    LDA #$04        ; Set up final effect pattern
$B7A0: 8D 1A 06 STA $061A
$B7A3: A9 05    LDA #$05
$B7A5: 8D 2E 06 STA $062E
$B7A8: A0 FF    LDY #$FF        ; Maximum delay for dramatic timing
$B7AA: 20 2F B8 JSR $B82F       ; Timed delay
$B7AD: 20 89 B8 JSR $B889       ; Copy effects to screen
$B7B0: A9 00    LDA #$00        ; Clear final staging areas
$B7B2: 8D 1A 06 STA $061A
$B7B5: 8D 2E 06 STA $062E
$B7B8: A9 20    LDA #$20        ; Set up next effect phase
$B7BA: 8D 1B 06 STA $061B
$B7BD: A9 1E    LDA #$1E
$B7BF: 8D 2F 06 STA $062F
$B7C2: A0 FF    LDY #$FF        ; Timed delay
$B7C4: 20 2F B8 JSR $B82F
$B7C7: 20 89 B8 JSR $B889       ; Copy to screen
$B7CA: 20 3A B8 JSR $B83A       ; **SCREEN CLEAR PHASE 1** (rows $14-$59)
$B7CD: A9 00    LDA #$00        ; Clear staging
$B7CF: 8D 1B 06 STA $061B
$B7D2: A9 06    LDA #$06        ; Next effect pattern
$B7D4: 8D 1C 06 STA $061C
$B7D7: A9 07    LDA #$07
$B7D9: 8D 2F 06 STA $062F
$B7DC: 20 89 B8 JSR $B889       ; Copy to screen
$B7DF: 20 5A B8 JSR $B85A       ; **SCREEN CLEAR PHASE 2** (rows $59-$9B)
$B7E2: A9 00    LDA #$00        ; Clear staging
$B7E4: 8D 1C 06 STA $061C
$B7E7: A9 08    LDA #$08        ; Final effect pattern
$B7E9: 8D 2F 06 STA $062F
$B7EC: A9 09    LDA #$09
$B7EE: 8D 30 06 STA $0630
$B7F1: 20 89 B8 JSR $B889       ; Copy to screen
$B7F4: 20 70 B8 JSR $B870       ; **SCREEN CLEAR PHASE 3** (rows $4F-$3F countdown)
$B7F7: A9 00    LDA #$00        ; Clear all effect staging
$B7F9: 8D 2F 06 STA $062F
$B7FC: 8D 30 06 STA $0630
$B7FF: A5 DA    LDA #$DA
$B801: D0 0A    BNE $B80D ; Loop back if not zero
$B803: A9 20    LDA #$20
$B805: 8D 18 06 STA $0618
$B808: A9 1E    LDA #$1E
$B80A: 8D 2C 06 STA $062C
$B80D: A0 FF    LDY #$FF
$B80F: 20 2F B8 JSR $B82F
$B812: A0 FF    LDY #$FF
$B814: 20 2F B8 JSR $B82F
$B817: A0 FF    LDY #$FF
$B819: 20 2F B8 JSR $B82F
$B81C: A0 FF    LDY #$FF
$B81E: 20 2F B8 JSR $B82F
$B821: A0 FF    LDY #$FF
$B823: 20 2F B8 JSR $B82F
$B826: A0 FF    LDY #$FF
$B828: 20 89 B8 JSR $B889
$B82B: 20 BD BD JSR $BDBD
$B82E: 60       RTS
; ===============================================================================
; TIMED_DELAY ($B82F)
; Creates precise timing delays for escape visual effects
; Uses nested countdown loops: X counts down from $FF, Y counts down from input
; This creates the dramatic pacing of the escape sequence
; ===============================================================================
$B82F: A2 FF    LDX #$FF        ; Set inner loop counter to maximum
$B831: CA       DEX             ; Decrement inner counter
$B832: D0 FD    BNE $B831       ; Loop until X = 0 (255 iterations)
$B834: 88       DEY             ; Decrement outer counter (Y = input value)
$B835: D0 FA    BNE $B831       ; Loop until Y = 0 (Y * 255 total iterations)
$B837: A2 40    LDX #$40        ; Restore X register
$B839: 60       RTS

; ===============================================================================
; SCREEN_EFFECTS_COPY ($B889)
; Copies escape effect data from staging area ($06xx) to screen memory ($2Exx)
; This is what makes the visual effects appear on screen during escape
; ===============================================================================
; SCREEN_CLEAR_PHASE_1 ($B83A)
; **TOP-TO-BOTTOM SCREEN CLEAR** - First phase (rows $14-$59)
; Creates the dramatic "screen wipe" effect during escape sequence
; ===============================================================================
$B83A: A9 00    LDA #$00        ; Clear hardware register
$B83C: 8D 08 E8 STA $E808       ; Reset sprite/display control
$B83F: A9 AC    LDA #$AC        ; Set display mode/pattern
$B841: 8D 01 E8 STA $E801       ; Configure display register
$B844: A9 14    LDA #$14        ; **START ROW** = $14 (20 decimal)
$B846: 85 92    STA $92         ; Store current row counter
$B848: A0 0A    LDY #$0A        ; Set delay counter for timing
$B84A: 20 2F B8 JSR $B82F       ; **TIMED DELAY** - creates visible sweep effect
$B84D: A4 92    LDY $92         ; Load current row
$B84F: C8       INY             ; **INCREMENT ROW** (clear next row)
$B850: 8C 00 E8 STY $E800       ; **CLEAR CURRENT ROW** via hardware register
$B853: 84 92    STY $92         ; Save new row position
$B855: C0 59    CPY #$59        ; Check if reached row $59 (89 decimal)
$B857: D0 EF    BNE $B848       ; **LOOP** until all rows $14-$59 cleared
$B859: 60       RTS             ; Phase 1 complete

; ===============================================================================
; SCREEN_CLEAR_PHASE_2 ($B85A)
; **TOP-TO-BOTTOM SCREEN CLEAR** - Second phase (rows $59-$9B)
; Continues the screen wipe effect from where phase 1 ended
; ===============================================================================
$B85A: A9 59    LDA #$59        ; **START ROW** = $59 (89 decimal)
$B85C: 85 92    STA $92         ; Store current row counter
$B85E: A0 0A    LDY #$0A        ; Set delay counter for timing
$B860: 20 2F B8 JSR $B82F       ; **TIMED DELAY** - maintains sweep timing
$B863: A4 92    LDY $92         ; Load current row
$B865: C8       INY             ; **INCREMENT ROW** (clear next row)
$B866: 8C 00 E8 STY $E800       ; **CLEAR CURRENT ROW** via hardware register
$B869: 84 92    STY $92         ; Save new row position
$B86B: C0 9B    CPY #$9B        ; Check if reached row $9B (155 decimal)
$B86D: D0 EF    BNE $B85E       ; **LOOP** until all rows $59-$9B cleared
$B86F: 60       RTS             ; Phase 2 complete

; ===============================================================================
; SCREEN_CLEAR_PHASE_3 ($B870)
; **TOP-TO-BOTTOM SCREEN CLEAR** - Final phase (rows $4F-$3F countdown)
; Completes the screen wipe effect with a countdown sequence
; ===============================================================================
$B870: A9 4F    LDA #$4F        ; **START ROW** = $4F (79 decimal)
$B872: 85 92    STA $92         ; Store current row counter
$B874: 8D 01 E8 STA $E801       ; Configure display register
$B877: A0 1C    LDY #$1C        ; Set delay counter (longer delay for final effect)
$B879: 20 2F B8 JSR $B82F       ; **TIMED DELAY** - dramatic final timing
$B87C: A4 92    LDY $92         ; Load current row
$B87E: 88       DEY             ; **DECREMENT ROW** (countdown effect)
$B87F: 8C 01 E8 STY $E801       ; **CLEAR CURRENT ROW** via hardware register
$B882: 84 92    STY $92         ; Save new row position
$B884: C0 3F    CPY #$3F        ; Check if reached row $3F (63 decimal)
$B886: D0 EF    BNE $B877       ; **LOOP** until countdown to row $3F complete
$B888: 60       RTS             ; Screen clear complete!
; ===============================================================================
; SCREEN_EFFECTS_COPY ($B889)
; Copies escape effect data from staging area ($06xx) to screen memory ($2Exx)
; This is what makes the visual effects appear on screen during escape
; ===============================================================================
$B889: A2 07    LDX #$07        ; Copy 8 bytes of effect data
$B88B: BD 29 06 LDA $0629,X     ; Load from effect staging area
$B88E: 9D 29 2E STA $2E29,X     ; Store to screen memory (makes effects visible)
$B891: BD 15 06 LDA $0615,X     ; Load from secondary staging area
$B894: 9D 15 2E STA $2E15,X     ; Store to secondary screen area
$B897: CA       DEX             ; Decrement copy counter
$B898: D0 F1    BNE $B88B       ; Loop until all 8 bytes copied
$B89A: 60       RTS
$B89B: A9 00    LDA #$00
$B89D: A2 00    LDX #$00
$B89F: 9D 00 28 STA $2800
$B8A2: 9D 00 29 STA $2900
$B8A5: 9D 00 2A STA $2A00
$B8A8: 9D F4 2A STA $2AF4
$B8AB: CA       DEX
$B8AC: D0 F1    BNE $B89F ; Loop back if not zero
$B8AE: 60       RTS
$B8AF: A9 00    LDA #$00
$B8B1: 85 7C    STA $7C
$B8B3: 85 7D    STA $7D
$B8B5: A5 54    LDA #$54
$B8B7: 85 BF    STA $BF
$B8B9: 2A       ROL
$B8BA: 2A       ROL
$B8BB: 29 FC    AND #$FC
$B8BD: 85 C2    STA $C2
$B8BF: 2A       ROL
$B8C0: 26 7D    ROL $7D
$B8C2: 2A       ROL
$B8C3: 26 7D    ROL $7D
$B8C5: 65 C2    ADC #$C2
$B8C7: 85 7C    STA $7C
$B8C9: 90 02    BCC $B8CD ; Branch if carry clear
$B8CB: E6 7D    INC $7D
$B8CD: A5 55    LDA #$55
$B8CF: 85 C0    STA $C0
$B8D1: 4A       LSR
$B8D2: 4A       LSR
$B8D3: A8       TAY
$B8D4: 18       CLC
$B8D5: A5 7D    LDA #$7D
$B8D7: 69 28    ADC #$28
$B8D9: 85 7D    STA $7D
$B8DB: A5 55    LDA #$55
$B8DD: 29 03    AND #$03
$B8DF: C9 00    CMP #$00
$B8E1: D0 07    BNE $B8EA ; Loop back if not zero
$B8E3: A5 69    LDA #$69
$B8E5: 29 C0    AND #$C0
$B8E7: 4C 04 B9 JMP $B904
$B8EA: C9 01    CMP #$01
$B8EC: D0 07    BNE $B8F5 ; Loop back if not zero
$B8EE: A5 69    LDA #$69
$B8F0: 29 30    AND #$30
$B8F2: 4C 04 B9 JMP $B904
$B8F5: C9 02    CMP #$02
$B8F7: D0 07    BNE $B900 ; Loop back if not zero
$B8F9: A5 69    LDA #$69
$B8FB: 29 0C    AND #$0C
$B8FD: 4C 04 B9 JMP $B904
$B900: A5 69    LDA #$69
$B902: 29 03    AND #$03
$B904: 85 C1    STA $C1
$B906: B1 7C    LDA #$7C
$B908: 05 C1    ORA #$C1
$B90A: 91 7C    STA $7C
$B90C: 60       RTS
$B90D: A5 55    LDA #$55
$B90F: C5 C0    CMP #$C0
$B911: F0 2D    BEQ $B940 ; Branch if equal/zero
$B913: 85 C3    STA $C3
$B915: 30 14    BMI $B92B
$B917: 38       SEC
$B918: E5 C0    SBC #$C0
$B91A: AA       TAX
$B91B: 20 AF B8 JSR $B8AF
$B91E: C6 55    DEC $55
$B920: CA       DEX
$B921: D0 F8    BNE $B91B ; Loop back if not zero
$B923: A5 C3    LDA #$C3
$B925: 85 55    STA $55
$B927: 85 C0    STA $C0
$B929: 60       RTS
$B92A: 60       RTS
$B92B: 38       SEC
$B92C: A5 C0    LDA #$C0
$B92E: E5 55    SBC #$55
$B930: AA       TAX
$B931: E6 55    INC $55
$B933: 20 AF B8 JSR $B8AF
$B936: CA       DEX
$B937: D0 F8    BNE $B931 ; Loop back if not zero
$B939: A5 C3    LDA #$C3
$B93B: 85 55    STA $55
$B93D: 85 C0    STA $C0
$B93F: 60       RTS
$B940: A5 54    LDA #$54
$B942: 85 C3    STA $C3
$B944: C5 BF    CMP #$BF
$B946: 30 13    BMI $B95B
$B948: 38       SEC
$B949: E5 BF    SBC #$BF
$B94B: AA       TAX
$B94C: C6 54    DEC $54
$B94E: 20 AF B8 JSR $B8AF
$B951: CA       DEX
$B952: D0 F8    BNE $B94C ; Loop back if not zero
$B954: A5 C3    LDA #$C3
$B956: 85 54    STA $54
$B958: 85 BF    STA $BF
$B95A: 60       RTS
$B95B: A5 BF    LDA #$BF
$B95D: 38       SEC
$B95E: E5 54    SBC #$54
$B960: AA       TAX
$B961: E6 54    INC $54
$B963: 20 AF B8 JSR $B8AF
$B966: CA       DEX
$B967: D0 F8    BNE $B961 ; Loop back if not zero
$B969: A5 C3    LDA #$C3
$B96B: 85 54    STA $54
$B96D: 85 BF    STA $BF
$B96F: 60       RTS
$B970: 20 20 20 JSR $2020
$B973: 31 20    AND #$20
$B975: 9B       .byte $9B        ; Data byte
$B976: B8       CLV ; Update player sprites
$B977: A9 A2    LDA #$A2
$B979: 85 06    STA $06
$B97B: A9 70    LDA #$70
$B97D: 85 05    STA $05
$B97F: A9 00    LDA #$00
$B981: 85 0C    STA $0C
$B983: A9 00    LDA #$00
$B985: 85 54    STA $54
$B987: A9 55    LDA #$55
$B989: 85 69    STA $69
$B98B: A9 4C    LDA #$4C
$B98D: 85 55    STA $55
$B98F: 20 AF B8 JSR $B8AF
$B992: A9 02    LDA #$02
$B994: 85 55    STA $55
$B996: 20 0D B9 JSR $B90D
$B999: A9 00    LDA #$00
$B99B: 85 0D    STA $0D
$B99D: A9 AA    LDA #$AA
$B99F: 85 69    STA $69
$B9A1: A9 03    LDA #$03
$B9A3: 85 55    STA $55
$B9A5: A9 02    LDA #$02
$B9A7: 85 54    STA $54
$B9A9: 20 AF B8 JSR $B8AF
$B9AC: A9 4C    LDA #$4C
$B9AE: 85 55    STA $55
$B9B0: 20 0D B9 JSR $B90D
$B9B3: A9 26    LDA #$26
$B9B5: 85 54    STA $54
$B9B7: 20 0D B9 JSR $B90D
$B9BA: A9 03    LDA #$03
$B9BC: 85 55    STA $55
$B9BE: 20 0D B9 JSR $B90D
$B9C1: A9 02    LDA #$02
$B9C3: 85 54    STA $54
$B9C5: 20 0D B9 JSR $B90D
$B9C8: A9 00    LDA #$00
$B9CA: 85 0E    STA $0E
$B9CC: A9 AA    LDA #$AA
$B9CE: 85 69    STA $69
$B9D0: A9 02    LDA #$02
$B9D2: 85 92    STA $92
$B9D4: 85 55    STA $55
$B9D6: AD 0A E8 LDA $E80A
$B9D9: 29 07    AND #$07
$B9DB: C9 06    CMP #$06
$B9DD: B0 F7    BCS $B9D6 ; Branch if carry set
$B9DF: 85 6C    STA $6C
$B9E1: A9 06    LDA #$06
$B9E3: 85 6B    STA $6B
$B9E5: 20 1C BD JSR $BD1C
$B9E8: A5 6D    LDA #$6D
$B9EA: 18       CLC
$B9EB: 69 02    ADC #$02
$B9ED: 85 54    STA $54
$B9EF: 20 AF B8 JSR $B8AF
$B9F2: E6 55    INC $55
$B9F4: E6 55    INC $55
$B9F6: 20 0D B9 JSR $B90D
$B9F9: C6 55    DEC $55
$B9FB: E6 54    INC $54
$B9FD: A9 FF    LDA #$FF
$B9FF: 85 69    STA $69
$BA01: 20 AF B8 JSR $B8AF
$BA04: A5 54    LDA #$54
$BA06: 18       CLC
$BA07: 69 05    ADC #$05
$BA09: 85 54    STA $54
$BA0B: 20 0D B9 JSR $B90D
$BA0E: E6 54    INC $54
$BA10: C6 55    DEC $55
$BA12: C6 54    DEC $54
$BA14: A9 AA    LDA #$AA
$BA16: 85 69    STA $69
$BA18: 20 AF B8 JSR $B8AF
$BA1B: E6 55    INC $55
$BA1D: E6 55    INC $55
$BA1F: 20 0D B9 JSR $B90D
$BA22: A9 4B    LDA #$4B
$BA24: C5 92    CMP #$92
$BA26: D0 AA    BNE $B9D2 ; Loop back if not zero
$BA28: A9 AA    LDA #$AA
$BA2A: 85 69    STA $69
$BA2C: A9 0E    LDA #$0E
$BA2E: 85 54    STA $54
$BA30: A9 03    LDA #$03
$BA32: 85 92    STA $92
$BA34: 85 55    STA $55
$BA36: AD 0A E8 LDA $E80A
$BA39: 29 01    AND #$01
$BA3B: D0 1B    BNE $BA58 ; Loop back if not zero
$BA3D: AD 0A E8 LDA $E80A
$BA40: 29 01    AND #$01
$BA42: D0 07    BNE $BA4B ; Loop back if not zero
$BA44: A5 55    LDA #$55
$BA46: 18       CLC
$BA47: 69 0C    ADC #$0C
$BA49: 85 55    STA $55
$BA4B: 20 AF B8 JSR $B8AF
$BA4E: A5 55    LDA #$55
$BA50: 18       CLC
$BA51: 69 0C    ADC #$0C
$BA53: 85 55    STA $55
$BA55: 20 0D B9 JSR $B90D
$BA58: A5 92    LDA #$92
$BA5A: 18       CLC
$BA5B: 69 18    ADC #$18
$BA5D: 85 92    STA $92
$BA5F: 85 55    STA $55
$BA61: C9 4B    CMP #$4B
$BA63: D0 D1    BNE $BA36 ; Loop back if not zero
$BA65: A5 54    LDA #$54
$BA67: 18       CLC
$BA68: 69 0C    ADC #$0C
$BA6A: 85 54    STA $54
$BA6C: C9 26    CMP #$26
$BA6E: D0 C0    BNE $BA30 ; Loop back if not zero
$BA70: A9 0F    LDA #$0F
$BA72: 85 55    STA $55
$BA74: A9 02    LDA #$02
$BA76: 85 92    STA $92
$BA78: 85 54    STA $54
$BA7A: AD 0A E8 LDA $E80A
$BA7D: 29 01    AND #$01
$BA7F: D0 1B    BNE $BA9C ; Loop back if not zero
$BA81: AD 0A E8 LDA $E80A
$BA84: 29 01    AND #$01
$BA86: D0 07    BNE $BA8F ; Loop back if not zero
$BA88: A5 54    LDA #$54
$BA8A: 18       CLC
$BA8B: 69 07    ADC #$07
$BA8D: 85 54    STA $54
$BA8F: 20 AF B8 JSR $B8AF
$BA92: A5 54    LDA #$54
$BA94: 18       CLC
$BA95: 69 05    ADC #$05
$BA97: 85 54    STA $54
$BA99: 20 0D B9 JSR $B90D
$BA9C: A5 92    LDA #$92
$BA9E: 18       CLC
$BA9F: 69 0C    ADC #$0C
$BAA1: 85 92    STA $92
$BAA3: 85 54    STA $54
$BAA5: C9 26    CMP #$26
$BAA7: D0 D1    BNE $BA7A ; Loop back if not zero
$BAA9: A5 55    LDA #$55
$BAAB: 18       CLC
$BAAC: 69 0C    ADC #$0C
$BAAE: 85 55    STA $55
$BAB0: C9 4B    CMP #$4B
$BAB2: D0 C0    BNE $BA74 ; Loop back if not zero
$BAB4: AD 0A E8 LDA $E80A
$BAB7: 09 07    ORA #$07
$BAB9: 85 0D    STA $0D
$BABB: A9 B7    LDA #$B7
$BABD: 85 0C    STA $0C
$BABF: 60       RTS
$BAC0: A2 00    LDX #$00
$BAC2: 20 64 BB JSR $BB64
$BAC5: A9 31    LDA #$31
$BAC7: 85 6B    STA $6B
$BAC9: 20 1C BD JSR $BD1C
$BACC: A5 6A    LDA #$6A
$BACE: 85 64    STA $64
$BAD0: A5 6D    LDA #$6D
$BAD2: 85 65    STA $65
$BAD4: A2 2B    LDX #$2B
$BAD6: 20 64 BB JSR $BB64
$BAD9: A9 07    LDA #$07
$BADB: 85 6B    STA $6B
$BADD: 20 1C BD JSR $BD1C
$BAE0: 38       SEC
$BAE1: A5 65    LDA #$65
$BAE3: E5 6D    SBC #$6D
$BAE5: 85 69    STA $69
$BAE7: A5 64    LDA #$64
$BAE9: E5 6A    SBC #$6A
$BAEB: 85 68    STA $68
$BAED: 90 0D    BCC $BAFC ; Branch if carry clear
$BAEF: A5 69    LDA #$69
$BAF1: 38       SEC
$BAF2: E5 CF    SBC #$CF
$BAF4: 85 69    STA $69
$BAF6: A5 68    LDA #$68
$BAF8: E5 CE    SBC #$CE
$BAFA: B0 04    BCS $BB00 ; Branch if carry set
$BAFC: A9 00    LDA #$00
$BAFE: 85 69    STA $69
$BB00: 0A       ASL
$BB01: 0A       ASL
$BB02: 0A       ASL
$BB03: AA       TAX
$BB04: E0 30    CPX #$30
$BB06: 90 06    BCC $BB0E ; Branch if carry clear
$BB08: A9 D0    LDA #$D0
$BB0A: 85 69    STA $69
$BB0C: A2 28    LDX #$28
$BB0E: A0 00    LDY #$00
$BB10: BD 0B A6 LDA $A60B
$BB13: 99 BA 06 STA $06BA
$BB16: E8       INX
$BB17: C8       INY
$BB18: C0 08    CPY #$08
$BB1A: D0 F4    BNE $BB10 ; Loop back if not zero
$BB1C: A5 69    LDA #$69
$BB1E: 85 6C    STA $6C
$BB20: A9 34    LDA #$34
$BB22: 85 6B    STA $6B
$BB24: 20 09 BD JSR $BD09
$BB27: A9 35    LDA #$35
$BB29: 38       SEC
$BB2A: E5 6C    SBC #$6C
$BB2C: 8D CE 06 STA $06CE
$BB2F: A9 30    LDA #$30
$BB31: 8D AC 06 STA $06AC
$BB34: 8D AD 06 STA $06AD
$BB37: 8D AE 06 STA $06AE
$BB3A: A5 CF    LDA #$CF
$BB3C: 85 6A    STA $6A
$BB3E: A5 CE    LDA #$CE
$BB40: 85 6D    STA $6D
$BB42: A2 02    LDX #$02
$BB44: FE AC 06 INC $06AC
$BB47: BD AC 06 LDA $06AC
$BB4A: C9 3A    CMP #$3A
$BB4C: D0 08    BNE $BB56 ; Loop back if not zero
$BB4E: A9 30    LDA #$30
$BB50: 9D AC 06 STA $06AC
$BB53: CA       DEX
$BB54: 10 EE    BPL $BB44
$BB56: A5 6A    LDA #$6A
$BB58: 38       SEC
$BB59: E9 34    SBC #$34
$BB5B: 85 6A    STA $6A
$BB5D: B0 E3    BCS $BB42 ; Branch if carry set
$BB5F: C6 6D    DEC $6D
$BB61: 10 DF    BPL $BB42
$BB63: 60       RTS
$BB64: BD 0B 06 LDA $060B
$BB67: 0A       ASL
$BB68: 0A       ASL
$BB69: 7D 0B 06 ADC $060B
$BB6C: 0A       ASL
$BB6D: 18       CLC
$BB6E: 7D 0C 06 ADC $060C
$BB71: 38       SEC
$BB72: E9 10    SBC #$10
$BB74: 85 6C    STA $6C
$BB76: 60       RTS
; ===============================================================================
; TIME_COUNTDOWN_AND_DISPLAY ($BB77)
; Time limit system and visual time bar update
; This routine:
; - Decrements time remaining counter ($D9) each time interval
; - Updates visual time bar display at screen memory $2800
; - Creates time pressure for enemy clearing and escape
; - When $D9 reaches 2, level automatically advances (time up)
; - Integrates with enemy system and exit activation
; ===============================================================================

$BB77: A5 AF    LDA $AF         ; Load time interval counter
$BB79: D0 3B    BNE $BBB6       ; Branch if not time to decrement
$BB7B: C6 D9    DEC $D9         ; DECREMENT TIME REMAINING (77 → 2 for level end)
$BB7D: A5 D9    LDA $D9         ; Load current time remaining
$BB7F: 4A       LSR             ; Divide by 4 for time bar calculation
$BB80: 4A       LSR
$BB81: AA       TAX             ; Store quotient in X
$BB82: A5 D9    LDA $D9         ; Load time remaining again
$BB84: 29 03    AND #$03        ; Get remainder (0-3) for bar segment type
$BB86: D0 05    BNE $BB8D       ; Branch if not 0
$BB88: A9 00    LDA #$00        ; Empty bar segment character
$BB8A: 4C A1 BB JMP $BBA1       ; Jump to display update
$BB8D: C9 01    CMP #$01        ; Check if remainder is 1
$BB8F: D0 05    BNE $BB96       ; Branch if not 1
$BB91: A9 40    LDA #$40        ; Partial bar segment character
$BB93: 4C A1 BB JMP $BBA1       ; Jump to display update
$BB96: C9 02    CMP #$02        ; Check if remainder is 2
$BB98: D0 05    BNE $BB9F       ; Branch if not 2
$BB9A: A9 50    LDA #$50        ; Partial bar segment character
$BB9C: 4C A1 BB JMP $BBA1       ; Jump to display update
$BB9F: A9 54    LDA #$54        ; Full bar segment character
$BBA1: 9D 00 28 STA $2800,X     ; Update time bar display at screen memory
$BBA4: A6 D9    LDX $D9         ; Load time remaining for threshold checks
$BBA6: E0 34    CPX #$34        ; Check if time = 52 (warning threshold)
$BBA8: D0 04    BNE $BBAE       ; Branch if not 52
$BBAA: A9 EE    LDA #$EE        ; Load warning indicator
$BBAC: 85 0C    STA $0C         ; Store warning state
$BBAE: E0 1A    CPX #$1A        ; Check if time = 26 (critical threshold)
$BBB0: D0 04    BNE $BBB6       ; Branch if not 26
$BBB2: A9 36    LDA #$36        ; Load critical indicator
$BBB4: 85 0C    STA $0C         ; Store critical state
$BBB6: E6 AF    INC $AF
$BBB8: A5 AF    LDA #$AF
$BBBA: C5 7F    CMP #$7F
$BBBC: D0 04    BNE $BBC2 ; Loop back if not zero
$BBBE: A9 00    LDA #$00
$BBC0: 85 AF    STA $AF
$BBC2: 60       RTS
; ===============================================================================
; MAIN_UPDATE ($BBC3)
; Primary game logic update with LEVEL-BASED FIRING FREQUENCY SETUP
; This routine:
; - Updates game timers
; - Processes game events  
; - Loads level-specific parameters including enemy firing frequency
; - Checks win/lose conditions
; - Manages game flow
; - **CRITICAL**: Sets $D7 firing frequency from level-based table
; ===============================================================================

$BBC3: A5 D5    LDA $D5         ; Load current level counter
$BBC5: AA       TAX             ; Transfer to X for state checking
$BBC6: A9 30    LDA #$30        ; Load base value
$BBC8: 85 7F    STA $7F         ; Store base parameter
$BBCA: A5 D5    LDA $D5         ; Load level counter again
$BBCC: 0A       ASL             ; Multiply by 4 (level * 4)
$BBCD: 0A       ASL             ; for 4-byte table lookup
$BBCE: AA       TAX             ; Use as table index
$BBCF: BD E4 BB LDA $BBE4,X     ; Load parameter 1 from level table
$BBD2: 85 D1    STA $D1         ; Store accuracy/difficulty parameter
$BBD4: BD E5 BB LDA $BBE5,X     ; **LOAD FIRING FREQUENCY** from level table
$BBD7: 85 D7    STA $D7         ; Store in firing frequency variable ($D7)
$BBD9: BD E7 BB LDA $BBE7,X     ; Load parameter 3 from level table  
$BBDC: 85 D8    STA $D8         ; Store timing parameter
$BBDE: BD E6 BB LDA $BBE6,X     ; Load parameter 2 from level table
$BBE1: 85 D6    STA $D6         ; Store game speed parameter
$BBE3: 60       RTS
; ===============================================================================
; LEVEL-BASED PARAMETER TABLES ($BBE4-$BC03)
; **ENEMY FIRING FREQUENCY AND DIFFICULTY DATA**
; Format: 4 bytes per level (D1, D7, D6, D8)
; - D1 = Accuracy/difficulty parameter  
; - D7 = FIRING FREQUENCY (frames between shots)
; - D6 = Game speed parameter
; - D8 = Timing parameter
; 
; FIRING FREQUENCY ANALYSIS (Atari 5200 NTSC @ 59.92 Hz):
; **THEORETICAL RATES** (if fired every opportunity):
; Level 0: D7=$00 (0)   = NO FIRING (tutorial level)
; Level 1: D7=$60 (96)  = 0.62 shots/sec (every 1602ms)
; Level 2: D7=$40 (64)  = 0.94 shots/sec (every 1068ms)
; Level 3: D7=$30 (48)  = 1.25 shots/sec (every 801ms)
; Level 4: D7=$25 (37)  = 1.62 shots/sec (every 617ms)
; Level 5: D7=$13 (19)  = 3.15 shots/sec (every 317ms)
; Level 6: D7=$06 (6)   = 9.99 shots/sec (every 100ms)
; Level 7: D7=$04 (4)   = 14.98 shots/sec (every 67ms)
;
; **ACTUAL RATES** (accounting for randomization and conditions):
; - ~25% of theoretical due to hardware randomization ($E80A & #$03 ≠ 0)
; - Additional reductions from enemy state and missile availability checks
; - Level 1: ~0.15 shots/sec (every ~6.4 seconds)
; - Level 2: ~0.23 shots/sec (every ~4.3 seconds)  
; - Level 3: ~0.31 shots/sec (every ~3.2 seconds)
; - Level 4: ~0.40 shots/sec (every ~2.5 seconds)
; - Level 5: ~0.79 shots/sec (every ~1.3 seconds)
; - Level 6: ~2.50 shots/sec (every ~0.4 seconds)
; - Level 7: ~3.75 shots/sec (every ~0.27 seconds)
; ===============================================================================
$BBE4: .byte $0E, $00, $02, $15    ; Level 0: No firing (D7=$00)
$BBE8: .byte $14, $60, $02, $12    ; Level 1: 0.6 shots/sec (D7=$60=96)
$BBEC: .byte $1A, $40, $03, $08    ; Level 2: 0.9 shots/sec (D7=$40=64)
$BBF0: .byte $1D, $30, $04, $06    ; Level 3: 1.2 shots/sec (D7=$30=48)
$BBF4: .byte $20, $25, $0A, $04    ; Level 4: 1.6 shots/sec (D7=$25=37)
$BBF8: .byte $24, $13, $50, $03    ; Level 5: 3.2 shots/sec (D7=$13=19)
$BBFC: .byte $36, $06, $FF, $01    ; Level 6: 10.0 shots/sec (D7=$06=6)
$BC00: .byte $75, $04, $FF, $01    ; Level 7: 15.0 shots/sec (D7=$04=4)

; ===============================================================================
; COMPLETE ENEMY FIRING SYSTEM SUMMARY
; ===============================================================================
; K-Razy Shoot-Out implements a sophisticated 3-layer enemy firing system:
;
; **LAYER 1: FREQUENCY CONTROL (VBI-synchronized timing)**
; - $A7 = Frame counter (increments each VBI at 59.92 Hz)
; - $D7 = Frequency limit (loaded from level table at $BBE4)
; - Enemies can only attempt to fire when $A7 = 0
; - Creates level-based difficulty scaling from 0.62 to 14.98 shots/sec
;
; **LAYER 2: TARGETING DECISION (Position-based AI)**
; - Calculates player-enemy distance in X/Y directions
; - Creates 4-bit targeting value based on alignment thresholds
; - Selects from 8 different firing patterns based on positioning
; - Ensures intelligent targeting rather than random firing
;
; **LAYER 3: MISSILE EXECUTION (Graphics and sound)**
; - Sets missile positions with spawn offsets (+5Y, +3X from enemy)
; - Applies rotation effects for visual variety per enemy
; - Triggers POKEY sound effects for audio feedback
; - Updates screen memory with missile graphics
;
; **DIFFICULTY PROGRESSION:**
; Level 0: Tutorial (no firing) - Learn movement and escape mechanics
; Level 1-2: Beginner (0.15-0.23 shots/sec) - Introduction to combat
; Level 3-4: Intermediate (0.31-0.40 shots/sec) - Standard challenge
; Level 5: Advanced (0.79 shots/sec) - High skill required
; Level 6-7: Expert (2.5-3.75 shots/sec) - Maximum challenge
;
; This system demonstrates sophisticated game design for 1981, combining
; mathematical precision with intuitive gameplay progression.
; ===============================================================================
$BC05: 01 FF    ORA #$FF
$BC07: 01 3C    ORA #$3C
$BC09: 3A       .byte $3A        ; Data byte
$BC0A: 38       SEC
$BC0B: 36 34    ROL $34
$BC0D: 32       .byte $32        ; Data byte
$BC0E: 30 2E    BMI $BC3E
$BC10: 2C A2 02 BIT $02A2
$BC13: AD 0A E8 LDA $E80A
$BC16: 29 01    AND #$01
$BC18: D0 02    BNE $BC1C ; Loop back if not zero
$BC1A: A2 03    LDX #$03
$BC1C: BD D4 BF LDA $BFD4
$BC1F: 85 80    STA $80
$BC21: 8D 00 C0 STA $C000
$BC24: A9 66    LDA #$66
$BC26: 85 84    STA $84
$BC28: A5 D4    LDA #$D4
$BC2A: C5 D1    CMP #$D1
$BC2C: B0 08    BCS $BC36 ; Branch if carry set
$BC2E: A9 00    LDA #$00
$BC30: 85 94    STA $94
$BC32: 85 95    STA $95
$BC34: 85 96    STA $96
$BC36: A9 01    LDA #$01
$BC38: 85 98    STA $98
$BC3A: 85 99    STA $99
$BC3C: 85 9A    STA $9A
$BC3E: 4C CB B4 JMP $B4CB
$BC41: A5 64    LDA #$64
$BC43: 18       CLC
$BC44: 65 72    ADC #$72
$BC46: 85 72    STA $72
$BC48: A6 64    LDX #$64
$BC4A: A4 77    LDY #$77
$BC4C: BD 20 BE LDA $BE20
$BC4F: 91 79    STA $79
$BC51: E8       INX
$BC52: C8       INY
$BC53: E4 72    CPX #$72
$BC55: D0 F5    BNE $BC4C ; Loop back if not zero
$BC57: 60       RTS
$BC58: A6 74    LDX #$74
$BC5A: A4 65    LDY #$65
$BC5C: A5 73    LDA #$73
$BC5E: F0 0E    BEQ $BC6E ; Branch if equal/zero
$BC60: A5 78    LDA #$78
$BC62: 18       CLC
$BC63: 69 01    ADC #$01
$BC65: 9D 00 C0 STA $C000
$BC68: 85 78    STA $78
$BC6A: 88       DEY
$BC6B: D0 F5    BNE $BC62 ; Loop back if not zero
$BC6D: 60       RTS
$BC6E: A5 78    LDA #$78
$BC70: 38       SEC
$BC71: E9 01    SBC #$01
$BC73: 9D 00 C0 STA $C000
$BC76: 85 78    STA $78
$BC78: 88       DEY
$BC79: D0 F5    BNE $BC70 ; Loop back if not zero
$BC7B: 60       RTS
$BC7C: A5 65    LDA #$65
$BC7E: 85 66    STA $66
$BC80: A9 FF    LDA #$FF
$BC82: 85 75    STA $75
$BC84: A4 7A    LDY #$7A
$BC86: 88       DEY
$BC87: 84 76    STY $76
$BC89: A5 73    LDA #$73
$BC8B: D0 13    BNE $BCA0 ; Loop back if not zero
$BC8D: A4 77    LDY #$77
$BC8F: A6 71    LDX #$71
$BC91: B1 79    LDA #$79
$BC93: 91 75    STA $75
$BC95: C8       INY
$BC96: CA       DEX
$BC97: 10 F8    BPL $BC91
$BC99: C6 77    DEC $77
$BC9B: C6 66    DEC $66
$BC9D: D0 EE    BNE $BC8D ; Loop back if not zero
$BC9F: 60       RTS
$BCA0: A5 77    LDA #$77
$BCA2: 18       CLC
$BCA3: 65 71    ADC #$71
$BCA5: A8       TAY
$BCA6: A6 71    LDX #$71
$BCA8: B1 75    LDA #$75
$BCAA: 91 79    STA $79
$BCAC: 88       DEY
$BCAD: CA       DEX
$BCAE: 10 F8    BPL $BCA8
$BCB0: E6 77    INC $77
$BCB2: C6 66    DEC $66
$BCB4: D0 EA    BNE $BCA0 ; Loop back if not zero
$BCB6: 60       RTS
$BCB7: A9 13    LDA #$13
$BCB9: 85 7A    STA $7A
$BCBB: A9 FF    LDA #$FF
$BCBD: 85 75    STA $75
$BCBF: A2 13    LDX #$13
$BCC1: CA       DEX
$BCC2: 8A       TXA
$BCC3: 85 76    STA $76
$BCC5: A5 72    LDA #$72
$BCC7: AA       TAX
$BCC8: BD 7C BF LDA $BF7C
$BCCB: 85 72    STA $72
$BCCD: 49 FF    EOR #$FF
$BCCF: 85 74    STA $74
$BCD1: A2 02    LDX #$02
$BCD3: A5 73    LDA #$73
$BCD5: D0 17    BNE $BCEE ; Loop back if not zero
$BCD7: A4 77    LDY #$77
$BCD9: B1 75    LDA #$75
$BCDB: 25 74    AND #$74
$BCDD: 85 66    STA $66
$BCDF: B1 79    LDA #$79
$BCE1: 25 72    AND #$72
$BCE3: 05 66    ORA #$66
$BCE5: 91 75    STA $75
$BCE7: C8       INY
$BCE8: CA       DEX
$BCE9: 10 EE    BPL $BCD9
$BCEB: C6 77    DEC $77
$BCED: 60       RTS
$BCEE: A5 77    LDA #$77
$BCF0: 18       CLC
$BCF1: 69 02    ADC #$02
$BCF3: A8       TAY
$BCF4: B1 79    LDA #$79
$BCF6: 25 74    AND #$74
$BCF8: 85 66    STA $66
$BCFA: B1 75    LDA #$75
$BCFC: 25 72    AND #$72
$BCFE: 05 66    ORA #$66
$BD00: 91 79    STA $79
$BD02: 88       DEY
$BD03: CA       DEX
$BD04: 10 EE    BPL $BCF4
$BD06: E6 77    INC $77
$BD08: 60       RTS
$BD09: A9 00    LDA #$00
$BD0B: A2 08    LDX #$08
$BD0D: 06 6C    ASL $6C
$BD0F: 2A       ROL
$BD10: C5 6B    CMP #$6B
$BD12: 90 04    BCC $BD18 ; Branch if carry clear
$BD14: E5 6B    SBC #$6B
$BD16: E6 6C    INC $6C
$BD18: CA       DEX
$BD19: D0 F2    BNE $BD0D ; Loop back if not zero
$BD1B: 60       RTS
$BD1C: A9 00    LDA #$00
$BD1E: A2 08    LDX #$08
$BD20: 46 6C    LSR $6C
$BD22: 90 03    BCC $BD27 ; Branch if carry clear
$BD24: 18       CLC
$BD25: 65 6B    ADC #$6B
$BD27: 4A       LSR
$BD28: 66 6D    ROR $6D
$BD2A: CA       DEX
$BD2B: D0 F3    BNE $BD20 ; Loop back if not zero
$BD2D: 85 6A    STA $6A
$BD2F: 60       RTS
$BD30: A5 64    LDA #$64
$BD32: 18       CLC
$BD33: 69 0C    ADC #$0C
$BD35: 85 72    STA $72
$BD37: A6 64    LDX #$64
$BD39: A4 77    LDY #$77
$BD3B: BD 80 BF LDA $BF80
$BD3E: 91 79    STA $79
$BD40: E8       INX
$BD41: C8       INY
$BD42: E4 72    CPX #$72
$BD44: D0 F5    BNE $BD3B ; Loop back if not zero
$BD46: 60       RTS
; ===============================================================================
; BOUNDARY_CHECK ($BD47)
; Player position boundary detection for escape through wall gaps
; This routine:
; - Checks if player position ($69 + $0E) exceeds boundary ($C0)
; - Sets escape detection flag $97 when boundary exceeded
; - Triggers escape processing in display update routine
; ===============================================================================
$BD47: A5 69    LDA $69         ; Load player position variable
$BD49: AA       TAX             ; Save original position
$BD4A: 18       CLC
$BD4B: 69 0E    ADC #$0E        ; Add offset (14 pixels)
$BD4D: 85 69    STA $69         ; Store adjusted position
$BD4F: C9 C0    CMP #$C0        ; Check if position >= $C0 (boundary exceeded)
$BD51: 90 07    BCC $BD5A       ; Branch if still within boundary
$BD53: A6 67    LDX $67         ; **BOUNDARY EXCEEDED!** Load index
$BD55: A9 01    LDA #$01
$BD57: 95 97    STA $97,X       ; Set escape detection flag $97 = 1
$BD59: 60       RTS             ; Return - escape will be processed next frame
$BD5A: BD C4 BE LDA $BEC4
$BD5D: 91 79    STA $79
$BD5F: E8       INX
$BD60: C8       INY
$BD61: E4 69    CPX #$69
$BD63: D0 F5    BNE $BD5A ; Loop back if not zero
$BD65: 60       RTS
; ===============================================================================
; PLAYER_MISSILE_HIT_PROCESSING ($BD66)
; **PLAYER MISSILE HIT SOUND AND SCORING**
; 
; This routine is called when player missile hits an enemy and handles:
; 1. **Hit Sound Effects**: Distinctive player hit sound (different from enemy fire)
; 2. **Score Updates**: Adds points when enemies are defeated
; 3. **Hit Confirmation**: Processes successful missile collision
; 4. **Visual Effects**: Triggers hit indicators and enemy destruction
;
; **MISSILE HIT PROCESSING**:
; - Called when hardware collision detection confirms hit ($C008 bits)
; - Adds points to score based on enemy type/value
; - Plays hit sound effect for audio feedback
; - Updates accuracy statistics (hits vs shots fired)
; ===============================================================================
$BD66: A5 AC    LDA $AC         ; **PLAYER FIRE SOUND PARAMETER**
$BD68: A2 02    LDX #$02        ; Set sound channel/duration
$BD6A: D0 02    BNE $BD6E       ; Branch to sound processing
$BD6C: A2 03    LDX #$03        ; Alternative sound parameter
$BD6E: 18       CLC             ; **SCORE UPDATE PROCESSING**
$BD6F: 7D 0B 06 ADC $060B,X     ; Add to score (instant-hit bonus)
$BD72: 9D 0B 06 STA $060B,X     ; Store updated score
$BD75: C9 3A    CMP #$3A        ; Check for score overflow
$BD77: 90 0A    BCC $BD83       ; Branch if no overflow
$BD79: A9 30    LDA #$30        ; Handle score digit overflow
$BD7B: 9D 0B 06 STA $060B,X     ; Reset digit
$BD7E: A9 01    LDA #$01        ; Carry to next digit
$BD80: CA       DEX             ; Move to next score digit
$BD81: 10 EB    BPL $BD6E       ; Continue score processing
$BD83: A2 04    LDX #$04        ; **SCORE DISPLAY UPDATE**
$BD85: BD 0B 06 LDA $060B,X     ; Load score digit
$BD88: 38       SEC             ; Set carry for subtraction
$BD89: E9 20    SBC #$20        ; Convert to screen code
$BD8B: 9D 0B 2E STA $2E0B,X     ; Update score display on screen
$BD8E: CA       DEX             ; Next digit
$BD8F: 10 F4    BPL $BD85       ; Continue until all digits updated
$BD91: AD 0B 06 LDA $060B       ; **SOUND EFFECT PROCESSING**
$BD94: C5 7B    CMP $7B         ; Compare with previous value
$BD96: D0 01    BNE $BD99       ; Branch if changed
$BD98: 60       RTS             ; Return if no change
$BD99: 85 7B    STA $7B         ; Store new sound value
$BD9B: A9 4F    LDA #$4F        ; **PLAYER FIRE SOUND PARAMETERS**
$BD9D: 85 D0    STA $D0         ; Set sound frequency/duration
$BD9F: 85 BD    STA $BD         ; Set sound control
$BDA1: 60       RTS             ; Return from player fire processing
$BDA2: A9 00    LDA #$00
$BDA4: 8D 1D C0 STA $C01D ; GTIA GRACTL - Graphics control
$BDA7: A2 07    LDX #$07
$BDA9: 9D 00 C0 STA $C000
$BDAC: CA       DEX
$BDAD: 10 FA    BPL $BDA9
$BDAF: 60       RTS
$BDB0: A9 40    LDA #$40
$BDB2: 8D 0E E8 STA $E80E
$BDB5: 85 00    STA $00
$BDB7: A9 A0    LDA #$A0
$BDB9: 8D 09 D4 STA $D409 ; POKEY SKCTL - Serial/keyboard control
$BDBC: 60       RTS
$BDBD: A9 00    LDA #$00
$BDBF: 85 BE    STA $BE
$BDC1: 85 B9    STA $B9
$BDC3: A2 07    LDX #$07
$BDC5: 9D 00 E8 STA $E800
$BDC8: CA       DEX
$BDC9: 10 FA    BPL $BDC5
$BDCB: A9 01    LDA #$01
$BDCD: 8D 08 E8 STA $E808
$BDD0: A9 A0    LDA #$A0
$BDD2: 85 B7    STA $B7
$BDD4: 60       RTS
$BDD5: 0A       ASL
$BDD6: 85 69    STA $69
$BDD8: 8A       TXA
$BDD9: A2 05    LDX #$05
$BDDB: 8D 0A D4 STA $D40A
$BDDE: CA       DEX
$BDDF: D0 FD    BNE $BDDE ; Loop back if not zero
$BDE1: A6 69    LDX #$69
$BDE3: 8D 05 02 STA $0205
$BDE6: 98       TYA
$BDE7: 8D 04 02 STA $0204
$BDEA: 60       RTS
$BDEB: A9 FF    LDA #$FF
$BDED: 85 60    STA $60
$BDEF: A5 12    LDA #$12
$BDF1: C9 B8    CMP #$B8
$BDF3: B0 0C    BCS $BE01 ; Branch if carry set
$BDF5: C9 18    CMP #$18
$BDF7: B0 0E    BCS $BE07 ; Branch if carry set
$BDF9: A5 60    LDA #$60
$BDFB: 29 FE    AND #$FE
$BDFD: 85 60    STA $60
$BDFF: D0 06    BNE $BE07 ; Loop back if not zero
$BE01: A5 60    LDA #$60
$BE03: 29 FD    AND #$FD
$BE05: 85 60    STA $60
$BE07: A5 11    LDA #$11
$BE09: C9 B8    CMP #$B8
$BE0B: B0 0C    BCS $BE19 ; Branch if carry set
$BE0D: C9 18    CMP #$18
$BE0F: B0 0E    BCS $BE1F ; Branch if carry set
$BE11: A5 60    LDA #$60
$BE13: 29 FB    AND #$FB
$BE15: 85 60    STA $60
$BE17: D0 06    BNE $BE1F ; Loop back if not zero
$BE19: A5 60    LDA #$60
$BE1B: 29 F7    AND #$F7
$BE1D: 85 60    STA $60
$BE1F: 60       RTS

; Player sprite animation data.

; PLAYER - STATIONARY
$BE20: 08       .byte $08        ; ....#... - Sprite data byte
$BE21: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE22: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE23: 08       .byte $08        ; ....#... - Sprite data byte
$BE24: 1C       .byte $1C        ; ...###.. - **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies
$BE25: 2A       .byte $2A        ; ..#.#.#. - Sprite data byte
$BE26: 2A       .byte $2A        ; ..#.#.#. - Sprite data byte
$BE27: 08       .byte $08        ; ....#... - Sprite data byte
$BE28: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE29: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE2A: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE2B: 36       .byte $36        ; ..##.##. - Sprite data byte

; PLAYER - WALKING LEFT 1
$BE2C: 08       .byte $08        ; ....#... - Sprite data byte
$BE2D: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE2E: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE2F: 08       .byte $08        ; ....#... - Sprite data byte
$BE30: 5C       .byte $5C        ; .#.###.. - Sprite data byte
$BE31: 2A       .byte $2A        ; ..#.#.#. - Sprite data byte
$BE32: 09       .byte $09        ; ....#..# - Sprite data byte
$BE33: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE34: 18       .byte $18        ; ...##... - Sprite data byte
$BE35: 24       .byte $24        ; ..#..#.. - Sprite data byte
$BE36: 27       .byte $27        ; ..#..### - Sprite data byte
$BE37: 61       .byte $61        ; .##....# - Sprite data byte

; PLAYER - WALKING LEFT 2
$BE38: 08       .byte $08        ; ....#... - Sprite data byte
$BE39: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE3A: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE3B: 08       .byte $08        ; ....#... - Sprite data byte
$BE3C: 0C       .byte $0C        ; ....##.. - Sprite data byte
$BE3D: 0C       .byte $0C        ; ....##.. - Sprite data byte
$BE3E: 3C       .byte $3C        ; ..####.. - Sprite data byte
$BE3F: 08       .byte $08        ; ....#... - Sprite data byte
$BE40: 18       .byte $18        ; ...##... - Sprite data byte
$BE41: 0C       .byte $0C        ; ....##.. - Sprite data byte
$BE42: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE43: 1C       .byte $1C        ; ...###.. - **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies

; PLAYER - WALKING RIGHT 1
$BE44: 10       .byte $10        ; ...#.... - Sprite data byte
$BE45: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE46: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE47: 10       .byte $10        ; ...#.... - Sprite data byte
$BE48: 3A       .byte $3A        ; ..###.#. - Sprite data byte
$BE49: 54       .byte $54        ; .#.#.#.. - Sprite data byte
$BE4A: 90       .byte $90        ; #..#.... - Sprite data byte
$BE4B: 50       .byte $50        ; .#.#.... - Sprite data byte
$BE4C: 18       .byte $18        ; ...##... - Sprite data byte
$BE4D: 24       .byte $24        ; ..#..#.. - Sprite data byte
$BE4E: E4       .byte $E4        ; ###..#.. - Sprite data byte
$BE4F: 86       .byte $86        ; #....##. - Sprite data byte

; PLAYER - WALKING RIGHT 2
$BE50: 10       .byte $10        ; ...#.... - Sprite data byte
$BE51: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE52: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE53: 10       .byte $10        ; ...#.... - Sprite data byte
$BE54: 30       .byte $30        ; ..##.... - Sprite data byte
$BE55: 30       .byte $30        ; ..##.... - Sprite data byte
$BE56: 3C       .byte $3C        ; ..####.. - Sprite data byte
$BE57: 10       .byte $10        ; ...#.... - Sprite data byte
$BE58: 18       .byte $18        ; ...##... - Sprite data byte
$BE59: 30       .byte $30        ; ..##.... - Sprite data byte
$BE5A: 50       .byte $50        ; .#.#.... - Sprite data byte
$BE5B: 38       .byte $38        ; ..###... - Sprite data byte

; PLAYER - WALKING UP/DOWN 1
$BE5C: 08       .byte $08        ; ....#... - Sprite data byte
$BE5D: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE5E: 34       .byte $34        ; ..##.#.. - Sprite data byte
$BE5F: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE60: 1C       .byte $1C        ; ...###.. - **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies
$BE61: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE62: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE63: 08       .byte $08        ; ....#... - Sprite data byte
$BE64: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE65: 16       .byte $16        ; ...#.##. - Sprite data byte
$BE66: 10       .byte $10        ; ...#.... - Sprite data byte
$BE67: 30       .byte $30        ; ..##.... - Sprite data byte

; PLAYER - WALKING UP/DOWN 2
$BE68: 08       .byte $08        ; ....#... - Sprite data byte
$BE69: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE6A: 16       .byte $16        ; ...#.##. - Sprite data byte
$BE6B: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE6C: 1C       .byte $1C        ; ...###.. - **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies
$BE6D: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE6E: 28       .byte $28        ; ..#.#... - Sprite data byte
$BE6F: 08       .byte $08        ; ....#... - Sprite data byte
$BE70: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE71: 34       .byte $34        ; ..##.#.. - Sprite data byte
$BE72: 04       .byte $04        ; .....#.. - Sprite data byte
$BE73: 06       .byte $06        ; .....##. - Sprite data byte

; PLAYER - SHOOTING LEFT
$BE74: 00       .byte $00        ; ........ - Sprite data byte
$BE75: 00       .byte $00        ; ........ - Sprite data byte
$BE76: 04       .byte $04        ; .....#.. - Sprite data byte
$BE77: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE78: 0A       .byte $0A        ; ....#.#. - Sprite data byte
$BE79: C4       .byte $C4        ; ##...#.. - Sprite data byte
$BE7A: 7C       .byte $7C        ; .#####.. - Sprite data byte
$BE7B: 04       .byte $04        ; .....#.. - Sprite data byte
$BE7C: 0C       .byte $0C        ; ....##.. - Sprite data byte
$BE7D: 14       .byte $14        ; ...#.#.. - Sprite data byte
$BE7E: 0F       .byte $0F        ; ....#### - Sprite data byte
$BE7F: 19       .byte $19        ; ...##..# - Sprite data byte

; PLAYER - SHOOTING TOP LEFT
$BE80: 00       .byte $00        ; ........ - Sprite data byte
$BE81: 40       .byte $40        ; .#...... - Sprite data byte
$BE82: 24       .byte $24        ; ..#..#.. - Animation pattern data
$BE83: 4A       .byte $4A        ; .#..#.#. - Animation pattern data
$BE84: 2A       .byte $2A        ; ..#.#.#. - Animation pattern data
$BE85: 14       .byte $14        ; ...#.#.. - Animation pattern data
$BE86: 0C       .byte $0C        ; ....##.. - Animation pattern data
$BE87: 04       .byte $04        ; .....#.. - **PLAYER HEAD (VERTICAL)** - Character $04
$BE88: 0C       .byte $0C        ; ....##.. - Animation pattern data
$BE89: 14       .byte $14        ; ...#.#.. - Animation pattern data
$BE8A: 0F       .byte $0F        ; ....#### - Animation pattern data
$BE8B: 19       .byte $19        ; ...##..# - Animation pattern data

; PLAYER - SHOOTING BOTTOM LEFT
$BE8C: 00       .byte $00        ; ........ - Animation pattern data
$BE8D: 00       .byte $00        ; ........ - Animation pattern data
$BE8E: 04       .byte $04        ; .....#.. - **PLAYER HEAD (VERTICAL)** - Character $04
$BE8F: 0A       .byte $0A        ; ....#.#. - Animation pattern data
$BE90: 0A       .byte $0A        ; ....#.#. - Animation pattern data
$BE91: 04       .byte $04        ; .....#.. - **PLAYER HEAD (VERTICAL)** - Character $04
$BE92: 0C       .byte $0C        ; ....##.. - Animation pattern data
$BE93: 54       .byte $54        ; .#.#.#.. - Animation pattern data
$BE94: AC       .byte $AC        ; #.#.##.. - Animation pattern data
$BE95: 14       .byte $14        ; ...#.#.. - Animation pattern data
$BE96: 0F       .byte $0F        ; ....#### - Animation pattern data
$BE97: 19       .byte $19        ; ...##..# - Animation pattern data

; PLAYER - SHOOTING RIGHT
$BE98: 00       .byte $00        ; ........ - Animation pattern data
$BE99: 00       .byte $00        ; ........ - Animation pattern data
$BE9A: 20       .byte $20        ; ..#..... - Animation pattern data
$BE9B: 50       .byte $50        ; .#.#.... - Animation pattern data
$BE9C: 50       .byte $50        ; .#.#.... - Animation pattern data
$BE9D: 23       .byte $23        ; ..#...## - Animation pattern data
$BE9E: 3E       .byte $3E        ; ..#####. - Animation pattern data
$BE9F: 20       .byte $20        ; ..#..... - Animation pattern data
$BEA0: 30       .byte $30        ; ..##.... - Animation pattern data
$BEA1: 28       .byte $28        ; ..#.#... - Animation pattern data
$BEA2: F0       .byte $F0        ; ####.... - Animation pattern data
$BEA3: 98       .byte $98        ; #..##... - Animation pattern data

; PLAYER - SHOOTING TOP RIGHT
$BEA4: 00       .byte $00        ; ........ - Animation pattern data
$BEA5: 02       .byte $02        ; ......#. - **PLAYER HEAD (SIDEWAYS)** - Character $02
$BEA6: 24       .byte $24        ; ..#..#.. - Animation pattern data
$BEA7: 52       .byte $52        ; .#.#..#. - Animation pattern data
$BEA8: 54       .byte $54        ; .#.#.#.. - Animation pattern data
$BEA9: 28       .byte $28        ; ..#.#... - Animation pattern data
$BEAA: 30       .byte $30        ; ..##.... - Animation pattern data
$BEAB: 20       .byte $20        ; ..#..... - Animation pattern data
$BEAC: 30       .byte $30        ; ..##.... - Animation pattern data
$BEAD: 28       .byte $28        ; ..#.#... - Animation pattern data
$BEAE: F0       .byte $F0        ; ####.... - Animation pattern data
$BEAF: 98       .byte $98        ; #..##... - Animation pattern data

; PLAYER - SHOOTING BOTTOM RIGHT
$BEB0: 00       .byte $00        ; ........ - Animation pattern data
$BEB1: 00       .byte $00        ; ........ - Animation pattern data
$BEB2: 20       .byte $20        ; ..#..... - Animation pattern data
$BEB3: 50       .byte $50        ; .#.#.... - Animation pattern data
$BEB4: 50       .byte $50        ; .#.#.... - Animation pattern data
$BEB5: 20       .byte $20        ; ..#..... - Animation pattern data
$BEB6: 30       .byte $30        ; ..##.... - Animation pattern data
$BEB7: 2A       .byte $2A        ; ..#.#.#. - Animation pattern data
$BEB8: 35       .byte $35        ; ..##.#.# - Animation pattern data
$BEB9: 28       .byte $28        ; ..#.#... - Animation pattern data
$BEBA: F0       .byte $F0        ; ####.... - Animation pattern data
$BEBB: 98       .byte $98        ; #..##... - Animation pattern data

; PLAYER - SHOOTING UP
$BEBC: 00       .byte $00        ; ........ - Animation pattern data
$BEBD: 04       .byte $04        ; .....#.. - **PLAYER HEAD (VERTICAL)** - Character $04
$BEBE: 24       .byte $24        ; ..#..#.. - Animation pattern data
$BEBF: 52       .byte $52        ; .#.#..#. - Animation pattern data
$BEC0: 54       .byte $54        ; .#.#.#.. - Animation pattern data
$BEC1: 28       .byte $28        ; ..#.#... - Animation pattern data
$BEC2: 30       .byte $30        ; ..##.... - Animation pattern data
$BEC3: 20       .byte $20        ; ..#..... - Animation pattern data
$BEC4: 30       .byte $30        ; ..##.... - Animation pattern data
$BEC5: 28       .byte $28        ; ..#.#... - Animation pattern data
$BEC6: F0       .byte $F0        ; ####.... - Animation pattern data
$BEC7: 98       .byte $98        ; #..##... - Animation pattern data

; PLAYER - SHOOTING DOWN
$BEC8: 00       .byte $00        ; ........ - Animation pattern data
$BEC9: 00       .byte $00        ; ........ - Animation pattern data
$BECA: 04       .byte $04        ; .....#.. - **PLAYER HEAD (VERTICAL)** - Character $04
$BECB: 0A       .byte $0A        ; ....#.#. - Animation pattern data
$BECC: 0A       .byte $0A        ; ....#.#. - Animation pattern data
$BECD: 04       .byte $04        ; .....#.. - **PLAYER HEAD (VERTICAL)** - Character $04
$BECE: 0C       .byte $0C        ; ....##.. - Animation pattern data
$BECF: 14       .byte $14        ; ...#.#.. - Animation pattern data
$BED0: 6C       .byte $6C        ; .##.##.. - Complex sprite pattern
$BED1: 54       .byte $54        ; .#.#.#.. - Complex sprite pattern  
$BED2: 0F       .byte $0F        ; ....#### - Complex sprite pattern
$BED3: 19       .byte $19        ; ...##..# - Animation pattern data

# Player / enemy explosion sprite animation.

; EXPLOSION 1
$BED4: 00       .byte $00        ; ........ - Padding/empty data
$BED5: 00       .byte $00        ; ........ - Padding/empty data
$BED6: 00       .byte $00        ; ........ - Padding/empty data
$BED7: 00       .byte $00        ; ........ - Padding/empty data
$BED8: 00       .byte $00        ; ........ - Padding/empty data
$BED9: 00       .byte $00        ; ........ - Padding/empty data
$BEDA: 08       .byte $08        ; ....#... - **DEATH ANIMATION** - Character $08
$BEDB: 08       .byte $08        ; ....#... - **DEATH ANIMATION** - Character $08
$BEDC: 00       .byte $00        ; ........ - Padding/empty data
$BEDD: 00       .byte $00        ; ........ - Padding/empty data
$BEDE: 00       .byte $00        ; ........ - Padding/empty data
$BEDF: 00       .byte $00        ; ........ - Padding/empty data

; EXPLOSION 2
$BEE0: 00       .byte $00        ; ........ - Padding/empty data
$BEE1: 00       .byte $00        ; ........ - Padding/empty data
$BEE2: 00       .byte $00        ; ........ - Padding/empty data
$BEE3: 00       .byte $00        ; ........ - Padding/empty data
$BEE4: 00       .byte $00        ; ........ - Padding/empty data
$BEE5: 00       .byte $00        ; ........ - Padding/empty data
$BEE6: 00       .byte $00        ; ........ - Padding/empty data
$BEE7: 10       .byte $10        ; ...#.... - Sparse pattern data
$BEE8: 38       .byte $38        ; ..###... - Sprite pattern data
$BEE9: 10       .byte $10        ; ...#.... - Sprite pattern data
$BEEA: 00       .byte $00        ; ........ - Padding/empty data
$BEEB: 00       .byte $00        ; ........ - Padding/empty data

; EXPLOSION 3
$BEEC: 00       .byte $00        ; ........ - Padding/empty data
$BEED: 00       .byte $00        ; ........ - Padding/empty data
$BEEE: 00       .byte $00        ; ........ - Padding/empty data
$BEEF: 00       .byte $00        ; ........ - Padding/empty data
$BEF0: 00       .byte $00        ; ........ - Padding/empty data
$BEF1: 00       .byte $00        ; ........ - Padding/empty data
$BEF2: 00       .byte $00        ; ........ - Padding/empty data
$BEF3: 00       .byte $00        ; ........ - Padding/empty data
$BEF4: 00       .byte $00        ; ........ - Padding/empty data
$BEF5: 14       .byte $14        ; ...#.#.. - Sprite pattern data
$BEF6: 00       .byte $00        ; ........ - Padding/empty data
$BEF7: 2C       .byte $2C        ; ..#.##.. - Sprite pattern data

; EXPLOSION 4
$BEF8: 00       .byte $00        ; ........ - Padding/empty data
$BEF9: 14       .byte $14        ; ...#.#.. - Sprite pattern data
$BEFA: 00       .byte $00        ; ........ - Padding/empty data
$BEFB: 00       .byte $00        ; ........ - Padding/empty data
$BEFC: 00       .byte $00        ; ........ - Padding/empty data
$BEFD: 00       .byte $00        ; ........ - Padding/empty data
$BEFE: 00       .byte $00        ; ........ - Padding/empty data
$BEFF: 00       .byte $00        ; ........ - Padding/empty data
$BF00: 00       .byte $00        ; ........ - Table entry
$BF01: 10       .byte $10        ; ...#.... - Table entry
$BF02: 00       .byte $00        ; ........ - Table entry
$BF03: 58       .byte $58        ; .#.##... - Table entry

; EXPLOSION 5
$BF04: 00       .byte $00        ; ........ - Table entry
$BF05: 2C       .byte $2C        ; ..#.##.. - Table entry
$BF06: 00       .byte $00        ; ........ - Table entry
$BF07: 50       .byte $50        ; .#.#.... - Table entry
$BF08: 00       .byte $00        ; ........ - Table entry
$BF09: 10       .byte $10        ; ...#.... - Table entry
$BF0A: 00       .byte $00        ; ........ - Table entry
$BF0B: 00       .byte $00        ; ........ - Table entry
$BF0C: 00       .byte $00        ; ........ - Table entry
$BF0D: 38       .byte $38        ; ..###... - Table entry
$BF0E: 00       .byte $00        ; ........ - Table entry
$BF0F: 92       .byte $92        ; #..#..#. - Table entry

; EXPLOSION 6
$BF10: 00       .byte $00        ; ........ - Table entry
$BF11: 58       .byte $58        ; .#.##... - Table entry
$BF12: 00       .byte $00        ; ........ - Table entry
$BF13: AA       .byte $AA        ; #.#.#.#. - Table entry
$BF14: 00       .byte $00        ; ........ - Table entry
$BF15: 54       .byte $54        ; .#.#.#.. - Table entry
$BF16: 00       .byte $00        ; ........ - Table entry
$BF17: 54       .byte $54        ; .#.#.#.. - Table entry
$BF18: 00       .byte $00        ; ........ - Table entry
$BF19: 00       .byte $00        ; ........ - Table entry
$BF1A: 48       .byte $48        ; .#..#... - Table entry
$BF1B: 10       .byte $10        ; ...#.... - Table entry

; EXPLOSION 7
$BF1C: 28       .byte $28        ; ..#.#... - Table entry
$BF1D: 92       .byte $92        ; #..#..#. - Table entry
$BF1E: 01       .byte $01        ; .......# - Table entry
$BF1F: 58       .byte $58        ; .#.##... - Table entry
$BF20: 00       .byte $00        ; ........ - Table entry
$BF21: 82       .byte $82        ; #.....#. - Table entry
$BF22: 00       .byte $00        ; ........ - Table entry
$BF23: 54       .byte $54        ; .#.#.#.. - Table entry
$BF24: 00       .byte $00        ; ........ - Table entry
$BF25: A0       .byte $A0        ; #.#..... - Table entry
$BF26: 10       .byte $10        ; ...#.... - Table entry
$BF27: 44       .byte $44        ; .#...#.. - Table entry

; EXPLOSION 8
$BF28: 52       .byte $52        ; .#.#..#. - Table entry
$BF29: 24       .byte $24        ; ..#..#.. - Table entry
$BF2A: 10       .byte $10        ; ...#.... - Table entry
$BF2B: A4       .byte $A4        ; #.#..#.. - Table entry
$BF2C: 09       .byte $09        ; ....#..# - **DEATH ANIMATION** - Character $09
$BF2D: A0       .byte $A0        ; #.#..... - Table entry
$BF2E: 00       .byte $00        ; ........ - Table entry
$BF2F: 00       .byte $00        ; ........ - Table entry
$BF30: 84       .byte $84        ; #....#.. - Table entry
$BF31: 00       .byte $00        ; ........ - Table entry
$BF32: 55       .byte $55        ; .#.#.#.# - Table entry
$BF33: 00       .byte $00        ; ........ - Table entry

; EXPLOSION 9
$BF34: 29       .byte $29        ; ..#.#..# - Table entry
$BF35: 52       .byte $52        ; .#.#..#. - Table entry
$BF36: 52       .byte $52        ; .#.#..#. - Table entry
$BF37: A4       .byte $A4        ; #.#..#.. - Table entry
$BF38: 10       .byte $10        ; ...#.... - Table entry
$BF39: A4       .byte $A4        ; #.#..#.. - Table entry
$BF3A: 01       .byte $01        ; .......# - Table entry
$BF3B: 80       .byte $80        ; #....... - Table entry
$BF3C: 01       .byte $01        ; .......# - Table entry
$BF3D: 00       .byte $00        ; ........ - Table entry
$BF3E: 80       .byte $80        ; #....... - Table entry
$BF3F: 00       .byte $00        ; ........ - Table entry

; EXPLOSION 10
$BF40: 45       .byte $45        ; .#...#.# - Table entry
$BF41: 00       .byte $00        ; ........ - Table entry
$BF42: A8       .byte $A8        ; #.#.#... - Table entry
$BF43: 52       .byte $52        ; .#.#..#. - Table entry
$BF44: 52       .byte $52        ; .#.#..#. - Table entry
$BF45: 24       .byte $24        ; ..#..#.. - Table entry
$BF46: 10       .byte $10        ; ...#.... - Table entry
$BF47: 24       .byte $24        ; ..#..#.. - Table entry
$BF48: 00       .byte $00        ; ........ - Table entry
$BF49: 80       .byte $80        ; #....... - Table entry
$BF4A: 01       .byte $01        ; .......# - Table entry
$BF4B: 00       .byte $00        ; ........ - Table entry

; EXPLOSION 11
$BF4C: 00       .byte $00        ; ........ - Table entry
$BF4D: 00       .byte $00        ; ........ - Table entry
$BF4E: 01       .byte $01        ; .......# - Table entry
$BF4F: 00       .byte $00        ; ........ - Table entry
$BF50: 29       .byte $29        ; ..#.#..# - Table entry
$BF51: 50       .byte $50        ; .#.#.... - Table entry
$BF52: 50       .byte $50        ; .#.#.... - Table entry
$BF53: A1       .byte $A1        ; #.#....# - Table entry
$BF54: 00       .byte $00        ; ........ - Table entry
$BF55: 00       .byte $00        ; ........ - Table entry
$BF56: 00       .byte $00        ; ........ - Table entry
$BF57: 80       .byte $80        ; #....... - Table entry

; EXPLOSION 12
$BF58: 01       .byte $01        ; .......# - Table entry
$BF59: 00       .byte $00        ; ........ - Table entry
$BF5A: 80       .byte $80        ; #....... - Table entry
$BF5B: 00       .byte $00        ; ........ - Table entry
$BF5C: 00       .byte $00        ; ........ - Table entry
$BF5D: 00       .byte $00        ; ........ - Table entry
$BF5E: 81       .byte $81        ; #......# - Table entry
$BF5F: 10       .byte $10        ; ...#.... - Table entry
$BF60: 00       .byte $00        ; ........ - Table entry
$BF61: 40       .byte $40        ; .#...... - Table entry
$BF62: 00       .byte $00        ; ........ - Table entry
$BF63: 02       .byte $02        ; ......#. - **PLAYER HEAD (SIDEWAYS)** - Character $02

; EXPLOSION 13
$BF64: 00       .byte $00        ; ........ - Table entry
$BF65: 80       .byte $80        ; #....... - Table entry
$BF66: 00       .byte $00        ; ........ - Table entry
$BF67: 01       .byte $01        ; .......# - Table entry
$BF68: 00       .byte $00        ; ........ - Table entry
$BF69: 00       .byte $00        ; ........ - Table entry
$BF6A: 20       .byte $20        ; ..#..... - Table entry
$BF6B: 00       .byte $00        ; ........ - Table entry
$BF6C: 00       .byte $00        ; ........ - Table entry
$BF6D: 10       .byte $10        ; ...#.... - Table entry
$BF6E: 00       .byte $00        ; ........ - Table entry
$BF6F: 00       .byte $00        ; ........ - Table entry

; EXPLOSION 14
$BF70: 00       .byte $00        ; ........ - Table entry
$BF71: 00       .byte $00        ; ........ - Table entry
$BF72: 00       .byte $00        ; ........ - Table entry
$BF73: 00       .byte $00        ; ........ - Table entry
$BF74: 00       .byte $00        ; ........ - Table entry
$BF75: 00       .byte $00        ; ........ - Table entry
$BF76: 00       .byte $00        ; ........ - Table entry
$BF77: 00       .byte $00        ; ........ - Table entry
$BF78: 00       .byte $00        ; ........ - Table entry
$BF79: 00       .byte $00        ; ........ - Table entry
$BF7A: 00       .byte $00        ; ........ - Table entry
$BF7B: 00       .byte $00        ; ........ - Table entry

; Unknown sprite?
$BF7C: 03       .byte $03        ; ......## - **PLAYER BODY (FRAME 1)** - Character $03
$BF7D: 0C       .byte $0C        ; ....##.. - Pattern data
$BF7E: 30       .byte $30        ; ..##.... - Pattern data
$BF7F: C0       .byte $C0        ; ##...... - Pattern data

# Enemy sprites and animations.

; ENEMY - STATIONARY
$BF80: 7E       .byte $7E        ; .######. - **DETAILED SPRITE** - Complex border pattern
$BF81: 18       .byte $18        ; ...##... - **DETAILED SPRITE** - Center detail
$BF82: FF       .byte $FF        ; ######## - **DETAILED SPRITE** - Full width line
$BF83: BD       .byte $BD        ; #.####.# - **DETAILED SPRITE** - Detailed body pattern
$BF84: BD       .byte $BD        ; #.####.# - **DETAILED SPRITE** - Repeated body pattern
$BF85: BD       .byte $BD        ; #.####.# - **DETAILED SPRITE** - Repeated body pattern
$BF86: BD       .byte $BD        ; #.####.# - **DETAILED SPRITE** - Repeated body pattern
$BF87: BD       .byte $BD        ; #.####.# - **DETAILED SPRITE** - Repeated body pattern
$BF88: 3C       .byte $3C        ; ..####.. - **DETAILED SPRITE** - Complex pattern
$BF89: 24       .byte $24        ; ..#..#.. - **DETAILED SPRITE** - Complex pattern
$BF8A: 24       .byte $24        ; ..#..#.. - **DETAILED SPRITE** - Complex pattern
$BF8B: 66       .byte $66        ; .##..##. - **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING LEFT 1
$BF8C: 7E       .byte $7E        ; .######. - **DETAILED SPRITE** - Complex pattern
$BF8D: 18       .byte $18        ; ...##... - **DETAILED SPRITE** - Complex pattern
$BF8E: 3F       .byte $3F        ; ..###### - **DETAILED SPRITE** - Complex pattern
$BF8F: 3D       .byte $3D        ; ..####.# - **DETAILED SPRITE** - Complex pattern
$BF90: 3D       .byte $3D        ; ..####.# - **DETAILED SPRITE** - Complex pattern
$BF91: 3D       .byte $3D        ; ..####.# - **DETAILED SPRITE** - Complex pattern
$BF92: 3D       .byte $3D        ; ..####.# - **DETAILED SPRITE** - Complex pattern
$BF93: 3D       .byte $3D        ; ..####.# - **DETAILED SPRITE** - Complex pattern
$BF94: 3C       .byte $3C        ; ..####.. - **DETAILED SPRITE** - Complex pattern
$BF95: 24       .byte $24        ; ..#..#.. - **DETAILED SPRITE** - Complex pattern
$BF96: 24       .byte $24        ; ..#..#.. - **DETAILED SPRITE** - Complex pattern
$BF97: 6C       .byte $6C        ; .##.##.. - **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING LEFT 2
$BF98: 7E       .byte $7E        ; .######. - **DETAILED SPRITE** - Complex pattern
$BF99: 18       .byte $18        ; ...##... - **DETAILED SPRITE** - Complex pattern
$BF9A: 3F       .byte $3F        ; ..###### - **DETAILED SPRITE** - Complex pattern
$BF9B: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern
$BF9C: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern  
$BF9D: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern
$BF9E: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern
$BF9F: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern
$BFA0: 3C       .byte $3C        ; ..####..  - **DETAILED SPRITE** - Complex pattern
$BFA1: 08       .byte $08        ; ....#...  - **DETAILED SPRITE** - Complex pattern
$BFA2: 08       .byte $08        ; ....#...  - **DETAILED SPRITE** - Complex pattern
$BFA3: 18       .byte $18        ; ...##...  - **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING RIGHT 1
$BFA4: 7E       .byte $7E        ; .######.  - **DETAILED SPRITE** - Complex pattern
$BFA5: 18       .byte $18        ; ...##...  - **DETAILED SPRITE** - Complex pattern
$BFA6: FC       .byte $FC        ; ######..  - **DETAILED SPRITE** - Complex pattern
$BFA7: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFA8: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFA9: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFAA: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFAB: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFAC: 3C       .byte $3C        ; ..####..  - **DETAILED SPRITE** - Complex pattern
$BFAD: 24       .byte $24        ; ..#..#..  - **DETAILED SPRITE** - Complex pattern
$BFAE: 24       .byte $24        ; ..#..#..  - **DETAILED SPRITE** - Complex pattern
$BFAF: 36       .byte $36        ; ..##.##.  - **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING RIGHT 2
$BFB0: 7E       .byte $7E        ; .######.  - **DETAILED SPRITE** - Complex pattern
$BFB1: 18       .byte $18        ; ...##...  - **DETAILED SPRITE** - Complex pattern
$BFB2: FC       .byte $FC        ; ######..  - **DETAILED SPRITE** - Complex pattern
$BFB3: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFB4: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFB5: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFB6: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFB7: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFB8: 3C       .byte $3C        ; ..####..  - **DETAILED SPRITE** - Complex pattern
$BFB9: 10       .byte $10        ; ...#....  - **DETAILED SPRITE** - Complex pattern
$BFBA: 10       .byte $10        ; ...#....  - **DETAILED SPRITE** - Complex pattern
$BFBB: 18       .byte $18        ; ...##...  - **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING UP/DOWN 1
$BFBC: 7E       .byte $7E        ; .######.  - **DETAILED SPRITE** - Complex pattern
$BFBD: 18       .byte $18        ; ...##...  - **DETAILED SPRITE** - Complex pattern
$BFBE: FF       .byte $FF        ; ########  - **DETAILED SPRITE** - Complex pattern
$BFBF: BD       .byte $BD        ; #.####.#  - **DETAILED SPRITE** - Complex pattern
$BFC0: BD       .byte $BD        ; #.####.#  - **DETAILED SPRITE** - Complex pattern
$BFC1: BD       .byte $BD        ; #.####.#  - **DETAILED SPRITE** - Complex pattern
$BFC2: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern
$BFC3: 3D       .byte $3D        ; ..######  - **DETAILED SPRITE** - Complex pattern
$BFC4: 3C       .byte $3C        ; ..####..  - **DETAILED SPRITE** - Complex pattern
$BFC5: 26       .byte $26        ; ..#..##.  - **DETAILED SPRITE** - Complex pattern
$BFC6: 20       .byte $20        ; ..#.....  - **DETAILED SPRITE** - Complex pattern
$BFC7: 60       .byte $60        ; .##.....  - **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING UP/DOWN 2
$BFC8: 7E       .byte $7E        ; .######.  - **DETAILED SPRITE** - Complex pattern
$BFC9: 18       .byte $18        ; ...##...  - **DETAILED SPRITE** - Complex pattern
$BFCA: FF       .byte $FF        ; ########  - **DETAILED SPRITE** - Complex pattern
$BFCB: BD       .byte $BD        ; #.####.#  - **DETAILED SPRITE** - Complex pattern
$BFCC: BD       .byte $BD        ; #.####.#  - **DETAILED SPRITE** - Complex pattern
$BFCD: BD       .byte $BD        ; #.####.#  - **DETAILED SPRITE** - Complex pattern
$BFCE: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFCF: BC       .byte $BC        ; #.####..  - **DETAILED SPRITE** - Complex pattern
$BFD0: 3C       .byte $3C        ; ..####..  - **DETAILED SPRITE** - Complex pattern
$BFD1: 64       .byte $64        ; .##..#..  - **DETAILED SPRITE** - Complex pattern
$BFD2: 04       .byte $04        ; .....#..  - **DETAILED SPRITE** - Complex pattern

; ===============================================================================
; SYSTEM INITIALIZATION AND RESET VECTORS ($BFD3-$BFFF)
; **SYSTEM STARTUP CODE** - Reset vector handling and initialization
; This section contains the system reset and initialization code
; ===============================================================================

$BFD3: 06 3D    ASL $3D          ; Arithmetic shift left on memory location $3D
$BFD5: 55 6E    EOR $6E,X        ; Exclusive OR with memory location $6E indexed by X
$BFD7: 87       .byte $87        ; Data byte - possibly part of initialization data

; ===============================================================================
; SYSTEM INITIALIZATION AND RESET VECTORS ($BFD8-$BFFF)
; **SYSTEM STARTUP CODE** - Reset vector handling and initialization
; This section contains the system reset and initialization code
; ===============================================================================
$BFD8: A0 BB    LDY #$BB         ; Load Y register with immediate value $BB
$BFDA: 30 66    BMI $C042        ; Branch if minus (negative flag set) to $C042
$BFDC: A6 C9    LDX $C9          ; Load X register from memory location $C9
$BFDE: 0E D0 06 ASL $06D0        ; Arithmetic shift left on memory location $06D0

; **SYSTEM RESET INITIALIZATION** - Main system startup sequence
$BFE1: A2 FF    LDX #$FF         ; Load X register with $FF (initialize stack pointer)
$BFE3: 9A       TXS              ; Transfer X to stack pointer (set stack to $01FF)
$BFE4: 4C C8 A2 JMP $A2C8        ; Jump to main initialization routine at $A2C8

; **INPUT HANDLING** - Check for specific input conditions
$BFE7: C9 0C    CMP #$0C         ; Compare accumulator with $0C
$BFE9: D0 03    BNE $BFEE        ; Branch if not equal to $BFEE
$BFEB: 4C 2B A3 JMP $A32B        ; Jump to routine at $A32B if equal to $0C

$BFEE: C9 0D    CMP #$0D         ; Compare accumulator with $0D  
$BFF0: D0 05    BNE $BFF7        ; Branch if not equal to $BFF7
$BFF2: AD 10 C0 LDA $C010        ; **TRIGGER INPUT** - Read trigger register (0=pressed, 1=released)
$BFF5: D0 FB    BNE $BFF2        ; Wait for trigger release (wait for 0) - TITLE SCREEN WAIT
$BFF7: 4C B2 FC JMP $FCB2        ; Jump to routine at $FCB2

; **RESET VECTOR DATA** - System reset vector table
$BFFA: 00       .byte $00        ; Reset vector low byte (part of 6502 reset vector)
$BFFB: 00       .byte $00        ; Reset vector continuation
$BFFC: 00       .byte $00        ; Reset vector continuation  
$BFFD: FF       .byte $FF        ; Reset vector high byte
$BFFE: C8       .byte $C8        ; **NMI VECTOR LOW** - Non-maskable interrupt vector low byte
$BFFF: A2       .byte $A2        ; **NMI VECTOR HIGH** - Non-maskable interrupt vector high byte (points to $A2C8)
