# K-Razy Shoot-Out Picotron - Development Notes

## Current Status

**Initial Setup Complete** - The project structure is in place with:

- Main game loop and state management
- Screen resolution set to 320x192 (matching Atari 5200)
- Modular code structure
- Placeholder sprite system
- Arena generation system
- Collision detection
- HUD layout

## File Structure

- `main.lua` - Main game loop, state management, initialization
- `sprites.lua` - Sprite rendering system (8x12 sprites)
- `entities.lua` - Player, enemies, missiles, explosions
- `arena.lua` - Arena generation with random layouts
- `collision.lua` - Collision detection functions
- `hud.lua` - HUD and timer bar rendering

## Next Steps

### 1. Complete Game Logic Implementation

The following functions need to be fully implemented in `main.lua`:

- `init_game()` - Initialize a new game/sector
- `update_game()` - Main game update loop
- `update_death_freeze()` - Handle death freeze state
- Player update logic
- Enemy update logic
- Missile update logic
- Explosion update logic

### 2. Port PICO-8 Game Logic

Most of the game logic can be ported directly from the PICO-8 version:

- Player movement (8-direction)
- Player firing (8-direction, cannot move while firing)
- Enemy AI (chase player, avoid walls)
- Enemy firing system
- Difficulty scaling
- Escape mechanic
- Arena clearing animation

### 3. Create Sprite Assets

The sprites need to be created as Picotron userdata:

- Player sprites (7 frames: stand, left x2, right x2, up/down x2)
- Enemy sprites (7 frames: same as player)
- Explosion sprites (8 frames)
- Convert from PICO-8 sprite data or recreate

### 4. Sound Effects

Implement sound effects using Picotron's audio system:

- Weapon fire (sfx 0)
- Explosion (sfx 1)
- Spawn (sfx 2)

### 5. Testing and Polish

- Test all game mechanics
- Verify collision detection accuracy
- Tune difficulty scaling
- Test escape mechanic
- Verify arena clearing animation

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

- Sprites are currently placeholder rectangles
- Sound effects not yet implemented
- Game logic needs to be completed
- No sprite sheet loaded yet

## How to Run

1. Load the project in Picotron
2. Run `main.lua`
3. The game will start at 320x192 resolution

Currently, only the title screen and basic structure are functional. Game logic is being ported from the PICO-8 version.
