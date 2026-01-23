#!/usr/bin/env python3
"""
Generate 8x8 PICO-8 sprites from the original 8x12 Atari sprites.
We'll take rows 2-9 (skipping first 2 and last 2) to get the core visual content.
"""

# Player sprites (0-6) - rows 2-9 from original 12-row sprites
player_sprites = [
    # 0: stationary (rows 2-9)
    [0x14, 0x08, 0x1C, 0x2A, 0x2A, 0x08, 0x14, 0x14],
    # 1: left 1 (rows 2-9)
    [0x14, 0x08, 0x5C, 0x2A, 0x09, 0x0A, 0x18, 0x24],
    # 2: left 2 (rows 2-9)
    [0x14, 0x08, 0x0C, 0x0C, 0x3C, 0x08, 0x18, 0x0C],
    # 3: right 1 (rows 2-9)
    [0x28, 0x10, 0x3A, 0x54, 0x90, 0x50, 0x18, 0x24],
    # 4: right 2 (rows 2-9)
    [0x28, 0x10, 0x30, 0x30, 0x3C, 0x10, 0x18, 0x30],
    # 5: up/down 1 (rows 2-9)
    [0x34, 0x28, 0x1C, 0x0A, 0x0A, 0x08, 0x14, 0x16],
    # 6: up/down 2 (rows 2-9)
    [0x16, 0x0A, 0x1C, 0x28, 0x28, 0x08, 0x14, 0x34],
]

# Enemy sprites (7-13) - rows 2-9 from original 12-row sprites
enemy_sprites = [
    # 7: stationary (rows 2-9)
    [0xFF, 0xBD, 0xBD, 0xBD, 0xBD, 0xBD, 0x3C, 0x24],
    # 8: left 1 (rows 2-9)
    [0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x24],
    # 9: left 2 (rows 2-9)
    [0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x08],
    # 10: right 1 (rows 2-9)
    [0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x24],
    # 11: right 2 (rows 2-9)
    [0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x10],
    # 12: up/down 1 (rows 2-9)
    [0xFF, 0xBD, 0xBD, 0xBD, 0x3D, 0x3D, 0x3C, 0x26],
    # 13: up/down 2 (rows 2-9)
    [0xFF, 0xBD, 0xBD, 0xBD, 0xBC, 0xBC, 0x3C, 0x64],
]

# Explosion sprites (14-27) - rows 4-11 from original 12-row sprites (centered)
explosion_sprites = [
    # 14: frame 1 (rows 4-11)
    [0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00],
    # 15: frame 2 (rows 4-11)
    [0x00, 0x00, 0x00, 0x10, 0x38, 0x10, 0x00, 0x00],
    # 16: frame 3 (rows 4-11)
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x2C],
    # 17: frame 4 (rows 4-11)
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x58],
    # 18: frame 5 (rows 4-11)
    [0x00, 0x10, 0x00, 0x00, 0x00, 0x38, 0x00, 0x92],
    # 19: frame 6 (rows 4-11)
    [0x00, 0x54, 0x00, 0x54, 0x00, 0x00, 0x48, 0x10],
    # 20: frame 7 (rows 4-11)
    [0x00, 0x82, 0x00, 0x54, 0x00, 0xA0, 0x10, 0x44],
    # 21: frame 8 (rows 4-11)
    [0x09, 0xA0, 0x00, 0x00, 0x84, 0x00, 0x55, 0x00],
    # 22: frame 9 (rows 4-11)
    [0x10, 0xA4, 0x01, 0x80, 0x01, 0x00, 0x80, 0x00],
    # 23: frame 10 (rows 4-11)
    [0x52, 0x24, 0x10, 0x24, 0x00, 0x80, 0x01, 0x00],
    # 24: frame 11 (rows 4-11)
    [0x29, 0x50, 0x50, 0xA1, 0x00, 0x00, 0x00, 0x80],
    # 25: frame 12 (rows 4-11)
    [0x00, 0x00, 0x81, 0x10, 0x00, 0x40, 0x00, 0x02],
    # 26: frame 13 (rows 4-11)
    [0x00, 0x00, 0x20, 0x00, 0x00, 0x10, 0x00, 0x00],
    # 27: frame 14 (rows 4-11)
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
]

def byte_to_pico8_row(byte_val, color):
    """Convert a byte to PICO-8 sprite row (8 hex chars)"""
    result = ""
    for bit in range(7, -1, -1):
        if byte_val & (1 << bit):
            result += f"{color:x}"
        else:
            result += "0"
    return result

def generate_sprite_sheet():
    """Generate complete PICO-8 sprite sheet with 8x8 sprites"""
    # PICO-8 sprite sheet is 128x128 pixels
    # Each sprite is 8x8 pixels
    # 16 sprites per row, 16 rows of sprites = 256 total sprite slots
    
    # Initialize empty sprite sheet (128 rows of 128 hex chars)
    rows = ["0" * 128 for _ in range(128)]
    
    # Combine all sprites
    all_sprites = player_sprites + enemy_sprites + explosion_sprites
    
    # Process each sprite
    for sprite_idx, sprite_data in enumerate(all_sprites):
        # Determine color based on sprite type
        if sprite_idx < 7:
            color = 7  # White for player
        elif sprite_idx < 14:
            color = 8  # Red for enemies
        else:
            color = 9  # Orange for explosions
        
        # Calculate position in sprite sheet
        # Sprites are arranged in a 16x16 grid
        sprite_col = sprite_idx % 16  # Column (0-15)
        sprite_row = sprite_idx // 16  # Row (0-1 for our 28 sprites)
        
        # Each sprite occupies 8 pixel rows
        pixel_row_start = sprite_row * 8
        pixel_col_start = sprite_col * 8
        
        # Add sprite data to rows
        for row_idx, byte_val in enumerate(sprite_data):
            actual_row = pixel_row_start + row_idx
            
            if actual_row < len(rows):
                sprite_pixels = byte_to_pico8_row(byte_val, color)
                
                # Insert sprite pixels into row
                row_list = list(rows[actual_row])
                for i, char in enumerate(sprite_pixels):
                    row_list[pixel_col_start + i] = char
                rows[actual_row] = "".join(row_list)
    
    return rows

# Generate and print
print("Generating 8x8 PICO-8 sprite sheet...")
rows = generate_sprite_sheet()

print("\n__gfx__")
for row in rows:
    print(row)

print("\nDone! Sprites are now proper 8x8 format.")
print(f"Total sprites: {len(player_sprites + enemy_sprites + explosion_sprites)}")
print("Use spr(n,x,y) without scaling - no need for 1.5x multiplier")
