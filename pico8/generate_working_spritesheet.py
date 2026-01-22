#!/usr/bin/env python3
"""
Generate PICO-8 sprite sheet with 8x12 sprites rendered at 1.5x scale.
Using the KNOWN GOOD player and enemy sprite data that was working.
"""

# Player sprites (0-6) - FULL 12 ROWS - KNOWN GOOD
player_sprites = [
    [0x08, 0x14, 0x14, 0x08, 0x1C, 0x2A, 0x2A, 0x08, 0x14, 0x14, 0x14, 0x36],  # 0: stationary
    [0x08, 0x14, 0x14, 0x08, 0x5C, 0x2A, 0x09, 0x0A, 0x18, 0x24, 0x27, 0x61],  # 1: left 1
    [0x08, 0x14, 0x14, 0x08, 0x0C, 0x0C, 0x3C, 0x08, 0x18, 0x0C, 0x0A, 0x1C],  # 2: left 2
    [0x10, 0x28, 0x28, 0x10, 0x3A, 0x54, 0x90, 0x50, 0x18, 0x24, 0xE4, 0x86],  # 3: right 1
    [0x10, 0x28, 0x28, 0x10, 0x30, 0x30, 0x3C, 0x10, 0x18, 0x30, 0x50, 0x38],  # 4: right 2
    [0x08, 0x14, 0x34, 0x28, 0x1C, 0x0A, 0x0A, 0x08, 0x14, 0x16, 0x10, 0x30],  # 5: up/down 1
    [0x08, 0x14, 0x16, 0x0A, 0x1C, 0x28, 0x28, 0x08, 0x14, 0x34, 0x04, 0x06],  # 6: up/down 2
]

# Enemy sprites (7-13) - FULL 12 ROWS - KNOWN GOOD
enemy_sprites = [
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBD, 0xBD, 0x3C, 0x24, 0x24, 0x66],  # 7: stationary
    [0x7E, 0x18, 0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x24, 0x24, 0x6C],  # 8: left 1
    [0x7E, 0x18, 0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x08, 0x08, 0x18],  # 9: left 2
    [0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x24, 0x24, 0x36],  # 10: right 1
    [0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x10, 0x10, 0x18],  # 11: right 2
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0x3D, 0x3D, 0x3C, 0x26, 0x20, 0x60],  # 12: up/down 1
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBC, 0xBC, 0x3C, 0x64, 0x04, 0x06],  # 13: up/down 2
]

# Explosion sprites (14-21) - Simple 8-frame explosion animation (8x8 pixels)
explosion_sprites = [
    # Frame 0: Single pixel
    [0x00, 0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00],
    # Frame 1: Small cross
    [0x00, 0x00, 0x08, 0x1C, 0x1C, 0x08, 0x00, 0x00],
    # Frame 2: Expanding
    [0x00, 0x08, 0x14, 0x3E, 0x3E, 0x14, 0x08, 0x00],
    # Frame 3: Full explosion
    [0x00, 0x14, 0x3E, 0x7F, 0x7F, 0x3E, 0x14, 0x00],
    # Frame 4: Peak with gaps
    [0x14, 0x22, 0x5D, 0xBE, 0xBE, 0x5D, 0x22, 0x14],
    # Frame 5: Dispersing
    [0x22, 0x41, 0x88, 0x94, 0x94, 0x88, 0x41, 0x22],
    # Frame 6: Fading
    [0x41, 0x00, 0x14, 0x00, 0x00, 0x14, 0x00, 0x41],
    # Frame 7: Last sparks
    [0x00, 0x00, 0x00, 0x14, 0x14, 0x00, 0x00, 0x00],
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
    """
    Generate PICO-8 sprite sheet for 8x12 sprites.
    
    We render with spr(n,x,y,1,2) which displays 16 pixels vertically.
    To avoid artifacts, we pad each 12-row sprite to 16 rows:
    - 2 empty rows at top
    - 12 rows of sprite data
    - 2 empty rows at bottom
    """
    
    # Initialize empty sprite sheet (128 rows)
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
        
        # Player/enemy sprites need padding for 8x12 rendering with spr(n,x,y,1,2)
        # Explosion sprites are simple 8x8, no padding needed
        if sprite_idx < 14:
            # Calculate position in sprite sheet
            sprite_col = sprite_idx % 16
            sprite_row_base = (sprite_idx // 16) * 16  # Each sprite takes 16 rows (for 1,2 rendering)
            
            # Add padding: 2 empty rows at top, 12 rows of data, 2 empty rows at bottom
            padded_sprite = [0x00, 0x00] + sprite_data + [0x00, 0x00]
            
            # Add all 16 rows of padded sprite data
            for row_idx, byte_val in enumerate(padded_sprite):
                actual_row = sprite_row_base + row_idx
                
                if actual_row < len(rows):
                    sprite_pixels = byte_to_pico8_row(byte_val, color)
                    pixel_col_start = sprite_col * 8
                    
                    # Insert sprite pixels into row
                    row_list = list(rows[actual_row])
                    for i, char in enumerate(sprite_pixels):
                        row_list[pixel_col_start + i] = char
                    rows[actual_row] = "".join(row_list)
        else:
            # Explosions: simple 8x8 sprites
            # Place them starting at row 2 (sprites 32+) to avoid conflict with player/enemy bottom halves
            explosion_idx = sprite_idx - 14  # 0-7 for explosion frames
            actual_sprite_slot = 32 + explosion_idx  # Sprites 32-39
            
            sprite_col = actual_sprite_slot % 16
            sprite_row_base = (actual_sprite_slot // 16) * 8  # Each sprite is 8 rows
            
            # Add 8 rows of sprite data
            for row_idx, byte_val in enumerate(sprite_data):
                actual_row = sprite_row_base + row_idx
                
                if actual_row < len(rows):
                    sprite_pixels = byte_to_pico8_row(byte_val, color)
                    pixel_col_start = sprite_col * 8
                    
                    # Insert sprite pixels into row
                    row_list = list(rows[actual_row])
                    for i, char in enumerate(sprite_pixels):
                        row_list[pixel_col_start + i] = char
                    rows[actual_row] = "".join(row_list)
    
    return rows

# Generate and print
print("Generating 8x12 PICO-8 sprite sheet...")
rows = generate_sprite_sheet()

print("\n__gfx__")
for row in rows:
    print(row)

print("\nDone! Use spr(n,x,y,1,2) to render 8x12 sprites (padded to 16 rows)")
print(f"Total sprites: {len(player_sprites + enemy_sprites + explosion_sprites)}")
print("Each sprite uses 16 rows: 2 empty + 12 data + 2 empty")
