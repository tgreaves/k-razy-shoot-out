# K-Razy Shoot-Out Arena Generation Analysis

## Overview
The arena generation happens in two phases:
1. **Initial Placement** ($AA13-$AA42): Places 39 elements in alternating pattern
2. **Randomization** ($B974-$BABF): Modifies elements with random patterns

---

## PHASE 1: Initial Element Placement ($AA13-$AA42)

### Main Loop Pseudocode
```
element_counter = 0          // $54 - tracks which element (0-38)
element_parameter = $00      // $69 - pattern data ($00=empty, $AA=wall)
element_type = $4D          // $55 - element type identifier

LOOP while element_counter < 39:
    // Place current element
    CALL place_element(element_counter, element_type, element_parameter)
    
    element_counter++
    
    IF element_counter == 39:
        BREAK  // All 39 elements placed
    
    // Alternate to wall pattern for next element
    element_parameter = $AA     // Switch to wall
    element_type = $02
    element_type = $4D          // Reset type
    
    CALL place_element(element_counter, element_type, element_parameter)
    
    // Visual delay (player watches arena build)
    DELAY(100 iterations)
    
    LOOP back
```

### Place Element Routine ($ACD9-$AD04)
```
FUNCTION place_element(element_counter, element_type, element_parameter):
    // Calculate screen memory address
    // Each element occupies 20 bytes of screen memory
    offset = element_counter * 20
    // Formula: (element_counter * 16) + (element_counter * 4) = element_counter * 20
    
    address = $2800 + offset
    
    // Fill 20 consecutive bytes with pattern
    FOR byte_index = 0 TO 19:
        memory[address + byte_index] = element_parameter
    
    RETURN
```

### Key Facts
- **39 elements total** (numbered 0-38)
- **20 bytes per element** (creates vertical columns on screen)
- **Alternating pattern**: empty, wall, empty, wall, etc.
- **Screen memory**: Starts at $2800
- **Element 0**: bytes $2800-$2813 (empty)
- **Element 1**: bytes $2814-$2827 (wall)
- **Element 2**: bytes $2828-$283B (empty, but special - LEFT EXIT)
- **Element 38**: bytes $2A70-$2A83 (wall, but special - RIGHT EXIT)

---

## PHASE 2: Arena Randomization ($B974-$BABF)

### Entry Point ($B974-$B9D5)
```
FUNCTION generate_arena():
    CALL clear_screen_memory()
    
    // Initialize parameters
    $06 = $A2
    $05 = $70
    $0C = $00
    element_counter = 0        // $54
    pattern_data = $55         // $69
    element_type = $4C         // $55
    
    CALL initial_generation()  // $B8AF
    
    // Setup Element 2 (left exit)
    element_type = $02
    CALL control_system()      // $B90D
    
    // Wall generation phase
    $0D = $00
    pattern_data = $AA         // Wall pattern
    element_type = $03
    element_counter = 2        // Back to Element 2
    
    CALL initial_generation()  // $B8AF
    
    element_type = $4C
    CALL control_system()      // $B90D
    
    // Setup Element 38 (right exit)
    element_counter = $26      // 38 decimal
    CALL control_system()      // $B90D
    
    element_type = $03
    CALL control_system()      // $B90D
    
    // Final Element 2 processing
    element_counter = $02
    CALL control_system()      // $B90D
    
    // Final parameters
    $0E = $00
    pattern_data = $AA
    generation_state = $02     // $92
    element_type = $02
```

### Hardware Random Exit Positioning ($B9D6-$B9E1)
```
FUNCTION generate_random_exit_position():
    // Generate random number 0-5 for exit vertical position
    LOOP:
        random = READ_HARDWARE_RANDOM($E80A)
        random = random AND $07    // Mask to 0-7
        IF random >= 6:
            CONTINUE LOOP          // Rejection sampling
        BREAK
    
    exit_position = random         // $6C - stores 0-5
    $6B = $06
    
    RETURN exit_position
```

