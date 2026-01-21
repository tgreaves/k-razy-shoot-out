# Development Notes

## Mapping from Disassembly to PICO-8

### Memory Locations → Lua Variables

| Original | PICO-8 | Description |
|----------|--------|-------------|
| $75-$76 | player.x, player.y | Player position |
| $79-$7A | (sprite data pointer) | Handled by sprite system |
| $94-$96 | enemies[].state | Enemy slot states (0=empty, 1=defeated) |
| $D1 | total_enemies | Total enemies for current level |
| $D4 | enemies_defeated | Number of enemies defeated |
| $D5 | level | Level progression counter |
| $DA | lives | Death counter (lives remaining) |

### Key Routines to Port

#### Player Movement ($A1B0)
- ✅ Basic movement implemented
- 🚧 Need to add proper collision with arena walls
- 🚧 Need to add exit detection

#### Player Firing ($A1D8)
- ✅ Basic firing implemented
- 🚧 Need to add missile limit (1 at a time)
- 🚧 Need to add proper missile collision

#### Enemy AI (Multiple routines)
- ✅ Basic AI implemented (move toward player)
- 🚧 Need to add proper movement patterns from disassembly
- 🚧 Need to add firing frequency based on difficulty

#### Collision Detection ($A1A0)
- ✅ Basic collision implemented
- 🚧 Need to refine hitboxes to match original

#### Arena Generation ($BA74)
- 🚧 Currently random - need to implement procedural generation
- 🚧 Need to add exit doors
- 🚧 Need to add proper wall patterns

#### Level Completion ($A4FF - check_sector_cleared)
- ✅ Basic implementation
- 🚧 Need to add exit door opening logic
- 🚧 Need to add proper level progression

### Sprite Data Conversion

From disassembly:
- Character set: $A000-$A2C7 (89 characters, 8x8 each)
- Player sprites: $BE20-$BED3 (13 sprites, 8x12 each)
- Explosion sprites: $BED4-$BF7B (14 frames, 8x12 each)
- Enemy sprites: $BF80+ (6 definitions)

PICO-8 sprite sheet allocation:
- Sprites 1-13: Player animations
- Sprites 14-15: Enemy sprites
- Sprites 16-29: Explosion frames
- Sprites 32-127: Font/HUD characters
- Sprites 128-255: Arena tiles

### Sound Effects

From sound analysis files:

#### Weapon Fire
- Frequency: ~440Hz
- Duration: ~0.1s
- Waveform: Square wave
- PICO-8: `sfx(0)` - short pulse

#### Enemy Spawn Chirrup
- Frequency: Rising from 200Hz to 800Hz
- Duration: ~0.2s
- PICO-8: `sfx(1)` - rising chirp

#### Explosion
- Frequency: Descending noise
- Duration: ~0.5s
- PICO-8: `sfx(2)` - noise burst

#### Death Music
- 4-note sequence from analysis
- PICO-8: `music(0)` - custom sequence

### Difficulty Progression

From disassembly difficulty tables:
- Enemy speed increases with level
- Enemy firing frequency increases
- Number of enemies increases
- Arena complexity increases

Need to implement tables from $BA74 routine.

### Token Budget

PICO-8 limit: 8192 tokens
Current estimate: ~1500 tokens
Remaining: ~6700 tokens (plenty of room!)

### Next Steps

1. **Import sprite data**
   - Convert PNG spritesheets to PICO-8 format
   - Use sprite editor to import

2. **Enhance arena generation**
   - Port procedural generation from $BA74
   - Add exit doors
   - Add proper wall patterns

3. **Refine enemy AI**
   - Implement movement patterns from disassembly
   - Add firing frequency tables
   - Add spawn timing

4. **Add explosion animations**
   - Import 14-frame explosion sequence
   - Add animation system

5. **Implement sound effects**
   - Create SFX based on frequency analysis
   - Add music for death sequence

6. **Add scrolling rank text**
   - Port display_rank routine ($A48C)
   - Implement horizontal scrolling

7. **Polish and tune**
   - Match original game feel
   - Balance difficulty
   - Add visual effects


## Sprite Implementation (8x12 Format)

**Approach**: Using 8x12 sprites from the original Atari 5200 game, rendered with PICO-8's scaling feature.

**Implementation**:
- Sprites stored with full 12 rows of pixel data in the sprite sheet
- Each sprite takes 12 rows vertically in the sprite sheet
- Rendered using `spr(n,x,y,1,1.5)` to scale 8-pixel width to 12-pixel height
- Player sprites (0-6): White (color 7)
- Enemy sprites (7-13): Red (color 8)  
- Explosion sprites (14-27): Orange (color 9)

**Known Good Sprites**:
- Player and enemy sprites are working correctly with this approach
- All 7 player animation frames render properly
- All 7 enemy animation frames render properly

**Explosion Sprites**:
- 14 frames of explosion animation from original game
- Currently may have rendering issues - needs investigation
- Sprite data is correct from disassembly (lines 6611-6813)

**Files**:
- `generate_working_spritesheet.py` - Generates the sprite sheet with 8x12 sprites
- Uses full 12-byte sprite data from original game
