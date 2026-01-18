#!/usr/bin/env python3
"""
Fix incorrect immediate mode notation in disassembly.
The issue: opcodes like A5, A6, A4, B5, B6, B4 are zero-page addressing,
but were incorrectly notated with # (immediate mode indicator).
"""

import re

def fix_disassembly_notation(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Track changes
    changes = 0
    
    # Fix patterns:
    # A5 XX LDA #$XX -> LDA $XX (zero page)
    # A6 XX LDX #$XX -> LDX $XX (zero page)
    # A4 XX LDY #$XX -> LDY $XX (zero page)
    # B5 XX LDA #$XX,X -> LDA $XX,X (zero page indexed)
    # B6 XX LDX #$XX,Y -> LDX $XX,Y (zero page indexed)
    # B4 XX LDY #$XX,X -> LDY $XX,X (zero page indexed)
    
    patterns = [
        # Zero page addressing (no index)
        (r'(\$[0-9A-F]{4}: A5 [0-9A-F]{2}\s+)LDA #(\$[0-9A-F]{2})', r'\1LDA \2'),
        (r'(\$[0-9A-F]{4}: A6 [0-9A-F]{2}\s+)LDX #(\$[0-9A-F]{2})', r'\1LDX \2'),
        (r'(\$[0-9A-F]{4}: A4 [0-9A-F]{2}\s+)LDY #(\$[0-9A-F]{2})', r'\1LDY \2'),
        
        # Zero page indexed addressing
        (r'(\$[0-9A-F]{4}: B5 [0-9A-F]{2}\s+)LDA #(\$[0-9A-F]{2})', r'\1LDA \2,X'),
        (r'(\$[0-9A-F]{4}: B6 [0-9A-F]{2}\s+)LDX #(\$[0-9A-F]{2})', r'\1LDX \2,Y'),
        (r'(\$[0-9A-F]{4}: B4 [0-9A-F]{2}\s+)LDY #(\$[0-9A-F]{2})', r'\1LDY \2,X'),
    ]
    
    for pattern, replacement in patterns:
        new_content, count = re.subn(pattern, replacement, content)
        if count > 0:
            print(f"Fixed {count} instances of pattern: {pattern[:50]}...")
            changes += count
            content = new_content
    
    if changes > 0:
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\nTotal changes: {changes}")
        print(f"Updated {filename}")
    else:
        print("No changes needed")
    
    return changes

if __name__ == '__main__':
    changes = fix_disassembly_notation('K_RAZY_SHOOTOUT_ANNOTATED.asm')
    print(f"\nDone! Fixed {changes} notation errors.")
