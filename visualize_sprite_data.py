#!/usr/bin/env python3
"""
Visualize sprite data from the complete sprite data sections as ASCII art
"""

# Complete sprite data from BED0-BFD0 table
def get_complete_sprite_data_from_rom():
    """Extract the actual hex values from the ROM section BED0-BFD2"""
    # BED0-BF9A data (extracted from the disassembly)
    data = []
    
    # BED0-BEDF
    data.extend([0x6C, 0x54, 0x0F, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00])
    
    # BEE0-BEEF  
    data.extend([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x38, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
    # BEF0-BEFF
    data.extend([0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x2C, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
    # BF00-BF0F
    data.extend([0x00, 0x10, 0x00, 0x58, 0x00, 0x2C, 0x00, 0x50, 0x00, 0x10, 0x00, 0x00, 0x00, 0x38, 0x00, 0x92])
    
    # BF10-BF1F
    data.extend([0x00, 0x58, 0x00, 0xAA, 0x00, 0x54, 0x00, 0x54, 0x00, 0x00, 0x48, 0x10, 0x28, 0x92, 0x01, 0x58])
    
    # BF20-BF2F
    data.extend([0x00, 0x82, 0x00, 0x54, 0x00, 0xA0, 0x10, 0x44, 0x52, 0x24, 0x10, 0xA4, 0x09, 0xA0, 0x00, 0x00])
    
    # BF30-BF3F
    data.extend([0x84, 0x00, 0x55, 0x00, 0x29, 0x52, 0x52, 0xA4, 0x10, 0xA4, 0x01, 0x80, 0x01, 0x00, 0x80, 0x00])
    
    # BF40-BF4F
    data.extend([0x45, 0x00, 0xA8, 0x52, 0x52, 0x24, 0x10, 0x24, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00])
    
    # BF50-BF5F
    data.extend([0x29, 0x50, 0x50, 0xA1, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x80, 0x00, 0x00, 0x00, 0x81, 0x10])
    
    # BF60-BF6F
    data.extend([0x00, 0x40, 0x00, 0x02, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00, 0x20, 0x00, 0x00, 0x10, 0x00, 0x00])
    
    # BF70-BF7F
    data.extend([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x0C, 0x30, 0xC0])
    
    # BF80-BF8F
    data.extend([0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0xBD, 0xBD, 0x3C, 0x24, 0x24, 0x66, 0x7E, 0x18, 0x3F, 0x3D])
    
    # BF90-BF9A
    data.extend([0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x24, 0x24, 0x6C, 0x7E, 0x18, 0x3F])
    
    # BF9B-BFD2 - Final section with detailed sprite patterns (sprite data ends at BFD2)
    data.extend([0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3C, 0x08, 0x08,  # BF9B-BFA2
                 0x18, 0x7E, 0x18, 0xFC, 0xBC, 0xBC, 0xBC, 0xBC,  # BFA3-BFAA
                 0xBC, 0x3C, 0x24, 0x24, 0x36, 0x7E, 0x18, 0xFC,  # BFAB-BFB2
                 0xBC, 0xBC, 0xBC, 0xBC, 0xBC, 0x3C, 0x10, 0x10,  # BFB3-BFBA
                 0x18, 0x7E, 0x18, 0xFF, 0xBD, 0xBD, 0xBD, 0x3D,  # BFBB-BFC2
                 0x3D, 0x3C, 0x26, 0x20, 0x60, 0x7E, 0x18, 0xFF,  # BFC3-BFCA (BFC5-BFC7 now included as sprite data)
                 0xBD, 0xBD, 0xBD, 0xBC, 0xBC, 0x3C, 0x64, 0x04]) # BFCB-BFD2 (sprite data ends here)
    
    return data

def byte_to_ascii(byte_val):
    """Convert a byte to 8-character ASCII representation"""
    binary = format(byte_val, '08b')
    return ''.join('#' if bit == '1' else '.' for bit in binary)

def render_8x8_sprite(data, start_idx, name):
    """Render an 8x8 sprite from 8 consecutive bytes"""
    print(f"\n; {name}")
    for i in range(8):
        if start_idx + i < len(data):
            ascii_row = byte_to_ascii(data[start_idx + i])
            print(f";   {ascii_row}")
        else:
            print(";   ........")

def analyze_complete_sprite_data():
    """Analyze the complete sprite data from BED0-BFD2"""
    sprite_data = get_complete_sprite_data_from_rom()
    
    print("COMPLETE SPRITE DATA ANALYSIS - BED0-BFD2")
    print("=" * 60)
    
    # Look for interesting patterns and known character codes
    print("\nKNOWN CHARACTER CODES FOUND:")
    print("-" * 40)
    
    for i, byte_val in enumerate(sprite_data):
        hex_addr = 0xBED0 + i
        ascii_rep = byte_to_ascii(byte_val)
        
        # Look for known character patterns
        if byte_val == 0x1C:
            print(f"${hex_addr:04X}: {byte_val:02X} = {ascii_rep} <- ENEMY CHARACTER $1C")
        elif byte_val in [0x02, 0x03, 0x04, 0x05, 0x1E]:  # Known player characters
            print(f"${hex_addr:04X}: {byte_val:02X} = {ascii_rep} <- PLAYER CHARACTER ${byte_val:02X}")
        elif byte_val in [0x06, 0x07, 0x08, 0x09]:  # Death animation characters
            print(f"${hex_addr:04X}: {byte_val:02X} = {ascii_rep} <- DEATH ANIMATION ${byte_val:02X}")
    
    print("\n" + "=" * 60)
    print("DETAILED SPRITE PATTERNS FROM BF80-BFD2:")
    print("=" * 60)
    
    # Focus on the detailed sprite patterns from BF80 onwards
    detailed_start = 0xBF80 - 0xBED0  # Offset in our data array
    
    # Render the detailed patterns as 8x8 sprites
    pattern_addresses = [
        (0xBF80, "Title Screen/Special Effect Pattern 1"),
        (0xBF88, "Title Screen/Special Effect Pattern 2"), 
        (0xBF90, "Title Screen/Special Effect Pattern 3"),
        (0xBF98, "Title Screen/Special Effect Pattern 4"),
        (0xBFA0, "Title Screen/Special Effect Pattern 5"),
        (0xBFA8, "Title Screen/Special Effect Pattern 6"),
        (0xBFB0, "Title Screen/Special Effect Pattern 7"),
        (0xBFB8, "Title Screen/Special Effect Pattern 8"),
        (0xBFC0, "Title Screen/Special Effect Pattern 9"),
        (0xBFC8, "Title Screen/Special Effect Pattern 10 (Extended to BFD2)")
    ]
    
    for addr, name in pattern_addresses:
        if addr <= 0xBFD2:  # Sprite data ends at BFD2
            data_offset = addr - 0xBED0
            if data_offset + 7 < len(sprite_data):
                render_8x8_sprite(sprite_data, data_offset, f"{name} (${addr:04X})")
            elif addr == 0xBFC8:  # Special handling for the extended pattern
                # This pattern extends beyond 8 bytes, so render what we have
                print(f"\n; {name} (${addr:04X}) - EXTENDED 11-BYTE PATTERN")
                for i in range(11):  # BFC8-BFD2 = 11 bytes
                    if data_offset + i < len(sprite_data):
                        byte_val = sprite_data[data_offset + i]
                        ascii_row = byte_to_ascii(byte_val)
                        addr_label = f"${addr + i:04X}"
                        print(f";   {ascii_row}  ; {addr_label}")
    
    print("\n" + "=" * 60)
    print("SUMMARY OF FINDINGS:")
    print("=" * 60)
    print("- BED0-BF7F: Player sprite animation data and explosion sprites")
    print("- BF80-BFD2: Detailed sprite patterns (likely title screen or special effects)")
    print("- Complex patterns suggest these are used for visual effects or title graphics")
    print("- Multiple 8x8 sprite patterns with intricate designs")
    print("- Final pattern (BFC8-BFD2) extends to 11 bytes total")
    print("- BFD3+ contains actual assembly code, not sprite data")
    print("- Data is distinct from the simpler character set sprites")

if __name__ == "__main__":
    analyze_complete_sprite_data()