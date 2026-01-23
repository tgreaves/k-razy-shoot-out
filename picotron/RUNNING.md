# How to Run K-Razy Shoot-Out in Picotron

## Quick Start

1. **Open Picotron** from your Applications directory

2. **Navigate to the project folder:**
   - In Picotron, open the file navigator
   - Navigate to where you cloned this repository
   - Go into the `picotron` folder

3. **Load the cartridge:**
   - Type in the terminal: `load krazy_shootout.p64`
   - Or double-click the `krazy_shootout.p64` folder in the file navigator

4. **Run the game:**
   - Press `CTRL-R` to run
   - Or type `run` in the terminal

**Alternative:** Run from your Mac terminal with `./picotron/run.sh`

## Controls

- **Arrow Keys**: Move in 8 directions
- **Z or X**: Fire weapon (hold + direction to aim)
- **ESCAPE**: Return to desktop/terminal
- **CTRL-R**: Restart game

## Current Status

The game is **fully playable** in Picotron!

- ✅ **Player sprites working** - 8x12 sprites with animation (standing, left, right, up/down)
- ✅ **Explosion sprites working** - 8-frame explosion animation
- ⚠️ **Enemy sprites missing** - Need to be created in sprite editor (sprites 7-13)
- ✅ **Sound effects working** - Weapon fire (sfx 0), explosions (sfx 1), spawns (sfx 2)
- ✅ **All gameplay mechanics implemented** - Movement, firing, enemies, collisions, escape, timer, etc.

## What Works

✅ All game mechanics from the PICO-8 version
✅ 320x192 resolution (matching Atari 5200)
✅ Proper HUD layout at bottom
✅ Arena generation with random layouts
✅ Player sprites with animation
✅ Explosion animation (8 frames)
✅ Player and enemy AI
✅ Collision detection (walls, missiles, explosions)
✅ Escape mechanic through exit gaps
✅ Wave replay if enemies remain when escaping
✅ Game over when timer runs out
✅ Difficulty scaling across 7 sectors
✅ Lives system with death freeze
✅ Timer countdown with color bar
✅ Sound effects (weapon, explosion, spawn)
✅ Score tracking and HUD display

## Next Steps to Complete

1. **Create enemy sprites** - Need sprites 7-13 in Picotron's sprite editor (same as player: stand, left x2, right x2, up/down x2)
2. **Fine-tune sound effects** - Adjust sfx 0, 1, 2 in Picotron's sound editor if needed
3. **Test and polish** - Play through all 7 sectors for balance

## Troubleshooting

If you get errors about missing functions:
- Make sure you're running in Picotron (not PICO-8)
- Check that all .lua files are in the same folder
- Try running from the terminal with: `cd picotron` then `load krazy_shootout.p64`

If the game runs but enemies are invisible:
- Enemy sprites (7-13) haven't been created yet
- They still work for collision detection, just not visible
- You can still play and test the game mechanics

## Creating Enemy Sprites

Enemy sprites (7-13) still need to be created. To add them:

1. In Picotron, load the cartridge: `load krazy_shootout.p64`
2. Open the sprite editor: press `CTRL-G` or type `gfx`
3. Create 8x12 pixel sprites for enemies (similar to player):
   - Sprite 7: Enemy standing
   - Sprites 8-9: Enemy walking left (2 frames)
   - Sprites 10-11: Enemy walking right (2 frames)
   - Sprites 12-13: Enemy walking up/down (2 frames)
4. Save the cartridge: `save`
5. Run to test: `run`

The sprites should match the player style but use different colors (enemies are drawn with random colors).

## Picotron API Compatibility

This game uses Picotron's native functions which are compatible with PICO-8:
- `btn()`, `btnp()` - Input
- `spr()`, `rectfill()`, `line()`, `print()`, `cls()` - Drawing
- `sfx()` - Audio
- `window()` - Display setup

All these functions work exactly as documented in the Picotron manual!
