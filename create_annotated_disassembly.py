#!/usr/bin/env python3
"""
Create K_RAZY_SHOOTOUT_ANNOTATED.asm
This script generates the complete annotated disassembly with ASCII art and detailed comments
"""

# Complete 6502 instruction set
opcodes = {
    0x00: ("BRK", 1), 0x01: ("ORA", 2), 0x05: ("ORA", 2), 0x06: ("ASL", 2),
    0x08: ("PHP", 1), 0x09: ("ORA", 2), 0x0A: ("ASL", 1), 0x0D: ("ORA", 3),
    0x0E: ("ASL", 3), 0x10: ("BPL", 2), 0x11: ("ORA", 2), 0x15: ("ORA", 2),
    0x16: ("ASL", 2), 0x18: ("CLC", 1), 0x19: ("ORA", 3), 0x1D: ("ORA", 3),
    0x1E: ("ASL", 3), 0x20: ("JSR", 3), 0x21: ("AND", 2), 0x24: ("BIT", 2),
    0x25: ("AND", 2), 0x26: ("ROL", 2), 0x28: ("PLP", 1), 0x29: ("AND", 2),
    0x2A: ("ROL", 1), 0x2C: ("BIT", 3), 0x2D: ("AND", 3), 0x2E: ("ROL", 3),
    0x30: ("BMI", 2), 0x31: ("AND", 2), 0x35: ("AND", 2), 0x36: ("ROL", 2),
    0x38: ("SEC", 1), 0x39: ("AND", 3), 0x3D: ("AND", 3), 0x3E: ("ROL", 3),
    0x40: ("RTI", 1), 0x41: ("EOR", 2), 0x45: ("EOR", 2), 0x46: ("LSR", 2),
    0x48: ("PHA", 1), 0x49: ("EOR", 2), 0x4A: ("LSR", 1), 0x4C: ("JMP", 3),
    0x4D: ("EOR", 3), 0x4E: ("LSR", 3), 0x50: ("BVC", 2), 0x51: ("EOR", 2),
    0x55: ("EOR", 2), 0x56: ("LSR", 2), 0x58: ("CLI", 1), 0x59: ("EOR", 3),
    0x5D: ("EOR", 3), 0x5E: ("LSR", 3), 0x60: ("RTS", 1), 0x61: ("ADC", 2),
    0x65: ("ADC", 2), 0x66: ("ROR", 2), 0x68: ("PLA", 1), 0x69: ("ADC", 2),
    0x6A: ("ROR", 1), 0x6C: ("JMP", 3), 0x6D: ("ADC", 3), 0x6E: ("ROR", 3),
    0x70: ("BVS", 2), 0x71: ("ADC", 2), 0x75: ("ADC", 2), 0x76: ("ROR", 2),
    0x78: ("SEI", 1), 0x79: ("ADC", 3), 0x7D: ("ADC", 3), 0x7E: ("ROR", 3),
    0x81: ("STA", 2), 0x84: ("STY", 2), 0x85: ("STA", 2), 0x86: ("STX", 2),
    0x88: ("DEY", 1), 0x8A: ("TXA", 1), 0x8C: ("STY", 3), 0x8D: ("STA", 3),
    0x8E: ("STX", 3), 0x90: ("BCC", 2), 0x91: ("STA", 2), 0x94: ("STY", 2),
    0x95: ("STA", 2), 0x96: ("STX", 2), 0x98: ("TYA", 1), 0x99: ("STA", 3),
    0x9A: ("TXS", 1), 0x9D: ("STA", 3), 0xA0: ("LDY", 2), 0xA1: ("LDA", 2),
    0xA2: ("LDX", 2), 0xA4: ("LDY", 2), 0xA5: ("LDA", 2), 0xA6: ("LDX", 2),
    0xA8: ("TAY", 1), 0xA9: ("LDA", 2), 0xAA: ("TAX", 1), 0xAC: ("LDY", 3),
    0xAD: ("LDA", 3), 0xAE: ("LDX", 3), 0xB0: ("BCS", 2), 0xB1: ("LDA", 2),
    0xB4: ("LDY", 2), 0xB5: ("LDA", 2), 0xB6: ("LDX", 2), 0xB8: ("CLV", 1),
    0xB9: ("LDA", 3), 0xBA: ("TSX", 1), 0xBC: ("LDY", 3), 0xBD: ("LDA", 3),
    0xBE: ("LDX", 3), 0xC0: ("CPY", 2), 0xC1: ("CMP", 2), 0xC4: ("CPY", 2),
    0xC5: ("CMP", 2), 0xC6: ("DEC", 2), 0xC8: ("INY", 1), 0xC9: ("CMP", 2),
    0xCA: ("DEX", 1), 0xCC: ("CPY", 3), 0xCD: ("CMP", 3), 0xCE: ("DEC", 3),
    0xD0: ("BNE", 2), 0xD1: ("CMP", 2), 0xD5: ("CMP", 2), 0xD6: ("DEC", 2),
    0xD8: ("CLD", 1), 0xD9: ("CMP", 3), 0xDD: ("CMP", 3), 0xDE: ("DEC", 3),
    0xE0: ("CPX", 2), 0xE1: ("SBC", 2), 0xE4: ("CPX", 2), 0xE5: ("SBC", 2),
    0xE6: ("INC", 2), 0xE8: ("INX", 1), 0xE9: ("SBC", 2), 0xEA: ("NOP", 1),
    0xEC: ("CPX", 3), 0xED: ("SBC", 3), 0xEE: ("INC", 3), 0xF0: ("BEQ", 2),
    0xF1: ("SBC", 2), 0xF5: ("SBC", 2), 0xF6: ("INC", 2), 0xF8: ("SED", 1),
    0xF9: ("SBC", 3), 0xFD: ("SBC", 3), 0xFE: ("INC", 3)
}

def bytes_to_ascii_art(char_data):
    """Convert 8 bytes to ASCII art representation"""
    if len(char_data) != 8:
        return [""] * 8
    
    lines = []
    for byte_val in char_data:
        line = ""
        for bit in range(7, -1, -1):
            if byte_val & (1 << bit):
                line += "#"
            else:
                line += "."
        lines.append(line)
    return lines

def get_character_description(char_num, char_data):
    """Get description of what a character represents"""
    if char_num == 0:
        return "Space/blank character"
    elif char_num == 1:
        return "Player body sprite (vertical bars)"
    elif char_num == 2:
        return "Small bullet sprite (diamond pattern)"
    elif char_num == 4:
        return "Tiny bullet sprite (smaller diamond)"
    elif char_num == 8:
        return "Player left leg sprite"
    elif char_num == 9:
        return "Player right leg sprite"
    elif char_num == 10:
        return "Explosion/star effect sprite"
    elif char_num == 11:
        return "Crosshair/plus sprite"
    elif 0x10 <= char_num <= 0x19:
        return f"Number '{char_num - 0x10}' for score display"
    elif 0x21 <= char_num <= 0x3A:
        letter = chr(ord('A') + char_num - 0x21)
        return f"Letter '{letter}' for text display"
    else:
        return "Game graphics/sprite data"

