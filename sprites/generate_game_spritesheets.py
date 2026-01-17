#!/usr/bin/env python3
"""
Generate spritesheets for K-Razy Shoot-Out based on discovered sprite animation data
Creates separate spritesheets for Player, Enemy, and Explosion sprites
"""

from PIL import Image, ImageDraw
import os

def extract_character_data_from_rom(rom_path):
    """Extract character sprite data from the ROM file"""
    with open(rom_path, 'rb') as f:
        data = f.read()
    
    # Character data starts at $A000 in ROM (offset 0x1000 in file)
    char_start = 0x1000
    characters = {}
    
    # Extract each 8-byte character pattern
    for char_num in range(256):
        offset = char_start + (char_num * 8)
        if offset + 8 <= len(data):
            char_data = data[offset:offset + 8]
            characters[char_num] = list(char_data)
    
    return characters

def render_character_to_pixels(char_data, scale=8):
    """Convert 8-byte character data to pixel array"""
    pixels = []
    for byte in char_data:
        for _ in range(scale):  # Vertical scaling
            row = []
            for bit in range(8):
                # Check each bit (MSB first)
                if byte & (0x80 >> bit):
                    row.extend([255, 255, 255] * scale)  # White pixel (scaled horizontally)
                else:
                    row.extend([0, 0, 0] * scale)        # Black pixel (scaled horizontally)
            pixels.extend(row)
    return pixels

def create_sprite_image(char_data, scale=8):
    """Create a PIL Image from character data"""
    # Create image directly without intermediate pixel array
    img = Image.new('RGB', (8 * scale, 8 * scale), (0, 0, 0))  # Black background
    
    for row in range(8):
        byte = char_data[row]
        for col in range(8):
            # Check each bit (MSB first)
            if byte & (0x80 >> col):
                # Draw white pixel scaled
                for y in range(row * scale, (row + 1) * scale):
                    for x in range(col * scale, (col + 1) * scale):
                        img.putpixel((x, y), (255, 255, 255))
    
    return img

def create_player_spritesheet():
    """Create player spritesheet with all animation frames"""
    print("Creating player spritesheet...")
    
    # Load ROM data
    characters = extract_character_data_from_rom('K-Razy Shoot-Out (USA).a52')
    
    # Player sprite character codes (from our analysis)
    player_chars = {
        'head_sideways': 0x02,      # Player Head (Sideways) - for horizontal movement
        'body_frame1': 0x03,        # Player Body Frame 1 - walking animation
        'head_vertical': 0x04,      # Player Head (Vertical) - for vertical/stationary movement  
        'body_frame2': 0x05,        # Player Body Frame 2 - walking animation
        'body_stationary': 0x1E,    # Player Body (Stationary) - for vertical/stationary movement
        'death1': 0x06,             # Death animation frame 1
        'death2': 0x07,             # Death animation frame 2
        'death3': 0x08,             # Death animation frame 3
        'death4': 0x09,             # Death animation frame 4 (final dead state)
    }
    
    scale = 16  # 16x scale for clear visibility
    char_size = 8 * scale
    
    # Create spritesheet layout: 3 columns x 3 rows
    sheet_width = char_size * 3
    sheet_height = char_size * 3
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (64, 64, 64))  # Dark gray background
    
    # Layout positions
    positions = [
        # Row 1: Movement sprites
        (0, 0, 'head_sideways', 'Head (Sideways)'),
        (1, 0, 'body_frame1', 'Body Frame 1'),
        (2, 0, 'body_frame2', 'Body Frame 2'),
        # Row 2: Stationary sprites  
        (0, 1, 'head_vertical', 'Head (Vertical)'),
        (1, 1, 'body_stationary', 'Body (Stationary)'),
        (2, 1, None, 'Empty'),
        # Row 3: Death animation
        (0, 2, 'death1', 'Death Frame 1'),
        (1, 2, 'death2', 'Death Frame 2'),
        (2, 2, 'death3', 'Death Frame 3'),
    ]
    
    draw = ImageDraw.Draw(spritesheet)
    
    for col, row, char_key, label in positions:
        x = col * char_size
        y = row * char_size
        
        if char_key and char_key in player_chars:
            char_num = player_chars[char_key]
            if char_num in characters:
                char_img = create_sprite_image(characters[char_num], scale)
                spritesheet.paste(char_img, (x, y))
                
                # Add label
                draw.text((x + 5, y + char_size - 20), f"${char_num:02X}: {label}", fill=(255, 255, 0))
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - PLAYER SPRITES", fill=(255, 255, 255))
    
    spritesheet.save('sprites/player_spritesheet.png')
    print("Player spritesheet saved as 'sprites/player_spritesheet.png'")

def create_enemy_spritesheet():
    """Create enemy spritesheet"""
    print("Creating enemy spritesheet...")
    
    # Load ROM data
    characters = extract_character_data_from_rom('K-Razy Shoot-Out (USA).a52')
    
    # Enemy sprite character code (from our analysis)
    enemy_char = 0x1C  # Enemy sprite
    
    scale = 32  # Large scale for the single enemy sprite
    char_size = 8 * scale
    
    # Create spritesheet with single large enemy sprite
    sheet_width = char_size + 40  # Extra space for labels
    sheet_height = char_size + 60
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (32, 32, 64))  # Dark blue background
    
    draw = ImageDraw.Draw(spritesheet)
    
    if enemy_char in characters:
        char_img = create_sprite_image(characters[enemy_char], scale)
        spritesheet.paste(char_img, (20, 40))
        
        # Add labels
        draw.text((10, 10), "K-RAZY SHOOT-OUT - ENEMY SPRITE", fill=(255, 255, 255))
        draw.text((25, char_size + 45), f"Character ${enemy_char:02X}: Enemy", fill=(255, 255, 0))
    
    spritesheet.save('sprites/enemy_spritesheet.png')
    print("Enemy spritesheet saved as 'sprites/enemy_spritesheet.png'")

