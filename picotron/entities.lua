-- game entities: player, enemies, missiles, explosions

-- player initialization
function init_player()
 -- find safe spawn position (not on a wall)
 local spawn_x, spawn_y
 local attempts = 0
 
 repeat
  spawn_x = 80 + flr(rnd(160))  -- center area of 320px wide arena
  spawn_y = 40 + flr(rnd(80))   -- center area of 160px tall arena
  attempts += 1
 until not check_wall_collision(spawn_x, spawn_y) or attempts > 50
 
 -- fallback to center if no safe spot found
 if attempts > 50 then
  spawn_x = ARENA_WIDTH / 2
  spawn_y = ARENA_HEIGHT / 2
 end
 
 player = {
  x = spawn_x,
  y = spawn_y,
  dir = 0,  -- 0=right, 1=down, 2=left, 3=up
  fire_dir = 0,  -- 0-7 for 8-way firing
  anim_frame = 0,
  anim_timer = 0,
  missile = nil,
  alive = true
 }
 
 sfx(2)  -- spawn sound
end

-- update player
function update_player()
 -- check if firing button is pressed
 local firing = btn(4) or btn(5)
 
 -- check direction input
 local dx, dy = 0, 0
 if btn(0) then dx = -1 end
 if btn(1) then dx = 1 end
 if btn(2) then dy = -1 end
 if btn(3) then dy = 1 end
 
 local dir_pressed = dx != 0 or dy != 0
 
 -- if firing, update aim direction but don't move
 if firing then
  if dir_pressed then
   -- update firing direction based on current input
   if dx < 0 and dy < 0 then
    player.fire_dir = 5  -- up-left
   elseif dx > 0 and dy < 0 then
    player.fire_dir = 7  -- up-right
   elseif dx < 0 and dy > 0 then
    player.fire_dir = 3  -- down-left
   elseif dx > 0 and dy > 0 then
    player.fire_dir = 1  -- down-right
   elseif dx < 0 then
    player.fire_dir = 4  -- left
   elseif dx > 0 then
    player.fire_dir = 0  -- right
   elseif dy < 0 then
    player.fire_dir = 6  -- up
   elseif dy > 0 then
    player.fire_dir = 2  -- down
   end
   
   -- fire missile
   if player.missile == nil then
    fire_player_missile()
   end
  end
 else
  -- not firing, can move
  if dir_pressed then
   local moving = false
   local move_dx = dx * PLAYER_SPEED
   local move_dy = dy * PLAYER_SPEED
   
   -- update visual direction
   if dx < 0 then
    player.dir = 2  -- left
   elseif dx > 0 then
    player.dir = 0  -- right
   elseif dy != 0 then
    player.dir = (dy < 0) and 3 or 1  -- up or down
   end
   
   -- calculate new position
   local newx = player.x + move_dx
   local newy = player.y + move_dy
   
   -- collision check with walls - instant death
   if check_wall_collision(newx, newy) then
    player_hit()
    return
   end
   
   -- collision check with enemies - both die
   for e in all(enemies) do
    if check_sprite_collision(newx, newy, e.x, e.y) then
     kill_enemy(e)
     player_hit()
     return
    end
   end
   
   -- collision check with explosions - player dies
   for ex in all(explosions) do
    if check_sprite_collision(newx, newy, ex.x, ex.y) then
     player_hit()
     return
    end
   end
   
   -- safe to move
   player.x = newx
   player.y = newy
   moving = true
   
   -- check for exit escape (when player goes off-screen through exit)
   -- check left exit (x < 0, within exit gap)
   if player.x < 0 and abs(player.y - left_exit_y) <= 16 then
    player_escaped()
    return
   end
   
   -- check right exit (x > ARENA_WIDTH, within exit gap)
   if player.x > ARENA_WIDTH and abs(player.y - right_exit_y) <= 16 then
    player_escaped()
    return
   end
   
   -- keep in bounds only if NOT in an exit gap
   local in_left_exit = (player.x <= 16 and abs(player.y - left_exit_y) <= 16)
   local in_right_exit = (player.x >= ARENA_WIDTH - 16 and abs(player.y - right_exit_y) <= 16)
   
   if not in_left_exit and not in_right_exit then
    player.x = mid(16, player.x, ARENA_WIDTH - 16)
    player.y = mid(16, player.y, ARENA_HEIGHT - 16)
   end
   
   -- animation
   if moving then
    -- start animation immediately if not already animating
    if player.anim_frame == 0 then
     player.anim_frame = 1
     player.anim_timer = 0
    else
     player.anim_timer += 1
     if player.anim_timer > 4 then
      player.anim_timer = 0
      player.anim_frame = (player.anim_frame == 1) and 2 or 1
     end
    end
   end
  else
   player.anim_frame = 0
   player.anim_timer = 0
  end
 end
 
 -- update missile
 if player.missile then
  update_player_missile()
 end
