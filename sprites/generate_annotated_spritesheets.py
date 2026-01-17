#!/usr/bin/env python3
"""
Generate spritesheets for K-Razy Shoot-Out based on annotated sprite data from $BE20
Uses the actual sprite data as annotated in the disassembly
"""

from PIL import Image, ImageDraw, ImageFont
import os

def extract_sprite_data_from_annotations():
    """Extract sprite data based on the annotations in the disassembly"""
    
    # Sprite data extracted from the annotated disassembly at $BE20
    sprites = {
        # Player sprites (12 bytes each - 3 rows of 4 bytes for composite sprites)
        'player_stationary': [
            # Row 1 (head)
            0x08, 0x14, 0x14, 0x08,
            # Row 2 (body top)  
            0x1C, 0x2A, 0x2A, 0x08,
            # Row 3 (body bottom)
            0x14, 0x14, 0x14, 0x36
        ],
        
        'player_walking_left_1': [
            0x08, 0x14, 0x14, 0x08,
            0x5C, 0x2A, 0x09, 0x0A,
            0x18, 0x24, 0x27, 0x61
        ],
        
        'player_walking_left_2': [
            0x08, 0x14, 0x14, 0x08,
            0x0C, 0x0C, 0x3C, 0x08,
            0x18, 0x0C, 0x0A, 0x1C
        ],
        
        'player_walking_right_1': [
            0x10, 0x28, 0x28, 0x10,
            0x3A, 0x54, 0x90, 0x50,
            0x18, 0x24, 0xE4, 0x86
        ],
        
        'player_walking_right_2': [
            0x10, 0x28, 0x28, 0x10,
            0x30, 0x30, 0x3C, 0x10,
            0x18, 0x30, 0x50, 0x38
        ],
        
        'player_walking_up_down_1': [
            0x08, 0x14, 0x34, 0x28,
            0x1C, 0x0A, 0x0A, 0x08,
            0x14, 0x16, 0x10, 0x30
        ],
        
        'player_walking_up_down_2': [
            0x08, 0x14, 0x16, 0x0A,
            0x1C, 0x28, 0x28, 0x08,
            0x14, 0x34, 0x04, 0x06
        ],
        
        'player_shooting_left': [
            0x00, 0x00, 0x04, 0x0A,
            0x0A, 0xC4, 0x7C, 0x04,
            0x0C, 0x14, 0x0F, 0x19
        ],
        
        'player_shooting_top_left': [
            0x00, 0x40, 0x24, 0x4A,
            0x2A, 0x14, 0x0C, 0x04,
            0x0C, 0x14, 0x0F, 0x19
        ],
        
        'player_shooting_bottom_left': [
            0x00, 0x00, 0x04, 0x0A,
            0x0A, 0x04, 0x0C, 0x54,
            0xAC, 0x14, 0x0F, 0x19
        ],
        
        'player_shooting_right': [
            0x00, 0x00, 0x20, 0x50,
            0x50, 0x23, 0x3E, 0x20,
            0x30, 0x28, 0xF0, 0x98
        ],
        
        'player_shooting_top_right': [
            0x00, 0x02, 0x24, 0x52,
            0x54, 0x28, 0x30, 0x20,
            0x30, 0x28, 0xF0, 0x98
        ],
        
        'player_shooting_bottom_right': [
            0x00, 0x00, 0x20, 0x50,
            0x50, 0x20, 0x30, 0x2A,
            0x35, 0x28, 0xF0, 0x98
        ],
        
        'player_shooting_up': [
            0x00, 0x04, 0x24, 0x52,
            0x54, 0x28, 0x30, 0x20,
            0x30, 0x28, 0xF0, 0x98
        ],
        
        'player_shooting_down': [
            0x00, 0x00, 0x04, 0x0A,
            0x0A, 0x04, 0x0C, 0x14,
            0x6C, 0x54, 0x0F, 0x19
        ],
        
        # Enemy sprites (12 bytes each - 7 different enemy sprites)
        'enemy_stationary': [
            0x7E, 0x18, 0xFF, 0xBD,
            0xBD, 0xBD, 0xBD, 0xBD,
            0x3C, 0x24, 0x24, 0x66
        ],
        
        'enemy_walking_left_1': [
            0x7E, 0x18, 0x3F, 0x3D,
            0x3D, 0x3D, 0x3D, 0x3D,
            0x3C, 0x24, 0x24, 0x6C
        ],
        
        'enemy_walking_left_2': [
            0x7E, 0x18, 0x3F, 0x3D,
            0x3D, 0x3D, 0x3D, 0x3D,
            0x3C, 0x08, 0x08, 0x18
        ],
        
        'enemy_walking_right_1': [
            0x7E, 0x18, 0xFC, 0xBC,
            0xBC, 0xBC, 0xBC, 0xBC,
            0x3C, 0x24, 0x24, 0x36
        ],
        
        'enemy_walking_right_2': [
            0x7E, 0x18, 0xFC, 0xBC,
            0xBC, 0xBC, 0xBC, 0xBC,
            0x3C, 0x10, 0x10, 0x18
        ],
        
        'enemy_walking_up_down_1': [
            0x7E, 0x18, 0xFF, 0xBD,
            0xBD, 0xBD, 0x3D, 0x3D,
            0x3C, 0x26, 0x20, 0x60
        ],
        
        'enemy_walking_up_down_2': [
            0x7E, 0x18, 0xFF, 0xBD,
            0xBD, 0xBD, 0xBC, 0xBC,
            0x3C, 0x64, 0x04, 0x00  # Note: last byte is 0x00 as sprite ends at BFD2
        ],
        
        # Explosion sprites (12 bytes each - 14 different explosion frames)
        'explosion_1': [
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x08, 0x08,
            0x00, 0x00, 0x00, 0x00
        ],
        
        'explosion_2': [
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x10,
            0x38, 0x10, 0x00, 0x00
        ],
        
        'explosion_3': [
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x14, 0x00, 0x2C
        ],
        
        'explosion_4': [
            0x00, 0x14, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x10, 0x00, 0x58
        ],
        
        'explosion_5': [
            0x00, 0x2C, 0x00, 0x50,
            0x00, 0x10, 0x00, 0x00,
            0x00, 0x38, 0x00, 0x92
        ],
        
        'explosion_6': [
            0x00, 0x58, 0x00, 0xAA,
            0x00, 0x54, 0x00, 0x54,
            0x00, 0x00, 0x48, 0x10
        ],
        
        'explosion_7': [
            0x28, 0x92, 0x01, 0x58,
            0x00, 0x82, 0x00, 0x54,
            0x00, 0xA0, 0x10, 0x44
        ],
        
        'explosion_8': [
            0x52, 0x24, 0x10, 0xA4,
            0x09, 0xA0, 0x00, 0x00,
            0x84, 0x00, 0x55, 0x00
        ],
        
        'explosion_9': [
            0x29, 0x52, 0x52, 0xA4,
            0x10, 0xA4, 0x01, 0x80,
            0x01, 0x00, 0x80, 0x00
        ],
        
        'explosion_10': [
            0x45, 0x00, 0xA8, 0x52,
            0x52, 0x24, 0x10, 0x24,
            0x00, 0x80, 0x01, 0x00
        ],
        
        'explosion_11': [
            0x00, 0x00, 0x01, 0x00,
            0x29, 0x50, 0x50, 0xA1,
            0x00, 0x00, 0x00, 0x80
        ],
        
        'explosion_12': [
            0x01, 0x00, 0x80, 0x00,
            0x00, 0x00, 0x81, 0x10,
            0x00, 0x40, 0x00, 0x02
        ],
        
        'explosion_13': [
            0x00, 0x80, 0x00, 0x01,
            0x00, 0x00, 0x20, 0x00,
            0x00, 0x10, 0x00, 0x00
        ],
        
        'explosion_14': [
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
        ],
    }
    
    return sprites

