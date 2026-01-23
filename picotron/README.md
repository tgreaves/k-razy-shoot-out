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

This is a work in progress. The game logic is being ported from the PICO-8 version with enhancements for the larger resolution.

## Credits

- Original Game: K. Dreyer (CBS Software, 1981)
- Picotron Recreation: Based on Atari 5200 disassembly
- Platform: Picotron by Lexaloffle Games
