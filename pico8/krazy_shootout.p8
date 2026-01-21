pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- k-razy shoot-out
-- pico-8 clone
-- based on atari 5200 disassembly
-- by tristan greaves

-- game states
state_title=0
state_game=1
state_gameover=2

-- game constants (from disassembly)
max_enemies=3
player_speed=1
enemy_speed=0.5
missile_speed=2

function _init()
 state=state_title
 score=0
 level=1
 lives=3
 init_game()
end

function _update()
 if state==state_title then
  update_title()
 elseif state==state_game then
  update_game()
 elseif state==state_gameover then
  update_gameover()
 end
end

function _draw()
 cls()
 if state==state_title then
  draw_title()
 elseif state==state_game then
  draw_game()
 elseif state==state_gameover then
  draw_gameover()
 end
end

-- title screen
function update_title()
 if btnp(4) or btnp(5) then
  state=state_game
  init_game()
 end
end

function draw_title()
 print("k-razy shoot-out",20,40,7)
 print("press ❎ to start",20,60,6)
 print("based on atari 5200",16,100,5)
 print("original by k.dreyer",14,108,5)
end

-- game initialization
function init_game()
 init_player()
 init_enemies()
 init_arena()
 enemies_defeated=0
 total_enemies=10+level*2
end

-- player (from disassembly $75-$7A)
function init_player()
 player={
  x=64,
  y=64,
  sprite=1,
  dir=0, -- 0=right,1=down,2=left,3=up
  anim_frame=0,
  anim_timer=0,
  missile=nil
 }
end

function update_player()
 -- movement
 local dx,dy=0,0
 local moving=false
 
 if btn(0) then dx=-player_speed moving=true end
 if btn(1) then dx=player_speed moving=true end
 if btn(2) then dy=-player_speed moving=true end
 if btn(3) then dy=player_speed moving=true end
 
 -- update direction based on movement
 -- prioritize horizontal movement for direction
 if dx<0 then 
  player.dir=2 -- left
 elseif dx>0 then 
  player.dir=0 -- right
 elseif dy!=0 then
  -- only use vertical direction if no horizontal movement
  if dy<0 then 
   player.dir=3 -- up
  else 
   player.dir=1 -- down
  end
 end
 
 -- collision check with walls
 local newx=player.x+dx
 local newy=player.y+dy
 if not check_wall_collision(newx,newy) then
  player.x=newx
  player.y=newy
 end
 
 -- keep in bounds
 player.x=mid(8,player.x,120)
 player.y=mid(8,player.y,120)
 
 -- animation (only animate when moving)
 if moving then
  player.anim_timer+=1
  if player.anim_timer>4 then
   player.anim_timer=0
   player.anim_frame=(player.anim_frame+1)%2
  end
 else
  player.anim_frame=0
  player.anim_timer=0
 end
 
 -- firing (from disassembly $A1D8)
 if btnp(4) or btnp(5) then
  if player.missile==nil then
   fire_player_missile()
  end
 end
 
 -- update missile
 if player.missile then
  update_player_missile()
 end
end

function fire_player_missile()
 -- create missile based on direction
 local mx,my=player.x,player.y
 local mdx,mdy=0,0
 
 if player.dir==0 then mdx=missile_speed
 elseif player.dir==1 then mdy=missile_speed
 elseif player.dir==2 then mdx=-missile_speed
 elseif player.dir==3 then mdy=-missile_speed
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
 
 -- check wall collision
 if check_wall_collision(m.x,m.y) then
  player.missile=nil
  return
 end
 
 -- check enemy collision
 for e in all(enemies) do
  if check_collision(m.x,m.y,e.x,e.y,6) then
   player.missile=nil
   kill_enemy(e)
   return
  end
 end
end

function draw_player()
 -- sprite mapping (sprites 0-6 in PICO-8):
 -- 0: stationary
 -- 1: walking left 1
 -- 2: walking left 2
 -- 3: walking right 1
 -- 4: walking right 2
 -- 5: walking up/down 1
 -- 6: walking up/down 2
 
 local spr_num=0 -- default stationary
 
 -- determine sprite based on direction and animation
 if player.dir==2 then -- left
  spr_num=1+player.anim_frame
 elseif player.dir==0 then -- right
  spr_num=3+player.anim_frame
 elseif player.dir==1 or player.dir==3 then -- up or down
  spr_num=5+player.anim_frame
 end
 
 -- draw player sprite (8x12 pixels)
 spr(spr_num,player.x-4,player.y-6,1,1.5)
 
 -- draw missile
 if player.missile then
  circfill(player.missile.x,player.missile.y,1,8)
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
 -- spawn at random edge
 local x,y
 local edge=flr(rnd(4))
 if edge==0 then x=8 y=rnd(120)
 elseif edge==1 then x=120 y=rnd(120)
 elseif edge==2 then x=rnd(120) y=8
 else x=rnd(120) y=120
 end
 
 add(enemies,{
  x=x,
  y=y,
  sprite=16,
  dir=0,
  move_timer=0,
  missile=nil
 })
end

function update_enemies()
 for e in all(enemies) do
  update_enemy(e)
 end
end