def create_sprite_image(sprite_data, scale=8):
    """Create a PIL Image from sprite data - 8 pixels wide, 12 rows tall"""
    width = 8  # Always 8 pixels wide
    height = len(sprite_data)  # Number of rows (should be 12 for player sprites)
    
    img_width = width * scale
    img_height = height * scale
    
    img = Image.new('RGB', (img_width, img_height), (0, 0, 0))  # Black background
    
    for row in range(height):
        if row < len(sprite_data):
            byte = sprite_data[row]
            
            # Draw each bit of the byte (8 pixels across)
            for bit in range(8):
                if byte & (0x80 >> bit):
                    # Draw white pixel scaled
                    pixel_x = bit * scale
                    pixel_y = row * scale
                    
                    for y in range(pixel_y, pixel_y + scale):
                        for x in range(pixel_x, pixel_x + scale):
                            if x < img_width and y < img_height:
                                img.putpixel((x, y), (255, 255, 255))
    
    return img

def create_player_spritesheet():
    """Create comprehensive player spritesheet"""
    print("Creating player spritesheet...")
    
    sprites = extract_sprite_data_from_annotations()
    
    # Player sprite names and layout (ALL player sprites - movement + shooting)
    player_sprites = [
        ('player_stationary', 'Stationary'),
        ('player_walking_left_1', 'Walking Left 1'),
        ('player_walking_left_2', 'Walking Left 2'),
        ('player_walking_right_1', 'Walking Right 1'),
        ('player_walking_right_2', 'Walking Right 2'),
        ('player_walking_up_down_1', 'Walking Up/Down 1'),
        ('player_walking_up_down_2', 'Walking Up/Down 2'),
        ('player_shooting_left', 'Shooting Left'),
        ('player_shooting_top_left', 'Shooting Top Left'),
        ('player_shooting_bottom_left', 'Shooting Bottom Left'),
        ('player_shooting_right', 'Shooting Right'),
        ('player_shooting_top_right', 'Shooting Top Right'),
        ('player_shooting_bottom_right', 'Shooting Bottom Right'),
        ('player_shooting_up', 'Shooting Up'),
        ('player_shooting_down', 'Shooting Down')
    ]
    
    scale = 6  # Smaller scale to fit all 15 sprites clearly
    sprite_width = 8 * scale   # 8 pixels wide
    sprite_height = 12 * scale  # 12 rows tall
    
    # Layout: 5 columns x 3 rows (15 sprites total)
    cols = 5
    rows = 3
    sheet_width = cols * sprite_width + 60
    sheet_height = rows * sprite_height + 140
    
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (32, 32, 64))
    draw = ImageDraw.Draw(spritesheet)
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - ALL PLAYER SPRITES (8x12)", fill=(255, 255, 255))
    draw.text((10, 25), "Movement + Shooting - 15 Total Sprites", fill=(200, 200, 200))
    
    for i, (sprite_key, label) in enumerate(player_sprites):
        if i >= cols * rows:
            break
            
        col = i % cols
        row = i // cols
        
        x = col * sprite_width + 30
        y = row * sprite_height + 60
        
        if sprite_key in sprites:
            sprite_img = create_sprite_image(sprites[sprite_key], scale)
            spritesheet.paste(sprite_img, (x, y))
            
            # Add label (abbreviated to fit smaller sprites)
            label_text = label.replace('Shooting ', 'S.').replace('Walking ', 'W.')
            draw.text((x + 2, y + sprite_height + 2), label_text, fill=(255, 255, 0))
    
    spritesheet.save('sprites/player_spritesheet.png')
    print("Complete player spritesheet (all 15 sprites) saved as 'sprites/player_spritesheet.png'")

