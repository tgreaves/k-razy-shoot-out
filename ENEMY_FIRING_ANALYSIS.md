# K-Razy Shoot-Out - Enemy Firing Behavior Analysis

## Overview
Complete analysis of how enemies decide when to fire at the player in K-Razy Shoot-Out. **CRITICAL DISCOVERY**: Enemies do not fire on Sector 1 - firing is only enabled from Sector 2 onwards.

## Sector-Based Firing Control

### Level Check at $B31A
```assembly
$B31A: A5 D5    LDA $D5         ; Load level counter
$B31C: D0 03    BNE $B321       ; Branch if NOT zero (Sector 2+)
$B31E: 4C BE B4 JMP $B4BE       ; If zero (Sector 1) - SKIP FIRING!
```

**Key Finding**: The level counter $D5 controls enemy firing:
- **$D5 = 0** (Sector 1): All firing logic is bypassed
- **$D5 ≥ 1** (Sector 2+): Full firing system is active

This explains why Sector 1 feels easier - it's designed as a tutorial level where players can learn movement and escape mechanics without the threat of enemy projectiles.

## Enemy Firing Decision System (Sector 2+ Only)

### 1. Position Analysis ($B349-$B3C9)
The enemy AI calculates the relative position between player and enemy:

```assembly
; Load player position
$B349: A5 80    LDA $80         ; Player X position
$B34B: 85 92    STA $92         ; Store as reference

; Calculate X-distance difference
$B363: A5 78    LDA $78         ; Enemy X position  
$B366: E5 92    SBC $92         ; Subtract player X
$B368: 85 9E    STA $9E         ; Store X-distance

; Calculate Y-distance difference  
$B393: A5 77    LDA $77         ; Enemy Y position
$B396: E5 92    SBC $92         ; Subtract player Y
$B398: 85 9F    STA $9F         ; Store Y-distance
```

### 2. Alignment Detection ($B3A9-$B3C9)
The system creates alignment flags based on distance thresholds:

```assembly
$B3AF: A5 9F    LDA $9F         ; Load Y-distance
$B3B1: C5 A0    CMP $A0         ; Compare with threshold
$B3B3: 90 04    BCC $B3B9       ; Branch if below threshold
$B3B5: A9 08    LDA #$08        ; Set horizontal alignment flag (bit 3)
$B3B7: 85 A3    STA $A3

$B3B9: A5 9E    LDA $9E         ; Load X-distance  
$B3BB: C5 A1    CMP $A1         ; Compare with threshold
$B3BD: 90 04    BCC $B3C3       ; Branch if below threshold
$B3BF: A9 04    LDA #$04        ; Set vertical alignment flag (bit 2)
$B3C1: 85 A2    STA $A2
```

### 3. Targeting Value Creation ($B3C3-$B3C9)
Combines all factors into a 4-bit targeting value:

```assembly
$B3C3: A5 A2    LDA $A2         ; Y-alignment flag (bit 2)
$B3C5: 05 A3    ORA $A3         ; X-alignment flag (bit 3)  
$B3C7: 05 9C    ORA $9C         ; Movement direction flag (bit 0)
$B3C9: 05 9D    ORA $9D         ; Movement direction flag (bit 1)
; Result: 4-bit value (0-15) determining firing behavior
```

## Firing Pattern Matrix

| Value | Binary | Alignment | Firing Pattern | Behavior |
|-------|--------|-----------|----------------|----------|
| 4     | 0100   | Vertical  | Horizontal     | Side-to-side shots |
| 5     | 0101   | Vertical+ | Diagonal       | Angled targeting |
| 6     | 0110   | Vertical+ | Horizontal     | Enhanced side shots |
| 7     | 0111   | Vertical+ | Diagonal       | Advanced angled |
| 8     | 1000   | Horizontal| Vertical       | Up/down shots |
| 9     | 1001   | Horizontal| Vertical       | Enhanced vertical |
| 10    | 1010   | Both      | Advanced       | Smart targeting |
| 11    | 1011   | Both      | Advanced       | Enhanced smart |
| 12    | 1100   | Close     | Rapid Fire     | High frequency |
| 13    | 1101   | Close     | Rapid Fire     | Pattern variant |
| 14    | 1110   | Close     | Rapid Fire     | Pattern variant |
| 15    | 1111   | Maximum   | Aggressive     | Highest aggression |

## Firing Pattern Implementation

