# Tally Screen Pseudocode Analysis

Based on analysis of K_RAZY_SHOOTOUT_ANNOTATED.asm

## Overview
The tally screen appears between levels after the player escapes through an exit. It shows how many enemies were defeated, categorized by point value (100pt, 50pt, 10pt), and awards bonus points if applicable.

## Key Variables
- `$D4` - Total enemies defeated by player in current level
- `$D2` - Count of 10-point enemies defeated
- `$D3` - Count of 50-point enemies defeated  
- `$D4` - Count of 100-point enemies defeated (reused variable)
- `$D1` - Total enemies that spawned in level (spawn limit)
- `$D5` - Current sector/level number (0-7)
- `$D9` - Time remaining counter
- Character `$1C` - Enemy sprite character used for display

## Main Flow

```pseudocode
FUNCTION player_escapes():
    // Called when player touches arena edge ($A35F-$A36A)
    
    // 1. Check if level should advance
    CALL check_sector_cleared()
        // Only increments $D5 if ALL enemies defeated ($D4 >= $D1)
        // Otherwise decrements $D5 (replay same level)
    
    // 2. Jump back to sector initialization
    JUMP back_to_init_sector
    
    
FUNCTION back_to_init_sector():
    // This leads to init_sector ($A9B6)
    
    IF level > 0:
        // 3. Show animated screen transition with tally
        CALL animated_screen_transition()
    
    // 4. Continue with new sector setup
    CALL generate_new_arena()


FUNCTION animated_screen_transition():
    // Main tally screen routine ($AAD6-$AB01)
    
    // Save registers
    PUSH A, X, Y
    
    // Initialize display registers
    $E808 = $00
    $E801 = $AC  // Audio/visual control
    $E800 = $50  // Animation counter (80 decimal)
    
    // Animate screen clearing effect
    WHILE $E800 > $10:
        CALL delay_routine()
        $E800 = $E800 - 1
    END WHILE
    
    // Clear control register
    $E801 = $00
    
    // Restore registers
    POP Y, X, A
    RETURN


// This is called during the sector initialization sequence
// After the animated transition, around $AA4A-$AAD3
FUNCTION display_enemy_tally():
    // Setup display system
    CALL prepare_display_and_input_scanning()
    
    // Display "100 POINT" enemies (if any)
    enemy_count = $D4  // 100-point enemy count
    point_value = $64  // 100 in decimal
    CALL display_enemy_kill_count(enemy_count, point_value)
    CALL screen_refresh()
    
    // Display "50 POINT" enemies (if any)
    enemy_count = $D3  // 50-point enemy count
    point_value = $32  // 50 in decimal
    CALL display_enemy_kill_count(enemy_count, point_value)
    CALL screen_refresh()
    
    // Display "10 POINT" enemies (if any)
    enemy_count = $D2  // 10-point enemy count
    point_value = $0A  // 10 in decimal
    CALL display_enemy_kill_count(enemy_count, point_value)
    
    // Wait for visual effect
    FOR i = 1 TO 6:
        CALL screen_refresh()
    END FOR


FUNCTION display_enemy_kill_count(kill_count, point_value):
    // Routine at $AC26-$AC92
    // Displays enemy sprites on screen to show how many were killed
    
    IF kill_count == 0:
        RETURN  // Nothing to display
    END IF
    
    // Determine screen position based on point value
    IF point_value == $64:  // 100-point enemies
        screen_row_1 = $2C12
        screen_row_2 = $2C26
        screen_row_3 = $2C3A
    ELSE IF point_value == $32:  // 50-point enemies
        screen_row_1 = $2C62
        screen_row_2 = (not used, only 1 row)
        screen_row_3 = (not used)
    ELSE:  // 10-point enemies (default)
        screen_row_1 = $2C9E
        screen_row_2 = (not used, only 1 row)
        screen_row_3 = (not used)
    END IF
    
    enemy_sprite = $1C  // Character code for enemy sprite
    
    // Display enemies one by one with animation
    remaining = kill_count
    screen_position = 8  // Starting Y offset
    
    // Row 1
    WHILE remaining > 0 AND screen_position < $15:
        screen_row_1[screen_position] = enemy_sprite
        CALL sprite_positioning_update()  // Sound/visual effect
        remaining = remaining - 1
        screen_position = screen_position + 1
    END WHILE
    
    // Row 2 (for 100-point enemies only)
    IF point_value == $64 AND remaining > 0:
        screen_position = 8
        WHILE remaining > 0 AND screen_position < $15:
            screen_row_2[screen_position] = enemy_sprite
            CALL sprite_positioning_update()
            remaining = remaining - 1
            screen_position = screen_position + 1
        END WHILE
    END IF
    
    // Row 3 (for 100-point enemies only)
    IF point_value == $64 AND remaining > 0:
        screen_position = 8
        WHILE remaining > 0 AND screen_position < $15:
            screen_row_3[screen_position] = enemy_sprite
            CALL sprite_positioning_update()
            remaining = remaining - 1
            screen_position = screen_position + 1
        END WHILE
    END IF
    
    RETURN


FUNCTION sprite_positioning_update():
    // Routine at $AAD6
    // Creates delay and possibly plays sound effect
    // Makes each enemy sprite appear one at a time
    CALL timing_delay()


FUNCTION timing_delay():
    // Routine at $AC0C-$AC25
    // Creates visible delay between enemy sprite appearances
    
    delay_counter = 0
    
    WHILE delay_counter < 1:
        // Nested delay loops for timing
        FOR x = $FF DOWN TO 0:
            FOR y = $FF DOWN TO 0:
                // Empty loop for timing
            END FOR
        END FOR
        delay_counter = delay_counter + 1
    END WHILE
    
    RETURN


// After tally display, bonus points are awarded
FUNCTION check_and_award_bonus():
    // Routine at $AB4A-$AB68
    
    // Check if all enemies were defeated
    IF $94 AND $95 AND $96 == 1:  // All enemy slots defeated
        IF $D4 >= $D1:  // Defeated count >= spawn limit
            // Award bonus based on time remaining
            IF $D9 >= $35:  // Time >= 53
                bonus_amount = 10
                display_param = $C6
            ELSE IF $D9 >= $1B:  // Time >= 27
                bonus_amount = 3
                display_param = $1A
            ELSE:
                // No bonus
                RETURN
            END IF
            
            // Display "BONUS POINTS" with flashing effect
            CALL display_bonus_points(bonus_amount, display_param)
        END IF
    END IF


FUNCTION display_bonus_points(bonus_amount, display_param):
    // Routine at $AB75-$ABA7
    
    // Display "BONUS POINTS" text at screen position
    FOR i = 0 TO 13:  // 14 characters
        char = bonus_text[i]
        screen_char = char + $20  // Convert to screen code
        screen_memory[$2C80 + i] = screen_char
    END FOR
    
    // Flash and award points
    FOR i = 1 TO bonus_amount:
        CALL fire_sound_and_add_points()  // Adds points to score
        CALL play_audio_tone()  // Flashing effect
    END FOR
    
    CALL final_timing_delay()
    
    RETURN


// Finally, display "ENTER SECTOR X" message
FUNCTION display_enter_sector():
    // Routine at $ABB4-$ABDD
    
    level_number = $D5 + 1  // Convert 0-based to 1-based
    level_char = level_number + '0'  // Convert to ASCII
    
    // Display "ENTER SECTOR " text
    FOR i = 0 TO 12:
        char = enter_sector_text[i]
        screen_char = char + $20
        screen_memory[$2467 + i] = screen_char
    END FOR
    
    // Display level number
    screen_memory[$2474] = level_char
    
    // Wait for effect
    FOR i = 1 TO 4:
        CALL timing_delay()
    END FOR
    
    // Reset counters for new level
    $D9 = $4D  // Time remaining = 77
    $D4 = 0    // Clear shot counter
    $D3 = 0    // Clear hit counter
    $D2 = 0    // Clear additional counter
    
    RETURN
```

## Summary

The tally screen sequence:

1. **Player escapes** through arena edge
2. **Check level completion** - only advance if all enemies defeated
3. **Animated transition** - screen clearing effect (if level > 0)
4. **Display enemy tally** - show enemy sprites for each defeated enemy, grouped by point value:
   - 100-point enemies (up to 3 rows of 13 enemies each)
   - 50-point enemies (1 row of 13 enemies)
   - 10-point enemies (1 row of 13 enemies)
5. **Award bonus points** (if applicable) - based on time remaining
6. **Display "ENTER SECTOR X"** message
7. **Generate new arena** and start next level

The key visual effect is displaying enemy sprites one at a time with delays, creating a "counting up" animation that shows the player how many enemies they defeated.
