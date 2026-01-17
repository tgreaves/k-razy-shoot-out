#!/usr/bin/env python3
"""
Advanced Player Sprite Analysis for K-Razy Shoot-Out
Creates detailed sprite sheets with movement analysis based on game code
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Player character data from ROM analysis
PLAYER_CHARACTERS = {
    0x01: [0x38, 0x38, 0x38, 0x38, 0x18, 0x00, 0x18, 0x00],  # Body
    0x08: [0x00, 0x00, 0x00, 0x00, 0x01, 0xC3, 0xC7, 0xFF],  # Left leg
    0x09: [0x00, 0x00, 0x00, 0x80, 0xC7, 0xE5, 0xFD, 0xF7]   # Right leg
}

def create_character_image(char_data, scale=8, color='black'):
    """Create an 8x8 character image scaled up with specified color"""
    width = 8 * scale
    height = 8 * scale
    
    img = Image.new('RGBA', (width, height), (255, 255, 255, 0))  # Transparent background
    draw = ImageDraw.Draw(img)
    
    # Color mapping
    colors = {
        'black': (0, 0, 0, 255),
        'blue': (0, 100, 200, 255),
        'red': (200, 0, 0, 255),
        'green': (0, 150, 0, 255)
    }
    
    fill_color = colors.get(color, colors['black'])
    
    for row, byte_val in enumerate(char_data):
        for bit in range(8):
            if byte_val & (1 << (7 - bit)):
                x1 = bit * scale
                y1 = row * scale
                x2 = x1 + scale
                y2 = y1 + scale
                draw.rectangle([x1, y1, x2-1, y2-1], fill=fill_color)
    
    return img

def create_layered_sprite(sprite_layers, scale=8):
    """Create a sprite with multiple colored layers"""
    width = 8 * scale
    height = 8 * scale
    
    composite = Image.new('RGBA', (width, height), (255, 255, 255, 255))
    
    for char_id, color in sprite_layers:
        if char_id in PLAYER_CHARACTERS:
            layer = create_character_image(PLAYER_CHARACTERS[char_id], scale, color)
            composite = Image.alpha_composite(composite, layer)
    
    return composite

def create_movement_analysis_sheet():
    """Create detailed movement analysis based on game code"""
    
    os.makedirs('player_sprites', exist_ok=True)
    
    scale = 20
    
    # Movement states with detailed analysis
    movement_states = {
        'idle': {
            'name': 'Standing Still (Idle State)',
            'sprites': [(0x01, 'blue')],
            'code_analysis': [
                'No joystick input detected ($C004 = 0, $C00C = 0)',
                'Horizontal movement flag $AD = 0',
                'Only body sprite (Character $01) displayed',
                'Player remains stationary on screen'
            ],
            'hardware': 'Single sprite in hardware register $E804'
        },
        
        'vertical_up': {
            'name': 'Moving Up (Vertical Movement)',
            'sprites': [(0x01, 'blue'), (0x08, 'red')],
            'code_analysis': [
                'Vertical input detected: $C00C register active',
                'Horizontal flag $AD remains 0 (no horizontal movement)',
                'Body + left leg combination selected',
                'Y-coordinate decreases each frame'
            ],
            'hardware': 'Body in $E804, left leg in $E805'
        },
        
        'vertical_down': {
            'name': 'Moving Down (Vertical Movement)', 
            'sprites': [(0x01, 'blue'), (0x08, 'red')],
            'code_analysis': [
                'Vertical input detected: $C00C register active',
                'Same sprite combination as moving up',
                'Direction determined by joystick value, not sprite',
                'Y-coordinate increases each frame'
            ],
            'hardware': 'Body in $E804, left leg in $E805'
        },
        
        'horizontal_left_step1': {
            'name': 'Moving Left - Animation Frame 1',
            'sprites': [(0x01, 'blue'), (0x08, 'red')],
            'code_analysis': [
                'Horizontal input: $C004 & $04 = true',
                'Sets horizontal movement flag: $AD = 1',
                'Walking animation frame 1: left leg forward',
                'X-coordinate decreases each frame'
            ],
            'hardware': 'Animated sprite sequence in PMG system'
        },
        
        'horizontal_left_step2': {
            'name': 'Moving Left - Animation Frame 2',
            'sprites': [(0x01, 'blue'), (0x09, 'green')],
            'code_analysis': [
                'Continuation of horizontal movement',
                'Walking animation frame 2: right leg forward',
                'Alternates with frame 1 for walking effect',
                'Synchronized to VBlank timing (59.92 Hz)'
            ],
            'hardware': 'Hardware sprite registers updated each VBlank'
        },
        
        'horizontal_right_step1': {
            'name': 'Moving Right - Animation Frame 1',
            'sprites': [(0x01, 'blue'), (0x08, 'red')],
            'code_analysis': [
                'Same sprite logic as moving left',
                'Direction determined by joystick sign, not sprite',
                'X-coordinate increases each frame',
                'Uses same walking animation cycle'
            ],
            'hardware': 'Mirror of left movement in hardware'
        },
        
        'horizontal_right_step2': {
            'name': 'Moving Right - Animation Frame 2',
            'sprites': [(0x01, 'blue'), (0x09, 'green')],
            'code_analysis': [
                'Right leg forward in walking cycle',
                'Completes the walking animation sequence',
                'Hardware collision detection active',
                'Boundary checking at screen edges'
            ],
            'hardware': 'Complete walking cycle in PMG system'
        },
        
        'diagonal_ne': {
            'name': 'Moving Diagonally (Northeast)',
            'sprites': [(0x01, 'blue'), (0x08, 'red')],
            'code_analysis': [
                'Combined input: both $C004 and $C00C active',
                'Horizontal flag $AD = 1 (horizontal takes priority)',
                'Uses horizontal movement sprite selection',
                'Both X and Y coordinates change each frame'
            ],
            'hardware': 'Combines horizontal and vertical movement logic'
        },
        
        'diagonal_se': {
            'name': 'Moving Diagonally (Southeast)',
            'sprites': [(0x01, 'blue'), (0x09, 'green')],
            'code_analysis': [
                'Diagonal movement with right leg animation',
                'Complex joystick input processing',
                'Movement vector calculated from both axes',
                'Maintains walking animation during diagonal movement'
            ],
            'hardware': 'Full 8-directional movement support'
        }
    }
    
    # Create comprehensive analysis sheet
    sheet_width = 1200
    sheet_height = len(movement_states) * 200 + 200
    
    analysis_sheet = Image.new('RGB', (sheet_width, sheet_height), 'white')
    draw = ImageDraw.Draw(analysis_sheet)
    
    # Try to load fonts
    try:
        title_font = ImageFont.truetype("arial.ttf", 20)
        header_font = ImageFont.truetype("arial.ttf", 14)
        text_font = ImageFont.truetype("arial.ttf", 10)
    except:
        title_font = ImageFont.load_default()
        header_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    # Title
    draw.text((20, 20), "K-Razy Shoot-Out: Complete Player Movement Analysis", 
              fill='black', font=title_font)
    draw.text((20, 50), "Based on 6502 Assembly Code Analysis and Hardware Register Usage", 
              fill='gray', font=header_font)
    
    y_offset = 100
    
    for state_key, state_info in movement_states.items():
        # Create sprite image
        sprite_img = create_layered_sprite(state_info['sprites'], scale)
        analysis_sheet.paste(sprite_img, (20, y_offset), sprite_img)
        
        # State name
        draw.text((200, y_offset), state_info['name'], fill='black', font=header_font)
        
        # Sprite composition
        sprite_desc = " + ".join([f"${char_id:02X}({color})" for char_id, color in state_info['sprites']])
        draw.text((200, y_offset + 25), f"Sprites: {sprite_desc}", fill='blue', font=text_font)
        
        # Hardware info
        draw.text((200, y_offset + 40), f"Hardware: {state_info['hardware']}", 
                 fill='purple', font=text_font)
        
        # Code analysis
        draw.text((200, y_offset + 60), "Code Analysis:", fill='black', font=text_font)
        for i, analysis in enumerate(state_info['code_analysis']):
            draw.text((220, y_offset + 75 + i * 15), f"• {analysis}", fill='darkgreen', font=text_font)
        
        y_offset += 180
    
    analysis_sheet.save('player_sprites/movement_analysis.png')
    
    # Create hardware register mapping sheet
    create_hardware_mapping_sheet(scale)
    
    # Create animation timing sheet
    create_animation_timing_sheet(scale)
    
    print("✓ Advanced player sprite analysis created!")
    print("  Files created:")
    print("    - movement_analysis.png (detailed movement states)")
    print("    - hardware_mapping.png (hardware register usage)")
    print("    - animation_timing.png (VBlank synchronization)")

def create_hardware_mapping_sheet(scale=16):
    """Create sheet showing hardware register mapping"""
    
    sheet_width = 1000
    sheet_height = 800
    
    hw_sheet = Image.new('RGB', (sheet_width, sheet_height), 'white')
    draw = ImageDraw.Draw(hw_sheet)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 18)
        header_font = ImageFont.truetype("arial.ttf", 14)
        text_font = ImageFont.truetype("arial.ttf", 10)
        code_font = ImageFont.truetype("consolas.ttf", 9)
    except:
        title_font = ImageFont.load_default()
        header_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        code_font = ImageFont.load_default()
    
    draw.text((20, 20), "Atari 5200 Hardware Register Mapping for Player Sprites", 
              fill='black', font=title_font)
    
    y_pos = 60
    
    # Hardware registers
    registers = [
        ('$E804', 'Player Sprite Position Register', 'Stores player body sprite ($01) position'),
        ('$E805', 'Player Sprite Control Register', 'Controls leg sprite ($08/$09) display'),
        ('$E806', 'Animation Frame Register', 'Tracks current animation frame (0-13)'),
        ('$E807', 'Animation Speed Register', 'Controls animation timing speed'),
        ('$C004', 'Joystick X-Axis Input', 'Horizontal movement detection ($04 bit)'),
        ('$C00C', 'Joystick Y-Axis Input', 'Vertical movement detection'),
        ('$AD', 'Horizontal Movement Flag', 'Set to 1 when horizontal movement detected'),
        ('$93', 'Joystick Input Flag', 'General joystick input confirmation')
    ]
    
    for reg_addr, reg_name, reg_desc in registers:
        draw.text((20, y_pos), reg_addr, fill='blue', font=code_font)
        draw.text((80, y_pos), reg_name, fill='black', font=header_font)
        draw.text((80, y_pos + 20), reg_desc, fill='gray', font=text_font)
        y_pos += 50
    
    # Code examples
    y_pos += 20
    draw.text((20, y_pos), "Key Code Sequences:", fill='black', font=header_font)
    y_pos += 30
    
    code_examples = [
        ("Horizontal Movement Detection:", [
            "$A952: AD 04 C0 LDA $C004  ; Read joystick X-axis",
            "$A955: 29 04    AND #$04   ; Check horizontal bit", 
            "$A957: F0 04    BEQ $A95D  ; Branch if no horizontal input",
            "$A959: A9 01    LDA #$01   ; HORIZONTAL MOVEMENT DETECTED",
            "$A95B: 85 AD    STA $AD    ; Set horizontal movement flag"
        ]),
        ("Animation Engine:", [
            "$A63B: A9 40    LDA #$40   ; Initialize animation system",
            "$A63F: 8D 0E E8 STA $E80E  ; Store in animation control register",
            "$A657: 8D 06 E8 STA $E806  ; Update animation register",
            "$A675: 8D 07 E8 STA $E807  ; Store to speed register"
        ])
    ]
    
    for title, code_lines in code_examples:
        draw.text((20, y_pos), title, fill='darkblue', font=text_font)
        y_pos += 20
        for code_line in code_lines:
            draw.text((40, y_pos), code_line, fill='darkgreen', font=code_font)
            y_pos += 15
        y_pos += 10
    
    hw_sheet.save('player_sprites/hardware_mapping.png')

def create_animation_timing_sheet(scale=12):
    """Create sheet showing VBlank timing and animation synchronization"""
    
    sheet_width = 1200
    sheet_height = 600
    
    timing_sheet = Image.new('RGB', (sheet_width, sheet_height), 'white')
    draw = ImageDraw.Draw(timing_sheet)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 18)
        header_font = ImageFont.truetype("arial.ttf", 14)
        text_font = ImageFont.truetype("arial.ttf", 10)
    except:
        title_font = ImageFont.load_default()
        header_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    draw.text((20, 20), "Player Animation Timing - VBlank Synchronization", 
              fill='black', font=title_font)
    draw.text((20, 50), "Atari 5200 NTSC: 59.92 Hz VBlank Interrupt", 
              fill='gray', font=header_font)
    
    # Animation timeline
    y_pos = 100
    frame_width = 80
    frame_height = 60
    
    # Walking cycle frames
    walking_frames = [
        ("Frame 1", [(0x01, 'blue'), (0x08, 'red')], "Left leg forward"),
        ("Frame 2", [(0x01, 'blue')], "Standing position"),
        ("Frame 3", [(0x01, 'blue'), (0x09, 'green')], "Right leg forward"),
        ("Frame 4", [(0x01, 'blue')], "Standing position")
    ]
    
    draw.text((20, y_pos), "Walking Animation Cycle (Horizontal Movement):", 
              fill='black', font=header_font)
    y_pos += 30
    
    x_pos = 20
    for frame_name, sprites, description in walking_frames:
        # Frame box
        draw.rectangle([x_pos, y_pos, x_pos + frame_width, y_pos + frame_height], 
                      outline='black', width=2)
        
        # Mini sprite
        mini_sprite = create_layered_sprite(sprites, 4)
        timing_sheet.paste(mini_sprite, (x_pos + 10, y_pos + 5), mini_sprite)
        
        # Labels
        draw.text((x_pos + 5, y_pos + frame_height + 5), frame_name, 
                 fill='black', font=text_font)
        draw.text((x_pos + 5, y_pos + frame_height + 20), description, 
                 fill='gray', font=text_font)
        
        # Timing arrow
        if x_pos < 20 + 3 * (frame_width + 20):
            draw.line([x_pos + frame_width + 5, y_pos + frame_height//2, 
                      x_pos + frame_width + 15, y_pos + frame_height//2], 
                     fill='red', width=2)
            draw.text((x_pos + frame_width + 8, y_pos + frame_height//2 - 10), 
                     "16.7ms", fill='red', font=text_font)
        
        x_pos += frame_width + 20
    
    # Timing information
    y_pos += 120
    timing_info = [
        "VBlank Frequency: 59.92 Hz (NTSC)",
        "Frame Duration: 16.69 ms per frame",
        "Animation Speed: Controlled by $E807 register",
        "Frame Counter: $B3 tracks current animation frame (0-13)",
        "Synchronization: Game loop synchronized to VBlank interrupt",
        "Hardware: PMG (Player/Missile Graphics) system handles sprite display"
    ]
    
    draw.text((20, y_pos), "Technical Details:", fill='black', font=header_font)
    y_pos += 25
    
    for info in timing_info:
        draw.text((40, y_pos), f"• {info}", fill='darkblue', font=text_font)
        y_pos += 20
    
    timing_sheet.save('player_sprites/animation_timing.png')

if __name__ == "__main__":
    create_movement_analysis_sheet()