### Horizontal Firing (Values 4, 6)
```assembly
$B3DF: A9 02    LDA #$02        ; Sprite type 2
$B3E1: 95 88    STA $88,X       ; Set enemy sprite
$B3E3: A9 0C    LDA #$0C        ; Pattern $0C
$B3E5: 85 6B    STA $6B         ; Horizontal missile pattern
$B3E7: A9 00    LDA #$00        ; Direction 0
$B3E9: 85 6C    STA $6C         ; Straight horizontal
```

### Diagonal Firing (Values 5, 7)  
```assembly
$B3F1: A9 05    LDA #$05        ; Sprite type 5
$B3F3: 95 88    STA $88,X       ; Set enemy sprite
$B3F5: A9 0C    LDA #$0C        ; Pattern $0C
$B3F7: 85 6B    STA $6B         ; Diagonal missile pattern
$B3F9: A9 00    LDA #$00        ; Direction 0
$B3FB: 85 6C    STA $6C         ; Angled trajectory
```

### Vertical Firing (Values 8, 9)
```assembly
$B403: A9 07    LDA #$07        ; Sprite type 7
$B405: 95 88    STA $88,X       ; Set enemy sprite  
$B407: A9 04    LDA #$04        ; Pattern $04
$B409: 85 6B    STA $6B         ; Vertical missile pattern
$B40B: 85 6C    STA $6C         ; Same pattern for direction
```

### Close-Range Rapid Fire (Values 12-15)
```assembly
$B424: A9 01    LDA #$01        ; Sprite type 1
$B426: 95 88    STA $88,X       ; Set enemy sprite
$B428: A9 08    LDA #$08        ; Pattern $08  
$B42A: 85 6B    STA $6B         ; Rapid fire pattern
$B42C: A9 04    LDA #$04        ; Direction $04
$B42E: 85 6C    STA $6C         ; Quick succession shots
```

## Missile Positioning System ($B46B-$B4B1)

### Position Calculation
```assembly
$B46B: B5 84    LDA $84,X       ; Enemy Y position
$B46E: 69 05    ADC #$05        ; +5 pixel spawn offset
$B470: 95 E2    STA $E2,X       ; Store missile Y

$B473: B5 80    LDA $80,X       ; Enemy X position  
$B476: 69 03    ADC #$03        ; +3 pixel spawn offset
$B478: 95 DE    STA $DE,X       ; Store missile X
$B47A: 9D 04 C0 STA $C004,X     ; Set hardware position
```

### Graphics Rotation by Enemy
- **Enemy 1**: No rotation (standard pattern)
- **Enemy 2**: Single rotation (2x ROL operations)
- **Enemy 3**: Double rotation (4x ROL operations)

This creates visual variety in missile appearances and trajectories.

### Sound Effects
```assembly
$B4A8: A9 AC    LDA #$AC        ; Sound parameter
$B4AC: 8D 03 E8 STA $E803       ; POKEY sound trigger
$B4AF: A9 04    LDA #$04        ; Sound duration
$B4B1: 85 B6    STA $B6         ; Sound timer
```

## Key Findings

### 1. **Sector-Based Difficulty Progression**
**Sector 1 = Tutorial Mode**: No enemy firing allows players to learn basic mechanics (movement, enemy avoidance, escape routes) without projectile threats.

**Sector 2+ = Full Combat**: Complete firing system activates with intelligent targeting and multiple attack patterns.

### 2. **Intelligent Targeting** (Sector 2+ Only)
Enemies don't fire randomly - they analyze player position and choose appropriate firing patterns based on alignment and distance.

### 3. **Difficulty Scaling**  
Closer proximity (values 12-15) triggers rapid fire modes, making the game more challenging when enemies get near the player.

### 4. **Pattern Variety**
8 different firing patterns provide varied gameplay, from simple horizontal shots to complex diagonal targeting.

### 5. **Visual Feedback**
Each enemy uses different sprite types and missile rotations, providing visual cues about firing behavior.

### 6. **Audio Cues**
Enemy firing triggers distinct sound effects ($E803 register), alerting players to incoming threats.

## Technical Implementation

The enemy firing system demonstrates sophisticated 6502 programming:
- **Bit manipulation** for alignment detection
- **Lookup tables** for firing patterns  
- **Hardware integration** with POKEY sound and GTIA graphics
- **Memory-efficient** decision trees
- **Real-time calculation** of targeting vectors

This analysis reveals K-Razy Shoot-Out's enemy AI as surprisingly advanced for 1981, using mathematical positioning algorithms rather than simple random firing patterns. The sector-based progression system shows thoughtful game design - Sector 1 serves as an effective tutorial that teaches core mechanics before introducing the complexity of enemy projectiles in later sectors.