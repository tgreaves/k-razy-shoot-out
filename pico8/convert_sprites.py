#!/usr/bin/env python3
"""
Convert player sprite data from K-Razy Shoot-Out disassembly to PICO-8 format.
Each sprite is 8x12 pixels from the original, but PICO-8 sprites are 8x8.
We'll create sprites that are 8x16 (2 PICO-8 sprites stacked).
"""

# Player sprite data from disassembly (each sprite is 12 bytes = 12 rows of 8 pixels)
player_sprites = {
    "STATIONARY": [
        0x08, 0x14, 0x14, 0x08, 0x1C, 0x2A, 0x2A, 0x08, 0x14, 0x14, 0x14, 0x36
    ],
    "WALKING_LEFT_1": [
        0x08, 0x14, 0x14, 0x08, 0x5C, 0x2A, 0x09, 0x0A, 0x18, 0x24, 0x27, 0x61
    ],
    "WALKING_LEFT_2": [
        0x08, 0x14, 0x14, 0x08, 0x0C, 0x0C, 0x3C, 0x08, 0x18, 0x0C, 0x0A, 0x1C
    ],
    "WALKING_RIGHT_1": [
        0x10, 0x28, 0x28, 0x10, 0x3A, 0x54, 0x90, 0x50, 0x18, 0x24, 0xE4, 0x86
    ],
    "WALKING_RIGHT_2": [
        0x10, 0x28, 0x28, 0x10, 0x30, 0x30, 0x3C, 0x10, 0x18, 0x30, 0x50, 0x38
    ],
    "WALKING_UP_DOWN_1": [
        0x08, 0x14, 0x34, 0x28, 0x1C, 0x0A, 0x0A, 0x08, 0x14, 0x16, 0x10, 0x30
    ],
    "WALKING_UP_DOWN_2": [
        0x08, 0x14, 0x16, 0x0A, 0x1C, 0x28, 0x28, 0x08, 0x14, 0x34, 0x04, 0x06
    ],
    "SHOOTING_LEFT": [
        0x00, 0x00, 0x04, 0x0A, 0x0A, 0xC4, 0x7C, 0x04, 0x0C, 0x14, 0x0F, 0x19
    ],
    "SHOOTING_TOP_LEFT": [
        0x00, 0x40, 0x24, 0x4A, 0x2A, 0x14, 0x0C, 0x04, 0x0C, 0x14, 0x0F, 0x19
    ],
    "SHOOTING_BOTTOM_LEFT": [
        0x00, 0x00, 0x04, 0x0A, 0x0A, 0x04, 0x0C, 0x54, 0xAC, 0x14, 0x0F, 0x19
    ],
    "SHOOTING_RIGHT": [
        0x00, 0x00, 0x20, 0x50, 0x50, 0x23, 0x3E, 0x20, 0x30, 0x28, 0xF0, 0x98
    ]
}

def byte_to_binary_string(byte_val):
    """Convert byte to 8-character binary string with # for 1 and . for 0"""
    bits = format(byte_val, '08b')
    return bits.replace('1', '#').replace('0', '.')

def print_sprite_visual(name, data):
    """Print a visual representation of the sprite"""
    print(f"\n{name}:")
    for row in data:
        print(f"  {byte_to_binary_string(row)}")

def generate_pico8_sprite_data(sprite_data, pad_to_16=True):
    """
    Generate PICO-8 sprite data format.
    PICO-8 sprites are 8x8, but we need 8x12 (or 8x16 with padding).
    We'll create two 8x8 sprites stacked vertically.
    """
    # Pad to 16 rows if needed (2 PICO-8 sprites)
    if pad_to_16:
        while len(sprite_data) < 16:
            sprite_data.append(0x00)
    
    # Convert to PICO-8 hex format
    # PICO-8 stores sprites as hex strings, 2 chars per row
    lines = []
    for i in range(0, len(sprite_data), 8):
        chunk = sprite_data[i:i+8]
        hex_line = ''.join(f'{b:02x}' for b in chunk)
        lines.append(hex_line)
    
    return lines

# Print visual representation of all sprites
print("=" * 60)
print("PLAYER SPRITE DATA VISUALIZATION")
print("=" * 60)

for name, data in player_sprites.items():
    print_sprite_visual(name, data)

# Generate PICO-8 format
print("\n" + "=" * 60)
print("PICO-8 SPRITE DATA (for __gfx__ section)")
print("=" * 60)
print("\nSprite mapping:")
print("  1: STATIONARY")
print("  2: WALKING_LEFT_1")
print("  3: WALKING_LEFT_2")
print("  4: WALKING_RIGHT_1")
print("  5: WALKING_RIGHT_2")
print("  6: WALKING_UP_DOWN_1")
print("  7: WALKING_UP_DOWN_2")
print("  8: SHOOTING_LEFT")
print("\nNote: Each sprite is 8x12 pixels, padded to 8x16 for PICO-8")
print("\nPaste this into the __gfx__ section of your .p8 file:")
print()

# Generate sprite data for PICO-8
# We'll create a simple format: each sprite as hex rows
sprite_num = 1
for name, data in list(player_sprites.items())[:8]:  # First 8 sprites
    print(f"; Sprite {sprite_num}: {name}")
    # Pad to 16 rows
    padded = data + [0x00] * (16 - len(data))
    for row in padded:
        print(f"{row:02x}000000000000000", end="")
        if (padded.index(row) + 1) % 8 == 0:
            print()
    sprite_num += 1
