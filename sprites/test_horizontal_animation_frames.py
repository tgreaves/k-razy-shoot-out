#!/usr/bin/env python3
"""
Test Horizontal Player Animation Frames
Shows both frames of horizontal movement animation:
Frame 1: Character $02 (Head Sideways) + Character $03 (Body Horizontal Frame 1)
Frame 2: Character $02 (Head Sideways) + Character $05 (Body Horizontal Frame 2)
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

def test_animation_frames():
    """Test both frames of horizontal movement animation"""
    print("Horizontal Player Animation Frames Test")
    print("=" * 50)
    
    # Extract character data
    characters = extract_character_data()
    
    # Get sprites
    head_sideways = characters[0x02]  # Character $02 - Head (Sideways)
    body_frame1 = characters[0x03]    # Character $03 - Body (Horizontal) Frame 1
    body_frame2 = characters[0x05]    # Character $05 - Body (Horizontal) Frame 2
    
    print("Character $02 - Head (Sideways) - Used in both frames:")
    print("-" * 55)
    head_ascii = char_data_to_ascii(head_sideways)
    for line in head_ascii:
        print(line)
    
    print("\nCharacter $03 - Body (Horizontal) Frame 1:")
    print("-" * 40)
    body1_ascii = char_data_to_ascii(body_frame1)
    for line in body1_ascii:
        print(line)
    
    print("\nCharacter $05 - Body (Horizontal) Frame 2:")
    print("-" * 40)
    body2_ascii = char_data_to_ascii(body_frame2)
    for line in body2_ascii:
        print(line)
    
    print("\nAnimation Frame 1 (Head + Body Frame 1):")
    print("=" * 45)
    for line in head_ascii:
        print(line)
    for line in body1_ascii:
        print(line)
    
    print("\nAnimation Frame 2 (Head + Body Frame 2):")
    print("=" * 45)
    for line in head_ascii:
        print(line)
    for line in body2_ascii:
        print(line)
    
    # Create visual images
    print("\nCreating animation frame images...")
    
    # Create individual character images
    head_img = char_data_to_image(head_sideways, 16)
    body1_img = char_data_to_image(body_frame1, 16)
    body2_img = char_data_to_image(body_frame2, 16)
    
    # Create combined images for each frame
    combined_width = 8 * 16  # 128 pixels
    combined_height = 16 * 16  # 256 pixels (two 8x8 characters stacked)
    
    # Frame 1
    frame1_img = Image.new('RGB', (combined_width, combined_height), (255, 255, 255))
    frame1_img.paste(head_img, (0, 0))
    frame1_img.paste(body1_img, (0, 8 * 16))
    frame1_img.save("horizontal_animation_frame1.png")
    
    # Frame 2
    frame2_img = Image.new('RGB', (combined_width, combined_height), (255, 255, 255))
    frame2_img.paste(head_img, (0, 0))
    frame2_img.paste(body2_img, (0, 8 * 16))
    frame2_img.save("horizontal_animation_frame2.png")
    
    # Create side-by-side animation comparison
    animation_width = 32 * 16 + 64  # Two frames plus gap
    animation_height = 16 * 16 + 32  # Frame height plus label space
    animation_img = Image.new('RGB', (animation_width, animation_height), (255, 255, 255))
    
    # Paste Frame 1 (left side)
    animation_img.paste(frame1_img, (0, 0))
    
    # Paste Frame 2 (right side)
    animation_img.paste(frame2_img, (16 * 16 + 32, 0))
    
    # Add labels
    draw = ImageDraw.Draw(animation_img)
    try:
        from PIL import ImageFont
        font = ImageFont.load_default()
        draw.text((32, 16 * 16 + 10), "Frame 1", fill=(0, 0, 0), font=font)
        draw.text((32, 16 * 16 + 25), "($02 + $03)", fill=(0, 0, 0), font=font)
        draw.text((16 * 16 + 64, 16 * 16 + 10), "Frame 2", fill=(0, 0, 0), font=font)
        draw.text((16 * 16 + 64, 16 * 16 + 25), "($02 + $05)", fill=(0, 0, 0), font=font)
    except:
        draw.text((32, 16 * 16 + 10), "Frame 1 ($02+$03)", fill=(0, 0, 0))
        draw.text((16 * 16 + 64, 16 * 16 + 10), "Frame 2 ($02+$05)", fill=(0, 0, 0))
    
    animation_img.save("horizontal_walking_animation.png")
    
    # Create body comparison (just the body sprites)
    body_comparison_width = 32 * 16 + 64
    body_comparison_height = 8 * 16 + 32
    body_comparison_img = Image.new('RGB', (body_comparison_width, body_comparison_height), (255, 255, 255))
    
    body_comparison_img.paste(body1_img, (0, 0))
    body_comparison_img.paste(body2_img, (16 * 16 + 32, 0))
    
    # Add labels for body comparison
    draw = ImageDraw.Draw(body_comparison_img)
    try:
        draw.text((32, 8 * 16 + 10), "Body Frame 1 ($03)", fill=(0, 0, 0), font=font)
        draw.text((16 * 16 + 64, 8 * 16 + 10), "Body Frame 2 ($05)", fill=(0, 0, 0), font=font)
    except:
        draw.text((32, 8 * 16 + 10), "Body Frame 1 ($03)", fill=(0, 0, 0))
        draw.text((16 * 16 + 64, 8 * 16 + 10), "Body Frame 2 ($05)", fill=(0, 0, 0))
    
    body_comparison_img.save("horizontal_body_animation_comparison.png")
    
    print("Images created:")
    print("  - horizontal_animation_frame1.png (complete frame 1)")
    print("  - horizontal_animation_frame2.png (complete frame 2)")
    print("  - horizontal_walking_animation.png (side-by-side animation)")
    print("  - horizontal_body_animation_comparison.png (body sprites only)")
    
    # Show hex data
    print(f"\nHex Data:")
    print(f"Character $02 (Head Sideways): {' '.join(f'{b:02X}' for b in head_sideways)}")
    print(f"Character $03 (Body Frame 1):  {' '.join(f'{b:02X}' for b in body_frame1)}")
    print(f"Character $05 (Body Frame 2):  {' '.join(f'{b:02X}' for b in body_frame2)}")
    
    # Show differences between body frames
    print(f"\nBody Frame Differences:")
    for i, (b1, b2) in enumerate(zip(body_frame1, body_frame2)):
        if b1 != b2:
            print(f"  Row {i}: ${b1:02X} -> ${b2:02X} (diff: ${b1^b2:02X})")

if __name__ == "__main__":
    try:
        test_animation_frames()
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()