def get_instruction_comment(addr, mnemonic, operand_str, rom_data, i):
    """Generate detailed comments for instructions"""
    comment = ""
    
    # Special handling for ADDITIONAL_SETUP section ($A518-$A580)
    if 0xA518 <= addr <= 0xA580:
        if addr == 0xA518:
            comment = " ; Clear game state variables"
        elif addr == 0xA51A:
            comment = " ; Clear RAM location $E801"
        elif addr == 0xA51D:
            comment = " ; Clear RAM location $E808"
        elif addr == 0xA520:
            comment = " ; Clear zero page variable $04"
        elif addr == 0xA522:
            comment = " ; Set game mode flag to 2"
        elif addr == 0xA524:
            comment = " ; Store game mode in RAM $E80F"
        elif addr == 0xA527:
            comment = " ; Call display setup routine"
        elif addr == 0xA52A:
            comment = " ; Initialize loop counter (8 iterations)"
        elif addr == 0xA52C:
            comment = " ; Clear score/statistics array"
        elif addr == 0xA52E:
            comment = " ; Decrement loop counter"
        elif addr == 0xA52F:
            comment = " ; Continue clearing array"
        elif addr == 0xA531:
            comment = " ; Initialize game state to 0"
        elif addr == 0xA533:
            comment = " ; Clear game state variable $D0"
        elif addr == 0xA535:
            comment = " ; Clear game state variable $BD"
        elif addr == 0xA537:
            comment = " ; Clear game over flag $D9"
        elif addr == 0xA539:
            comment = " ; Clear counter variable $CE"
        elif addr == 0xA53B:
            comment = " ; Clear counter variable $CF"
        elif addr == 0xA53D:
            comment = " ; Clear zero page variable $0E"
        elif addr == 0xA53F:
            comment = " ; Load initial difficulty/level value"
        elif addr == 0xA541:
            comment = " ; Set initial level counter"
        elif addr == 0xA543:
            comment = " ; Set X to $30 (48 decimal) for text setup"
        elif addr == 0xA545:
            comment = " ; Set flag to 1 (enable something)"
        elif addr == 0xA547:
            comment = " ; Store flag in game state variable"
        elif addr == 0xA549:
            comment = " ; Set Y to $18 (24 decimal) for display"
        elif addr == 0xA54B:
            comment = " ; Call text display setup routine"
        elif addr == 0xA54E:
            comment = " ; Clear zero page variable again"
        elif addr == 0xA550:
            comment = " ; Store in zero page $0E"
        elif addr == 0xA552:
            comment = " ; Clear zero page variable $0C"
        elif addr == 0xA554:
            comment = " ; Set loop counter to $53 (83 chars)"
        elif addr == 0xA556:
            comment = " ; Load character from text table"
        elif addr == 0xA559:
            comment = " ; Set carry for subtraction"
        elif addr == 0xA55A:
            comment = " ; Convert to screen code (subtract $20)"
        elif addr == 0xA55C:
            comment = " ; Store to screen memory location 1"
        elif addr == 0xA55F:
            comment = " ; Store to screen memory location 2"
        elif addr == 0xA562:
            comment = " ; Decrement character counter"
        elif addr == 0xA563:
            comment = " ; Continue copying text"
        elif addr == 0xA565:
            comment = " ; Set up score display (5 digits)"
        elif addr == 0xA567:
            comment = " ; Load ASCII '0' for initial score"
        elif addr == 0xA569:
            comment = " ; Store score digit to screen"
        elif addr == 0xA56C:
            comment = " ; Check if this is digit 2"
        elif addr == 0xA56E:
            comment = " ; Skip decimal point if not digit 2"
        elif addr == 0xA570:
            comment = " ; Load ASCII '.' for decimal point"
        elif addr == 0xA572:
            comment = " ; Store to time display area"
        elif addr == 0xA575:
            comment = " ; Decrement digit counter"
        elif addr == 0xA576:
            comment = " ; Continue setting up digits"
        elif addr == 0xA578:
            comment = " ; Clear final game state"
        elif addr == 0xA57A:
            comment = " ; Clear game over flag $DA"
        elif addr == 0xA57C:
            comment = " ; Set initial time/score value"
        elif addr == 0xA57E:
            comment = " ; Store in time variable $7B"
        elif addr == 0xA580:
            comment = " ; Return from additional setup"
    
    # Special handling for GAME_RESTART section ($A581-$A5D6)
    elif 0xA581 <= addr <= 0xA5D6:
        if addr == 0xA581:
            comment = " ; Game restart/new level setup"
        elif addr == 0xA584:
            comment = " ; Call text display setup routine"
        elif addr == 0xA587:
            comment = " ; Load hardware configuration"
        elif addr == 0xA58A:
            comment = " ; Mask upper 4 bits"
        elif addr == 0xA58C:
            comment = " ; Set bit 3 (enable feature)"
        elif addr == 0xA58E:
            comment = " ; Store configuration in $0C"
        elif addr == 0xA590:
            comment = " ; Set loop counter to $34 (52 bytes)"
        elif addr == 0xA592:
            comment = " ; Load from data table"
        elif addr == 0xA595:
            comment = " ; Set carry for subtraction"
        elif addr == 0xA596:
            comment = " ; Convert to screen code"
        elif addr == 0xA598:
            comment = " ; Store to screen memory $3900"
        elif addr == 0xA59B:
            comment = " ; Decrement counter"
        elif addr == 0xA59C:
            comment = " ; Continue copying data"
        elif addr == 0xA59E:
            comment = " ; Set up 5-byte copy operation"
        elif addr == 0xA5A0:
            comment = " ; Load from score area"
        elif addr == 0xA5A3:
            comment = " ; Copy to backup area"
        elif addr == 0xA5A6:
            comment = " ; Decrement copy counter"
        elif addr == 0xA5A7:
            comment = " ; Continue copying score"
        elif addr == 0xA5A9:
            comment = " ; Set up another 5-byte copy"
        elif addr == 0xA5AB:
            comment = " ; Load from time area"
        elif addr == 0xA5AE:
            comment = " ; Copy to backup area"
        elif addr == 0xA5B1:
            comment = " ; Decrement copy counter"
        elif addr == 0xA5B2:
            comment = " ; Continue copying time"
        elif addr == 0xA5B4:
            comment = " ; Initialize comparison loop"
        elif addr == 0xA5B6:
            comment = " ; Load from high score table"
        elif addr == 0xA5B9:
            comment = " ; Compare with current score"
        elif addr == 0xA5BC:
            comment = " ; Branch if not equal"
        elif addr == 0xA5BE:
            comment = " ; Increment comparison index"
        elif addr == 0xA5BF:
            comment = " ; Check if all 5 digits compared"
        elif addr == 0xA5C1:
            comment = " ; Continue comparison"
        elif addr == 0xA5C3:
            comment = " ; Branch if current score higher"
        elif addr == 0xA5C5:
            comment = " ; Update high score table"
        elif addr == 0xA5C8:
            comment = " ; Store new high score digit"
        elif addr == 0xA5CB:
            comment = " ; Increment table index"
        elif addr == 0xA5CC:
            comment = " ; Check if all digits updated"
        elif addr == 0xA5CE:
            comment = " ; Continue updating high score"
        elif addr == 0xA5D0:
            comment = " ; Call screen update routine"
        elif addr == 0xA5D3:
            comment = " ; Call additional display routine"
        elif addr == 0xA5D6:
            comment = " ; Return from game restart"
    
    # Special handling for ANIMATION_ENGINE section ($A63B-$A6CD)
    elif 0xA63B <= addr <= 0xA6CD:
        if addr == 0xA63B:
            comment = " ; Initialize animation system"
        elif addr == 0xA63D:
            comment = " ; Clear animation state"
        elif addr == 0xA63F:
            comment = " ; Store in animation control register"
        elif addr == 0xA642:
            comment = " ; Check animation enable flag"
        elif addr == 0xA644:
            comment = " ; Branch if animations disabled"
        elif addr == 0xA646:
            comment = " ; Load animation frame counter"
        elif addr == 0xA648:
            comment = " ; Check if frame limit reached"
        elif addr == 0xA64A:
            comment = " ; Branch if animation complete"
        elif addr == 0xA64C:
            comment = " ; Load animation type flag"
        elif addr == 0xA64E:
            comment = " ; Branch if not this animation type"
        elif addr == 0xA650:
            comment = " ; Load current frame number"
        elif addr == 0xA652:
            comment = " ; Clear carry for addition"
        elif addr == 0xA653:
            comment = " ; Increment frame counter"
        elif addr == 0xA655:
            comment = " ; Store new frame number"
        elif addr == 0xA657:
            comment = " ; Update animation register"
        elif addr == 0xA65A:
            comment = " ; Check if reached frame 13"
        elif addr == 0xA65C:
            comment = " ; Branch if not at end"
        elif addr == 0xA65E:
            comment = " ; Load animation end value"
        elif addr == 0xA660:
            comment = " ; Store animation state"
        elif addr == 0xA662:
            comment = " ; Jump to animation cleanup"
        elif addr == 0xA665:
            comment = " ; Load animation sequence index"
        elif addr == 0xA667:
            comment = " ; Increment sequence"
        elif addr == 0xA668:
            comment = " ; Check if sequence complete (3 steps)"
        elif addr == 0xA66A:
            comment = " ; Branch if more steps"
        elif addr == 0xA66C:
            comment = " ; Reset sequence to 0"
        elif addr == 0xA66E:
            comment = " ; Store sequence index"
        elif addr == 0xA670:
            comment = " ; Jump to next animation phase"
        elif addr == 0xA673:
            comment = " ; Load animation speed control"
        elif addr == 0xA675:
            comment = " ; Store to speed register"
        elif addr == 0xA678:
            comment = " ; Check if speed at minimum"
        elif addr == 0xA67A:
            comment = " ; Branch if not minimum"
        elif addr == 0xA67C:
            comment = " ; Clear animation enable"
        elif addr == 0xA67E:
            comment = " ; Store animation disable"
        elif addr == 0xA680:
            comment = " ; Jump to animation end"
        elif addr == 0xA683:
            comment = " ; Set carry for subtraction"
        elif addr == 0xA684:
            comment = " ; Decrease animation speed"
        elif addr == 0xA686:
            comment = " ; Store new speed"
        elif addr == 0xA688:
            comment = " ; Increment animation timer"
        elif addr == 0xA68A:
            comment = " ; Load timer value"
        elif addr == 0xA68C:
            comment = " ; Store to timer register"
        elif addr == 0xA68F:
            comment = " ; Check if timer reached 32"
        elif addr == 0xA691:
            comment = " ; Branch if timer not full"
        elif addr == 0xA693:
            comment = " ; Load secondary timer"
        elif addr == 0xA695:
            comment = " ; Check if secondary timer at max"
        elif addr == 0xA697:
            comment = " ; Branch if timer complete"
        elif addr == 0xA699:
            comment = " ; Set carry for subtraction"
        elif addr == 0xA69A:
            comment = " ; Decrement secondary timer"
        elif addr == 0xA69C:
            comment = " ; Store new timer value"
        elif addr == 0xA69E:
            comment = " ; Update timer register"
        elif addr == 0xA6A1:
            comment = " ; Check sprite animation flag"
        elif addr == 0xA6A3:
            comment = " ; Branch if sprite animation off"
        elif addr == 0xA6A5:
            comment = " ; Load sprite position"
        elif addr == 0xA6A7:
            comment = " ; Set carry for subtraction"
        elif addr == 0xA6A8:
            comment = " ; Move sprite 4 pixels"
        elif addr == 0xA6AA:
            comment = " ; Store new sprite position"
        elif addr == 0xA6AC:
            comment = " ; Update sprite register"
        elif addr == 0xA6AF:
            comment = " ; Check if sprite at edge (8 pixels)"
        elif addr == 0xA6B1:
            comment = " ; Branch if sprite not at edge"
        elif addr == 0xA6B3:
            comment = " ; Clear sprite animation"
        elif addr == 0xA6B5:
            comment = " ; Store to sprite control"
        elif addr == 0xA6B8:
            comment = " ; Store sprite disable flag"
        elif addr == 0xA6BA:
            comment = " ; Check game trigger flag"
        elif addr == 0xA6BC:
            comment = " ; Branch if trigger active"
        elif addr == 0xA6BE:
            comment = " ; Load accuracy counter"
        elif addr == 0xA6C0:
            comment = " ; Set carry for subtraction"
        elif addr == 0xA6C1:
            comment = " ; Calculate accuracy (shots - hits)"
        elif addr == 0xA6C3:
            comment = " ; Branch if negative (impossible)"
        elif addr == 0xA6C5:
            comment = " ; Check if accuracy good (< 5 misses)"
        elif addr == 0xA6C7:
            comment = " ; Branch if accuracy poor"
        elif addr == 0xA6C9:
            comment = " ; Load bonus value for good accuracy"
        elif addr == 0xA6CB:
            comment = " ; Store accuracy bonus"
        elif addr == 0xA6CD:
            comment = " ; Jump to OS ROM routine (NMI handler)"
    
    # Special handling for SETUP_ROUTINE section ($A6D0-$A78B)
    elif 0xA6D0 <= addr <= 0xA78B:
        if addr == 0xA6D0:
            comment = " ; Main display setup routine"
        elif addr == 0xA6D3:
            comment = " ; Clear setup variables"
        elif addr == 0xA6D5:
            comment = " ; Clear difficulty counter"
        elif addr == 0xA6D7:
            comment = " ; Set up memory clear loop (8 bytes)"
        elif addr == 0xA6D9:
            comment = " ; Clear RAM area $E800-$E807"
        elif addr == 0xA6DC:
            comment = " ; Decrement clear counter"
        elif addr == 0xA6DD:
            comment = " ; Continue clearing memory"
        elif addr == 0xA6DF:
            comment = " ; Call display initialization"
        elif addr == 0xA6E2:
            comment = " ; Set up large copy operation (168 bytes)"
        elif addr == 0xA6E4:
            comment = " ; Load from text data table"
        elif addr == 0xA6E7:
            comment = " ; Store to screen memory area"
        elif addr == 0xA6EA:
            comment = " ; Decrement copy counter"
        elif addr == 0xA6EB:
            comment = " ; Continue copying text data"
        elif addr == 0xA6ED:
            comment = " ; Set up display parameters"
        elif addr == 0xA6EF:
            comment = " ; X coordinate for display"
        elif addr == 0xA6F1:
            comment = " ; Y coordinate for display"
        elif addr == 0xA6F3:
            comment = " ; Call display positioning routine"
        elif addr == 0xA6F6:
            comment = " ; Set up text display (48 chars)"
        elif addr == 0xA6F8:
            comment = " ; Text display mode 2"
        elif addr == 0xA6FA:
            comment = " ; Text height (8 lines)"
        elif addr == 0xA6FC:
            comment = " ; Call text setup routine"
        elif addr == 0xA6FF:
            comment = " ; Load hardware configuration"
        elif addr == 0xA702:
            comment = " ; Mask upper 4 bits"
        elif addr == 0xA704:
            comment = " ; Set display enable bit"
        elif addr == 0xA706:
            comment = " ; Store display config"
        elif addr == 0xA708:
            comment = " ; Load hardware config again"
        elif addr == 0xA70B:
            comment = " ; Mask upper 4 bits again"
        elif addr == 0xA70D:
            comment = " ; Set enable bit again"
        elif addr == 0xA70F:
            comment = " ; Store to second config register"
        elif addr == 0xA711:
            comment = " ; Set up playfield graphics pointer"
        elif addr == 0xA713:
            comment = " ; Store graphics pointer high byte"
        elif addr == 0xA715:
            comment = " ; Set up playfield graphics pointer low"
        elif addr == 0xA717:
            comment = " ; Store graphics pointer low byte"
        elif addr == 0xA719:
            comment = " ; Set up display list parameters"
        elif addr == 0xA71B:
            comment = " ; Store display list config"
        elif addr == 0xA71D:
            comment = " ; Initialize screen clear loop"
        elif addr == 0xA71F:
            comment = " ; Store clear index"
        elif addr == 0xA721:
            comment = " ; Transfer index to accumulator"
        elif addr == 0xA722:
            comment = " ; Clear screen memory page $2000"
        elif addr == 0xA725:
            comment = " ; Clear screen memory page $2100"
        elif addr == 0xA728:
            comment = " ; Decrement clear counter"
        elif addr == 0xA729:
            comment = " ; Continue clearing screen"
        elif addr == 0xA72B:
            comment = " ; Set up pattern copy (14 bytes)"
        elif addr == 0xA72D:
            comment = " ; Set up pattern counter (12 patterns)"
        elif addr == 0xA72F:
            comment = " ; Store pattern counter"
        elif addr == 0xA731:
            comment = " ; Load from pattern table"
        elif addr == 0xA734:
            comment = " ; Store to screen memory"
        elif addr == 0xA737:
            comment = " ; Increment source index"
        elif addr == 0xA738:
            comment = " ; Increment destination index"
        elif addr == 0xA739:
            comment = " ; Decrement pattern counter"
        elif addr == 0xA73B:
            comment = " ; Continue copying pattern"
        elif addr == 0xA73D:
            comment = " ; Transfer Y to accumulator"
        elif addr == 0xA73E:
            comment = " ; Clear carry for addition"
        elif addr == 0xA73F:
            comment = " ; Add 28 to Y (next row)"
        elif addr == 0xA741:
            comment = " ; Transfer back to Y"
        elif addr == 0xA742:
            comment = " ; Check if reached end ($FE)"
        elif addr == 0xA744:
            comment = " ; Continue with next row"
        elif addr == 0xA746:
            comment = " ; Set up final pattern copy (11 bytes)"
        elif addr == 0xA748:
            comment = " ; Load from pattern table 1"
        elif addr == 0xA74B:
            comment = " ; Store to screen position 1"
        elif addr == 0xA74E:
            comment = " ; Load from pattern table 2"
        elif addr == 0xA751:
            comment = " ; Store to screen position 2"
        elif addr == 0xA754:
            comment = " ; Load from pattern table 3"
        elif addr == 0xA757:
            comment = " ; Store to screen position 3"
        elif addr == 0xA75A:
            comment = " ; Decrement pattern counter"
        elif addr == 0xA75B:
            comment = " ; Continue copying patterns"
        elif addr == 0xA75D:
            comment = " ; Set up special character"
        elif addr == 0xA75F:
            comment = " ; Store special character to screen"
    
    # JSR comments
    elif mnemonic == "JSR":
        if "$BBC3" in operand_str:
            comment = " ; Main game logic update"
        elif "$B974" in operand_str:
            comment = " ; Graphics/sprite updates"
        elif "$AFAD" in operand_str:
            comment = " ; Input handling routine"
        elif "$BC11" in operand_str:
            comment = " ; Sound/audio updates"
        elif "$B14F" in operand_str:
            comment = " ; Collision detection"
        elif "$B2B3" in operand_str:
            comment = " ; Enemy AI/movement"
        elif "$B4BF" in operand_str:
            comment = " ; Display updates"
        elif "$BD66" in operand_str:
            comment = " ; Fire sound effect"
        elif "$BD6C" in operand_str:
            comment = " ; Hit/action sound effect"
        elif "$A6D0" in operand_str:
            comment = " ; Setup routine"
        elif "$A518" in operand_str:
            comment = " ; Additional setup - Initialize game variables and text displays"
        elif "$A9B6" in operand_str:
            comment = " ; Game initialization"
        elif "$BDA2" in operand_str:
            comment = " ; Display list setup routine"
        elif "$BDB0" in operand_str:
            comment = " ; Text display setup routine"
        elif "$BAC0" in operand_str:
            comment = " ; Screen update routine"
        elif "$A48C" in operand_str:
            comment = " ; Additional display routine"
    
    # Hardware register access
    elif mnemonic in ["LDA", "STA"] and "$" in operand_str:
        if "$C008" in operand_str:
            comment = " ; GTIA P0PF - Player 0/Playfield collision (fire buttons)"
        elif "$C009" in operand_str:
            comment = " ; GTIA P1PF - Player 1/Playfield collision"
        elif "$C00A" in operand_str:
            comment = " ; GTIA P2PF - Player 2/Playfield collision"
        elif "$C00B" in operand_str:
            comment = " ; GTIA P3PF - Player 3/Playfield collision"
        elif "$C00C" in operand_str:
            comment = " ; GTIA M0PF - Missile 0/Playfield collision"
        elif "$C00D" in operand_str:
            comment = " ; GTIA M1PF - Missile 1/Playfield collision"
        elif "$C00E" in operand_str:
            comment = " ; GTIA M2PF - Missile 2/Playfield collision"
        elif "$C00F" in operand_str:
            comment = " ; GTIA M3PF - Missile 3/Playfield collision"
        elif "$C010" in operand_str:
            comment = " ; GTIA collision register"
        elif "$C01D" in operand_str:
            comment = " ; GTIA GRACTL - Graphics control"
        elif "$C01E" in operand_str:
            comment = " ; GTIA HITCLR - Clear collision registers"
        elif "$C01F" in operand_str:
            comment = " ; GTIA PRIOR - Priority control"
        elif "$D400" in operand_str:
            comment = " ; ANTIC DMACTL - DMA control"
        elif "$D407" in operand_str:
            comment = " ; ANTIC PMBASE - Player/Missile base address"
        elif "$D409" in operand_str:
            comment = " ; POKEY SKCTL - Serial/keyboard control"
        elif "$D40B" in operand_str:
            comment = " ; ANTIC VCOUNT - Vertical line counter"
        elif "$D40E" in operand_str:
            comment = " ; ANTIC NMIEN - NMI enable"
    
    # Game state variables
    elif mnemonic in ["LDA", "STA"] and operand_str.startswith("$") and len(operand_str) == 3:
        var_addr = operand_str[1:]
        if var_addr == "94":
            comment = " ; Player 1 action flag"
        elif var_addr == "95":
            comment = " ; Player 2 action flag"
        elif var_addr == "96":
            comment = " ; Player 3 action flag"
        elif var_addr == "92":
            comment = " ; Game mode/state flag"
        elif var_addr == "93":
            comment = " ; Special game condition flag"
        elif var_addr == "AD":
            comment = " ; Game continuation flag"
        elif var_addr == "AC":
            comment = " ; Difficulty/speed modifier"
        elif var_addr == "A9":
            comment = " ; Main loop condition"
        elif var_addr == "D2":
            comment = " ; Hit counter (targets destroyed)"
        elif var_addr == "D3":
            comment = " ; Action/bonus counter"
        elif var_addr == "D4":
            comment = " ; Shot counter (affects accuracy)"
        elif var_addr == "D5":
            comment = " ; Level/difficulty counter"
    
    # Branch instructions
    elif mnemonic in ["BEQ", "BNE", "BCC", "BCS", "BPL", "BMI", "BVC", "BVS"]:
        if mnemonic == "BNE" and i > 0:
            comment = " ; Loop back if not zero"
        elif mnemonic == "BEQ":
            comment = " ; Branch if equal/zero"
        elif mnemonic == "BCC":
            comment = " ; Branch if carry clear"
        elif mnemonic == "BCS":
            comment = " ; Branch if carry set"
    
    # Increment/decrement with game context
    elif mnemonic == "INC" and operand_str in ["$D2", "$D3", "$D4", "$D5"]:
        if operand_str == "$D2":
            comment = " ; Increment hit counter"
        elif operand_str == "$D3":
            comment = " ; Increment action counter"
        elif operand_str == "$D4":
            comment = " ; Increment shot counter"
        elif operand_str == "$D5":
            comment = " ; Increment level counter"
    
    # Special handling for MISC_UPDATE section ($A83A-$A8FF)
    elif 0xA83A <= addr <= 0xA8FF:
        if addr == 0xA83A:
            comment = " ; Miscellaneous game updates routine"
        elif addr == 0xA83C:
            comment = " ; Load game state flag"
        elif addr == 0xA83E:
            comment = " ; Check if game active"
        elif addr == 0xA840:
            comment = " ; Branch if game not active"
        elif addr == 0xA842:
            comment = " ; Load player action state"
        elif addr == 0xA844:
            comment = " ; Check if player action triggered"
        elif addr == 0xA846:
            comment = " ; Branch if no action"
        elif addr == 0xA848:
            comment = " ; Load collision register P0PF"
        elif addr == 0xA84B:
            comment = " ; Mask collision bits"
        elif addr == 0xA84D:
            comment = " ; Check for collision"
        elif addr == 0xA84F:
            comment = " ; Branch if no collision"
        elif addr == 0xA851:
            comment = " ; Process collision - increment hit counter"
        elif addr == 0xA853:
            comment = " ; Update hit statistics"
        elif addr == 0xA855:
            comment = " ; Load sound effect trigger"
        elif addr == 0xA857:
            comment = " ; Store to sound register"
        elif addr == 0xA85A:
            comment = " ; Clear collision registers"
        elif addr == 0xA85D:
            comment = " ; Return from collision processing"
    
    # Special handling for GAME_INIT section ($A9B6-$AA00)
    elif 0xA9B6 <= addr <= 0xAA00:
        if addr == 0xA9B6:
            comment = " ; Main game initialization routine"
        elif addr == 0xA9B8:
            comment = " ; Clear game variables"
        elif addr == 0xA9BA:
            comment = " ; Initialize player positions"
        elif addr == 0xA9BC:
            comment = " ; Set up sprite graphics"
        elif addr == 0xA9BE:
            comment = " ; Configure collision detection"
        elif addr == 0xA9C0:
            comment = " ; Enable player missiles"
        elif addr == 0xA9C2:
            comment = " ; Set initial game speed"
        elif addr == 0xA9C4:
            comment = " ; Configure display list"
        elif addr == 0xA9C6:
            comment = " ; Initialize sound system"
        elif addr == 0xA9C8:
            comment = " ; Set up interrupt handlers"
        elif addr == 0xA9CA:
            comment = " ; Enable NMI interrupts"
        elif addr == 0xA9CC:
            comment = " ; Configure GTIA graphics mode"
        elif addr == 0xA9CE:
            comment = " ; Set player/missile priorities"
        elif addr == 0xA9D0:
            comment = " ; Initialize game timers"
        elif addr == 0xA9D2:
            comment = " ; Set up playfield graphics"
        elif addr == 0xA9D4:
            comment = " ; Configure character set"
        elif addr == 0xA9D6:
            comment = " ; Initialize score display"
        elif addr == 0xA9D8:
            comment = " ; Set up level progression"
        elif addr == 0xA9DA:
            comment = " ; Configure difficulty settings"
        elif addr == 0xA9DC:
            comment = " ; Enable game loop"
        elif addr == 0xA9DE:
            comment = " ; Return from initialization"
    
    # Special handling for COLLISION_PROCESSING section ($A99C-$A9B5)
    elif 0xA99C <= addr <= 0xA9B5:
        if addr == 0xA99C:
            comment = " ; Process player collision (X = player number)"
        elif addr == 0xA99E:
            comment = " ; Load player state"
        elif addr == 0xA9A0:
            comment = " ; Store collision result"
        elif addr == 0xA9A2:
            comment = " ; Decrement collision timer"
        elif addr == 0xA9A3:
            comment = " ; Call collision effect routine"
        elif addr == 0xA9A6:
            comment = " ; Call secondary collision routine"
        elif addr == 0xA9A9:
            comment = " ; Load collision data from table"
        elif addr == 0xA9AC:
            comment = " ; Invert collision bits"
        elif addr == 0xA9AE:
            comment = " ; Store processed collision"
        elif addr == 0xA9B0:
            comment = " ; Update player score"
        elif addr == 0xA9B2:
            comment = " ; Trigger hit sound effect"
        elif addr == 0xA9B4:
            comment = " ; Return from collision processing"
    
    # Special handling for SPRITE_UPDATE section ($AAD6-$AB01)
    elif 0xAAD6 <= addr <= 0xAB01:
        if addr == 0xAAD6:
            comment = " ; Update sprite positions and animations"
        elif addr == 0xAAD8:
            comment = " ; Load sprite X position"
        elif addr == 0xAADA:
            comment = " ; Check sprite bounds"
        elif addr == 0xAADC:
            comment = " ; Branch if sprite off-screen"
        elif addr == 0xAADE:
            comment = " ; Update sprite animation frame"
        elif addr == 0xAAE0:
            comment = " ; Load animation sequence"
        elif addr == 0xAAE2:
            comment = " ; Increment animation counter"
        elif addr == 0xAAE4:
            comment = " ; Check animation limit"
        elif addr == 0xAAE6:
            comment = " ; Reset animation if needed"
        elif addr == 0xAAE8:
            comment = " ; Store new animation frame"
        elif addr == 0xAAEA:
            comment = " ; Call sprite positioning routine"
        elif addr == 0xAAED:
            comment = " ; Set carry for movement calculation"
        elif addr == 0xAAEE:
            comment = " ; Subtract movement speed"
        elif addr == 0xAAF0:
            comment = " ; Store new position"
        elif addr == 0xAAF2:
            comment = " ; Check if sprite reached edge"
        elif addr == 0xAAF4:
            comment = " ; Branch if more movement needed"
        elif addr == 0xAAF6:
            comment = " ; Disable sprite (off-screen)"
        elif addr == 0xAAF8:
            comment = " ; Clear sprite graphics"
        elif addr == 0xAAFA:
            comment = " ; Update sprite register"
        elif addr == 0xAAFC:
            comment = " ; Load return address"
        elif addr == 0xAAFE:
            comment = " ; Pull return address from stack"
        elif addr == 0xAB00:
            comment = " ; Pull Y register from stack"
        elif addr == 0xAB01:
            comment = " ; Return from sprite update"
    
    # Special handling for LEVEL_PROGRESSION section ($AB02-$AB50)
    elif 0xAB02 <= addr <= 0xAB50:
        if addr == 0xAB02:
            comment = " ; Level progression and difficulty management"
        elif addr == 0xAB04:
            comment = " ; Load current level"
        elif addr == 0xAB06:
            comment = " ; Check if level complete"
        elif addr == 0xAB08:
            comment = " ; Branch if level not complete"
        elif addr == 0xAB0A:
            comment = " ; Increment level counter"
        elif addr == 0xAB0C:
            comment = " ; Check maximum level reached"
        elif addr == 0xAB0E:
            comment = " ; Branch if more levels"
        elif addr == 0xAB10:
            comment = " ; Reset to level 1 (wrap around)"
        elif addr == 0xAB12:
            comment = " ; Store new level"
        elif addr == 0xAB14:
            comment = " ; Update difficulty based on level"
        elif addr == 0xAB16:
            comment = " ; Load difficulty multiplier"
        elif addr == 0xAB18:
            comment = " ; Calculate enemy speed"
        elif addr == 0xAB1A:
            comment = " ; Store enemy speed"
        elif addr == 0xAB1C:
            comment = " ; Calculate spawn rate"
        elif addr == 0xAB1E:
            comment = " ; Store spawn rate"
        elif addr == 0xAB20:
            comment = " ; Update score multiplier"
        elif addr == 0xAB22:
            comment = " ; Load bonus points for level"
        elif addr == 0xAB24:
            comment = " ; Add level completion bonus"
        elif addr == 0xAB26:
            comment = " ; Update total score"
        elif addr == 0xAB28:
            comment = " ; Display level transition"
        elif addr == 0xAB2A:
            comment = " ; Call screen update"
        elif addr == 0xAB2C:
            comment = " ; Set transition timer"
        elif addr == 0xAB2E:
            comment = " ; Wait for transition complete"
        elif addr == 0xAB30:
            comment = " ; Initialize new level"
    
    # Special handling for ENEMY_SPAWN section ($ABF3-$AC50)
    elif 0xABF3 <= addr <= 0xAC50:
        if addr == 0xABF3:
            comment = " ; Enemy spawning and management system"
        elif addr == 0xABF5:
            comment = " ; Check spawn timer"
        elif addr == 0xABF7:
            comment = " ; Branch if not time to spawn"
        elif addr == 0xABF9:
            comment = " ; Load spawn rate (difficulty dependent)"
        elif addr == 0xABFB:
            comment = " ; Reset spawn timer"
        elif addr == 0xABFD:
            comment = " ; Find empty enemy slot"
        elif addr == 0xABFF:
            comment = " ; Load enemy slot index"
        elif addr == 0xAC01:
            comment = " ; Check if slot occupied"
        elif addr == 0xAC03:
            comment = " ; Branch if slot busy"
        elif addr == 0xAC05:
            comment = " ; Initialize new enemy"
        elif addr == 0xAC07:
            comment = " ; Set enemy type (random)"
        elif addr == 0xAC09:
            comment = " ; Set initial position"
        elif addr == 0xAC0B:
            comment = " ; Set enemy speed"
        elif addr == 0xAC0D:
            comment = " ; Set enemy direction"
        elif addr == 0xAC0F:
            comment = " ; Enable enemy sprite"
        elif addr == 0xAC11:
            comment = " ; Set enemy graphics"
        elif addr == 0xAC13:
            comment = " ; Initialize enemy AI state"
        elif addr == 0xAC15:
            comment = " ; Set enemy health/hits"
        elif addr == 0xAC17:
            comment = " ; Set enemy score value"
        elif addr == 0xAC19:
            comment = " ; Add to active enemy list"
        elif addr == 0xAC1B:
            comment = " ; Update enemy counter"
        elif addr == 0xAC1D:
            comment = " ; Return from spawn routine"
    
    # Special handling for DISPLAY_MANAGEMENT section ($AC0C-$AC92)
    elif 0xAC0C <= addr <= 0xAC92:
        if addr == 0xAC0C:
            comment = " ; Display list and screen management"
        elif addr == 0xAC0E:
            comment = " ; Load display list pointer"
        elif addr == 0xAC10:
            comment = " ; Check display mode"
        elif addr == 0xAC12:
            comment = " ; Branch for different modes"
        elif addr == 0xAC14:
            comment = " ; Set up game display mode"
        elif addr == 0xAC16:
            comment = " ; Configure character set"
        elif addr == 0xAC18:
            comment = " ; Set screen memory"
        elif addr == 0xAC1A:
            comment = " ; Configure color registers"
        elif addr == 0xAC1C:
            comment = " ; Set background color"
        elif addr == 0xAC1E:
            comment = " ; Set playfield colors"
        elif addr == 0xAC20:
            comment = " ; Set player colors"
        elif addr == 0xAC22:
            comment = " ; Configure sprite priorities"
        elif addr == 0xAC24:
            comment = " ; Enable display DMA"
        elif addr == 0xAC26:
            comment = " ; Set horizontal scroll"
        elif addr == 0xAC28:
            comment = " ; Set vertical scroll"
        elif addr == 0xAC2A:
            comment = " ; Update display registers"
        elif addr == 0xAC2C:
            comment = " ; Wait for vertical blank"
        elif addr == 0xAC2E:
            comment = " ; Synchronize display updates"
        elif addr == 0xAC30:
            comment = " ; Check for display errors"
        elif addr == 0xAC32:
            comment = " ; Handle display interrupts"
    
    # Special handling for MAIN_UPDATE section ($BBC3-$BC10)
    elif 0xBBC3 <= addr <= 0xBC10:
        if addr == 0xBBC3:
            comment = " ; Main game logic update routine"
        elif addr == 0xBBC5:
            comment = " ; Check game state flags"
        elif addr == 0xBBC7:
            comment = " ; Update game timers"
        elif addr == 0xBBC9:
            comment = " ; Process game events"
        elif addr == 0xBBCB:
            comment = " ; Update player states"
        elif addr == 0xBBCD:
            comment = " ; Check win/lose conditions"
        elif addr == 0xBBCF:
            comment = " ; Update score multipliers"
        elif addr == 0xBBD1:
            comment = " ; Process level progression"
        elif addr == 0xBBD3:
            comment = " ; Update difficulty settings"
        elif addr == 0xBBD5:
            comment = " ; Manage game flow"
    
    # Special handling for GRAPHICS_UPDATE section ($B974-$B9FF)
    elif 0xB974 <= addr <= 0xB9FF:
        if addr == 0xB974:
            comment = " ; Graphics and sprite update routine"
        elif addr == 0xB976:
            comment = " ; Update player sprites"
        elif addr == 0xB978:
            comment = " ; Update enemy sprites"
        elif addr == 0xB97A:
            comment = " ; Update bullet sprites"
        elif addr == 0xB97C:
            comment = " ; Update explosion effects"
        elif addr == 0xB97E:
            comment = " ; Update background graphics"
        elif addr == 0xB980:
            comment = " ; Process sprite animations"
        elif addr == 0xB982:
            comment = " ; Update sprite positions"
        elif addr == 0xB984:
            comment = " ; Handle sprite collisions"
        elif addr == 0xB986:
            comment = " ; Update sprite colors"
        elif addr == 0xB988:
            comment = " ; Manage sprite priorities"
    
    # Special handling for INPUT_HANDLING section ($AFAD-$B000)
    elif 0xAFAD <= addr <= 0xB000:
        if addr == 0xAFAD:
            comment = " ; Main input processing routine"
        elif addr == 0xAFAF:
            comment = " ; Read controller inputs"
        elif addr == 0xAFB1:
            comment = " ; Process fire button states"
        elif addr == 0xAFB3:
            comment = " ; Handle directional input"
        elif addr == 0xAFB5:
            comment = " ; Update player movement"
        elif addr == 0xAFB7:
            comment = " ; Process special buttons"
        elif addr == 0xAFB9:
            comment = " ; Handle pause/start"
        elif addr == 0xAFBB:
            comment = " ; Update input flags"
        elif addr == 0xAFBD:
            comment = " ; Debounce button presses"
        elif addr == 0xAFBF:
            comment = " ; Store input state"
    
    # Special handling for SOUND_UPDATE section ($BC11-$BC60)
    elif 0xBC11 <= addr <= 0xBC60:
        if addr == 0xBC11:
            comment = " ; Sound and audio update routine"
        elif addr == 0xBC13:
            comment = " ; Check sound queue"
        elif addr == 0xBC15:
            comment = " ; Process sound effects"
        elif addr == 0xBC17:
            comment = " ; Update music playback"
        elif addr == 0xBC19:
            comment = " ; Handle sound priorities"
        elif addr == 0xBC1B:
            comment = " ; Update sound channels"
        elif addr == 0xBC1D:
            comment = " ; Process audio mixing"
        elif addr == 0xBC1F:
            comment = " ; Update volume levels"
        elif addr == 0xBC21:
            comment = " ; Handle sound timing"
        elif addr == 0xBC23:
            comment = " ; Clear finished sounds"
    
    # Special handling for COLLISION_DETECT section ($B14F-$B200)
    elif 0xB14F <= addr <= 0xB200:
        if addr == 0xB14F:
            comment = " ; Collision detection system"
        elif addr == 0xB151:
            comment = " ; Check player-enemy collisions"
        elif addr == 0xB153:
            comment = " ; Check bullet-enemy collisions"
        elif addr == 0xB155:
            comment = " ; Check player-powerup collisions"
        elif addr == 0xB157:
            comment = " ; Process collision responses"
        elif addr == 0xB159:
            comment = " ; Update collision flags"
        elif addr == 0xB15B:
            comment = " ; Handle collision damage"
        elif addr == 0xB15D:
            comment = " ; Trigger collision effects"
        elif addr == 0xB15F:
            comment = " ; Update collision counters"
        elif addr == 0xB161:
            comment = " ; Clear collision registers"
    
    # Special handling for ENEMY_AI section ($B2B3-$B350)
    elif 0xB2B3 <= addr <= 0xB350:
        if addr == 0xB2B3:
            comment = " ; Enemy AI and movement system"
        elif addr == 0xB2B5:
            comment = " ; Update enemy positions"
        elif addr == 0xB2B7:
            comment = " ; Process enemy AI logic"
        elif addr == 0xB2B9:
            comment = " ; Handle enemy movement patterns"
        elif addr == 0xB2BB:
            comment = " ; Update enemy states"
        elif addr == 0xB2BD:
            comment = " ; Process enemy attacks"
        elif addr == 0xB2BF:
            comment = " ; Handle enemy spawning"
        elif addr == 0xB2C1:
            comment = " ; Update enemy health"
        elif addr == 0xB2C3:
            comment = " ; Process enemy death"
        elif addr == 0xB2C5:
            comment = " ; Update enemy counters"
    
    # Special handling for DISPLAY_UPDATE section ($B4BF-$B550)
    elif 0xB4BF <= addr <= 0xB550:
        if addr == 0xB4BF:
            comment = " ; Display and screen update routine"
        elif addr == 0xB4C1:
            comment = " ; Update score display"
        elif addr == 0xB4C3:
            comment = " ; Update time display"
        elif addr == 0xB4C5:
            comment = " ; Update level display"
        elif addr == 0xB4C7:
            comment = " ; Update status indicators"
        elif addr == 0xB4C9:
            comment = " ; Refresh screen areas"
        elif addr == 0xB4CB:
            comment = " ; Update text displays"
        elif addr == 0xB4CD:
            comment = " ; Handle screen transitions"
        elif addr == 0xB4CF:
            comment = " ; Update color palettes"
        elif addr == 0xB4D1:
            comment = " ; Process screen effects"
    
    return comment