def create_explosion_spritesheet():
    """Create explosion/death animation spritesheet"""
    print("Creating explosion spritesheet...")
    
    # Load ROM data
    characters = extract_character_data_from_rom('K-Razy Shoot-Out (USA).a52')
    
    # Explosion/death animation character codes (from our analysis)
    explosion_chars = {
        'death_vertical_1': 0x06,   # Death Animation (Vertical Pair) 1
        'death_vertical_2': 0x07,   # Death Animation (Vertical Pair) 2  
        'death_horizontal_1': 0x08, # Death Animation (Horizontal Pair) 1
        'death_horizontal_2': 0x09, # Death Animation (Horizontal Pair) 2
    }
    
    scale = 20  # Good scale for animation frames
    char_size = 8 * scale
    
    # Create spritesheet layout: 2 columns x 2 rows
    sheet_width = char_size * 2 + 40
    sheet_height = char_size * 2 + 80
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (64, 32, 32))  # Dark red background
    
    # Layout positions
    positions = [
        (0, 0, 'death_vertical_1', 'Vertical Pair 1'),
        (1, 0, 'death_vertical_2', 'Vertical Pair 2'),
        (0, 1, 'death_horizontal_1', 'Horizontal Pair 1'),
        (1, 1, 'death_horizontal_2', 'Horizontal Pair 2'),
    ]
    
    draw = ImageDraw.Draw(spritesheet)
    
    for col, row, char_key, label in positions:
        x = col * char_size + 20
        y = row * char_size + 40
        
        if char_key in explosion_chars:
            char_num = explosion_chars[char_key]
            if char_num in characters:
                char_img = create_sprite_image(characters[char_num], scale)
                spritesheet.paste(char_img, (x, y))
                
                # Add label
                draw.text((x + 5, y + char_size + 5), f"${char_num:02X}: {label}", fill=(255, 255, 0))
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - EXPLOSION/DEATH SPRITES", fill=(255, 255, 255))
    
    spritesheet.save('sprites/explosion_spritesheet.png')
    print("Explosion spritesheet saved as 'sprites/explosion_spritesheet.png'")

def create_combined_spritesheet():
    """Create a combined spritesheet with all game sprites"""
    print("Creating combined spritesheet...")
    
    # Load ROM data
    characters = extract_character_data_from_rom('K-Razy Shoot-Out (USA).a52')
    
    # All game sprite character codes
    all_sprites = {
        # Player sprites
        'Player Head (Sideways)': 0x02,
        'Player Body Frame 1': 0x03,
        'Player Head (Vertical)': 0x04,
        'Player Body Frame 2': 0x05,
        'Death Animation 1': 0x06,
        'Death Animation 2': 0x07,
        'Death Animation 3': 0x08,
        'Death Animation 4': 0x09,
        'Player Body (Stationary)': 0x1E,
        # Enemy sprite
        'Enemy': 0x1C,
    }
    
    scale = 12
    char_size = 8 * scale
    
    # Create spritesheet layout: 5 columns x 2 rows
    sheet_width = char_size * 5 + 60
    sheet_height = char_size * 2 + 100
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (48, 48, 48))  # Dark gray background
    
    draw = ImageDraw.Draw(spritesheet)
    
    # Layout all sprites
    sprite_list = list(all_sprites.items())
    for i, (label, char_num) in enumerate(sprite_list):
        col = i % 5
        row = i // 5
        
        x = col * char_size + 30
        y = row * char_size + 50
        
        if char_num in characters:
            char_img = create_sprite_image(characters[char_num], scale)
            spritesheet.paste(char_img, (x, y))
            
            # Add label
            draw.text((x + 2, y + char_size + 2), f"${char_num:02X}", fill=(255, 255, 0))
            draw.text((x + 2, y - 15), label[:12], fill=(255, 255, 255))  # Truncate long labels
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - ALL GAME SPRITES", fill=(255, 255, 255))
    
    spritesheet.save('sprites/all_sprites_combined.png')
    print("Combined spritesheet saved as 'sprites/all_sprites_combined.png'")

def main():
    """Generate all spritesheets"""
    # Ensure sprites directory exists
    os.makedirs('sprites', exist_ok=True)
    
    print("Generating K-Razy Shoot-Out spritesheets...")
    print("=" * 50)
    
    try:
        create_player_spritesheet()
        create_enemy_spritesheet()
        create_explosion_spritesheet()
        create_combined_spritesheet()
        
        print("\n" + "=" * 50)
        print("All spritesheets generated successfully!")
        print("Files created:")
        print("- sprites/player_spritesheet.png")
        print("- sprites/enemy_spritesheet.png") 
        print("- sprites/explosion_spritesheet.png")
        print("- sprites/all_sprites_combined.png")
        
    except FileNotFoundError:
        print("Error: Could not find 'K-Razy Shoot-Out (USA).a52' ROM file")
        print("Make sure the ROM file is in the current directory")
    except Exception as e:
        print(f"Error generating spritesheets: {e}")

if __name__ == "__main__":
    main()