#!/usr/bin/env python3
"""
Create Player Character Sprite Sheets for K-Razy Shoot-Out
Based on the game code analysis, this creates sprite sheets showing all possible
player character combinations for different movement states.
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Player character data extracted from ROM
PLAYER_CHARACTERS = {
    # Character $01 - Player body sprite (main torso)
    0x01: [0x38, 0x38, 0x38, 0x38, 0x18, 0x00, 0x18, 0x00],
    
    # Character $08 - Player left leg sprite  
    0x08: [0x00, 0x00, 0x00, 0x00, 0x01, 0xC3, 0xC7, 0xFF],
    
    # Character $09 - Player right leg sprite
    0x09: [0x00, 0x00, 0x00, 0x80, 0xC7, 0xE5, 0xFD, 0xF7]
}

def create_character_image(char_data, scale=8):
    """Create an 8x8 character image scaled up"""
    width = 8 * scale
    height = 8 * scale
    
    img = Image.new('RGB', (width, height), 'white')
    draw = ImageDraw.Draw(img)
    
    for row, byte_val in enumerate(char_data):
        for bit in range(8):
            if byte_val & (1 << (7 - bit)):
                # Draw a scaled pixel (black)
                x1 = bit * scale
                y1 = row * scale
                x2 = x1 + scale
                y2 = y1 + scale
                draw.rectangle([x1, y1, x2-1, y2-1], fill='black')
    
    return img

def create_composite_sprite(char_list, scale=8, spacing=2):
    """Create a composite sprite from multiple characters"""
    if not char_list:
        return create_character_image([0] * 8, scale)
    
    char_width = 8 * scale
    char_height = 8 * scale
    total_width = len(char_list) * char_width + (len(char_list) - 1) * spacing
    
    composite = Image.new('RGB', (total_width, char_height), 'white')
    
    x_offset = 0
    for char_id in char_list:
        if char_id in PLAYER_CHARACTERS:
            char_img = create_character_image(PLAYER_CHARACTERS[char_id], scale)
            composite.paste(char_img, (x_offset, 0))
        x_offset += char_width + spacing
    
    return composite

def create_ascii_art(char_data):
    """Create ASCII art representation of character"""
    lines = []
    for byte_val in char_data:
        line = ""
        for bit in range(7, -1, -1):
            if byte_val & (1 << bit):
                line += "█"
            else:
                line += "·"
        lines.append(line)
    return lines

def create_player_sprite_sheet():
    """Create comprehensive player sprite sheets"""
    
    # Create output directory
    os.makedirs('player_sprites', exist_ok=True)
    
    scale = 16  # Large scale for clear visibility
    spacing = 4
    
    # Define all possible player states based on game analysis
    player_states = {
        'standing_still': {
            'description': 'Standing Still (Idle)',
            'sprites': [0x01],  # Just the body
            'explanation': 'Player at rest - only body sprite visible'
        },
        
        'moving_vertical': {
            'description': 'Moving Up/Down (Vertical Movement)',
            'sprites': [0x01, 0x08],  # Body + left leg
            'explanation': 'Vertical movement uses body + left leg sprite'
        },
        
        'moving_horizontal_left': {
            'description': 'Moving Left/Right - Left Step',
            'sprites': [0x01, 0x08],  # Body + left leg
            'explanation': 'Horizontal movement - left leg forward'
        },
        
        'moving_horizontal_right': {
            'description': 'Moving Left/Right - Right Step', 
            'sprites': [0x01, 0x09],  # Body + right leg
            'explanation': 'Horizontal movement - right leg forward'
        },
        
        'moving_diagonal_left': {
            'description': 'Moving Diagonally - Left Step',
            'sprites': [0x01, 0x08],  # Body + left leg
            'explanation': 'Diagonal movement combines vertical + horizontal logic'
        },
        
        'moving_diagonal_right': {
            'description': 'Moving Diagonally - Right Step',
            'sprites': [0x01, 0x09],  # Body + right leg  
            'explanation': 'Diagonal movement with right leg forward'
        }
    }
    
    # Create individual character sheets
    print("Creating individual character sprites...")
    for char_id, char_data in PLAYER_CHARACTERS.items():
        img = create_character_image(char_data, scale)
        filename = f'player_sprites/character_{char_id:02X}.png'
        img.save(filename)
        print(f"  Saved: {filename}")
    
    # Create composite sprite sheet
    print("\nCreating composite sprite sheet...")
    
    # Calculate dimensions for the complete sheet
    max_sprites = max(len(state['sprites']) for state in player_states.values())
    char_width = 8 * scale
    char_height = 8 * scale
    state_width = max_sprites * char_width + (max_sprites - 1) * spacing
    state_height = char_height + 60  # Extra space for labels
    
    sheet_width = state_width + 40  # Margins
    sheet_height = len(player_states) * state_height + 100  # Title space
    
    sprite_sheet = Image.new('RGB', (sheet_width, sheet_height), 'white')
    draw = ImageDraw.Draw(sprite_sheet)
    
    # Try to load a font, fall back to default if not available
    try:
        title_font = ImageFont.truetype("arial.ttf", 24)
        label_font = ImageFont.truetype("arial.ttf", 14)
        small_font = ImageFont.truetype("arial.ttf", 10)
    except:
        title_font = ImageFont.load_default()
        label_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Title
    title = "K-Razy Shoot-Out Player Character Sprite Sheet"
    draw.text((20, 20), title, fill='black', font=title_font)
    draw.text((20, 50), "Based on ROM Analysis - All Movement States", fill='gray', font=label_font)
    
    y_offset = 100
    
    for state_name, state_info in player_states.items():
        # Create composite sprite for this state
        composite = create_composite_sprite(state_info['sprites'], scale, spacing)
        
        # Paste onto main sheet
        sprite_sheet.paste(composite, (20, y_offset))
        
        # Add labels
        draw.text((20, y_offset + char_height + 10), state_info['description'], 
                 fill='black', font=label_font)
        draw.text((20, y_offset + char_height + 30), state_info['explanation'], 
                 fill='gray', font=small_font)
        
        # Add sprite IDs
        sprite_ids = " + ".join([f"${sprite_id:02X}" for sprite_id in state_info['sprites']])
        draw.text((20, y_offset + char_height + 45), f"Sprites: {sprite_ids}", 
                 fill='blue', font=small_font)
        
        y_offset += state_height
    
    sprite_sheet.save('player_sprites/complete_sprite_sheet.png')
    print("  Saved: player_sprites/complete_sprite_sheet.png")
    
    # Create animation sequence sheet
    print("\nCreating animation sequence sheet...")
    
    # Show walking animation sequence
    walking_sequence = [
        ('Step 1', [0x01, 0x08]),  # Left leg
        ('Step 2', [0x01]),        # Standing
        ('Step 3', [0x01, 0x09]),  # Right leg
        ('Step 4', [0x01])         # Standing
    ]
    
    seq_width = len(walking_sequence) * (char_width * 2 + spacing) + 40
    seq_height = char_height + 120
    
    anim_sheet = Image.new('RGB', (seq_width, seq_height), 'white')
    draw = ImageDraw.Draw(anim_sheet)
    
    draw.text((20, 20), "Player Walking Animation Sequence", fill='black', font=title_font)
    draw.text((20, 50), "Horizontal Movement Animation Cycle", fill='gray', font=label_font)
    
    x_offset = 20
    for step_name, sprites in walking_sequence:
        composite = create_composite_sprite(sprites, scale, spacing)
        anim_sheet.paste(composite, (x_offset, 80))
        
        # Add step label
        draw.text((x_offset, 80 + char_height + 10), step_name, fill='black', font=label_font)
        
        x_offset += char_width * 2 + spacing + 20
    
    anim_sheet.save('player_sprites/walking_animation.png')
    print("  Saved: player_sprites/walking_animation.png")
    
    # Create technical reference sheet
    print("\nCreating technical reference sheet...")
    
    tech_width = 800
    tech_height = 600
    tech_sheet = Image.new('RGB', (tech_width, tech_height), 'white')
    draw = ImageDraw.Draw(tech_sheet)
    
    draw.text((20, 20), "Technical Reference - Character Data", fill='black', font=title_font)
    
    y_pos = 60
    for char_id, char_data in PLAYER_CHARACTERS.items():
        # Character image
        char_img = create_character_image(char_data, 8)
        tech_sheet.paste(char_img, (20, y_pos))
        
        # Character info
        draw.text((100, y_pos), f"Character ${char_id:02X}", fill='black', font=label_font)
        
        if char_id == 0x01:
            draw.text((100, y_pos + 20), "Player Body Sprite (Main Torso)", fill='gray', font=small_font)
        elif char_id == 0x08:
            draw.text((100, y_pos + 20), "Player Left Leg Sprite", fill='gray', font=small_font)
        elif char_id == 0x09:
            draw.text((100, y_pos + 20), "Player Right Leg Sprite", fill='gray', font=small_font)
        
        # Hex data
        hex_data = " ".join([f"{b:02X}" for b in char_data])
        draw.text((100, y_pos + 40), f"Data: {hex_data}", fill='blue', font=small_font)
        
        # ASCII art
        ascii_art = create_ascii_art(char_data)
        for i, line in enumerate(ascii_art):
            draw.text((300, y_pos + i * 12), line, fill='black', font=small_font)
        
        y_pos += 120
    
    # Add movement logic explanation
    draw.text((20, y_pos), "Movement Logic (from game code analysis):", fill='black', font=label_font)
    y_pos += 30
    
    explanations = [
        "• Horizontal movement detected: $C004 & $04 → sets flag $AD = 1",
        "• Vertical movement: $C00C register processed separately", 
        "• Standing still: Only character $01 (body) displayed",
        "• Moving up/down: Character $01 + $08 (body + left leg)",
        "• Moving left/right: Alternates $01+$08 and $01+$09 (walking cycle)",
        "• Animation synchronized to VBlank interrupt (59.92 Hz)",
        "• Hardware registers $E804-$E807 control sprite display"
    ]
    
    for explanation in explanations:
        draw.text((20, y_pos), explanation, fill='black', font=small_font)
        y_pos += 20
    
    tech_sheet.save('player_sprites/technical_reference.png')
    print("  Saved: player_sprites/technical_reference.png")
    
    # Create summary
    print(f"\n✓ Player sprite sheets created successfully!")
    print(f"  Output directory: player_sprites/")
    print(f"  Files created:")
    print(f"    - character_01.png (body sprite)")
    print(f"    - character_08.png (left leg sprite)")  
    print(f"    - character_09.png (right leg sprite)")
    print(f"    - complete_sprite_sheet.png (all movement states)")
    print(f"    - walking_animation.png (animation sequence)")
    print(f"    - technical_reference.png (technical details)")
    
    return True

if __name__ == "__main__":
    create_player_sprite_sheet()