def create_shooting_spritesheet():
    """Create dedicated shooting sprites spritesheet"""
    print("Creating shooting sprites spritesheet...")
    
    sprites = extract_sprite_data_from_annotations()
    
    # All shooting sprite variants
    shooting_sprites = [
        ('player_shooting_left', 'Shooting Left'),
        ('player_shooting_top_left', 'Shooting Top Left'),
        ('player_shooting_bottom_left', 'Shooting Bottom Left'),
        ('player_shooting_right', 'Shooting Right'),
        ('player_shooting_top_right', 'Shooting Top Right'),
        ('player_shooting_bottom_right', 'Shooting Bottom Right'),
        ('player_shooting_up', 'Shooting Up'),
        ('player_shooting_down', 'Shooting Down')
    ]
    
    scale = 10
    sprite_width = 8 * scale   # 8 pixels wide
    sprite_height = 12 * scale  # 12 rows tall
    
    # Layout: 4 columns x 2 rows
    cols = 4
    rows = 2
    sheet_width = cols * sprite_width + 50
    sheet_height = rows * sprite_height + 120
    
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (64, 32, 64))
    draw = ImageDraw.Draw(spritesheet)
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - SHOOTING SPRITES (8x12)", fill=(255, 255, 255))
    
    for i, (sprite_key, label) in enumerate(shooting_sprites):
        if i >= cols * rows:
            break
            
        col = i % cols
        row = i // cols
        
        x = col * sprite_width + 25
        y = row * sprite_height + 50
        
        if sprite_key in sprites:
            sprite_img = create_sprite_image(sprites[sprite_key], scale)
            spritesheet.paste(sprite_img, (x, y))
            
            # Add label
            draw.text((x + 2, y + sprite_height + 5), label, fill=(255, 255, 0))
    
    spritesheet.save('sprites/shooting_sprites.png')
    print("Shooting sprites saved as 'sprites/shooting_sprites.png'")

