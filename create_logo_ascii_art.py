#!/usr/bin/env python3
"""
Create ASCII art representation of the logo pattern using character block definitions
"""

def create_logo_ascii_art():
    """Create ASCII art for the logo pattern"""
    
    # Pattern data arranged as 12 blocks wide
    pattern_rows = [
        [0x47, 0x4A, 0x49, 0x40, 0x4A, 0x4A, 0x49, 0x40, 0x47, 0x4A, 0x49, 0x40],  # Row 1
        [0x46, 0x4A, 0x45, 0x4A, 0x46, 0x4A, 0x45, 0x4A, 0x46, 0x4A, 0x45, 0x4A],  # Row 2
        [0x45, 0x43, 0x41, 0x4A, 0x49, 0x4A, 0x41, 0x4A, 0x49, 0x48, 0x40, 0x4A],  # Row 3
        [0x45, 0x48, 0x44, 0x4A, 0x46, 0x4A, 0x44, 0x42, 0x43, 0x4A, 0x45, 0x4A],  # Row 4
        [0x49, 0x4A, 0x45, 0x4A, 0x49, 0x4A, 0x45, 0x4A, 0x49, 0x4A, 0x45, 0x42],  # Row 5
        [0x4A, 0x46, 0x40, 0x4A, 0x4A, 0x46, 0x40, 0x42, 0x4A, 0x46, 0x40]         # Row 6 (11 blocks)
    ]
    
    # Define 8x8 patterns for each character block
    # These are educated guesses based on typical block graphics
    # Each character is 8 pixels wide by 8 pixels tall
    char_patterns = {
        0x40: [  # Solid block
            "########",
            "########", 
            "########",
            "########",
            "########",
            "########",
            "########",
            "########"
        ],
        0x41: [  # Dark shade (75% filled)
            "#.#.#.#.",
            ".#.#.#.#",
            "#.#.#.#.",
            ".#.#.#.#",
            "#.#.#.#.",
            ".#.#.#.#",
            "#.#.#.#.",
            ".#.#.#.#"
        ],
        0x42: [  # Medium shade (50% filled)
            "#.#.....",
            ".#......",
            "....#.#.",
            ".....#..",
            "#.#.....",
            ".#......",
            "....#.#.",
            ".....#.."
        ],
        0x43: [  # Light shade (25% filled)
            "#.......",
            "........",
            "....#...",
            "........",
            "#.......",
            "........",
            "....#...",
            "........"
        ],
        0x44: [  # Lower half block
            "........",
            "........",
            "........",
            "........",
            "########",
            "########",
            "########",
            "########"
        ],
        0x45: [  # Upper half block
            "########",
            "########",
            "########",
            "########",
            "........",
            "........",
            "........",
            "........"
        ],
        0x46: [  # Left half block
            "####....",
            "####....",
            "####....",
            "####....",
            "####....",
            "####....",
            "####....",
            "####...."
        ],
        0x47: [  # Right half block
            "....####",
            "....####",
            "....####",
            "....####",
            "....####",
            "....####",
            "....####",
            "....####"
        ],
        0x48: [  # Small solid square (center)
            "........",
            "..####..",
            "..####..",
            "..####..",
            "..####..",
            "..####..",
            "..####..",
            "........"
        ],
        0x49: [  # Small empty square (outline)
            "........",
            "..####..",
            "..#..#..",
            "..#..#..",
            "..#..#..",
            "..#..#..",
            "..####..",
            "........"
        ],
        0x4A: [  # Space/background
            "........",
            "........",
            "........",
            "........",
            "........",
            "........",
            "........",
            "........"
        ]
    }
    
    print("Title Screen Logo ASCII Art Representation")
    print("=" * 60)
    print()
    
    # Generate the complete logo by combining character patterns
    logo_lines = [""] * 8  # 8 lines tall (each character is 8 pixels tall)
    
    for row_idx, pattern_row in enumerate(pattern_rows):
        print(f"Processing row {row_idx + 1}: {len(pattern_row)} blocks")
        
        # For each line within the 8-pixel-tall characters
        for line_idx in range(8):
            line = ""
            for char_code in pattern_row:
                if char_code in char_patterns:
                    line += char_patterns[char_code][line_idx]
                else:
                    line += "????????"  # Unknown character
            
            # Add this line to the appropriate position in the logo
            logo_line_idx = row_idx * 8 + line_idx
            if logo_line_idx < len(logo_lines) * len(pattern_rows):
                if row_idx == 0:
                    logo_lines[line_idx] = line
                else:
                    # Extend the logo_lines array if needed
                    while len(logo_lines) <= logo_line_idx:
                        logo_lines.append("")
                    logo_lines[logo_line_idx] = line
    
    # Print the complete logo
    print("\nComplete Logo Pattern:")
    print("-" * 100)
    
    total_lines = len(pattern_rows) * 8
    for i in range(total_lines):
        if i < len(logo_lines):
            print(f";   {logo_lines[i]}")
        else:
            print(f";   (line {i} not generated)")
    
    print()
    print("Assembly format for inclusion:")
    print("-" * 40)
    
    # Show how it would look in the assembly file
    for i in range(total_lines):
        if i < len(logo_lines) and logo_lines[i]:
            print(f";   {logo_lines[i]}")

def main():
    """Create the ASCII art representation"""
    try:
        create_logo_ascii_art()
        
    except Exception as e:
        print(f"Error creating ASCII art: {e}")

if __name__ == "__main__":
    main()