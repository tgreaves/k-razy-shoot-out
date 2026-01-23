# K-Razy Shoot-Out Picotron - Development Notes

## Current Status

**Game Logic Complete** - All core gameplay has been ported from PICO-8:

- ✅ Main game loop and state management
- ✅ Screen resolution set to 320x192 (matching Atari 5200)
- ✅ Modular code structure
- ✅ Player movement and firing (8-direction)
- ✅ Enemy AI (chase player, avoid walls, smart movement)
- ✅ Missile system (player and enemy)
- ✅ Collision detection (sprites, walls, missiles, explosions)
- ✅ Explosion animations
- ✅ Difficulty scaling across 7 sectors
- ✅ Escape mechanic through exits
- ✅ Arena clearing animation
- ✅ Lives system and respawning
- ✅ Timer countdown
- ✅ HUD layout
- ⏳ Sprite rendering (placeholder rectangles)
- ⏳ Sound effects (placeholder functions)
- ⏳ Picotron API integration (needs testing)

## File Structure

- `krazy_shootout.p64.lua` - Main cartridge entry point
- `main.lua` - Main game loop, state management, initialization
- `utils.lua` - Utility functions and Picotron API wrappers
- `sprites.lua` - Sprite rendering system (8x12 sprites)
- `entities.lua` - Player, enemies, missiles, explosions (complete logic)
- `arena.lua` - Arena generation with random layouts
- `collision.lua` - Collision detection functions
- `hud.lua` - HUD and timer bar rendering

## Next Steps

### 1. Picotron API Integration

The game logic is complete but needs to be connected to Picotron's actual APIs:

**In utils.lua:**
- `btn()` / `btnp()` - Connect to Picotron input system
- `print()` - Connect to Picotron text rendering
- `line()`, `rect()`, `rectfill()` - Connect to Picotron drawing functions
- `cls()` - Connect to Picotron screen clear
- `sfx()` - Connect to Picotron audio system
- `window()` - Connect to Picotron window management

**Reference:** Check Picotron documentation for:
- `get_input()` or equivalent for button states
- Drawing API functions
- Audio playback functions
- Window/display configuration

### 2. Create Sprite Assets

The sprites need to be created as Picotron userdata:

- Player sprites (7 frames: stand, left x2, right x2, up/down x2)
- Enemy sprites (7 frames: same as player)
- Explosion sprites (8 frames)
- Can be converted from PICO-8 sprite data or recreated

### 3. Sound Effects

Implement sound effects using Picotron's audio system:

- Weapon fire (sfx 0)
- Explosion (sfx 1)
- Spawn (sfx 2)

### 4. Testing

Once APIs are connected:
- Test all game mechanics
- Verify collision detection accuracy
- Tune difficulty scaling
- Test escape mechanic
- Verify arena clearing animation
- Test at 320x192 resolution

## Differences from PICO-8 Version

### Resolution
- PICO-8: 128x128
- Picotron: 320x192 (2.5x wider, 1.5x taller)

### Playfield
- PICO-8: Entire screen is playfield + minimal HUD
- Picotron: 320x160 arena + 32px HUD (matching Atari original)

### Sprites
- Both use 8x12 sprites (authentic to Atari)
- Picotron has more screen space for sprites to move

### Code Structure
- PICO-8: Single file
- Picotron: Modular files for better organization

## Atari 5200 Authenticity

This version aims to match the original as closely as possible:

- ✅ Resolution: 320x192 (Mode 8)
- ✅ Sprite size: 8x12 pixels
- ✅ Arena layout: Larger playfield with proper proportions
- ✅ HUD: Bottom section with score, sector, lives
- ⏳ Colors: Atari 5200 palette (to be implemented)
- ⏳ Sound: POKEY chip approximation (to be implemented)
- ⏳ Gameplay: All mechanics from original (in progress)

## Known Issues

- Sprites are currently placeholder rectangles (need actual sprite data)
- Sound effects are placeholder functions (need Picotron audio API)
- Input functions are placeholders (need Picotron input API)
- Drawing functions are placeholders (need Picotron draw API)
- Game logic is complete but untested in Picotron environment

## How to Run

1. Load the project in Picotron
2. Run `krazy_shootout.p64.lua`
3. The game will start at 320x192 resolution

**Note:** The game logic is complete but requires Picotron API integration to function. The placeholder functions in `utils.lua` need to be replaced with actual Picotron API calls.

## Game Logic Status

All gameplay mechanics have been ported from the PICO-8 version:

✅ **Player System:**
- 8-direction movement
- 8-direction firing
- Cannot move while firing
- Collision with walls (instant death)
- Collision with enemies (both die)
- Collision with explosions (player dies)
- Escape through exit gaps
- Animation system

✅ **Enemy System:**
- Smart AI (chase player, avoid walls)
- 8-direction movement with smooth transitions
- Prevents bouncing/jitter with close-threshold logic
- Enemy-to-enemy collision (both die)
- Enemy-explosion collision (enemy dies)
- Firing system with frequency-based timing
- 8-direction missile aiming
- Color randomization per enemy

✅ **Missile System:**
- 8-direction firing for player and enemies
- Tip-based collision detection (accurate)
- Missile-wall collision
- Missile-sprite collision
- Enemy missiles can hit other enemies

✅ **Game Flow:**
- Title screen
- Sector intro screen ("ENTERING SECTOR X")
- Main gameplay
- Death freeze (1 second)
- Arena clearing animation
- Game over screen
- Escape mechanic (progress or replay)

✅ **Difficulty Scaling:**
- 7 sectors with progressive difficulty
- Sector 1 is tutorial (no enemy firing)
- Spawn limits increase
- Firing frequency increases
- Speed scaling (sectors 6-7 are faster)

✅ **Arena System:**
- Random wall generation
- Exit gaps (left and right)
- Zone-based wall placement
- Vertical, horizontal, and L-shaped walls
- Proper spacing and collision

✅ **Timer System:**
- Countdown from 77 to 2
- Color-coded bar (green → orange → red)
- Game over when time runs out

✅ **Lives System:**
- 3 lives to start
- Respawn after death
- Progress persists across deaths
- Game over when lives reach 0