end

function fire_player_missile()
 -- create missile based on firing direction (8 directions)
 local mx, my = player.x, player.y
 local mdx, mdy = 0, 0
 
 local dir = player.fire_dir or 0
 
 -- convert direction to dx/dy
 if dir == 0 then mdx = missile_speed mdy = 0  -- right
 elseif dir == 1 then mdx = missile_speed mdy = missile_speed  -- down-right
 elseif dir == 2 then mdx = 0 mdy = missile_speed  -- down
 elseif dir == 3 then mdx = -missile_speed mdy = missile_speed  -- down-left
 elseif dir == 4 then mdx = -missile_speed mdy = 0  -- left
 elseif dir == 5 then mdx = -missile_speed mdy = -missile_speed  -- up-left
 elseif dir == 6 then mdx = 0 mdy = -missile_speed  -- up
 elseif dir == 7 then mdx = missile_speed mdy = -missile_speed  -- up-right
 end
 
 player.missile = {
  x = mx,
  y = my,
  dx = mdx,
  dy = mdy
 }
 
 sfx(0)  -- weapon sound
end

function update_player_missile()
 local m = player.missile
 m.x += m.dx
 m.y += m.dy
 
 -- check bounds
 if m.x < 0 or m.x > ARENA_WIDTH or m.y < 0 or m.y > ARENA_HEIGHT then
  player.missile = nil
  return
 end
 
 -- check wall collision at tip of missile (3 pixels ahead)
 local tip_x = m.x
 local tip_y = m.y
 if m.dx > 0 then tip_x = m.x + 3
 elseif m.dx < 0 then tip_x = m.x - 3
 end
 if m.dy > 0 then tip_y = m.y + 3
 elseif m.dy < 0 then tip_y = m.y - 3
 end
 
 if check_missile_wall_collision(tip_x, tip_y) then
  player.missile = nil
  return
 end
 
 -- check enemy collision (missile point vs enemy sprite box)
 for e in all(enemies) do
  if check_box_collision(m.x - 1, m.y - 1, 2, 2, e.x - 4, e.y - 6, 8, 12) then
   player.missile = nil
   kill_enemy(e)
   return
  end
 end
end

function player_hit()
 -- hide player sprite
 player.alive = false
 
 -- create explosion at player position
 add(explosions, {
  x = player.x,
  y = player.y,
  frame = 0,
  timer = 0
 })
 
 sfx(1)  -- explosion sound
 
 lives -= 1
 
 -- always freeze for 1 second to show explosion
 state = STATE_DEATH_FREEZE
 death_freeze_timer = 60  -- 60 frames = 1 second
end

function player_escaped()
 -- clear enemies and explosions immediately
 enemies = {}
 explosions = {}
 spawn_queue = {}
 
 -- start arena clearing animation
 clear_line = 0
 clear_timer = 0
 
 -- check if all enemies defeated
 if enemies_defeated >= total_enemies then
  -- all enemies defeated - progress to next sector
  level += 1
  next_state_after_clear = STATE_SECTOR_INTRO
 else
  -- enemies remain - replay the wave (same sector)
  next_state_after_clear = STATE_SECTOR_INTRO
 end
 
 state = STATE_ARENA_CLEAR
