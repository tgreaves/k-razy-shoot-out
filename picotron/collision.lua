-- collision detection system

-- circle collision (for general use)
function check_collision(x1, y1, x2, y2, dist)
 local dx = x1 - x2
 local dy = y1 - y2
 return (dx * dx + dy * dy) < (dist * dist)
end

-- box collision (more accurate for sprites)
function check_box_collision(x1, y1, w1, h1, x2, y2, w2, h2)
 return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

-- sprite collision (8x12 sprites)
function check_sprite_collision(x1, y1, x2, y2)
 -- sprites are 8x12, centered at x,y
 -- so box is from (x-4,y-6) to (x+4,y+6)
 return check_box_collision(
  x1 - 4, y1 - 6, 8, 12,
  x2 - 4, y2 - 6, 8, 12
 )
end

-- wall collision (sprite vs walls)
function check_wall_collision(x, y)
 -- check 8x12 sprite centered at x,y against walls
 for w in all(arena) do
  -- sprite box is from (x-4,y-6) to (x+4,y+6)
  -- wall is WALL_SIZE x WALL_SIZE at w.x,w.y
  if check_box_collision(
   x - 4, y - 6, 8, 12,
   w.x, w.y, WALL_SIZE, WALL_SIZE
  ) then
   return true
  end
 end
 return false
end

-- missile-wall collision (point vs walls)
function check_missile_wall_collision(x, y)
 for w in all(arena) do
  if x >= w.x and x < w.x + WALL_SIZE and
     y >= w.y and y < w.y + WALL_SIZE then
   return true
  end
 end
 return false
end
