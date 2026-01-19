# K-Razy Shoot-Out - Game Mechanics Reference

## Game Overview
K-Razy Shoot-Out is a single-player action game where Space Commanders must escape through randomly-generated Alien Control Sectors by destroying Droids.

## Lives System

### Starting Lives
- **3 Space Commanders** at game start
- Only one Commander active per Sector at a time

### Extra Lives
- **Awarded every 10,000 points**
- **Maximum: 4 Commanders in reserve** at any time
- Total possible: 1 active + 4 reserve = 5 Commanders maximum

### Death Conditions
A Space Commander is lost when:
1. Running into a barrier
2. Hit by enemy fire
3. Contact with a Droid
4. Contact with radioactive debris (remains after Droid elimination)

### Special Death Rule
If you eliminate all but 1-2 Droids and then die:
- Reserve Commander appears in the Sector
- **No Droids will confront the new Commander**
- Reason: "Droid philosophy - need 3 to 1 odds minimum"

## Sector System

### Sector Levels
- **7 Sector Levels total**
- Each level progressively more challenging
- Sectors are **randomly generated** with millions of combinations
- No two Sectors are ever the same

### Sector Progression
- **Sector 1**: Simple, unarmed Droids
- **Sector 2**: Droids begin returning laser fire
- **Sector 5+**: Droids move and shoot extremely fast

### Sector Completion
To advance to next Sector:
1. Eliminate ALL Droids in current Sector
2. Exit before Countdown Bar expires

## Droid System

### Droid Behavior by Sector
- **Sector 1**: Unarmed, can destroy themselves by colliding
- **Sector 2+**: Armed, return laser fire
- **Sector 5+**: Very fast movement and shooting

### Droid Spawning
- Droids materialize at the **perimeters of the Sector**
- Can spawn on top of player if not careful

### Droid Count Indicator
- **Space Commander turns green** when 6 or fewer Droids remain

## Countdown Bar System

### Bar Behavior
- Located at top of screen above Sector
- Starts **green** and gradually disappears left to right
- Changes to **yellow** at midpoint
- Changes to **red** near end
- Game ends if bar disappears completely before all Droids eliminated

### Bonus Points by Bar Color
- **Green**: 1,000 points
- **Yellow**: 300 points  
- **Red**: 0 points

## Scoring System

### Droid Elimination Points
| Method | Sectors 1-3 | Sectors 4-7 |
|--------|-------------|-------------|
| Shot by player | 100 points | 200 points |
| Colliding with barrier | 10 points | 10 points |
| Colliding with each other | 10 points | 10 points |
| Shooting each other | 50 points | 50 points |

### Bonus Points
- Awarded based on Countdown Bar color when exiting
- Only awarded if ALL Droids eliminated before exit

## Weapons System

### Ammunition
- **Unlimited power-pack casings**
- Each casing contains **50 laser rounds**
- Ammunition counter displayed during game

### Firing Mechanics
1. Press and hold trigger button
2. Move joystick in desired direction while holding trigger
3. Can fire in 8 directions: up, down, left, right, and 4 diagonals

## Rank & Classification System

### Ranks (Ascending Order)
1. **Goon** (lowest)
2. **Rookie**
3. **Novice**
4. **Gunner**
5. **Blaster**
6. **Marksman** (highest)

### Classifications
- Each Rank divided into **5 Classifications**
- **5** = lowest classification
- **1** = highest classification
- Example: "Rookie 5" → "Rookie 1" → "Novice 5"

## Special Features

### "Chickening Out" Penalty
If player exits Sector before eliminating all Droids:
- Must replay **up to 2 Sectors**
- **No points scored** during replayed Sectors
- Replayed Sectors are completely new designs

### Game Over Conditions
1. All Space Commanders lost
2. Countdown Bar expires before all Droids eliminated

### Controls
- **Joystick**: 8-directional movement
- **Trigger buttons** (2): Fire laser pistol
- **PAUSE**: Pause/resume game
- **START**: Return to Sector 1 (keeps high score)
- **RESET**: Return to title screen (clears high score)

## Display Information

### On-Screen Elements
- **Score**: Bottom of screen (running total)
- **Time**: Elapsed time display
- **Countdown Bar**: Top of screen (green/yellow/red)
- **Commanders in Reserve**: Visual indicator
- **Commander Color**: Turns green when ≤6 Droids remain

### End Game Display
- Total score
- Time used
- Number of power-pack casings used
- Rank and Classification
- High score

## Strategy Notes (from Manual)

1. **Maneuver Droids into barriers** - use Commander as decoy
2. **Cause Droids to shoot each other** - 50 points vs 10 points for collision
3. **Watch Commander color** - turns green at 6 or fewer Droids
4. **Avoid perimeters** - Droids spawn at edges
5. **Aim carefully** - avoid near misses between Droid legs/shoulders

## Code Analysis Notes

### Lives Counter Location
- **Unknown** - needs to be located in code
- Should initialize to 3 at game start
- Should decrement on death
- Should increment every 10,000 points (max 4 reserve)
- Game over when reaches 0

### Key Memory Locations to Find
- Lives counter (starts at 3)
- Extra life award threshold (10,000 points)
- Maximum reserve lives check (4)
- Droid count per Sector
- Countdown bar timer
- Power-pack casing counter (50 rounds each)
- Rank/Classification calculation
