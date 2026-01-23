#!/usr/bin/env python3
"""
Convert enemy sprite data to PICO-8 format.
Enemy sprites are 8x12 pixels, same as player sprites.
"""

# Enemy sprite data from disassembly (each sprite is 12 bytes = 12 rows of 8 pixels)
enemy_sprites = [
    # Sprite 8: STATIONARY
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBD, 0xBD, 0x3C, 0x24, 0x24, 0x66],
    # Sprite 9: WALKING_LEFT_1
    [0x7E, 0x18, 0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x24, 0x24, 0x6C],
    # Sprite 10: WALKING_LEFT_2
    [0x7E, 0x18, 0x3F, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x08, 0x08, 0x18],
    # Sprite 11: WALKING_RIGHT_1
    [0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x24, 0x24, 0x36],
    # Sprite 12: WALKING_RIGHT_2
    [0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x10, 0x10, 0x18],
    # Sprite 13: WALKING_UP_DOWN_1
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0x3D, 0x3D, 0x3C, 0x26, 0x20, 0x60],
    # Sprite 14: WALKING_UP_DOWN_2
    [0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBC, 0xBC, 0x3C, 0x64, 0x04, 0x06],
]

def byte_to_binary_string(byte_val):
    """Convert byte to 8-character binary string with # for 1 and . for 0"""
    bits = format(byte_val, '08b')
    return bits.replace('1', '#').replace('0', '.')

def byte_to_pico8_row(byte_val, color=8):
    """
    Convert a byte to a PICO-8 sprite row.
    Each bit becomes a hex digit: 0 for transparent, color for set bit.
    """
    result = ""
    for bit in range(7, -1, -1):  # Process bits from left to right
        if byte_val & (1 << bit):
            result += f"{color:x}"  # Use specified color (8=red for enemies)
        else:
            result += "0"  # Transparent
    return result

# Print visual representation
print("=" * 60)
print("ENEMY SPRITE DATA VISUALIZATION")
print("=" * 60)

sprite_names = [
    "STATIONARY",
    "WALKING_LEFT_1",
    "WALKING_LEFT_2",
    "WALKING_RIGHT_1",
    "WALKING_RIGHT_2",
    "WALKING_UP_DOWN_1",
    "WALKING_UP_DOWN_2"
]

for name, data in zip(sprite_names, enemy_sprites):
    print(f"\n{name}:")
    for row in data:
        print(f"  {byte_to_binary_string(row)}")

# Generate PICO-8 sprite data
print("\n" + "=" * 60)
print("PICO-8 SPRITE DATA FOR ENEMIES")
print("=" * 60)
print("\nSprite mapping (sprites 8-14):")
for i, name in enumerate(sprite_names):
    print(f"  {8+i}: {name}")

print("\nAdd these sprites starting at position 8 (column 64) in sprite sheet:")
print()

# Generate the sprite rows for enemies
# Sprites 8-14 start at column 64 (8 sprites * 8 pixels each)
for sprite_idx, sprite_data in enumerate(enemy_sprites):
    print(f"; Sprite {8+sprite_idx}: {sprite_names[sprite_idx]}")
    # Pad to 16 rows
    padded_data = sprite_data + [0x00] * (16 - len(sprite_data))
    
    for row_idx, byte_val in enumerate(padded_data):
        sprite_row = byte_to_pico8_row(byte_val, color=8)  # Red color for enemies
        print(f"Row {row_idx}: ...add '{sprite_row}' at column 64+{sprite_idx*8}")
    print()
