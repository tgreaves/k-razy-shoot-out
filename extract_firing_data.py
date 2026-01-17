#!/usr/bin/env python3
"""
Extract firing frequency data from K-Razy Shoot-Out ROM
Updated with correct Atari 5200 NTSC frame rate
"""

def extract_firing_data():
    with open('K-Razy Shoot-Out (USA).a52', 'rb') as f:
        rom = f.read()
        
    # $BBE4 in ROM is at offset $BBE4 - $A000 = $1BE4
    offset = 0x1BE4
    
    # Atari 5200 NTSC runs at approximately 59.92 Hz (not 60 Hz)
    # This is the VBI (Vertical Blank Interrupt) frequency
    atari_5200_fps = 59.92
    
    print('Level Parameter Tables at $BBE4:')
    print('Format: D1(accuracy) D7(firing_freq) D6(speed) D8(timing)')
    print(f'Frame Rate: {atari_5200_fps} Hz (Atari 5200 NTSC VBI frequency)')
    print()
    
    for i in range(8):  # Show 8 levels worth of data
        addr = 0xBBE4 + (i * 4)
        d1 = rom[offset + (i * 4)]
        d7 = rom[offset + (i * 4) + 1] 
        d6 = rom[offset + (i * 4) + 2]
        d8 = rom[offset + (i * 4) + 3]
        
        if d7 > 0:
            firing_rate = atari_5200_fps / d7
            period_ms = (d7 / atari_5200_fps) * 1000
        else:
            firing_rate = 0
            period_ms = 0
        
        print(f'Level {i}: ${addr:04X}: {d1:02X} {d7:02X} {d6:02X} {d8:02X}')
        print(f'         D1=${d1:02X}({d1}), D7=${d7:02X}({d7}), D6=${d6:02X}({d6}), D8=${d8:02X}({d8})')
        if d7 > 0:
            print(f'         Firing Rate: {firing_rate:.2f} shots/sec (every {period_ms:.0f}ms)')
        else:
            print(f'         Firing Rate: NO FIRING (tutorial level)')
        print()

if __name__ == '__main__':
    extract_firing_data()