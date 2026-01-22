# Tally Screen Implementation

## Overview
Implemented the between-level tally screen and bonus points screen based on the original Atari 5200 K-Razy Shoot-Out game.

## Changes Made

### 1. New Game States
Added two new states:
- `state_tally` (6) - Shows enemies defeated
- `state_bonus` (7) - Shows bonus points awarded

### 2. Enemy Kill Tracking
Added three new counters to track enemies by **defeat method**:
- `enemies_defeated_100pt` - Enemies shot by player (100-200 points depending on sector)
- `enemies_defeated_50pt` - Enemies killed by other enemy missiles (50 points)
- `enemies_defeated_10pt` - Enemies killed by collision with other enemies (10 points)

These are initialized in `init_game()` and incremented in `kill_enemy()` based on the `killed_by` parameter.

**Note**: The tally categories (100/50/10) represent HOW enemies were defeated, not necessarily the exact points awarded. The actual scoring happens during gameplay.

### 3. Tally Screen (`state_tally`)

**Flow:**
1. After player escapes and arena clears, if all enemies were defeated, transition to tally screen
2. Display "ENEMIES VANQUISHED" title
3. Show enemy sprites (sprite 7 - stationary enemy) one at a time with sound
4. Group by defeat method:
   - 100pt category: Enemies shot by player
   - 50pt category: Enemies killed by enemy missiles
   - 10pt category: Enemies killed by collision
5. Display up to 13 enemies per row
6. After all displayed, wait 1 second then check for bonus

**Functions:**
- `init_tally_screen()` - Initialize counters
- `update_tally()` - Animate enemy display, check for completion
- `draw_tally()` - Render enemy sprites in rows by point value

**Timing:**
- New enemy appears every 8 frames (~0.13 seconds)
- Plays weapon sound (sfx 0) for each enemy
- Waits 60 frames (1 second) after all displayed

### 4. Bonus Points Screen (`state_bonus`)

**Flow:**
1. Check time remaining:
   - If ≥53: Award 10 bonuses of 1000 points each (10,000 total)
   - If ≥27: Award 3 bonuses of 300 points each (900 total)
   - If <27: No bonus, skip to next sector
2. Flash "BONUS POINTS" text
3. Award points with each flash (sound + score increment)
4. After all bonuses awarded, wait 1 second then advance to next sector

**Functions:**
- `init_bonus_screen()` - Calculate bonus amount based on time
- `update_bonus()` - Handle flashing and point awarding
- `draw_bonus()` - Render flashing text and counter

**Timing:**
- Text flashes every 8 frames (~0.13 seconds)
- Each flash awards one bonus increment
- Plays weapon sound (sfx 0) for each bonus
- Waits 60 frames (1 second) after all bonuses

### 5. Game Flow Updates

**Modified `player_escaped()`:**
- Now checks if all enemies defeated
- If yes: Sets `next_state_after_clear=state_tally`
- If no: Sets `next_state_after_clear=state_sector_intro` (replay level)
- Level increment moved to bonus screen (or tally if no bonus)

**Modified `update_arena_clear()`:**
- Added initialization of tally screen when transitioning to it

**Modified `_update()` and `_draw()`:**
- Added handlers for `state_tally` and `state_bonus`

## Visual Design

### Tally Screen
```
     ENEMIES VANQUISHED
     
     100 POINTS
     [enemy] [enemy] [enemy] ...
     
     50 POINTS
     [enemy] [enemy] ...
     
     10 POINTS
     [enemy] [enemy] ...
```

### Bonus Screen
```
     
     
          BONUS POINTS    (flashing)
          
             3/10
            +3000
```

## Differences from Original

1. **Point Values**: Implemented correctly based on defeat method:
   - Player shoots enemy: 100 points (sectors 1-3) or 200 points (sectors 4-7)
   - Enemy missile hits enemy: 50 points
   - Enemy collision: 10 points
2. **Sprite Display**: Uses sprite 7 (stationary enemy) for all tally displays
3. **Layout**: Adapted to PICO-8's 128x128 screen (original was larger)
4. **Timing**: Slightly faster animation to fit PICO-8's 60fps

## Testing

To test:
1. Start game and complete a sector by defeating all enemies
2. Try different defeat methods:
   - Shoot enemies with your weapon (100pt category)
   - Let enemies shoot each other (50pt category)
   - Let enemies collide with each other (10pt category)
3. Exit through the gap
4. Watch arena clear animation
5. See tally screen with enemies appearing one by one, grouped by defeat method
6. If time remaining ≥27, see bonus points screen
7. Advance to next sector

## Future Enhancements

1. Add more visual effects (enemy colors, sparkles)
2. Add statistics display (accuracy, time bonus, etc.)
3. Match original timing more closely
4. Add different colored enemy sprites for each category on tally screen
