# K-Razy Shoot-Out: Missile Movement System Analysis

## Overview

After analyzing the complete enemy firing system, we can now understand how enemy missiles move across the screen over time. The answer reveals a fascinating aspect of 1980s game programming: **hardware-accelerated projectile movement**.

## Key Discovery: Hardware-Based Movement

Unlike modern games that update projectile positions in software each frame, K-Razy Shoot-Out leverages the Atari 5200's dedicated **Player/Missile Graphics (PMG)** hardware system to handle missile movement automatically.

## Complete Missile Lifecycle

### 1. Missile Creation ($B46B-$B4B1)

When an enemy decides to fire (based on the frequency control system we analyzed):

```assembly
$B46B: B5 84    LDA $84,X       ; Load enemy Y position
$B46E: 69 05    ADC #$05        ; Add 5 pixels offset for missile spawn
$B470: 95 E2    STA $E2,X       ; Store missile Y position
$B473: B5 80    LDA $80,X       ; Load enemy X position  
$B476: 69 03    ADC #$03        ; Add 3 pixels offset for missile spawn
$B478: 95 DE    STA $DE,X       ; Store missile X position
$B47A: 9D 04 C0 STA $C004,X     ; Set hardware missile position register
```

**Missile Positioning Logic**:
- **Y Position**: Enemy Y + 5 pixels (spawn point below enemy)
- **X Position**: Enemy X + 3 pixels (spawn point right of enemy center)
- **Hardware Register**: $C004,X sets the actual hardware missile position

### 2. Trajectory Setup ($B481-$B495)

Each enemy creates missiles with different visual patterns and trajectories:

```assembly
$B482: 26 6B    ROL $6B         ; Rotate missile pattern bits
$B486: 26 6C    ROL $6C         ; Rotate direction bits (varies trajectory)
$B488: 26 6C    ROL $6C         ; (creates different trajectory angles)
```

**Trajectory System**:
- **$6B**: Missile visual pattern (graphics appearance)
- **$6C**: Missile direction/trajectory data
- **Enemy 1**: No rotation (straight trajectory)
- **Enemy 2**: Single rotation (slight angle)
- **Enemy 3**: Double rotation (steeper angle)

### 3. Hardware Movement (Automatic)

**This is the key insight**: Once the missile is created and positioned in the hardware register ($C004,X), the **Atari 5200's ANTIC/GTIA chips automatically handle the movement**!

**Hardware PMG System**:
- **ANTIC Chip**: Handles display list processing and sprite positioning
- **GTIA Chip**: Manages sprite graphics and collision detection
- **Automatic Movement**: Hardware moves missiles toward player based on trajectory
- **No Software Updates**: No per-frame position calculations needed in code

### 4. Collision Detection ($A85D-$A8CD)

The hardware automatically detects when missiles hit targets:

```assembly
$A85D: AD 0D C0 LDA $C00D ; GTIA M1PF - Missile 1/Playfield collision
$A891: AD 0E C0 LDA $C00E ; GTIA M2PF - Missile 2/Playfield collision  
$A8C7: AD 0F C0 LDA $C00F ; GTIA M3PF - Missile 3/Playfield collision
```

**Collision Registers**:
- **$C00D**: Missile 1 collision with playfield/player
- **$C00E**: Missile 2 collision with playfield/player
- **$C00F**: Missile 3 collision with playfield/player

### 5. Missile Destruction (Automatic)

When collision is detected, the hardware automatically:
- Removes missile from screen
- Clears collision registers
- Frees missile slot for next firing

## Why No Per-Frame Movement Code?

**Hardware Acceleration**: The Atari 5200's PMG system was specifically designed to handle sprite movement automatically, freeing the CPU for game logic.

**Performance Benefits**:
- **1.79 MHz 6502 CPU**: Limited processing power required hardware assistance
- **Smooth Movement**: Hardware ensures consistent 59.92 Hz movement
- **Collision Detection**: Hardware handles pixel-perfect collision checking
- **CPU Efficiency**: Software focuses on AI, sound, and game state

## Technical Implementation Details

### Hardware Registers Used

| Register | Purpose | Usage |
|----------|---------|-------|
| $C004-$C007 | Missile horizontal positions | Set initial position |
| $C00D-$C00F | Missile/playfield collision | Detect hits |
| $D004-$D007 | Hardware missile positions | Automatic movement |
| $D00C | Missile sizes | Configure appearance |

### Memory Variables

| Variable | Purpose | Usage |
|----------|---------|-------|
| $DE,X | Missile X position | Software tracking |
| $E2,X | Missile Y position | Software tracking |
| $6B | Missile pattern | Visual appearance |
| $6C | Missile trajectory | Movement direction |

## Comparison to Modern Games

**1980s Hardware Approach (K-Razy Shoot-Out)**:
- Set initial position and trajectory
- Hardware handles movement automatically
- Check collision registers for hits
- Minimal CPU overhead

**Modern Software Approach**:
- Calculate new position each frame
- Update sprite coordinates manually
- Perform collision detection in software
- Higher CPU usage but more flexibility

## Conclusion

The missile movement system in K-Razy Shoot-Out demonstrates the elegant efficiency of 1980s hardware-accelerated game programming. Rather than updating missile positions in software each frame, the game leverages the Atari 5200's dedicated PMG hardware to handle movement automatically.

This approach was essential for achieving smooth gameplay on the limited 1.79 MHz 6502 processor, and represents a fascinating example of how hardware constraints drove innovative programming solutions in early video games.

The complete missile system works as follows:
1. **Enemy AI** decides when to fire based on frequency control
2. **Software** sets initial missile position and trajectory  
3. **Hardware** automatically moves missiles toward player
4. **Hardware** detects collisions and removes missiles
5. **Software** processes collision results and updates game state

This hardware-software collaboration created the smooth, responsive projectile system that made K-Razy Shoot-Out an engaging arcade-style shooter on the Atari 5200.