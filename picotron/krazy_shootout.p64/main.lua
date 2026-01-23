-- k-razy shoot-out
-- picotron edition (320x192)
-- based on atari 5200 original
-- by tristan greaves

-- include modules
include("utils.lua")
include("sprites.lua")
include("collision.lua")
include("arena.lua")
include("entities.lua")
include("hud.lua")
include("sprite_data.lua")

-- set screen resolution to match atari 5200
function _init()
 -- set 320x192 resolution (matching atari 5200 mode 8)
 window({
  width=320,
  height=192,
  resizable=false
 })
 
 init_game_state()
 init_sprites()
end

-- game states
STATE_TITLE = 0
STATE_SECTOR_INTRO = 1
STATE_GAME = 2
STATE_DEATH_FREEZE = 3
STATE_GAMEOVER = 4
STATE_ARENA_CLEAR = 5

-- game constants
MAX_ENEMIES = 3
PLAYER_SPEED = 1
MISSILE_SPEED = 2

-- playfield dimensions (based on atari original)
-- arena is 320x160 (top 160 pixels)
-- HUD is 320x32 (bottom 32 pixels)
ARENA_WIDTH = 320
ARENA_HEIGHT = 160
HUD_Y = 160
HUD_HEIGHT = 32

-- exit positions (set during arena generation)
left_exit_y = 0
right_exit_y = 0

-- arena clearing animation
clear_line = 0
clear_timer = 0
next_state_after_clear = STATE_SECTOR_INTRO

-- difficulty table (from atari disassembly $bbe4)
-- format: {spawn_limit, fire_freq, speed, anim_timing}
difficulty_table = {
 {14, 0, 2, 21},    -- sector 1 (tutorial)
 {20, 96, 2, 18},   -- sector 2
 {26, 64, 3, 8},    -- sector 3
 {29, 48, 4, 6},    -- sector 4
 {32, 37, 10, 4},   -- sector 5
 {36, 19, 80, 3},   -- sector 6
 {54, 6, 255, 1}    -- sector 7
}

-- atari 5200 color palette (matching original)
-- using RGB values that approximate atari colors
COLORS = {
 BLACK = 0,
 WHITE = 7,
 RED = 8,
 ORANGE = 9,
 YELLOW = 10,
 GREEN = 11,
 CYAN = 12,
 BLUE = 13,
 PURPLE = 14,
 PINK = 15
}

-- colors for random selection (excluding black/white/dark)
atari_colors = {8, 9, 10, 11, 12, 13, 14, 15}

function init_game_state()
 state = STATE_TITLE
 score = 0
 level = 1
 lives = 3
 sector_intro_timer = 0
 death_freeze_timer = 0
 
 -- difficulty variables
 enemy_fire_freq = 0
 enemy_speed = 1
 missile_speed = 2
 anim_timing = 0
 
 -- game entities
 player = nil
 enemies = {}
 explosions = {}
 spawn_queue = {}
 arena = {}
 
 -- game progress
 enemies_defeated = 0
 total_enemies = 0
 time_remaining = 77
 time_counter = 0
 
 -- colors
 arena_color = 5
 enemy_colors = {}
end

function _update()
 if state == STATE_TITLE then
  update_title()
 elseif state == STATE_SECTOR_INTRO then
  update_sector_intro()
 elseif state == STATE_GAME then
  update_game()
 elseif state == STATE_DEATH_FREEZE then
  update_death_freeze()
 elseif state == STATE_GAMEOVER then
  update_gameover()
 elseif state == STATE_ARENA_CLEAR then
  update_arena_clear()
 end
end

function _draw()
 cls(0)
 
 if state == STATE_TITLE then
  draw_title()
 elseif state == STATE_SECTOR_INTRO then
  draw_sector_intro()
 elseif state == STATE_GAME then
  draw_game()
 elseif state == STATE_DEATH_FREEZE then
  draw_game()  -- show frozen game state
 elseif state == STATE_GAMEOVER then
  draw_gameover()
 elseif state == STATE_ARENA_CLEAR then
  draw_arena_clear()
 end
end

-- title screen
function update_title()
 if btnp(4) or btnp(5) then
  state = STATE_SECTOR_INTRO
  sector_intro_timer = 0
 end
end

function draw_title()
 print("K-RAZY SHOOT-OUT", 80, 70, 7)
 print("PRESS BUTTON TO START", 60, 100, 6)
 print("BASED ON ATARI 5200 ORIGINAL", 40, 140, 5)
 print("BY K. DREYER", 110, 150, 5)
end

-- sector intro screen
function update_sector_intro()
 sector_intro_timer += 1
 if sector_intro_timer >= 60 then  -- 1 second at 60fps
  state = STATE_GAME
  init_game()
 end
end

function draw_sector_intro()
 cls(0)
 local text = "ENTERING SECTOR " .. level
 print(text, 100, 80, 7)
end

