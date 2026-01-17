# Player Missile Control: Fire Button Input Processing - UNRESOLVED

## The Original Question

What stops the player from firing again when they have a projectile already on screen?

## Critical Discovery: Missing Fire Button Input Code

After extensive analysis of the K-Razy Shoot-Out disassembly, **the actual fire button input processing has not been located**. This represents a significant gap in understanding the complete player missile system.

## What We Expected to Find vs What We Found

### Expected Fire Button Processing:
```assembly
; Expected pattern:
LDA TRIG0_REGISTER    ; Read fire button (TRIG0 on Atari 5200)
BNE no_fire          ; Branch if button not pressed
LDA missile_status   ; Check if missile already active
BNE no_fire          ; Branch if missile already exists
; Create new missile:
LDA joystick_x       ; Sample joystick direction
STA missile_direction
LDA player_position
STA $C004           ; Set Missile 0 position
```

### What We Actually Found:
1. **Input routine at $AFAD**: Appears to be initialization/setup, not input processing
2. **Collision detection at $A8F6-$A930**: Processes missile hits AFTER firing
3. **Code at $A932**: Reads $C008 collision register, labeled as "fire button check" but appears to be collision-related
4. **No POKEY register reads**: No clear reads of $D200-$D207 (joystick) or TRIG0 (fire button)

## Analysis of Available Evidence

### 1. Hardware Missile System Confirmed

**Evidence from collision detection code**:
- $C008 register used for player missile/enemy collision detection
- $C00C register (M0PF) indicates Missile 0/Playfield collision
- Missile 0 appears to be reserved for player use
- Hardware PMG system handles missile movement automatically

### 2. Single Missile Limitation Confirmed

**Evidence from collision processing**:
- Only one set of collision bits checked for player missile
- Enemy defeat processing assumes single player missile
- No multiple missile state management found

### 3. The Missing Input Processing

**What should exist but hasn't been found**:
```assembly
; Fire button input processing (MISSING):
check_fire_button:
    LDA TRIG0_REGISTER    ; Read Atari 5200 fire button
    BNE no_fire           ; Branch if not pressed
    
check_missile_available:
    LDA missile_0_status  ; Check if Missile 0 is active
    BNE no_fire           ; Branch if missile already exists
    
create_missile:
    LDA joystick_x        ; Sample joystick X position
    STA missile_x_dir     ; Store X direction
    LDA joystick_y        ; Sample joystick Y position  
    STA missile_y_dir     ; Store Y direction
    LDA player_x_pos      ; Get player position
    STA $C004             ; Set Missile 0 X position
    ; Enable missile graphics and collision
```

### 4. Possible Explanations for Missing Code

**Theory 1: Interrupt-Based Processing**
- Fire button processing might be in VBI (Vertical Blank Interrupt) routine
- Input sampling could be integrated into the main game loop differently

**Theory 2: Unusual Input Method**
- Game might use collision detection as input method (unusual but possible)
- Fire button might be mapped to collision register somehow

**Theory 3: Code Location Not Yet Found**
- Fire button processing exists but is in a routine not yet analyzed
- Could be integrated into a different system routine

**Theory 4: Hardware-Only Implementation**
- Atari 5200 hardware might handle some input processing automatically
- Software might only need to check results, not process input directly

## Current Understanding: What Prevents Multiple Missiles

Based on the available evidence, the most likely mechanism is:

### Hardware-Based Limitation
**Atari 5200 PMG System**:
- Only 4 missile objects available total (Missiles 0-3)
- Missiles 1-3 used by enemies (one per enemy slot)
- **Missile 0 reserved for player use**
- Hardware can only track one missile per slot

### Probable Prevention Mechanism
```
1. Player presses fire button (processing location unknown)
2. Game checks if Missile 0 is already active (method unknown)
3. If Missile 0 is free:
   - Sample joystick direction (code not found)
   - Create missile with trajectory (code not found)
   - Set Missile 0 hardware registers (code not found)
4. If Missile 0 is busy:
   - Ignore fire button press
   - No new missile created
```

### Automatic Cleanup
**Hardware handles missile lifecycle**:
- When missile hits target: Hardware clears missile automatically
- When missile leaves screen: Hardware clears missile automatically
- Missile 0 slot becomes available for next shot

## Conclusion: Partial Understanding

**What we know**:
1. **Single missile limitation exists** - only one player missile at a time
2. **Hardware PMG system** manages missile state automatically
3. **Missile 0** is used for player missiles
4. **Collision detection works** - hits are properly processed

**Critical gap**:
**The actual fire button input processing that creates missiles and prevents multiple firing has not been located** despite extensive analysis.

**Next steps needed**:
1. **Find fire button input routine** - locate TRIG0 register reads
2. **Find missile creation code** - locate $C004 register setup
3. **Find missile availability check** - locate code that prevents multiple missiles
4. **Find joystick sampling** - locate POKEY register reads for direction

This represents a significant mystery in the game's input system that requires further investigation to fully understand the complete player firing mechanism.