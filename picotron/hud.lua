-- HUD drawing system
-- HUD is at bottom of screen (y=160-192)

function draw_hud()
 -- draw HUD background
 rectfill(0, HUD_Y, ARENA_WIDTH - 1, 191, 0)
 
 -- draw separator line
 line(0, HUD_Y, ARENA_WIDTH - 1, HUD_Y, 7)
 
 -- score (left side)
 print("SCORE: " .. score, 10, HUD_Y + 8, 7)
 
 -- sector (center)
 print("SECTOR: " .. level, 130, HUD_Y + 8, 7)
 
 -- lives (right side)
 print("LIVES: " .. lives, 240, HUD_Y + 8, 7)
 
 -- debug info (second line)
 if enemies_defeated and total_enemies then
  local remaining = total_enemies - enemies_defeated
  print("LEFT: " .. remaining .. "/" .. total_enemies, 10, HUD_Y + 18, 6)
 end
 
 if enemy_fire_freq then
  print("FREQ: " .. enemy_fire_freq, 130, HUD_Y + 18, 6)
 end
 
 if enemy_speed then
  print("SPEED: " .. enemy_speed, 240, HUD_Y + 18, 6)
 end
end

function draw_timer_bar()
 -- timer bar at top of arena (like original)
 local bar_width = ARENA_WIDTH
 local bar_height = 4
 
 -- draw white background for visibility
 rectfill(0, 0, bar_width - 1, bar_height - 1, 7)
 
 -- calculate bar fill
 local bar_segments = flr(time_remaining / 4)
 local remainder = time_remaining % 4
 
 -- determine color based on time remaining
 local bar_color = 11  -- green
 if time_remaining <= 26 then
  bar_color = 8  -- red for critical
 elseif time_remaining <= 52 then
  bar_color = 9  -- orange for warning
 end
 
 -- draw filled segments
 for i = 0, bar_segments - 1 do
  rectfill(i * 4, 0, i * 4 + 3, bar_height - 1, bar_color)
 end
 
 -- draw partial segment
 if remainder > 0 then
  local width = remainder
  rectfill(bar_segments * 4, 0, bar_segments * 4 + width - 1, bar_height - 1, bar_color)
 end
end
