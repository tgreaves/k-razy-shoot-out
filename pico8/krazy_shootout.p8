pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- k-razy shoot-out
-- pico-8 clone
-- based on atari 5200 disassembly
-- by tristan greaves

-- game states
state_title=0
state_sector_intro=1
state_game=2
state_death_freeze=3
state_gameover=4

-- game constants (from disassembly)
max_enemies=3
player_speed=1

-- difficulty table (from $bbe4)
-- format: {spawn_limit, fire_freq, speed, anim_timing}
difficulty_table={
 {14,0,2,21},   -- sector 1 (tutorial)
 {20,96,2,18},  -- sector 2
 {26,64,3,8},   -- sector 3
 {29,48,4,6},   -- sector 4
 {32,37,10,4},  -- sector 5
 {36,19,80,3},  -- sector 6
 {54,6,255,1}   -- sector 7
}

-- difficulty variables
enemy_fire_freq=0
enemy_speed=0.5
missile_speed=2
anim_timing=0

-- atari 5200 color palette (excluding white/black and dark colors)
-- pico-8 colors: 8=red, 9=orange, 10=yellow, 11=green, 
--                12=light blue, 13=indigo, 14=pink, 15=peach
atari_colors={8,9,10,11,12,13,14,15}

-- color variables
arena_color=5
enemy_colors={}

function _init()
 state=state_title
 score=0
 level=1
 lives=3
 sector_intro_timer=0
 death_freeze_timer=0
end

function _update()
 if state==state_title then
  update_title()
 elseif state==state_sector_intro then
  update_sector_intro()
 elseif state==state_game then
  update_game()
 elseif state==state_death_freeze then
  update_death_freeze()
 elseif state==state_gameover then
  update_gameover()
 end
end

function _draw()
 cls()
 if state==state_title then
  draw_title()
 elseif state==state_sector_intro then
  draw_sector_intro()
 elseif state==state_game then
  draw_game()
 elseif state==state_death_freeze then
  draw_game()  -- show frozen game state
 elseif state==state_gameover then
  draw_gameover()
 end
end

-- title screen
function update_title()
 if btnp(4) or btnp(5) then
  state=state_sector_intro
  sector_intro_timer=0
 end
end

function draw_title()
 print("k-razy shoot-out",20,40,7)
 print("press ❎ to start",20,60,6)
 print("based on atari 5200",16,100,5)
 print("original by k.dreyer",14,108,5)
end

-- sector intro screen
function update_sector_intro()
 sector_intro_timer+=1
 if sector_intro_timer>=60 then  -- 1 second at 60fps
  state=state_game
  init_game()
 end
end

function draw_sector_intro()
 cls()
 -- large text in center
 local text="entering sector "..level
 print(text,32,60,7)
end