-- placeholder functions (to be implemented)
function init_game()
 -- randomize arena color for this sector
 arena_color = atari_colors[flr(rnd(#atari_colors)) + 1]
 
 init_arena()  -- create arena first
 load_sector_difficulty()  -- load difficulty params
 init_player()  -- then spawn player (needs arena for collision check)
 init_enemies()
 explosions = {}
 enemies_defeated = 0
 time_remaining = 77
 time_counter = 0
 spawn_queue = {}  -- queue of pending enemy spawns
end

-- load difficulty parameters
function load_sector_difficulty()
 -- clamp sector to 1-7
 local sector = mid(1, level, 7)
 
 local params = difficulty_table[sector]
 
 total_enemies = params[1]      -- spawn limit
 enemy_fire_freq = params[2]    -- firing frequency
 local game_speed = params[3]   -- speed multiplier
 anim_timing = params[4]        -- animation timing
 
 -- scale speeds based on game_speed parameter
 if game_speed <= 2 then
  enemy_speed = 1
  missile_speed = 2
 elseif game_speed <= 3 then
  enemy_speed = 1
  missile_speed = 2
 elseif game_speed <= 4 then
  enemy_speed = 1
  missile_speed = 2
 elseif game_speed <= 10 then
  enemy_speed = 1
  missile_speed = 3
 elseif game_speed <= 80 then
  enemy_speed = 2
  missile_speed = 3
 else
  enemy_speed = 2
  missile_speed = 4
 end
end

function init_enemies()
 enemies = {}
 for i = 1, MAX_ENEMIES do
  spawn_enemy()
 end
end

function update_game()
 -- debug: skip to next sector with both action buttons
 if btn(4) and btn(5) then
  level += 1
  if level > 7 then level = 7 end
  state = STATE_SECTOR_INTRO
  sector_intro_timer = 0
  return
 end
 
 update_player()
 update_enemies()
 update_explosions()
 update_timer()
 update_spawn_queue()
end

function update_spawn_queue()
 for sq in all(spawn_queue) do
  sq.timer -= 1
  if sq.timer <= 0 then
   spawn_enemy()
   del(spawn_queue, sq)
  end
 end
end

function update_explosions()
 for ex in all(explosions) do
  ex.timer += 1
  if ex.timer > 3 then
   ex.timer = 0
   ex.frame += 1
   if ex.frame >= 8 then  -- 8 frames of explosion
    del(explosions, ex)
   end
  end
 end
end

function update_timer()
 time_counter += 1
 if time_counter >= 127 then
  time_counter = 0
  time_remaining -= 1
  
  -- check if time ran out
  if time_remaining <= 2 then
   -- time's up - clear arena then game over
   enemies = {}
   explosions = {}
   spawn_queue = {}
   clear_line = 0
   clear_timer = 0
   next_state_after_clear = STATE_GAMEOVER
   state = STATE_ARENA_CLEAR
  end
 end
end

function draw_game()
 -- draw arena
 draw_arena()
 
 -- draw timer bar at top
 draw_timer_bar()
 
 -- draw entities
 draw_player()
 draw_enemies()
 draw_explosions()
 
 -- draw HUD at bottom
 draw_hud()
end

function update_death_freeze()
 -- only update explosions during freeze
 update_explosions()
 
 death_freeze_timer -= 1
 if death_freeze_timer <= 0 then
  if lives <= 0 then
   -- game over after freeze - clear arena first
   enemies = {}
   explosions = {}
   spawn_queue = {}
   clear_line = 0
   clear_timer = 0
   next_state_after_clear = STATE_GAMEOVER
   state = STATE_ARENA_CLEAR
  else
   -- respawn everything except arena
   init_player()
   
   -- clear all enemies and respawn
   enemies = {}
   for i = 1, MAX_ENEMIES do
    spawn_enemy()
   end
   
   -- clear spawn queue
   spawn_queue = {}
   
   -- keep enemies_defeated counter (progress persists across deaths)
   
   -- resume game
   state = STATE_GAME
  end
 end
end

function update_gameover()
 if btnp(4) or btnp(5) then
  init_game_state()
 end
end

function draw_gameover()
 cls(0)
 print("GAME OVER", 120, 70, 8)
 print("SCORE: " .. score, 120, 90, 7)
 print("PRESS BUTTON", 110, 120, 6)
end

function update_arena_clear()
 clear_timer += 1
 if clear_timer >= 2 then  -- advance every 2 frames
  clear_timer = 0
  clear_line += 4  -- clear 4 pixels at a time
  
  if clear_line >= ARENA_HEIGHT then
   -- clearing complete, transition to next state
   state = next_state_after_clear
   if state == STATE_SECTOR_INTRO then
    sector_intro_timer = 0
   end
  end
 end
end

function draw_arena_clear()
 -- draw the arena
 draw_arena()
 
 -- draw black rectangle to clear from top down to clear_line
 if clear_line > 0 then
  rectfill(0, 0, ARENA_WIDTH - 1, clear_line - 1, 0)
 end
 
 -- draw HUD
 draw_hud()
end