end

-- enemy spawning
function spawn_enemy()
 -- spawn at random edge, avoiding collisions
 local x, y
 local attempts = 0
 local safe = false
 
 repeat
  attempts += 1
  local edge = flr(rnd(4))
  
  if edge == 0 then
   x = 32
   y = 32 + rnd(ARENA_HEIGHT - 64)
  elseif edge == 1 then
   x = ARENA_WIDTH - 32
   y = 32 + rnd(ARENA_HEIGHT - 64)
  elseif edge == 2 then
   x = 32 + rnd(ARENA_WIDTH - 64)
   y = 32
  else
   x = 32 + rnd(ARENA_WIDTH - 64)
   y = ARENA_HEIGHT - 32
  end
  
  -- check if position is safe
  safe = true
  
  -- check walls
  if check_wall_collision(x, y) then
   safe = false
  end
  
  -- check player
  if safe and player and check_sprite_collision(x, y, player.x, player.y) then
   safe = false
  end
  
  -- check other enemies
  if safe then
   for e in all(enemies) do
    if check_sprite_collision(x, y, e.x, e.y) then
     safe = false
     break
    end
   end
  end
  
  -- check explosions
  if safe then
   for ex in all(explosions) do
    if check_collision(x, y, ex.x, ex.y, 12) then
     safe = false
     break
    end
   end
  end
  
 until safe or attempts > 50
 
 -- pick a random color different from arena
 local enemy_color
 repeat
  enemy_color = atari_colors[flr(rnd(#atari_colors)) + 1]
 until enemy_color != arena_color
 
 add(enemies, {
  x = x,
  y = y,
  dir = 0,
  move_timer = 0,
  anim_frame = 0,
  missile = nil,
  fire_timer = 0,
  color = enemy_color
 })
 
 sfx(2)  -- spawn sound
end

-- draw player
function draw_player()
 if not player or not player.alive then
  return
 end
 
 local spr_num = SPR_PLAYER_STAND
 
 if player.anim_frame > 0 then
  local frame_offset = player.anim_frame - 1
  
  if player.dir == 2 then  -- left
   spr_num = SPR_PLAYER_LEFT_1 + frame_offset
  elseif player.dir == 0 then  -- right
   spr_num = SPR_PLAYER_RIGHT_1 + frame_offset
  elseif player.dir == 1 or player.dir == 3 then  -- up or down
   spr_num = SPR_PLAYER_UP_1 + frame_offset
  end
 end
 
 draw_sprite(spr_num, player.x, player.y, 7)
 
 -- draw missile
 if player.missile then
  draw_missile(player.missile, 7)
 end
end

-- draw enemies
function draw_enemies()
 for e in all(enemies) do
  local spr_num = SPR_ENEMY_STAND
  
  if e.anim_frame > 0 then
   if e.dir == 2 then  -- left
    spr_num = (e.anim_frame == 1) and SPR_ENEMY_LEFT_1 or SPR_ENEMY_LEFT_2
   elseif e.dir == 0 then  -- right
    spr_num = (e.anim_frame == 1) and SPR_ENEMY_RIGHT_1 or SPR_ENEMY_RIGHT_2
   elseif e.dir == 1 or e.dir == 3 then  -- up or down
    spr_num = (e.anim_frame == 1) and SPR_ENEMY_UP_1 or SPR_ENEMY_UP_2
   end
  end
  
  draw_sprite(spr_num, e.x, e.y, e.color)
  
  -- draw missile
  if e.missile then
   draw_missile(e.missile, 8)
  end
 end
end

-- draw missile as a line
function draw_missile(m, col)
 local x1, y1, x2, y2 = m.x, m.y, m.x, m.y
 
 -- extend line based on direction
 if m.dx > 0 then x2 = m.x + 3 end
 if m.dx < 0 then x2 = m.x - 3 end
 if m.dy > 0 then y2 = m.y + 3 end
 if m.dy < 0 then y2 = m.y - 3 end
 
 line(x1, y1, x2, y2, col)
end

-- draw explosions
function draw_explosions()
 for ex in all(explosions) do
  local spr_num = SPR_EXPLOSION_1 + ex.frame
  if spr_num < SPR_EXPLOSION_8 + 1 then
   draw_sprite(spr_num, ex.x, ex.y, 9)
  end
 end
end


-- update all enemies
function update_enemies()
 for e in all(enemies) do
  update_enemy(e)
 end
end

function update_enemy(e)
 -- ai: move toward player
 e.move_timer += 1
 if e.move_timer > 15 then
  e.move_timer = 0
  
  local dist_x = player.x - e.x
  local dist_y = player.y - e.y
  
  local dx = sgn(dist_x) * enemy_speed
  local dy = sgn(dist_y) * enemy_speed
  
  local moved = false
  local newx, newy
  
  -- only try diagonal if both axes need significant movement
  local close_threshold = 2
  local close_x = (abs(dist_x) <= close_threshold)
  local close_y = (abs(dist_y) <= close_threshold)
  local try_diagonal = (not close_x and not close_y and dx != 0 and dy != 0)
  
  -- try diagonal movement first (only if not close on either axis)
  if try_diagonal then
   newx = e.x + dx
   newy = e.y + dy
   if not check_wall_collision(newx, newy) then
    -- check collision with other enemies
    local enemy_collision = false
    for other in all(enemies) do
     if other != e and check_sprite_collision(newx, newy, other.x, other.y) then
      kill_enemy(e)
      kill_enemy(other)
      enemy_collision = true
      break
     end
    end
    -- check collision with explosions
    if not enemy_collision then
     for ex in all(explosions) do
      if check_sprite_collision(newx, newy, ex.x, ex.y) then
       kill_enemy(e)
       return
      end
     end
    end
    if not enemy_collision then
     e.x = newx
     e.y = newy
     e.dir = (dx < 0) and 2 or 0  -- use horizontal sprite for diagonal
     moved = true
    else
     return
    end
   end
  end
  
  -- if diagonal failed or not needed, try horizontal (if not already aligned)
  if not moved and dx != 0 and not close_x then
   newx = e.x + dx
   newy = e.y
   if not check_wall_collision(newx, newy) then
    -- check collision with other enemies
    local enemy_collision = false
    for other in all(enemies) do
     if other != e and check_sprite_collision(newx, newy, other.x, other.y) then
      kill_enemy(e)
      kill_enemy(other)
      enemy_collision = true
      break
     end
    end
    -- check collision with explosions
    if not enemy_collision then
     for ex in all(explosions) do
      if check_sprite_collision(newx, newy, ex.x, ex.y) then
       kill_enemy(e)
       return
      end
     end
    end
    if not enemy_collision then
     e.x = newx
     e.dir = (dx < 0) and 2 or 0  -- left or right
     moved = true
    else
     return
    end
   end
  end
  
  -- if still not moved, try vertical (if not already aligned)
  if not moved and dy != 0 and not close_y then
   newx = e.x
   newy = e.y + dy
   if not check_wall_collision(newx, newy) then
    -- check collision with other enemies
    local enemy_collision = false
    for other in all(enemies) do
     if other != e and check_sprite_collision(newx, newy, other.x, other.y) then
      kill_enemy(e)
      kill_enemy(other)
      enemy_collision = true
      break
     end
    end
    -- check collision with explosions
    if not enemy_collision then
     for ex in all(explosions) do
      if check_sprite_collision(newx, newy, ex.x, ex.y) then
       kill_enemy(e)
       return
      end
     end
    end
    if not enemy_collision then
     e.y = newy
     e.dir = (dy < 0) and 3 or 1  -- up or down
     moved = true
    else
     return
    end
   end
  end
  
  -- animate when moving, reset to stationary when blocked
  if moved then
   -- toggle animation frame on each move
   e.anim_frame = (e.anim_frame == 1) and 2 or 1
  else
   -- stationary - reset animation frame
   e.anim_frame = 0
  end
 end
 
 -- firing logic with frequency check (OUTSIDE move_timer block)
 if enemy_fire_freq > 0 then  -- sector 1 has freq=0 (no firing)
  e.fire_timer += 1
  
  if e.fire_timer >= enemy_fire_freq then
   e.fire_timer = 0
   -- random chance to fire (25% like original)
   if rnd(1) < 0.25 and e.missile == nil then
    fire_enemy_missile(e)
   end
  end
 end
 
 -- update missile
 if e.missile then
  update_enemy_missile(e)
 end
 
 -- check collision with player - both die
 if check_sprite_collision(e.x, e.y, player.x, player.y) then
  kill_enemy(e)
  player_hit()
 end
end

function fire_enemy_missile(e)
 -- aim at player in one of 8 directions
 local dx = player.x - e.x
 local dy = player.y - e.y
 
 -- normalize to determine primary direction
 local abs_dx = abs(dx)
 local abs_dy = abs(dy)
 
 -- determine which of 8 directions is closest
 local mdx, mdy = 0, 0
 
 if abs_dx > abs_dy * 2.5 then
  -- primarily horizontal
  if dx > 0 then
   mdx = missile_speed mdy = 0  -- right
  else
   mdx = -missile_speed mdy = 0  -- left
  end
 elseif abs_dy > abs_dx * 2.5 then
  -- primarily vertical
  if dy > 0 then
   mdx = 0 mdy = missile_speed  -- down
  else
   mdx = 0 mdy = -missile_speed  -- up
  end
 else
  -- diagonal
  if dx > 0 and dy > 0 then
   mdx = missile_speed mdy = missile_speed  -- down-right
  elseif dx < 0 and dy > 0 then
   mdx = -missile_speed mdy = missile_speed  -- down-left
  elseif dx < 0 and dy < 0 then
   mdx = -missile_speed mdy = -missile_speed  -- up-left
  else
   mdx = missile_speed mdy = -missile_speed  -- up-right
  end
 end
 
 e.missile = {
  x = e.x,
  y = e.y,
  dx = mdx,
  dy = mdy
 }
 
 sfx(0)  -- weapon sound
end

function update_enemy_missile(e)
 local m = e.missile
 m.x += m.dx
 m.y += m.dy
 
 -- check bounds
 if m.x < 0 or m.x > ARENA_WIDTH or m.y < 0 or m.y > ARENA_HEIGHT then
  e.missile = nil
  return
 end
 
 -- check wall collision at tip of missile (3 pixels ahead)
 local tip_x = m.x
 local tip_y = m.y
 if m.dx > 0 then tip_x = m.x + 3
 elseif m.dx < 0 then tip_x = m.x - 3
 end
 if m.dy > 0 then tip_y = m.y + 3
 elseif m.dy < 0 then tip_y = m.y - 3
 end
 
 if check_missile_wall_collision(tip_x, tip_y) then
  e.missile = nil
  return
 end
 
 -- check player collision (missile point vs player sprite box)
 if check_box_collision(m.x - 1, m.y - 1, 2, 2, player.x - 4, player.y - 6, 8, 12) then
  e.missile = nil
  player_hit()
  return
 end
 
 -- check collision with other enemies (missile point vs enemy sprite box)
 for other in all(enemies) do
  if other != e and check_box_collision(m.x - 1, m.y - 1, 2, 2, other.x - 4, other.y - 6, 8, 12) then
   e.missile = nil
   kill_enemy(other)
   return
  end
 end
end

function kill_enemy(e)
 -- create explosion at enemy position
 add(explosions, {
  x = e.x,
  y = e.y,
  frame = 0,
  timer = 0
 })
 
 del(enemies, e)
 score += 100
 enemies_defeated += 1
 sfx(1)  -- explosion sound
 
 -- queue new enemy spawn if more remain (1 second delay)
 if enemies_defeated < total_enemies then
  add(spawn_queue, {timer = 60})  -- 60 frames = 1 second
 end
end