### Phase 2A: Randomized Element Processing ($BA28-$BA70)
```
FUNCTION randomized_element_processing():
    pattern_data = $AA             // $69
    element_counter = $0E          // 14 decimal
    generation_state = $03         // $92
    element_type = $03             // $55
    
    LOOP:
        random1 = READ_HARDWARE_RANDOM($E80A) AND $01
        
        IF random1 == 0:
            random2 = READ_HARDWARE_RANDOM($E80A) AND $01
            
            IF random2 == 0:
                element_type = element_type + $0C  // Add 12
        
        CALL advanced_generation()  // $B8AF
        
        element_type = element_type + $0C  // Add 12
        CALL control_system()       // $B90D
        
        generation_state = generation_state + $18  // Add 24
        element_type = generation_state
        
        IF generation_state == $4B:  // 75 decimal
            BREAK
        
        LOOP back
    
    element_counter = element_counter + $0C  // Add 12
    
    IF element_counter != $26:  // 38 decimal
        LOOP back to start
```

### Phase 2B: Secondary Randomization ($BA70-$BAB4)
```
FUNCTION secondary_randomization():
    element_type = $0F             // 15 decimal
    generation_state = $02
    element_counter = $02          // Back to Element 2
    
    LOOP:
        random1 = READ_HARDWARE_RANDOM($E80A) AND $01
        
        IF random1 == 0:
            random2 = READ_HARDWARE_RANDOM($E80A) AND $01
            
            IF random2 == 0:
                element_counter = element_counter + $07  // Add 7
        
        CALL advanced_generation()  // $B8AF
        
        element_counter = element_counter + $05  // Add 5
        CALL control_system()       // $B90D
        
        generation_state = generation_state + $0C  // Add 12
        element_counter = generation_state
        
        IF element_counter == $26:  // 38 decimal
            element_type = element_type + $0C  // Add 12
            
            IF element_type == $4B:  // 75 decimal
                BREAK
            
            // Reset for next iteration
            generation_state = $02
            element_counter = $02
        
        LOOP back
```

### Final Configuration ($BAB4-$BABF)
```
FUNCTION final_configuration():
    random = READ_HARDWARE_RANDOM($E80A)
    random = random OR $07         // Set bits 0,1,2
    $0D = random
    
    $0C = $B7                      // Completion marker
    
    RETURN
```

---

## Analysis Notes

### Element Layout
- Screen is 128 pixels wide
- 39 elements × ~3.3 pixels each ≈ 128 pixels
- Each element's 20 bytes represents a vertical column
- Alternating empty/wall creates base structure

### Randomization Strategy
- Uses hardware random register ($E80A) for true randomness
- Rejection sampling ensures uniform distribution (0-5 for exits)
- Multiple passes modify different element ranges
- Element 2 and 38 get special exit treatment

### Questions to Resolve
1. What do $B8AF and $B90D routines actually do?
2. How do the element_type values map to visual patterns?
3. What's the relationship between element_counter and screen position?
4. How do the random modifications create the wall segments we see?

---

## SCREEN MEMORY MAPPING

### Understanding the 20-Byte Blocks

From $ACD9-$AD04, we see each element is **20 consecutive bytes** in screen memory:
- Element 0: $2800-$2813 (20 bytes)
- Element 1: $2814-$2827 (20 bytes)
- Element 2: $2828-$283B (20 bytes) - LEFT EXIT
- ...
- Element 38: $2A70-$2A83 (20 bytes) - RIGHT EXIT

### Atari 5200 Screen Layout

The Atari 5200 uses character-based graphics. The screen memory at $2800 likely represents:
- **40 columns × 24 rows** of characters (Mode 2)
- Each byte in screen memory = one character on screen
- 20 bytes = 20 rows of a single column (half the screen height)

### Element to Screen Position Mapping

With 39 elements and 40 columns:
- Element 0 = Column 0 (left edge)
- Element 1 = Column 1
- Element 2 = Column 2 (left exit column)
- ...
- Element 38 = Column 38 (right exit column)
- (Column 39 is likely the right edge wall)

### How Bit Patterns Create Walls

Each byte in the 20-byte block represents one row of that column:
- Byte 0 = Row 0 (top)
- Byte 1 = Row 1
- ...
- Byte 19 = Row 19 (bottom)

The bits within each byte control sub-pixel patterns within that character cell:
- $00 = empty (no wall)
- $AA = wall pattern (10101010 binary)
- Other values = partial walls/patterns

### Advanced Placement Bit Manipulation

The advanced placement routine ($B8AF) uses bit masks to modify specific bits:
- **Mask $C0** (11000000): Modifies bits 7,6
- **Mask $30** (00110000): Modifies bits 5,4
- **Mask $0C** (00001100): Modifies bits 3,2
- **Mask $03** (00000011): Modifies bits 1,0

