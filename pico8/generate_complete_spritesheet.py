#!/usr/bin/env python3
"""
Generate complete PICO-8 sprite sheet with player, enemy, and explosion sprites.
Since we render at 1.5x scale (8x8 -> 8x12), we only store 8 rows per sprite.
"""

# Player sprites (0-6) - using first 8 rows of 12-byte data
player_sprites = [
    [0x08, 0x14, 0x14, 0x08, 0x1C, 0x2A, 0x2A, 0x08],  # 0: stationary
    [0x08, 0x14, 0x14, 0x08, 0x5C, 0x2A, 0x09, 0x0A],  # 1: left 1
    [0x08, 0x14, 0x14, 0x08, 0x0C, 0x0C, 0x3C, 0x08],  # 2: left 2
    [0x10, 0x28, 0x28, 0x10, 0x3A, 0x54, 0x90, 0x50],  # 3: right 1
    [0x10, 0x28, 0x28, 0x10, 0x30, 0x30, 0x3C, 0x10],  # 4: right 2
    [0x08, 0x14, 0x34, 0x28, 0x1C, 0x0A, 0x0A, 0x08],  # 5: up/down 1
    [0x08, 0x14, 0x16, 0x0A, 0x1C, 0x28, 0x28, 0x08],  # 6: up/down 2
]

# Enemy sprites (7-13) - using first 8 rows of 12-byte data
enemy_sprites = [
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBD, 0xBD],  # 7: stationary
    [0x7E, 0x18, 0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D],  # 8: left 1
    [0x7E, 0x18, 0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D],  # 9: left 2
    [0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC],  # 10: right 1
    [0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC],  # 11: right 2
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0x3D, 0x3D],  # 12: up/down 1
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBC, 0xBC],  # 13: up/down 2
]

# Explosion sprites (14-27) - using first 8 rows of 12-byte data
explosion_sprites = [
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08],  # 14
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10],  # 15
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],  # 16
    [0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],  # 17
    [0x00, 0x2C, 0x00, 0x50, 0x00, 0x10, 0x00, 0x00],  # 18
    [0x00, 0x58, 0x00, 0xAA, 0x00, 0x54, 0x00, 0x54],  # 19
    [0x28, 0x92, 0x01, 0x58, 0x00, 0x82, 0x00, 0x54],  # 20
    [0x52, 0x24, 0x10, 0xA4, 0x09, 0xA0, 0x00, 0x00],  # 21
    [0x29, 0x52, 0x52, 0xA4, 0x10, 0xA4, 0x01, 0x80],  # 22
    [0x45, 0x00, 0xA8, 0x52, 0x52, 0x24, 0x10, 0x24],  # 23
    [0x00, 0x00, 0x01, 0x00, 0x29, 0x50, 0x50, 0xA1],  # 24
    [0x01, 0x00, 0x80, 0x00, 0x00, 0x00, 0x81, 0x10],  # 25
    [0x00, 0x80, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00],  # 26
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],  # 27
]

def byte_to_pico8_row(byte_val, color):
    """Convert a byte to PICO-8 sprite row"""
    result = ""
    for bit in range(7, -1, -1):
        if byte_val & (1 << bit):
            result += f"{color:x}"
        else:
            result += "0"
    return result

def generate_sprite_sheet():
    """Generate complete PICO-8 sprite sheet"""
    # PICO-8 sprite sheet is 128x128 pixels = 128 rows of 128 hex chars
    # Sprites are 8x8 pixels normally, but we're using 8x12 with 1.5 scaling
    # We need to store them as 8-pixel wide columns
    
    # Initialize empty sprite sheet (64 rows to be safe)
    rows = ["0" * 128 for _ in range(64)]
    
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
        # PICO-8 sprites are arranged in a 16x16 grid
        # Each sprite is 8x8 pixels
        sprite_col = sprite_idx % 16  # Column in sprite grid (0-15)
        sprite_row = sprite_idx // 16  # Row in sprite grid (0-1 for our 28 sprites)
        
        # Each sprite occupies 8 rows in the pixel data
        # But our sprites are 12 bytes tall, so we need 12 rows
        pixel_row_start = sprite_row * 8  # Start row in pixel data
        pixel_col_start = sprite_col * 8  # Start column in pixel data
        
        # Add sprite data to rows (only use first 8 bytes for 8x8 sprite)
        for row_idx in range(min(8, len(sprite_data))):
            byte_val = sprite_data[row_idx]
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
print("Generating complete PICO-8 sprite sheet...")
rows = generate_sprite_sheet()

print("\n__gfx__")
for row in rows:
    print(row)

print("\nDone! Copy the above __gfx__ section into your .p8 file")
print(f"Total sprites: {len(player_sprites + enemy_sprites + explosion_sprites)}")
