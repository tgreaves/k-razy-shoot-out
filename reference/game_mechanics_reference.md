# K-Razy Shoot-Out - Game Mechanics Reference

## Game Overview
K-Razy Shoot-Out is a single-player action game where Space Commanders must escape through randomly-generated Alien Control Sectors by destroying Droids.

## Lives System

### Starting Lives
- **3 Space Commanders** at game start
- Only one Commander active per Sector at a time
- **Lives tracked by death counter $DA** (starts at 0)

### Death Counter ($DA)
- **$DA = 0**: No deaths yet (3 lives remaining)
- **$DA = 1**: 1 death (2 lives remaining)
- **$DA = 2**: 2 deaths (1 life remaining)
- **$DA = 3**: 3 deaths (0 lives remaining) → **GAME OVER**

### Code Locations
- **$A57A**: Death counter initialized to 0 at game start
- **$B768**: Death counter incremented on each death
- **$A34F-$A353**: Main game loop checks if $DA == 3 for game over
- **$B75E**: Player death and respawn routine (player_death_and_respawn)

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
5. Going out of bounds (detected by boundary check at $BD47)

### Death Detection
- **$97**: Death detection flag (set to 1 when death condition occurs)
- **$BD47**: Boundary check routine that sets $97 when player goes out of bounds
- **$B4C3**: Death routine called when $97 is set
- **$B765**: Death music played ($B097)
- **$B768**: Death counter $DA incremented

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

### Lives System Implementation
- **$DA (death counter)**: Tracks number of deaths (0-3)
  - Initialized to 0 at $A57A (3 lives remaining)
  - Incremented at $B768 on each death
  - Checked at $A34F for game over condition
- **$97 (death flag)**: Set to 1 when death condition detected
  - Set by boundary check at $BD57
  - Checked at $B4C1 to trigger death routine
- **$B75E (player_death_and_respawn)**: Main death handling routine
  - Plays death music
  - Increments death counter
  - Handles respawn animation
  - Returns to game if lives remaining

### Extra Life System
- **Award threshold**: Every 10,000 points
- **Maximum reserve**: 4 Commanders in reserve
- **Implementation**: NOT YET FOUND in code
  - Should check ten-thousands digit ($060B) for changes
  - Should increment lives counter (or decrement death counter?)
  - May not be fully implemented in this version

### Key Memory Locations Found
- **$DA**: Death counter (0-3, game over at 3)
- **$97**: Death detection flag
- **$060B-$060F**: Score (5 BCD digits)
- **$7B**: Previous ten-thousands digit (for extra life detection?)
- **$D5**: Current level/sector number
- **$D9**: Time remaining counter

### Key Memory Locations to Find
- Extra life award mechanism (10,000 point check)
- Droid count per Sector
- Power-pack casing counter (50 rounds each)
- Rank/Classification calculation
