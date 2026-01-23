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
