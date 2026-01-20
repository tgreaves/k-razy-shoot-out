# K-Razy Shoot-Out - Game Mechanics Reference

## Game Overview
K-Razy Shoot-Out is a single-player action game where Space Commanders must escape through randomly-generated Alien Control Sectors by destroying Droids.

## Game Screens Overview

- The title screen (with the CBS electronics logo) appears first.
- The game loop begins when the player presses the fire / trigger button.
- Sector 1 is the first sector.
- Before a sector is displayed, 'ENTERING SECTOR x' is shown on the screen.
- The maze, game HUD and player + enemy sprites then appear, and the game begins.
- When the player leaves the arena, the screen is cleared line by line.
- A tally of killed droids appears.
- Bonus points are awarded ('BONUS POINTS') if applicable due to time remaining.
- The next sector starts IF all droids were killed, otherwise the same sector is replayed.
- At game over, a 'PRESS TRIGGER TO PLAY AGAIN' screen is displayed, and a scrolling message along the top shows the player's score and rank.

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
1. Running into a barrier (This includes walls at the edge of the arena)
2. Hit by enemy fire
3. Contact with a Droid
4. Contact with radioactive debris (remains after Droid elimination)

### Death Detection
- **$97**: Death detection flag (set to 1 when death condition occurs)
- **$BD47**: Boundary check routine that sets $97 when player goes out of bounds
- **$B4C3**: Death routine called when $97 is set
- **$B765**: Death music played ($B097)
- **$B768**: Death counter $DA incremented

## Sector System

### Sector Levels
- **7 Sector Levels total**
- Each level progressively more challenging.
- A data look-up table defines the number of droids to defeat, how fast they move, and how aggressive they are.
- Droids do NOT fire on the first sector.
- Sectors are **randomly generated** with millions of combinations
- No two Sectors are ever the same

### Sector Completion
To advance to next Sector:
1. Eliminate ALL Droids in current Sector
2. Exit before Countdown Bar expires

Note that the player can escape before all droids are defeated, but this will NOT advance the sector count.  The sector will be replayed.

## Droid System

### Droid Spawning
- Droids materialize at the **perimeters of the Sector**
- Can spawn on top of player if not careful
- A maximum of three droids can spawn at any one time.
- The maximum number of permitted droids will always spawn where possible.

### Droid Count Indicator
- **Space Commander turns green** when 6 or fewer Droids remain

## Droid movement and AI

- Data look-up table used to define behaviour on a per-sector basis.
- Droids will avoid walking into barriers.
- Droids will walk into each other -- not deliberately, but if movement towards the player makes this happen.
- Each droid can only have one droid missile on screen at any one time.
- Droids have infinite ammunition.

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
- Casings used shown on the 'GAME OVER' screen in the scrolling text.
- There is no reload mechanic.

### Firing Mechanics
1. Press and hold trigger button
2. Move joystick in desired direction while holding trigger
3. Can fire in 8 directions: up, down, left, right, and 4 diagonals
4. Only one player missile can be on screen at any one time.

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

CHECK THIS: It's mentioned in the manual, but does game code confirm it?

If player exits Sector before eliminating all Droids:
- Must replay **up to 2 Sectors**
- **No points scored** during replayed Sectors
- Replayed Sectors are completely new designs

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
