#!/usr/bin/env python3
"""
Show Player Sprite Combination
Visualizes Character $02 (head) + Character $1E (body) combined vertically
"""

import os
from PIL import Image, ImageDraw

def extract_character_data():
    """Extract character data from ROM"""
    with open("K-Razy Shoot-Out (USA).a52", "rb") as f:
        rom = f.read()
    
    characters = {}
    for char_num in range(89):
        start_offset = char_num * 8
        char_data = rom[start_offset:start_offset + 8]
        characters[char_num] = char_data
    
    return characters

def char_data_to_ascii(char_data):
    """Convert character data to ASCII art"""
    lines = []
    for byte_val in char_data:
        line = ""
        for bit in range(7, -1, -1):
            line += "██" if byte_val & (1 << bit) else "  "
        lines.append(line)
    return lines

def char_data_to_image(char_data, scale=16):
    """Convert 8x8 character data to PIL Image"""
    img = Image.new('RGB', (8 * scale, 8 * scale), (255, 255, 255))
    pixels = img.load()
    
    for row in range(8):
        if row >= len(char_data):
            continue
        byte_val = char_data[row]
        for col in range(8):
            if byte_val & (1 << (7 - col)):  # Pixel is on
                # Fill the scaled pixel area
                for y in range(row * scale, (row + 1) * scale):
                    for x in range(col * scale, (col + 1) * scale):
                        pixels[x, y] = (0, 0, 0)  # Black pixel
    
    return img

def show_player_combination():
    """Show the combined player sprite"""
    print("Player Sprite Combination Analysis")
    print("=" * 50)
    
    # Extract character data
    characters = extract_character_data()
    
    # Get head and body data
    head_data = characters[0x04]  # Character $04 - Player head
    body_data = characters[0x1E]  # Character $1E - Player body (stationary)
    
    print("Character $04 - Player Head:")
    print("-" * 30)
    head_ascii = char_data_to_ascii(head_data)
    for line in head_ascii:
        print(line)
    
    print("\nCharacter $1E - Player Body (Stationary):")
    print("-" * 40)
    body_ascii = char_data_to_ascii(body_data)
    for line in body_ascii:
        print(line)
    
    print("\nCombined Player Sprite (Head on top, Body below):")
    print("=" * 50)
    for line in head_ascii:
        print(line)
    for line in body_ascii:
        print(line)
    
    # Create visual image
    print("\nCreating visual image...")
    
    # Create individual character images
    head_img = char_data_to_image(head_data, 16)
    body_img = char_data_to_image(body_data, 16)
    
    # Create combined image (head above body)
    combined_width = 8 * 16  # 128 pixels
    combined_height = 16 * 16  # 256 pixels (two 8x8 characters stacked)
    combined_img = Image.new('RGB', (combined_width, combined_height), (255, 255, 255))
    
    # Paste head on top
    combined_img.paste(head_img, (0, 0))
    # Paste body below
    combined_img.paste(body_img, (0, 8 * 16))
    
    # Save the combined image
    combined_img.save("player_sprite_head_body_combined.png")
    
    # Also create side-by-side comparison
    side_by_side_width = 16 * 16 + 32  # Two characters plus gap
    side_by_side_height = 8 * 16
    side_by_side_img = Image.new('RGB', (side_by_side_width, side_by_side_height), (255, 255, 255))
    
    # Paste head and body side by side
    side_by_side_img.paste(head_img, (0, 0))
    side_by_side_img.paste(body_img, (8 * 16 + 32, 0))
    
    # Add labels
    draw = ImageDraw.Draw(side_by_side_img)
    try:
        # Try to use a font, fall back to default if not available
        from PIL import ImageFont
        font = ImageFont.load_default()
        draw.text((10, 8 * 16 + 10), "Head ($04)", fill=(0, 0, 0), font=font)
        draw.text((8 * 16 + 42, 8 * 16 + 10), "Body ($1E)", fill=(0, 0, 0), font=font)
    except:
        draw.text((10, 8 * 16 + 10), "Head ($04)", fill=(0, 0, 0))
        draw.text((8 * 16 + 42, 8 * 16 + 10), "Body ($1E)", fill=(0, 0, 0))
    
    side_by_side_img.save("player_sprite_head_body_separate.png")
    
    print("Images created:")
    print("  - player_sprite_head_body_combined.png (stacked vertically)")
    print("  - player_sprite_head_body_separate.png (side by side)")
    
    # Show hex data
    print(f"\nHex Data:")
    print(f"Character $04 (Head): {' '.join(f'{b:02X}' for b in head_data)}")
    print(f"Character $1E (Body): {' '.join(f'{b:02X}' for b in body_data)}")

if __name__ == "__main__":
    try:
        show_player_combination()
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()