The `element_type >> 2` determines WHICH of the 20 bytes to modify (row selection).
The `element_type AND $03` determines WHICH bit pair to modify (sub-pattern selection).

---

## Next Steps
- ~~Trace through $B8AF (advanced_generation)~~ ✓
- ~~Trace through $B90D (control_system)~~ ✓
- ~~Understand how 20-byte blocks map to screen pixels~~ ✓
- Map element numbers to actual screen X positions for PICO-8


---

## DETAILED ROUTINE ANALYSIS

### Advanced Arena Element Placement ($B8AF-$B90C)

This is the KEY routine that actually draws patterns to screen memory.

```
FUNCTION advanced_arena_element_placement(element_counter, element_type, pattern_data):
    // Calculate screen memory address (same as basic routine)
    offset = element_counter * 20
    address = $2800 + offset
    
    // Extract position bits for pattern selection
    position_index = element_type >> 2  // Divide by 4
    pattern_selector = element_type AND $03  // Get bits 0-1 (0-3)
    
    // Select bit mask based on pattern_selector
    SWITCH pattern_selector:
        CASE 0:
            mask = $C0  // Bits 7,6 (11000000)
        CASE 1:
            mask = $30  // Bits 5,4 (00110000)
        CASE 2:
            mask = $0C  // Bits 3,2 (00001100)
        CASE 3:
            mask = $03  // Bits 1,0 (00000011)
    
    // Extract pattern using mask
    extracted_pattern = pattern_data AND mask
    
    // Combine with existing screen data (additive!)
    existing_data = memory[address + position_index]
    new_data = existing_data OR extracted_pattern
    memory[address + position_index] = new_data
    
    RETURN
```

**KEY INSIGHT**: This routine uses OR operations, meaning it ADDS patterns to existing data rather than replacing it. This allows multiple passes to build up complex wall structures!

### Control System ($B90D-$B96F)

This routine calls the advanced placement multiple times with different parameters.

```
FUNCTION control_system(element_type, element_counter):
    saved_type = element_type
    
    IF element_type == $C0:
        // Special element-based generation
        GOTO special_generation
    
    IF element_type < 0:
        // Reverse generation (incrementing types)
        count = $C0 - element_type
        FOR i = 1 TO count:
            element_type++
            CALL advanced_placement()
        element_type = saved_type
        RETURN
    ELSE:
        // Forward generation (decrementing types)
        count = element_type - $C0
        FOR i = 1 TO count:
            CALL advanced_placement()
            element_type--
        element_type = saved_type
        RETURN
    
special_generation:
    saved_counter = element_counter
    
    IF element_counter < $BF:
        // Forward element processing
        count = $BF - element_counter
        FOR i = 1 TO count:
            element_counter++
            CALL advanced_placement()
    ELSE:
        // Backward element processing
        count = element_counter - $BF
        FOR i = 1 TO count:
            element_counter--
            CALL advanced_placement()
    
    element_counter = saved_counter
    RETURN
```

---

## CRITICAL UNDERSTANDING

### How Patterns Work

1. **20-byte blocks**: Each element is 20 bytes of screen memory
2. **Bit patterns**: Each byte can have bits set to create visual patterns
3. **Additive generation**: Multiple passes OR patterns together
4. **Masks select bits**: Different masks ($C0, $30, $0C, $03) select different bit pairs
5. **Position index**: The `element_type >> 2` determines WHICH of the 20 bytes to modify

### Example

If `element_type = 5`:
- `position_index = 5 >> 2 = 1` (modify byte 1 of the 20-byte block)
- `pattern_selector = 5 AND $03 = 1` (use mask $30)
- If `pattern_data = $AA` (10101010):
  - `extracted = $AA AND $30 = $20` (00100000)
  - This sets bit 5 in byte 1 of the element

### Why This Creates Walls

- Setting bits in screen memory creates visible pixels
- Different bit patterns create different visual shapes
- Multiple passes with different masks build up complex wall structures
- The 20-byte width creates vertical columns
- Bits within each byte create horizontal patterns

---

## NEXT STEPS

1. Map element numbers (0-38) to actual screen X positions
2. Understand how 20 bytes map to visible pixels
3. Trace through one complete generation to see the pattern
4. Simplify for PICO-8 implementation

The key is that this is NOT random placement - it's a deterministic algorithm that uses bit manipulation to create complex patterns from simple rules!


