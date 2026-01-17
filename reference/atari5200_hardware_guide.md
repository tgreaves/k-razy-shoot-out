# Atari 5200 Hardware Reference Guide

## System Overview

The Atari 5200 SuperSystem (1982) was Atari's attempt to create a more powerful home console. It's essentially a simplified Atari 400/800 computer in console form.

### Core Components

- **CPU**: MOS 6502C running at 1.79 MHz
- **RAM**: 16KB system RAM
- **ROM**: 2KB OS ROM + cartridge space
- **Custom Chips**: ANTIC, GTIA, POKEY (same as Atari 8-bit computers)

## Memory Map

```
$0000-$00FF   Zero Page (256 bytes)
              - Fast access variables and pointers
              - Stack pointer, processor flags
              
$0100-$01FF   Stack (256 bytes)  
              - 6502 hardware stack
              - Subroutine return addresses, saved registers
              
$0200-$3FFF   Main RAM (14KB)
              - Program variables, buffers
              - Screen memory (typically $3000-$3FFF)
              - Display lists, character sets
              
$4000-$7FFF   Unused/Expansion
              - Not used in standard 5200
              
$8000-$9FFF   OS ROM (8KB)
              - Atari 5200 BIOS routines
              - Interrupt handlers, I/O routines
              
$A000-$BFFF   Cartridge ROM (8KB standard)
              - Game code and data
              - Can be larger with bank switching
              
$C000-$CFFF   GTIA Registers
              - Graphics and color control
              
$D000-$D0FF   ANTIC Registers  
              - Display list processor
              
$D200-$D2FF   POKEY Registers
              - Sound, input, timers
              
$D300-$D3FF   PIA (Peripheral Interface)
              - Controller inputs
              
$E000-$FFFF   OS ROM continued
              - More BIOS routines
              - Interrupt vectors at $FFFA-$FFFF
```

## Custom Chips Explained

### ANTIC (Alpha-Numeric Television Interface Controller)

ANTIC is the display processor that generates video timing and fetches screen data.

**Key Registers:**
- `$D000 DMACTL` - DMA Control (enables screen DMA)
- `$D002-$D003 DLISTL/H` - Display List pointer
- `$D004 HSCROL` - Horizontal fine scroll
- `$D005 VSCROL` - Vertical fine scroll
- `$D00A WSYNC` - Wait for horizontal sync
- `$D40E NMIEN` - NMI Enable (VBlank, Display List Interrupts)

**Display Lists:**
ANTIC uses "display lists" - small programs that tell it how to draw each screen line:
```assembly
; Example display list for text mode
display_list:
    .byte $70,$70,$70        ; 3 blank lines  
    .byte $42,$00,$30        ; Mode 2 + LMS, point to $3000
    .byte $02,$02,$02        ; 3 more Mode 2 lines
    .byte $41,$00,$A0        ; Jump to $A000 (repeat)
```

### GTIA (George's Television Interface Adaptor)

GTIA handles colors, sprites (players/missiles), and collision detection.

**Color Registers:**
- `$C000-$C003 COLPM0-3` - Player colors
- `$C004-$C007 COLPF0-3` - Playfield colors  
- `$C008 COLBK` - Background color
- `$C009 PRIOR` - Priority control

**Sprite Registers:**
- `$D000-$D003 HPOSP0-3` - Player horizontal positions
- `$D004-$D007 HPOSM0-3` - Missile horizontal positions
- `$D008-$D00B SIZEP0-3` - Player sizes
- `$D00C SIZEM` - Missile sizes

### POKEY (Pot Keyboard Integrated Circuit)

POKEY handles sound, keyboard, joysticks, and timers.

**Input Registers:**
- `$D200-$D207 POT0-7` - Paddle/joystick readings
- `$D208 ALLPOT` - Paddle trigger status
- `$D209 KBCODE` - Keyboard scan code
- `$D20A RANDOM` - Random number generator

**Sound Registers:**
- `$D200,$D202,$D204,$D206 AUDF1-4` - Audio frequencies
- `$D201,$D203,$D205,$D207 AUDC1-4` - Audio control/volume

**Control Registers:**
- `$D20E IRQEN` - IRQ enable mask
- `$D20F SKCTL` - Serial/keyboard control

## Graphics Modes

The Atari 5200 supports multiple graphics modes:

### Text Modes
- **Mode 2**: 40x24 characters, 5 colors
- **Mode 3**: 40x24 characters, 4 colors  
- **Mode 4**: 40x12 characters, 5 colors
- **Mode 5**: 40x12 characters, 4 colors

### Bitmap Modes  
- **Mode 8**: 320x192, 4 colors
- **Mode 9**: 80x192, 16 colors
- **Mode 10**: 80x192, 9 colors
- **Mode 11**: 80x192, 16 colors

### Player/Missile Graphics
- 4 players (sprites) + 4 missiles
- Hardware collision detection
- Sizes: normal, double, quad width
- Can be combined for larger sprites

## Sound System

POKEY provides 4 audio channels with:
- Frequency control (pitch)
- Volume control (0-15)
- Distortion types (noise, pure tone, etc.)
- High-pass filters
- Can link channels for 16-bit frequency resolution

## Controller Input

The Atari 5200 uses analog joysticks with:
- Analog X/Y position (read via POT registers)
- Numeric keypad (0-9, *, #)  
- Start, Pause, Reset buttons
- Fire buttons (up to 2 per controller)

## Programming Tips

### Initialization Sequence
1. Clear RAM and zero page
2. Set up display list
3. Initialize color registers
4. Enable interrupts (VBlank for timing)
5. Set up sound channels
6. Initialize game variables

### VBlank Interrupt
Most games use VBlank (vertical blank) interrupt for timing:
- Occurs 60 times per second (NTSC)
- Good for updating sprites, sound, input
- Ensures smooth animation

### Memory Management
- Use zero page for frequently accessed variables
- Screen memory typically at $3000-$3FFF
- Character sets can be in RAM or ROM
- Display lists are small (usually < 100 bytes)

This hardware reference should help understand what the disassembled code is doing!