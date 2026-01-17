#!/usr/bin/env python3
"""
Test Horizontal Player Sprite Combination
Visualizes Character $02 (Head Sideways) + Character $03 (Body Horizontal)
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

def test_horizontal_combination():
    """Test the horizontal movement player sprite combination"""
    print("Horizontal Player Sprite Combination Test")
    print("=" * 50)
    
    # Extract character data
    characters = extract_character_data()
    
    # Get horizontal movement sprites
    head_sideways = characters[0x02]  # Character $02 - Head (Sideways)
    body_horizontal = characters[0x03]  # Character $03 - Body (Horizontal)
    
    print("Character $02 - Head (Sideways):")
    print("-" * 35)
    head_ascii = char_data_to_ascii(head_sideways)
    for line in head_ascii:
        print(line)
    
    print("\nCharacter $03 - Body (Horizontal):")
    print("-" * 35)
    body_ascii = char_data_to_ascii(body_horizontal)
    for line in body_ascii:
        print(line)
    
    print("\nCombined Horizontal Player Sprite (Head on top, Body below):")
    print("=" * 60)
    for line in head_ascii:
        print(line)
    for line in body_ascii:
        print(line)
    
    # Create visual images
    print("\nCreating visual images...")
    
    # Create individual character images
    head_img = char_data_to_image(head_sideways, 16)
    body_img = char_data_to_image(body_horizontal, 16)
    
    # Create combined image (head above body)
    combined_width = 8 * 16  # 128 pixels
    combined_height = 16 * 16  # 256 pixels (two 8x8 characters stacked)
    combined_img = Image.new('RGB', (combined_width, combined_height), (255, 255, 255))
    
    # Paste head on top
    combined_img.paste(head_img, (0, 0))
    # Paste body below
    combined_img.paste(body_img, (0, 8 * 16))
    
    # Save the combined image
    combined_img.save("horizontal_player_sprite_combined.png")
    
    # Create side-by-side comparison
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
        draw.text((10, 8 * 16 + 10), "Head Sideways ($02)", fill=(0, 0, 0), font=font)
        draw.text((8 * 16 + 42, 8 * 16 + 10), "Body Horizontal ($03)", fill=(0, 0, 0), font=font)
    except:
        draw.text((10, 8 * 16 + 10), "Head Sideways ($02)", fill=(0, 0, 0))
        draw.text((8 * 16 + 42, 8 * 16 + 10), "Body Horizontal ($03)", fill=(0, 0, 0))
    
    side_by_side_img.save("horizontal_player_sprite_separate.png")
    
    # Also create comparison with vertical sprites
    print("\nCreating comparison with vertical sprites...")
    
    # Get vertical sprites for comparison
    head_vertical = characters[0x04]  # Character $04 - Head (Vertical)
    body_stationary = characters[0x1E]  # Character $1E - Body (Stationary)
    
    # Create comparison image showing both combinations
    comparison_width = 32 * 16 + 64  # Four characters plus gaps
    comparison_height = 16 * 16 + 32  # Two rows plus gap
    comparison_img = Image.new('RGB', (comparison_width, comparison_height), (255, 255, 255))
    
    # Create vertical combination images
    vert_head_img = char_data_to_image(head_vertical, 16)
    vert_body_img = char_data_to_image(body_stationary, 16)
    
    # Paste vertical combination (left side)
    comparison_img.paste(vert_head_img, (0, 0))
    comparison_img.paste(vert_body_img, (0, 8 * 16))
    
    # Paste horizontal combination (right side)
    comparison_img.paste(head_img, (16 * 16 + 32, 0))
    comparison_img.paste(body_img, (16 * 16 + 32, 8 * 16))
    
    # Add labels
    draw = ImageDraw.Draw(comparison_img)
    try:
        font = ImageFont.load_default()
        draw.text((10, 16 * 16 + 10), "Vertical/Stationary", fill=(0, 0, 0), font=font)
        draw.text((10, 16 * 16 + 25), "($04 + $1E)", fill=(0, 0, 0), font=font)
        draw.text((16 * 16 + 42, 16 * 16 + 10), "Horizontal Movement", fill=(0, 0, 0), font=font)
        draw.text((16 * 16 + 42, 16 * 16 + 25), "($02 + $03)", fill=(0, 0, 0), font=font)
    except:
        draw.text((10, 16 * 16 + 10), "Vertical ($04+$1E)", fill=(0, 0, 0))
        draw.text((16 * 16 + 42, 16 * 16 + 10), "Horizontal ($02+$03)", fill=(0, 0, 0))
    
    comparison_img.save("player_sprite_movement_comparison.png")
    
    print("Images created:")
    print("  - horizontal_player_sprite_combined.png (horizontal combination stacked)")
    print("  - horizontal_player_sprite_separate.png (horizontal sprites side by side)")
    print("  - player_sprite_movement_comparison.png (vertical vs horizontal comparison)")
    
    # Show hex data
    print(f"\nHex Data:")
    print(f"Character $02 (Head Sideways): {' '.join(f'{b:02X}' for b in head_sideways)}")
    print(f"Character $03 (Body Horizontal): {' '.join(f'{b:02X}' for b in body_horizontal)}")
    print(f"Character $04 (Head Vertical): {' '.join(f'{b:02X}' for b in head_vertical)}")
    print(f"Character $1E (Body Stationary): {' '.join(f'{b:02X}' for b in body_stationary)}")

if __name__ == "__main__":
    try:
        test_horizontal_combination()
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()