def create_enemy_spritesheet():
    """Create enemy spritesheet with all 7 enemy sprites"""
    print("Creating enemy spritesheet...")
    
    sprites = extract_sprite_data_from_annotations()
    
    # All enemy sprite variants
    enemy_sprites = [
        ('enemy_stationary', 'Stationary'),
        ('enemy_walking_left_1', 'Walking Left 1'),
        ('enemy_walking_left_2', 'Walking Left 2'),
        ('enemy_walking_right_1', 'Walking Right 1'),
        ('enemy_walking_right_2', 'Walking Right 2'),
        ('enemy_walking_up_down_1', 'Walking Up/Down 1'),
        ('enemy_walking_up_down_2', 'Walking Up/Down 2')
    ]
    
    scale = 10
    sprite_width = 8 * scale   # 8 pixels wide
    sprite_height = 12 * scale  # 12 rows tall
    
    # Layout: 4 columns x 2 rows
    cols = 4
    rows = 2
    sheet_width = cols * sprite_width + 50
    sheet_height = rows * sprite_height + 120
    
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (64, 32, 32))
    draw = ImageDraw.Draw(spritesheet)
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - ENEMY SPRITES (8x12)", fill=(255, 255, 255))
    
    for i, (sprite_key, label) in enumerate(enemy_sprites):
        if i >= cols * rows:
            break
            
        col = i % cols
        row = i // cols
        
        x = col * sprite_width + 25
        y = row * sprite_height + 50
        
        if sprite_key in sprites:
            sprite_img = create_sprite_image(sprites[sprite_key], scale)
            spritesheet.paste(sprite_img, (x, y))
            
            # Add label
            draw.text((x + 2, y + sprite_height + 5), label, fill=(255, 255, 0))
    
    spritesheet.save('sprites/enemy_spritesheet.png')
    print("Enemy spritesheet saved as 'sprites/enemy_spritesheet.png'")

