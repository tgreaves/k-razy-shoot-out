# K-Razy Shoot-Out Player Character Sprite Documentation

## Overview

This documentation describes the complete player character sprite system for K-Razy Shoot-Out, based on detailed analysis of the 6502 assembly code and ROM data. The player character uses a multi-component sprite system with different combinations for various movement states.

## Character Components

The player character is composed of three distinct 8x8 pixel sprites:

### Character $01 - Player Body Sprite (Main Torso)
```
ROM Address: $A008-$A00F
Hex Data: 38 38 38 38 18 00 18 00

Visual:
..###...
..###...
..###...
..###...
...##...
........
...##...
........
```

**Usage**: Always present - forms the main body of the player character.

### Character $08 - Player Left Leg Sprite
```
ROM Address: $A040-$A047  
Hex Data: 00 00 00 00 01 C3 C7 FF

Visual:
........
........
........
........
.......#
##....##
##...###
########
```

**Usage**: Used during vertical movement and left step of horizontal walking animation.

### Character $09 - Player Right Leg Sprite
```
ROM Address: $A048-$A04F
Hex Data: 00 00 00 80 C7 E5 FD F7

Visual:
........
........
........
#.......
##...###
###..#.#
######.#
####.###
```

**Usage**: Used during right step of horizontal walking animation.

## Movement States and Sprite Combinations

Based on the game code analysis, here are all possible player character states:

### 1. Standing Still (Idle)
- **Sprites**: Character $01 only
- **Code Logic**: No joystick input detected
- **Hardware**: Single sprite in register $E804
- **Visual**: Just the body sprite, player appears stationary

### 2. Moving Up/Down (Vertical Movement)
- **Sprites**: Character $01 + Character $08 (body + left leg)
- **Code Logic**: $C00C register active, horizontal flag $AD = 0
- **Hardware**: Body in $E804, left leg in $E805
- **Visual**: Body with left leg extended, suggesting upward/downward motion

### 3. Moving Left/Right (Horizontal Movement) - Walking Animation

The horizontal movement uses a 2-frame walking animation cycle:

#### Frame 1: Left Step
- **Sprites**: Character $01 + Character $08 (body + left leg)
- **Code Logic**: $C004 & $04 = true, sets $AD = 1
- **Visual**: Left leg forward in walking cycle

#### Frame 2: Right Step  
- **Sprites**: Character $01 + Character $09 (body + right leg)
- **Code Logic**: Continuation of horizontal movement
- **Visual**: Right leg forward in walking cycle

### 4. Moving Diagonally
- **Sprites**: Uses horizontal movement sprite logic
- **Code Logic**: Both $C004 and $C00C active, horizontal takes priority
- **Animation**: Same walking cycle as horizontal movement
- **Visual**: Walking animation while moving diagonally

## Hardware Implementation

### Animation Engine ($A63B-$A6CD)
The game uses a sophisticated animation system:

- **Frame Counter**: $B3 tracks current animation frame (0-13)
- **Animation Timer**: $B6 provides timing control  
- **Speed Control**: $B2 controls animation speed
- **Hardware Registers**: $E804-$E807 control sprite display

### VBlank Synchronization
- **Frequency**: 59.92 Hz (Atari 5200 NTSC)
- **Frame Duration**: 16.69 ms per frame
- **Synchronization**: Animation synchronized to VBlank interrupt
- **Hardware**: PMG (Player/Missile Graphics) system

### Input Processing
```assembly
; Horizontal movement detection
$A952: AD 04 C0 LDA $C004  ; Read joystick X-axis
$A955: 29 04    AND #$04   ; Check horizontal bit
$A957: F0 04    BEQ $A95D  ; Branch if no horizontal input
$A959: A9 01    LDA #$01   ; HORIZONTAL MOVEMENT DETECTED
$A95B: 85 AD    STA $AD    ; Set horizontal movement flag
```

## Sprite Sheet Files Generated

### Basic Sprite Sheets
1. **character_01.png** - Individual body sprite
2. **character_08.png** - Individual left leg sprite  
3. **character_09.png** - Individual right leg sprite
4. **complete_sprite_sheet.png** - All movement states in one sheet
5. **walking_animation.png** - Walking animation sequence
6. **technical_reference.png** - Technical details and hex data

### Advanced Analysis Sheets
7. **movement_analysis.png** - Detailed movement states with code analysis
8. **hardware_mapping.png** - Hardware register usage explanation
9. **animation_timing.png** - VBlank synchronization and timing details

## Technical Specifications

### Sprite Dimensions
- **Original Size**: 8x8 pixels per character
- **Color Depth**: 1-bit monochrome (black/white)
- **Scaling**: Generated sheets use 16x-20x scaling for visibility

### Memory Layout
- **Character Data**: Stored at $A000-$A04F in ROM
- **Hardware Registers**: $E804-$E807 for sprite control
- **Input Registers**: $C004 (X-axis), $C00C (Y-axis)
- **Game Variables**: $AD (horizontal flag), $93 (input flag)

### Animation Timing
- **Base Frequency**: 59.92 Hz VBlank interrupt
- **Walking Cycle**: 4 frames (2 unique sprite combinations)
- **Frame Duration**: ~16.7ms per frame
- **Total Cycle Time**: ~67ms for complete walking cycle

## Usage in Game Development

These sprite sheets can be used for:

1. **Game Recreation**: Accurate player character sprites for ports/remakes
2. **Animation Reference**: Understanding classic 8-bit animation techniques
3. **Pixel Art Study**: Examples of efficient sprite design within hardware constraints
4. **Technical Analysis**: Learning about Atari 5200 PMG system implementation

## Code Integration

The sprite system demonstrates several advanced techniques:

1. **Multi-Component Characters**: Using multiple 8x8 sprites to create larger characters
2. **State-Based Animation**: Different sprite combinations based on movement state
3. **Hardware Optimization**: Efficient use of PMG system registers
4. **Input-Responsive Graphics**: Immediate sprite changes based on joystick input
5. **VBlank Synchronization**: Smooth animation through proper timing

This sprite system showcases sophisticated game programming techniques from 1981, demonstrating how developers maximized the capabilities of limited hardware through clever sprite composition and animation systems.