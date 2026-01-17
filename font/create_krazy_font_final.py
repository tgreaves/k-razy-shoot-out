#!/usr/bin/env python3
"""
Create K-Razy Shoot-Out Font (Final Working Version)
This script creates a bitmap font from the game's character data
"""

import os
from PIL import Image, ImageDraw, ImageFont
import struct

def extract_character_data():
    """Extract all 89 characters from the ROM"""
    with open("K-Razy Shoot-Out (USA).a52", "rb") as f:
        rom = f.read()
    
    characters = []
    for char_num in range(89):  # 89 characters total
        start_offset = char_num * 8
        char_data = rom[start_offset:start_offset + 8]
        characters.append(char_data)
    
    return characters

def get_character_mapping():
    """Map character indices to ASCII characters"""
    mapping = {}
    
    # Space character
    mapping[0] = ' '
    
    # Numbers 0-9 (characters 0x10-0x19)
    for i in range(10):
        char_idx = 0x10 + i
        if char_idx < 89:
            mapping[char_idx] = str(i)
    
    # Letters A-Z (characters 0x21-0x3A)
    for i in range(26):
        char_idx = 0x21 + i
        if char_idx < 89:
            mapping[char_idx] = chr(ord('A') + i)
    
    return mapping

def char_data_to_image(char_data, scale=8):
    """Convert 8x8 character data to PIL Image"""
    # Create 8x8 image
    img = Image.new('1', (8, 8), 0)  # 1-bit black and white
    pixels = img.load()
    
    for row in range(8):
        if row >= len(char_data):
            continue
        byte_val = char_data[row]
        for col in range(8):
            if byte_val & (1 << (7 - col)):  # Pixel is on
                pixels[col, row] = 1
    
    # Scale up the image
    if scale > 1:
        img = img.resize((8 * scale, 8 * scale), Image.NEAREST)
    
    return img

def create_font_bitmap():
    """Create a bitmap font image"""
    print("Extracting character data from ROM...")
    characters = extract_character_data()
    char_mapping = get_character_mapping()
    
    print("Creating font bitmap...")
    
    # Calculate grid size (16x16 grid should be enough for our characters)
    grid_cols = 16
    grid_rows = 16
    char_size = 64  # 8x8 scaled up 8x
    
    # Create large bitmap
    font_width = grid_cols * char_size
    font_height = grid_rows * char_size
    font_img = Image.new('RGB', (font_width, font_height), (255, 255, 255))
    
    # Process each character
    char_count = 0
    for char_idx, char_data in enumerate(characters):
        if char_idx in char_mapping:
            # Create character image
            char_img = char_data_to_image(char_data, 8)
            
            # Convert to RGB and invert colors (black on white)
            char_rgb = Image.new('RGB', char_img.size, (255, 255, 255))
            char_pixels = char_img.load()
            rgb_pixels = char_rgb.load()
            
            for y in range(char_img.height):
                for x in range(char_img.width):
                    if char_pixels[x, y]:
                        rgb_pixels[x, y] = (0, 0, 0)  # Black pixel
            
            # Calculate position in grid
            grid_x = char_count % grid_cols
            grid_y = char_count // grid_cols
            
            # Paste character into font bitmap
            paste_x = grid_x * char_size
            paste_y = grid_y * char_size
            font_img.paste(char_rgb, (paste_x, paste_y))
            
            # Show progress
            char_desc = f"'{char_mapping[char_idx]}'"
            print(f"  Character {char_idx:02X} -> {char_desc} at grid ({grid_x}, {grid_y})")
            
            char_count += 1
    
    return font_img

def create_character_samples():
    """Create individual character sample images"""
    print("Creating character samples...")
    characters = extract_character_data()
    char_mapping = get_character_mapping()
    
    # Create samples directory
    os.makedirs("character_samples", exist_ok=True)
    
    for char_idx, char_data in enumerate(characters):
        if char_idx in char_mapping:
            # Create large version of character
            char_img = char_data_to_image(char_data, 16)  # 16x scale = 128x128 pixels
            
            # Convert to RGB
            char_rgb = Image.new('RGB', char_img.size, (255, 255, 255))
            char_pixels = char_img.load()
            rgb_pixels = char_rgb.load()
            
            for y in range(char_img.height):
                for x in range(char_img.width):
                    if char_pixels[x, y]:
                        rgb_pixels[x, y] = (0, 0, 0)  # Black pixel
            
            # Save character sample
            char_name = char_mapping[char_idx]
            if char_name == ' ':
                char_name = 'space'
            elif char_name.isalnum():
                pass  # Keep as is
            else:
                char_name = f"char_{ord(char_name):02X}"
            
            filename = f"character_samples/char_{char_idx:02X}_{char_name}.png"
            char_rgb.save(filename)

