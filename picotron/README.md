# K-Razy Shoot-Out - Picotron Edition

A faithful recreation of the Atari 5200 classic "K-Razy Shoot-Out" for Picotron.

## About This Version

This Picotron edition runs at **320x192 resolution**, matching the Atari 5200's Mode 8 display. This allows for:

- Authentic screen dimensions and proportions
- Original sprite sizes (8x12 pixels) at native resolution
- Accurate playfield layout with proper HUD
- True-to-original gameplay experience

## Screen Layout

- **Arena**: 320x160 pixels (top portion)
- **HUD**: 320x32 pixels (bottom portion)
- **Total**: 320x192 pixels (matching Atari 5200)

## Differences from PICO-8 Version

The PICO-8 version (128x128) was a proof-of-concept that compressed the game into a tiny resolution. This Picotron version:

- Uses the original Atari 5200 resolution (320x192)
- Has a larger playfield matching the original game
- Features a more detailed HUD at the bottom
- Maintains authentic sprite dimensions (8x12)
- Provides more screen real estate for complex arena layouts

## Game Mechanics

All core mechanics from the original Atari 5200 game are preserved:

- 8-direction movement and shooting
- Cannot move while firing
- Enemy AI that chases the player
- Collision detection (player/enemy, missiles, walls, explosions)
- Timer countdown with color-coded bar
- Escape mechanic through exit gaps
- Wave replay if enemies remain when escaping
- Progressive difficulty across 7 sectors
- Lives system with respawning
- Arena clearing animation

## Controls

- **Arrow Keys**: Move in 8 directions
- **Z or X**: Fire weapon (hold + direction to aim)
- **Escape**: Pause/Menu

## Development Status

**Current Status**: Fully playable! All core gameplay mechanics are implemented and working.

### Completed Features
- ✅ Full game logic ported from PICO-8 version
- ✅ 320x192 resolution with proper arena and HUD layout
- ✅ Player sprites (8x12) with animation
- ✅ Explosion sprites (8-frame animation)
- ✅ 8-direction movement and shooting
- ✅ Enemy AI with pathfinding and collision avoidance
- ✅ Missile collision detection (walls, enemies, player)
- ✅ Explosion collision (kills player and enemies)
- ✅ Timer system with countdown
- ✅ Escape mechanic through exit gaps
- ✅ Wave replay if enemies remain
- ✅ Game over when timer runs out
- ✅ Difficulty scaling across 7 sectors
- ✅ Lives system with death freeze
- ✅ Arena clearing animation
- ✅ Sound effects (weapon, explosion, spawn)
- ✅ Score tracking and HUD display

### Known Issues
- Enemy sprites (7-13) need to be created in sprite editor
- Sound effects may need tuning in Picotron's sfx editor

### Next Steps
1. Create enemy sprites in Picotron sprite editor
2. Fine-tune sound effects
3. Test all 7 sectors for difficulty balance

## Credits

- Original Game: K. Dreyer (CBS Software, 1981)
- Picotron Recreation: Based on Atari 5200 disassembly
- Platform: Picotron by Lexaloffle Games