function update_enemy(e)
 -- simple ai: move toward player
 e.move_timer+=1
 if e.move_timer>20 then
  e.move_timer=0
  
  local dx=sgn(player.x-e.x)
  local dy=sgn(player.y-e.y)
  
  -- try horizontal movement
  if abs(player.x-e.x)>abs(player.y-e.y) then
   if not check_wall_collision(e.x+dx*enemy_speed,e.y) then
    e.x+=dx*enemy_speed
   end
  else
   if not check_wall_collision(e.x,e.y+dy*enemy_speed) then
    e.y+=dy*enemy_speed
   end
  end
  
  -- random firing
  if rnd(1)<0.1 and e.missile==nil then
   fire_enemy_missile(e)
  end
 end
 
 -- update missile
 if e.missile then
  update_enemy_missile(e)
 end
 
 -- check collision with player
 if check_collision(e.x,e.y,player.x,player.y,6) then
  player_hit()
 end
end

function fire_enemy_missile(e)
 -- aim at player
 local dx=player.x-e.x
 local dy=player.y-e.y
 local dist=sqrt(dx*dx+dy*dy)
 
 e.missile={
  x=e.x,
  y=e.y,
  dx=dx/dist*missile_speed*0.7,
  dy=dy/dist*missile_speed*0.7
 }
 
 sfx(1) -- enemy fire sound
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
 
 -- check wall collision
 if check_wall_collision(m.x,m.y) then
  e.missile=nil
  return
 end
 
 -- check player collision
 if check_collision(m.x,m.y,player.x,player.y,4) then
  e.missile=nil
  player_hit()
  return
 end
end

function kill_enemy(e)
 del(enemies,e)
 score+=100
 enemies_defeated+=1
 sfx(2) -- explosion sound
 
 -- spawn new enemy if more remain
 if enemies_defeated<total_enemies then
  spawn_enemy()
 end
 
 -- check level complete
 if enemies_defeated>=total_enemies and #enemies==0 then
  level+=1
  init_game()
 end
end

function draw_enemies()
 for e in all(enemies) do
  -- draw enemy as simple shape (until sprites are added)
  rectfill(e.x-3,e.y-3,e.x+3,e.y+3,8)
  
  -- draw missile
  if e.missile then
   circfill(e.missile.x,e.missile.y,1,8)
  end
 end
end

function player_hit()
 lives-=1
 if lives<=0 then
  state=state_gameover
 else
  -- respawn player
  player.x=64
  player.y=64
 end
end

-- arena (from disassembly $BA74)
function init_arena()
 -- simple arena with walls
 arena={}
 
 -- outer walls
 for i=0,15 do
  add(arena,{x=i*8,y=0})
  add(arena,{x=i*8,y=120})
  add(arena,{x=0,y=i*8})
  add(arena,{x=120,y=i*8})
 end
 
 -- random interior walls
 for i=1,10 do
  local wx=flr(rnd(14))*8+8
  local wy=flr(rnd(14))*8+8
  add(arena,{x=wx,y=wy})
 end
end

function check_wall_collision(x,y)
 for w in all(arena) do
  if check_collision(x,y,w.x+4,w.y+4,6) then
   return true
  end
 end
 return false
end

function draw_arena()
 for w in all(arena) do
  rectfill(w.x,w.y,w.x+7,w.y+7,5)
 end
end

-- collision detection
function check_collision(x1,y1,x2,y2,dist)
 local dx=x1-x2
 local dy=y1-y2
 return sqrt(dx*dx+dy*dy)<dist
end

-- game update/draw
function update_game()
 update_player()
 update_enemies()
end

function draw_game()
 -- draw arena
 draw_arena()
 
 -- draw entities
 draw_player()
 draw_enemies()
 
 -- draw hud
 print("score:"..score,2,2,7)
 print("level:"..level,2,122,7)
 print("lives:"..lives,90,2,7)
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
 print("game over",40,50,8)
 print("score:"..score,40,60,7)
 print("press ❎",40,80,6)
end

__gfx__
00007000000070000000700000070000000700000007000000007000000000000000000000000000000000000000000000000000000000000000000000000000
00070700000707000007070000707000007070000007070000070700000000000000000000000000000000000000000000000000000000000000000000000000
00070700000707000007070000707000007070000077070000070770000000000000000000000000000000000000000000000000000000000000000000000000
00007000000070000000700000070000000700000070700000007070000000000000000000000000000000000000000000000000000000000000000000000000
00077700070777000000770000777070007700000007770000077700000000000000000000000000000000000000000000000000000000000000000000000000
00707070007070700000770007070700007700000000707000707000000000000000000000000000000000000000000000000000000000000000000000000000
00707070000070070077770070070000007777000000707000707000000000000000000000000000000000000000000000000000000000000000000000000000
00007000000070700000700007070000000700000000700000007000000000000000000000000000000000000000000000000000000000000000000000000000
00070700000770000007700000077000000770000007070000070700000000000000000000000000000000000000000000000000000000000000000000000000
00070700007007000000770000700700007700000007077000770700000000000000000000000000000000000000000000000000000000000000000000000000
00070700007007770000707077700700070700000007000000000700000000000000000000000000000000000000000000000000000000000000000000000000
00770770077000070007770070000770007770000077000000000770000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000c0500c0500c0500c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c050
000200001f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f0501f050
