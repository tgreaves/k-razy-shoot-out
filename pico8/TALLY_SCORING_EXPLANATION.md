# Tally Screen Scoring Explanation

## How Enemy Point Values Work

The tally screen categories (100pt/50pt/10pt) represent **HOW** enemies were defeated, not the exact points awarded during gameplay.

### Defeat Methods and Scoring

| Tally Category | Defeat Method | Points Awarded | Assembly Variable |
|----------------|---------------|----------------|-------------------|
| **100 POINTS** | Player shoots enemy | 100 (sectors 1-3)<br>200 (sectors 4-7) | `$D4` |
| **50 POINTS** | Enemy missile hits enemy | 50 points | `$D2` |
| **10 POINTS** | Enemy collides with enemy | 10 points | `$D3` |

### From the Original Assembly Code

Looking at the collision detection routines in `K_RAZY_SHOOTOUT_ANNOTATED.asm`:

**Player Missile Hits Enemy** (`$A903-$A930`):
```assembly
$A905: 20 66 BD JSR player_bonus_score_increase  ; Add to score
$A908: E6 D4    INC $D4                          ; Increment $D4 counter
```
- Awards 10 points base (multiplied by sector difficulty)
- Increments `$D4` → Shows as "100 POINTS" on tally

**Enemy Missile Hits Enemy** (`$A869-$A8DA`):
```assembly
$A86B: 20 6C BD JSR enemy_hit_scoring           ; Add 1 point to score
$A86E: E6 D2    INC $D2                          ; Increment $D2 counter
```
- Awards 1 point base (multiplied by 50 in scoring routine)
- Increments `$D2` → Shows as "50 POINTS" on tally (but actually 50pts)

**Enemy Collides with Enemy** (`$A852-$A8C1`):
```assembly
$A852: A9 05    LDA #$05                         ; 5 points bonus
$A854: 20 6C BD JSR enemy_hit_scoring           ; Add bonus to score
$A857: E6 D3    INC $D3                          ; Increment $D3 counter
```
- Awards 5 points base (multiplied by 2 in scoring routine = 10 points)
- Increments `$D3` → Shows as "10 POINTS" on tally (but actually 10pts)

### Why the Confusion?

The tally screen labels (100/50/10) don't directly match the points awarded:
- They're just **category labels** to distinguish defeat methods
- The actual scoring happens during gameplay with different multipliers
- The original game manual confirms: "Droids shot: 100 points" and "Droids shooting each other: 50 points"

### PICO-8 Implementation

In `kill_enemy(e, killed_by)`:

```lua
if killed_by=="enemy_missile" then
  -- enemy shot by another enemy's missile
  points=50
  enemies_defeated_50pt+=1
  
elseif killed_by=="collision" then
  -- enemy died from collision with another enemy
  points=10
  enemies_defeated_10pt+=1
  
else
  -- player shot the enemy
  if level>=4 then
   points=200  -- sectors 4-7
  else
   points=100  -- sectors 1-3
  end
  enemies_defeated_100pt+=1
end
```

### Tally Display

The tally screen then shows:
```
ENEMIES VANQUISHED

100 POINTS          <- Enemies you shot
[enemy] [enemy] ...

50 POINTS           <- Enemies killed by enemy missiles
[enemy] [enemy] ...

10 POINTS           <- Enemies killed by collision
[enemy] [enemy] ...
```

This matches the original game's behavior where the tally categories represent the defeat method, creating a nice summary of how you cleared the sector.