---

## PICO-8 IMPLEMENTATION PLAN

### Screen Mapping

PICO-8 screen: 128×128 pixels
Arena area: ~120×120 pixels (leaving room for HUD)

**Element to X-Position Mapping:**
- 39 elements across ~120 pixels = ~3 pixels per element
- Element 0: X = 0-2
- Element 1: X = 3-5
- Element 2: X = 6-8 (LEFT EXIT)
- Element 3: X = 9-11
- ...
- Element 38: X = 114-116 (RIGHT EXIT)
- Right wall: X = 117-119

**Y-Position Mapping:**
- 20 bytes per element = 20 vertical positions
- Map to Y = 8-116 (arena area, excluding HUD)
- Each byte position = ~5.4 pixels vertically

### Simplified Implementation Strategy

Since PICO-8 uses pixel-based graphics (not character-based), we need to translate:

1. **Element = Column**: Each element number maps to an X position (3 pixels wide)
2. **Byte Index = Row**: Each of the 20 bytes maps to a Y position (~5 pixels tall)
3. **Bit Pattern = Wall Presence**: Instead of bit manipulation, use boolean (wall/no wall)

### Proposed PICO-8 Data Structure

```lua
-- Arena as 2D grid
-- arena[element][byte_index] = pattern_value
arena_data = {}

for element = 0, 38 do
  arena_data[element] = {}
  for byte_idx = 0, 19 do
    arena_data[element][byte_idx] = 0x00  -- Start empty
  end
end
```

### Phase 1: Initial Placement (Simplified)

```lua
function init_arena_phase1()
  local element_param = 0x00  -- Start with empty
  
  for element = 0, 38 do
    -- Fill element with current pattern
    for byte_idx = 0, 19 do
      arena_data[element][byte_idx] = element_param
    end
    
    -- Alternate pattern
    element_param = (element_param == 0x00) and 0xAA or 0x00
  end
end
```

### Phase 2: Randomization (Simplified)

Instead of complex bit manipulation, use simplified random wall placement:

```lua
function init_arena_phase2()
  -- Generate random exit positions (0-5)
  local exit_y = flr(rnd(6))
  
  -- Clear exits at Element 2 and 38
  for y = exit_y*3, exit_y*3+2 do
    arena_data[2][y] = 0x00
    arena_data[38][y] = 0x00
  end
  
  -- Add random interior walls
  for pass = 1, 3 do
    for element = 4, 36, 4 do
      if rnd(1) < 0.5 then
        -- Add vertical wall segment
        local start_y = flr(rnd(15))
        local height = flr(rnd(5)) + 3
        for y = start_y, min(start_y+height, 19) do
          arena_data[element][y] = 0xAA
        end
      end
    end
  end
end
```

### Rendering to PICO-8 Screen

```lua
function draw_arena()
  for element = 0, 38 do
    local x = element * 3
    for byte_idx = 0, 19 do
      if arena_data[element][byte_idx] != 0x00 then
        -- Draw wall block
        local y = 8 + byte_idx * 5
        rectfill(x, y, x+2, y+4, 5)  -- 3×5 pixel blocks
      end
    end
  end
end
```

### Alternative: Keep Current 4×4 Block System

The current PICO-8 implementation uses 4×4 pixel blocks. We can adapt:

```lua
-- Convert element/byte to 4×4 blocks
function element_to_blocks(element, byte_idx)
  local x = element * 3  -- 3 pixels per element
  local y = 8 + byte_idx * 5  -- 5 pixels per byte
  
  -- Round to nearest 4×4 block
  local block_x = flr(x / 4) * 4
  local block_y = flr(y / 4) * 4
  
  return block_x, block_y
end
```

---

## FINAL RECOMMENDATION

For authentic arena generation matching the assembly code:

1. **Use 39-element structure** (not column-by-column)
2. **Implement two-phase generation**:
   - Phase 1: Alternating empty/wall pattern
   - Phase 2: Random modifications with proper exit placement
3. **Simplify bit manipulation** to boolean wall/no-wall for PICO-8
4. **Map elements to X positions** (3 pixels wide each)
5. **Map byte indices to Y positions** (5-6 pixels tall each)
6. **Render as 4×4 blocks** (current system) or 3×5 blocks (closer to original)

This preserves the spirit of the original algorithm while adapting to PICO-8's pixel-based graphics system.