def create_explosion_spritesheet():
    """Create explosion animation spritesheet with all 14 explosion frames"""
    print("Creating explosion spritesheet...")
    
    sprites = extract_sprite_data_from_annotations()
    
    explosion_sprites = [
        ('explosion_1', 'Explosion 1'),
        ('explosion_2', 'Explosion 2'),
        ('explosion_3', 'Explosion 3'),
        ('explosion_4', 'Explosion 4'),
        ('explosion_5', 'Explosion 5'),
        ('explosion_6', 'Explosion 6'),
        ('explosion_7', 'Explosion 7'),
        ('explosion_8', 'Explosion 8'),
        ('explosion_9', 'Explosion 9'),
        ('explosion_10', 'Explosion 10'),
        ('explosion_11', 'Explosion 11'),
        ('explosion_12', 'Explosion 12'),
        ('explosion_13', 'Explosion 13'),
        ('explosion_14', 'Explosion 14')
    ]
    
    scale = 8
    sprite_width = 8 * scale   # 8 pixels wide
    sprite_height = 12 * scale  # 12 rows tall
    
    # Layout: 7 columns x 2 rows
    cols = 7
    rows = 2
    sheet_width = cols * sprite_width + 80
    sheet_height = rows * sprite_height + 120
    
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (64, 64, 32))
    draw = ImageDraw.Draw(spritesheet)
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - EXPLOSION ANIMATION (8x12) - 14 FRAMES", fill=(255, 255, 255))
    
    for i, (sprite_key, label) in enumerate(explosion_sprites):
        if i >= cols * rows:
            break
            
        col = i % cols
        row = i // cols
        
        x = col * sprite_width + 40
        y = row * sprite_height + 50
        
        if sprite_key in sprites:
            sprite_img = create_sprite_image(sprites[sprite_key], scale)
            spritesheet.paste(sprite_img, (x, y))
            
            # Add label
            draw.text((x + 2, y + sprite_height + 5), f"Frame {i+1}", fill=(255, 255, 0))
    
    spritesheet.save('sprites/explosion_spritesheet.png')
    print("Explosion spritesheet saved as 'sprites/explosion_spritesheet.png'")

def create_animation_guide():
    """Create a visual guide showing sprite animations"""
    print("Creating animation guide...")
    
    sprites = extract_sprite_data_from_annotations()
    
    # Animation sequences
    animations = {
        'Walking Left': ['player_walking_left_1', 'player_walking_left_2'],
        'Walking Right': ['player_walking_right_1', 'player_walking_right_2'],
        'Walking Up/Down': ['player_walking_up_down_1', 'player_walking_up_down_2'],
        'Explosion': ['explosion_1', 'explosion_2', 'explosion_3', 'explosion_4', 'explosion_5']
    }
    
    scale = 10
    max_frames = 5
    player_sprite_width = 8 * scale   # Player sprites are 8 pixels wide
    player_sprite_height = 12 * scale  # Player sprites are 12 rows tall
    explosion_sprite_height = 8 * scale  # Explosion sprites are 8 rows tall
    
    sheet_width = max_frames * player_sprite_width + 100
    sheet_height = len(animations) * (player_sprite_height + 60) + 50
    
    spritesheet = Image.new('RGB', (sheet_width, sheet_height), (48, 48, 48))
    draw = ImageDraw.Draw(spritesheet)
    
    # Add title
    draw.text((10, 10), "K-RAZY SHOOT-OUT - ANIMATION SEQUENCES", fill=(255, 255, 255))
    
    y_offset = 50
    for anim_name, frame_list in animations.items():
        # Add animation name
        draw.text((20, y_offset), anim_name, fill=(255, 255, 0))
        
        # Draw frames
        for i, sprite_key in enumerate(frame_list):
            x = i * player_sprite_width + 50
            y = y_offset + 30
            
            if sprite_key in sprites:
                sprite_img = create_sprite_image(sprites[sprite_key], scale)
                spritesheet.paste(sprite_img, (x, y))
                
                # Add frame number
                draw.text((x + 5, y + sprite_img.height + 5), f"Frame {i+1}", fill=(200, 200, 200))
        
        y_offset += player_sprite_height + 60
    
    spritesheet.save('sprites/animation_guide.png')
    print("Animation guide saved as 'sprites/animation_guide.png'")

def main():
    """Generate all spritesheets based on annotated data"""
    # Ensure sprites directory exists
    os.makedirs('sprites', exist_ok=True)
    
    print("Generating K-Razy Shoot-Out spritesheets from annotated data...")
    print("=" * 60)
    
    try:
        create_player_spritesheet()
        create_enemy_spritesheet()
        create_explosion_spritesheet()
        create_animation_guide()
        
        print("\n" + "=" * 60)
        print("All spritesheets generated successfully!")
        print("Files created:")
        print("- sprites/player_spritesheet.png (ALL 15 player sprites)")
        print("- sprites/enemy_spritesheet.png")
        print("- sprites/explosion_spritesheet.png")
        print("- sprites/animation_guide.png")
        
    except Exception as e:
        print(f"Error generating spritesheets: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()