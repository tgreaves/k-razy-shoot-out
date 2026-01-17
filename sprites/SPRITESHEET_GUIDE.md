# K-Razy Shoot-Out Spritesheets Guide

This directory contains generated spritesheets based on the annotated sprite data from the ROM analysis starting at $BE20.

## Generated Files

### 1. `player_spritesheet.png`
**All Player Sprites** - Complete collection of all 15 player sprites (8×12 pixels each)
- **Movement Sprites**: Stationary + Walking Left/Right/Up/Down (2 frames each) = 7 sprites
- **Shooting Sprites**: All 8 directional shooting poses = 8 sprites
  - Shooting Left, Top Left, Bottom Left
  - Shooting Right, Top Right, Bottom Right  
  - Shooting Up, Shooting Down
- **Layout**: 5 columns × 3 rows for easy reference
- **Total**: 15 player sprites on one comprehensive sheet

### 2. `enemy_spritesheet.png`
**Enemy Sprites** - All 7 enemy animation states (8×12 pixels each)
- **Stationary**: Enemy at rest
- **Walking Left 1/2**: Two-frame walking animation for leftward movement
- **Walking Right 1/2**: Two-frame walking animation for rightward movement
- **Walking Up/Down 1/2**: Two-frame walking animation for vertical movement

### 4. `explosion_spritesheet.png`
**Explosion Animation Sprites** - Complete 14-frame explosion sequence (8×12 pixels each)
- **Frames 1-14**: Progressive explosion animation from start to finish
**Enemy Sprite** - Single enemy character
- **Enemy**: The enemy sprite referenced as character $1C in the code

### 4. `explosion_spritesheet.png`
**Explosion Animation Sprites** - Five-frame explosion sequence
- **Frame 1-5**: Progressive explosion animation frames

### 4. `animation_guide.png`
**Animation Reference** - Shows complete animation sequences
- **Walking Animations**: Left, Right, and Up/Down movement cycles
- **Explosion Sequence**: Complete 5-frame explosion animation

## Sprite Data Source

The sprite data is extracted from the annotated ROM section starting at **$BE20**, which contains:

### Player Sprite Data Structure
Each player sprite is **12 bytes** representing:
- **12 rows** of 8 pixels each
- **Dimensions**: 8 pixels wide × 12 pixels tall
- **Format**: 1 byte per row, each bit represents one pixel

This creates 8×12 pixel sprites for all player animations.

### Enemy Sprite Data
- **7 different enemy sprites** (12 bytes each)
- **Dimensions**: 8 pixels wide × 12 pixels tall
- **Animation States**: Stationary, walking in 4 directions with 2-frame cycles

### Explosion Sprite Data  
- **14 different explosion frames** (12 bytes each)
- **Dimensions**: 8 pixels wide × 12 pixels tall
- **Creates**: Complete progressive explosion animation sequence
- **Usage**: Both player death and enemy destruction effects

## Animation System Details

### Player Movement Animation
Based on the annotated data, the player uses different sprite sets for:
- **Horizontal Movement**: Walking Left/Right with 2-frame animation (4 sprites)
- **Vertical Movement**: Walking Up/Down with 2-frame animation (2 sprites)
- **Stationary State**: Single static sprite (1 sprite)
- **Shooting States**: 8 directional shooting sprites for complete coverage (8 sprites)
- **Total**: 15 player sprites providing complete animation coverage

### Enemy System
- **7 Different Sprites**: Multiple enemy animation states for varied movement
- **Animation Cycles**: 2-frame walking animations for each direction
- **PMG Positioning**: Hardware sprites positioned via Player/Missile Graphics
- **Multiple Instances**: Up to 3 enemies can be active simultaneously

### Explosion Effects
- **14-Frame Sequence**: Complete progressive explosion animation
- **Triggered Events**: Used for player death and enemy destruction
- **Visual Feedback**: Provides detailed destruction sequence

## Technical Implementation

### Data Format
- **Source**: ROM addresses $BE20 onwards
- **Player Sprites**: 12 bytes each (8×12 pixels)
- **Enemy Sprite**: 8 bytes (8×8 pixels)
- **Explosion Sprites**: 8 bytes each (8×8 pixels)
- **Bit Mapping**: Each bit represents one pixel (1=white, 0=black)
- **Structure**: 1 byte per row, 8 pixels per row

### Rendering Details
- **Player Sprites**: 8×12 pixels (12 bytes of data)
- **Enemy/Explosion Sprites**: 8×8 pixels (8 bytes of data)
- **Scaling**: Images scaled up for visibility in spritesheets
- **Colors**: Monochrome (white on black) - original hardware used different palettes
- **Layout**: Organized for easy reference and animation understanding

## Usage in Game Code

The annotated assembly shows these sprites are used throughout:
- **Movement Routines**: Select appropriate walking animations
- **Shooting System**: Use shooting-specific sprite variants
- **Collision Detection**: Trigger explosion animations
- **Enemy AI**: Reference enemy sprite for positioning and targeting
- **PMG System**: Hardware sprite positioning and movement

This sprite system provides the complete visual representation for K-Razy Shoot-Out gameplay.