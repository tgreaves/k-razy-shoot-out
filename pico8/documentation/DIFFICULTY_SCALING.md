# K-Razy Shoot-Out Difficulty Scaling Analysis

## Overview
The original game uses a difficulty table with 7 sectors (1-7), each with progressively harder parameters. The difficulty is controlled by 4 parameters per sector.

**D8 Parameter Purpose**: D8 controls the sprite animation/rendering frame counter limit. The game increments a counter ($91) each frame and compares it to D8. When the counter reaches D8, it resets and triggers sprite updates. Lower D8 values = more frequent sprite updates = faster/smoother enemy animations.

---

## Difficulty Parameters (from $BBE4-$BC03)

### Parameter Definitions
- **D1**: Enemy spawn limit (total enemies that must be defeated to clear sector)
- **D7**: Enemy firing frequency (frames between shots - lower = more frequent)
- **D6**: Game speed parameter (affects movement/missile speed)
- **D8**: Sprite animation frame limit (frames before sprite update - lower = smoother animation)

### Sector Difficulty Table

| Sector | D1 (Spawn Limit) | D7 (Fire Freq) | D6 (Speed) | D8 (Timing) | Notes |
|--------|------------------|----------------|------------|-------------|-------|
| 1      | 14               | 0              | 2          | 21          | Tutorial - No firing |
| 2      | 20               | 96             | 2          | 18          | Easy |
| 3      | 26               | 64             | 3          | 8           | Medium-Easy |
| 4      | 29               | 48             | 4          | 6           | Medium |
| 5      | 32               | 37             | 10         | 4           | Medium-Hard |
| 6      | 36               | 19             | 80         | 3           | Hard |
| 7      | 54               | 6              | 255        | 1           | Very Hard |

---

## Firing Frequency Analysis

### Theoretical Rates (if fired every opportunity)
- Sector 1: **NO FIRING** (tutorial)
- Sector 2: **0.62 shots/sec** (every 1.6 seconds)
- Sector 3: **0.94 shots/sec** (every 1.1 seconds)
- Sector 4: **1.25 shots/sec** (every 0.8 seconds)
- Sector 5: **1.62 shots/sec** (every 0.6 seconds)
- Sector 6: **3.15 shots/sec** (every 0.3 seconds)
- Sector 7: **9.99 shots/sec** (every 0.1 seconds)

### Actual Rates (with randomization)
The game uses hardware randomization that reduces firing by ~75%, resulting in:
- Sector 2: ~0.15 shots/sec (every ~6.4 seconds)
- Sector 3: ~0.23 shots/sec (every ~4.3 seconds)
- Sector 4: ~0.31 shots/sec (every ~3.2 seconds)
- Sector 5: ~0.40 shots/sec (every ~2.5 seconds)
- Sector 6: ~0.79 shots/sec (every ~1.3 seconds)
- Sector 7: ~2.50 shots/sec (every ~0.4 seconds)

---

## Difficulty Progression Patterns

### Enemy Count Scaling
- **Sectors 1-5**: Gradual increase (14 → 32 enemies)
- **Sector 6**: Moderate jump (36 enemies)
- **Sector 7**: Large jump (54 enemies, +50%)

### Firing Frequency Scaling
- **Sector 1**: No firing (tutorial)
- **Sectors 2-5**: Gradual decrease in delay (96 → 37 frames)
- **Sector 6**: Significant jump (19 frames, ~50% faster)
- **Sector 7**: Extreme aggression (6 frames, near-constant firing)

### Speed Scaling
- **Sectors 1-4**: Slow progression (2 → 4)
- **Sector 5**: Moderate increase (10)
- **Sector 6**: Large jump (80)
- **Sector 7**: Maximum speed (255)

---

## PICO-8 Implementation Strategy

### Current Implementation
```lua
total_enemies = 10 + level * 2
```
This is too simple and doesn't match the original progression.

### Proposed Implementation

#### 1. Difficulty Table
```lua
-- difficulty parameters per sector
-- format: {spawn_limit, fire_freq, speed, timing}
difficulty_table = {
  {14, 0,   2,   21},  -- sector 1 (tutorial)
  {20, 96,  2,   18},  -- sector 2
  {26, 64,  3,   8},   -- sector 3
  {29, 48,  4,   6},   -- sector 4
  {32, 37,  10,  4},   -- sector 5
  {36, 19,  80,  3},   -- sector 6
  {54, 6,   255, 1}    -- sector 7
}
```

