#!/usr/bin/env python3
"""
Convert player sprite data to proper PICO-8 format.
PICO-8 sprites are stored as hex strings where each character represents one pixel.
"""

# Player sprite data from disassembly (each sprite is 12 bytes = 12 rows of 8 pixels)
player_sprites = [
    # Sprite 1: STATIONARY
    [0x08, 0x14, 0x14, 0x08, 0x1C, 0x2A, 0x2A, 0x08, 0x14, 0x14, 0x14, 0x36],
    # Sprite 2: WALKING_LEFT_1
    [0x08, 0x14, 0x14, 0x08, 0x5C, 0x2A, 0x09, 0x0A, 0x18, 0x24, 0x27, 0x61],
    # Sprite 3: WALKING_LEFT_2
    [0x08, 0x14, 0x14, 0x08, 0x0C, 0x0C, 0x3C, 0x08, 0x18, 0x0C, 0x0A, 0x1C],
    # Sprite 4: WALKING_RIGHT_1
    [0x10, 0x28, 0x28, 0x10, 0x3A, 0x54, 0x90, 0x50, 0x18, 0x24, 0xE4, 0x86],
    # Sprite 5: WALKING_RIGHT_2
    [0x10, 0x28, 0x28, 0x10, 0x30, 0x30, 0x3C, 0x10, 0x18, 0x30, 0x50, 0x38],
    # Sprite 6: WALKING_UP_DOWN_1
    [0x08, 0x14, 0x34, 0x28, 0x1C, 0x0A, 0x0A, 0x08, 0x14, 0x16, 0x10, 0x30],
    # Sprite 7: WALKING_UP_DOWN_2
    [0x08, 0x14, 0x16, 0x0A, 0x1C, 0x28, 0x28, 0x08, 0x14, 0x34, 0x04, 0x06],
]

def byte_to_pico8_row(byte_val, color=7):
    """
    Convert a byte to a PICO-8 sprite row.
    Each bit becomes a hex digit: 0 for transparent, color for set bit.
    PICO-8 format: 16 hex chars per row (8 pixels, 2 chars each for color)
    """
    result = ""
    for bit in range(7, -1, -1):  # Process bits from left to right
        if byte_val & (1 << bit):
            result += f"{color:x}"  # Use specified color
        else:
            result += "0"  # Transparent
    return result

def generate_pico8_gfx():
    """Generate complete __gfx__ section for PICO-8"""
    # PICO-8 sprite sheet is 128x128 pixels = 16x16 sprites of 8x8 each
    # Each row in the file is 128 pixels = 128 hex characters
    
    lines = []
    
    # Process each sprite
    for sprite_idx, sprite_data in enumerate(player_sprites):
        # Each sprite is 8 pixels wide, starts at column sprite_idx * 8
        # Sprite takes up 12 rows (we'll pad to 16 for two 8x8 blocks)
        
        # Pad sprite data to 16 rows
        padded_data = sprite_data + [0x00] * (16 - len(sprite_data))
        
        # For each row of this sprite
        for row_idx, byte_val in enumerate(padded_data):
            # Make sure we have enough lines
            while len(lines) <= row_idx:
                lines.append("0" * 128)
            
            # Convert byte to PICO-8 format
            sprite_row = byte_to_pico8_row(byte_val, color=7)  # White color
            
            # Insert into the correct position in the line
            line = list(lines[row_idx])
            start_pos = sprite_idx * 8
            for i, char in enumerate(sprite_row):
                line[start_pos + i] = char
            lines[row_idx] = "".join(line)
    
    return lines

# Generate the sprite data
print("Generating PICO-8 sprite data...")
gfx_lines = generate_pico8_gfx()

print("\n__gfx__")
for line in gfx_lines:
    print(line)

print("\n" + "=" * 60)
print("Copy the above __gfx__ section into your .p8 file")
print("Replace everything from __gfx__ to __sfx__")
print("=" * 60)
