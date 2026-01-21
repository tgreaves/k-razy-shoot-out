# K-Razy Shoot-Out - PICO-8 Clone

A PICO-8 recreation of the classic Atari 5200 game, based on the complete disassembly and analysis.

## About

This is a faithful recreation of K-Razy Shoot-Out (originally by Dr. Keith Dreyer and Torre Meede, published by CBS Electronics) for the PICO-8 fantasy console.

The game logic, enemy AI, and mechanics are based on the detailed disassembly found in the parent directory.

## How to Play

### Controls
- **Arrow keys**: Move player
- **Z or X**: Fire weapon
- **ESC**: Pause/Menu

### Objective
- Shoot all enemies in each level
- Avoid enemy fire
- Escape through the exits when all enemies are defeated
- Survive as long as possible and rack up a high score

## Running the Game

### Option 1: PICO-8 Desktop
1. Install PICO-8 from https://www.lexaloffle.com/pico-8.php
2. Open PICO-8
3. Type: `load krazy_shootout.p8`
4. Type: `run`

### Option 2: Web Export
1. In PICO-8, load the cart
2. Type: `export krazy_shootout.html`
3. Open the generated HTML file in a web browser

### Option 3: PICO-8 Education Edition
Upload the .p8 file to https://www.pico-8-edu.com/

## Current Implementation Status

### ✅ Implemented
- Player movement and animation
- Player firing system
- Enemy spawning and AI
- Enemy firing
- Collision detection (player, enemies, missiles, walls)
- Basic arena generation
- Score tracking
- Level progression
- Lives system
- Title screen and game over screen

### 🚧 To Do
- Import actual sprite data from disassembly
- Implement proper arena generation (from $BA74 routine)
- Add explosion animations (14 frames)
- Implement exit doors that open when enemies cleared
- Add sound effects based on frequency analysis
- Add scrolling rank text on game over
- Implement difficulty progression tables
- Add HUD with proper font
- Fine-tune enemy AI patterns from disassembly
- Add enemy spawn chirrup sound

## Game Mechanics (From Disassembly)

### Variables Mapped
- `player.x, player.y` → Original $75-$76 (player position)
- `enemies[]` → Original $94-$96 (enemy slots)
- `enemies_defeated` → Original $D4 (enemies defeated counter)
- `total_enemies` → Original $D1 (total enemies for level)
- `level` → Original $D5 (level progression counter)

### Key Routines Implemented
- Player movement → Based on $A1B0 routine
- Player firing → Based on $A1D8 routine
- Enemy AI → Based on enemy movement analysis
- Collision detection → Based on $A1A0 routine
- Level completion → Based on check_sector_cleared ($A4FF)

## Differences from Original

Due to PICO-8's constraints:
- Screen resolution: 128x128 (vs original larger playfield)
- Simplified arena generation (can be enhanced)
- 16-color palette (vs original Atari 5200 palette)
- Simplified sound (4 channels vs POKEY chip)

## Credits

- **Original Game**: Dr. Keith Dreyer and Torre Meede
- **Publisher**: CBS Electronics (1981)
- **Disassembly**: Tristan Greaves
- **PICO-8 Port**: Based on complete disassembly analysis

## License

See LICENSE file in parent directory for details.