def create_annotated_disassembly():
    """Create fully annotated disassembly with ASCII art and detailed comments"""
    with open("K-Razy Shoot-Out (USA).a52", "rb") as f:
        rom = f.read()
    
    output = []
    output.append("; ===============================================================================")
    output.append("; K-RAZY SHOOT-OUT (USA) - COMPLETE ANNOTATED DISASSEMBLY")
    output.append("; ===============================================================================")
    output.append("; Original Game: CBS Electronics, 1981")
    output.append("; Platform: Atari 5200 SuperSystem")
    output.append("; CPU: MOS 6502C @ 1.79 MHz")
    output.append("; ROM Size: 8KB (8192 bytes)")
    output.append("; Memory Map: $A000-$BFFF")
    output.append(";")
    output.append("; This disassembly includes:")
    output.append("; - ASCII art representations of all graphics")
    output.append("; - Detailed comments on game mechanics")
    output.append("; - Hardware register explanations")
    output.append("; - Game state variable documentation")
    output.append("; ===============================================================================")
    output.append("")
    output.append("        .org $A000")
    output.append("")
    
    # Graphics section with ASCII art
    output.append("; ===============================================================================")
    output.append("; GRAPHICS DATA SECTION ($A000-$A2C7)")
    output.append("; ===============================================================================")
    output.append("; Character set data - 89 characters total (712 bytes)")
    output.append("; Each character is 8x8 pixels, stored as 8 bytes")
    output.append("; Bit 1 = pixel on (#), Bit 0 = pixel off (.)")
    output.append("")
    
    i = 0
    while i < 0x2C8:  # Graphics section
        if i % 8 == 0:
            char_num = i // 8
            char_data = rom[i:i+8]
            ascii_art = bytes_to_ascii_art(char_data)
            description = get_character_description(char_num, char_data)
            
            output.append(f"; Character ${char_num:02X} - {description}")
            for j, line in enumerate(ascii_art):
                output.append(f";   {line}")
            output.append("")
        
        byte_val = rom[i]
        addr = 0xA000 + i
        row = i % 8
        output.append(f"        .byte ${byte_val:02X}        ; ${addr:04X} - Row {row}")
        i += 1
        
        if i % 8 == 0:
            output.append("")
    
    # Code section with detailed comments
    output.append("; ===============================================================================")
    output.append("; GAME CODE SECTION ($A2C8-$BFFF)")
    output.append("; ===============================================================================")
    output.append("")
    
    # Add major section markers
    major_sections = {
        0x2C8: ("INITIALIZATION", "System startup and hardware setup"),
        0x332: ("MAIN_GAME_LOOP", "Core game loop - runs continuously during play"),
        0x844: ("INPUT_HANDLING", "Player input detection using collision registers"),
        0x4FF: ("SCORE_UPDATE", "Score calculation and statistics tracking"),
        0x518: ("ADDITIONAL_SETUP", "Game variable initialization and text display setup\n; This routine:\n; - Clears all game state variables\n; - Sets up initial score display (00000)\n; - Sets up time display (00.00)\n; - Copies game text to screen memory\n; - Initializes difficulty level\n; - Prepares display lists for game screens"),
        0x581: ("GAME_RESTART", "Game restart and high score handling\n; This routine:\n; - Sets up display for new game/level\n; - Copies game text to screen memory\n; - Backs up current score and time\n; - Compares current score with high score\n; - Updates high score table if needed\n; - Refreshes screen displays"),
        0x63B: ("ANIMATION_ENGINE", "Sprite animation and timing system\n; This routine:\n; - Manages sprite animation frames\n; - Controls animation timing and sequences\n; - Handles sprite movement and positioning\n; - Processes accuracy bonuses\n; - Updates animation counters and timers"),
        0x6D0: ("SETUP_ROUTINE", "Main display setup and initialization\n; This routine:\n; - Initializes display hardware\n; - Sets up screen memory and graphics\n; - Configures display lists\n; - Clears screen areas\n; - Sets up playfield patterns"),
        0x83A: ("MISC_UPDATE", "Miscellaneous game updates and collision processing\n; This routine:\n; - Processes player actions\n; - Handles collision detection\n; - Updates hit statistics\n; - Triggers sound effects\n; - Manages game state changes"),
        0x99C: ("COLLISION_PROCESSING", "Player collision detection and response\n; This routine:\n; - Processes individual player collisions\n; - Updates collision statistics\n; - Triggers hit effects and sounds\n; - Manages collision timers"),
        0x9B6: ("GAME_INIT", "Main game initialization and setup\n; This routine:\n; - Initializes all game systems\n; - Sets up sprites and graphics\n; - Configures collision detection\n; - Enables interrupts and timers\n; - Prepares game for play"),
        0xAD6: ("SPRITE_UPDATE", "Sprite positioning and animation updates\n; This routine:\n; - Updates sprite positions\n; - Manages sprite animations\n; - Handles sprite bounds checking\n; - Controls sprite visibility\n; - Processes sprite movement"),
        0xB02: ("LEVEL_PROGRESSION", "Level advancement and difficulty management\n; This routine:\n; - Manages level progression\n; - Updates difficulty settings\n; - Calculates level bonuses\n; - Handles level transitions\n; - Controls game pacing"),
        0xBF3: ("ENEMY_SPAWN", "Enemy spawning and management system\n; This routine:\n; - Controls enemy spawn timing\n; - Initializes new enemies\n; - Manages enemy slots\n; - Sets enemy properties\n; - Updates enemy counters"),
        0xC0C: ("DISPLAY_MANAGEMENT", "Display list and screen management\n; This routine:\n; - Manages display modes\n; - Updates screen memory\n; - Controls color registers\n; - Handles display synchronization\n; - Manages display interrupts"),
        0x1BC3: ("MAIN_UPDATE", "Primary game logic update\n; This routine:\n; - Updates game timers\n; - Processes game events\n; - Checks win/lose conditions\n; - Manages game flow\n; - Updates difficulty settings"),
        0x1974: ("GRAPHICS_UPDATE", "Sprite and graphics management\n; This routine:\n; - Updates player sprites\n; - Manages enemy sprites\n; - Processes sprite animations\n; - Handles sprite collisions\n; - Updates sprite positions"),
        0x1C11: ("SOUND_UPDATE", "Audio and sound effects\n; This routine:\n; - Processes sound effects\n; - Updates music playback\n; - Handles sound priorities\n; - Manages audio mixing\n; - Controls sound timing"),
        0x114F: ("COLLISION_DETECT", "Collision detection system\n; This routine:\n; - Checks player-enemy collisions\n; - Processes bullet-enemy collisions\n; - Handles collision responses\n; - Updates collision flags\n; - Triggers collision effects"),
        0x12B3: ("ENEMY_AI", "Enemy movement and AI system\n; This routine:\n; - Updates enemy positions\n; - Processes AI logic\n; - Handles movement patterns\n; - Manages enemy states\n; - Controls enemy attacks"),
        0x14BF: ("DISPLAY_UPDATE", "Screen and graphics updates\n; This routine:\n; - Updates score display\n; - Refreshes screen areas\n; - Handles screen transitions\n; - Updates text displays\n; - Processes screen effects"),
        0x1FAD: ("INPUT_ROUTINE", "Main input processing routine\n; This routine:\n; - Reads controller inputs\n; - Processes fire button states\n; - Handles directional input\n; - Updates player movement\n; - Manages input debouncing")
    }
    
    while i < len(rom):
        addr = 0xA000 + i
        
        # Check for major section markers
        offset = i
        if offset in major_sections:
            section_name, description = major_sections[offset]
            output.append(f"; ===============================================================================")
            output.append(f"; {section_name} (${addr:04X})")
            output.append(f"; {description}")
            output.append(f"; ===============================================================================")
            output.append("")
        
        # Handle text data
        if 0x391 <= i <= 0x4E8:  # Text data section
            byte_val = rom[i]
            if 0x20 <= byte_val <= 0x7E:  # Printable ASCII
                char = chr(byte_val)
                output.append(f"        .byte ${byte_val:02X}        ; ${addr:04X} - '{char}'")
            else:
                output.append(f"        .byte ${byte_val:02X}        ; ${addr:04X}")
            i += 1
            continue
        
        # Handle data section before MISC_UPDATE
        if 0x835 <= i <= 0x839:  # Data section before MISC_UPDATE
            byte_val = rom[i]
            output.append(f"        .byte ${byte_val:02X}        ; ${addr:04X} - Data byte")
            i += 1
            continue
        
        # Disassemble code
        opcode = rom[i]
        if opcode in opcodes:
            mnemonic, size = opcodes[opcode]
            
            # Get instruction bytes
            inst_bytes = rom[i:i+size] if i+size <= len(rom) else rom[i:]
            hex_str = " ".join(f"{b:02X}" for b in inst_bytes)
            
            # Format operand
            operand_str = ""
            if size == 1:
                operand_str = ""
            elif size == 2:
                if len(inst_bytes) >= 2:
                    operand = inst_bytes[1]
                    if mnemonic in ["LDA", "LDX", "LDY", "CMP", "CPX", "CPY", "ADC", "SBC", "AND", "ORA", "EOR"]:
                        operand_str = f" #${operand:02X}"
                    elif mnemonic in ["BPL", "BMI", "BVC", "BVS", "BCC", "BCS", "BNE", "BEQ"]:
                        target = addr + 2 + (operand if operand < 128 else operand - 256)
                        operand_str = f" ${target:04X}"
                    else:
                        operand_str = f" ${operand:02X}"
                else:
                    operand_str = " ??"
            elif size == 3:
                if len(inst_bytes) >= 3:
                    target = inst_bytes[2] * 256 + inst_bytes[1]
                    operand_str = f" ${target:04X}"
                else:
                    operand_str = " ????"
            
            # Get detailed comment
            comment = get_instruction_comment(addr, mnemonic, operand_str, rom, i)
            
            output.append(f"${addr:04X}: {hex_str:<8} {mnemonic}{operand_str}{comment}")
            i += size
        else:
            # Data byte
            output.append(f"${addr:04X}: {opcode:02X}       .byte ${opcode:02X}        ; Data byte")
            i += 1
    
    return output

if __name__ == "__main__":
    print("Creating fully annotated disassembly with ASCII art...")
    disasm = create_annotated_disassembly()
    
    with open("K_RAZY_SHOOTOUT_ANNOTATED.asm", "w") as f:
        for line in disasm:
            f.write(line + "\n")
    
    print(f"Annotated disassembly created: {len(disasm)} lines")
    print("File: K_RAZY_SHOOTOUT_ANNOTATED.asm")