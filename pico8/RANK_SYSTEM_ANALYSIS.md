# K-RAZY SHOOT-OUT RANK SYSTEM ANALYSIS

## Overview
The original Atari 5200 game displays a skill rank on the Game Over screen based on the player's performance. The rank is calculated using a formula that considers both score and time performance.

## Rank Levels
The game has 6 rank levels, each with 5 classifications (5 = lowest, 1 = highest):

| Index | Rank Name | Description |
|-------|-----------|-------------|
| 0     | GOON      | Lowest performance |
| 8     | ROOKIE    | Beginner level |
| 16    | NOVICE    | Intermediate level |
| 24    | GUNNER    | Good performance |
| 32    | BLASTER   | Very good performance |
| 40    | MARKSMAN  | Highest rank (capped) |

Each rank name is exactly 8 bytes (padded with spaces for shorter names like "GOON").

### Classification System
Within each rank, there are 5 classifications:
- **Class 5**: Lowest within the rank
- **Class 4**: Below average
- **Class 3**: Average
- **Class 2**: Above average
- **Class 1**: Highest within the rank

Example displays:
- "GOON CLASS 5" (worst possible)
- "ROOKIE CLASS 3" (average rookie)
- "MARKSMAN CLASS 1" (best possible)

## Rank Calculation Algorithm

### Pseudocode

```
function calculate_rank():
    # Step 1: Process score data
    # Converts BCD score digits to numeric values
    # Uses offsets 0 and 43 (0x2B) into score table
    
    score_value_1 = convert_score_to_number(offset=0)
    score_value_1 = process_with_parameter(score_value_1, param=49)
    
    score_value_2 = convert_score_to_number(offset=43)
    score_value_2 = process_with_parameter(score_value_2, param=7)
    
    # Step 2: Calculate performance delta
    # Subtracts processed score values (multi-byte subtraction)
    performance = score_value_1 - score_value_2
    
    # Step 3: Adjust for time performance
    # Subtracts time-related values (stored in $CE/$CF)
    performance = performance - time_factor
    
    # Step 4: Handle underflow (negative result)
    if performance < 0:
        performance = 0  # Set to lowest rank
    
    # Step 5: Convert to rank index
    # Multiply by 8 to get index into rank table
    rank_index = performance * 8
    
    # Step 6: Cap at maximum rank
    if rank_index >= 48:
        rank_index = 40  # Cap at MARKSMAN
        performance = 0xD0  # Store capped value
    
    # Step 7: Display rank text
    # Copy 8 bytes from rank table to screen memory
    rank_text = rank_table[rank_index : rank_index + 8]
    display_at_screen_position(rank_text, position=0x06BA)
    
    # Step 8: Calculate classification (1-5)
    # Formula: 53 - performance_value
    # This gives Class 1 (best) for high performance, Class 5 (worst) for low
    classification = 53 - performance
    if classification < 1:
        classification = 1
    if classification > 5:
        classification = 5
    
    # Step 9: Convert performance value to displayable digits
    # Creates a 3-digit decimal display of the performance value
    convert_to_digits(performance)
    
    return rank_text, classification


function convert_score_to_number(offset):
    # Converts two BCD score digits to decimal number
    # Algorithm: (first_digit * 10) + second_digit - 16
    
    digit1 = score_table[offset]
    digit2 = score_table[offset + 1]
    
    # Multiply first digit by 10
    # Using: (digit * 4 + digit) * 2 = digit * 10
    value = digit1 * 4
    value = value + digit1  # Now value = digit1 * 5
    value = value * 2       # Now value = digit1 * 10
    
    # Add second digit
    value = value + digit2
    
    # Adjust for ASCII/BCD offset
    value = value - 16
    
    return value
```

## Key Implementation Details

### Score Processing
- The game uses BCD (Binary Coded Decimal) format for scores
- Two different offsets (0 and 43) are used to access different parts of the score data
- Each score value is processed with different parameters (49 and 7)
- The algorithm performs multi-byte arithmetic for precision

### Time Factor
- Time performance is stored in memory locations $CE (high byte) and $CF (low byte)
- Better time performance (faster completion) results in higher rank
- The time factor is subtracted from the score-based performance value

### Rank Index Calculation
- The final performance value is multiplied by 8 (via three left shifts)
- This creates an index into the 48-byte rank table (6 ranks × 8 bytes each)
- Maximum index is capped at 40 (MARKSMAN rank)

### Classification Calculation
- After determining the rank, the game calculates: `classification = 53 - performance`
- This inverts the scale so higher performance = lower class number (Class 1 is best)
- The classification ranges from 1 (highest) to 5 (lowest)
- Combined with rank, this creates 30 possible skill levels (6 ranks × 5 classes)

### Display
- The 8-character rank name is copied to screen memory at position $06BA
- The classification number (1-5) is calculated and displayed
- Additional digit conversion creates a numeric performance display
- The rank appears on the Game Over screen as "RANK CLASS #" (e.g., "MARKSMAN CLASS 1")
- Also displays: score, time used, power-pack casings used, and high score

## Game Over Screen Flow

```
function game_over_screen():
    1. Clear collision registers
    2. Initialize display hardware
    3. Display "PRESS TRIGGER TO PLAY AGAIN" message
    4. Backup current score to temporary storage
    5. Backup current time to temporary storage
    6. Compare current score with high score
    7. If new high score, update high score table
    8. Call calculate_rank() to determine player rank
    9. Call display_rank() to show rank with scrolling animation
    10. Wait for player input to restart
```

## PICO-8 Implementation Notes

For the PICO-8 port, the rank system can be simplified:

1. **Score-based ranking**: Use final score as primary factor
2. **Time bonus consideration**: Factor in remaining time or time bonuses earned
3. **Simplified formula**: 
   ```
   performance = score / 1000
   rank_index = min(floor(performance / 8), 5)  # 0-5 for 6 ranks
   classification = 5 - (performance % 8)       # 1-5 within rank
   ```

4. **Rank thresholds** (suggested):
   - 0-7999: GOON (Classes 5-1)
   - 8000-15999: ROOKIE (Classes 5-1)
   - 16000-23999: NOVICE (Classes 5-1)
   - 24000-31999: GUNNER (Classes 5-1)
   - 32000-39999: BLASTER (Classes 5-1)
   - 40000+: MARKSMAN (Classes 5-1)

5. **Alternative simpler formula**:
   ```
   # Determine rank (0-5)
   if score < 5000: rank = 0      # GOON
   elif score < 10000: rank = 1   # ROOKIE
   elif score < 20000: rank = 2   # NOVICE
   elif score < 30000: rank = 3   # GUNNER
   elif score < 50000: rank = 4   # BLASTER
   else: rank = 5                 # MARKSMAN
   
   # Determine classification within rank (1-5)
   # Use score modulo to determine position within rank
   rank_score = score % rank_threshold
   class = 5 - min(floor(rank_score / (rank_threshold / 5)), 4)
   ```

6. **Display format**: 
   - Show rank name and classification: "MARKSMAN CLASS 1"
   - Display on game over screen with final score

The exact thresholds should be tuned based on playtesting to ensure ranks feel achievable but challenging.