#### 2. Load Difficulty Parameters
```lua
function load_sector_difficulty()
  -- clamp sector to 1-7
  local sector = mid(1, level, 7)
  
  local params = difficulty_table[sector]  -- lua is 1-indexed, sector 1 = index 1
  
  total_enemies = params[1]      -- spawn limit
  enemy_fire_freq = params[2]    -- firing frequency
  game_speed = params[3]         -- speed multiplier
  timing_param = params[4]       -- timing parameter
end
```

#### 3. Apply Firing Frequency
```lua
function update_enemy(e)
  -- existing movement code...
  
  -- firing logic with frequency check
  if enemy_fire_freq > 0 then  -- sector 1 has freq=0 (no firing)
    e.fire_timer = e.fire_timer or 0
    e.fire_timer += 1
    
    if e.fire_timer >= enemy_fire_freq then
      e.fire_timer = 0
      -- random chance to fire (25% like original)
      if rnd(1) < 0.25 and e.missile == nil then
        fire_enemy_missile(e)
      end
    end
  end
end
```

#### 4. Apply Speed Scaling
```lua
function load_sector_difficulty()
  -- ... existing code ...
  
  -- scale speeds based on game_speed parameter
  -- sectors 1-5: normal speed
  -- sector 6: 40x faster (80/2)
  -- sector 7: 127x faster (255/2)
  
  local speed_mult = game_speed / 2
  enemy_speed = 0.5 * speed_mult
  missile_speed = 2 * speed_mult
  
  -- clamp to reasonable values for PICO-8
  enemy_speed = min(enemy_speed, 2)
  missile_speed = min(missile_speed, 4)
end
```

#### 5. Enemy Spawn Initialization
```lua
function spawn_enemy()
  -- existing spawn code...
  
  add(enemies, {
    x = x,
    y = y,
    dir = 0,
    move_timer = 0,
    anim_frame = 0,
    anim_timer = 0,
    missile = nil,
    fire_timer = 0  -- add firing timer
  })
end
```

---

## Key Changes Needed

### 1. Add Difficulty Variables
```lua
-- in _init() or init_game()
enemy_fire_freq = 0
game_speed = 2
timing_param = 0
```

### 2. Call Difficulty Loader
```lua
function init_game()
  init_arena()
  load_sector_difficulty()  -- NEW: load difficulty params
  init_player()
  init_enemies()
  -- ... rest of init
end
```

### 3. Update Enemy Firing Logic
Replace the current random firing with frequency-based firing:
```lua
-- OLD:
if rnd(1) < 0.1 and e.missile == nil then
  fire_enemy_missile(e)
end

-- NEW:
if enemy_fire_freq > 0 then
  e.fire_timer = (e.fire_timer or 0) + 1
  if e.fire_timer >= enemy_fire_freq then
    e.fire_timer = 0
    if rnd(1) < 0.25 and e.missile == nil then
      fire_enemy_missile(e)
    end
  end
end
```

### 4. Scale Movement Speeds
```lua
-- in load_sector_difficulty()
if game_speed <= 10 then
  -- sectors 1-5: normal speed
  enemy_speed = 0.5
  missile_speed = 2
elseif game_speed <= 80 then
  -- sector 6: faster
  enemy_speed = 0.75
  missile_speed = 2.5
else
  -- sector 7: maximum speed
  enemy_speed = 1.0
  missile_speed = 3.0
end
```

---

## Testing Recommendations

1. **Sector 1**: Verify enemies don't fire (tutorial mode)
2. **Sectors 2-4**: Gradual difficulty increase, manageable
3. **Sector 5**: Noticeable speed increase
4. **Sector 6**: Significant challenge with faster firing
5. **Sector 7**: Extreme difficulty, near-constant enemy fire

---

## Notes

- The original uses frame-based timing (60fps), PICO-8 also runs at 60fps
- **D8 controls sprite animation speed**: Code at $B6F5-$B708 increments counter $91 each frame and compares to D8. When $91 >= D8, it resets and updates sprites. Lower D8 = faster animation updates.
- Speed scaling should be capped to keep game playable in PICO-8
- Consider adding visual feedback for sector difficulty (color changes, etc.)
- **D8 implementation**: In PICO-8, this could control enemy animation frame rate or movement update frequency. Lower values make enemies appear more fluid/aggressive.
