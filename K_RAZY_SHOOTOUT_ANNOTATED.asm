; ===============================================================================
; K-RAZY SHOOT-OUT (USA) - COMPLETE ANNOTATED DISASSEMBLY
; ===============================================================================
; Original Game: CBS Electronics, 1981
; Platform: Atari 5200 SuperSystem
; CPU: MOS 6502C @ 1.79 MHz
; ROM Size: 8KB (8192 bytes)
; Memory Map: $A000-$BFFF
;
; Disassembly by: Tristan Greaves <tristan@extricate.org>
; ===============================================================================

; ===============================================================================
; IMPORTANT VARIABLES (Zero Page and RAM)
; ===============================================================================
;
; GAME STATE & COUNTERS:
; $60     - Joystick input value (direction codes: $F6-$FE, $FF=no input)
; $64     - Current sprite character/offset being rendered
; $65     - Player active flag / sprite row counter
; $67     - Current enemy slot index (1-3)
; $71     - Sprite width in bytes (inner loop counter)
; $72     - Sprite pattern index (for $BF7C table lookup)
; $73     - Sprite orientation/direction flag (0=decrement/up-left, 1=increment/down-right)
; $77     - Sprite Y position / vertical offset
; $78     - Sprite X position / horizontal position
; $79/$7A - 16-bit pointer (low/high) for sprite data source/destination
; $80,X   - Enemy X positions (slots 0-3)
; $84,X   - Enemy Y positions (slots 0-3)
; $8C,X   - Enemy sprite character codes (slots 0-3, $FF=spawning)
; $91     - Game state counter / animation frame counter
; $93,X   - Enemy slot status (0=empty, 1=active, $C0=spawn limit reached)
; $97,X   - Death detection flags (player and enemies)
; $A4     - Sprite rendering flag (horizontal movement processed)
; $A5     - Sprite rendering flag (vertical movement processed)
; $A7     - Enemy firing frequency counter
; $A8     - Missile movement timing counter
; $A9     - Player respawn flag
; $AC     - Bonus point value for scoring
; $AD     - Player exit flag (set when touching arena edge)
;
; DIFFICULTY & LEVEL PARAMETERS:
; $D0     - Sound effect timer / special effect counter
; $D1     - Enemy spawn limit (from difficulty table $BBE4)
; $D2     - Enemy missile hit counter
; $D3     - Enemy-to-enemy collision counter
; $D4     - Enemies defeated by player (incremented on player missile hit)
; $D5     - Current sector/level number (0-7)
; $D6     - Missile speed threshold (from difficulty table)
; $D7     - Enemy firing frequency limit (from difficulty table)
; $D8     - Unknown difficulty parameter (from difficulty table)
; $D9     - Time remaining counter
; $DA     - Death counter (0-3, tracks lives used)
;
; SPRITE & GRAPHICS:
; $E2-$E5 - Missile Y positions (M0=player, M1-M3=enemies)
; $E800   - Hardware register for screen effects
; $E801   - Hardware register for display mode
; $E805   - Player sprite character register
; $E806   - Hardware animation frame register
; $E807   - AUDC4 - Audio control 4
; $E808   - Sprite control register
; $E80A   - Hardware random seed
;
; POINTERS & MEMORY:
; $75/$76 - 16-bit pointer for destination memory (sprite masking)
; $79/$7A - 16-bit pointer for source memory (sprite data)
; $6F/$70 - 16-bit pointer for sprite calculations
;
; COLLISION REGISTERS (Hardware):
; $C000-$C003 - HPOSP0-HPOSP3 (Player horizontal positions)
; $C004       - P0PF (Player 0 to Playfield collision)
; $C008       - M0PL (Missile 0 to Player collision)
; $C009-$C00B - P1PF-P3PF (Enemy to Playfield collision)
; $C00D-$C00F - M1PF-M3PF (Enemy missile to Playfield collision)
; $C01D       - GTIA GRACTL (Enable PMG graphics)
; $C01E       - GTIA HITCLR (Clear collision registers)
; $C01F       - GTIA PRIOR (Priority control)
;
; SCREEN MEMORY:
; $0600-$067F - Score and HUD display area
; $2000-$21FF - Main playfield screen memory
; $2400-$2DFF - Additional screen memory areas
;
; PMG MEMORY:
; $1300-$13FF - Player 0 sprite memory (player character)
; $1400-$14FF - Player 1 sprite memory (enemy 1)
; $1500-$15FF - Player 2 sprite memory (enemy 2)
; $1600-$16FF - Player 3 sprite memory (enemy 3)
; $1700-$17FF - Missile graphics memory (M0-M3)
; ===============================================================================

        .org $A000

