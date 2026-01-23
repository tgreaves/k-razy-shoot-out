-- arena generation system
-- creates random maze layouts with exits

-- wall block size (matching atari original proportions)
WALL_SIZE = 8

function init_arena()
 arena = {}
 
 -- randomize arena color for this sector
 arena_color = atari_colors[flr(rnd(#atari_colors)) + 1]
 
 -- random exit positions (0-4 for 5 options)
 local left_exit_pos = flr(rnd(5))
 local right_exit_pos = flr(rnd(5))
 
 -- calculate exit y positions and store globally
 -- exits are spaced across the arena height
 left_exit_y = 40 + left_exit_pos * 24
 right_exit_y = 40 + right_exit_pos * 24
 
 -- top wall
 for x = 0, ARENA_WIDTH - WALL_SIZE, WALL_SIZE do
  add(arena, {x = x, y = 16})
 end
 
 -- bottom wall
 for x = 0, ARENA_WIDTH - WALL_SIZE, WALL_SIZE do
  add(arena, {x = x, y = ARENA_HEIGHT - 16})
 end
 
 -- left wall with exit gap
 for y = 24, ARENA_HEIGHT - 24, WALL_SIZE do
  if y < left_exit_y - 16 or y > left_exit_y + 16 then
   add(arena, {x = 0, y = y})
  end
 end
 
 -- right wall with exit gap
 for y = 24, ARENA_HEIGHT - 24, WALL_SIZE do
  if y < right_exit_y - 16 or y > right_exit_y + 16 then
   add(arena, {x = ARENA_WIDTH - WALL_SIZE, y = y})
  end
 end
 
 -- track occupied grid cells for interior walls
 local occupied = {}
 for gx = 0, 19 do
  occupied[gx] = {}
  for gy = 0, 9 do
   occupied[gx][gy] = false
  end
 end
 
 -- helper to safely mark cell
 local function mark_cell(gx, gy)
  if gx >= 0 and gx <= 19 and gy >= 0 and gy <= 9 then
   occupied[gx][gy] = true
  end
 end
 
 -- add random interior walls
 local num_walls = 4 + flr(rnd(2))  -- 4-5 walls
 local attempts = 0
 local placed = 0
 
 -- divide arena into zones for better distribution
 local zones = {
  {2, 4, 2, 4},
  {6, 8, 2, 4},
  {2, 4, 6, 8},
  {6, 8, 6, 8}
 }
 local zone_idx = 1
 
 while placed < num_walls and attempts < 50 do
  attempts += 1
  
  local wall_type = flr(rnd(3))
  
  -- try to place in current zone first, then random
  local grid_x, grid_y
  if zone_idx <= #zones and rnd(1) < 0.7 then
   local zone = zones[zone_idx]
   grid_x = zone[1] + flr(rnd(zone[2] - zone[1] + 1))
   grid_y = zone[3] + flr(rnd(zone[4] - zone[3] + 1))
   zone_idx += 1
  else
   grid_x = 2 + flr(rnd(16))
   grid_y = 2 + flr(rnd(6))
  end
  
  if not occupied[grid_x][grid_y] then
   local x = grid_x * 16
   local y = grid_y * 16 + 16
   
   if wall_type == 0 then
    -- vertical wall
    local height = 32 + flr(rnd(3)) * 16
    local cells = flr(height / 16)
    
    local can_place = true
    for c = 0, cells do
     if grid_y + c > 9 or occupied[grid_x][grid_y + c] then
      can_place = false
      break
     end
    end
    
    if can_place then
     for dy = 0, height, WALL_SIZE do
      if y + dy <= ARENA_HEIGHT - 24 then
       add(arena, {x = x, y = y + dy})
      end
     end
     for c = 0, cells do
      mark_cell(grid_x, grid_y + c)
      mark_cell(grid_x - 1, grid_y + c)
      mark_cell(grid_x + 1, grid_y + c)
     end
     placed += 1
    end
    
   elseif wall_type == 1 then
    -- horizontal wall
    local width = 32 + flr(rnd(3)) * 16
    local cells = flr(width / 16)
    
    local can_place = true
    for c = 0, cells do
     if grid_x + c > 19 or occupied[grid_x + c][grid_y] then
      can_place = false
      break
     end
    end
    
    if can_place then
     for dx = 0, width, WALL_SIZE do
      if x + dx <= ARENA_WIDTH - 16 then
       add(arena, {x = x + dx, y = y})
      end
     end
     for c = 0, cells do
      mark_cell(grid_x + c, grid_y)
      mark_cell(grid_x + c, grid_y - 1)
      mark_cell(grid_x + c, grid_y + 1)
     end
     placed += 1
    end
    
   else
    -- L-shape wall
    local size = 24 + flr(rnd(2)) * 16
    local dir = flr(rnd(4))
    
    if dir == 0 then
     for d = 0, size, WALL_SIZE do
      if y + d <= ARENA_HEIGHT - 24 then add(arena, {x = x, y = y + d}) end
      if x + d <= ARENA_WIDTH - 16 then add(arena, {x = x + d, y = y}) end
     end
    elseif dir == 1 then
     for d = 0, size, WALL_SIZE do
      if y + d <= ARENA_HEIGHT - 24 then add(arena, {x = x, y = y + d}) end
      if x - d >= 16 then add(arena, {x = x - d, y = y}) end
     end
    elseif dir == 2 then
     for d = 0, size, WALL_SIZE do
      if y - d >= 24 then add(arena, {x = x, y = y - d}) end
      if x + d <= ARENA_WIDTH - 16 then add(arena, {x = x + d, y = y}) end
     end
    else
     for d = 0, size, WALL_SIZE do
      if y - d >= 24 then add(arena, {x = x, y = y - d}) end
      if x - d >= 16 then add(arena, {x = x - d, y = y}) end
     end
    end
    mark_cell(grid_x, grid_y)
    placed += 1
   end
  end
 end
end

function draw_arena()
 for w in all(arena) do
  rectfill(w.x, w.y, w.x + WALL_SIZE - 1, w.y + WALL_SIZE - 1, arena_color)
 end
end
