-- sprite system for k-razy shoot-out
-- sprites are 8x12 pixels (matching atari original)

-- sprite data will be stored as userdata/images
-- for now, we'll use placeholder rectangles

SPRITE_WIDTH = 8
SPRITE_HEIGHT = 12

-- sprite IDs
SPR_PLAYER_STAND = 0
SPR_PLAYER_LEFT_1 = 1
SPR_PLAYER_LEFT_2 = 2
SPR_PLAYER_RIGHT_1 = 3
SPR_PLAYER_RIGHT_2 = 4
SPR_PLAYER_UP_1 = 5
SPR_PLAYER_UP_2 = 6

SPR_ENEMY_STAND = 7
SPR_ENEMY_LEFT_1 = 8
SPR_ENEMY_LEFT_2 = 9
SPR_ENEMY_RIGHT_1 = 10
SPR_ENEMY_RIGHT_2 = 11
SPR_ENEMY_UP_1 = 12
SPR_ENEMY_UP_2 = 13

SPR_EXPLOSION_1 = 32
SPR_EXPLOSION_2 = 33
SPR_EXPLOSION_3 = 34
SPR_EXPLOSION_4 = 35
SPR_EXPLOSION_5 = 36
SPR_EXPLOSION_6 = 37
SPR_EXPLOSION_7 = 38
SPR_EXPLOSION_8 = 39

-- draw a sprite at x,y with optional color override
function draw_sprite(sprite_id, x, y, color)
 -- Picotron's spr() function: spr(s, x, y, [flip_x], [flip_y])
 -- Sprites in Picotron are drawn from top-left corner
 -- Our sprites are 8x12, so we need to offset to center them at x,y
 
 local sx = x - SPRITE_WIDTH / 2
 local sy = y - SPRITE_HEIGHT / 2
 
 -- If color override is specified, we need to use pal() to swap colors
 if color then
  -- Swap color 7 (white) to the specified color
  pal(7, color)
  spr(sprite_id, sx, sy)
  pal() -- reset palette
 else
  spr(sprite_id, sx, sy)
 end
end

-- create sprite sheet from PICO-8 data
-- this will need to be converted to Picotron format
function init_sprites()
 -- TODO: load sprite sheet
 -- for now, sprites will be drawn as colored rectangles
end