-- game initialization
function init_game()
 -- randomize arena color for this sector
 arena_color=atari_colors[flr(rnd(#atari_colors))+1]
 
 init_arena()  -- create arena first
 load_sector_difficulty()  -- load difficulty params
 init_player()  -- then spawn player (needs arena for collision check)
 init_enemies()
 explosions={}
 enemies_defeated=0
 time_remaining=77
 time_counter=0
 spawn_queue={}  -- queue of pending enemy spawns
end

-- load difficulty parameters
function load_sector_difficulty()
 -- clamp sector to 1-7
 local sector=mid(1,level,7)
 
 local params=difficulty_table[sector]
 
 total_enemies=params[1]      -- spawn limit
 enemy_fire_freq=params[2]    -- firing frequency
 local game_speed=params[3]   -- speed multiplier
 anim_timing=params[4]        -- animation timing
 
 -- scale speeds based on game_speed parameter
 -- use integer speeds to avoid position drift/jitter
 -- sectors 1-2: speed=2 (base speed)
 -- sector 3: speed=3 (slightly faster)
 -- sector 4: speed=4 (faster)
 -- sector 5: speed=10 (much faster)
 -- sector 6: speed=80 (very fast)
 -- sector 7: speed=255 (maximum)
 if game_speed<=2 then
  enemy_speed=1
  missile_speed=2
 elseif game_speed<=3 then
  enemy_speed=1
  missile_speed=2
 elseif game_speed<=4 then
  enemy_speed=1
  missile_speed=2
 elseif game_speed<=10 then
  enemy_speed=1
  missile_speed=3
 elseif game_speed<=80 then
  enemy_speed=2
  missile_speed=3
 else
  enemy_speed=2
  missile_speed=4
 end
end

-- player (from disassembly $75-$7A)
function init_player()
 -- find safe spawn position (not on a wall)
 local spawn_x, spawn_y
 local attempts=0
 repeat
  spawn_x=32+flr(rnd(64))  -- center area
  spawn_y=32+flr(rnd(64))
  attempts+=1
 until not check_wall_collision(spawn_x,spawn_y) or attempts>50
 
 -- fallback to center if no safe spot found
 if attempts>50 then
  spawn_x=64
  spawn_y=64
 end
 
 player={
  x=spawn_x,
  y=spawn_y,
  sprite=1,
  dir=0, -- 0=right,1=down,2=left,3=up (for animation)
  fire_dir=0, -- 0-7 for 8-way firing
  anim_frame=0,
  anim_timer=0,
  missile=nil,
  alive=true
 }
end

function update_player()
 -- check if firing button is pressed
 local firing=btn(4) or btn(5)
 
 -- check direction input
 local dx,dy=0,0
 if btn(0) then dx=-1 end
 if btn(1) then dx=1 end
 if btn(2) then dy=-1 end
 if btn(3) then dy=1 end
 
 local dir_pressed=dx!=0 or dy!=0
 
 -- if firing, update aim direction but don't move
 if firing then
  if dir_pressed then
   -- update firing direction based on current input
   if dx<0 and dy<0 then
    player.fire_dir=5 -- up-left
   elseif dx>0 and dy<0 then
    player.fire_dir=7 -- up-right
   elseif dx<0 and dy>0 then
    player.fire_dir=3 -- down-left
   elseif dx>0 and dy>0 then
    player.fire_dir=1 -- down-right
   elseif dx<0 then
    player.fire_dir=4 -- left
   elseif dx>0 then
    player.fire_dir=0 -- right
   elseif dy<0 then
    player.fire_dir=6 -- up
   elseif dy>0 then
    player.fire_dir=2 -- down
   end
   
   -- fire missile
   if player.missile==nil then
    fire_player_missile()
   end
  end
 else
  -- not firing, can move
  if dir_pressed then
   local moving=false
   local move_dx=dx*player_speed
   local move_dy=dy*player_speed
   
   -- update visual direction
   if dx<0 then
    player.dir=2 -- left
   elseif dx>0 then
    player.dir=0 -- right
   elseif dy!=0 then
    player.dir=(dy<0) and 3 or 1 -- up or down
   end
   
   -- calculate new position
   local newx=player.x+move_dx
   local newy=player.y+move_dy
   
   -- collision check with walls - instant death
   if check_wall_collision(newx,newy) then
    player_hit()
    return
   end
   
   -- collision check with enemies - both die
   for e in all(enemies) do
    if check_sprite_collision(newx,newy,e.x,e.y) then
     kill_enemy(e)
     player_hit()
     return
    end
   end
   
   -- collision check with explosions - player dies
   for ex in all(explosions) do
    if check_sprite_collision(newx,newy,ex.x,ex.y) then
     player_hit()
     return
    end
   end
   
   -- safe to move
   player.x=newx
   player.y=newy
   moving=true
   
   -- keep in bounds
   player.x=mid(8,player.x,120)
   player.y=mid(8,player.y,120)
   
   -- animation
   if moving then
    -- start animation immediately if not already animating
    if player.anim_frame==0 then
     player.anim_frame=1
     player.anim_timer=0
    else
     player.anim_timer+=1
     if player.anim_timer>4 then
      player.anim_timer=0
      player.anim_frame=(player.anim_frame==1) and 2 or 1  -- toggle between 1 and 2
     end
    end
   end
  else
   player.anim_frame=0
   player.anim_timer=0
  end
 end
 
 -- update missile
 if player.missile then
  update_player_missile()
 end
end

function fire_player_missile()
 -- create missile based on firing direction (8 directions)
 local mx,my=player.x,player.y
 local mdx,mdy=0,0
 
 local dir=player.fire_dir or 0
 
 -- convert direction to dx/dy
 if dir==0 then mdx=missile_speed mdy=0 -- right
 elseif dir==1 then mdx=missile_speed mdy=missile_speed -- down-right
 elseif dir==2 then mdx=0 mdy=missile_speed -- down
 elseif dir==3 then mdx=-missile_speed mdy=missile_speed -- down-left
 elseif dir==4 then mdx=-missile_speed mdy=0 -- left
 elseif dir==5 then mdx=-missile_speed mdy=-missile_speed -- up-left
 elseif dir==6 then mdx=0 mdy=-missile_speed -- up
 elseif dir==7 then mdx=missile_speed mdy=-missile_speed -- up-right
 end
 
 player.missile={
  x=mx,
  y=my,
  dx=mdx,
  dy=mdy
 }
 
 sfx(0) -- weapon sound
end

function update_player_missile()
 local m=player.missile
 m.x+=m.dx
 m.y+=m.dy
 
 -- check bounds
 if m.x<0 or m.x>128 or m.y<0 or m.y>128 then
  player.missile=nil
  return
 end
 
 -- check wall collision at tip of missile (3 pixels ahead)
 local tip_x=m.x
 local tip_y=m.y
 if m.dx>0 then tip_x=m.x+3
 elseif m.dx<0 then tip_x=m.x-3
 end
 if m.dy>0 then tip_y=m.y+3
 elseif m.dy<0 then tip_y=m.y-3
 end
 
 if check_missile_wall_collision(tip_x,tip_y) then
  player.missile=nil
  return
 end
 
 -- check enemy collision (missile point vs enemy sprite box)
 for e in all(enemies) do
  if check_box_collision(m.x-1,m.y-1,2,2,e.x-4,e.y-6,8,12) then
   player.missile=nil
   kill_enemy(e)
   return
  end
 end
end

function draw_player()
 -- only draw if alive
 if not player.alive then
  return
 end
 
 -- sprite mapping (sprites 0-6 in PICO-8):
 -- 0: stationary
 -- 1: walking left 1
 -- 2: walking left 2
 -- 3: walking right 1
 -- 4: walking right 2
 -- 5: walking up/down 1
 -- 6: walking up/down 2
 
 local spr_num=0 -- default stationary
 
 -- only show walking animation if anim_frame > 0
 if player.anim_frame>0 then
  -- anim_frame is 1 or 2, convert to 0 or 1 for sprite offset
  local frame_offset=player.anim_frame-1
  -- determine sprite based on direction and animation
  if player.dir==2 then -- left
   spr_num=1+frame_offset
  elseif player.dir==0 then -- right
   spr_num=3+frame_offset
  elseif player.dir==1 or player.dir==3 then -- up or down
   spr_num=5+frame_offset
  end
 end
 
 -- draw player sprite (8x12 pixels)
 -- use 1,2 to render 2 sprite slots vertically (8x16) which includes our 12 rows
 spr(spr_num,player.x-4,player.y-8,1,2)
 
 -- draw missile as line
 if player.missile then
  local m=player.missile
  local x1,y1,x2,y2=m.x,m.y,m.x,m.y
  
  -- extend line based on direction (support diagonals)
  if m.dx>0 then x2=m.x+3 end -- right
  if m.dx<0 then x2=m.x-3 end -- left
  if m.dy>0 then y2=m.y+3 end -- down
  if m.dy<0 then y2=m.y-3 end -- up
  
  line(x1,y1,x2,y2,7)
 end
end

-- enemies (from disassembly $94-$96)
function init_enemies()
 enemies={}
 for i=1,max_enemies do
  spawn_enemy()
 end
end

function spawn_enemy()
 -- spawn at random edge, avoiding collisions
 local x,y
 local attempts=0
 local safe=false
 
 repeat
  attempts+=1
  local edge=flr(rnd(4))
  if edge==0 then 
   x=16 
   y=16+rnd(96)
  elseif edge==1 then 
   x=112 
   y=16+rnd(96)
  elseif edge==2 then 
   x=16+rnd(96) 
   y=16
  else 
   x=16+rnd(96) 
   y=112
  end
  
  -- check if position is safe
  safe=true
  
  -- check walls
  if check_wall_collision(x,y) then
   safe=false
  end
  
  -- check player (use larger safety distance)
  if safe and check_sprite_collision(x,y,player.x,player.y) then
   safe=false
  end
  
  -- check other enemies (use larger safety distance)
  if safe then
   for e in all(enemies) do
    if check_sprite_collision(x,y,e.x,e.y) then
     safe=false
     break
    end
   end
  end
  
  -- check explosions (use circle collision for safety)
  if safe then
   for ex in all(explosions) do
    if check_collision(x,y,ex.x,ex.y,12) then
     safe=false
     break
    end
   end
  end
  
 until safe or attempts>50
 
 -- if we couldn't find a safe spot after 50 tries, spawn anyway
 -- (better than blocking the game)
 
 -- pick a random color different from arena
 local enemy_color
 repeat
  enemy_color=atari_colors[flr(rnd(#atari_colors))+1]
 until enemy_color!=arena_color
 
 add(enemies,{
  x=x,
  y=y,
  dir=0, -- 0=right,1=down,2=left,3=up
  move_timer=0,
  anim_frame=0,
  missile=nil,
  fire_timer=0,  -- firing timer
  color=enemy_color
 })
end

function update_enemies()
 for e in all(enemies) do
  update_enemy(e)
 end
end

function update_enemy(e)
 -- ai: move toward player
 e.move_timer+=1
 if e.move_timer>15 then
  e.move_timer=0
  
  local dist_x=player.x-e.x
  local dist_y=player.y-e.y
  
  local dx=sgn(dist_x)*enemy_speed
  local dy=sgn(dist_y)*enemy_speed
  
  local moved=false
  local newx,newy
  
  -- only try diagonal if both axes need significant movement
  -- if close on one axis (within 2 pixels), skip diagonal and use single-axis
  local close_threshold=2
  local close_x=(abs(dist_x)<=close_threshold)
  local close_y=(abs(dist_y)<=close_threshold)
  local try_diagonal=(not close_x and not close_y and dx!=0 and dy!=0)
  
  -- try diagonal movement first (only if not close on either axis)
  if try_diagonal then
   newx=e.x+dx
   newy=e.y+dy
   if not check_wall_collision(newx,newy) then
    -- check collision with other enemies
    local enemy_collision=false
    for other in all(enemies) do
     if other!=e and check_sprite_collision(newx,newy,other.x,other.y) then
      kill_enemy(e)
      kill_enemy(other)
      enemy_collision=true
      break
     end
    end
    -- check collision with explosions
    if not enemy_collision then
     for ex in all(explosions) do
      if check_sprite_collision(newx,newy,ex.x,ex.y) then
       kill_enemy(e)
       return
      end
     end
    end
    if not enemy_collision then
     e.x=newx
     e.y=newy
     e.dir=(dx<0) and 2 or 0 -- use horizontal sprite for diagonal
     moved=true
    else
     return
    end
   end
  end
  
  -- if diagonal failed or not needed, try horizontal (if not already aligned)
  if not moved and dx!=0 and not close_x then
   newx=e.x+dx
   newy=e.y
   if not check_wall_collision(newx,newy) then
    -- check collision with other enemies
    local enemy_collision=false
    for other in all(enemies) do
     if other!=e and check_sprite_collision(newx,newy,other.x,other.y) then
      kill_enemy(e)
      kill_enemy(other)
      enemy_collision=true
      break
     end
    end
    -- check collision with explosions
    if not enemy_collision then
     for ex in all(explosions) do
      if check_sprite_collision(newx,newy,ex.x,ex.y) then
       kill_enemy(e)
       return
      end
     end
    end
    if not enemy_collision then
     e.x=newx
     e.dir=(dx<0) and 2 or 0 -- left or right
     moved=true
    else
     return
    end
   end
  end
  
  -- if still not moved, try vertical (if not already aligned)
  if not moved and dy!=0 and not close_y then
   newx=e.x
   newy=e.y+dy
   if not check_wall_collision(newx,newy) then
    -- check collision with other enemies
    local enemy_collision=false
    for other in all(enemies) do
     if other!=e and check_sprite_collision(newx,newy,other.x,other.y) then
      kill_enemy(e)
      kill_enemy(other)
      enemy_collision=true
      break
     end
    end
    -- check collision with explosions
    if not enemy_collision then
     for ex in all(explosions) do
      if check_sprite_collision(newx,newy,ex.x,ex.y) then
       kill_enemy(e)
       return
      end
     end
    end
    if not enemy_collision then
     e.y=newy
     e.dir=(dy<0) and 3 or 1 -- up or down
     moved=true
    else
     return
    end
   end
  end
  
  -- animate when moving, reset to stationary when blocked
  if moved then
   -- toggle animation frame on each move
   e.anim_frame=(e.anim_frame==1) and 2 or 1
  else
   -- stationary - reset animation frame
   e.anim_frame=0
  end
 end
 
 -- firing logic with frequency check (OUTSIDE move_timer block)
 if enemy_fire_freq>0 then  -- sector 1 has freq=0 (no firing)
  e.fire_timer+=1
  
  if e.fire_timer>=enemy_fire_freq then
   e.fire_timer=0
   -- random chance to fire (25% like original)
   if rnd(1)<0.25 and e.missile==nil then
    fire_enemy_missile(e)
   end
  end
 end
 
 -- update missile
 if e.missile then
  update_enemy_missile(e)
 end
 
 -- check collision with player - both die
 if check_sprite_collision(e.x,e.y,player.x,player.y) then
  kill_enemy(e)
  player_hit()
 end
end

function fire_enemy_missile(e)
 -- aim at player in one of 8 directions
 local dx=player.x-e.x
 local dy=player.y-e.y
 
 -- normalize to determine primary direction
 local abs_dx=abs(dx)
 local abs_dy=abs(dy)
 
 -- determine which of 8 directions is closest
 local mdx,mdy=0,0
 
 if abs_dx>abs_dy*2.5 then
  -- primarily horizontal
  if dx>0 then
   mdx=missile_speed mdy=0 -- right
  else
   mdx=-missile_speed mdy=0 -- left
  end
 elseif abs_dy>abs_dx*2.5 then
  -- primarily vertical
  if dy>0 then
   mdx=0 mdy=missile_speed -- down
  else
   mdx=0 mdy=-missile_speed -- up
  end
 else
  -- diagonal
  if dx>0 and dy>0 then
   mdx=missile_speed mdy=missile_speed -- down-right
  elseif dx<0 and dy>0 then
   mdx=-missile_speed mdy=missile_speed -- down-left
  elseif dx<0 and dy<0 then
   mdx=-missile_speed mdy=-missile_speed -- up-left
  else
   mdx=missile_speed mdy=-missile_speed -- up-right
  end
 end
 
 e.missile={
  x=e.x,
  y=e.y,
  dx=mdx,
  dy=mdy
 }
 
 sfx(0) -- weapon sound
end

function update_enemy_missile(e)
 local m=e.missile
 m.x+=m.dx
 m.y+=m.dy
 
 -- check bounds
 if m.x<0 or m.x>128 or m.y<0 or m.y>128 then
  e.missile=nil
  return
 end
 
 -- check wall collision at tip of missile (3 pixels ahead)
 local tip_x=m.x
 local tip_y=m.y
 if m.dx>0 then tip_x=m.x+3
 elseif m.dx<0 then tip_x=m.x-3
 end
 if m.dy>0 then tip_y=m.y+3
 elseif m.dy<0 then tip_y=m.y-3
 end
 
 if check_missile_wall_collision(tip_x,tip_y) then
  e.missile=nil
  return
 end
 
 -- check player collision (missile point vs player sprite box)
 if check_box_collision(m.x-1,m.y-1,2,2,player.x-4,player.y-6,8,12) then
  e.missile=nil
  player_hit()
  return
 end
 
 -- check collision with other enemies (missile point vs enemy sprite box)
 for other in all(enemies) do
  if other!=e and check_box_collision(m.x-1,m.y-1,2,2,other.x-4,other.y-6,8,12) then
   e.missile=nil
   kill_enemy(other)
   return
  end
 end
end

function kill_enemy(e)
 -- create explosion at enemy position
 add(explosions,{
  x=e.x,
  y=e.y,
  frame=0,
  timer=0
 })
 
 del(enemies,e)
 score+=100
 enemies_defeated+=1
 sfx(2) -- explosion sound
 
 -- queue new enemy spawn if more remain (1 second delay)
 if enemies_defeated<total_enemies then
  add(spawn_queue,{timer=60})  -- 60 frames = 1 second
 end
 
 -- check level complete
 if enemies_defeated>=total_enemies and #enemies==0 then
  level+=1
  state=state_sector_intro
  sector_intro_timer=0
 end
end

function draw_enemies()
 for e in all(enemies) do
  -- sprite mapping (sprites 7-13):
  -- 7: stationary
  -- 8: walking left 1
  -- 9: walking left 2
  -- 10: walking right 1
  -- 11: walking right 2
  -- 12: walking up/down 1
  -- 13: walking up/down 2
  
  local spr_num=7 -- default stationary
  
  -- only show walking animation if anim_frame > 0
  -- (anim_frame is reset to 0 when stationary)
  if e.anim_frame>0 then
   -- determine sprite based on direction and animation
   -- anim_frame is 1 or 2, we need to map to correct sprite indices
   if e.dir==2 then -- left
    spr_num=(e.anim_frame==1) and 8 or 9
   elseif e.dir==0 then -- right
    spr_num=(e.anim_frame==1) and 10 or 11
   elseif e.dir==1 or e.dir==3 then -- up or down
    spr_num=(e.anim_frame==1) and 12 or 13
   end
  end
  
  -- swap color 8 (red) to enemy's color
  pal(8,e.color)
  
  -- draw enemy sprite (8x12 pixels)
  -- use 1,2 to render 2 sprite slots vertically (8x16) which includes our 12 rows
  spr(spr_num,e.x-4,e.y-8,1,2)
  
  -- reset palette
  pal()
  
  -- draw missile as line
  if e.missile then
   local m=e.missile
   local x1,y1,x2,y2=m.x,m.y,m.x,m.y
   
   -- extend line based on direction
   if m.dx>0 then x2=m.x+3 -- right
   elseif m.dx<0 then x2=m.x-3 -- left
   end
   if m.dy>0 then y2=m.y+3 -- down
   elseif m.dy<0 then y2=m.y-3 -- up
   end
   
   line(x1,y1,x2,y2,8)
  end
 end
end

function player_hit()
 -- hide player sprite
 player.alive=false
 
 -- create explosion at player position
 add(explosions,{
  x=player.x,
  y=player.y,
  frame=0,
  timer=0
 })
 
 sfx(2) -- explosion sound
 
 lives-=1
 
 -- always freeze for 1 second to show explosion
 state=state_death_freeze
 death_freeze_timer=60  -- 60 frames = 1 second
end

-- death freeze state
function update_death_freeze()
 -- only update explosions during freeze
 update_explosions()
 
 death_freeze_timer-=1
 if death_freeze_timer<=0 then
  if lives<=0 then
   -- game over after freeze
   state=state_gameover
  else
   -- respawn everything except arena
   init_player()
   
   -- clear all enemies and respawn
   enemies={}
   for i=1,max_enemies do
    spawn_enemy()
   end
   
   -- clear spawn queue
   spawn_queue={}
   
   -- reset enemy defeat counter but keep total
   enemies_defeated=0
   
   -- resume game
   state=state_game
  end
 end
end

-- arena generation
function init_arena()
 arena={}
 
 -- random exit positions (0-4 for 5 options)
 local left_exit_pos=flr(rnd(5))
 local right_exit_pos=flr(rnd(5))
 
 -- calculate exit y positions
 local left_exit_y=20+left_exit_pos*20
 local right_exit_y=20+right_exit_pos*20
 
 -- top wall
 for x=0,124,4 do
  add(arena,{x=x,y=8})
 end
 
 -- bottom wall
 for x=0,124,4 do
  add(arena,{x=x,y=116})
 end
 
 -- left wall with exit gap
 for y=12,112,4 do
  if y<left_exit_y-8 or y>left_exit_y+8 then
   add(arena,{x=0,y=y})
  end
 end
 
 -- right wall with exit gap
 for y=12,112,4 do
  if y<right_exit_y-8 or y>right_exit_y+8 then
   add(arena,{x=124,y=y})
  end
 end
 
 -- track occupied grid cells
 local occupied={}
 for gx=0,7 do
  occupied[gx]={}
  for gy=0,6 do
   occupied[gx][gy]=false
  end
 end
 
 -- helper to safely mark cell
 function mark_cell(gx,gy)
  if gx>=0 and gx<=7 and gy>=0 and gy<=6 then
   occupied[gx][gy]=true
  end
 end
 
 -- add random interior walls
 -- use systematic placement for better coverage
 local num_walls=4+flr(rnd(2))  -- 4-5 walls (reduced to ensure gaps)
 local attempts=0
 local placed=0
 
 -- divide arena into zones and place walls in different zones
 local zones={{1,2,1,2},{3,4,1,2},{1,2,3,4},{3,4,3,4}}
 local zone_idx=1
 
 while placed<num_walls and attempts<50 do
  attempts+=1
  
  local wall_type=flr(rnd(3))
  
  -- try to place in current zone first, then random
  local grid_x,grid_y
  if zone_idx<=#zones and rnd(1)<0.7 then
   local zone=zones[zone_idx]
   grid_x=zone[1]+flr(rnd(zone[2]-zone[1]+1))
   grid_y=zone[3]+flr(rnd(zone[4]-zone[3]+1))
   zone_idx+=1
  else
   grid_x=1+flr(rnd(6))
   grid_y=1+flr(rnd(5))
  end
  
  if not occupied[grid_x][grid_y] then
   local x=grid_x*16
   local y=grid_y*16+8
   
   if wall_type==0 then
    -- vertical wall
    local height=16+flr(rnd(3))*8
    local cells=flr(height/16)
    
    -- check all cells this wall will occupy
    local can_place=true
    for c=0,cells do
     if grid_y+c>6 or occupied[grid_x][grid_y+c] then
      can_place=false
      break
     end
    end
    
    if can_place then
     -- place wall (single block wide)
     for dy=0,height,4 do
      if y+dy<=112 then
       add(arena,{x=x,y=y+dy})
      end
     end
     -- mark all cells and buffers
     for c=0,cells do
      mark_cell(grid_x,grid_y+c)
      mark_cell(grid_x-1,grid_y+c)  -- left buffer
      mark_cell(grid_x+1,grid_y+c)  -- right buffer
     end
     placed+=1
    end
    
   elseif wall_type==1 then
    -- horizontal wall
    local width=16+flr(rnd(3))*8
    local cells=flr(width/16)
    
    -- check all cells this wall will occupy
    local can_place=true
    for c=0,cells do
     if grid_x+c>7 or occupied[grid_x+c][grid_y] then
      can_place=false
      break
     end
    end
    
    if can_place then
     -- place wall (single block tall)
     for dx=0,width,4 do
      if x+dx<=120 then
       add(arena,{x=x+dx,y=y})
      end
     end
     -- mark all cells and buffers
     for c=0,cells do
      mark_cell(grid_x+c,grid_y)
      mark_cell(grid_x+c,grid_y-1)  -- top buffer
      mark_cell(grid_x+c,grid_y+1)  -- bottom buffer
     end
     placed+=1
    end
    
   else
    -- l-shape wall (can connect to other walls at right angles)
    local size=12+flr(rnd(2))*8
    local dir=flr(rnd(4))
    
    -- place wall
    if dir==0 then
     for d=0,size,4 do
      if y+d<=112 then add(arena,{x=x,y=y+d}) end
      if x+d<=120 then add(arena,{x=x+d,y=y}) end
     end
    elseif dir==1 then
     for d=0,size,4 do
      if y+d<=112 then add(arena,{x=x,y=y+d}) end
      if x-d>=8 then add(arena,{x=x-d,y=y}) end
     end
    elseif dir==2 then
     for d=0,size,4 do
      if y-d>=12 then add(arena,{x=x,y=y-d}) end
      if x+d<=120 then add(arena,{x=x+d,y=y}) end
     end
    else
     for d=0,size,4 do
      if y-d>=12 then add(arena,{x=x,y=y-d}) end
      if x-d>=8 then add(arena,{x=x-d,y=y}) end
     end
    end
    -- only mark center cell (allow L-shapes to connect to other walls)
    mark_cell(grid_x,grid_y)
    placed+=1
   end
  end
 end
end

-- collision detection
-- collision radii constants
collision_radius_player=4
collision_radius_enemy=4
collision_radius_missile=2
collision_radius_wall=2

-- circle collision (for general use)
function check_collision(x1,y1,x2,y2,dist)
 local dx=x1-x2
 local dy=y1-y2
 -- use squared distance to avoid sqrt
 return (dx*dx+dy*dy)<(dist*dist)
end

-- box collision (more accurate for sprites)
function check_box_collision(x1,y1,w1,h1,x2,y2,w2,h2)
 return x1<x2+w2 and x2<x1+w1 and y1<y2+h2 and y2<y1+h1
end

-- sprite collision (8x12 sprites)
function check_sprite_collision(x1,y1,x2,y2)
 -- sprites are 8x12, centered at x,y
 -- so box is from (x-4,y-6) to (x+4,y+6)
 return check_box_collision(x1-4,y1-6,8,12,x2-4,y2-6,8,12)
end

function check_wall_collision(x,y)
 -- check 4x4 walls with proper box collision
 for w in all(arena) do
  -- entity is 8x12 sprite centered at x,y
  -- sprite box is from (x-4,y-6) to (x+4,y+6)
  -- wall is 4x4 at w.x,w.y
  if check_box_collision(x-4,y-6,8,12,w.x,w.y,4,4) then
   return true
  end
 end
 return false
end

function check_missile_wall_collision(x,y)
 -- check missile (single point) against walls
 for w in all(arena) do
  -- missile is a point at x,y
  -- wall is 4x4 at w.x,w.y
  if x>=w.x and x<w.x+4 and y>=w.y and y<w.y+4 then
   return true
  end
 end
 return false
end

function draw_arena()
 for w in all(arena) do
  rectfill(w.x,w.y,w.x+3,w.y+3,arena_color)
 end
end

-- game update/draw
function update_game()
 -- debug: skip to next sector with 'n' key
 if btn(4) and btn(5) then  -- both action buttons together
  level+=1
  if level>7 then level=7 end
  state=state_sector_intro
  sector_intro_timer=0
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
  sq.timer-=1
  if sq.timer<=0 then
   spawn_enemy()
   del(spawn_queue,sq)
  end
 end
end

function update_explosions()
 for ex in all(explosions) do
  ex.timer+=1
  if ex.timer>3 then
   ex.timer=0
   ex.frame+=1
   if ex.frame>=8 then  -- 8 frames of explosion
    del(explosions,ex)
   end
  end
 end
end


function update_timer()
 time_counter+=1
 if time_counter>=127 then
  time_counter=0
  time_remaining-=1
  
  -- check if time ran out
  if time_remaining<=2 then
   level+=1
   state=state_sector_intro
   sector_intro_timer=0
  end
 end
end

function draw_explosions()
 for ex in all(explosions) do
  -- explosion sprites are at positions 32-39 (8 frames)
  -- render as simple 8x8 sprites (no 1,2 scaling needed)
  local spr_num=32+ex.frame
  if spr_num<40 then
   spr(spr_num,ex.x-4,ex.y-4)
  end
 end
end

-- game over
function update_gameover()
 if btnp(4) or btnp(5) then
  state=state_title
  score=0
  level=1
  lives=3
 end
end

function draw_gameover()
 cls()
 print("game over",40,50,8)
 print("score:"..score,40,60,7)
 print("press ❎",40,80,6)
end


function draw_game()
 -- draw arena
 draw_arena()
 
 -- draw entities
 draw_player()
 draw_enemies()
 draw_explosions()
 
 -- draw hud
 print("score:"..score,44,120,7)
 print("sector:"..level,2,120,7)
 print("lives:"..lives,90,120,7)
 -- debug: show fire freq and enemies remaining
 print("freq:"..enemy_fire_freq,2,2,7)
 local remaining=total_enemies-enemies_defeated
 print("left:"..remaining.."/"..total_enemies,2,8,7)
 print("speed:"..enemy_speed,2,14,7)
 
 -- draw timer bar at top (LAST so nothing covers it)
 draw_timer_bar()
end

function draw_timer_bar()
 -- DEBUG: draw a bright white bar across the entire top
 rectfill(0,0,127,3,7)
 
 -- timer bar at top of screen (like original)
 local bar_segments=flr(time_remaining/4)
 local remainder=time_remaining%4
 
 -- determine color based on time remaining
 local bar_color=11 -- cyan
 if time_remaining<=26 then
  bar_color=8 -- red for critical
 elseif time_remaining<=52 then
  bar_color=9 -- orange for warning
 end
 
 -- draw filled segments (thicker bar, 4 pixels tall)
 for i=0,bar_segments-1 do
  rectfill(i*4,0,i*4+3,3,bar_color)
 end
 
 -- draw partial segment based on remainder
 if remainder>0 then
  local width=remainder
  rectfill(bar_segments*4,0,bar_segments*4+width-1,3,bar_color)
 end
end

function draw_explosions()
 for ex in all(explosions) do
  -- explosion sprites are at positions 32-39 (8 frames)
  -- render as simple 8x8 sprites (no 1,2 scaling needed)
  local spr_num=32+ex.frame
  if spr_num<40 then
   spr(spr_num,ex.x-4,ex.y-4)
  end
 end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007000000070000000700000070000000700000000700000007000088888800888888008888880088888800888888008888880088888800000000000000000
00070700000707000007070000707000007070000007070000070700000880000008800000088000000880000008800000088000000880000000000000000000
00070700000707000007070000707000007070000077070000070770888888880088888800888888888888008888880088888888888888880000000000000000
00007000000070000000700000070000000700000070700000007070808888080088880800888808808888008088880080888808808888080000000000000000
00077700070777000000770000777070007700000007770000077700808888080088880800888808808888008088880080888808808888080000000000000000
00707070007070700000770007070700007700000000707000707000808888080088880800888808808888008088880080888808808888080000000000000000
00707070000070070077770070070000007777000000707000707000808888080088880800888808808888008088880000888808808888000000000000000000
00007000000070700000700007070000000700000000700000007000808888080088880800888808808888008088880000888808808888000000000000000000
00070700000770000007700000077000000770000007070000070700008888000088880000888800008888000088880000888800008888000000000000000000
00070700007007000000770000700700007700000007077000770700008008000080080000008000008008000008000000800880088008000000000000000000
00070700007007770000707077700700070700000007000000000700008008000080080000008000008008000008000000800000000008000000000000000000
00770770077000070007770070000770007770000077000000000770088008800880880000088000008808800008800008800000000008800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000909000090009009000009000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000900000090900009000900900000900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090000009090000999990090999099000900000090900000000000000000000000000000000000000000000000000000000000000000000000000
00009000000999000099999009999999909999909009090000000000000909000000000000000000000000000000000000000000000000000000000000000000
00009000000999000099999009999999909999909009090000000000000909000000000000000000000000000000000000000000000000000000000000000000
00000000000090000009090000999990090999099000900000090900000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000900000090900009000900900000900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000909000090009009000009000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003c7503c7403c7303c7203c7103c7003c6003c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001c6501c6501c6501c6501865014650106500c6500865004650016500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003f6553f6453f6353f6253f6153f6053f5053f4053f3053f2053f1053f0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

