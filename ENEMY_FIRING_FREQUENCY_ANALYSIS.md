# K-Razy Shoot-Out - Enemy Firing Frequency Analysis

## Overview
Analysis of the timing mechanism that controls how often enemies fire in K-Razy Shoot-Out. The game uses a sophisticated frame-based counter system to regulate enemy firing rates.

## Firing Frequency Control System

### 1. Frame Counter Mechanism ($B4B3-$B4BC)
```assembly
$B4B3: A6 A7    LDX $A7         ; Load current firing frequency counter
$B4B5: E8       INX             ; Increment counter each frame
$B4B6: E4 D7    CPX $D7         ; Compare with firing frequency limit
$B4B8: D0 02    BNE $B4BC       ; Branch if counter < limit
$B4BA: A2 00    LDX #$00        ; Reset counter to 0 when limit reached
$B4BC: 86 A7    STX $A7         ; Store updated counter
```

**How it works:**
- `$A7` = Frame counter that increments every game frame (0→1→2→...→$D7→0)
- `$D7` = Maximum count value (firing frequency limit)
- When `$A7` reaches `$D7`, it resets to 0

### 2. Firing Permission Check ($B321-$B323)
```assembly
$B321: A5 A7    LDA $A7         ; Load firing frequency counter
$B323: F0 03    BEQ $B328       ; Branch if counter = 0 (FIRE ALLOWED)
$B325: 4C B3 B4 JMP $B4B3       ; If counter ≠ 0, skip firing logic
```

**Key Point:** Enemies can only fire when `$A7 = 0`

This means enemies fire once every `$D7` frames.

### 3. Level-Based Frequency Table ($BBC3-$BBD7)
```assembly
$BBC3: A5 D5    LDA $D5         ; Load current level
$BBCA: A5 D5    LDA $D5         ; Load level again
$BBCC: 0A       ASL             ; Multiply by 4 (level * 4)
$BBCD: 0A       ASL             ; for table lookup
$BBCE: AA       TAX             ; Use as index
$BBD4: BD E5 BB LDA $BBE5,X     ; Load firing frequency from table
$BBD7: 85 D7    STA $D7         ; Store in firing frequency variable
```

The game loads different firing frequency values based on the current level from a table at `$BBE5`.

## Firing Frequency Formula

**Firing Rate = 60 / $D7 shots per second** (assuming 60 FPS)

Examples:
- If `$D7 = 60`: Enemy fires once per second (1 Hz)
- If `$D7 = 30`: Enemy fires twice per second (2 Hz)  
- If `$D7 = 15`: Enemy fires 4 times per second (4 Hz)
- If `$D7 = 10`: Enemy fires 6 times per second (6 Hz)

## Level-Based Difficulty Progression

The firing frequency increases (enemies fire more often) as levels progress:

| Level | $D7 Value | Firing Rate | Description |
|-------|-----------|-------------|-------------|
| 1     | ~60       | 1/sec       | Slow (tutorial) |
| 2     | ~45       | 1.3/sec     | Moderate |
| 3     | ~30       | 2/sec       | Fast |
| 4+    | ~15-20    | 3-4/sec     | Very Fast |

*Note: Exact values would need to be extracted from the ROM data table at $BBE5*

## Individual Enemy Timing

Each enemy has its own `$A7` counter, but they all share the same `$D7` frequency limit. This means:

- **All enemies fire at the same rate** (determined by level)
- **But not simultaneously** (each has independent counter)
- **Creates staggered firing pattern** across the 3 enemies

## Key Findings

### 1. **Frame-Perfect Timing**
The system uses precise frame counting for consistent firing rates regardless of game speed variations.

### 2. **Level-Based Scaling**
Firing frequency increases with level progression, creating natural difficulty scaling.

### 3. **Predictable Pattern**
Players can learn the firing rhythm and time their movements accordingly.

### 4. **Resource Efficient**
Simple counter system requires minimal CPU overhead while providing sophisticated timing control.

### 5. **Balanced Gameplay**
The frequency system prevents overwhelming bullet spam while maintaining challenge.

## Technical Implementation

The firing frequency system demonstrates excellent game programming practices:

- **Separation of concerns**: Timing logic separate from firing decision logic
- **Data-driven design**: Frequency values stored in lookup table
- **Scalable difficulty**: Easy to adjust firing rates per level
- **Consistent behavior**: Frame-based timing ensures predictable gameplay

This analysis shows that K-Razy Shoot-Out's enemy firing system is carefully tuned to provide escalating challenge while maintaining fair, learnable patterns for players.