; ===============================================================================
; GRAPHICS DATA SECTION ($A000-$A2C7)
; ===============================================================================
; Character set data - 89 characters total (712 bytes)
; Each character is 8x8 pixels, stored as 8 bytes
; Bit 1 = pixel on (#), Bit 0 = pixel off (.)

; Character $00 - Space/blank character

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $01 - UNKNOWN usage

        .byte $38        ; ..###...
        .byte $38        ; ..###...
        .byte $38        ; ..###...
        .byte $38        ; ..###...
        .byte $18        ; ...##...
        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $00        ; ........

; Character $02 - HUD Player sprite: Head - Sideways

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $10        ; ...#....
        .byte $28        ; ..#.#...
        .byte $28        ; ..#.#...
        .byte $10        ; ...#....

; Character $03 - HUD Player sprite: Walking 1

        .byte $3A        ; ..###.#.
        .byte $54        ; .#.#.#..
        .byte $90        ; #..#....
        .byte $50        ; .#.#....
        .byte $18        ; ...##...
        .byte $24        ; ..#..#..
        .byte $E4        ; ###..#..
        .byte $86        ; #....##.

; Character $04 - HUD Player sprite: Head - Stationary

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $08        ; ....#...

; Character $05 - HUD Player sprite: Walking 2

        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $1E        ; ...####.
        .byte $08        ; ....#...
        .byte $08        ; ....#...
        .byte $18        ; ...##...
        .byte $28        ; ..#.#...
        .byte $1C        ; ...###..

; Character $06 - HUD Player sprite: Dying Top
; Positioned up and to the right of the bottom half.

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $8C        ; #...##..
        .byte $94        ; #..#.#..
        .byte $58        ; .#.##...
        .byte $20        ; ..#.....
        .byte $50        ; .#.#....
        .byte $8C        ; #...##..

; Character $07 - HUD Player sprite: Dying Bottom

        .byte $07        ; .....###
        .byte $09        ; ....#..#
        .byte $11        ; ...#...#
        .byte $A2        ; #.#...#.
        .byte $44        ; .#...#..
        .byte $08        ; ....#...
        .byte $10        ; ...#....
        .byte $08        ; ....#...

; Character $08 - HUD Player sprite: Dead (Left)

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $01        ; .......#
        .byte $C3        ; ##....##
        .byte $C7        ; ##...###
        .byte $FF        ; ########

; Character $09 - HUD Player sprite: Dead (right)

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $80        ; #.......
        .byte $C7        ; ##...###
        .byte $E5        ; ###..#.#
        .byte $FD        ; ######.#
        .byte $F7        ; ####.###

; Character $0A - Font Character: * (Asterisk)

        .byte $00        ; ........
        .byte $66        ; .##..##.
        .byte $3C        ; ..####..
        .byte $FF        ; ########
        .byte $3C        ; ..####..
        .byte $66        ; .##..##.
        .byte $00        ; ........
        .byte $00        ; ........

; Character $0B - Font Character: + (Plus)

        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $7E        ; .######.
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $00        ; ........
        .byte $00        ; ........

; Character $0C - Font Character: , (Comma)

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $30        ; ..##....

; Character $0D - Font Character: - (Hyphen)

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $7E        ; .######.
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $0E - Font Character: . (Period)

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $00        ; ........

; Character $0F - Font Character: / (Forward Slash)

        .byte $03        ; ......##
        .byte $06        ; .....##.
        .byte $0C        ; ....##..
        .byte $18        ; ...##...
        .byte $30        ; ..##....
        .byte $60        ; .##.....
        .byte $40        ; .#......
        .byte $00        ; ........

; Character $10 - Number '0' for score display

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $11 - Number '1' for score display

        .byte $38        ; ..###...
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $3E        ; ..#####.
        .byte $3E        ; ..#####.
        .byte $3E        ; ..#####.
        .byte $00        ; ........

; Character $12 - Number '2' for score display

        .byte $7F        ; .#######
        .byte $03        ; ......##
        .byte $03        ; ......##
        .byte $7F        ; .#######
        .byte $60        ; .##.....
        .byte $60        ; .##.....
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $13 - Number '3' for score display

        .byte $7E        ; .######.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $7F        ; .#######
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $14 - Number '4' for score display

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $7F        ; .#######
        .byte $07        ; .....###
        .byte $00        ; ........

; Character $15 - Number '5' for score display

        .byte $7F        ; .#######
        .byte $60        ; .##.....
        .byte $60        ; .##.....
        .byte $7F        ; .#######
        .byte $03        ; ......##
        .byte $03        ; ......##
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $16 - Number '6' for score display

        .byte $7C        ; .#####..
        .byte $6C        ; .##.##..
        .byte $60        ; .##.....
        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $17 - Number '7' for score display

        .byte $7F        ; .#######
        .byte $03        ; ......##
        .byte $03        ; ......##
        .byte $1F        ; ...#####
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $00        ; ........

; Character $18 - Number '8' for score display

        .byte $3E        ; ..#####.
        .byte $36        ; ..##.##.
        .byte $36        ; ..##.##.
        .byte $7F        ; .#######
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $19 - Number '9' for score display

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $7F        ; .#######
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $00        ; ........

; Character $1A - Font character: Colon (:)

        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $00        ; ........
        .byte $00        ; ........

; Character $1B - Font character: Semicolon (;)

        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $00        ; ........
        .byte $18        ; ...##...
        .byte $18        ; ...##...
        .byte $30        ; ..##....
        .byte $00        ; ........

; Character $1C - Enemy
; This version used between rounds when showing scoring.

        .byte $00        ; ........
        .byte $3E        ; ..#####.
        .byte $08        ; ....#...
        .byte $7F        ; .#######
        .byte $5D        ; .#.###.#
        .byte $5D        ; .#.###.#
        .byte $5D        ; .#.###.#
        .byte $1C        ; ...###..

; Character $1D - UNKNOWN usage

        .byte $00        ; ........
        .byte $7E        ; .######.
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $7E        ; .######.
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $1E - HUD Player sprite: Body - Stationary

        .byte $1C        ; ...###..
        .byte $2A        ; ..#.#.#.
        .byte $2A        ; ..#.#.#.
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $36        ; ..##.##.

; Character $1F - Font character: Question mark (?)

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $03        ; ......##
        .byte $1F        ; ...#####
        .byte $1C        ; ...###..
        .byte $00        ; ........
        .byte $1C        ; ...###..
        .byte $00        ; ........

; Character $20 - HUD Player sprite: Head - Stationary

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $08        ; ....#...

; Character $21 - Letter 'A' for text display

        .byte $3F        ; ..######
        .byte $33        ; ..##..##
        .byte $33        ; ..##..##
        .byte $7F        ; .#######
        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $00        ; ........

; Character $22 - Letter 'B' for text display

        .byte $7E        ; .######.
        .byte $66        ; .##..##.
        .byte $66        ; .##..##.
        .byte $7F        ; .#######
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $23 - Letter 'C' for text display

        .byte $7F        ; .#######
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $60        ; .##.....
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $24 - Letter 'D' for text display

        .byte $7E        ; .######.
        .byte $66        ; .##..##.
        .byte $66        ; .##..##.
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $25 - Letter 'E' for text display

        .byte $7F        ; .#######
        .byte $60        ; .##.....
        .byte $60        ; .##.....
        .byte $7F        ; .#######
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $26 - Letter 'F' for text display

        .byte $7F        ; .#######
        .byte $60        ; .##.....
        .byte $60        ; .##.....
        .byte $7F        ; .#######
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........

; Character $27 - Letter 'G' for text display

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $60        ; .##.....
        .byte $6F        ; .##.####
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $28 - Letter 'H' for text display

        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $7F        ; .#######
        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $00        ; ........

; Character $29 - Letter 'I' for text display

        .byte $7F        ; .#######
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $2A - Letter 'J' for text display

        .byte $0C        ; ....##..
        .byte $0C        ; ....##..
        .byte $0C        ; ....##..
        .byte $0E        ; ....###.
        .byte $0E        ; ....###.
        .byte $6E        ; .##.###.
        .byte $7E        ; .######.
        .byte $00        ; ........

; Character $2B - Letter 'K' for text display

        .byte $66        ; .##..##.
        .byte $66        ; .##..##.
        .byte $6C        ; .##.##..
        .byte $7F        ; .#######
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $00        ; ........

; Character $2C - Letter 'L' for text display

        .byte $30        ; ..##....
        .byte $30        ; ..##....
        .byte $30        ; ..##....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $7E        ; .######.
        .byte $00        ; ........

; Character $2D - Letter 'M' for text display

        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $7F        ; .#######
        .byte $77        ; .###.###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $00        ; ........

; Character $2E - Letter 'N' for text display

        .byte $67        ; .##..###
        .byte $77        ; .###.###
        .byte $7F        ; .#######
        .byte $6F        ; .##.####
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $00        ; ........

; Character $2F - Letter 'O' for text display

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $30 - Letter 'P' for text display

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $7F        ; .#######
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........

; Character $31 - Letter 'Q' for text display

        .byte $7F        ; .#######
        .byte $63        ; .##...##
        .byte $63        ; .##...##
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $07        ; .....###

; Character $32 - Letter 'R' for text display

        .byte $7E        ; .######.
        .byte $66        ; .##..##.
        .byte $66        ; .##..##.
        .byte $7F        ; .#######
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........

; Character $33 - Letter 'S' for text display

        .byte $7F        ; .#######
        .byte $60        ; .##.....
        .byte $7F        ; .#######
        .byte $03        ; ......##
        .byte $73        ; .###..##
        .byte $73        ; .###..##
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $34 - Letter 'T' for text display

        .byte $7F        ; .#######
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $00        ; ........

; Character $35 - Letter 'U' / Player sprite: Static player character (lives display)

        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $36 - Letter 'V' for text display

        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $6F        ; .##.####
        .byte $3E        ; ..#####.
        .byte $1C        ; ...###..
        .byte $00        ; ........

; Character $37 - Letter 'W' for text display

        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $6F        ; .##.####
        .byte $7F        ; .#######
        .byte $7F        ; .#######
        .byte $67        ; .##..###
        .byte $00        ; ........

; Character $38 - Letter 'X' for text display

        .byte $00        ; ........
        .byte $C3        ; ##....##
        .byte $66        ; .##..##.
        .byte $3C        ; ..####..
        .byte $18        ; ...##...
        .byte $3C        ; ..####..
        .byte $66        ; .##..##.
        .byte $C3        ; ##....##

; Character $39 - Letter 'Y' for text display

        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $1C        ; ...###..
        .byte $00        ; ........

; Character $3A - Letter 'Z' for text display

        .byte $7F        ; .#######
        .byte $66        ; .##..##.
        .byte $6C        ; .##.##..
        .byte $18        ; ...##...
        .byte $37        ; ..##.###
        .byte $67        ; .##..###
        .byte $7F        ; .#######
        .byte $00        ; ........

; Character $3B - UNKNOWN usage

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $42        ; .#....#.
        .byte $00        ; ........
        .byte $20        ; ..#.....
        .byte $02        ; ......#.
        .byte $02        ; ......#.

; Character $3C - UNKNOWN usage

        .byte $02        ; ......#.
        .byte $02        ; ......#.
        .byte $02        ; ......#.
        .byte $70        ; .###....
        .byte $06        ; .....##.
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $02        ; ......#.

; Character $3D - UNKNOWN usage

        .byte $70        ; .###....
        .byte $07        ; .....###
        .byte $70        ; .###....
        .byte $30        ; ..##....
        .byte $06        ; .....##.
        .byte $70        ; .###....
        .byte $06        ; .....##.
        .byte $70        ; .###....

; Character $3E - UNKNOWN usage

        .byte $30        ; ..##....
        .byte $06        ; .....##.
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $02        ; ......#.
        .byte $41        ; .#.....#
        .byte $D8        ; ##.##...
        .byte $A1        ; #.#....#

; Character $3F - UNKNOWN usage

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $40 - UNKNOWN usage

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $41 - CBS logo building block

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $42 - CBS logo building block

        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $43 - CBS logo building block

        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Character $44 - CBS logo building block

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........

; Character $45 - CBS logo building block

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........

; Character $46 - CBS logo building block

        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........

; Character $47 - CBS logo building block

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $00        ; ........

; Character $48 - CBS logo building block

        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........

; Character $49 - CBS logo building block

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $00        ; ........
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........

; Character $4A - CBS logo building block

        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $77        ; .###.###
        .byte $00        ; ........

; Character $4B - UNKNOWN usage

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $47        ; .#...###
        .byte $00        ; ........
        .byte $24        ; ..#..#..
        .byte $07        ; .....###
        .byte $07        ; .....###

; Character $4C - UNKNOWN usage

        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $07        ; .....###
        .byte $46        ; .#...##.

; Character $4D - UNKNOWN usage

        .byte $00        ; ........
        .byte $2E        ; ..#.###.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $41        ; .#.....#
        .byte $58        ; .#.##...
        .byte $A2        ; #.#...#.

; Character $4E - UNKNOWN usage

        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $70        ; .###....
        .byte $4A        ; .#..#.#.
        .byte $00        ; ........
        .byte $28        ; ..#.#...
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.

; Character $4F - UNKNOWN usage

        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.

; Character $50 - UNKNOWN usage

        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.

; Character $51 - UNKNOWN usage

        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.

; Character $52 - UNKNOWN usage

        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.

; Character $53 - UNKNOWN usage

        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $46        ; .#...##.
        .byte $00        ; ........
        .byte $2E        ; ..#.###.

; Character $54 - UNKNOWN usage

        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $41        ; .#.....#
        .byte $70        ; .###....
        .byte $A2        ; #.#...#.
        .byte $70        ; .###....
        .byte $70        ; .###....

; Character $55 - UNKNOWN usage

        .byte $70        ; .###....
        .byte $46        ; .#...##.
        .byte $00        ; ........
        .byte $2C        ; ..#.##..
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.

; Character $56 - UNKNOWN usage

        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.

; Character $57 - UNKNOWN usage

        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $46        ; .#...##.

; Character $58 - UNKNOWN usage

        .byte $00        ; ........
        .byte $2E        ; ..#.###.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $06        ; .....##.
        .byte $41        ; .#.....#
        .byte $A6        ; #.#..##.
        .byte $A2        ; #.#...#.

; Note: There is more sprite data (player and enemy animations) at the end of this
; dissassembly.

; ===============================================================================
; GAME CODE SECTION ($A2C8-$BFFF)
; ===============================================================================

GAME_CODE_START:

; ===============================================================================
; CARTRIDGE / GAME INITIALIZATION ($A2C8)
; System startup and hardware setup
; This is vectored to after system start.
; ===============================================================================

$A2C8: E8       cartridge_init:
                INX
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
$A328: 20 D0 A6 JSR title_screen ; Display title screen and wait for trigger

go_back_to_prepare_new_game:
$A32B: 20 18 A5 JSR prepare_new_game ; Initialize game variables and text displays
$A32E: 58       CLI
back_to_init_sector:
$A32F: 20 B6 A9 JSR init_sector ; Initialize first sector and generate arena

; ===============================================================================
; MAIN_GAME_LOOP ($A332)
; ===============================================================================
MAIN_GAME_LOOP:
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
$A33A: 20 C3 BB JSR set_sector_difficulty ; Load difficulty parameters for current sector
$A33D: 20 74 B9 JSR generate_arena ; Generate arena layout and patterns
$A340: 20 AD AF JSR pmg_system_init ; Input handling routine
$A343: 20 11 BC JSR position_player_and_activate_enemies ; Position player and activate enemy system

$A346: 20 4F B1 sector_game_loop:
                JSR move_missiles_in_flight ; Move active player missiles
$A349: 20 B3 B2 JSR $B2B3 ; Enemy AI/movement
$A34C: 20 BF B4 JSR spawn_enemies ; Enemy spawning and death detection
$A34F: A5 DA    LDA $DA         ; Load death counter (0-3)
$A351: C9 03    CMP #$03        ; Check if 3 deaths (all lives used)
$A353: F0 2D    BEQ player_out_of_lives ; Branch if game over (3 deaths)

$A355: A5 A9    LDA $A9         ; Load player respawn check
$A357: D0 E7    BNE $A340       ; Go back to re-init PMG, position player etc.

$A359: 20 5B B5 JSR render_enemy_sprites ; Render all 3 enemy sprites
$A35C: 20 3A A8 JSR collision_detection ; Process all collision detection

$A35F: A5 AD    LDA $AD         ; Is player moving horizontally right now?
$A361: F0 0A    BEQ skip_player_escape_check      ; If not, skip ahead.

; Player has escaped.
; 'check_sector_cleared' will increase level ONLY if all enemies were defeated.
; This means a player 'chickening out' just plays the same level again.
$A363: A6 D5    LDX $D5
$A365: F6 C5    INC $C5
$A367: 20 FF A4 JSR check_sector_cleared
$A36A: 4C 2F A3 JMP back_to_init_sector

skip_player_escape_check:
$A36D: 20 3D B2 JSR $B23D
$A370: 20 1A B3 JSR enemy_firing
$A373: 20 05 AD JSR process_player_input
$A376: 20 26 B7 JSR update_elapsed_game_time
$A379: 20 77 BB JSR time_countdown_and_display
$A37C: A5 D9    LDA $D9         ; Load time remaining counter
$A37E: C9 02    CMP #$02        ; Check if time almost up (2 time units left)
$A380: D0 C4    BNE sector_game_loop ; Loop back if time remaining > 2
                                ; TIME UP! This also ends the game.
player_out_of_lives:
$A382: A6 D5    LDX $D5         ; Load current level counter
$A384: F6 C5    INC $C5,X       ; Increment level statistics
$A386: E6 D5    INC $D5         ; INCREMENT LEVEL COUNTER - triggers new sector
$A388: 20 B6 A9 JSR init_sector ; Initialize new sector and generate arena
$A38B: 20 81 A5 JSR game_over_screen ; Display game over screen with skill ranking
$A38E: 4C 2B A3 JMP go_back_to_prepare_new_game ; Jump to main game setup

; Miscellaneous game text.

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
; ===============================================================================
; display_rank ($A48C-$A4E8)
; Horizontal scrolling rank text display routine
; 
; Called after calculate_rank to display the player's skill ranking with
; smooth horizontal scrolling animation on the game over screen.
;
; SCROLLING MECHANISM:
; 1. Uses $D404 (HSCROL) hardware register for fine horizontal scrolling (0-7 pixels)
; 2. $64 counter decrements to create scroll animation (masked to 0-7)
; 3. $92 index advances through text data ($0653) from 0 to $87 (135 bytes)
; 4. Copies 22-byte window of text to screen memory at $3980
; 5. When fine scroll completes cycle (== 7), advances to next character
; 6. Continues until all text has scrolled across screen
;
; DISPLAY SETUP:
; 1. Copies 21-byte display list from $A4E9 to $3800 (ANTIC display list memory)
; 2. Synchronizes with VCOUNT register ($D40B) for smooth animation
; 3. Converts ASCII to screen codes (subtracts $20)
;
; The scrolling creates a smooth left-to-right text animation effect.
; ===============================================================================
display_rank:
$A48C: A9 38    LDA #$38        ; Load display parameter
$A48E: 85 06    STA $06         ; Store to zero page
$A490: A9 00    LDA #$00        ; Clear accumulator
$A492: 85 05    STA $05         ; Clear zero page location
$A494: A0 15    LDY #$15        ; Set loop counter to 21 bytes
$A496: B9 E9 A4 LDA $A4E9,Y     ; Load from display list data table
$A499: 99 00 38 STA $3800,Y     ; Store to ANTIC display list memory at $3800
$A49C: 88       DEY             ; Decrement counter
$A49D: 10 F7    BPL $A496       ; Loop until all 21 bytes copied
$A49F: A9 22    LDA #$22        ; Load parameter value
$A4A1: 85 07    STA $07         ; Store to zero page
$A4A3: A2 00    LDX #$00        ; Initialize X register
$A4A5: 86 64    STX $64         ; Clear scroll counter $64
$A4A7: 86 92    STX $92         ; Clear text index $92
$A4A9: AD 0B D4 LDA $D40B       ; Read VCOUNT (vertical line counter)
$A4AC: C9 40    CMP #$40        ; Wait for scanline $40
$A4AE: D0 F9    BNE $A4A9       ; Loop until VCOUNT = $40 (sync timing)
$A4B0: 8D 0A D4 STA $D40A       ; Write to WSYNC (wait for horizontal sync)
$A4B3: 8D 0A D4 STA $D40A       ; Write again (ensure sync)
$A4B6: A5 64    LDA $64         ; Load scroll counter
$A4B8: C6 64    DEC $64         ; Decrement scroll counter (creates animation)
$A4BA: 29 07    AND #$07        ; Mask to 0-7 (fine scroll range)
$A4BC: 8D 04 D4 STA $D404       ; Write to HSCROL (horizontal scroll register)
$A4BF: A0 00    LDY #$00        ; Initialize Y counter
$A4C1: A6 92    LDX $92         ; Load text index from $92
$A4C3: BD 53 06 LDA $0653,X     ; Load character from text data
$A4C6: 38       SEC             ; Set carry for subtraction
$A4C7: E9 20    SBC #$20        ; Convert ASCII to screen code
$A4C9: 99 80 39 STA $3980,Y     ; Store to screen memory (22-byte window)
$A4CC: E8       INX             ; Increment text index
$A4CD: C8       INY             ; Increment screen position
$A4CE: C0 16    CPY #$16        ; Check if 22 bytes copied
$A4D0: D0 F1    BNE $A4C3       ; Loop until 22-byte window filled
$A4D2: AD 10 C0 LDA $C010       ; Read abort flag
$A4D5: F0 11    BEQ $A4E8       ; Exit if abort flag set
$A4D7: A5 64    LDA $64         ; Load scroll counter
$A4D9: 29 07    AND #$07        ; Mask to 0-7
$A4DB: C9 07    CMP #$07        ; Check if scroll cycle complete
$A4DD: D0 CA    BNE $A4A9       ; Continue scrolling if not complete
$A4DF: A6 92    LDX $92         ; Load text index
$A4E1: E8       INX             ; Advance to next character
$A4E2: E0 87    CPX #$87        ; Check if reached end of text (135 chars)
$A4E4: 90 C1    BCC $A4A7       ; Continue scrolling if more text remains
$A4E6: B0 BB    BCS $A4A3       ; Loop back (restart scroll)
$A4E8: 60       RTS             ; Return from scrolling display routine
; ===============================================================================
; Display list data table used by display_rank routine ($A48C)
; This is an Atari ANTIC display list structure that defines screen layout
; 
; Display list instructions:
; $70 = Blank 8 scan lines (vertical spacing)
; $57 = Display mode 7 with flags
; $80 = Flag byte (DLI or LMS bit)
; $39 = Display mode 9 or mode with flags
; $47 = Display mode 7 with flags  
; $41 = Display mode 1 with flags
; $38 = Display mode 8
; $07 = Display mode 7
; $00 = Padding/end marker
;
; This display list is copied to $3800 to configure the screen layout
; for the game over/ranking screen display
; ===============================================================================
$A4E9: 70       .byte $70        ; Blank 8 scan lines
$A4EA: 70       .byte $70        ; Blank 8 scan lines
$A4EB: 70       .byte $70        ; Blank 8 scan lines
$A4EC: 70       .byte $70        ; Blank 8 scan lines
$A4ED: 70       .byte $70        ; Blank 8 scan lines
$A4EE: 70       .byte $70        ; Blank 8 scan lines
$A4EF: 70       .byte $70        ; Blank 8 scan lines
$A4F0: 57       .byte $57        ; Display mode 7 with flags
$A4F1: 80       .byte $80        ; Flag byte (DLI/LMS)
$A4F2: 39       .byte $39        ; Display mode instruction
$A4F3: 70       .byte $70        ; Blank 8 scan lines
$A4F4: 70       .byte $70        ; Blank 8 scan lines
$A4F5: 70       .byte $70        ; Blank 8 scan lines
$A4F6: 70       .byte $70        ; Blank 8 scan lines
$A4F7: 47       .byte $47        ; Display mode 7 with flags
$A4F8: 00       .byte $00        ; Padding/end marker
$A4F9: 39       .byte $39        ; Display mode instruction
$A4FA: 07       .byte $07        ; Display mode 7
$A4FB: 07       .byte $07        ; Display mode 7
$A4FC: 41       .byte $41        ; Display mode 1 with flags
$A4FD: 00       .byte $00        ; Padding/end marker
$A4FE: 38       .byte $38        ; Display mode 8
; ===============================================================================
; check_sector_cleared ($A4FF)
; Level completion check - determines if player advances to next level
; 
; This routine checks if ALL enemies in the level were defeated before escaping.
; Only if all enemies are defeated will the level counter increment.
; 
; Key variables:
; - $D4: Number of enemies defeated in current level
; - $D1: Total number of enemies that spawn in current level
; - $D5: Level progression counter (incremented only if all enemies defeated)
; 
; Logic:
; 1. Check if all 3 enemy slots are currently defeated ($94 AND $95 AND $96)
; 2. If all slots defeated, compare $D4 (enemies defeated) with $D1 (total enemies)
; 3. If $D4 >= $D1 (all enemies defeated), increment level counter $D5
; 4. If $D4 < $D1 (some enemies escaped), decrement level counter $D5
; 
; This means escaping without defeating all enemies forces replay of same level.
; ===============================================================================

check_sector_cleared:
$A4FF: A5 94    LDA $94         ; Load enemy slot 1 state (0=empty, 1=defeated)
$A501: 25 95    AND $95         ; AND with enemy slot 2 state  
$A503: 25 96    AND $96         ; AND with enemy slot 3 state
                                ; Result = 1 only if ALL 3 enemies defeated
                                ; Result = 0 if ANY slot empty (exits open!)
$A505: F0 0A    BEQ $A511       ; Branch if any enemy slot empty
$A507: A5 D4    LDA $D4         ; Load enemies defeated count
$A509: C5 D1    CMP $D1         ; Compare with total enemies for this level
$A50B: 90 04    BCC $A511       ; Branch if $D4 < $D1 (not all enemies defeated)
$A50D: E6 D5    INC $D5         ; All enemies defeated! Increment level counter
$A50F: D0 06    BNE $A517       ; Continue to next check
$A511: A5 D5    LDA $D5         ; Load level progression counter
$A513: F0 02    BEQ $A517       ; Branch if zero
$A515: C6 D5    DEC $D5         ; Not all enemies defeated - decrement level counter
$A517: 60       RTS             ; Return from level completion check
; ===============================================================================
; PREPARE NEW GAME ($A518)
; Game variable initialization and text display setup
; This routine:
; - Clears all game state variables
; - Sets up initial score display (00000)
; - Sets up time display (00.00)
; - Copies game text to screen memory
; - Initializes difficulty level
; - Prepares display lists for game screens
; ===============================================================================

$A518: A9 00    prepare_new_game:
                LDA #$00 ; Clear game state variables
$A51A: 8D 01 E8 STA $E801 ; Clear RAM location $E801
$A51D: 8D 08 E8 STA $E808 ; Clear RAM location $E808
$A520: 85 04    STA $04 ; Clear zero page variable $04
$A522: A9 02    LDA #$02 ; Set game mode flag to 2
$A524: 8D 0F E8 STA $E80F ; Store game mode in RAM $E80F
$A527: 20 A2 BD JSR clear_collision_registers ; Clear collision detection hardware
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
$A53F: A5 DC    LDA $DC ; Load initial difficulty/level value
$A541: 85 D5    STA $D5 ; Set initial level counter
$A543: A2 30    LDX #$30 ; Set X to $30 (48 decimal) for text setup
$A545: A9 01    LDA #$01 ; Set flag to 1 (enable something)
$A547: 85 DB    STA $DB ; Store flag in game state variable
$A549: A0 18    LDY #$18 ; Set Y to $18 (24 decimal) for display
$A54B: 20 B0 BD JSR prepare_display_and_input_scanning ; Initialize hardware for display
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
$A57A: 85 DA    STA $DA ; Clear death counter (start with 3 lives)
$A57C: A9 30    LDA #$30 ; Set initial time/score value
$A57E: 85 7B    STA $7B ; Store in time variable $7B
$A580: 60       RTS ; Return from additional setup
; ===============================================================================
; game_over_screen ($A581)
; Game over screen display and high score handling
; This routine:
; - Displays "PRESS TRIGGER TO PLAY AGAIN" message to screen memory
; - Backs up current score and time to temporary storage
; - Compares current score with high score
; - Updates high score table if player achieved new high score
; - Calls additional display routines (rank selection likely happens there)
; - Refreshes screen displays
; 
; NOTE: Skill rank text (ROOKIE, NOVICE, GUNNER, BLASTER, MARKSMAN) exists in
; the data table at $A612-$A639 but is NOT copied by this routine.
; ===============================================================================
game_over_screen:
$A581: 20 A2 BD JSR clear_collision_registers ; Clear collision detection
$A584: 20 B0 BD JSR prepare_display_and_input_scanning ; Initialize hardware
$A587: AD 0A E8 LDA $E80A ; Load hardware configuration
$A58A: 29 F0    AND #$F0 ; Mask upper 4 bits
$A58C: 09 08    ORA #$08 ; Set bit 3 (enable feature)
$A58E: 85 0C    STA $0C ; Store configuration in $0C
$A590: A2 34    LDX #$34 ; Set loop counter to $34 (52 bytes)
$A592: BD D7 A5 LDA $A5D7,X ; Load from text table ($A5D7+X down to $A5D7+0)
$A595: 38       SEC ; Set carry for subtraction
$A596: E9 20    SBC #$20 ; Convert ASCII to screen code (subtract $20)
$A598: 9D 00 39 STA $3900,X ; Store to screen memory $3900
$A59B: CA       DEX ; Decrement counter
$A59C: 10 F4    BPL $A592 ; Loop: copy "PRESS TRIGGER TO PLAY AGAIN" (52 bytes)
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
$A5D0: 20 C0 BA JSR calculate_rank ; Calculate player rank and display rank text
$A5D3: 20 8C A4 JSR display_rank ; Display rank screen with ANTIC display list
$A5D6: 60       RTS ; Return from game over screen
; ===============================================================================
; GAME_COMPLETION_TEXT_DATA ($A5D7)
; Text data for game completion screens
; 
; $A5D7-$A60B (52 bytes): "   PRESS TRIGGER          TO PLAY             AGAIN"
; 
; $A60B-$A63A (48 bytes): Skill rank names in 8-byte chunks
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
; UNUSED_NMI_HANDLER ($A63B-$A6CD)
; **UNREACHABLE CODE - UNUSED INTERRUPT HANDLER**
; 
; WARNING: This code is never called. No references to $A63B exist in the ROM.
; 
; **WHAT THIS IS:**
; This is an unused NMI (Non-Maskable Interrupt) handler that would run 60 times
; per second during VBlank. The JMP $FCB2 at the end chains to the OS NMI handler,
; which is the signature of a custom interrupt handler.
;
; **WHY IT'S UNUSED:**
; The game likely used this during development but replaced it with a different
; interrupt handling approach. The NMI vector at $BFFE-$BFFF points to $A2C8
; (cartridge_init), not to this routine.
;
; **WHAT IT WOULD DO IF ACTIVE:**
; This routine would handle per-frame game updates:
;
; 1. ANIMATION FRAME SEQUENCING ($A63B-$A662):
;
; 2. ANIMATION SPEED CONTROL ($A673-$A686):
;
; 3. TIMER MANAGEMENT ($A688-$A69E):
;
; 4. SPRITE POSITION ANIMATION ($A6A1-$A6B8):
;
; 5. ACCURACY BONUS SYSTEM ($A6BA-$A6CB):
;
; 6. CHAIN TO OS NMI HANDLER ($A6CD):
;
; This represents a complete per-frame game loop that was developed but never
; integrated into the final game. The functionality may have been moved to
; other routines or simplified for performance reasons.
; ===============================================================================

$A63B: A9 40    LDA #$40 ; Load animation control value
$A63D: 85 00    STA $00 ; Store to zero page animation state
$A63F: 8D 0E E8 STA $E80E ; Store in hardware animation control register
$A642: A5 BE    LDA $BE ; Check animation enable flag
$A644: F0 1F    BEQ $A665 ; Branch if animations disabled
$A646: A5 B3    LDA $B3 ; Load animation frame counter (0-17)
$A648: C9 11    CMP #$11 ; Check if frame 17 reached
$A64A: B0 27    BCS $A673 ; Branch to cleanup if animation complete
$A64C: A5 B4    LDA $B4 ; Load animation phase (0-2)
$A64E: D0 15    BNE $A665 ; Branch if not in phase 0
$A650: A5 B3    LDA $B3 ; Load current frame number
$A652: 18       CLC ; Clear carry for addition
$A653: 69 01    ADC #$01 ; Increment frame counter
$A655: 85 B3    STA $B3 ; Store new frame number
$A657: 8D 06 E8 STA $E806 ; Update hardware animation frame register
$A65A: C9 0D    CMP #$0D ; Check if reached frame 13
$A65C: D0 07    BNE $A665 ; Branch if not at frame 13
$A65E: A9 87    LDA #$87 ; Load animation completion state
$A660: 85 B2    STA $B2 ; Store animation state
$A662: 4C 73 A6 JMP $A673 ; Jump to animation cleanup
$A665: A6 B4    LDX $B4 ; Load animation phase index (0-2)
$A667: E8       INX ; Increment to next phase
$A668: E0 03    CPX #$03 ; Check if phase 3 (wrap around)
$A66A: D0 02    BNE $A66E ; Branch if not wrapping
$A66C: A2 00    LDX #$00 ; Reset phase to 0
$A66E: 86 B4    STX $B4 ; Store updated phase index
$A670: 4C 88 A6 JMP $A688 ; Jump to timer management
$A673: A5 B2    LDA $B2 ; Load animation speed control
$A675: 8D 07 E8 STA $E807 ; Store to hardware speed register
$A678: C9 80    CMP #$80 ; Check if speed at minimum ($80)
$A67A: D0 07    BNE $A683 ; Branch if not at minimum
$A67C: A9 00    LDA #$00 ; Clear animation enable flag
$A67E: 85 BE    STA $BE ; Disable animations
$A680: 4C 88 A6 JMP $A688 ; Jump to timer management
$A683: 38       SEC ; Set carry for subtraction
$A684: E9 01    SBC #$01 ; Decrease animation speed (slowdown)
$A686: 85 B2    STA $B2 ; Store new speed value
$A688: E6 B6    INC $B6 ; Increment primary animation timer
$A68A: A5 B6    LDA $B6 ; Load timer value
$A68C: 8D 02 E8 STA $E802 ; Store to hardware timer register
$A68F: C9 20    CMP #$20 ; Check if timer reached 32
$A691: 90 0E    BCC $A6A1 ; Branch if timer < 32
$A693: A5 B7    LDA $B7 ; Load secondary timer
$A695: C9 A0    CMP #$A0 ; Check if secondary timer at max ($A0)
$A697: F0 08    BEQ $A6A1 ; Branch if timer complete
$A699: 38       SEC ; Set carry for subtraction
$A69A: E9 01    SBC #$01 ; Decrement secondary timer
$A69C: 85 B7    STA $B7 ; Store new timer value
$A69E: 8D 03 E8 STA $E803 ; Update hardware timer register
$A6A1: A5 B9    LDA $B9 ; Check sprite animation enable flag
$A6A3: F0 15    BEQ $A6BA ; Branch if sprite animation disabled
$A6A5: A5 B8    LDA $B8 ; Load sprite X position
$A6A7: 38       SEC ; Set carry for subtraction
$A6A8: E9 04    SBC #$04 ; Move sprite left 4 pixels
$A6AA: 85 B8    STA $B8 ; Store new sprite position
$A6AC: 8D 04 E8 STA $E804 ; Update player sprite X position register
$A6AF: C9 08    CMP #$08 ; Check if sprite at left edge (8 pixels)
$A6B1: B0 07    BCS $A6BA ; Branch if sprite not at edge
$A6B3: A9 00    LDA #$00 ; Clear sprite character
$A6B5: 8D 05 E8 STA $E805 ; Clear player sprite character (hide sprite)
$A6B8: 85 B9    STA $B9 ; Disable sprite animation flag
$A6BA: A5 93    LDA $93 ; Check game trigger flag
$A6BC: D0 0F    BNE $A6CD ; Branch if trigger active (skip bonus)
$A6BE: A5 D1    LDA $D1 ; Load shot counter (total shots fired)
$A6C0: 38       SEC ; Set carry for subtraction
$A6C1: E5 D4    SBC $D4 ; Subtract hit counter (calculate misses)
$A6C3: 90 04    BCC $A6C9 ; Branch if underflow (shouldn't happen)
$A6C5: C9 05    CMP #$05 ; Check if misses < 5 (good accuracy)
$A6C7: B0 04    BCS $A6CD ; Branch if accuracy poor (≥5 misses)
$A6C9: A9 C9    LDA #$C9 ; Load accuracy bonus value
$A6CB: 85 08    STA $08 ; Store accuracy bonus
$A6CD: 4C B2 FC JMP $FCB2 ; Chain to OS ROM NMI handler

; ===============================================================================
; TITLE SCREEN ROUTINE ($A6D0)
; Displays the title screen with CBS logo and game title
; This routine:
; - Initializes display hardware
; - Sets up screen memory and graphics
; - Displays CBS logo pattern
; - Shows "CBS electronics PRESENTS"
; - Shows "K-RAZY SHOOTOUT" title
; - Waits for trigger press to start game
; ===============================================================================

$A6D0: 20 A2 BD title_screen:
                JSR clear_collision_registers ; Clear collision detection hardware
$A6D3: A9 00    LDA #$00 ; Clear setup variables
$A6D5: 85 DC    STA $DC ; Clear difficulty counter
$A6D7: A2 08    LDX #$08 ; Set up memory clear loop (8 bytes)
$A6D9: 9D 00 E8 STA $E800 ; Clear RAM area $E800-$E807
$A6DC: CA       DEX ; Decrement clear counter
$A6DD: D0 FA    BNE $A6D9 ; Continue clearing memory
$A6DF: 20 BD BD JSR clear_game_state ; Clear game state variables ($E800-$E807)
$A6E2: A2 A8    LDX #$A8 ; Set up large copy operation (168 bytes)
$A6E4: BD E3 A3 LDA $A3E3 ; Load from text data table
$A6E7: 9D 52 06 STA $0652 ; Store to screen memory area
$A6EA: CA       DEX ; Decrement copy counter
$A6EB: D0 F7    BNE $A6E4 ; Continue copying text data
$A6ED: A9 07    LDA #$07 ; **SECTOR DISPLAY SETUP** - Load sector number/display parameter
$A6EF: A2 A6    LDX #$A6 ; X coordinate for display (166 decimal)
$A6F1: A0 3B    LDY #$3B ; Y coordinate for display (59 decimal)
$A6F3: 20 D5 BD JSR configure_display_list ; **CONFIGURE DISPLAY LIST** - Set up screen positioning for sector display
$A6F6: A2 30    LDX #$30 ; Set up text display (48 chars)
$A6F8: A9 02    LDA #$02 ; Text display mode 2
$A6FA: A0 08    LDY #$08 ; Text height (8 lines)
$A6FC: 20 B0 BD JSR prepare_display_and_input_scanning ; Initialize hardware for sector display
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
; ===============================================================================
TITLE_SCREEN_DATA:
; Character-based logo pattern for title screen display - 71 bytes
; Each byte represents a character code ($40-$4A) for block graphics
; Pattern is 12 blocks wide by 6 rows (last row has 11 blocks)
; Character $4A is background/space (used 27/71 times = 38%)
; 
; Logo Pattern (each character is 8x8 pixels) - Spells "CBS":
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

; ===============================================================================
; TITLE SCREEN TEXT DATA ($A7D4-$A839)
; ===============================================================================
TITLE_SCREEN_TEXT:
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
; collision_detection ($A83A-$A99B)
; Collision detection system with fire button processing
; 
; Called once per frame from main game loop after enemy sprite rendering.
; Handles all collision detection between enemies, missiles, playfield, and player.
; Uses GTIA hardware collision registers to detect overlaps and trigger game events.
;
; MAIN SECTIONS:
;
; 1. ENEMY-TO-ENEMY COLLISION DETECTION ($A844-$A8DD):
;
; 2. PLAYER MISSILE HIT DETECTION ($A8F6-$A930):
;
; 3. FIRE BUTTON PROCESSING ($A932-$A93E):
;
; 4. PLAYER EXIT DETECTION ($A941-$A967):
;
; 5. ENEMY MISSILE FIRING ($A969-$A995):
;
; 6. CLEANUP ($A996-$A99B):
;
; **SCORING SYSTEM**:
; - Enemy-to-Enemy Collision: 5 POINTS (strategic bonus)
; - Enemy missile hits: 1 POINT
; - Player missile hits enemy: 1 POINT
;
; **SPRITE ASSIGNMENTS**:
; - P0 = Player character
; - P1, P2, P3 = Three enemy sprites
; - M0 = Player's missile
; - M1, M2, M3 = Enemy missiles
;
; **COLLISION REGISTERS USED**:
; - $C004 (P0PF): Player to playfield - detects exit attempts
; - $C008 (M0PL): Player missile to enemies - detects hits
; - $C009-$C00B (P1PF-P3PF): Enemies to playfield - triggers enemy firing
; - $C00C (P0PL): Player to enemies - detects player death
; - $C00D-$C00F (M1PF-M3PF): Enemy missiles to playfield
; ===============================================================================
collision_detection:
$A83A: A6 D5    LDX $D5         ; Load current level/sector number
$A83C: B5 C5    LDA $C5,X       ; Load level statistics
$A83E: 85 92    STA $92         ; Store to working register
$A840: A5 94    LDA $94         ; Check enemy slot 1 status
$A842: D0 30    BNE $A874       ; Skip if enemy already defeated
; --- ENEMY SLOT 1: ENEMY-TO-ENEMY COLLISION (5 POINTS BONUS) ---
$A844: AD 0A C0 LDA $C00A       ; GTIA P2PF - Enemy 2 (P2) collision register
$A847: 0D 0B C0 ORA $C00B       ; OR with P3PF - Enemy 3 (P3) collision register
$A84A: 29 02    AND #$02        ; Check if Enemy 2 or 3 collided with Enemy 1
$A84C: F0 0F    BEQ $A85D       ; Branch if no collision
$A84E: A5 92    LDA $92         ; Load level statistics flag
$A850: D0 05    BNE $A857       ; Skip sound if already processed
$A852: A9 05    LDA #$05        ; **5 POINTS BONUS** - Enemy-to-enemy collision!
$A854: 20 6C BD JSR enemy_hit_scoring ; Add bonus to score and play hit sound
$A857: E6 D3    INC $D3         ; Increment hit counter (enemy defeated)
$A859: A9 01    LDA #$01
$A85B: 85 94    STA $94         ; Set enemy slot 1 to DEFEATED
; --- ENEMY SLOT 1: ENEMY MISSILE COLLISION (1 POINT) ---
$A85D: AD 0D C0 LDA $C00D       ; GTIA M1PF - Enemy 1 missile (M1) collision
$A860: 0D 05 C0 ORA $C005       ; OR with additional collision register
$A863: F0 0F    BEQ $A874       ; Branch if no collision
$A865: A5 92    LDA $92         ; Load level statistics flag
$A867: D0 05    BNE $A86E       ; Skip sound if already processed
$A869: A9 01    LDA #$01        ; **1 POINT** - Enemy missile hit something
$A86B: 20 6C BD JSR enemy_hit_scoring ; Add to score and play hit sound
$A86E: E6 D2    INC $D2         ; Increment hit counter
$A870: A9 01    LDA #$01
$A872: 85 94    STA $94         ; Set enemy slot 1 to DEFEATED
$A874: A5 95    LDA $95         ; Check enemy slot 2 status
$A876: D0 32    BNE $A8AA       ; Skip if enemy already defeated
; --- ENEMY SLOT 2: ENEMY-TO-ENEMY COLLISION (5 POINTS BONUS) ---
$A878: AD 09 C0 LDA $C009       ; GTIA P1PF - Enemy 1 (P1) collision register
$A87B: 0D 0B C0 ORA $C00B       ; OR with P3PF - Enemy 3 (P3) collision register
$A87E: 29 04    AND #$04        ; Check if Enemy 1 or 3 collided with Enemy 2
$A880: F0 0F    BEQ $A891       ; Branch if no collision
$A882: A5 92    LDA $92         ; Load level statistics flag
$A884: D0 05    BNE $A88B       ; Skip sound if already processed
$A886: A9 05    LDA #$05        ; **5 POINTS BONUS** - Enemy-to-enemy collision!
$A888: 20 6C BD JSR enemy_hit_scoring ; Add bonus to score and play hit sound
$A88B: E6 D3    INC $D3         ; Increment hit counter (enemy defeated)
$A88D: A9 01    LDA #$01
$A88F: 85 95    STA $95         ; Set enemy slot 2 to DEFEATED
; --- ENEMY SLOT 2: ENEMY MISSILE COLLISION (1 POINT) ---
$A891: AD 0E C0 LDA $C00E       ; GTIA M2PF - Enemy 2 missile (M2) collision
$A894: 0D 06 C0 ORA $C006       ; OR with additional collision register
$A897: F0 11    BEQ $A8AA       ; Branch if no collision
$A899: A5 92    LDA $92         ; Load level statistics flag
$A89B: D0 05    BNE $A8A2       ; Skip sound if already processed
$A89D: A9 01    LDA #$01        ; **1 POINT** - Enemy missile hit something
$A89F: 20 6C BD JSR enemy_hit_scoring ; Add to score and play hit sound
$A8A2: E6 D2    INC $D2         ; Increment hit counter
$A8A4: A9 01    LDA #$01
$A8A6: 85 95    STA $95         ; Set enemy slot 2 to DEFEATED
$A8A8: A9 01    LDA #$01        ; (Redundant load)
$A8AA: A5 96    LDA $96         ; Check enemy slot 3 status
$A8AC: D0 30    BNE $A8DE       ; Skip if enemy already defeated
; --- ENEMY SLOT 3: ENEMY-TO-ENEMY COLLISION (5 POINTS BONUS) ---
$A8AE: AD 09 C0 LDA $C009       ; GTIA P1PF - Enemy 1 (P1) collision register
$A8B1: 0D 0A C0 ORA $C00A       ; OR with P2PF - Enemy 2 (P2) collision register
$A8B4: 29 08    AND #$08        ; Check if Enemy 1 or 2 collided with Enemy 3
$A8B6: F0 0F    BEQ $A8C7       ; Branch if no collision
$A8B8: A5 92    LDA $92         ; Load level statistics flag
$A8BA: D0 05    BNE $A8C1       ; Skip sound if already processed
$A8BC: A9 05    LDA #$05        ; **5 POINTS BONUS** - Enemy-to-enemy collision!
$A8BE: 20 6C BD JSR enemy_hit_scoring ; Add bonus to score and play hit sound
$A8C1: E6 D3    INC $D3         ; Increment hit counter (enemy defeated)
$A8C3: A9 01    LDA #$01
$A8C5: 85 96    STA $96         ; Set enemy slot 3 to DEFEATED
; --- ENEMY SLOT 3: ENEMY MISSILE COLLISION (1 POINT) ---
$A8C7: AD 0F C0 LDA $C00F       ; GTIA M3PF - Enemy 3 missile (M3) collision
$A8CA: 0D 07 C0 ORA $C007       ; OR with additional collision register
$A8CD: F0 0F    BEQ $A8DE       ; Branch if no collision
$A8CF: A5 92    LDA $92         ; Load level statistics flag
$A8D1: D0 05    BNE $A8D8       ; Skip sound if already processed
$A8D3: A9 01    LDA #$01        ; **1 POINT** - Enemy missile hit something
$A8D5: 20 6C BD JSR enemy_hit_scoring ; Add to score and play hit sound
$A8D8: E6 D2    INC $D2         ; Increment hit counter
$A8DA: A9 01    LDA #$01
$A8DC: 85 96    STA $96         ; Set enemy slot 3 to DEFEATED
$A8DE: A9 00    LDA #$00
$A8E0: A9 01    LDA #$01
$A8E2: 85 AC    STA $AC
$A8E4: A5 D5    LDA $D5
$A8E6: C9 03    CMP #$03
$A8E8: 90 04    BCC $A8EE ; Branch if carry clear
$A8EA: A9 02    LDA #$02
$A8EC: 85 AC    STA $AC
$A8EE: A5 92    LDA $92
$A8F0: F0 04    BEQ $A8F6 ; Branch if equal/zero
$A8F2: A9 00    LDA #$00
$A8F4: 85 AC    STA $AC
; ===============================================================================
; PLAYER MISSILE vs ENEMY COLLISION DETECTION ($A8F6-$A930)
; **PLAYER MISSILE HIT DETECTION SYSTEM**
; 
; This code checks for player missile (M0) collisions with each of the 3 enemy
; sprites (P1, P2, P3). The game uses hardware collision detection to determine
; when the player's missile hits an enemy.
;
; **COLLISION DETECTION SYSTEM**:
; - Player missile (M0) collision with enemies (P1-P3) detected via hardware
; - Hardware collision register $C008 detects M0 hitting enemy sprites
; - Each bit represents collision with a different enemy:
;
; **HIT PROCESSING**:
; - When collision detected, enemy slot flag ($94/$95/$96) is set
; - Awards 1 POINT for standard ranged kill
; - Sound effect played and shot counter incremented
; - Enemy is marked as defeated, enabling level progression
; ===============================================================================
$A8F6: A5 94    LDA $94         ; Check enemy slot 1 status
$A8F8: D0 10    BNE $A90A       ; Skip if enemy already defeated
$A8FA: AD 08 C0 LDA $C008       ; **M0 COLLISION** - Read player missile collision register
$A8FD: 29 02    AND #$02        ; Check bit 1: Player missile (M0) hit Enemy 1 (P1)
$A8FF: F0 09    BEQ $A90A       ; Branch if no collision
$A901: A9 01    LDA #$01        ; **1 POINT** - Standard ranged kill
$A903: 85 94    STA $94         ; Set enemy slot 1 to DEFEATED
$A905: 20 66 BD JSR player_bonus_score_increase ; Add to score and play hit sound
$A908: E6 D4    INC $D4         ; Increment shot counter (accuracy tracking)
$A90A: A5 95    LDA $95         ; Check enemy slot 2 status
$A90C: D0 10    BNE $A91E       ; Skip if enemy already defeated
$A90E: AD 08 C0 LDA $C008       ; **M0 COLLISION** - Read player missile collision register
$A911: 29 04    AND #$04        ; Check bit 2: Player missile (M0) hit Enemy 2 (P2)
$A913: F0 09    BEQ $A91E       ; Branch if no collision
$A915: A9 01    LDA #$01        ; **1 POINT** - Standard ranged kill
$A917: 85 95    STA $95         ; Set enemy slot 2 to DEFEATED
$A919: 20 66 BD JSR player_bonus_score_increase ; Add to score and play hit sound
$A91C: E6 D4    INC $D4         ; Increment shot counter (accuracy tracking)
$A91E: A5 96    LDA $96         ; Check enemy slot 3 status
$A920: D0 10    BNE $A932       ; Skip if enemy already defeated
$A922: AD 08 C0 LDA $C008       ; **M0 COLLISION** - Read player missile collision register
$A925: 29 08    AND #$08        ; Check bit 3: Player missile (M0) hit Enemy 3 (P3)
$A927: F0 09    BEQ $A932       ; Branch if no collision
$A929: A9 01    LDA #$01        ; **1 POINT** - Standard ranged kill
$A92B: 85 96    STA $96         ; Set enemy slot 3 to DEFEATED
$A92D: 20 66 BD JSR player_bonus_score_increase ; Add to score and play hit sound
$A930: E6 D4    INC $D4         ; Increment shot counter (accuracy tracking)
$A932: AD 08 C0 LDA $C008       ; Read collision/fire button register
$A935: 29 0E    AND #$0E        ; Mask bits 1,2,3
$A937: 0D 00 C0 ORA $C000       ; Combine with base register
$A93A: F0 05    BEQ $A941       ; Branch if no fire button pressed
$A93C: A2 00    LDX #$00        ; Player missile slot (M0)
$A93E: 20 9C A9 JSR clear_missile_graphics ; Clear player missile after hit
; --- PLAYER EXIT DETECTION ($A941-$A967) ---
; Checks if player is touching playfield edges (attempting to exit arena)
$A941: A5 93    LDA $93         ; Check player collision flag
$A943: D0 24    BNE $A969       ; Branch if collision already detected
$A945: AD 09 C0 LDA $C009       ; Read P1PF - Enemy 1 to playfield collision
$A948: 0D 0A C0 ORA $C00A       ; OR with P2PF - Enemy 2 to playfield collision
$A94B: 0D 0B C0 ORA $C00B       ; OR with P3PF - Enemy 3 to playfield collision
$A94E: 29 01    AND #$01        ; Check if any enemy hit playfield
$A950: D0 13    BNE $A965       ; Branch if enemy-playfield collision detected
; **PLAYER EXIT DETECTION** - Check if player touching arena edges
$A952: AD 04 C0 LDA $C004       ; **P0PF** - Read Player 0 to Playfield collision
$A955: 29 04    AND #$04        ; Check bit 2 (specific playfield color for exits)
$A957: F0 04    BEQ $A95D       ; Branch if player not at exit
$A959: A9 01    LDA #$01        ; Player is at exit!
$A95B: 85 AD    STA $AD         ; **SET EXIT FLAG** - Triggers sector exit processing
$A95D: AD 04 C0 LDA $C004       ; Read P0PF again
$A960: 0D 0C C0 ORA $C00C       ; OR with P0PL - Player 0 to Player collision
$A963: F0 04    BEQ $A969       ; Branch if no collision
$A965: A9 01    LDA #$01        ; Collision detected
$A967: 85 93    STA $93         ; Set general collision flag
; --- ENEMY MISSILE FIRING ($A969-$A995) ---
; When enemies collide with playfield, they fire missiles
$A969: AD 09 C0 LDA $C009       ; Read P1PF - Enemy 1 to playfield collision
$A96C: 29 0D    AND #$0D        ; Mask specific playfield bits
$A96E: 0D 01 C0 ORA $C001       ; OR with M1PF - Missile 1 to playfield
$A971: F0 05    BEQ $A978       ; Branch if no collision
$A973: A2 01    LDX #$01        ; Enemy 1 missile slot (M1)
$A975: 20 9C A9 JSR clear_missile_graphics ; Clear enemy 1 missile after hit
$A978: AD 0A C0 LDA $C00A       ; Read P2PF - Enemy 2 to playfield collision
$A97B: 29 0B    AND #$0B        ; Mask specific playfield bits
$A97D: 0D 02 C0 ORA $C002       ; OR with M2PF - Missile 2 to playfield
$A980: F0 05    BEQ $A987       ; Branch if no collision
$A982: A2 02    LDX #$02        ; Enemy 2 missile slot (M2)
$A984: 20 9C A9 JSR clear_missile_graphics ; Clear enemy 2 missile after hit
$A987: AD 0B C0 LDA $C00B       ; Read P3PF - Enemy 3 to playfield collision
$A98A: 29 07    AND #$07        ; Mask specific playfield bits
$A98C: 0D 03 C0 ORA $C003       ; OR with M3PF - Missile 3 to playfield
$A98F: F0 05    BEQ $A996       ; Branch if no collision
$A991: A2 03    LDX #$03        ; Enemy 3 missile slot (M3)
$A993: 20 9C A9 JSR clear_missile_graphics ; Clear enemy 3 missile after hit
$A996: A9 00    LDA #$00        ; Clear accumulator
$A998: 8D 1E C0 STA $C01E       ; GTIA HITCLR - Clear all collision registers
$A99B: 60       RTS             ; Return from collision_detection
; ===============================================================================
; CLEAR_MISSILE_GRAPHICS ($A99C-$A9B5)
; **MISSILE GRAPHICS ERASING ROUTINE**
; 
; Clears missile graphics from PMG memory after collisions. Uses bit masks to
; clear specific horizontal pixel columns where missiles are drawn.
;
; **PARAMETERS**:
; - X: Missile slot (0-3)
;
; **BIT MASK TABLE ($BF7C)**:
; - $BF7C: $03 (00000011) - Player missile column
; - $BF7D: $0C (00001100) - Enemy 1 missile column
; - $BF7E: $30 (00110000) - Enemy 2 missile column
; - $BF7F: $C0 (11000000) - Enemy 3 missile column
;
; **FUNCTION**:
; 1. Loads missile Y position from $E2+X
; 2. Clears position slot ($E2+X = 0) to deactivate missile
; 3. Decrements Y position
; 4. Calls erase subroutine twice (clears 2 scanlines)
; 5. Erase subroutine:
;
; **CONTEXT**:
; Called after collision detection when missiles hit targets. Removes the
; missile graphics from screen and frees the missile slot for reuse.
; ===============================================================================
clear_missile_graphics:
$A99C: B4 E2    LDY $E2,X       ; Load missile Y position from array ($E2-$E5)
$A99E: A9 00    LDA #$00        ; Clear accumulator
$A9A0: 95 E2    STA $E2,X       ; Clear missile position slot (deactivate missile)
$A9A2: 88       DEY             ; Decrement Y position
$A9A3: 20 A9 A9 JSR $A9A9       ; Call erase subroutine (clear scanline 1)
$A9A6: 20 A9 A9 JSR $A9A9       ; Call erase subroutine (clear scanline 2)
$A9A9: BD 7C BF LDA $BF7C,X     ; Load bit mask from table
$A9AC: 49 FF    EOR #$FF        ; Invert mask to preserve other pixels
$A9AE: 39 00 13 AND $1300,Y     ; AND with PMG memory (clears missile pixels)
$A9B1: 99 00 13 STA $1300,Y     ; Store cleared graphics back to PMG memory
$A9B4: C8       INY             ; Increment Y (next scanline)
$A9B5: 60       RTS             ; Return
; ===============================================================================
; SECTOR INITIALIZATION ($A9B6) - PROCEDURAL ARENA GENERATOR
; ===============================================================================
; Initializes a new sector/level with procedurally generated arena
; This routine is called:
; - At game start (back_to_init_sector at $A32F) for the initial sector
; - When advancing to new sectors ($A388) after completing a level
;
; PHASES:
; 1. Clear Game State - Reset sprite/sound variables
; 2. Display System Setup - Configure graphics mode and display lists
; 3. Difficulty Configuration - Load level-specific parameters
; 4. Player Sprite Initialization - Set starting position and character
; 5. **PROCEDURAL ARENA GENERATION** - Build randomized maze (39 elements)
; 6. Score Display Setup - Configure HUD and statistics areas
; 7. Final System Configuration - Complete level setup
;
; Each call generates a fresh arena layout for the new sector.
; ===============================================================================

$A9B6: 20 BD BD init_sector:
                JSR clear_game_state ; **PHASE 1: CLEAR GAME STATE** - Reset sprite/sound variables
$A9B9: 20 A2 BD JSR clear_collision_registers ; **PHASE 2: CLEAR COLLISION DETECTION** - Reset hardware registers
$A9BC: AD 3A 06 LDA $063A       ; **DIFFICULTY/SPEED CONFIGURATION**
$A9BF: 0D 39 06 ORA $0639       ; Combine speed settings from multiple memory locations
$A9C2: 0D 37 06 ORA $0637       ; Set initial game speed based on level
$A9C5: 0D 36 06 ORA $0636       ; Aggregate all speed/difficulty parameters
$A9C8: C9 30    CMP #$30        ; Compare with difficulty threshold ($30 = 48 decimal)
$A9CA: D0 03    BNE $A9CF       ; Branch to different init path if not standard difficulty
$A9CC: 4C 0D AB JMP $AB0D       ; Jump to final configuration for high difficulty levels
$A9CF: A6 D5    LDX $D5         ; **LEVEL-BASED INITIALIZATION PATH**
$A9D1: F0 04    BEQ $A9D7       ; Branch if level 0 (first level)
$A9D3: 4E 89 B6 LSR $B689       ; Modify level-specific data for higher levels
$A9D6: CA       DEX             ; Decrement level counter for processing
$A9D7: B5 C5    LDA $C5,X       ; Load level-specific configuration data
$A9D9: C9 02    CMP #$02        ; Check configuration threshold
$A9DB: 90 03    BCC $A9E0       ; Branch to normal init if below threshold
$A9DD: 4C 0D AB JMP $AB0D       ; Jump to final config for special levels
$A9E0: 20 D6 AA JSR animated_screen_transition ; **ANIMATED TRANSITION** - Only for level > 0
$A9E3: 20 0C AC JSR $AC0C       ; Screen update/refresh routine
$A9E6: 20 0C AC JSR $AC0C       ; Double refresh for stability
$A9E9: A5 0D    LDA $0D         ; Load system parameter
$A9EB: 85 92    STA $92         ; Store in game state variable
$A9ED: A9 38    LDA #$38        ; Load sprite parameter ($38 = 56 decimal)
$A9EF: 85 A6    STA $A6         ; Store sprite configuration
$A9F1: A5 0D    LDA $0D         ; Reload system parameter
$A9F3: 85 A4    STA $A4         ; Store in secondary location
$A9F5: 20 F3 AB JSR $ABF3       ; Additional sprite setup routine
$A9F8: A9 04    LDA #$04        ; **SPRITE CONTROL SETUP**
$A9FA: 8D 08 E8 STA $E808       ; Configure sprite control register
$A9FD: A9 AC    LDA #$AC        ; Load sprite parameter
$A9FF: 8D 01 E8 STA $E801       ; Set sprite configuration register
$AA02: A9 00    LDA #$00        ; **INITIALIZE ARENA COUNTER**
$AA04: 85 54    STA $54         ; Clear arena element counter (starts at 0)
$AA06: 8D 00 E8 STA $E800       ; Clear sprite position register
$AA09: A9 A0    LDA #$A0        ; **DEFAULT PLAYER SPRITE CHARACTER**
$AA0B: 8D 05 E8 STA $E805       ; Load Character $A0 into player sprite register
$AA0E: A9 14    LDA #$14        ; **PLAYER STARTING POSITION**
$AA10: 8D 04 E8 STA $E804       ; Set player sprite X position to $14 (20 decimal)
$AA13: A9 00    LDA #$00        ; **PHASE 3: PROCEDURAL ARENA GENERATION LOOP**
$AA15: 85 69    STA $69         ; Clear arena generation parameter
$AA17: A9 4D    LDA #$4D        ; Load arena element type ($4D = 77 decimal)
$AA19: 85 55    STA $55         ; Store element type for placement
$AA1B: 20 D9 AC JSR $ACD9       ; **ARENA ELEMENT PLACEMENT ROUTINE** - Places maze/arena elements
$AA1E: E6 54    INC $54         ; **INCREMENT ARENA COUNTER** - Move to next element position
$AA20: A5 54    LDA $54         ; Load current arena element count
$AA22: 8D 00 E8 STA $E800       ; Update position register with element count
$AA25: C9 27    CMP #$27        ; **CHECK ARENA COMPLETION** - Compare with 39 decimal (total elements)
$AA27: F0 1C    BEQ $AA45       ; Branch to completion when all 39 elements placed
$AA29: A9 AA    LDA #$AA        ; **ALTERNATE ELEMENT TYPE** - Different arena element
$AA2B: 85 69    STA $69         ; Store alternate element parameter
$AA2D: A9 02    LDA #$02        ; Load element variation
$AA2F: 85 55    STA $55         ; Store variation type
$AA31: A9 4D    LDA #$4D        ; Reload primary element type
$AA33: 85 55    STA $55         ; Store for next placement
$AA35: 20 D9 AC JSR $ACD9       ; **PLACE NEXT ARENA ELEMENT** - Continue building maze
$AA38: A2 64    LDX #$64        ; **VISUAL GENERATION DELAY** - Load delay counter (100 decimal)
$AA3A: A0 00    LDY #$00        ; Initialize inner delay counter
$AA3C: 88       DEY             ; Decrement inner counter (256 iterations)
$AA3D: D0 FD    BNE $AA3C       ; Inner delay loop - creates visible generation timing
$AA3F: CA       DEX             ; Decrement outer counter
$AA40: D0 F8    BNE $AA3A       ; Outer delay loop - allows player to see arena being built
$AA42: 4C 13 AA JMP $AA13       ; **CONTINUE ARENA GENERATION** - Loop back for next element
$AA45: A9 A0    LDA #$A0        ; **PHASE 4: ARENA GENERATION COMPLETE**
$AA47: 8D 01 E8 STA $E801       ; Finalize sprite configuration
$AA4A: 20 B0 BD JSR prepare_display_and_input_scanning ; **SCORE DISPLAY SYSTEM SETUP** - Initialize hardware
$AA4D: A5 92    LDA $92         ; Load game state parameter
$AA4F: 85 0D    STA $0D         ; Store in zero page for fast access
$AA51: A9 00    LDA #$00        ; Clear secondary parameter
$AA53: 85 0E    STA $0E         ; Store cleared value
$AA55: A9 A2    LDA #$A2        ; **SCORE DISPLAY MEMORY SETUP**
$AA57: A2 A6    LDX #$A6        ; Load display parameters
$AA59: 85 06    STA $06         ; Store display pointer low byte
$AA5B: 86 05    STX $05         ; Store display pointer high byte
$AA5D: 20 93 AC JSR $AC93
$AA60: 20 CB AC JSR $ACCB
$AA63: A2 04    LDX #$04
$AA65: BD B4 AC LDA $ACB4
$AA68: 18       CLC
$AA69: 69 20    ADC #$20
$AA6B: 9D 14 2C STA $2C14
$AA6E: CA       DEX
$AA6F: 10 F4    BPL $AA65
$AA71: A4 D5    LDY $D5         ; **LEVEL-BASED SCORE DISPLAY CONFIGURATION**
$AA73: C0 04    CPY #$04        ; Check if level 4 or higher
$AA75: 90 0E    BCC $AA85       ; Branch to standard setup if below level 4
$AA77: A2 04    LDX #$04        ; **HIGH LEVEL SCORE SETUP** - Load counter for 5 elements
$AA79: BD AF AC LDA $ACAF,X     ; Load high-level score display data
$AA7C: 18       CLC             ; Clear carry for addition
$AA7D: 69 20    ADC #$20        ; Add offset for screen memory location
$AA7F: 9D 14 2C STA $2C14,X     ; **STORE TO SCORE AREA 1** - Screen memory $2C14-$2C18
$AA82: CA       DEX             ; Decrement counter
$AA83: 10 F4    BPL $AA79       ; Loop for all 5 score elements
$AA85: 20 0C AC JSR $AC0C       ; Screen refresh after score setup
$AA88: A5 D4    LDA $D4         ; Load score counter 1
$AA8A: A0 64    LDY #$64        ; Load display parameter (100 decimal)
$AA8C: 20 26 AC JSR $AC26       ; Update score display routine
$AA8F: 20 0C AC JSR $AC0C       ; Screen refresh
$AA92: 20 0C AC JSR $AC0C       ; Double refresh for stability
$AA95: A2 03    LDX #$03        ; **SCORE AREA 2 SETUP** - Load counter for 4 elements
$AA97: BD B9 AC LDA $ACB9,X     ; Load score display data for area 2
$AA9A: 18       CLC             ; Clear carry
$AA9B: 69 20    ADC #$20        ; Add screen memory offset
$AA9D: 9D 65 2C STA $2C65,X     ; **STORE TO SCORE AREA 2** - Screen memory $2C65-$2C68
$AAA0: CA       DEX             ; Decrement counter
$AAA1: 10 F4    BPL $AA97       ; Loop for all 4 elements
$AAA3: A5 D3    LDA $D3         ; Load score counter 2
$AAA5: A0 32    LDY #$32        ; Load display parameter (50 decimal)
$AAA7: 20 26 AC JSR $AC26       ; Update score display
$AAAA: 20 0C AC JSR $AC0C       ; Screen refresh
$AAAD: 20 0C AC JSR $AC0C       ; Double refresh
$AAB0: A2 03    LDX #$03        ; **SCORE AREA 3 SETUP** - Load counter for 4 elements
$AAB2: BD BD AC LDA $ACBD,X     ; Load score display data for area 3
$AAB5: 18       CLC             ; Clear carry
$AAB6: 69 20    ADC #$20        ; Add screen memory offset
$AAB8: 9D A1 2C STA $2CA1,X     ; **STORE TO SCORE AREA 3** - Screen memory $2CA1-$2CA4
$AABB: CA       DEX             ; Decrement counter
$AABC: 10 F4    BPL $AAB2       ; Loop for all 4 elements
$AABE: A0 0A    LDY #$0A        ; Load final display parameter (10 decimal)
$AAC0: 20 0C AC JSR $AC0C       ; Screen refresh
$AAC3: A5 D2    LDA $D2         ; Load score counter 3
$AAC5: 20 26 AC JSR $AC26       ; Update final score display
$AAC8: A9 06    LDA #$06        ; **PHASE 5: FINAL SYSTEM CONFIGURATION**
$AACA: 85 69    STA $69         ; Set final countdown parameter (6 iterations)
$AACC: 20 0C AC JSR $AC0C       ; Screen refresh
$AACF: C6 69    DEC $69         ; Decrement countdown
$AAD1: D0 F9    BNE $AACC       ; Loop until countdown complete (6 refreshes)
$AAD3: 4C 0D AB JMP $AB0D       ; **JUMP TO FINAL CONFIGURATION** - Complete arena generation
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
; ANIMATED_SCREEN_TRANSITION ($AAD6-$AB01)
; **CLEVER SCREEN CLEARING ANIMATION**
; 
; This routine creates a visual transition effect when advancing to a new sector.
; Only called when level > 0 (not on first level).
;
; **ANIMATION EFFECT**:
; - Counts down from $50 (80) to $10 (16) in $E800 register
; - Each iteration calls delay routine at $AB02
; - Creates smooth visual transition between sectors
; - Provides player feedback that level is changing
;
; **FLOW**:
; 1. Save registers (A, X, Y) on stack
; 2. Initialize $E808 = $00, $E801 = $AC, $E800 = $50
; 3. Loop: Decrement $E800, delay, repeat until $E800 = $10
; 4. Clear $E801
; 5. Restore registers and return
; ===============================================================================
animated_screen_transition:
$AAD6: 48       PHA             ; Save accumulator
$AAD7: 98       TYA             ; Transfer Y to A
$AAD8: 48       PHA             ; Save Y register
$AAD9: 8A       TXA             ; Transfer X to A
$AADA: 48       PHA             ; Save X register
$AADB: A9 00    LDA #$00        ; Clear value
$AADD: 8D 08 E8 STA $E808       ; Initialize register $E808
$AAE0: A9 AC    LDA #$AC        ; Load animation parameter
$AAE2: 8D 01 E8 STA $E801       ; Set register $E801 (audio/visual control)
$AAE5: A9 50    LDA #$50        ; **START ANIMATION** - Load $50 (80 decimal)
$AAE7: 8D 00 E8 STA $E800       ; Store to animation register
$AAEA: 20 02 AB JSR $AB02       ; **DELAY ROUTINE** - Creates visible animation timing
$AAED: 38       SEC             ; Set carry for subtraction
$AAEE: E9 01    SBC #$01        ; **DECREMENT ANIMATION** - Subtract 1
$AAF0: 8D 00 E8 STA $E800       ; Update animation register
$AAF3: C9 10    CMP #$10        ; Check if reached $10 (16 decimal)
$AAF5: D0 F3    BNE $AAEA       ; **LOOP** - Continue animation until $10
$AAF7: A9 00    LDA #$00        ; Clear value
$AAF9: 8D 01 E8 STA $E801       ; Clear control register
$AAFC: 68       PLA             ; Restore X register
$AAFD: AA       TAX             ; Transfer to X
$AAFE: 68       PLA             ; Restore Y register
$AAFF: A8       TAY             ; Transfer to Y
$AB00: 68       PLA             ; Restore accumulator
$AB01: 60       RTS             ; Return from animation
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

$AB0D: A5 DA    LDA $DA
$AB0F: C9 03    CMP #$03
$AB11: D0 03    BNE $AB16 ; Loop back if not zero
$AB13: 4C D2 AB JMP $ABD2
$AB16: A5 D9    LDA $D9
$AB18: C9 02    CMP #$02 ; Calculate enemy speed
$AB1A: D0 03    BNE $AB1F ; Loop back if not zero
$AB1C: 4C D2 AB JMP $ABD2 ; Calculate spawn rate
$AB1F: 20 B0 BD JSR prepare_display_and_input_scanning ; Initialize hardware
$AB22: A9 7C    LDA #$7C
$AB24: 85 0D    STA $0D
$AB26: A9 00    LDA #$00
$AB28: 85 0E    STA $0E
$AB2A: 20 93 AC JSR $AC93
$AB2D: A5 94    LDA $94
$AB2F: F0 2E    BEQ $AB5F ; Branch if equal/zero
$AB31: A5 95    LDA $95
$AB33: F0 2A    BEQ $AB5F ; Branch if equal/zero
$AB35: A5 96    LDA $96
$AB37: F0 26    BEQ $AB5F ; Branch if equal/zero
$AB39: A5 D4    LDA $D4
$AB3B: C5 D1    CMP #$D1
$AB3D: 90 20    BCC $AB5F ; Branch if carry clear
$AB3F: A6 D5    LDX $D5
$AB41: F0 01    BEQ $AB44 ; Branch if equal/zero
$AB43: CA       DEX
$AB44: B5 C5    LDA $C5,X
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
$ABA2: 20 17 B1 JSR play_audio_tone ; **FLASHING EFFECT** - toggles text visibility
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

$ABF3: A4 A6    LDY $A6 ; Enemy spawning and management system
$ABF5: 20 B0 BD JSR prepare_display_and_input_scanning ; Initialize hardware
$ABF8: A9 00    LDA #$00
$ABFA: 85 0E    STA $0E
$ABFC: A5 92    LDA $92
$ABFE: 85 0D    STA $0D
$AC00: A5 A4    LDA $A4
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

; ===============================================================================
; SCREEN_MEMORY_MANAGEMENT ($ACC1-$AD04)
; ===============================================================================
; Screen memory clearing and character positioning routines
; - Clears screen memory areas ($2400, $2C00-$2D00)
; - Complex screen positioning calculations using indirect addressing
; - Character placement and screen coordinate management
; ===============================================================================
$ACC1: A2 00    LDX #$00
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
; ===============================================================================
; ARENA_ELEMENT_PLACEMENT ($ACD9-$AD04)
; ===============================================================================
; **CORE ARENA GENERATION ROUTINE WITH EXIT PLACEMENT LOGIC**
; This routine places individual maze/arena elements during procedural generation.
; Called 39 times by GAME_INIT to build the complete arena layout.
; 
; **SPECIAL EXIT ELEMENT HANDLING**:
; While most elements are placed sequentially with standard wall/empty patterns,
; specific elements receive special treatment for exit placement:
; - Element 2: LEFT WALL EXIT - Modified pattern creates opening in left perimeter
; - Element 38: RIGHT WALL EXIT - Modified pattern creates opening in right perimeter
; - Exit vertical position determined by random value from $6C (0-5 range)
; - Other elements (0-1, 3-37, 39) use standard wall/obstacle patterns
;
; INPUT PARAMETERS:
; - $54: Arena element counter (0-38, incremented by caller)
; - $55: Element type ($4D or $02 - different maze components)  
; - $69: Element parameter ($00 or $AA - element variation, modified for exits)
; - $6C: Random exit position (0-5, from hardware randomization at $B9D6)
;
; ALGORITHM:
; 1. Calculate screen memory address based on element counter
; 2. Check if current element is exit element (2 or 38)
; 3. Apply exit-specific pattern modifications if needed
; 4. Use mathematical positioning to place element in arena grid
; 5. Store element data to screen memory for visual display
; ===============================================================================

$ACD9: A9 00    LDA #$00        ; **STEP 1: INITIALIZE CALCULATION VARIABLES**
$ACDB: 85 7C    STA $7C         ; Clear screen address low byte
$ACDD: 85 7D    STA $7D         ; Clear screen address high byte
$ACDF: A5 54    LDA $54         ; **STEP 2: LOAD ARENA ELEMENT COUNTER** (0-38)
$ACE1: 18       CLC             ; Clear carry for arithmetic
$ACE2: 2A       ROL             ; **MULTIPLY BY 4** - Rotate left (x2)
$ACE3: 2A       ROL             ; Rotate left again (x4) - Each element needs 4 bytes
$ACE4: 85 C2    STA $C2         ; Store intermediate result (element_count * 4)
$ACE6: 2A       ROL             ; **MULTIPLY BY 8** - Continue rotation (x8)
$ACE7: 26 7D    ROL $7D         ; Rotate carry into high byte
$ACE9: 2A       ROL             ; **MULTIPLY BY 16** - Final rotation (x16)
$ACEA: 26 7D    ROL $7D         ; Rotate carry into high byte (element_count * 16)
$ACEC: 65 C2    ADC $C2         ; **ADD INTERMEDIATE RESULT** - (16 * count) + (4 * count) = 20 * count
$ACEE: 85 7C    STA $7C         ; Store final address offset low byte
$ACF0: 90 02    BCC $ACF4       ; Branch if no carry from addition
$ACF2: E6 7D    INC $7D         ; Increment high byte if carry occurred
$ACF4: A9 28    LDA #$28        ; **STEP 3: ADD SCREEN MEMORY BASE** - Load screen base ($28xx)
$ACF6: 18       CLC             ; Clear carry
$ACF7: 65 7D    ADC $7D         ; Add to calculated high byte
$ACF9: 85 7D    STA $7D         ; Store final screen memory high byte
$ACFB: A5 69    LDA $69         ; **STEP 4: LOAD ELEMENT DATA** - Get element parameter ($00 or $AA)
$ACFD: A0 13    LDY #$13        ; **ELEMENT SIZE** - Load counter for 20 bytes (19+1)
$ACFF: 91 7C    STA ($7C),Y     ; **PLACE ELEMENT** - Store element data to screen memory
$AD01: 88       DEY             ; Decrement byte counter
$AD02: 10 FB    BPL $ACFF       ; **FILL ELEMENT BLOCK** - Loop until all 20 bytes placed
$AD04: 60       RTS             ; Return to arena generation loop
; ===============================================================================
; MAJOR INPUT/MOVEMENT PROCESSING SECTION ($AD05-$AF03)
; ===============================================================================
INPUT_HANDLING_SYSTEM:
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

process_player_input:
$AD05: A5 84    LDA $84         ; Load current player Y position
$AD07: 85 77    STA $77         ; Store for sprite positioning
$AD09: 20 EB BD JSR process_joystick_input ; Call sprite update routine
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
$AF39: 20 7C BC JSR copy_sprite_data ; Copy sprite data to PMG memory
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
$AF58: 20 58 BC JSR update_hpos ; Call sprite setup routine
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
$AF71: 20 7C BC JSR copy_sprite_data ; Copy sprite data to PMG memory
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
$AF8C: 20 58 BC JSR update_hpos ; Call sprite setup routine
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
$AFA5: 20 7C BC JSR copy_sprite_data ; Copy sprite data to PMG memory
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

pmg_system_init:
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
$B027: 20 BD BD JSR clear_game_state ; **CLEAR GAME STATE** - Reset sprite/sound variables
$B02A: A9 07    LDA #$07        ; **SET SOUND PARAMETERS** - Load sound value
$B02C: A2 A6    LDX #$A6        ; Load sound parameter X
$B02E: A0 3B    LDY #$3B        ; Load sound parameter Y
$B030: 4C D5 BD JMP configure_display_list       ; **JUMP TO SOUND SETUP** - Initialize audio system
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
; PLAYER DEATH MUSIC GENERATOR ($B097-$B0FC)
; **HARDCODED MELODIC DEATH SEQUENCE** - Creates the player death music
; 
; **FREQUENCY DECISION SYSTEM**:
; The death music uses a FIXED MELODIC SEQUENCE with hardcoded frequency values:
; 
; **DEATH MELODY SEQUENCE**:
; 1. $5B (91 decimal) - Initial death tone (low/somber)
; 2. $60 (96 decimal) - Rising tone (slightly higher)
; 3. $4C (76 decimal) - Falling tone (lower/sadder)
; 4. $51 (81 decimal) - Recovery tone (mid-range)
; 5. $5B (91 decimal) - Return to initial (repetition)
; 6. $60 (96 decimal) - Final rising tone (conclusion)
; 7. $5B (91 decimal) - Final death tone (ending)
;
; **SOUND PARAMETER ALTERNATION**:
; - **Setup 1** ($B10A): Parameters $2E, $7A, $4A - Brighter/sharper tone
; - **Setup 2** ($B0FD): Parameters $1C, $3E, $2A - Darker/muted tone
; - Alternates between setups to create tonal variation within the melody
;
; **POKEY FREQUENCY CALCULATION**:
; POKEY frequency = 1.79MHz / (2 × (frequency_value + 1))
; - $5B (91): ~9,830 Hz - Deep, somber tone
; - $60 (96): ~9,226 Hz - Slightly higher, rising
; - $4C (76): ~11,636 Hz - Higher pitch, falling effect
; - $51 (81): ~10,915 Hz - Mid-range recovery
;
; **MUSICAL STRUCTURE**:
; The sequence creates a "death melody" with:
; - Initial somber tone (death recognition)
; - Rising tone (struggle/resistance)  
; - Falling tone (defeat/sadness)
; - Recovery attempt (brief hope)
; - Return to somber (acceptance)
; - Final resolution (death complete)
;
; This is NOT a data-driven system - it's a carefully composed musical sequence
; hardcoded into the game to create a specific emotional death experience.
; ===============================================================================

$B097: A9 5B    LDA #$5B        ; **START COMPLEX SOUND** - Load initial frequency
$B099: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B09C: 20 0A B1 JSR $B10A       ; **CALL SOUND SETUP 1** - Configure sound parameters
$B09F: 20 17 B1 JSR play_audio_tone ; **PLAY AUDIO TONE** - Create timed audio output
$B0A2: 20 17 B1 JSR play_audio_tone ; **PLAY AUDIO TONE** - Repeat for emphasis
$B0A5: 20 FD B0 JSR $B0FD       ; **CALL SOUND SETUP 2** - Configure alternate parameters
$B0A8: 20 17 B1 JSR play_audio_tone ; **PLAY AUDIO TONE** - Create timed audio output
$B0AB: 20 0A B1 JSR $B10A       ; Call sound setup 1 (return to original)
$B0AE: A9 60    LDA #$60        ; **CHANGE FREQUENCY** - Load new frequency
$B0B0: 85 BC    STA $BC         ; Store frequency parameter
$B0B2: 20 17 B1 JSR play_audio_tone ; **PLAY AUDIO TONE** - Create timed audio output with new frequency
$B0B5: A9 4C    LDA #$4C        ; **FREQUENCY TRANSITION** - Load transition frequency
$B0B7: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0BA: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0BD: 20 17 B1 JSR play_audio_tone ; **PLAY AUDIO TONE** - Create timed audio output
$B0C0: A9 51    LDA #$51        ; **CONTINUE SEQUENCE** - Load next frequency
$B0C2: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0C5: 20 FD B0 JSR $B0FD       ; Call sound setup 2
$B0C8: 20 17 B1 JSR play_audio_tone ; Call flashing effect
$B0CB: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0CE: 20 17 B1 JSR play_audio_tone ; Call flashing effect
$B0D1: A9 5B    LDA #$5B        ; **RETURN TO START** - Load original frequency
$B0D3: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0D6: 20 FD B0 JSR $B0FD       ; Call sound setup 2
$B0D9: 20 17 B1 JSR play_audio_tone ; Call flashing effect
$B0DC: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0DF: 20 17 B1 JSR play_audio_tone ; Call flashing effect
$B0E2: A9 60    LDA #$60        ; **FINAL FREQUENCY** - Load ending frequency
$B0E4: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0E7: 20 FD B0 JSR $B0FD       ; Call sound setup 2
$B0EA: 20 17 B1 JSR play_audio_tone ; Call flashing effect
$B0ED: A9 5B    LDA #$5B        ; **SEQUENCE END** - Load final frequency
$B0EF: 8D 00 E8 STA $E800       ; Set audio frequency channel 1
$B0F2: 20 0A B1 JSR $B10A       ; Call sound setup 1
$B0F5: A9 FF    LDA #$FF        ; **SET END FLAG** - Load completion flag
$B0F7: 85 BC    STA $BC         ; Store completion flag
$B0F9: 20 17 B1 JSR play_audio_tone ; Call flashing effect (final)
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
; AUDIO TONE DURATION CONTROLLER ($B117-$B14E)
; ===============================================================================
; **AUDIO TONE TIMING AND DURATION SYSTEM**
; This routine controls the duration and timing of audio tones by managing
; POKEY audio control register $E801. It creates precisely timed audio effects
; using the parameters set by the sound setup routines ($B10A/$B0FD).
; 
; **AUDIO CONTROL PARAMETERS**:
; - $BA: Phase A timing parameter (controls initial tone duration)
; - $BB: Phase B timing parameter (controls sustain duration)  
; - $BC: Phase C timing parameter (controls release/fade duration)
; 
; **THREE-PHASE AUDIO CONTROL**:
; 1. **Phase A**: Initial tone with $A0 control value, duration based on $BA
; 2. **Phase B**: Sustain phase with $0E control value, duration based on $BB
; 3. **Phase C**: Release phase with $AF control value, duration based on $BC
; 
; **HARDWARE INTEGRATION**:
; - Writes to $E801 (POKEY Audio Control Channel 1) to control tone characteristics
; - Uses nested timing loops for precise duration control
; - Creates the actual "note duration" for each frequency set in $E800
; - No visual effects - this is purely audio timing control
; 
; **USAGE IN DEATH MUSIC**:
; Each JSR $B117 call creates one "note" of the specified duration based on
; the current sound setup parameters (Setup 1 = longer notes, Setup 2 = shorter notes)
; ===============================================================================

play_audio_tone:
$B117: A9 A0    LDA #$A0        ; **PHASE A: INITIAL TONE** - Load audio control value
$B119: 8D 01 E8 STA $E801       ; **AUDC1** - Set audio control register (tone characteristics)
$B11C: A6 BA    LDX $BA         ; **LOAD PHASE A DURATION** - Get timing parameter from sound setup
$B11E: 20 46 B1 JSR $B146       ; **CALL TIMING DELAY** - Create precise tone duration
$B121: 18       CLC             ; Clear carry flag
$B122: 69 01    ADC #$01        ; Increment phase counter
$B124: C9 B0    CMP #$B0        ; Check if Phase A complete ($A0 + 16 = $B0)
$B126: D0 F1    BNE $B119       ; Loop back if phase not complete (continue Phase A)
$B128: A9 0E    LDA #$0E        ; **PHASE B: SUSTAIN TONE** - Load sustain control value
$B12A: A6 BB    LDX $BB         ; **LOAD PHASE B DURATION** - Get sustain timing parameter
$B12C: 20 46 B1 JSR $B146       ; Call timing delay for sustain phase
$B12F: 38       SEC             ; Set carry flag
$B130: E9 01    SBC #$01        ; Decrement Phase B counter
$B132: D0 F6    BNE $B12A       ; Loop back if sustain not complete (continue Phase B)
$B134: A9 AF    LDA #$AF        ; **PHASE C: RELEASE/FADE** - Load release control value
$B136: 8D 01 E8 STA $E801       ; **AUDC1** - Set audio control for release phase
$B139: A6 BC    LDX $BC         ; **LOAD PHASE C DURATION** - Get release timing parameter
$B13B: 20 46 B1 JSR $B146       ; Call timing delay for release phase
$B13E: 38       SEC             ; Set carry flag
$B13F: E9 01    SBC #$01        ; Decrement Phase C counter
$B141: C9 9F    CMP #$9F        ; Check if release complete ($AF - 16 = $9F)
$B143: D0 F1    BNE $B136       ; Loop back if release not complete (continue Phase C)
$B145: 60       RTS             ; **RETURN** - Audio tone duration complete

; **PRECISION TIMING DELAY ROUTINE** ($B146-$B14E):
; Creates precise timing delays for audio tone duration control
$B146: A0 13    LDY #$13        ; **TIMING DELAY** - Load inner delay counter (19 cycles)
$B148: 88       DEY             ; Decrement inner delay counter
$B149: D0 FD    BNE $B148       ; Loop until inner counter reaches zero
$B14B: CA       DEX             ; Decrement outer delay counter (X register)
$B14C: D0 F8    BNE $B146       ; Loop back to inner delay until X reaches zero
$B14E: 60       RTS             ; Return from timing delay routine
; ===============================================================================
; MISSILE_MOVEMENT_AND_ANIMATION ($B14F-$B23C)
; ===============================================================================
; **PLAYER MISSILE MOVEMENT AND SPRITE ANIMATION SYSTEM**
; This routine handles player-fired missile movement and associated sprite
; animations. It processes up to 4 active missiles ($E2-$E5) and updates
; their positions based on movement direction ($88).
;
; **FUNCTION**:
; 1. Checks timing counter ($A8) - only processes every Nth frame
; 2. Checks if any missiles are active ($E2-$E5)
; 3. For each active missile:
; 4. Increments timing counter and compares with speed ($D6)
;
; **TIMING CONTROL**:
; - $A8: Frame counter for missile movement timing
; - $D6: Speed threshold (from difficulty table)
; - Movement only occurs when $A8 reaches $D6
;
; **MISSILE VARIABLES**:
; - $E2-$E5: Missile Y positions (0=inactive)
; - $DE: Missile X position
; - $88: Movement direction (1-9 for 8 directions)
; - $77: Temporary missile position storage
;
; **CALLED FROM**:
; - $A346: Main game loop (sector_game_loop)
; ===============================================================================

move_missiles_in_flight:
$B14F: A5 A8    LDA $A8         ; **LOAD TIMING COUNTER** - Check frame counter
$B151: D0 05    BNE $B158       ; **SKIP IF NOT ZERO** - Only process on specific frames
$B153: 85 04    STA $04         ; **CLEAR VARIABLE** - Reset $04 to zero
$B155: 4C 2D B2 JMP $B22D       ; **JUMP TO COUNTER UPDATE** - Skip missile processing this frame
$B158: A5 E2    LDA $E2         ; **CHECK MISSILE 1** - Load missile 1 Y position
$B15A: 05 E3    ORA $E3         ; **CHECK MISSILE 2** - OR with missile 2 Y position
$B15C: 05 E4    ORA $E4         ; **CHECK MISSILE 3** - OR with missile 3 Y position
$B15E: 05 E5    ORA $E5         ; **CHECK MISSILE 4** - OR with missile 4 Y position
$B160: D0 03    BNE $B165       ; **BRANCH IF ANY ACTIVE** - Process if any missile != 0
$B162: 4C 2D B2 JMP $B22D       ; **NO MISSILES ACTIVE** - Skip to counter update
$B165: A9 00    LDA #$00        ; **INITIALIZE MISSILE INDEX** - Start with missile 0
$B167: 85 67    STA $67         ; **STORE MISSILE INDEX** - Save in $67

$B169: A5 67    LDA $67         ; **LOAD MISSILE INDEX** - Get current missile being processed
$B16B: 85 72    STA $72         ; **STORE IN $72** - Copy for subroutine use
$B16D: C9 04    CMP #$04        ; **CHECK IF DONE** - Processed all 4 missiles?
$B16F: F0 F1    BEQ $B162       ; **EXIT IF DONE** - Jump to counter update
$B171: A9 04    LDA #$04        ; **LOAD RETRY COUNTER** - Set to 4 attempts
$B173: 85 68    STA $68         ; **STORE RETRY COUNTER** - Save in $68
$B175: A5 67    LDA $67         ; **LOAD MISSILE INDEX** - Get current missile
$B177: 85 72    STA $72         ; **STORE IN $72** - Copy for subroutine use
$B179: AA       TAX             ; **TRANSFER TO X** - Use as index register
$B17A: B5 E2    LDA $E2,X       ; **LOAD MISSILE Y POSITION** - Get Y pos from $E2-$E5
$B17C: D0 05    BNE $B183       ; **BRANCH IF ACTIVE** - Process if missile Y != 0
$B17E: E6 67    INC $67         ; **NEXT MISSILE** - Increment missile index
$B180: 4C 69 B1 JMP $B169       ; **LOOP BACK** - Check next missile
$B183: 85 77    STA $77         ; **SAVE MISSILE Y** - Store Y position in $77
$B185: A5 68    LDA $68         ; **LOAD RETRY COUNTER** - Get retry count
$B187: 38       SEC             ; **SET CARRY** - Prepare for subtraction
$B188: E9 01    SBC #$01        ; **DECREMENT RETRY** - Subtract 1
$B18A: 85 68    STA $68         ; **STORE RETRY COUNTER** - Save decremented value
$B18C: F0 F0    BEQ $B17E       ; **NEXT MISSILE IF DONE** - Move to next if retries exhausted
$B18E: B5 DE    LDA $DE,X       ; **LOAD MISSILE X POSITION** - Get X pos from $DE-$E1
$B190: 85 78    STA $78         ; **SAVE MISSILE X** - Store X position in $78
$B192: B5 88    LDA $88,X       ; **LOAD MOVEMENT DIRECTION** - Get direction from $88-$8B
$B194: C9 07    CMP #$07        ; **CHECK DIRECTION** - Compare with 7 (DOWN)
$B196: 30 2F    BMI $B1C7       ; **BRANCH IF < 7** - Handle directions 1-6
$B198: C9 07    CMP #$07        ; **CHECK IF EXACTLY 7** - Is it DOWN?
$B19A: D0 04    BNE $B1A0       ; **BRANCH IF NOT 7** - Handle direction 8-9
$B19C: A9 00    LDA #$00        ; **VERTICAL MOVEMENT** - Set flag for vertical
$B19E: F0 02    BEQ $B1A2       ; **SKIP TO ANIMATION** - Always branches
$B1A0: A9 01    LDA #$01        ; **DIAGONAL MOVEMENT** - Set flag for diagonal
$B1A2: 85 73    STA $73         ; **STORE MOVEMENT TYPE** - Save in $73
$B1A4: 20 B7 BC JSR update_vpos_with_masking ; **CALL SPRITE ANIMATION** - Update sprite for movement
$B1A7: A5 67    LDA $67         ; **RELOAD MISSILE INDEX** - Get current missile
$B1A9: 85 72    STA $72         ; **STORE IN $72** - Copy for subroutine
$B1AB: 20 B7 BC JSR update_vpos_with_masking ; **CALL SPRITE ANIMATION** - Additional animation update
$B1AE: A5 67    LDA $67         ; **RELOAD MISSILE INDEX** - Get current missile
$B1B0: 85 72    STA $72         ; **STORE IN $72** - Copy for subroutine
$B1B2: 20 B7 BC JSR update_vpos_with_masking ; **CALL SPRITE ANIMATION** - Additional animation update
$B1B5: A5 67    LDA $67         ; **RELOAD MISSILE INDEX** - Get current missile
$B1B7: 85 72    STA $72         ; **STORE IN $72** - Copy for subroutine
$B1B9: 20 B7 BC JSR update_vpos_with_masking ; **CALL SPRITE ANIMATION** - Additional animation update
$B1BC: A6 67    LDX $67         ; **LOAD MISSILE INDEX TO X** - Get index in X register
$B1BE: A5 77    LDA $77         ; **LOAD SAVED Y POSITION** - Get missile Y from $77
$B1C0: 95 E2    STA $E2,X       ; **UPDATE MISSILE Y** - Store back to $E2-$E5
$B1C2: E6 67    INC $67         ; **NEXT MISSILE** - Increment missile index
$B1C4: 4C 69 B1 JMP $B169       ; **LOOP BACK** - Process next missile
$B1C7: C9 04    CMP #$04        ; **CHECK DIRECTION** - Compare with 4 (LEFT)
$B1C9: 30 31    BMI $B1FC       ; **BRANCH IF < 4** - Handle directions 1-3
$B1CB: 8A       TXA             ; **TRANSFER INDEX** - Move missile index to A
$B1CC: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$B1CD: 69 04    ADC #$04        ; **ADD OFFSET** - Add 4 to index
$B1CF: 85 74    STA $74         ; **STORE OFFSET INDEX** - Save in $74
$B1D1: A9 01    LDA #$01        ; **MOVEMENT FLAG** - Set to 1
$B1D3: 85 73    STA $73         ; **STORE MOVEMENT TYPE** - Save in $73
$B1D5: 20 58 BC JSR update_hpos ; **CALL POSITION UPDATE** - Update missile position
$B1D8: A6 67    LDX $67         ; **RELOAD MISSILE INDEX** - Get index in X
$B1DA: A5 78    LDA $78         ; **LOAD UPDATED X** - Get new X position
$B1DC: 95 DE    STA $DE,X       ; **UPDATE MISSILE X** - Store to $DE-$E1
$B1DE: B5 88    LDA $88,X       ; **LOAD MOVEMENT DIRECTION** - Get direction again
$B1E0: C9 05    CMP #$05        ; **CHECK IF 5** - Is it UP-LEFT?
$B1E2: F0 91    BEQ $B175       ; **LOOP BACK IF 5** - Continue processing
$B1E4: C9 04    CMP #$04        ; **CHECK IF 4** - Is it LEFT?
$B1E6: D0 04    BNE $B1EC       ; **BRANCH IF NOT 4** - Handle direction 6
$B1E8: A9 00    LDA #$00        ; **HORIZONTAL MOVEMENT** - Set flag for horizontal
$B1EA: F0 02    BEQ $B1EE       ; **SKIP TO ANIMATION** - Always branches
$B1EC: A9 01    LDA #$01        ; **DIAGONAL MOVEMENT** - Set flag for diagonal
$B1EE: 85 73    STA $73         ; **STORE MOVEMENT TYPE** - Save in $73
$B1F0: 20 B7 BC JSR update_vpos_with_masking ; **CALL SPRITE ANIMATION** - Update sprite
$B1F3: A6 67    LDX $67         ; **RELOAD MISSILE INDEX** - Get index in X
$B1F5: A5 77    LDA $77         ; **LOAD SAVED Y** - Get missile Y from $77
$B1F7: 95 E2    STA $E2,X       ; **UPDATE MISSILE Y** - Store to $E2-$E5
$B1F9: 4C 75 B1 JMP $B175       ; **LOOP BACK** - Continue processing
$B1FC: 8A       TXA             ; **TRANSFER INDEX** - Move missile index to A
$B1FD: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$B1FE: 69 04    ADC #$04        ; **ADD OFFSET** - Add 4 to index
$B200: 85 74    STA $74         ; **STORE OFFSET INDEX** - Save in $74
$B202: A9 00    LDA #$00        ; **MOVEMENT FLAG** - Set to 0
$B204: 85 73    STA $73         ; **STORE MOVEMENT TYPE** - Save in $73
$B206: 20 58 BC JSR update_hpos ; **CALL POSITION UPDATE** - Update missile position
$B209: A6 67    LDX $67         ; **RELOAD MISSILE INDEX** - Get index in X
$B20B: A5 78    LDA $78         ; **LOAD UPDATED X** - Get new X position
$B20D: 95 DE    STA $DE,X       ; **UPDATE MISSILE X** - Store to $DE-$E1
$B20F: B5 88    LDA $88,X       ; **LOAD MOVEMENT DIRECTION** - Get direction again
$B211: C9 02    CMP #$02        ; **CHECK IF 2** - Is it UP-RIGHT?
$B213: F0 E4    BEQ $B1F9       ; **LOOP BACK IF 2** - Continue processing
$B215: C9 01    CMP #$01        ; **CHECK IF 1** - Is it DOWN-LEFT?
$B217: D0 04    BNE $B21D       ; **BRANCH IF NOT 1** - Handle direction 3
$B219: A9 00    LDA #$00        ; **VERTICAL MOVEMENT** - Set flag for vertical
$B21B: F0 02    BEQ $B21F       ; **SKIP TO ANIMATION** - Always branches
$B21D: A9 01    LDA #$01        ; **DIAGONAL MOVEMENT** - Set flag for diagonal
$B21F: 85 73    STA $73         ; **STORE MOVEMENT TYPE** - Save in $73
$B221: 20 B7 BC JSR update_vpos_with_masking ; **CALL SPRITE ANIMATION** - Update sprite
$B224: A6 67    LDX $67         ; **RELOAD MISSILE INDEX** - Get index in X
$B226: A5 77    LDA $77         ; **LOAD SAVED Y** - Get missile Y from $77
$B228: 95 E2    STA $E2,X       ; **UPDATE MISSILE Y** - Store to $E2-$E5
$B22A: 4C 75 B1 JMP $B175       ; **LOOP BACK** - Continue processing

$B22D: A5 A8    LDA $A8         ; **LOAD TIMING COUNTER** - Get frame counter
$B22F: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$B230: 69 01    ADC #$01        ; **INCREMENT COUNTER** - Add 1
$B232: 85 A8    STA $A8         ; **STORE COUNTER** - Save incremented value
$B234: C5 D6    CMP $D6         ; **COMPARE WITH SPEED** - Check against speed threshold
$B236: D0 04    BNE $B23C       ; **RETURN IF NOT EQUAL** - Skip reset if not at threshold
$B238: A9 00    LDA #$00        ; **RESET COUNTER** - Load zero
$B23A: 85 A8    STA $A8         ; **STORE ZERO** - Reset timing counter
$B23C: 60       RTS             ; **RETURN** - Exit routine
; ===============================================================================
; ===============================================================================
; SOUND_PROCESSING_ROUTINE ($B23D-$B2B2)
; **GENERAL SOUND EFFECT PROCESSOR**
; 
; Processes sound effects using $D0 as the primary sound timer/control value.
; Different $D0 values trigger different sound behaviors.
;
; **ENTRY CONDITIONS**:
; - $D0: Sound timer/control value (0 = no sound, $4F = special case)
; - $BD: Sound envelope control timer
; - $DA: Used for visual effect selection and timing in special case
;
; **SPECIAL CASE ($D0 = $4F)**:
; When $D0 = $4F (set by player_bonus_score_increase at $BD9D):
; - Uses $DA value (0, 1, or 2) to select different visual effect locations
; - Writes visual effect data to screen memory ($0617-$0619, $062B-$062D)
; - Decrements both $DA and $D0 as timers
; - Calls $B889 to copy visual effects to screen
;
; **GENERAL CASE ($D0 ≠ $4F)**:
; - Skips visual effect setup
; - Proceeds directly to sound generation at $B284
; - Decrements $D0 only
;
; **SOUND GENERATION**:
; - Uses POKEY audio registers $E800 (AUDF1) and $E801 (AUDC1)
; - Two-phase envelope controlled by $BD bit 2
; - Phase 1: Frequency $1F (attack)
; - Phase 2: Frequency $12 with control $AC (sustain)
; ===============================================================================
; ===============================================================================
; SOUND_PROCESSING_ROUTINE ($B23D-$B2B2)
; **GENERAL SOUND EFFECT PROCESSOR**
; 
; Processes sound effects using $D0 as the primary sound timer/control value.
; Different $D0 values trigger different sound behaviors.
;
; **ENTRY CONDITIONS**:
; - $D0: Sound timer/control value (0 = no sound, $4F = special case)
; - $BD: Sound envelope control timer
; - $DA: Used for visual effect selection and timing in special case
;
; **SPECIAL CASE ($D0 = $4F)**:
; When $D0 = $4F (set by player_bonus_score_increase at $BD9D):
; - Uses $DA value (0, 1, or 2) to select different visual effect locations
; - Writes visual effect data to screen memory ($0617-$0619, $062B-$062D)
; - Decrements both $DA and $D0 as timers
; - Calls $B889 to copy visual effects to screen
;
; **GENERAL CASE ($D0 ≠ $4F)**:
; - Skips visual effect setup
; - Proceeds directly to sound generation at $B284
; - Decrements $D0 only
;
; **SOUND GENERATION**:
; - Uses POKEY audio registers $E800 (AUDF1) and $E801 (AUDC1)
; - Two-phase envelope controlled by $BD bit 2
; - Phase 1: Frequency $1F (attack)
; - Phase 2: Frequency $12 with control $AC (sustain)
; ===============================================================================
$B23D: A5 D0    LDA $D0         ; Load sound timer
$B23F: D0 01    BNE $B242       ; Branch if sound active
$B241: 60       RTS             ; Return if no sound
$B242: C9 4F    CMP #$4F        ; Check for special case value
$B244: D0 3E    BNE $B284       ; Branch to general sound processing if not $4F
; --- SPECIAL CASE: $D0 = $4F (Visual Effects + Sound) ---
$B246: A5 DA    LDA $DA         ; Load visual effect selector
$B248: D0 0D    BNE $B257       ; Branch if not zero
; $DA = 0: Write to locations $0619 and $062D
$B24A: A9 20    LDA #$20        ; Load visual data value
$B24C: 8D 19 06 STA $0619       ; Store to screen memory
$B24F: A9 1E    LDA #$1E        ; Load secondary visual value
$B251: 8D 2D 06 STA $062D       ; Store to screen memory
$B254: 4C 76 B2 JMP $B276       ; Jump to timer processing
; $DA = 1: Write to locations $0618 and $062C
$B257: C9 01    CMP #$01        ; Check if $DA = 1
$B259: D0 0D    BNE $B268       ; Branch if not 1
$B25B: A9 20    LDA #$20        ; Load visual data value
$B25D: 8D 18 06 STA $0618       ; Store to screen memory
$B260: A9 1E    LDA #$1E        ; Load secondary visual value
$B262: 8D 2C 06 STA $062C       ; Store to screen memory
$B265: 4C 76 B2 JMP $B276       ; Jump to timer processing
; $DA = 2: Write to locations $0617 and $062B
$B268: C9 02    CMP #$02        ; Check if $DA = 2
$B26A: D0 0A    BNE $B276       ; Branch if not 2 (skip visual setup)
$B26C: A9 20    LDA #$20        ; Load visual data value
$B26E: 8D 17 06 STA $0617       ; Store to screen memory
$B271: A9 1E    LDA #$1E        ; Load secondary visual value
$B273: 8D 2B 06 STA $062B       ; Store to screen memory
; Timer processing for special case
$B276: A5 DA    LDA $DA         ; Load $DA timer
$B278: C9 FF    CMP #$FF        ; Check for termination value
$B27A: D0 01    BNE $B27D       ; Branch if not terminated
$B27C: 60       RTS             ; Return if terminated
$B27D: C6 DA    DEC $DA         ; Decrement $DA timer
$B27F: 20 89 B8 JSR $B889       ; Call visual effect copy routine
$B282: C6 D0    DEC $D0         ; Decrement sound timer
; --- GENERAL SOUND GENERATION (all cases) ---
$B284: A9 12    LDA #$12        ; Load base frequency $12
$B286: 8D 00 E8 STA $E800       ; AUDF1 - Set POKEY frequency
$B289: A5 BD    LDA $BD         ; Load sound envelope control
$B28B: D0 08    BNE $B295       ; Branch if envelope active
; Envelope finished - silence
$B28D: 85 0E    STA $0E         ; Clear sound parameter 1
$B28F: 85 10    STA $10         ; Clear sound parameter 2
$B291: 8D 01 E8 STA $E801       ; AUDC1 - Clear audio control (silence)
$B294: 60       RTS             ; Return
; Envelope active - process phases
$B295: C6 BD    DEC $BD         ; Decrement envelope timer
$B297: 29 04    AND #$04        ; Test bit 2 for phase
$B299: D0 0C    BNE $B2A7       ; Branch to phase 2 if bit set
; Phase 1: Attack
$B29B: A9 1F    LDA #$1F        ; Load attack frequency
$B29D: 8D 00 E8 STA $E800       ; AUDF1 - Set attack frequency
$B2A0: A9 00    LDA #$00        ; Clear parameters
$B2A2: 85 0E    STA $0E         ; Clear sound parameter 1
$B2A4: 85 10    STA $10         ; Clear sound parameter 2
$B2A6: 60       RTS             ; Return
; Phase 2: Sustain
$B2A7: A9 AC    LDA #$AC        ; Load sustain control value
$B2A9: 8D 01 E8 STA $E801       ; AUDC1 - Set audio control
$B2AC: A9 32    LDA #$32        ; Load sustain parameter
$B2AE: 85 0E    STA $0E         ; Set sound parameter 1
$B2B0: 85 10    STA $10         ; Set sound parameter 2
$B2B2: 60       RTS             ; Return
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
; 4. **Firing Patterns**: Different values trigger different firing behaviors:
; 5. **Missile Setup**: Sets enemy missile positions ($E2/$DE) and enables firing
; ===============================================================================

; TODO: Dig into this section next.

$B2B3: A9 13    LDA #$13        ; **INITIALIZE SPRITE HEIGHT** - Load 19 pixels
$B2B5: 85 7A    STA $7A         ; **STORE HEIGHT** - Save sprite height
$B2B7: A9 00    LDA #$00        ; **INITIALIZE INDEX** - Start with enemy 0
$B2B9: 85 67    STA $67         ; **STORE ENEMY INDEX** - Save in $67
$B2BB: A6 67    LDX $67         ; **LOAD ENEMY INDEX** - Get current enemy being processed
$B2BD: E6 7A    INC $7A         ; **INCREMENT HEIGHT** - Adjust sprite height
$B2BF: B5 93    LDA $93,X       ; **LOAD ENEMY STATE** - Get enemy status from $93-$96
$B2C1: F0 39    BEQ $B2FC       ; **SKIP IF INACTIVE** - Branch if enemy state = 0
$B2C3: C9 01    CMP #$01        ; **CHECK IF SPAWNING** - Is enemy in spawn state?
$B2C5: D0 10    BNE $B2D7       ; **SKIP IF NOT SPAWNING** - Branch if state != 1
$B2C7: A9 00    LDA #$00        ; **CLEAR AUDIO** - Load zero
$B2C9: 8D 06 E8 STA $E806       ; **AUDC3** - Clear audio control 3
$B2CC: 85 B3    STA $B3         ; **CLEAR VARIABLE** - Reset $B3
$B2CE: A9 8F    LDA #$8F        ; **LOAD AUDIO VALUE** - Set audio parameter
$B2D0: 85 B2    STA $B2         ; **STORE AUDIO** - Save in $B2
$B2D2: 8D 07 E8 STA $E807       ; **AUDC4** - Set audio control 4
$B2D5: 85 BE    STA $BE         ; **STORE VARIABLE** - Save in $BE
$B2D7: B5 93    LDA $93,X       ; **RELOAD ENEMY STATE** - Get enemy status again
$B2D9: 29 F0    AND #$F0        ; **MASK HIGH NIBBLE** - Check upper 4 bits
$B2DB: D0 0C    BNE $B2E9       ; **BRANCH IF SET** - Skip if high bits set
$B2DD: B5 93    LDA $93,X       ; **LOAD ENEMY STATE** - Get enemy status
$B2DF: 95 08    STA $08,X       ; **STORE TO BACKUP** - Save state to $08-$0B
$B2E1: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$B2E2: 69 03    ADC #$03        ; **INCREMENT STATE** - Add 3 to state
$B2E4: 95 93    STA $93,X       ; **UPDATE ENEMY STATE** - Store new state
$B2E6: 4C FC B2 JMP $B2FC       ; **CONTINUE** - Jump to next enemy
$B2E9: A5 9B    LDA $9B         ; **LOAD COUNTER** - Get animation/timing counter
$B2EB: D0 0F    BNE $B2FC       ; **SKIP IF NOT ZERO** - Branch if counter active
$B2ED: B5 93    LDA $93,X       ; **LOAD ENEMY POSITION** - Get position from slot
$B2EF: 85 69    STA $69         ; **STORE POSITION** - Save in position variable
$B2F1: B4 84    LDY $84,X       ; **LOAD Y COORDINATE** - Get Y position
$B2F3: 20 47 BD JSR $BD47       ; **CHECK BOUNDARY** - Call boundary check (sets $97 if escaped)
$B2F6: A6 67    LDX $67         ; **RESTORE INDEX** - Reload enemy index
$B2F8: A5 69    LDA $69         ; **LOAD UPDATED POSITION** - Get modified position
$B2FA: 95 93    STA $93,X       ; **STORE BACK** - Save to position slot
$B2FC: A5 67    LDA $67         ; **LOAD ENEMY INDEX** - Get current index
$B2FE: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$B2FF: 69 01    ADC #$01        ; **NEXT ENEMY** - Increment to next enemy
$B301: 85 67    STA $67         ; **STORE INDEX** - Save updated index
$B303: C9 04    CMP #$04        ; **CHECK IF DONE** - Processed all 4 enemies?
$B305: B0 03    BCS $B30A       ; **EXIT IF DONE** - Branch if >= 4
$B307: 4C BB B2 JMP $B2BB       ; **LOOP BACK** - Process next enemy
$B30A: A5 9B    LDA $9B         ; **LOAD ANIMATION COUNTER** - Get counter
$B30C: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$B30D: 69 01    ADC #$01        ; **INCREMENT COUNTER** - Add 1
$B30F: 85 9B    STA $9B         ; **STORE COUNTER** - Save updated counter
$B311: C9 03    CMP #$03        ; **CHECK LIMIT** - Counter reached 3?
$B313: 30 04    BMI $B319       ; **RETURN IF < 3** - Branch if less than 3
$B315: A9 00    LDA #$00        ; **RESET COUNTER** - Load zero
$B317: 85 9B    STA $9B         ; **STORE ZERO** - Reset counter
$B319: 60       RTS             ; **RETURN** - Exit routine
; ===============================================================================
; LEVEL-BASED FIRING CONTROL ($B31A)
; **FIRING FREQUENCY PERMISSION CHECK**
; This routine checks if enemies are allowed to fire based on frame counter
; ===============================================================================
enemy_firing:
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
$B349: A5 80    LDA $80         ; **LOAD PLAYER X** - Get player X position
$B34B: 85 92    STA $92         ; **STORE PLAYER X** - Save in $92
$B34D: B5 80    LDA $80,X       ; **LOAD ENEMY X** - Get enemy X position
$B34F: 85 78    STA $78         ; **STORE ENEMY X** - Save in $78
$B351: C5 80    CMP $80         ; **COMPARE POSITIONS** - Enemy X vs Player X
$B353: B0 0E    BCS $B363       ; **BRANCH IF ENEMY >= PLAYER** - Skip if enemy to right
$B355: 85 6B    STA $6B         ; **STORE ENEMY X** - Save for calculation
$B357: A5 80    LDA $80         ; **LOAD PLAYER X** - Get player X again
$B359: 85 78    STA $78         ; **STORE AS TARGET** - Save as target position
$B35B: A5 6B    LDA $6B         ; **LOAD ENEMY X** - Get enemy X back
$B35D: 85 92    STA $92         ; **STORE AS SOURCE** - Save as source position
$B35F: A9 01    LDA #$01        ; **SET DIRECTION FLAG** - Enemy left of player
$B361: 85 9C    STA $9C         ; **STORE DIRECTION** - Save horizontal direction
$B363: 38       SEC             ; **SET CARRY** - Prepare for subtraction
$B364: A5 78    LDA $78         ; **LOAD TARGET X** - Get target position
$B366: E5 92    SBC $92         ; **CALCULATE DISTANCE** - Target - Source
$B368: 85 9E    STA $9E         ; **STORE X DISTANCE** - Save horizontal distance
$B36A: 85 6C    STA $6C         ; **STORE FOR CALCULATION** - Save for division
$B36C: A9 03    LDA #$03        ; **LOAD DIVISOR** - Set divisor to 3
$B36E: 85 6B    STA $6B         ; **STORE DIVISOR** - Save divisor
$B370: 20 09 BD JSR $BD09       ; **CALL DIVISION** - Divide distance by 3
$B373: A6 67    LDX $67         ; **RESTORE ENEMY INDEX** - Get enemy index back
$B375: A5 6C    LDA $6C         ; **LOAD RESULT** - Get division result
$B377: 85 A0    STA $A0         ; **STORE X VELOCITY** - Save horizontal velocity
$B379: A5 84    LDA $84         ; **LOAD PLAYER Y** - Get player Y position
$B37B: 85 92    STA $92         ; **STORE PLAYER Y** - Save in $92
$B37D: B5 84    LDA $84,X       ; **LOAD ENEMY Y** - Get enemy Y position
$B37F: 85 77    STA $77         ; **STORE ENEMY Y** - Save in $77
$B381: C5 84    CMP $84         ; **COMPARE POSITIONS** - Enemy Y vs Player Y
$B383: B0 0E    BCS $B393       ; **BRANCH IF ENEMY >= PLAYER** - Skip if enemy below
$B385: 85 6B    STA $6B         ; **STORE ENEMY Y** - Save for calculation
$B387: A5 84    LDA $84         ; **LOAD PLAYER Y** - Get player Y again
$B389: 85 77    STA $77         ; **STORE AS TARGET** - Save as target position
$B38B: A5 6B    LDA $6B         ; **LOAD ENEMY Y** - Get enemy Y back
$B38D: 85 92    STA $92         ; **STORE AS SOURCE** - Save as source position
$B38F: A9 02    LDA #$02        ; **SET DIRECTION FLAG** - Enemy above player
$B391: 85 9D    STA $9D
$B393: 38       SEC
$B394: A5 77    LDA $77
$B396: E5 92    SBC #$92
$B398: 85 9F    STA $9F
$B39A: 85 6C    STA $6C
$B39C: A9 03    LDA #$03
$B39E: 85 6B    STA $6B
$B3A0: 20 09 BD JSR $BD09
$B3A3: A6 67    LDX $67
$B3A5: A5 6C    LDA $6C
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
; ===============================================================================
ENEMY_FIRING_SYSTEM:
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
; ===============================================================================
; ENEMY_SPAWN_AND_STATUS_UPDATE ($B4BF-$B51B)
; **ENEMY SPAWNING AND STATE MANAGEMENT**
; 
; Handles player death detection and enemy spawning/respawning logic.
; Processes 3 enemy slots (X=1,2,3) each frame.
;
; **DEATH CHECK ($B4BF-$B4CA)**:
; - Checks $97 (death detection flag)
; - If player died: calls player_death_and_respawn, sets $A9=1, returns
;
; **ENEMY SLOT PROCESSING ($B4CB-$B51B)**:
; For each enemy slot (X=1 to 3):
; 1. Checks $97,X (enemy status flag)
; 2. If inactive ($97,X = 0): skips to next slot
; 3. If active: compares $D4 (enemies defeated) with $D1 (spawn limit)
;
; **SPAWN LIMIT SYSTEM**:
; $D1 is loaded from sector difficulty table ($BBE4). It controls how many
; enemies can spawn in a sector. Once player defeats $D1 enemies, no more
; spawn, allowing player to clear the sector and exit.
;
; **VARIABLES**:
; - $97: Death detection flag (player)
; - $97,X ($98-$9A): Enemy status flags
; - $93,X ($94-$96): Enemy slot states
; - $80,X ($81-$83): Enemy X positions
; - $84,X ($85-$87): Enemy Y positions
; - $8C,X ($8D-$8F): Enemy sprite characters
; - $D4: Enemies defeated by player (incremented on player missile hits)
; - $D1: Enemy spawn limit (from sector difficulty table)
; - $A9: Respawn flag
; - $92: Working register
; ===============================================================================
spawn_enemies:
$B4BF: A5 97    LDA $97         ; Check death detection flag
$B4C1: F0 08    BEQ $B4CB       ; Branch if no death detected
$B4C3: 20 5E B7 JSR player_death_and_respawn ; **PLAYER DEATH!** Process player death and respawn
$B4C6: A9 01    LDA #$01        ; Set respawn flag
$B4C8: 85 A9    STA $A9         ; Store respawn flag
$B4CA: 60       RTS             ; Return (skip enemy processing this frame)

; --- ENEMY SLOT PROCESSING LOOP ---
$B4CB: A9 FF    LDA #$FF        ; Load $FF
$B4CD: 85 92    STA $92         ; Store to working register
$B4CF: A2 01    LDX #$01        ; Start with enemy slot 1
$B4D1: 86 67    STX $67         ; Store current slot index
$B4D3: B5 97    LDA $97,X       ; Load enemy status flag ($98-$9A)
$B4D5: F0 3F    BEQ $B516       ; Branch if enemy inactive (skip to next)
; Enemy is active - check spawn limit
$B4D7: A5 D4    LDA $D4         ; Load enemies defeated count
$B4D9: C5 D1    CMP $D1         ; Compare with spawn limit
$B4DB: 90 06    BCC $B4E3       ; Branch if $D4 < $D1 (can still spawn)
; Spawn limit reached - no more enemies
$B4DD: A9 C0    LDA #$C0        ; Load "limit reached" marker
$B4DF: 95 93    STA $93,X       ; Store to enemy slot ($94-$96)
$B4E1: D0 33    BNE $B516       ; Branch to next slot (always taken)
; --- ENEMY SPAWN/RESPAWN ---
$B4E3: A9 00    LDA #$00        ; Clear value
$B4E5: 95 97    STA $97,X       ; Clear enemy status flag
$B4E7: 95 93    STA $93,X       ; Clear enemy slot state
$B4E9: A9 FF    LDA #$FF        ; Load $FF
$B4EB: 95 8C    STA $8C,X       ; Set enemy sprite character to $FF
$B4ED: 20 1C B5 JSR random_spawn_x ; Generate random X spawn position (0-5)
$B4F0: 20 31 B5 JSR random_spawn_y ; Generate random Y spawn position (0-2)
$B4F3: 8A       TXA             ; Transfer X to A
$B4F4: 48       PHA             ; Save X on stack
$B4F5: BD D4 BF LDA $BFD4,X     ; Load X position from spawn table
$B4F8: 48       PHA             ; Save X position on stack
$B4F9: B9 DA BF LDA $BFDA,Y     ; Load Y position from spawn table
$B4FC: A6 67    LDX $67         ; Restore current slot index
$B4FE: 95 84    STA $84,X       ; Store Y position to enemy array
$B500: 68       PLA             ; Restore X position from stack
$B501: 95 80    STA $80,X       ; Store X position to enemy array
$B503: 9D 00 C0 STA $C000,X     ; Store to color register (COLPM0+X)
$B506: 68       PLA             ; Restore X from stack
$B507: E0 01    CPX #$01        ; Check if slot 1
$B509: D0 02    BNE $B50D       ; Branch if not slot 1
$B50B: 85 92    STA $92         ; Store to working register (slot 1 only)
$B50D: AD 0A E8 LDA $E80A       ; Load hardware register
$B510: 29 F0    AND #$F0        ; Mask upper nibble
$B512: 09 08    ORA #$08        ; Set bit 3
$B514: 95 08    STA $08,X       ; Store to display register
; --- LOOP CONTROL ---
$B516: E8       INX             ; Next enemy slot
$B517: E0 04    CPX #$04        ; Check if processed all 3 slots
$B519: D0 B6    BNE $B4D1       ; Loop back if more slots to process
$B51B: 60       RTS             ; Return
; ===============================================================================
; RANDOM NUMBER GENERATORS ($B51C, $B531, $B54A)
; Hardware-based random number generation using $E80A register
; Used for enemy spawning to select random positions from spawn tables
; ===============================================================================

; **RANDOM_SPAWN_X ($B51C-$B530)**
; Generates random X coordinate index (0-5) for enemy spawn position
; Returns: A and X = random value 0-5 (indexes into $BFD4 X position table)
; Avoids repeating previous values stored in $B0 and $92
random_spawn_x:
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

; **RANDOM_SPAWN_Y ($B531-$B549)**
; Generates random Y coordinate index (0-2) for enemy spawn position
; Returns: A and Y = random value 0, 2, or 0-2 (indexes into $BFDA Y position table)
; Special handling: If X=0 or X=5, calls random_spawn_y_full for 0-2 range
random_spawn_y:
$B531: E0 00    CPX #$00        ; Check X register value
$B533: F0 15    BEQ $B54A       ; Branch to full range if X=0
$B535: E0 05    CPX #$05        ; Check if X is 5
$B537: F0 11    BEQ $B54A       ; Branch to full range if X=5
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

; **RANDOM_SPAWN_Y_FULL ($B54A-$B55A)**
; Generates random Y coordinate index (0-2) with full range
; Returns: A and Y = random value 0-2 (indexes into $BFDA Y position table)
; Called when X=0 or X=5 to allow spawning at any Y position
; Avoids repeating previous value stored in $B1
random_spawn_y_full:
$B54A: AD 0A E8 LDA $E80A       ; Load hardware random register
$B54D: 29 03    AND #$03        ; Mask to get 0-3 range
$B54F: C9 03    CMP #$03        ; Check if 3
$B551: B0 F7    BCS $B54A       ; Loop if 3 (reject to get 0-2)
$B553: C5 B1    CMP $B1         ; Compare with previous value
$B555: F0 F3    BEQ $B54A       ; Loop if same (avoid repeats)
$B557: 85 B1    STA $B1         ; Store new random value
$B559: A8       TAY             ; Transfer to Y
$B55A: 60       RTS             ; Return with random 0-2 in A and Y
; ===============================================================================
; render_enemy_sprites ($B55B-$B708)
; Enemy sprite positioning and display rendering system
; 
; Called once per frame from main game loop to process all 3 enemy sprites.
; Calculates screen positions, updates sprite characters, and renders enemies.
;
; PROCESS:
; 1. LOOP THROUGH 3 ENEMY SLOTS (X = 1, 2, 3):
;
; 2. LOAD ENEMY SPRITE DATA:
;
; 3. CALCULATE SPRITE SCREEN POSITIONS:
;
; 4. BUILD DISPLAY DATA:
;
; 5. UPDATE SPRITE DISPLAY:
;
; 6. LOOP MANAGEMENT:
;
; NOTE: Contains apparent bug at $B587-$B589 where character $AC (172) is
; loaded into player sprite register $E805. Character $AC is beyond the 89
; characters defined in ROM ($00-$58), suggesting this is unused debug code
; or a bug that occurs when $8C,X = $FF (invalid state).
; ===============================================================================
render_enemy_sprites:
$B55B: A2 13    LDX #$13        ; Initialize counter
$B55D: E8       INX             ; Increment to $14
$B55E: 8A       TXA             ; Transfer to accumulator
$B55F: 85 7A    STA $7A         ; Store counter value
$B561: A9 0E    LDA #$0E        ; Load sprite parameter
$B563: 85 71    STA $71         ; Store sprite config
$B565: A2 01    LDX #$01        ; Start with enemy slot 1
$B567: 86 67    STX $67         ; Store current enemy slot index
$B569: 86 74    STX $74         ; Store to secondary index
$B56B: E6 7A    INC $7A         ; Increment counter
$B56D: B5 93    LDA $93,X       ; Load enemy slot status (0=empty, 1=active)
$B56F: F0 03    BEQ $B574       ; Branch if slot empty
$B571: 4C EB B6 JMP $B6EB       ; Jump to next enemy slot
$B574: A9 00    LDA #$00        ; Clear working registers
$B576: 85 A4    STA $A4         ; Clear flag A4
$B578: 85 A5    STA $A5         ; Clear flag A5
$B57A: A5 91    LDA $91         ; Check game state flag
$B57C: F0 03    BEQ $B581       ; Branch if normal state
$B57E: 4C EB B6 JMP $B6EB       ; Skip this enemy if special state
$B581: B5 8C    LDA $8C,X       ; Load enemy sprite character from table
$B583: C9 FF    CMP #$FF        ; Check if character = $FF (invalid/special)
$B585: D0 0B    BNE $B592       ; Branch if valid character
$B587: A9 AC    LDA #$AC        ; BUG: Load invalid character $AC (beyond ROM charset)
$B589: 8D 05 E8 STA $E805       ; BUG: Store to PLAYER sprite register (should be enemy?)
$B58C: A9 20    LDA #$20        ; Load position value
$B58E: 85 B8    STA $B8         ; Store sprite position
$B590: 85 B9    STA $B9         ; Store sprite position copy
$B592: A0 00    LDY #$00        ; Initialize Y counter
$B594: A9 00    LDA #$00        ; Clear accumulator
$B596: 85 6F    STA $6F         ; Clear pointer low byte
$B598: A9 28    LDA #$28        ; Load pointer high byte ($28xx)
$B59A: 85 70    STA $70         ; Store pointer high byte
$B59C: B5 80    LDA $80,X       ; Load enemy X position from table
$B59E: 85 78    STA $78         ; Store to working register
$B5A0: C5 80    CMP $80         ; Compare with base position
$B5A2: D0 03    BNE $B5A7       ; Branch if not equal
$B5A4: 4C 4D B6 JMP $B64D       ; Jump to Y position processing
$B5A7: 30 09    BMI $B5B2       ; Branch if negative position
$B5A9: 38       SEC             ; Set carry for subtraction
$B5AA: E9 03    SBC #$03        ; Subtract 3 (position offset)
$B5AC: 85 6C    STA $6C         ; Store adjusted position
$B5AE: A9 00    LDA #$00        ; Clear direction flag (positive)
$B5B0: F0 07    BEQ $B5B9       ; Branch to continue
$B5B2: 18       CLC             ; Clear carry for addition
$B5B3: 69 0B    ADC #$0B        ; Add 11 (negative position adjustment)
$B5B5: 85 6C    STA $6C         ; Store adjusted position
$B5B7: A9 01    LDA #$01        ; Set direction flag (negative)
$B5B9: 85 73    STA $73         ; Store direction flag
$B5BB: A9 02    LDA #$02        ; Load calculation parameter
$B5BD: 85 6B    STA $6B         ; Store parameter
$B5BF: 20 09 BD JSR $BD09       ; Call calculation routine
$B5C2: A6 67    LDX $67         ; Restore enemy slot index
$B5C4: A5 6C    LDA $6C         ; Load calculated value
$B5C6: 38       SEC             ; Set carry for subtraction
$B5C7: E9 18    SBC #$18        ; Subtract 24 (screen offset)
$B5C9: 85 6C    STA $6C         ; Store adjusted screen position
$B5CB: A9 04    LDA #$04        ; Load calculation parameter
$B5CD: 85 6B    STA $6B         ; Store parameter
$B5CF: 20 09 BD JSR $BD09       ; Call calculation routine again
$B5D2: A6 67    LDX $67         ; Restore enemy slot index
$B5D4: A5 6C    LDA $6C         ; Load final X position
$B5D6: 85 92    STA $92         ; Store X screen position
$B5D8: EA       NOP
$B5D9: B5 84    LDA $84,X
$B5DB: 38       SEC
$B5DC: E9 03    SBC #$03
$B5DE: 85 6C    STA $6C
$B5E0: A9 04    LDA #$04
$B5E2: 85 6B    STA $6B
$B5E4: 20 09 BD JSR $BD09
$B5E7: A6 67    LDX $67
$B5E9: A5 6C    LDA $6C
$B5EB: 38       SEC
$B5EC: E9 08    SBC #$08
$B5EE: 85 6C    STA $6C
$B5F0: A5 92    LDA $92
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
$B60D: A6 67    LDX $67
$B60F: A5 6B    LDA $6B
$B611: D0 3A    BNE $B64D ; Loop back if not zero
$B613: B5 84    LDA $84,X
$B615: 85 77    STA $77
$B617: A9 01    LDA #$01
$B619: 85 A4    STA $A4
$B61B: A5 73    LDA $73
$B61D: F0 14    BEQ $B633 ; Branch if equal/zero
$B61F: A9 24    LDA #$24
$B621: D5 8C    CMP #$8C
$B623: D0 02    BNE $B627 ; Loop back if not zero
$B625: A9 30    LDA #$30
$B627: 85 64    STA $64
$B629: 95 8C    STA $8C
$B62B: 20 30 BD JSR $BD30
$B62E: A6 67    LDX $67
$B630: 4C 44 B6 JMP $B644
$B633: A9 0C    LDA #$0C
$B635: D5 8C    CMP #$8C
$B637: D0 02    BNE $B63B ; Loop back if not zero
$B639: A9 18    LDA #$18
$B63B: 85 64    STA $64
$B63D: 95 8C    STA $8C
$B63F: 20 30 BD JSR $BD30
$B642: A6 67    LDX $67
$B644: 20 58 BC JSR update_hpos
$B647: A6 67    LDX $67
$B649: A5 78    LDA $78
$B64B: 95 80    STA $80
$B64D: A0 00    LDY #$00
$B64F: A9 00    LDA #$00
$B651: 85 6F    STA $6F
$B653: C8       INY
$B654: A9 28    LDA #$28
$B656: 85 70    STA $70
$B658: B5 84    LDA $84,X
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
$B67E: A6 67    LDX $67
$B680: A5 6C    LDA $6C
$B682: 38       SEC
$B683: E9 08    SBC #$08
$B685: 85 92    STA $92
$B687: B5 80    LDA $80,X
$B689: 85 6C    STA $6C
$B68B: A9 02    LDA #$02
$B68D: 85 6B    STA $6B
$B68F: 20 09 BD JSR $BD09
$B692: A6 67    LDX $67
$B694: A5 6C    LDA $6C
$B696: 38       SEC
$B697: E9 18    SBC #$18
$B699: 85 6C    STA $6C
$B69B: A9 04    LDA #$04
$B69D: 85 6B    STA $6B
$B69F: 20 09 BD JSR $BD09
$B6A2: A6 67    LDX $67
$B6A4: A5 6C    LDA $6C
$B6A6: 85 A6    STA $A6
$B6A8: A5 92    LDA $92
$B6AA: 85 6C    STA $6C
$B6AC: A5 A6    LDA $A6
$B6AE: 20 09 B7 JSR $B709
$B6B1: B1 6F    LDA #$6F
$B6B3: D0 25    BNE $B6DA ; Loop back if not zero
$B6B5: A5 A4    LDA $A4
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
$B6CC: A6 67    LDX $67
$B6CE: 20 7C BC JSR copy_sprite_data ; Copy sprite data to PMG memory
$B6D1: 20 7C BC JSR copy_sprite_data ; Copy sprite data to PMG memory (second pass)
$B6D4: A6 67    LDX $67
$B6D6: A5 77    LDA $77
$B6D8: 95 84    STA $84
$B6DA: A5 A4    LDA $A4
$B6DC: 05 A5    ORA #$A5
$B6DE: D0 0B    BNE $B6EB ; Loop back if not zero
$B6E0: 85 64    STA $64
$B6E2: 95 8C    STA $8C
$B6E4: B5 84    LDA $84,X
$B6E6: 85 77    STA $77
$B6E8: 20 30 BD JSR $BD30
$B6EB: A6 67    LDX $67         ; Restore enemy slot index
$B6ED: E8       INX             ; Increment to next enemy slot
$B6EE: E0 04    CPX #$04        ; Check if processed all 3 enemies (slots 1-3)
$B6F0: F0 03    BEQ $B6F5       ; Branch if all enemies processed
$B6F2: 4C 67 B5 JMP $B567       ; Loop back to process next enemy
$B6F5: A5 91    LDA $91         ; Load game state counter
$B6F7: 18       CLC             ; Clear carry for addition
$B6F8: 69 01    ADC #$01        ; Increment counter
$B6FA: 85 91    STA $91         ; Store updated counter
$B6FC: C5 D8    CMP $D8         ; Compare with limit
$B6FE: 30 08    BMI $B708       ; Branch if below limit
$B700: A9 00    LDA #$00        ; Reset counter to 0
$B702: 85 91    STA $91         ; Store reset counter
$B704: A9 01    LDA #$01        ; Set flag
$B706: 85 65    STA $65         ; Store flag
$B708: 60       RTS             ; Return from render_enemy_sprites

$B708: 60       RTS
$B709: 48       PHA
$B70A: A9 14    LDA #$14
$B70C: 85 6B    STA $6B
$B70E: 20 1C BD JSR $BD1C
$B711: A6 67    LDX $67
$B713: 68       PLA
$B714: 18       CLC
$B715: 65 6D    ADC #$6D
$B717: 85 6D    STA $6D
$B719: A8       TAY
$B71A: 90 02    BCC $B71E ; Branch if carry clear
$B71C: E6 6A    INC $6A
$B71E: A5 6A    LDA $6A
$B720: 18       CLC
$B721: 65 70    ADC #$70
$B723: 85 70    STA $70
$B725: 60       RTS

update_elapsed_game_time:
$B726: E6 AA    INC $AA
$B728: A6 AA    LDX $AA
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
; PLAYER_DEATH_AND_RESPAWN ($B75E) - COMPLETE ANALYSIS
; Player death sequence - Handles death animation, music, and respawn
; 
; This routine creates a complex visual and audio death sequence when the player
; dies (hits enemy, barrier, or goes out of bounds). It manages the lives system
; and triggers game over when all lives are exhausted.
;
; DEATH SEQUENCE BREAKDOWN:
; 1. Initialize death effects ($B760-$B765)
; 2. Increment death counter $DA (0→1→2→3)
; 3. Multi-stage visual effects loop ($B76C-$B794)
; 4. Final death effects and cleanup ($B796-$B82E)
;
; LIVES SYSTEM:
; - Player starts with 3 lives ($DA = 0)
; - Each death increments $DA
; - When $DA reaches 3, all lives exhausted → game over
; - Death counter checked in main game loop at $A34F
;
; TECHNICAL DETAILS:
; - Uses $06xx memory as staging area for screen effects
; - Copies staged data to screen memory $2Exx via $B889 routine
; - Controls hardware registers $E800-$E808 for sprite/display effects
; - Creates timed delays via $B82F routine (nested countdown loops)
; - Processes multiple animation frames with different effect patterns
; ===============================================================================
player_death_and_respawn:
$B75E: A2 40    LDX #$40        ; Initialize death effects
$B760: 20 BD BD JSR clear_game_state ; Clear game state variables ($E800-$E807)
$B763: A0 FF    LDY #$FF        ; Set maximum delay counter
$B765: 20 97 B0 JSR $B097       ; **PLAYER DEATH MUSIC** - Play death music sequence
$B768: E6 DA    INC $DA         ; **INCREMENT DEATH COUNTER** (0→1→2→3, tracks lives used)
$B76A: A5 DA    LDA $DA         ; Load death counter
$B76C: 48       PHA             ; Save death counter on stack
$B76D: 49 03    EOR #$03        ; XOR with 3 (when $DA=3, result=0 → game over)
$B76F: AA       TAX             ; Use result as index for effect variation
$B770: A9 00    LDA #$00        ; Clear effect staging areas
$B772: 9D 16 06 STA $0616,X     ; Clear primary effect buffer
$B775: 9D 2A 06 STA $062A,X     ; Clear secondary effect buffer
$B778: A9 02    LDA #$02        ; Load base effect value
$B77A: E0 01    CPX #$01        ; Check if death counter = 2 (second death)
$B77C: D0 02    BNE $B780       ; Branch if not second death
$B77E: A9 04    LDA #$04        ; Use enhanced effect for second death
$B780: 9D 17 06 STA $0617,X     ; Store effect pattern to staging area
$B783: 09 01    ORA #$01        ; Add effect modifier
$B785: 9D 2B 06 STA $062B,X     ; Store modified effect pattern
$B788: A0 FF    LDY #$FF        ; Set delay counter
$B78A: 20 2F B8 JSR $B82F       ; **TIMED DELAY** - creates visual timing
$B78D: 20 89 B8 JSR $B889       ; **COPY EFFECTS TO SCREEN** - $06xx → $2Exx
$B790: 68       PLA             ; Restore death counter from stack
$B791: 38       SEC             ; Set carry for subtraction
$B792: E9 01    SBC #$01        ; Decrement loop counter
$B794: 10 D6    BPL $B76C       ; Loop back for multiple effect frames
$B796: A9 00    LDA #$00        ; **FINAL DEATH EFFECTS PHASE**
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
$B7D2: A9 06    LDA #$06        ; **CHARACTER $06 - DEATH ANIMATION TOP** - Load death sprite top half
$B7D4: 8D 1C 06 STA $061C       ; Stage Character $06 for death animation display
$B7D7: A9 07    LDA #$07        ; **CHARACTER $07 - DEATH ANIMATION BOTTOM** - Load death sprite bottom half
$B7D9: 8D 2F 06 STA $062F       ; Stage Character $07 for death animation display
$B7DC: 20 89 B8 JSR $B889       ; Copy to screen
$B7DF: 20 5A B8 JSR $B85A       ; **SCREEN CLEAR PHASE 2** (rows $59-$9B)
$B7E2: A9 00    LDA #$00        ; Clear staging
$B7E4: 8D 1C 06 STA $061C
$B7E7: A9 08    LDA #$08        ; **CHARACTER $08 - FINAL DEAD STATE LEFT** - Load final dead sprite left half
$B7E9: 8D 2F 06 STA $062F       ; Stage Character $08 for final dead state display
$B7EC: A9 09    LDA #$09        ; **CHARACTER $09 - FINAL DEAD STATE RIGHT** - Load final dead sprite right half
$B7EE: 8D 30 06 STA $0630       ; Stage Character $09 for final dead state display
$B7F1: 20 89 B8 JSR $B889       ; Copy to screen
$B7F4: 20 70 B8 JSR $B870       ; **SCREEN CLEAR PHASE 3** (rows $4F-$3F countdown)
$B7F7: A9 00    LDA #$00        ; Clear all effect staging
$B7F9: 8D 2F 06 STA $062F
$B7FC: 8D 30 06 STA $0630
$B7FF: A5 DA    LDA $DA
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
$B82B: 20 BD BD JSR clear_game_state
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
; ARENA_PATTERN_TRANSFER ($B889-$B89A)
; ===============================================================================
; **ARENA DATA MANAGEMENT SYSTEM WITH EXIT FINALIZATION**
; This routine transfers pre-calculated arena pattern data from staging areas
; to specific screen memory locations. Part of the sophisticated procedural
; arena generation system, with special handling for exit placement finalization.
;
; **EXIT PLACEMENT FINALIZATION**:
; This routine plays a crucial role in the exit placement system by transferring
; the final calculated exit patterns to their screen positions:
;
; 1. **EXIT PATTERN STAGING**: Exit hole patterns calculated by $B8AF are staged
; 2. **SCREEN TRANSFER**: Patterns are transferred to final screen positions
; 3. **COORDINATE MAPPING**: These screen positions correspond to the left and
; 4. **TIMING COORDINATION**: Transfer occurs after all pattern calculations
;
; **MEMORY MAPPING FOR EXITS**:
; - $0629-$0630 → $2E29-$2E30: Left wall exit pattern data
; - $0615-$061C → $2E15-$2E1C: Right wall exit pattern data
; - Screen positions calculated to align with Element 2 and Element 38 locations
; - Vertical offsets within these ranges determined by random value from $6C
;
; PROCESS:
; 1. Transfers arena pattern data from staging area ($06xx) to screen memory
; 2. Handles two separate 8-byte pattern blocks for different arena elements
; 3. Works in conjunction with screen clearing and pattern calculation routines
; 4. Finalizes exit hole visibility for player navigation
;
; MEMORY TRANSFERS:
; - Block 1: $0629-$0630 → $2E29-$2E30 (arena pattern data with left exit)
; - Block 2: $0615-$061C → $2E15-$2E1C (arena variation data with right exit)
; ===============================================================================

$B889: A2 07    LDX #$07        ; **ARENA PATTERN TRANSFER** - Load counter for 8 bytes
$B88B: BD 29 06 LDA $0629,X     ; Load from arena pattern staging area ($0629+X)
$B88E: 9D 29 2E STA $2E29,X     ; Store to screen memory location ($2E29+X)
$B891: BD 15 06 LDA $0615,X     ; Load from arena variation staging area ($0615+X)
$B894: 9D 15 2E STA $2E15,X     ; Store to screen memory location ($2E15+X)
$B897: CA       DEX             ; Decrement transfer counter
$B898: D0 F1    BNE $B88B       ; Loop until all 8 bytes of both blocks transferred
$B89A: 60       RTS             ; Arena pattern transfer complete

; ===============================================================================
; SCREEN_MEMORY_INITIALIZATION ($B89B-$B8AE)
; ===============================================================================
; **COMPLETE SCREEN MEMORY CLEARING ROUTINE**
; Clears entire screen memory area in preparation for arena generation.
; Clears 768+ bytes across three screen memory pages plus specific areas.
; ===============================================================================

clear_screen_memory:
$B89B: A9 00    LDA #$00        ; **SCREEN MEMORY CLEAR** - Load zero for clearing
$B89D: A2 00    LDX #$00        ; Initialize counter (will wrap from $00 to $FF)
$B89F: 9D 00 28 STA $2800,X     ; Clear screen memory page $2800-$28FF (256 bytes)
$B8A2: 9D 00 29 STA $2900,X     ; Clear screen memory page $2900-$29FF (256 bytes)
$B8A5: 9D 00 2A STA $2A00,X     ; Clear screen memory page $2A00-$2AFF (256 bytes)
$B8A8: 9D F4 2A STA $2AF4,X     ; Clear specific screen area around $2AF4
$B8AB: CA       DEX             ; Decrement counter (wraps $00→$FF on first iteration)
$B8AC: D0 F1    BNE $B89F       ; Loop until counter wraps back to $00 (256 iterations)
$B8AE: 60       RTS             ; Screen memory initialization complete
; ===============================================================================
; ADVANCED_ARENA_ELEMENT_PLACEMENT ($B8AF-$B90C)
; ===============================================================================
; **SOPHISTICATED PROCEDURAL ARENA GENERATION WITH EXIT HOLE CREATION**
; This is the advanced arena generation routine that creates complex maze patterns
; using bit manipulation, conditional logic, and position-dependent calculations.
; Much more sophisticated than the basic placement routine at $ACD9.
;
; **EXIT HOLE CREATION MECHANISM**:
; This routine is responsible for creating the actual exit holes in the perimeter walls.
; When processing exit elements (Element 2 and Element 38), it uses special pattern
; masking to create openings instead of solid walls:
;
; 1. **PATTERN TYPE SELECTION**: Based on element position ($55 & #$03), selects
; 2. **EXIT-SPECIFIC MASKING**: For exit elements, uses reduced bit patterns to
; 3. **VERTICAL POSITIONING**: Uses random value from $6C to determine which
; 4. **PATTERN COMBINATION**: Uses ORA operations to combine exit patterns with
;
; **BIT MASK PATTERNS FOR EXIT CREATION**:
; - Pattern 0 ($C0 mask): Creates wide exit holes (bits 7,6)
; - Pattern 1 ($30 mask): Creates medium exit holes (bits 5,4)  
; - Pattern 2 ($0C mask): Creates narrow exit holes (bits 3,2)
; - Pattern 3 ($03 mask): Creates minimal exit holes (bits 1,0)
;
; The mask selection combined with the random vertical offset ($6C) ensures
; that exits appear at different heights and widths, creating the "seemingly
; random vertical levels" observed in gameplay.
;
; FEATURES:
; - Position calculation with additional logic and masking
; - Bit-level pattern manipulation using AND operations with different masks
; - Conditional shape selection based on position and game state
; - Pattern combination using ORA operations
; - Integration with hardware random number generation
;
; ALGORITHM:
; 1. Calculate screen memory position (similar to $ACD9 but with enhancements)
; 2. Extract bit patterns from shape data using position-dependent masks
; 3. Apply exit-specific modifications for elements 2 and 38
; 4. Combine patterns with existing screen data using ORA operations
; 5. Apply conditional logic based on position and parameters
; ===============================================================================

$B8AF: A9 00    LDA #$00        ; **STEP 1: INITIALIZE CALCULATION VARIABLES**
$B8B1: 85 7C    STA $7C         ; Clear screen address low byte
$B8B3: 85 7D    STA $7D         ; Clear screen address high byte
$B8B5: A5 54    LDA $54         ; **STEP 2: LOAD ELEMENT COUNTER** - Current arena element
$B8B7: 85 BF    STA $BF         ; Store element counter for later use
$B8B9: 2A       ROL             ; **ENHANCED POSITION CALCULATION** - Start multiplication
$B8BA: 2A       ROL             ; Continue rotation (×4)
$B8BB: 29 FC    AND #$FC        ; **MASK LOWER BITS** - Ensure alignment ($FC = 11111100)
$B8BD: 85 C2    STA $C2         ; Store intermediate result (element_count × 4, aligned)
$B8BF: 2A       ROL             ; Continue multiplication (×8)
$B8C0: 26 7D    ROL $7D         ; Rotate carry into high byte
$B8C2: 2A       ROL             ; Final multiplication (×16)
$B8C3: 26 7D    ROL $7D         ; Rotate carry into high byte
$B8C5: 65 C2    ADC $C2         ; **ADD INTERMEDIATE** - (16×count) + (4×count) = 20×count
$B8C7: 85 7C    STA $7C         ; Store final address offset low byte
$B8C9: 90 02    BCC $B8CD       ; Branch if no carry from addition
$B8CB: E6 7D    INC $7D         ; Increment high byte if carry occurred
$B8CD: A5 55    LDA $55         ; **STEP 3: LOAD POSITION PARAMETER** - Arena element type
$B8CF: 85 C0    STA $C0         ; Store position parameter for calculations
$B8D1: 4A       LSR             ; **EXTRACT POSITION BITS** - Shift right
$B8D2: 4A       LSR             ; Shift right again (divide by 4)
$B8D3: A8       TAY             ; Transfer result to Y register for indexing
$B8D4: 18       CLC             ; Clear carry for addition
$B8D5: A5 7D    LDA $7D         ; **STEP 4: ADD SCREEN MEMORY BASE**
$B8D7: 69 28    ADC #$28        ; Add screen base ($28xx)
$B8D9: 85 7D    STA $7D         ; Store final screen memory high byte
$B8DB: A5 55    LDA $55         ; **STEP 5: CONDITIONAL PATTERN SELECTION**
$B8DD: 29 03    AND #$03        ; Extract lower 2 bits (0-3 range)
$B8DF: C9 00    CMP #$00        ; **PATTERN TYPE 0**: Check if bits = 00
$B8E1: D0 07    BNE $B8EA       ; Branch if not pattern type 0
$B8E3: A5 69    LDA $69         ; Load shape data
$B8E5: 29 C0    AND #$C0        ; **MASK PATTERN 0** - Extract bits 7,6 (11000000)
$B8E7: 4C 04 B9 JMP $B904       ; Jump to pattern application
$B8EA: C9 01    CMP #$01        ; **PATTERN TYPE 1**: Check if bits = 01
$B8EC: D0 07    BNE $B8F5       ; Branch if not pattern type 1
$B8EE: A5 69    LDA $69         ; Load shape data
$B8F0: 29 30    AND #$30        ; **MASK PATTERN 1** - Extract bits 5,4 (00110000)
$B8F2: 4C 04 B9 JMP $B904       ; Jump to pattern application
$B8F5: C9 02    CMP #$02        ; **PATTERN TYPE 2**: Check if bits = 10
$B8F7: D0 07    BNE $B900       ; Branch if not pattern type 2
$B8F9: A5 69    LDA $69         ; Load shape data
$B8FB: 29 0C    AND #$0C        ; **MASK PATTERN 2** - Extract bits 3,2 (00001100)
$B8FD: 4C 04 B9 JMP $B904       ; Jump to pattern application
$B900: A5 69    LDA $69         ; **PATTERN TYPE 3**: Default case (bits = 11)
$B902: 29 03    AND #$03        ; **MASK PATTERN 3** - Extract bits 1,0 (00000011)
$B904: 85 C1    STA $C1         ; **STEP 6: STORE EXTRACTED PATTERN**
$B906: B1 7C    LDA ($7C),Y     ; **STEP 7: READ EXISTING SCREEN DATA**
$B908: 05 C1    ORA $C1         ; **COMBINE PATTERNS** - OR new pattern with existing data
$B90A: 91 7C    STA ($7C),Y     ; **STEP 8: WRITE COMBINED PATTERN** to screen memory
$B90C: 60       RTS             ; Advanced arena element placement complete
; ===============================================================================
; ARENA_GENERATION_CONTROL_SYSTEM ($B90D-$B96F)
; ===============================================================================
; **MULTI-ELEMENT ARENA GENERATION CONTROLLER**
; This sophisticated control system manages multiple calls to the advanced arena
; generation routine ($B8AF) with different parameters to create complex arena
; layouts. It handles conditional logic, parameter management, and iterative
; element placement.
;
; **CONTROL FLOW ANALYSIS**:
; The system uses multiple conditional branches and parameter comparisons to
; determine how many elements to generate and with what characteristics:
;
; 1. **PARAMETER COMPARISON SYSTEM**: Compares $55 (element type) with $C0 
; 2. **ITERATIVE GENERATION**: Uses loop counters to call $B8AF multiple times
; 3. **STATE PRESERVATION**: Saves and restores generation parameters ($C3)
; 4. **BIDIRECTIONAL PARAMETER MODIFICATION**: Can increment or decrement 
;
; **FORWARD vs BACKWARD GENERATION EXPLAINED**:
; - **FORWARD GENERATION** ($B917-$B929): DECREMENTS element type ($55) each iteration
;
; - **BACKWARD GENERATION** ($B92B-$B93F): INCREMENTS element type ($55) each iteration  
;
; This allows the system to generate arena elements in different type sequences
; depending on the starting parameters, creating varied arena patterns.
;
; **THREE MAIN GENERATION PATHS**:
; - Path 1 ($B917-$B929): Forward generation (decrementing element types)
; - Path 2 ($B92B-$B93F): Backward generation (incrementing element types)
; - Path 3 ($B940-$B96F): Special element-based generation (element position control)
; ===============================================================================

$B90D: A5 55    LDA $55         ; **LOAD ELEMENT TYPE PARAMETER**
$B90F: C5 C0    CMP $C0         ; **COMPARE WITH CONTROL THRESHOLD** ($C0)
$B911: F0 2D    BEQ $B940       ; **BRANCH TO SPECIAL GENERATION** if equal
$B913: 85 C3    STA $C3         ; **SAVE CURRENT PARAMETER** for restoration
$B915: 30 14    BMI $B92B       ; **BRANCH TO REVERSE GENERATION** if negative
; **FORWARD GENERATION PATH** ($B917-$B929)
$B917: 38       SEC             ; Set carry for subtraction
$B918: E5 C0    SBC $C0         ; **CALCULATE GENERATION COUNT** ($55 - $C0)
$B91A: AA       TAX             ; Store count in X register
$B91B: 20 AF B8 JSR $B8AF       ; **CALL ADVANCED GENERATION** routine
$B91E: C6 55    DEC $55         ; **DECREMENT ELEMENT TYPE** for next iteration
$B920: CA       DEX             ; Decrement loop counter
$B921: D0 F8    BNE $B91B       ; **LOOP** until all elements generated
$B923: A5 C3    LDA $C3         ; **RESTORE SAVED PARAMETER**
$B925: 85 55    STA $55         ; Restore element type
$B927: 85 C0    STA $C0         ; Restore control threshold
$B929: 60       RTS             ; Return from forward generation
$B92A: 60       RTS             ; Alternate return point
; **REVERSE GENERATION PATH** ($B92B-$B93F)
$B92B: 38       SEC             ; Set carry for subtraction
$B92C: A5 C0    LDA $C0         ; Load control threshold
$B92E: E5 55    SBC $55         ; **CALCULATE REVERSE COUNT** ($C0 - $55)
$B930: AA       TAX             ; Store count in X register
$B931: E6 55    INC $55         ; **INCREMENT ELEMENT TYPE** for reverse generation
$B933: 20 AF B8 JSR $B8AF       ; **CALL ADVANCED GENERATION** routine
$B936: CA       DEX             ; Decrement loop counter
$B937: D0 F8    BNE $B931       ; **LOOP** until all reverse elements generated
$B939: A5 C3    LDA $C3         ; **RESTORE SAVED PARAMETER**
$B93B: 85 55    STA $55         ; Restore element type
$B93D: 85 C0    STA $C0         ; Restore control threshold
$B93F: 60       RTS             ; Return from reverse generation
; **SPECIAL ELEMENT-BASED GENERATION PATH** ($B940-$B96F)
; This path operates on element positions ($54) rather than element types ($55):
;
; - **BACKWARD ELEMENT PROCESSING** ($B948-$B95A): DECREMENTS element position ($54)
;
; - **FORWARD ELEMENT PROCESSING** ($B95B-$B96F): INCREMENTS element position ($54)
;
; This allows processing arena elements in different positional sequences,
; enabling precise control over which specific elements (like Elements 2 and 38
; for exits) receive specialized processing.
$B940: A5 54    LDA $54         ; **LOAD ELEMENT COUNTER** (arena position)
$B942: 85 C3    STA $C3         ; **SAVE ELEMENT COUNTER** for restoration
$B944: C5 BF    CMP $BF         ; **COMPARE WITH ELEMENT THRESHOLD** ($BF)
$B946: 30 13    BMI $B95B       ; **BRANCH TO FORWARD ELEMENT PROCESSING** if less
; **BACKWARD ELEMENT PROCESSING** ($B948-$B95A)
$B948: 38       SEC             ; Set carry for subtraction
$B949: E5 BF    SBC $BF         ; **CALCULATE ELEMENT DIFFERENCE** ($54 - $BF)
$B94B: AA       TAX             ; Store difference in X register
$B94C: C6 54    DEC $54         ; **DECREMENT ELEMENT COUNTER** for backward processing
$B94E: 20 AF B8 JSR $B8AF       ; **CALL ADVANCED GENERATION** routine
$B951: CA       DEX             ; Decrement loop counter
$B952: D0 F8    BNE $B94C       ; **LOOP** until all backward elements processed
$B954: A5 C3    LDA $C3         ; **RESTORE ELEMENT COUNTER**
$B956: 85 54    STA $54         ; Restore element position
$B958: 85 BF    STA $BF         ; Restore element threshold
$B95A: 60       RTS             ; Return from backward element processing
; **FORWARD ELEMENT PROCESSING** ($B95B-$B96F)
$B95B: A5 BF    LDA $BF         ; Load element threshold
$B95D: 38       SEC             ; Set carry for subtraction
$B95E: E5 54    SBC $54         ; **CALCULATE FORWARD DIFFERENCE** ($BF - $54)
$B960: AA       TAX             ; Store difference in X register
$B961: E6 54    INC $54         ; **INCREMENT ELEMENT COUNTER** for forward processing
$B963: 20 AF B8 JSR $B8AF       ; **CALL ADVANCED GENERATION** routine
$B966: CA       DEX             ; Decrement loop counter
$B967: D0 F8    BNE $B961       ; **LOOP** until all forward elements processed
$B969: A5 C3    LDA $C3         ; **RESTORE ELEMENT COUNTER**
$B96B: 85 54    STA $54         ; Restore element position
$B96D: 85 BF    STA $BF         ; Restore element threshold
$B96F: 60       RTS             ; Return from forward element processing
; ===============================================================================
; ARENA_GENERATION_SEQUENCE ($B970-$B9D4)
; ===============================================================================
; **COORDINATED ARENA GENERATION SEQUENCE**
; This routine orchestrates a complex sequence of arena generation calls using
; the control system above. It sets up specific parameters and calls both the
; advanced generation routine ($B8AF) and the control system ($B90D) to create
; the complete arena layout with proper exit placement.
;
; **GENERATION SEQUENCE ANALYSIS**:
; The routine follows a carefully orchestrated sequence to build the arena:
;
; 1. **INITIALIZATION PHASE** ($B977-$B98F): Sets up base parameters and 
; 2. **EXIT ELEMENT PROCESSING** ($B992-$B996): Specifically handles Element 2
; 3. **WALL GENERATION PHASE** ($B999-$B9C7): Creates perimeter walls and
; 4. **FINAL PARAMETER SETUP** ($B9C8-$B9D4): Prepares for hardware randomization
;
; **KEY ELEMENT TARGETING**:
; - Element 2 ($B9A7): LEFT EXIT - Specifically targeted for exit hole creation
; - Element 38 ($B9B5): RIGHT EXIT - Targeted through element counter $26 (38 decimal)
; - Multiple calls ensure proper wall/exit pattern integration
; ===============================================================================

$B970: 20 20 20 .byte $20,$20,$20  ; Data bytes (padding or table data)
$B973: 31       .byte $31       ; Data byte

generate_arena:
$B974: 20 9B B8 JSR clear_screen_memory ; **ARENA GENERATION CALL** - Clear screen before generation
$B977: A9 A2    LDA #$A2        ; **INITIALIZATION PHASE** - Load base parameter
$B979: 85 06    STA $06         ; Store in zero page variable
$B97B: A9 70    LDA #$70        ; Load secondary parameter
$B97D: 85 05    STA $05         ; Store in zero page variable
$B97F: A9 00    LDA #$00        ; **CLEAR COUNTERS** - Initialize to zero
$B981: 85 0C    STA $0C         ; Clear counter variable
$B983: A9 00    LDA #$00        ; Clear element counter
$B985: 85 54    STA $54         ; **RESET ELEMENT COUNTER** to start position
$B987: A9 55    LDA #$55        ; Load pattern parameter
$B989: 85 69    STA $69         ; **SET PATTERN DATA** for generation
$B98B: A9 4C    LDA #$4C        ; Load element type parameter
$B98D: 85 55    STA $55         ; **SET ELEMENT TYPE** for initial generation
$B98F: 20 AF B8 JSR $B8AF       ; **INITIAL ARENA GENERATION** call
$B992: A9 02    LDA #$02        ; **ELEMENT 2 SETUP** - Target left exit element
$B994: 85 55    STA $55         ; Set element type to 2
$B996: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** for Element 2 processing
$B999: A9 00    LDA #$00        ; **WALL GENERATION PHASE** - Reset parameters
$B99B: 85 0D    STA $0D         ; Clear control variable
$B99D: A9 AA    LDA #$AA        ; **WALL PATTERN** - Load solid wall pattern
$B99F: 85 69    STA $69         ; Set pattern data for walls
$B9A1: A9 03    LDA #$03        ; Load wall element type
$B9A3: 85 55    STA $55         ; Set element type for wall generation
$B9A5: A9 02    LDA #$02        ; Load element position
$B9A7: 85 54    STA $54         ; **SET TO ELEMENT 2** (left exit area)
$B9A9: 20 AF B8 JSR $B8AF       ; **GENERATE WALL AROUND LEFT EXIT**
$B9AC: A9 4C    LDA #$4C        ; Load different element type
$B9AE: 85 55    STA $55         ; Set element type parameter
$B9B0: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** for wall processing
$B9B3: A9 26    LDA #$26        ; **ELEMENT 38 SETUP** - Load $26 (38 decimal)
$B9B5: 85 54    STA $54         ; **SET TO ELEMENT 38** (right exit area)
$B9B7: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** for Element 38 processing
$B9BA: A9 03    LDA #$03        ; Load element type for final processing
$B9BC: 85 55    STA $55         ; Set element type parameter
$B9BE: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** for final elements
$B9C1: A9 02    LDA #$02        ; Reset to Element 2
$B9C3: 85 54    STA $54         ; Set element counter back to 2
$B9C5: 20 0D B9 JSR $B90D       ; **FINAL ELEMENT 2 PROCESSING**
$B9C8: A9 00    LDA #$00        ; **FINAL PARAMETER SETUP** - Clear variables
$B9CA: 85 0E    STA $0E         ; Clear control variable
$B9CC: A9 AA    LDA #$AA        ; Load final pattern parameter
$B9CE: 85 69    STA $69         ; **SET FINAL PATTERN** for randomization
$B9D0: A9 02    LDA #$02        ; Set arena generation parameter
$B9D2: 85 92    STA $92         ; Store generation state
$B9D4: 85 55    STA $55         ; Store element type parameter
; ===============================================================================
; HARDWARE_RANDOM_GENERATION ($B9D6-$B9E1)
; ===============================================================================
; **TRUE HARDWARE RANDOM NUMBER GENERATOR FOR EXIT PLACEMENT**
; This routine generates random values used for vertical exit positioning within
; the predetermined left/right exit elements. Uses rejection sampling to ensure
; uniform distribution across the 0-5 range.
;
; **EXIT POSITIONING ALGORITHM**:
; 1. Read hardware random register $E80A (true randomness from system noise)
; 2. Mask to 0-7 range (8 possible values)
; 3. Reject values 6-7 to ensure uniform 0-5 distribution (6 exit heights)
; 4. Store result in $6C for use by arena generation system
; 5. Each value (0-5) corresponds to different vertical offset within exit elements
;
; **INTEGRATION WITH EXIT SYSTEM**:
; - Element 2 (left exit): Random value determines Y-position within left wall
; - Element 38 (right exit): Same random value used for right wall Y-position
; - Creates consistent but varied exit placement across levels
; - Ensures exits are always present but at unpredictable heights
;
; This explains the user's observation of "seemingly random vertical levels"
; while maintaining the guaranteed left/right exit structure.
; ===============================================================================

$B9D6: AD 0A E8 LDA $E80A       ; **HARDWARE RANDOM NUMBER GENERATION** - Load random register
$B9D9: 29 07    AND #$07        ; Mask to 0-7 range (8 possible values)
$B9DB: C9 06    CMP #$06        ; Check if value >= 6
$B9DD: B0 F7    BCS $B9D6       ; **REJECTION SAMPLING** - Loop if >= 6 (ensures 0-5 range)
$B9DF: 85 6C    STA $6C         ; **STORE RANDOM VALUE** - Save random number (0-5) for exit positioning
$B9E1: A9 06    LDA #$06        ; Load parameter value
$B9E3: 85 6B    STA $6B         ; Store parameter for calculations
; ===============================================================================
; ADVANCED_ARENA_PATTERN_GENERATION ($B9E5-$BABF)
; ===============================================================================
; **COMPLEX MULTI-PHASE ARENA GENERATION SYSTEM**
; This sophisticated routine implements multiple phases of arena generation using
; nested loops, hardware randomization, and complex parameter manipulation to
; create varied maze layouts with proper exit placement.
;
; **PHASE 1: INITIAL PATTERN SETUP** ($B9E5-$BA28)
; Sets up base parameters and performs initial arena element calculations
; **PHASE 2: RANDOMIZED ELEMENT PROCESSING** ($BA28-$BA70) 
; Uses hardware randomization to create varied element patterns
; **PHASE 3: SECONDARY RANDOMIZATION** ($BA70-$BAB4)
; Additional randomization layer for enhanced pattern variety
; **PHASE 4: FINAL PARAMETER SETUP** ($BAB4-$BABF)
; Completes arena generation with final parameter configuration
; ===============================================================================

$B9E5: 20 1C BD JSR $BD1C       ; **CALL CALCULATION ROUTINE** - Complex parameter processing
$B9E8: A5 6D    LDA $6D         ; Load calculated parameter
$B9EA: 18       CLC             ; Clear carry for addition
$B9EB: 69 02    ADC #$02        ; **ADD OFFSET** - Adjust parameter by 2
$B9ED: 85 54    STA $54         ; **UPDATE ELEMENT COUNTER** - Store adjusted position
$B9EF: 20 AF B8 JSR $B8AF       ; **CALL ADVANCED GENERATION** - Apply pattern
$B9F2: E6 55    INC $55         ; **INCREMENT ELEMENT TYPE** - Move to next type
$B9F4: E6 55    INC $55         ; **INCREMENT AGAIN** - Skip to type+2
$B9F6: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** - Process with new type
$B9F9: C6 55    DEC $55         ; **DECREMENT ELEMENT TYPE** - Adjust back
$B9FB: E6 54    INC $54         ; **INCREMENT ELEMENT POSITION** - Move to next position
$B9FD: A9 FF    LDA #$FF        ; **SPECIAL PATTERN** - Load pattern modifier
$B9FF: 85 69    STA $69         ; Store pattern data
$BA01: 20 AF B8 JSR $B8AF       ; **APPLY SPECIAL PATTERN** - Generate with modifier
$BA04: A5 54    LDA $54         ; Load current element position
$BA06: 18       CLC             ; Clear carry
$BA07: 69 05    ADC #$05        ; **ADD POSITION OFFSET** - Jump ahead 5 positions
$BA09: 85 54    STA $54         ; Store new position
$BA0B: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** - Process at new position
$BA0E: E6 54    INC $54         ; **INCREMENT POSITION** - Move forward
$BA10: C6 55    DEC $55         ; **DECREMENT TYPE** - Adjust element type
$BA12: C6 54    DEC $54         ; **DECREMENT POSITION** - Step back
$BA14: A9 AA    LDA #$AA        ; **WALL PATTERN** - Load solid wall pattern
$BA16: 85 69    STA $69         ; Store wall pattern data
$BA18: 20 AF B8 JSR $B8AF       ; **GENERATE WALL ELEMENT** - Apply wall pattern
$BA1B: E6 55    INC $55         ; **INCREMENT TYPE** - Move to next type
$BA1D: E6 55    INC $55         ; **INCREMENT AGAIN** - Skip to type+2
$BA1F: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** - Process with new type
$BA22: A9 4B    LDA #$4B        ; **LOOP CONTROL** - Load loop termination value
$BA24: C5 92    CMP $92         ; **COMPARE WITH STATE** - Check loop condition
$BA26: D0 AA    BNE $B9D2       ; **LOOP BACK** - Continue if not complete
; **PHASE 2: RANDOMIZED ELEMENT PROCESSING** ($BA28-$BA70)
$BA28: A9 AA    LDA #$AA        ; **RESET WALL PATTERN** - Load wall pattern
$BA2A: 85 69    STA $69         ; Store pattern data
$BA2C: A9 0E    LDA #$0E        ; **ELEMENT POSITION** - Load position 14
$BA2E: 85 54    STA $54         ; Set element counter
$BA30: A9 03    LDA #$03        ; **ELEMENT TYPE** - Load type 3
$BA32: 85 92    STA $92         ; Store generation state
$BA34: 85 55    STA $55         ; Store element type
$BA36: AD 0A E8 LDA $E80A       ; **HARDWARE RANDOMIZATION** - Read random register
$BA39: 29 01    AND #$01        ; **MASK TO BIT 0** - Get 0 or 1 value
$BA3B: D0 1B    BNE $BA58       ; **BRANCH ON RANDOM** - Skip if bit set
$BA3D: AD 0A E8 LDA $E80A       ; **SECOND RANDOM CHECK** - Read again for more randomness
$BA40: 29 01    AND #$01        ; Mask to bit 0
$BA42: D0 07    BNE $BA4B       ; **CONDITIONAL BRANCH** - Skip modification if bit set
$BA44: A5 55    LDA $55         ; Load current element type
$BA46: 18       CLC             ; Clear carry
$BA47: 69 0C    ADC #$0C        ; **ADD TYPE OFFSET** - Increase type by 12
$BA49: 85 55    STA $55         ; Store modified type
$BA4B: 20 AF B8 JSR $B8AF       ; **GENERATE WITH RANDOM TYPE** - Apply pattern
$BA4E: A5 55    LDA $55         ; Load element type
$BA50: 18       CLC             ; Clear carry
$BA51: 69 0C    ADC #$0C        ; **ADD TYPE OFFSET** - Increase by 12
$BA53: 85 55    STA $55         ; Store new type
$BA55: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** - Process with new type
$BA58: A5 92    LDA $92         ; **LOAD GENERATION STATE** - Check current state
$BA5A: 18       CLC             ; Clear carry
$BA5B: 69 18    ADC #$18        ; **ADD STATE INCREMENT** - Increase by 24
$BA5D: 85 92    STA $92         ; Store new state
$BA5F: 85 55    STA $55         ; **UPDATE ELEMENT TYPE** - Use state as type
$BA61: C9 4B    CMP #$4B        ; **CHECK TERMINATION** - Compare with end value (75)
$BA63: D0 D1    BNE $BA36       ; **LOOP BACK** - Continue if not complete
$BA65: A5 54    LDA $54         ; **LOAD ELEMENT POSITION** - Check position
$BA67: 18       CLC             ; Clear carry
$BA68: 69 0C    ADC #$0C        ; **ADD POSITION INCREMENT** - Increase by 12
$BA6A: 85 54    STA $54         ; Store new position
$BA6C: C9 26    CMP #$26        ; **CHECK POSITION LIMIT** - Compare with 38 (Element 38!)
$BA6E: D0 C0    BNE $BA30       ; **LOOP BACK** - Continue until position 38 reached
; **PHASE 3: SECONDARY RANDOMIZATION** ($BA70-$BAB4)
$BA70: A9 0F    LDA #$0F        ; **RESET ELEMENT TYPE** - Load type 15
$BA72: 85 55    STA $55         ; Store element type
$BA74: A9 02    LDA #$02        ; **RESET GENERATION STATE** - Load state 2
$BA76: 85 92    STA $92         ; Store generation state
$BA78: 85 54    STA $54         ; **RESET ELEMENT POSITION** - Back to Element 2!
$BA7A: AD 0A E8 LDA $E80A       ; **HARDWARE RANDOMIZATION** - Read random register
$BA7D: 29 01    AND #$01        ; Mask to bit 0
$BA7F: D0 1B    BNE $BA9C       ; **BRANCH ON RANDOM** - Skip if bit set
$BA81: AD 0A E8 LDA $E80A       ; **SECOND RANDOM CHECK** - Additional randomization
$BA84: 29 01    AND #$01        ; Mask to bit 0
$BA86: D0 07    BNE $BA8F       ; **CONDITIONAL BRANCH** - Skip modification if bit set
$BA88: A5 54    LDA $54         ; Load current element position
$BA8A: 18       CLC             ; Clear carry
$BA8B: 69 07    ADC #$07        ; **ADD POSITION OFFSET** - Increase position by 7
$BA8D: 85 54    STA $54         ; Store modified position
$BA8F: 20 AF B8 JSR $B8AF       ; **GENERATE WITH RANDOM POSITION** - Apply pattern
$BA92: A5 54    LDA $54         ; Load element position
$BA94: 18       CLC             ; Clear carry
$BA95: 69 05    ADC #$05        ; **ADD POSITION OFFSET** - Increase by 5
$BA97: 85 54    STA $54         ; Store new position
$BA99: 20 0D B9 JSR $B90D       ; **CALL CONTROL SYSTEM** - Process at new position
$BA9C: A5 92    LDA $92         ; **LOAD GENERATION STATE** - Check current state
$BA9E: 18       CLC             ; Clear carry
$BA9F: 69 0C    ADC #$0C        ; **ADD STATE INCREMENT** - Increase by 12
$BAA1: 85 92    STA $92         ; Store new state
$BAA3: 85 54    STA $54         ; **UPDATE ELEMENT POSITION** - Use state as position
$BAA5: C9 26    CMP #$26        ; **CHECK POSITION LIMIT** - Compare with 38 (Element 38!)
$BAA7: D0 D1    BNE $BA7A       ; **LOOP BACK** - Continue until position 38 reached
$BAA9: A5 55    LDA $55         ; **LOAD ELEMENT TYPE** - Check current type
$BAAB: 18       CLC             ; Clear carry
$BAAC: 69 0C    ADC #$0C        ; **ADD TYPE INCREMENT** - Increase by 12
$BAAE: 85 55    STA $55         ; Store new type
$BAB0: C9 4B    CMP #$4B        ; **CHECK TYPE LIMIT** - Compare with 75
$BAB2: D0 C0    BNE $BA74       ; **LOOP BACK** - Continue until type 75 reached
; **PHASE 4: FINAL PARAMETER SETUP** ($BAB4-$BABF)
$BAB4: AD 0A E8 LDA $E80A       ; **FINAL RANDOMIZATION** - Read hardware random
$BAB7: 09 07    ORA #$07        ; **SET LOWER BITS** - Ensure bits 0,1,2 are set
$BAB9: 85 0D    STA $0D         ; **STORE FINAL PARAMETER** - Save configuration
$BABB: A9 B7    LDA #$B7        ; **COMPLETION MARKER** - Load completion value
$BABD: 85 0C    STA $0C         ; Store completion state
$BABF: 60       RTS             ; **ARENA GENERATION COMPLETE** - Return
; ===============================================================================
; calculate_rank ($BAC0-$BB63)
; ===============================================================================
; **PLAYER RANK CALCULATION AND DISPLAY SYSTEM**
; Calculates player's skill rank based on score and time performance, then
; displays the appropriate rank text on screen.
;
; RANK CALCULATION PROCESS:
; 1. Processes score data from $060B using mathematical operations
; 2. Processes time data and performs multi-byte subtraction
; 3. Multiplies result by 8 to create index into rank text table
; 4. Range-checks index (0-40, capped at 40 for max rank)
; 5. Copies 8 bytes from rank table at $A60B+index to screen at $06BA
; 6. Converts score/time values to displayable digits
;
; RANK LEVELS (index * 8):
; - Index 0:  Lowest performance rank
; - Index 8:  ROOKIE
; - Index 16: NOVICE  
; - Index 24: GUNNER
; - Index 32: BLASTER
; - Index 40: MARKSMAN (highest, capped at this value)
;
; The routine performs complex arithmetic on player stats to determine which
; 8-byte chunk of the rank text table to display.
; ===============================================================================
calculate_rank:
$BAC0: A2 00    LDX #$00        ; Initialize score processing counter
$BAC2: 20 64 BB JSR convert_score_to_numbers_for_calculation ; Calculate score value (multiply by 10, etc.)
$BAC5: A9 31    LDA #$31        ; Load parameter value (49 decimal)
$BAC7: 85 6B    STA $6B         ; Store calculation parameter
$BAC9: 20 1C BD JSR $BD1C       ; Process parameter
$BACC: A5 6A    LDA $6A         ; Load calculated result
$BACE: 85 64    STA $64         ; Store first calculation result
$BAD0: A5 6D    LDA $6D         ; Load second calculated result
$BAD2: 85 65    STA $65         ; Store second calculation result
$BAD4: A2 2B    LDX #$2B        ; Load parameter (43 decimal)
$BAD6: 20 64 BB JSR convert_score_to_numbers_for_calculation ; Calculate score value again
$BAD9: A9 07    LDA #$07        ; Load parameter value
$BADB: 85 6B    STA $6B         ; Store calculation parameter
$BADD: 20 1C BD JSR $BD1C       ; Process parameter
$BAE0: 38       SEC             ; Set carry for subtraction
$BAE1: A5 65    LDA $65         ; Load first operand
$BAE3: E5 6D    SBC $6D         ; Subtract to calculate performance delta
$BAE5: 85 69    STA $69         ; Store difference (low byte)
$BAE7: A5 64    LDA $64         ; Load second operand
$BAE9: E5 6A    SBC $6A         ; Subtract with borrow (high byte)
$BAEB: 85 68    STA $68         ; Store high byte result
$BAED: 90 0D    BCC $BAFC       ; Branch if underflow (negative result)
$BAEF: A5 69    LDA $69         ; Load low byte of positive result
$BAF1: 38       SEC             ; Set carry
$BAF2: E5 CF    SBC $CF         ; Subtract time/performance factor
$BAF4: 85 69    STA $69         ; Store adjusted result
$BAF6: A5 68    LDA $68         ; Load high byte
$BAF8: E5 CE    SBC $CE         ; Subtract high byte with borrow
$BAFA: B0 04    BCS $BB00       ; Branch if no underflow
$BAFC: A9 00    LDA #$00        ; Underflow: set rank to 0 (lowest)
$BAFE: 85 69    STA $69         ; Clear result
$BB00: 0A       ASL             ; Multiply rank by 8 (shift left ×2)
$BB01: 0A       ASL             ; Shift left again (×4)
$BB02: 0A       ASL             ; Shift left again (×8)
$BB03: AA       TAX             ; Transfer rank index to X register
$BB04: E0 30    CPX #$30        ; Check if rank index >= 48
$BB06: 90 06    BCC $BB0E       ; Branch if in valid range (< 48)
$BB08: A9 D0    LDA #$D0        ; Cap exceeded: load max value
$BB0A: 85 69    STA $69         ; Store capped result
$BB0C: A2 28    LDX #$28        ; Set to max rank index (40 = MARKSMAN)
$BB0E: A0 00    LDY #$00        ; Initialize copy counter
$BB10: BD 0B A6 LDA $A60B,X     ; Load rank text byte from table ($A60B + rank*8)
$BB13: 99 BA 06 STA $06BA,Y     ; Store to screen memory at $06BA
$BB16: E8       INX             ; Increment source pointer
$BB17: C8       INY             ; Increment destination pointer
$BB18: C0 08    CPY #$08        ; Check if 8 bytes copied
$BB1A: D0 F4    BNE $BB10       ; Loop until 8 bytes of rank text copied
$BB1C: A5 69    LDA $69         ; Load calculated performance value
$BB1E: 85 6C    STA $6C         ; Store for digit conversion
$BB20: A9 34    LDA #$34        ; Load parameter (52 decimal)
$BB22: 85 6B    STA $6B         ; Store parameter
$BB24: 20 09 BD JSR $BD09       ; Process parameter
$BB27: A9 35    LDA #$35        ; Load value (53 decimal)
$BB29: 38       SEC             ; Set carry for subtraction
$BB2A: E5 6C    SBC $6C         ; Subtract calculated value
$BB2C: 8D CE 06 STA $06CE       ; Store result to memory
$BB2F: A9 30    LDA #$30        ; Load ASCII '0' (48) for digit initialization
$BB31: 8D AC 06 STA $06AC       ; Initialize first digit to '0'
$BB34: 8D AD 06 STA $06AD       ; Initialize second digit to '0'
$BB37: 8D AE 06 STA $06AE       ; Initialize third digit to '0'
$BB3A: A5 CF    LDA $CF         ; Load counter value
$BB3C: 85 6A    STA $6A         ; Store counter
$BB3E: A5 CE    LDA $CE         ; Load second counter
$BB40: 85 6D    STA $6D         ; Store second counter
$BB42: A2 02    LDX #$02        ; Initialize digit position (rightmost)
$BB44: FE AC 06 INC $06AC,X     ; Increment digit at position X
$BB47: BD AC 06 LDA $06AC,X     ; Load current digit value
$BB4A: C9 3A    CMP #$3A        ; Check if digit > '9' (overflow to ':')
$BB4C: D0 08    BNE $BB56       ; Branch if digit is valid (0-9)
$BB4E: A9 30    LDA #$30        ; Reset overflowed digit to '0'
$BB50: 9D AC 06 STA $06AC,X     ; Store reset digit
$BB53: CA       DEX             ; Move to next higher digit (carry)
$BB54: 10 EE    BPL $BB44       ; Loop if more digits to process
$BB56: A5 6A    LDA $6A         ; Load counter
$BB58: 38       SEC             ; Set carry for subtraction
$BB59: E9 34    SBC #$34        ; Decrement counter by 52
$BB5B: 85 6A    STA $6A         ; Store decremented counter
$BB5D: B0 E3    BCS $BB42       ; Loop if counter still positive
$BB5F: C6 6D    DEC $6D         ; Decrement high byte of counter
$BB61: 10 DF    BPL $BB42       ; Loop if high counter still positive
$BB63: 60       RTS             ; Return from rank calculation
; ===============================================================================
; convert_score_to_numbers_for_calculation ($BB64-$BB76)
; Helper subroutine for calculate_rank
; Converts BCD score digits to numeric value for rank calculation
; 
; INPUT: X = offset into score table at $060B
; OUTPUT: $6C = calculated numeric value
; 
; ALGORITHM: Converts two BCD digits to decimal number
; - Multiplies first digit by 10 (×4 + ×1 = ×5, then ×2 = ×10)
; - Adds second digit
; - Subtracts 16 (adjusts for ASCII/BCD offset)
; ===============================================================================
convert_score_to_numbers_for_calculation:
$BB64: BD 0B 06 LDA $060B,X     ; Load score digit from table
$BB67: 0A       ASL             ; Multiply by 4 (shift left ×2)
$BB68: 0A       ASL             ; Shift left again (×4)
$BB69: 7D 0B 06 ADC $060B,X     ; Add original value (×4 + ×1 = ×5)
$BB6C: 0A       ASL             ; Multiply by 2 (×5 × 2 = ×10)
$BB6D: 18       CLC             ; Clear carry for addition
$BB6E: 7D 0C 06 ADC $060C,X     ; Add next digit value
$BB71: 38       SEC             ; Set carry for subtraction
$BB72: E9 10    SBC #$10        ; Subtract 16 (adjust for ASCII/BCD offset)
$BB74: 85 6C    STA $6C         ; Store calculated value
$BB76: 60       RTS             ; Return from calculation
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

time_countdown_and_display:
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
$BBB8: A5 AF    LDA $AF
$BBBA: C5 7F    CMP #$7F
$BBBC: D0 04    BNE $BBC2 ; Loop back if not zero
$BBBE: A9 00    LDA #$00
$BBC0: 85 AF    STA $AF
$BBC2: 60       RTS
; ===============================================================================
; SET SECTOR DIFFICULTY ($BBC3)
; ===============================================================================
; Loads difficulty parameters based on current sector level
; This routine configures enemy behavior, firing frequency, and game speed
; for the current sector by loading 4 parameters from a level-based table.
;
; Called once per frame from main game loop ($A33A)
;
; Parameters loaded:
; - $D1: Enemy accuracy/difficulty parameter
; - $D7: Enemy firing frequency (frames between shots - lower = faster)
; - $D6: Game speed parameter
; - $D8: Timing parameter
;
; The level table at $BBE4 contains 4 bytes per sector (0-7+)
; As sectors increase, firing frequency increases (D7 decreases)
; ===============================================================================

$BBC3: A5 D5    set_sector_difficulty:
                LDA $D5         ; Load current sector/level counter
$BBC5: AA       TAX             ; Transfer to X for state checking
$BBC6: A9 30    LDA #$30        ; Load base value
$BBC8: 85 7F    STA $7F         ; Store base parameter
$BBCA: A5 D5    LDA $D5         ; Load sector counter again
$BBCC: 0A       ASL             ; Multiply by 4 (sector * 4)
$BBCD: 0A       ASL             ; Each sector has 4 bytes of parameters
$BBCE: AA       TAX             ; Use as table index
$BBCF: BD E4 BB LDA $BBE4,X     ; Load parameter 1 from sector table
$BBD2: 85 D1    STA $D1         ; Store enemy accuracy/difficulty parameter
$BBD4: BD E5 BB LDA $BBE5,X     ; **LOAD FIRING FREQUENCY** from sector table
$BBD7: 85 D7    STA $D7         ; Store in firing frequency variable ($D7)
                                ; Lower values = enemies fire more frequently
$BBD9: BD E7 BB LDA $BBE7,X     ; Load parameter 3 from sector table  
$BBDC: 85 D8    STA $D8         ; Store timing parameter
$BBDE: BD E6 BB LDA $BBE6,X     ; Load parameter 2 from sector table
$BBE1: 85 D6    STA $D6         ; Store game speed parameter
$BBE3: 60       RTS             ; Return
; ===============================================================================
; SECTOR DIFFICULTY PARAMETER TABLES ($BBE4-$BC03)
; ===============================================================================
; **ENEMY FIRING FREQUENCY AND DIFFICULTY DATA**
; Format: 4 bytes per sector (D1, D7, D6, D8)
; - D1 = Enemy spawn limit (enemies that must be defeated to clear sector)
; - D7 = FIRING FREQUENCY (frames between shots - lower = more frequent)
; - D6 = Game speed parameter
; - D8 = Timing parameter
; 
; **GAME HAS 8 SECTORS (0-7)**:
; - Sector 0: Tutorial (no enemy firing)
; - Sectors 1-7: Progressive difficulty
; - Data at $BC04-$BC0F appears to be unused/leftover development data
;
; FIRING FREQUENCY ANALYSIS (Atari 5200 NTSC @ 59.92 Hz):
; **THEORETICAL RATES** (if fired every opportunity):
; Sector 0: D7=$00 (0)   = NO FIRING (tutorial sector)
; Sector 1: D7=$60 (96)  = 0.62 shots/sec (every 1602ms)
; Sector 2: D7=$40 (64)  = 0.94 shots/sec (every 1068ms)
; Sector 3: D7=$30 (48)  = 1.25 shots/sec (every 801ms)
; Sector 4: D7=$25 (37)  = 1.62 shots/sec (every 617ms)
; Sector 5: D7=$13 (19)  = 3.15 shots/sec (every 317ms)
; Sector 6: D7=$06 (6)   = 9.99 shots/sec (every 100ms)
; Sector 7: D7=$04 (4)   = 14.98 shots/sec (every 67ms)
;
; **ACTUAL RATES** (accounting for randomization and conditions):
; - ~25% of theoretical due to hardware randomization ($E80A & #$03 ≠ 0)
; - Additional reductions from enemy state and missile availability checks
; - Sector 1: ~0.15 shots/sec (every ~6.4 seconds)
; - Sector 2: ~0.23 shots/sec (every ~4.3 seconds)  
; - Sector 3: ~0.31 shots/sec (every ~3.2 seconds)
; - Sector 4: ~0.40 shots/sec (every ~2.5 seconds)
; - Sector 5: ~0.79 shots/sec (every ~1.3 seconds)
; - Sector 6: ~2.50 shots/sec (every ~0.4 seconds)
; - Sector 7: ~3.75 shots/sec (every ~0.27 seconds)
; ===============================================================================
$BBE4: .byte $0E, $00, $02, $15    ; Sector 0:  D1=14,  D7=0,    D6=2,   D8=21  (No firing)
$BBE8: .byte $14, $60, $02, $12    ; Sector 1:  D1=20,  D7=96,   D6=2,   D8=18
$BBEC: .byte $1A, $40, $03, $08    ; Sector 2:  D1=26,  D7=64,   D6=3,   D8=8
$BBF0: .byte $1D, $30, $04, $06    ; Sector 3:  D1=29,  D7=48,   D6=4,   D8=6
$BBF4: .byte $20, $25, $0A, $04    ; Sector 4:  D1=32,  D7=37,   D6=10,  D8=4
$BBF8: .byte $24, $13, $50, $03    ; Sector 5:  D1=36,  D7=19,   D6=80,  D8=3
$BBFC: .byte $36, $06, $FF, $01    ; Sector 6:  D1=54,  D7=6,    D6=255, D8=1
$BC00: .byte $75, $04, $FF, $01    ; Sector 7:  D1=117, D7=4,    D6=255, D8=1

; Unused/leftover data (beyond 8 valid sectors)
$BC04: .byte $01, $FF, $01, $3C    ; Unused:    D1=1,   D7=255,  D6=1,   D8=60
$BC08: .byte $3A, $38, $36, $34    ; Unused:    D1=58,  D7=56,   D6=54,  D8=52
$BC0C: .byte $32, $30, $2E, $2C    ; Unused:    D1=50,  D7=48,   D6=46,  D8=44

; ===============================================================================
; PLAYER_RESET_AND_INITIALIZATION ($BC11-$BC3E)
; ===============================================================================
; **PLAYER CHARACTER RESET AND ENEMY SLOT CLEARING**
; This routine resets the player character to a starting position and clears
; enemy slot status. Called at the beginning of each sector or after player death.
; It randomizes the starting X position and initializes player/enemy state variables.
;
; **FUNCTION**:
; 1. Randomly selects starting position (index 2 or 3 from $BFD4 table)
; 2. Sets player X position ($80) and hardware register ($C000/HPOSP0)
; 3. Sets player Y position to $66 (102 decimal)
; 4. Clears enemy slot status ($94-$96) - marks all 3 enemy slots as empty
; 5. Sets active flags ($98-$9A) - enables player, enemy, and missile systems
; 6. Jumps to additional player setup routine at $B4CB
;
; **RANDOMIZATION**:
; - Uses hardware random register ($E80A) to select between X positions
; - If random bit 0 = 0: Uses index 2 (X=$6E/110)
; - If random bit 0 = 1: Uses index 3 (X=$87/135)
; - This provides variety in player starting positions
;
; **ENEMY SLOT CLEARING**:
; - $94, $95, $96: Enemy slot status (0=empty, 1=defeated)
; - Clearing these allows new enemies to spawn
; - Only cleared if game state ($D4) < difficulty ($D1)
;
; **ACTIVE FLAGS**:
; - $98: Player active flag (1=active)
; - $99: Enemy active flag (1=active)
; - $9A: Missile active flag (1=active)
;
; **CALLED FROM**:
; - $A343: Main game loop (sector initialization)
; ===============================================================================

position_player_and_activate_enemies:
$BC11: A2 02    LDX #$02        ; **INITIALIZE INDEX** - Default to position 2
$BC13: AD 0A E8 LDA $E80A       ; **HARDWARE RANDOMIZATION** - Read random register
$BC16: 29 01    AND #$01        ; **MASK BIT 0** - Get random 0 or 1
$BC18: D0 02    BNE $BC1C       ; **BRANCH IF BIT SET** - Use index 3 if random bit = 1
$BC1A: A2 03    LDX #$03        ; **ALTERNATE INDEX** - Use position 3
$BC1C: BD D4 BF LDA $BFD4,X     ; **LOAD STARTING X POSITION** - Get X coord from table
$BC1F: 85 80    STA $80         ; **STORE PLAYER X** - Save to player X position variable
$BC21: 8D 00 C0 STA $C000       ; **HPOSP0** - Set Player 0 hardware X position
$BC24: A9 66    LDA #$66        ; **LOAD STARTING Y** - Y position = 102 decimal
$BC26: 85 84    STA $84         ; **STORE PLAYER Y** - Save to player Y position variable
$BC28: A5 D4    LDA $D4         ; **LOAD GAME STATE** - Check current game state
$BC2A: C5 D1    CMP $D1         ; **COMPARE WITH DIFFICULTY** - Check against difficulty parameter
$BC2C: B0 08    BCS $BC36       ; **BRANCH IF HIGHER** - Skip clearing if state >= difficulty
$BC2E: A9 00    LDA #$00        ; **CLEAR VALUE** - Load zero
$BC30: 85 94    STA $94         ; **CLEAR ENEMY SLOT 1** - Mark enemy slot 1 as empty
$BC32: 85 95    STA $95         ; **CLEAR ENEMY SLOT 2** - Mark enemy slot 2 as empty
$BC34: 85 96    STA $96         ; **CLEAR ENEMY SLOT 3** - Mark enemy slot 3 as empty
$BC36: A9 01    LDA #$01        ; **INITIALIZE VALUE** - Load 1
$BC38: 85 98    STA $98         ; **SET PLAYER ACTIVE** - Enable player system
$BC3A: 85 99    STA $99         ; **SET ENEMY ACTIVE** - Enable enemy system
$BC3C: 85 9A    STA $9A         ; **SET MISSILE ACTIVE** - Enable missile system
$BC3E: 4C CB B4 JMP $B4CB       ; **JUMP TO PLAYER SETUP** - Continue initialization

$BC41: A5 64    LDA $64
$BC43: 18       CLC
$BC44: 65 72    ADC #$72
$BC46: 85 72    STA $72
$BC48: A6 64    LDX $64
$BC4A: A4 77    LDY $77
$BC4C: BD 20 BE LDA $BE20
$BC4F: 91 79    STA $79
$BC51: E8       INX
$BC52: C8       INY
$BC53: E4 72    CPX #$72
$BC55: D0 F5    BNE $BC4C ; Loop back if not zero
$BC57: 60       RTS

; ===============================================================================
; ADJUST_HORIZONTAL_POSITION ($BC58-$BC7B)
; ===============================================================================
; **HORIZONTAL POSITION ADJUSTMENT WITH HARDWARE UPDATE**
; This routine adjusts a horizontal position value and updates the corresponding
; hardware position register. Used for moving sprites/missiles left or right.
;
; **INPUT PARAMETERS**:
; - $73: Direction flag (0=left/decrement, 1=right/increment)
; - $74: Hardware register offset (added to $C000 base)
; - $65: Number of pixels to move (loop counter)
; - $78: Current X position
;
; **FUNCTION**:
; - If $73 = 0: Decrements $78 by $65 (moves left)
; - If $73 = 1: Increments $78 by $65 (moves right)
; - Updates hardware register $C000+$74 each iteration
; - Returns updated position in $78
;
; **HARDWARE REGISTERS**:
; - $C000-$C003: HPOSP0-HPOSP3 (Player horizontal positions)
; - $C004-$C007: HPOSM0-HPOSM3 (Missile horizontal positions)
;
; **CALLED FROM**:
; - $AF58, $AF8C: Player sprite positioning
; - $B1D5, $B206: Missile movement system
; - $B644: Additional sprite positioning
; ===============================================================================

update_hpos:
$BC58: A6 74    LDX $74         ; **LOAD REGISTER OFFSET** - Get hardware register index
$BC5A: A4 65    LDY $65         ; **LOAD MOVE DISTANCE** - Get number of pixels to move
$BC5C: A5 73    LDA $73         ; **LOAD DIRECTION FLAG** - Check movement direction
$BC5E: F0 0E    BEQ $BC6E       ; **BRANCH IF ZERO** - Jump to decrement (left/up)
; **INCREMENT PATH (RIGHT/DOWN MOVEMENT)**
$BC60: A5 78    LDA $78         ; **LOAD CURRENT X** - Get current position
$BC62: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$BC63: 69 01    ADC #$01        ; **INCREMENT X** - Move right by 1 pixel
$BC65: 9D 00 C0 STA $C000,X     ; **UPDATE HARDWARE** - Write to position register
$BC68: 85 78    STA $78         ; **STORE NEW X** - Save updated position
$BC6A: 88       DEY             ; **DECREMENT COUNTER** - One less pixel to move
$BC6B: D0 F5    BNE $BC60       ; **LOOP** - Continue until all pixels moved
$BC6D: 60       RTS             ; **RETURN** - Exit with updated position
; **DECREMENT PATH (LEFT/UP MOVEMENT)**
$BC6E: A5 78    LDA $78         ; **LOAD CURRENT X** - Get current position
$BC70: 38       SEC             ; **SET CARRY** - Prepare for subtraction
$BC71: E9 01    SBC #$01        ; **DECREMENT X** - Move left by 1 pixel
$BC73: 9D 00 C0 STA $C000,X     ; **UPDATE HARDWARE** - Write to position register
$BC76: 85 78    STA $78         ; **STORE NEW X** - Save updated position
$BC78: 88       DEY             ; **DECREMENT COUNTER** - One less pixel to move
$BC79: D0 F5    BNE $BC6E       ; **LOOP** - Continue until all pixels moved
$BC7B: 60       RTS             ; **RETURN** - Exit with updated position

; ===============================================================================
; COPY_SPRITE_DATA ($BC7C-$BCB6)
; ===============================================================================
; **SPRITE DATA COPY/RENDERING ROUTINE**
; This routine copies sprite graphics data from source to destination memory,
; used for rendering sprites to PMG (Player/Missile Graphics) memory.
; The direction of copying is controlled by the orientation flag in $73.
;
; **INPUT PARAMETERS**:
; - $65: Number of rows to copy (outer loop counter)
; - $71: Number of bytes per row (inner loop counter, width)
; - $73: Orientation/direction flag (0=decrement Y, 1=increment Y)
; - $75/$76: Destination pointer (high/low bytes, $75 initialized to $FF)
; - $77: Starting Y position/offset
; - $79/$7A: Source pointer (high/low bytes)
;
; **FUNCTION**:
; - Copies sprite data row by row from source ($79/$7A) to destination ($75/$76)
; - If $73 = 0: Copies while decrementing Y (moving up/left in memory)
; - If $73 ≠ 0: Copies while incrementing Y (moving down/right in memory)
; - Each row copies $71 bytes using indirect indexed addressing
;
; **CALLED FROM**:
; - $AF39, $AF71, $AFA5: Player sprite rendering with orientation
; - $B6CE, $B6D1: Enemy sprite updates (called twice)
; ===============================================================================

copy_sprite_data:
$BC7C: A5 65    LDA $65         ; **LOAD ROW COUNT** - Get number of rows to copy
$BC7E: 85 66    STA $66         ; **STORE COUNTER** - Save as outer loop counter
$BC80: A9 FF    LDA #$FF        ; **INIT DEST HIGH** - Load high byte for destination pointer
$BC82: 85 75    STA $75         ; **STORE DEST HIGH** - Set destination pointer high byte
$BC84: A4 7A    LDY $7A         ; **LOAD SOURCE HIGH** - Get source pointer high byte
$BC86: 88       DEY             ; **DECREMENT** - Adjust source pointer
$BC87: 84 76    STY $76         ; **STORE DEST LOW** - Set destination pointer low byte
$BC89: A5 73    LDA $73         ; **LOAD DIRECTION** - Check orientation flag
$BC8B: D0 13    BNE $BCA0       ; **BRANCH IF INCREMENT** - Jump to increment path if $73 ≠ 0

; **DECREMENT PATH** (orientation = 0, moving up/left)
$BC8D: A4 77    LDY $77         ; **LOAD Y OFFSET** - Get starting Y position
$BC8F: A6 71    LDX $71         ; **LOAD WIDTH** - Get bytes per row counter
$BC91: B1 79    LDA ($79),Y     ; **READ SOURCE** - Load byte from source pointer + Y
$BC93: 91 75    STA ($75),Y     ; **WRITE DEST** - Store byte to destination pointer + Y
$BC95: C8       INY             ; **INCREMENT Y** - Move to next byte in row
$BC96: CA       DEX             ; **DECREMENT WIDTH** - One less byte to copy
$BC97: 10 F8    BPL $BC91       ; **LOOP ROW** - Continue until row complete
$BC99: C6 77    DEC $77         ; **DECREMENT Y POS** - Move to previous row (up/left)
$BC9B: C6 66    DEC $66         ; **DECREMENT ROWS** - One less row to copy
$BC9D: D0 EE    BNE $BC8D       ; **LOOP ROWS** - Continue until all rows copied
$BC9F: 60       RTS             ; **RETURN** - Exit decrement path

; **INCREMENT PATH** (orientation ≠ 0, moving down/right)
$BCA0: A5 77    LDA $77         ; **LOAD Y OFFSET** - Get starting Y position
$BCA2: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$BCA3: 65 71    ADC $71         ; **ADD WIDTH** - Calculate ending Y position
$BCA5: A8       TAY             ; **TRANSFER TO Y** - Use as Y index
$BCA6: A6 71    LDX $71         ; **LOAD WIDTH** - Get bytes per row counter
$BCA8: B1 75    LDA ($75),Y     ; **READ SOURCE** - Load byte from source pointer + Y
$BCAA: 91 79    STA ($79),Y     ; **WRITE DEST** - Store byte to destination pointer + Y
$BCAC: 88       DEY             ; **DECREMENT Y** - Move to previous byte in row
$BCAD: CA       DEX             ; **DECREMENT WIDTH** - One less byte to copy
$BCAE: 10 F8    BPL $BCA8       ; **LOOP ROW** - Continue until row complete
$BCB0: E6 77    INC $77         ; **INCREMENT Y POS** - Move to next row (down/right)
$BCB2: C6 66    DEC $66         ; **DECREMENT ROWS** - One less row to copy
$BCB4: D0 EA    BNE $BCA0       ; **LOOP ROWS** - Continue until all rows copied
$BCB6: 60       RTS             ; **RETURN** - Exit increment path

; ===============================================================================
; UPDATE_VPOS_WITH_MASKING ($BCB7-$BD08)
; ===============================================================================
; **VERTICAL POSITION UPDATE WITH SPRITE MASKING**
; This routine updates vertical sprite positions with proper masking to handle
; sprite overlap and movement. It uses bit masking to clear old sprite data
; and draw new sprite data at the updated position.
;
; **INPUT PARAMETERS**:
; - $72: Sprite index (used to look up sprite data at $BF7C)
; - $73: Direction flag (0=up/decrement, 1=down/increment)
; - $77: Current Y position
; - $75/$76: Pointer to sprite memory (high/low bytes)
; - $79/$7A: Pointer to destination memory (high/low bytes)
;
; **FUNCTION**:
; 1. Loads sprite pattern from $BF7C table
; 2. Creates inverted mask (EOR #$FF) for clearing
; 3. If $73 = 0: Moves sprite up (decrements Y)
; 4. If $73 = 1: Moves sprite down (increments Y)
; 5. Uses AND/ORA operations to mask and draw sprite
;
; **MASKING TECHNIQUE**:
; - AND with inverted pattern clears old sprite bits
; - ORA with normal pattern sets new sprite bits
; - Prevents sprite corruption during movement
;
; **CALLED FROM**:
; - $B1A4, $B1AB, $B1B2, $B1B9: Missile movement (multiple calls for smooth animation)
; - $B1F0, $B221: Additional missile animation updates
; ===============================================================================

update_vpos_with_masking:
$BCB7: A9 13    LDA #$13        ; **INITIALIZE HEIGHT** - Load sprite height (19 pixels)
$BCB9: 85 7A    STA $7A         ; **STORE HEIGHT** - Save in $7A
$BCBB: A9 FF    LDA #$FF        ; **INITIALIZE MASK** - Load $FF for masking
$BCBD: 85 75    STA $75         ; **STORE MASK HIGH** - Save high byte
$BCBF: A2 13    LDX #$13        ; **LOAD COUNTER** - Initialize to 19
$BCC1: CA       DEX             ; **DECREMENT COUNTER** - Reduce by 1
$BCC2: 8A       TXA             ; **TRANSFER TO A** - Move counter to accumulator
$BCC3: 85 76    STA $76         ; **STORE MASK LOW** - Save low byte
$BCC5: A5 72    LDA $72         ; **LOAD SPRITE INDEX** - Get sprite table index
$BCC7: AA       TAX             ; **TRANSFER TO X** - Use as index register
$BCC8: BD 7C BF LDA $BF7C,X     ; **LOAD SPRITE PATTERN** - Get pattern from table
$BCCB: 85 72    STA $72         ; **STORE PATTERN** - Save sprite pattern
$BCCD: 49 FF    EOR #$FF        ; **INVERT PATTERN** - Create clear mask (flip all bits)
$BCCF: 85 74    STA $74         ; **STORE INVERTED** - Save inverted pattern for clearing
$BCD1: A2 02    LDX #$02        ; **LOAD PIXEL COUNT** - Process 2 pixels
$BCD3: A5 73    LDA $73         ; **LOAD DIRECTION FLAG** - Check movement direction
$BCD5: D0 17    BNE $BCEE       ; **BRANCH IF DOWN** - Jump to increment path
; **DECREMENT PATH (UP MOVEMENT)**
$BCD7: A4 77    LDY $77         ; **LOAD Y POSITION** - Get current Y coordinate
$BCD9: B1 75    LDA ($75),Y     ; **LOAD OLD SPRITE DATA** - Read from sprite memory
$BCDB: 25 74    AND $74         ; **CLEAR OLD BITS** - Mask out old sprite with inverted pattern
$BCDD: 85 66    STA $66         ; **STORE CLEARED** - Save cleared data
$BCDF: B1 79    LDA ($79),Y     ; **LOAD DESTINATION** - Read from destination memory
$BCE1: 25 72    AND $72         ; **MASK WITH PATTERN** - Apply sprite pattern
$BCE3: 05 66    ORA $66         ; **COMBINE** - Merge cleared and new sprite data
$BCE5: 91 75    STA ($75),Y     ; **WRITE SPRITE** - Store to sprite memory
$BCE7: C8       INY             ; **INCREMENT Y** - Move to next scan line
$BCE8: CA       DEX             ; **DECREMENT COUNTER** - One less pixel to process
$BCE9: 10 EE    BPL $BCD9       ; **LOOP** - Continue if more pixels
$BCEB: C6 77    DEC $77         ; **DECREMENT Y POSITION** - Move sprite up
$BCED: 60       RTS             ; **RETURN** - Exit routine
; **INCREMENT PATH (DOWN MOVEMENT)**
$BCEE: A5 77    LDA $77         ; **LOAD Y POSITION** - Get current Y coordinate
$BCF0: 18       CLC             ; **CLEAR CARRY** - Prepare for addition
$BCF1: 69 02    ADC #$02        ; **ADD OFFSET** - Move down 2 pixels
$BCF3: A8       TAY             ; **TRANSFER TO Y** - Use as index
$BCF4: B1 79    LDA ($79),Y     ; **LOAD DESTINATION** - Read from destination memory
$BCF6: 25 74    AND $74         ; **CLEAR OLD BITS** - Mask out old sprite with inverted pattern
$BCF8: 85 66    STA $66         ; **STORE CLEARED** - Save cleared data
$BCFA: B1 75    LDA ($75),Y     ; **LOAD SPRITE DATA** - Read from sprite memory
$BCFC: 25 72    AND $72         ; **MASK WITH PATTERN** - Apply sprite pattern
$BCFE: 05 66    ORA $66         ; **COMBINE** - Merge cleared and new sprite data
$BD00: 91 79    STA ($79),Y     ; **WRITE SPRITE** - Store to destination memory
$BD02: 88       DEY             ; **DECREMENT Y** - Move to previous scan line
$BD03: CA       DEX             ; **DECREMENT COUNTER** - One less pixel to process
$BD04: 10 EE    BPL $BCF4       ; **LOOP** - Continue if more pixels
$BD06: E6 77    INC $77         ; **INCREMENT Y POSITION** - Move sprite down
$BD08: 60       RTS             ; **RETURN** - Exit routine

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

$BD30: A5 64    LDA $64
$BD32: 18       CLC
$BD33: 69 0C    ADC #$0C
$BD35: 85 72    STA $72
$BD37: A6 64    LDX $64
$BD39: A4 77    LDY $77
$BD3B: BD 80 BF LDA $BF80
$BD3E: 91 79    STA $79
$BD40: E8       INX
$BD41: C8       INY
$BD42: E4 72    CPX #$72
$BD44: D0 F5    BNE $BD3B ; Loop back if not zero
$BD46: 60       RTS
; ===============================================================================
; BOUNDARY_CHECK ($BD47)
; Player position boundary detection for death trigger
; This routine:
; - Checks if player position ($69 + $0E) exceeds boundary ($C0)
; - Sets death detection flag $97 when boundary exceeded
; - Triggers death processing in display update routine
; - Boundary check likely detects player going off-screen or into deadly areas
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
$BD57: 95 97    STA $97,X       ; Set death detection flag $97 = 1
$BD59: 60       RTS             ; Return - death will be processed next frame
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
; ===============================================================================
; PLAYER_BONUS_SCORE_INCREASE ($BD66-$BDA1)
; Player bonus scoring and enemy hit scoring system
; 
; Two entry points:
; - $BD66: Called when player fires weapon (with $AC parameter)
; - $BD6C: Called when enemy is hit (with X=#$03 parameter)
;
; FUNCTIONS:
; 1. SCORE UPDATE ($BD6E-$BD82):
;
; 2. SCORE DISPLAY UPDATE ($BD83-$BD8F):
;
; 3. SOUND EFFECT TRIGGER ($BD91-$BDA1):
;
; **ENTRY POINTS**:
; - $BD66 (player_bonus_score_increase): Bonus point awards (loads value from $AC)
;
; - $BD6C (enemy_hit_scoring): Combat scoring (value already in accumulator)
; ===============================================================================
player_bonus_score_increase:
$BD66: A5 AC    LDA $AC         ; **BONUS ENTRY** - Load bonus value from $AC
$BD68: A2 02    LDX #$02        ; Set score digit index (hundreds place)
$BD6A: D0 02    BNE $BD6E       ; Branch to score processing
enemy_hit_scoring:
$BD6C: A2 03    LDX #$03        ; **COMBAT ENTRY** - Set score digit index (tens place)
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
$BD91: AD 0B 06 LDA $060B       ; Load updated score digit
$BD94: C5 7B    $060CMP $7B         ; Compare with previous score value
$BD96: D0 01    BNE $BD99       ; Branch if score changed
$BD98: 60       RTS             ; Return if no score change (no sound)
$BD99: 85 7B    STA $7B         ; Store new score value
$BD9B: A9 4F    LDA #$4F        ; Load hit sound frequency/duration
$BD9D: 85 D0    STA $D0         ; Set sound frequency register
$BD9F: 85 BD    STA $BD         ; Set sound control register
$BDA1: 60       RTS             ; Return from player_bonus_score_increase

; ===============================================================================
; CLEAR COLLISION REGISTERS ($BDA2)
; ===============================================================================
; Resets GTIA graphics control and collision detection registers
; This routine:
; - Disables graphics via GRACTL register
; - Clears all 8 collision detection registers ($C000-$C007)
; - Prepares hardware for new display/collision detection cycle
;
; Called at: title screen, sector init, new level setup, game preparation
; ===============================================================================
$BDA2: A9 00    clear_collision_registers:
                LDA #$00         ; Clear accumulator
$BDA4: 8D 1D C0 STA $C01D        ; GTIA GRACTL - Graphics control (disable graphics)
$BDA7: A2 07    LDX #$07         ; Set loop counter (8 registers to clear)
$BDA9: 9D 00 C0 STA $C000,X      ; Clear collision registers $C000-$C007
                                 ; $C000-$C003: Player-to-playfield collisions (P0PF-P3PF)
                                 ; $C004-$C007: Missile-to-playfield collisions (M0PF-M3PF)
$BDAC: CA       DEX              ; Decrement counter
$BDAD: 10 FA    BPL $BDA9        ; Loop until all 8 registers cleared
$BDAF: 60       RTS              ; Return

; ===============================================================================
; HARDWARE_INIT ($BDB0-$BDBC)
; ===============================================================================
; **HARDWARE INITIALIZATION ROUTINE**
; Initializes critical hardware registers for display and sound systems.
; This routine is called frequently throughout the game to reset hardware state.
;
; **FUNCTION**:
; 1. Sets $E80E to $40 (64) - Display/sprite control register
; 2. Sets $00 (zero page) to $40 - Mirror of display control
; 3. Sets POKEY SKCTL ($D409) to $A0 (160) - Serial/keyboard control
;
; **POKEY SKCTL ($D409) = $A0 (10100000 binary)**:
; - Bit 7 (1): Force break (serial output)
; - Bit 5 (1): Enable keyboard scan
; - Bits 0-4 (0): Normal serial mode, no fast pot scan
;
; **USAGE CONTEXTS**:
; - **Sector Setup** ($A54B, $A584, $A6FC): Initialize display for new sector
; - **Arena Generation** ($AA4A): Reset hardware before arena creation
; - **Game State Changes** ($AB1F, $ABF5): Reinitialize during gameplay transitions
;
; **PURPOSE**:
; This routine ensures the hardware is in a known state for display rendering
; and input processing. The $40 value in $E80E/$00 likely controls sprite/display
; modes, while the POKEY SKCTL setting enables keyboard scanning for joystick input.
; ===============================================================================

prepare_display_and_input_scanning:
$BDB0: A9 40    LDA #$40         ; **DISPLAY CONTROL** - Load display mode value
$BDB2: 8D 0E E8 STA $E80E        ; Set display/sprite control register
$BDB5: 85 00    STA $00          ; Mirror to zero page for fast access
$BDB7: A9 A0    LDA #$A0         ; **POKEY CONTROL** - Load SKCTL value ($A0 = 10100000)
$BDB9: 8D 09 D4 STA $D409        ; **POKEY SKCTL** - Enable keyboard scan, force break
$BDBC: 60       RTS              ; Return with hardware initialized

; ===============================================================================
; CLEAR GAME STATE ($BDBD)
; ===============================================================================
; Resets game state variables in RAM $E800-$E807
; This routine clears sprite positions, animation counters, and sound parameters
; Called at: title screen, arena generation, player respawn, escape sequence
; ===============================================================================
$BDBD: A9 00    clear_game_state:
                LDA #$00         ; Clear accumulator
$BDBF: 85 BE    STA $BE          ; Clear zero page variable $BE
$BDC1: 85 B9    STA $B9          ; Clear sprite animation flag $B9
$BDC3: A2 07    LDX #$07         ; Set loop counter (8 bytes: $E800-$E807)
$BDC5: 9D 00 E8 STA $E800,X      ; Clear game state RAM $E800-$E807
                                 ; $E800 = sprite position/arena counter
                                 ; $E801 = sprite config/audio control
                                 ; $E802 = animation timer
                                 ; $E803 = secondary timer/sound
                                 ; $E804 = player sprite X position
                                 ; $E805 = player sprite character code
                                 ; $E806 = animation frame
                                 ; $E807 = animation speed
$BDC8: CA       DEX              ; Decrement counter
$BDC9: 10 FA    BPL $BDC5        ; Loop until all 8 bytes cleared
$BDCB: A9 01    LDA #$01         ; Set initialization flag
$BDCD: 8D 08 E8 STA $E808        ; Store to sound/sprite control register
$BDD0: A9 A0    LDA #$A0         ; Load default sprite character code
$BDD2: 85 B7    STA $B7          ; Store to zero page variable $B7
$BDD4: 60       RTS              ; Return

; ===============================================================================
; DISPLAY_LIST_SETUP ($BDD5-$BDEA)
; ===============================================================================
; **DISPLAY LIST MODIFICATION WITH SYNCHRONIZED TIMING**
; This routine modifies the display list with precise timing synchronization
; to avoid visual artifacts (tearing/glitches) during screen updates.
;
; **INPUT PARAMETERS**:
; - A: Base value (multiplied by 2 via ASL) - typically sector number or display mode
; - X: Value to write to WSYNC ($A6 = 166) - triggers horizontal sync wait
; - Y: Vertical position/parameter ($3B = 59)
;
; **FUNCTION**:
; 1. Doubles the accumulator value (ASL) and stores in $69
; 2. Writes X to POKEY WSYNC ($D40A) - **HALTS CPU until next horizontal scan line**
; 3. Executes 5-cycle delay loop for additional timing precision
; 4. Writes doubled A value (from $69) to display list at $0205
; 5. Writes Y value to display list at $0204
;
; **WHY WSYNC AND DELAY?**:
; - **WSYNC**: Ensures display list modifications happen during horizontal blank
; - **5-cycle delay**: Provides additional timing buffer to ensure modifications
; - **Purpose**: Prevents visual tearing/glitches when changing display list mid-frame
;
; **DISPLAY LIST MEMORY ($0204-$0205)**:
; These locations are part of the display list structure that controls how
; ANTIC renders the screen. Modifying them with synchronized timing ensures
; smooth visual transitions without artifacts.
;
; **USAGE CONTEXTS**:
; - **Sector Setup** ($A6F3): Updates display list for sector/level display
; - **Sound System** ($B030): Same timing mechanism for audio/visual coordination
;
; **NOT SCREEN ERASING**: This routine modifies display list parameters, not
; screen memory. Screen clearing is done by other routines (like $B89B).
; ===============================================================================

configure_display_list:
$BDD5: 0A       ASL             ; **DOUBLE INPUT VALUE** - Multiply A by 2
$BDD6: 85 69    STA $69         ; Store doubled value in zero page for later use
$BDD8: 8A       TXA             ; **TRANSFER X TO A** - Prepare X value for WSYNC
$BDD9: A2 05    LDX #$05        ; **TIMING DELAY SETUP** - Load 5-cycle counter
$BDDB: 8D 0A D4 STA $D40A       ; **POKEY WSYNC** - Write to WSYNC, CPU halts until horizontal sync!
$BDDE: CA       DEX             ; Decrement delay counter (executed after sync)
$BDDF: D0 FD    BNE $BDDE       ; **5-CYCLE DELAY LOOP** - Additional timing buffer
$BDE1: A6 69    LDX $69         ; **RELOAD DOUBLED VALUE** - Get processed A value from $69
$BDE3: 8D 05 02 STA $0205       ; **DISPLAY LIST UPDATE** - Write to DL during safe timing window
$BDE6: 98       TYA             ; **TRANSFER Y PARAMETER** - Move Y to accumulator  
$BDE7: 8D 04 02 STA $0204       ; **DISPLAY LIST UPDATE** - Write Y to DL during safe timing window
$BDEA: 60       RTS             ; Return with display list safely modified

process_joystick_input:
$BDEB: A9 FF    LDA #$FF
$BDED: 85 60    STA $60
$BDEF: A5 12    LDA $12
$BDF1: C9 B8    CMP #$B8
$BDF3: B0 0C    BCS $BE01 ; Branch if carry set
$BDF5: C9 18    CMP #$18
$BDF7: B0 0E    BCS $BE07 ; Branch if carry set
$BDF9: A5 60    LDA $60
$BDFB: 29 FE    AND #$FE
$BDFD: 85 60    STA $60
$BDFF: D0 06    BNE $BE07 ; Loop back if not zero
$BE01: A5 60    LDA $60
$BE03: 29 FD    AND #$FD
$BE05: 85 60    STA $60
$BE07: A5 11    LDA $11
$BE09: C9 B8    CMP #$B8
$BE0B: B0 0C    BCS $BE19 ; Branch if carry set
$BE0D: C9 18    CMP #$18
$BE0F: B0 0E    BCS $BE1F ; Branch if carry set
$BE11: A5 60    LDA $60
$BE13: 29 FB    AND #$FB
$BE15: 85 60    STA $60
$BE17: D0 06    BNE $BE1F ; Loop back if not zero
$BE19: A5 60    LDA $60
$BE1B: 29 F7    AND #$F7
$BE1D: 85 60    STA $60
$BE1F: 60       RTS

; ===============================================================================
; PLAYER SPRITE ANIMATION DATA ($BE20-$BFD3)
; ===============================================================================
PLAYER_SPRITE_DATA:
; Player sprite animation data.

; PLAYER - STATIONARY
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $08        ; ....#...
        .byte $1C        ; ...###.. **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies
        .byte $2A        ; ..#.#.#.
        .byte $2A        ; ..#.#.#.
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $36        ; ..##.##.

; PLAYER - WALKING LEFT 1
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $08        ; ....#...
        .byte $5C        ; .#.###..
        .byte $2A        ; ..#.#.#.
        .byte $09        ; ....#..#
        .byte $0A        ; ....#.#.
        .byte $18        ; ...##...
        .byte $24        ; ..#..#..
        .byte $27        ; ..#..###
        .byte $61        ; .##....#

; PLAYER - WALKING LEFT 2
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $14        ; ...#.#..
        .byte $08        ; ....#...
        .byte $0C        ; ....##..
        .byte $0C        ; ....##..
        .byte $3C        ; ..####..
        .byte $08        ; ....#...
        .byte $18        ; ...##...
        .byte $0C        ; ....##..
        .byte $0A        ; ....#.#.
        .byte $1C        ; ...###.. **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies

; PLAYER - WALKING RIGHT 1
        .byte $10        ; ...#....
        .byte $28        ; ..#.#...
        .byte $28        ; ..#.#...
        .byte $10        ; ...#....
        .byte $3A        ; ..###.#.
        .byte $54        ; .#.#.#..
        .byte $90        ; #..#....
        .byte $50        ; .#.#....
        .byte $18        ; ...##...
        .byte $24        ; ..#..#..
        .byte $E4        ; ###..#..
        .byte $86        ; #....##.

; PLAYER - WALKING RIGHT 2
        .byte $10        ; ...#....
        .byte $28        ; ..#.#...
        .byte $28        ; ..#.#...
        .byte $10        ; ...#....
        .byte $30        ; ..##....
        .byte $30        ; ..##....
        .byte $3C        ; ..####..
        .byte $10        ; ...#....
        .byte $18        ; ...##...
        .byte $30        ; ..##....
        .byte $50        ; .#.#....
        .byte $38        ; ..###...

; PLAYER - WALKING UP/DOWN 1
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $34        ; ..##.#..
        .byte $28        ; ..#.#...
        .byte $1C        ; ...###.. **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $16        ; ...#.##.
        .byte $10        ; ...#....
        .byte $30        ; ..##....

; PLAYER - WALKING UP/DOWN 2
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $16        ; ...#.##.
        .byte $0A        ; ....#.#.
        .byte $1C        ; ...###.. **ENEMY SPRITE CHARACTER** - Character $1C used for moving enemies
        .byte $28        ; ..#.#...
        .byte $28        ; ..#.#...
        .byte $08        ; ....#...
        .byte $14        ; ...#.#..
        .byte $34        ; ..##.#..
        .byte $04        ; .....#..
        .byte $06        ; .....##.

; PLAYER - SHOOTING LEFT
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $04        ; .....#..
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $C4        ; ##...#..
        .byte $7C        ; .#####..
        .byte $04        ; .....#..
        .byte $0C        ; ....##..
        .byte $14        ; ...#.#..
        .byte $0F        ; ....####
        .byte $19        ; ...##..#

; PLAYER - SHOOTING TOP LEFT
        .byte $00        ; ........
        .byte $40        ; .#......
        .byte $24        ; ..#..#..
        .byte $4A        ; .#..#.#.
        .byte $2A        ; ..#.#.#.
        .byte $14        ; ...#.#..
        .byte $0C        ; ....##..
        .byte $04        ; .....#.. **PLAYER HEAD (VERTICAL)** - Character $04
        .byte $0C        ; ....##..
        .byte $14        ; ...#.#..
        .byte $0F        ; ....####
        .byte $19        ; ...##..#

; PLAYER - SHOOTING BOTTOM LEFT
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $04        ; .....#.. **PLAYER HEAD (VERTICAL)** - Character $04
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $04        ; .....#.. **PLAYER HEAD (VERTICAL)** - Character $04
        .byte $0C        ; ....##..
        .byte $54        ; .#.#.#..
        .byte $AC        ; #.#.##..
        .byte $14        ; ...#.#..
        .byte $0F        ; ....####
        .byte $19        ; ...##..#

; PLAYER - SHOOTING RIGHT
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $20        ; ..#.....
        .byte $50        ; .#.#....
        .byte $50        ; .#.#....
        .byte $23        ; ..#...##
        .byte $3E        ; ..#####.
        .byte $20        ; ..#.....
        .byte $30        ; ..##....
        .byte $28        ; ..#.#...
        .byte $F0        ; ####....
        .byte $98        ; #..##...

; PLAYER - SHOOTING TOP RIGHT
        .byte $00        ; ........
        .byte $02        ; ......#. **PLAYER HEAD (SIDEWAYS)** - Character $02
        .byte $24        ; ..#..#..
        .byte $52        ; .#.#..#.
        .byte $54        ; .#.#.#..
        .byte $28        ; ..#.#...
        .byte $30        ; ..##....
        .byte $20        ; ..#.....
        .byte $30        ; ..##....
        .byte $28        ; ..#.#...
        .byte $F0        ; ####....
        .byte $98        ; #..##...

; PLAYER - SHOOTING BOTTOM RIGHT
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $20        ; ..#.....
        .byte $50        ; .#.#....
        .byte $50        ; .#.#....
        .byte $20        ; ..#.....
        .byte $30        ; ..##....
        .byte $2A        ; ..#.#.#.
        .byte $35        ; ..##.#.#
        .byte $28        ; ..#.#...
        .byte $F0        ; ####....
        .byte $98        ; #..##...

; PLAYER - SHOOTING UP
        .byte $00        ; ........
        .byte $04        ; .....#.. **PLAYER HEAD (VERTICAL)** - Character $04
        .byte $24        ; ..#..#..
        .byte $52        ; .#.#..#.
        .byte $54        ; .#.#.#..
        .byte $28        ; ..#.#...
        .byte $30        ; ..##....
        .byte $20        ; ..#.....
        .byte $30        ; ..##....
        .byte $28        ; ..#.#...
        .byte $F0        ; ####....
        .byte $98        ; #..##...

; PLAYER - SHOOTING DOWN
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $04        ; .....#.. **PLAYER HEAD (VERTICAL)** - Character $04
        .byte $0A        ; ....#.#.
        .byte $0A        ; ....#.#.
        .byte $04        ; .....#.. **PLAYER HEAD (VERTICAL)** - Character $04
        .byte $0C        ; ....##..
        .byte $14        ; ...#.#..
        .byte $6C        ; .##.##.. Complex sprite pattern
        .byte $54        ; .#.#.#.. Complex sprite pattern
        .byte $0F        ; ....#### Complex sprite pattern
        .byte $19        ; ...##..#

# Player / enemy explosion sprite animation.

; EXPLOSION 1
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $08        ; ....#... **DEATH ANIMATION** - Character $08
        .byte $08        ; ....#... **DEATH ANIMATION** - Character $08
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; EXPLOSION 2
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $10        ; ...#.... Sparse pattern data
        .byte $38        ; ..###...
        .byte $10        ; ...#....
        .byte $00        ; ........
        .byte $00        ; ........

; EXPLOSION 3
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $14        ; ...#.#..
        .byte $00        ; ........
        .byte $2C        ; ..#.##..

; EXPLOSION 4
        .byte $00        ; ........
        .byte $14        ; ...#.#..
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $10        ; ...#....
        .byte $00        ; ........
        .byte $58        ; .#.##...

; EXPLOSION 5
        .byte $00        ; ........
        .byte $2C        ; ..#.##..
        .byte $00        ; ........
        .byte $50        ; .#.#....
        .byte $00        ; ........
        .byte $10        ; ...#....
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $38        ; ..###...
        .byte $00        ; ........
        .byte $92        ; #..#..#.

; EXPLOSION 6
        .byte $00        ; ........
        .byte $58        ; .#.##...
        .byte $00        ; ........
        .byte $AA        ; #.#.#.#.
        .byte $00        ; ........
        .byte $54        ; .#.#.#..
        .byte $00        ; ........
        .byte $54        ; .#.#.#..
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $48        ; .#..#...
        .byte $10        ; ...#....

; EXPLOSION 7
        .byte $28        ; ..#.#...
        .byte $92        ; #..#..#.
        .byte $01        ; .......#
        .byte $58        ; .#.##...
        .byte $00        ; ........
        .byte $82        ; #.....#.
        .byte $00        ; ........
        .byte $54        ; .#.#.#..
        .byte $00        ; ........
        .byte $A0        ; #.#.....
        .byte $10        ; ...#....
        .byte $44        ; .#...#..

; EXPLOSION 8
        .byte $52        ; .#.#..#.
        .byte $24        ; ..#..#..
        .byte $10        ; ...#....
        .byte $A4        ; #.#..#..
        .byte $09        ; ....#..# **DEATH ANIMATION** - Character $09
        .byte $A0        ; #.#.....
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $84        ; #....#..
        .byte $00        ; ........
        .byte $55        ; .#.#.#.#
        .byte $00        ; ........

; EXPLOSION 9
        .byte $29        ; ..#.#..#
        .byte $52        ; .#.#..#.
        .byte $52        ; .#.#..#.
        .byte $A4        ; #.#..#..
        .byte $10        ; ...#....
        .byte $A4        ; #.#..#..
        .byte $01        ; .......#
        .byte $80        ; #.......
        .byte $01        ; .......#
        .byte $00        ; ........
        .byte $80        ; #.......
        .byte $00        ; ........

; EXPLOSION 10
        .byte $45        ; .#...#.#
        .byte $00        ; ........
        .byte $A8        ; #.#.#...
        .byte $52        ; .#.#..#.
        .byte $52        ; .#.#..#.
        .byte $24        ; ..#..#..
        .byte $10        ; ...#....
        .byte $24        ; ..#..#..
        .byte $00        ; ........
        .byte $80        ; #.......
        .byte $01        ; .......#
        .byte $00        ; ........

; EXPLOSION 11
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $01        ; .......#
        .byte $00        ; ........
        .byte $29        ; ..#.#..#
        .byte $50        ; .#.#....
        .byte $50        ; .#.#....
        .byte $A1        ; #.#....#
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $80        ; #.......

; EXPLOSION 12
        .byte $01        ; .......#
        .byte $00        ; ........
        .byte $80        ; #.......
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $81        ; #......#
        .byte $10        ; ...#....
        .byte $00        ; ........
        .byte $40        ; .#......
        .byte $00        ; ........
        .byte $02        ; ......#. **PLAYER HEAD (SIDEWAYS)** - Character $02

; EXPLOSION 13
        .byte $00        ; ........
        .byte $80        ; #.......
        .byte $00        ; ........
        .byte $01        ; .......#
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $20        ; ..#.....
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $10        ; ...#....
        .byte $00        ; ........
        .byte $00        ; ........

; EXPLOSION 14
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........
        .byte $00        ; ........

; Unknown sprite?
        .byte $03        ; ......## **PLAYER BODY (FRAME 1)** - Character $03
        .byte $0C        ; ....##.. Pattern data
        .byte $30        ; ..##.... Pattern data
        .byte $C0        ; ##...... Pattern data

# Enemy sprites and animations.

; ENEMY - STATIONARY
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex border pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Center detail
        .byte $FF        ; ######## **DETAILED SPRITE** - Full width line
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Detailed body pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Repeated body pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Repeated body pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Repeated body pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Repeated body pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $24        ; ..#..#.. **DETAILED SPRITE** - Complex pattern
        .byte $24        ; ..#..#.. **DETAILED SPRITE** - Complex pattern
        .byte $66        ; .##..##. **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING LEFT 1
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern
        .byte $3F        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..####.# **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..####.# **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..####.# **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..####.# **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..####.# **DETAILED SPRITE** - Complex pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $24        ; ..#..#.. **DETAILED SPRITE** - Complex pattern
        .byte $24        ; ..#..#.. **DETAILED SPRITE** - Complex pattern
        .byte $6C        ; .##.##.. **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING LEFT 2
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern
        .byte $3F        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $08        ; ....#... **DETAILED SPRITE** - Complex pattern
        .byte $08        ; ....#... **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING RIGHT 1
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern
        .byte $FC        ; ######.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $24        ; ..#..#.. **DETAILED SPRITE** - Complex pattern
        .byte $24        ; ..#..#.. **DETAILED SPRITE** - Complex pattern
        .byte $36        ; ..##.##. **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING RIGHT 2
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern
        .byte $FC        ; ######.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $10        ; ...#.... **DETAILED SPRITE** - Complex pattern
        .byte $10        ; ...#.... **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING UP/DOWN 1
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern
        .byte $FF        ; ######## **DETAILED SPRITE** - Complex pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Complex pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Complex pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3D        ; ..###### **DETAILED SPRITE** - Complex pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $26        ; ..#..##. **DETAILED SPRITE** - Complex pattern
        .byte $20        ; ..#..... **DETAILED SPRITE** - Complex pattern
        .byte $60        ; .##..... **DETAILED SPRITE** - Complex pattern

; ENEMY - WALKING UP/DOWN 2
        .byte $7E        ; .######. **DETAILED SPRITE** - Complex pattern
        .byte $18        ; ...##... **DETAILED SPRITE** - Complex pattern
        .byte $FF        ; ######## **DETAILED SPRITE** - Complex pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Complex pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Complex pattern
        .byte $BD        ; #.####.# **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $BC        ; #.####.. **DETAILED SPRITE** - Complex pattern
        .byte $3C        ; ..####.. **DETAILED SPRITE** - Complex pattern
        .byte $64        ; .##..#.. **DETAILED SPRITE** - Complex pattern
        .byte $04        ; .....#.. **DETAILED SPRITE** - Complex pattern
        .byte $06        ; .....##. **DETAILED SPRITE** - Complex pattern

; ===============================================================================
; PLAYER STARTING POSITION TABLE ($BFD4-$BFD7)
; ===============================================================================
; **INITIAL PLAYER X POSITIONS**
; This table contains 4 possible starting X positions for the player character.
; The game randomly selects between positions 2 and 3 (index $02 or $03) at
; the start of each sector using hardware randomization ($E80A).
;
; Used by:
; - $B015: Initial player setup at sector start
; - $BC1C: Player respawn/reset positioning
; ===============================================================================
$BFD4: 3D       .byte $3D        ; Starting position 0: X=61
$BFD5: 55       .byte $55        ; Starting position 1: X=85
$BFD6: 6E       .byte $6E        ; Starting position 2: X=110 (commonly used)
$BFD7: 87       .byte $87        ; Starting position 3: X=135 (commonly used)

; ===============================================================================
; ENEMY SPAWN POSITION TABLES ($BFD8-$BFDF)
; ===============================================================================
; **ENEMY SPAWN COORDINATES**
; These tables contain spawn positions for enemies at the arena perimeter/edges.
; Enemies always spawn at the edges as documented in the manual.
;
; **NO COLLISION CHECKING**: The spawn routine does NOT check for walls, player,
; or other enemies at spawn positions. Relies on edge positions being relatively
; safe and collision detection handling any overlaps after spawning.
;
; Used by:
; - $B4F5: Enemy spawn X position (indexed by random 0-5 from random_spawn_x)
; - $B4F9: Enemy spawn Y position (indexed by random 0-2 from random_spawn_y)
; ===============================================================================
$BFD8: A0       .byte $A0        ; X position 4: X=160 (right edge)
$BFD9: BB       .byte $BB        ; X position 5: X=187 (far right edge)
$BFDA: 30       .byte $30        ; Y position 0: Y=48  (top edge)
$BFDB: 66       .byte $66        ; Y position 1: Y=102 (middle)
$BFDC: A6       .byte $A6        ; Y position 2: Y=166 (bottom edge)
$BFDD: C9       .byte $C9        ; Unused/padding
$BFDE: 0E       .byte $0E        ; Unused/padding
$BFDF: D0       .byte $D0        ; Unused/padding

; ===============================================================================
; SYSTEM INITIALIZATION AND RESET VECTORS ($BFE0-$BFFF)
; **SYSTEM STARTUP CODE** - Reset vector handling and initialization
; This section contains the system reset and initialization code
; ===============================================================================
$BFE1: A2 FF    LDX #$FF         ; Load X register with $FF (initialize stack pointer)
$BFE3: 9A       TXS              ; Transfer X to stack pointer (set stack to $01FF)
$BFE4: 4C C8 A2 JMP cartridge_init ; Jump to main initialization routine at $A2C8

; **INPUT HANDLING** - Check for specific input conditions
$BFE7: C9 0C    CMP #$0C         ; Compare accumulator with $0C
$BFE9: D0 03    BNE $BFEE        ; Branch if not equal to $BFEE
$BFEB: 4C 2B A3 JMP go_back_to_prepare_new_game ; Jump to routine at $A32B if equal to $0C

$BFEE: C9 0D    CMP #$0D         ; Compare accumulator with $0D  
$BFF0: D0 05    BNE $BFF7        ; Branch if not equal to $BFF7
$BFF2: AD 10 C0 LDA $C010        ; **TRIGGER INPUT** - Read trigger register (0=pressed, 1=released)
$BFF5: D0 FB    BNE $BFF2        ; Wait for trigger release (wait for 0) - TITLE SCREEN WAIT
$BFF7: 4C B2 FC JMP $FCB2        ; Jump to routine at $FCB2

; ===============================================================================
; HARDWARE VECTORS ($BFFA-$BFFF)
; ===============================================================================
HARDWARE_VECTORS:
; **RESET VECTOR DATA** - System reset vector table
$BFFA: 00       .byte $00        ; Reset vector low byte (part of 6502 reset vector)
$BFFB: 00       .byte $00        ; Reset vector continuation
$BFFC: 00       .byte $00        ; Reset vector continuation  
$BFFD: FF       .byte $FF        ; Reset vector high byte
$BFFE: C8       .byte $C8        ; **NMI VECTOR LOW** - Non-maskable interrupt vector low byte
$BFFF: A2       .byte $A2        ; **NMI VECTOR HIGH** - Non-maskable interrupt vector high byte (points to cartridge_init)
