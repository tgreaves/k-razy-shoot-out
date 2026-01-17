#!/usr/bin/env python3
"""
Create the correct logo pattern using actual character definitions from the ROM
"""

def create_correct_logo():
    """Create the logo using actual character patterns"""
    
    # Pattern data arranged as 12 blocks wide
    pattern_rows = [
        [0x47, 0x4A, 0x49, 0x40, 0x4A, 0x4A, 0x49, 0x40, 0x47, 0x4A, 0x49, 0x40],  # Row 1
        [0x46, 0x4A, 0x45, 0x4A, 0x46, 0x4A, 0x45, 0x4A, 0x46, 0x4A, 0x45, 0x4A],  # Row 2
        [0x45, 0x43, 0x41, 0x4A, 0x49, 0x4A, 0x41, 0x4A, 0x49, 0x48, 0x40, 0x4A],  # Row 3
        [0x45, 0x48, 0x44, 0x4A, 0x46, 0x4A, 0x44, 0x42, 0x43, 0x4A, 0x45, 0x4A],  # Row 4
        [0x49, 0x4A, 0x45, 0x4A, 0x49, 0x4A, 0x45, 0x4A, 0x49, 0x4A, 0x45, 0x42],  # Row 5
        [0x4A, 0x46, 0x40, 0x4A, 0x4A, 0x46, 0x40, 0x42, 0x4A, 0x46, 0x40]         # Row 6 (11 blocks)
    ]
    
    # Actual character patterns from the ROM
    char_patterns = {
        0x40: [  # Character $40 - All empty
            "........",
            "........", 
            "........",
            "........",
            "........",
            "........",
            "........",
            "........"
        ],
        0x41: [  # Character $41 - Left top block
            ".###....",
            ".###....",
            ".###....",
            "........",
            "........",
            "........",
            "........",
            "........"
        ],
        0x42: [  # Character $42 - Right top block
            ".....###",
            ".....###",
            ".....###",
            "........",
            "........",
            "........",
            "........",
            "........"
        ],
        0x43: [  # Character $43 - Top blocks left and right
            ".###.###",
            ".###.###",
            ".###.###",
            "........",
            "........",
            "........",
            "........",
            "........"
        ],
        0x44: [  # Character $44 - Left bottom block
            "........",
            "........",
            "........",
            "........",
            ".###....",
            ".###....",
            ".###....",
            "........"
        ],
        0x45: [  # Character $45 - Left top and bottom blocks
            ".###....",
            ".###....",
            ".###....",
            "........",
            ".###....",
            ".###....",
            ".###....",
            "........"
        ],
        0x46: [  # Character $46 - Left blocks and top right
            ".###.###",
            ".###.###",
            ".###.###",
            "........",
            ".###....",
            ".###....",
            ".###....",
            "........"
        ],
        0x47: [  # Character $47 - Right bottom block
            "........",
            "........",
            "........",
            "........",
            ".....###",
            ".....###",
            ".....###",
            "........"
        ],
        0x48: [  # Character $48 - Bottom blocks left and right
            "........",
            "........",
            "........",
            "........",
            ".###.###",
            ".###.###",
            ".###.###",
            "........"
        ],
        0x49: [  # Character $49 - Left top, bottom left and right
            ".###....",
            ".###....",
            ".###....",
            "........",
            ".###.###",
            ".###.###",
            ".###.###",
            "........"
        ],
        0x4A: [  # Character $4A - All blocks (background pattern)
            ".###.###",
            ".###.###",
            ".###.###",
            "........",
            ".###.###",
            ".###.###",
            ".###.###",
            "........"
        ]
    }
    
    print("Correct Logo Pattern Using Actual Character Definitions")
    print("=" * 60)
    print()
    
    # Generate the complete logo
    for row_idx, pattern_row in enumerate(pattern_rows):
        print(f"Row {row_idx + 1} ({len(pattern_row)} blocks):")
        
        # For each line within the 8-pixel-tall characters
        for line_idx in range(8):
            line = ""
            for char_code in pattern_row:
                if char_code in char_patterns:
                    line += char_patterns[char_code][line_idx]
                else:
                    line += "????????"  # Unknown character
            
            print(f";   {line}")
        
        print(";")  # Empty line between rows
    
    print()
    print("First few characters verification:")
    print(f"First block ($47): Should be right bottom block")
    for i, line in enumerate(char_patterns[0x47]):
        print(f"  Row {i}: {line}")
    
    print(f"\nSecond block ($4A): Should be background pattern")  
    for i, line in enumerate(char_patterns[0x4A]):
        print(f"  Row {i}: {line}")

def main():
    """Create the correct logo"""
    try:
        create_correct_logo()
        
    except Exception as e:
        print(f"Error creating logo: {e}")

if __name__ == "__main__":
    main()