def create_ascii_art_map():
    """Create ASCII art representation of all characters"""
    characters = extract_character_data()
    char_mapping = get_character_mapping()
    
    def bytes_to_ascii_art(char_data):
        lines = []
        for byte_val in char_data:
            line = ""
            for bit in range(7, -1, -1):
                line += "██" if byte_val & (1 << bit) else "  "
            lines.append(line)
        return lines
    
    map_text = []
    map_text.append("K-Razy Shoot-Out Character Map")
    map_text.append("=" * 50)
    map_text.append("")
    map_text.append("Each character is 8x8 pixels from the original game ROM")
    map_text.append("")
    
    for char_idx, char_data in enumerate(characters):
        if char_idx in char_mapping:
            ascii_art = bytes_to_ascii_art(char_data)
            char_name = char_mapping[char_idx]
            
            char_desc = f"Character {char_idx:02X} - '{char_name}'"
            if char_name == ' ':
                char_desc += " (space)"
            elif char_name.isdigit():
                char_desc += f" (number)"
            elif char_name.isalpha():
                char_desc += f" (letter)"
            
            map_text.append(char_desc)
            map_text.append("-" * len(char_desc))
            for line in ascii_art:
                map_text.append(line)
            map_text.append("")
    
    return "\n".join(map_text)

def create_usage_guide():
    """Create usage guide and examples"""
    char_mapping = get_character_mapping()
    
    guide_text = []
    guide_text.append("K-Razy Shoot-Out Font Usage Guide")
    guide_text.append("=" * 40)
    guide_text.append("")
    guide_text.append("This font contains the original 8x8 pixel characters from")
    guide_text.append("the 1981 Atari 5200 game K-Razy Shoot-Out.")
    guide_text.append("")
    
    # Show available characters
    numbers = "".join(char_mapping[0x10 + i] for i in range(10) if 0x10 + i in char_mapping)
    letters = "".join(char_mapping[0x21 + i] for i in range(26) if 0x21 + i in char_mapping)
    
    guide_text.append("Available Characters:")
    guide_text.append(f"  Numbers: {numbers}")
    guide_text.append(f"  Letters: {letters}")
    guide_text.append(f"  Space: (available)")
    guide_text.append("")
    
    guide_text.append("Sample Text:")
    guide_text.append("  KRAZY SHOOTOUT")
    guide_text.append("  SCORE 12345")
    guide_text.append("  GAME OVER")
    guide_text.append("  HIGH SCORE")
    guide_text.append("")
    
    guide_text.append("Files Created:")
    guide_text.append("  - krazy_font_bitmap.png (complete font bitmap)")
    guide_text.append("  - character_samples/ (individual character images)")
    guide_text.append("  - krazy_character_map.txt (ASCII art map)")
    guide_text.append("  - krazy_usage_guide.txt (this file)")
    guide_text.append("")
    
    guide_text.append("Usage Ideas:")
    guide_text.append("  - Use character images in game development")
    guide_text.append("  - Create retro-style graphics and logos")
    guide_text.append("  - Reference for pixel art and font design")
    guide_text.append("  - Educational study of classic game graphics")
    guide_text.append("")
    
    guide_text.append("Technical Details:")
    guide_text.append("  - Original size: 8x8 pixels per character")
    guide_text.append("  - Format: 1-bit monochrome bitmap")
    guide_text.append("  - Total characters: 89 (37 mapped to ASCII)")
    guide_text.append("  - Source: K-Razy Shoot-Out ROM data")
    
    return "\n".join(guide_text)

if __name__ == "__main__":
    try:
        print("K-Razy Shoot-Out Font Creator")
        print("=" * 40)
        
        # Check if PIL is available
        try:
            from PIL import Image, ImageDraw
        except ImportError:
            print("Error: PIL (Pillow) library not found.")
            print("Please install it with: pip install pillow")
            exit(1)
        
        # Create font bitmap
        font_bitmap = create_font_bitmap()
        
        # Save font bitmap
        bitmap_file = "krazy_font_bitmap.png"
        print(f"\nSaving font bitmap to {bitmap_file}...")
        font_bitmap.save(bitmap_file)
        
        # Create character samples
        create_character_samples()
        
        # Create ASCII art map
        map_file = "krazy_character_map.txt"
        print(f"Creating character map {map_file}...")
        with open(map_file, "w", encoding="utf-8") as f:
            f.write(create_ascii_art_map())
        
        # Create usage guide
        guide_file = "krazy_usage_guide.txt"
        print(f"Creating usage guide {guide_file}...")
        with open(guide_file, "w", encoding="utf-8") as f:
            f.write(create_usage_guide())
        
        print(f"\nFont creation complete!")
        print(f"Files created:")
        print(f"  - {bitmap_file} (complete font bitmap)")
        print(f"  - character_samples/ (individual character PNGs)")
        print(f"  - {map_file} (ASCII art character map)")
        print(f"  - {guide_file} (usage guide)")
        print(f"\nThe font contains {len(get_character_mapping())} characters from the original game.")
        print("You can use these images in graphics software, game development, or pixel art projects!")
        
    except Exception as e:
        print(f"Error creating font: {e}")
        import traceback
        traceback.print_exc()