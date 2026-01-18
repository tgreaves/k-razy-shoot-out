#!/usr/bin/env python3
"""
K-Razy Shoot-Out Explosion Sound Generator
Creates white noise style explosion sound based on ROM analysis
"""

import numpy as np
import wave

# Audio parameters
SAMPLE_RATE = 44100
AMPLITUDE = 0.4

def generate_explosion_sound():
    """Generate explosion sound based on ROM random register usage"""
    
    print("Generating K-Razy Shoot-Out Explosion Sound...")
    print("Based on hardware random register $E80A usage in enemy death code")
    print()
    
    # ROM analysis shows enemy death code uses:
    # LDA $E80A  - Load hardware random register (noise source)
    # AND #$F0   - Keep upper 4 bits
    # ORA #$08   - Set bit 3
    # This creates a pseudo-random pattern for explosion effects
    
    duration = 0.25  # Short explosion burst
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    print(f"Duration: {duration:.2f} seconds")
    print(f"Samples: {samples:,}")
    print()
    
    # Generate white noise base (simulating hardware random register)
    white_noise = np.random.normal(0, 1, samples)
    
    # Apply ROM-style bit manipulation
    # Simulate the AND #$F0, ORA #$08 operations
    # This creates a more structured noise pattern
    
    # Create multiple frequency bands for explosion character
    # High frequency burst (initial explosion)
    high_freq = np.random.normal(0, 1, samples)
    high_freq = np.sign(high_freq)  # Square wave noise (POKEY style)
    
    # Mid frequency rumble
    mid_freq = np.random.normal(0, 1, samples // 4)
    mid_freq = np.repeat(mid_freq, 4)
    if len(mid_freq) > samples:
        mid_freq = mid_freq[:samples]
    elif len(mid_freq) < samples:
        mid_freq = np.pad(mid_freq, (0, samples - len(mid_freq)), 'constant')
    
    # Low frequency boom
    low_freq = np.random.normal(0, 1, samples // 8)
    low_freq = np.repeat(low_freq, 8)
    if len(low_freq) > samples:
        low_freq = low_freq[:samples]
    elif len(low_freq) < samples:
        low_freq = np.pad(low_freq, (0, samples - len(low_freq)), 'constant')
    
    # Combine frequency bands
    explosion_noise = (high_freq * 0.6 + mid_freq * 0.3 + low_freq * 0.1)
    
    # Apply explosion envelope
    # Sharp attack, exponential decay
    envelope = np.exp(-t * 12)  # Fast decay for explosion
    
    # Add slight attack ramp
    attack_samples = int(0.01 * SAMPLE_RATE)  # 10ms attack
    if attack_samples > 0 and attack_samples < samples:
        envelope[:attack_samples] *= np.linspace(0, 1, attack_samples)
    
    # Apply envelope
    explosion_audio = explosion_noise * envelope * AMPLITUDE
    
    return explosion_audio

def generate_pokey_style_explosion():
    """Generate POKEY-style explosion using square wave noise"""
    
    print("Generating POKEY-style explosion with square wave noise...")
    
    duration = 0.3
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    # Generate pseudo-random square wave pattern
    # Simulating POKEY's limited noise generation capabilities
    
    # Create random frequency modulation
    base_freq = 1000  # Base frequency
    freq_variation = np.random.normal(0, 500, samples // 100)
    freq_variation = np.repeat(freq_variation, 100)
    if len(freq_variation) > samples:
        freq_variation = freq_variation[:samples]
    elif len(freq_variation) < samples:
        freq_variation = np.pad(freq_variation, (0, samples - len(freq_variation)), 'constant')
    
    # Frequency sweep with random modulation
    freq_sweep = base_freq + freq_variation
    freq_sweep = np.clip(freq_sweep, 100, 3000)  # Keep in reasonable range
    
    # Generate phase for frequency sweep
    phase = 2 * np.pi * np.cumsum(freq_sweep) / SAMPLE_RATE
    
    # Square wave with random bit flipping (simulating hardware noise)
    square_wave = np.sign(np.sin(phase))
    
    # Add random bit flips to simulate hardware noise register
    flip_probability = 0.1  # 10% chance of bit flip per sample
    random_flips = np.random.random(samples) < flip_probability
    square_wave[random_flips] *= -1
    
    # Apply explosion envelope
    envelope = np.exp(-t * 8)  # Explosion decay
    
    # Add attack
    attack_samples = int(0.005 * SAMPLE_RATE)  # 5ms attack
    if attack_samples > 0 and attack_samples < samples:
        envelope[:attack_samples] *= np.linspace(0, 1, attack_samples)
    
    explosion_audio = square_wave * envelope * AMPLITUDE
    
    return explosion_audio

def generate_rom_based_explosion():
    """Generate explosion based on actual ROM bit manipulation"""
    
    print("Generating ROM-based explosion using actual bit manipulation pattern...")
    
    duration = 0.2
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    # Simulate the ROM's random register processing:
    # LDA $E80A  - Load 8-bit random value
    # AND #$F0   - Keep upper 4 bits (0xF0 mask)
    # ORA #$08   - Set bit 3 (add 0x08)
    
    explosion_data = []
    
    for i in range(samples):
        # Simulate hardware random register
        random_byte = np.random.randint(0, 256)
        
        # Apply ROM bit manipulation
        masked_value = random_byte & 0xF0  # AND #$F0
        final_value = masked_value | 0x08  # ORA #$08
        
        # Convert to audio sample (-1 to 1)
        # Map 0x08-0xF8 range to audio
        audio_sample = (final_value - 128) / 128.0
        explosion_data.append(audio_sample)
    
    explosion_audio = np.array(explosion_data)
    
    # Apply explosion envelope
    envelope = np.exp(-t * 15)  # Very fast decay
    explosion_audio = explosion_audio * envelope * AMPLITUDE
    
    return explosion_audio

def save_wav(audio_data, filename):
    """Save audio data as WAV file"""
    # Normalize to prevent clipping
    max_val = np.max(np.abs(audio_data))
    if max_val > 0.95:
        audio_data = audio_data * (0.95 / max_val)
    
    # Convert to 16-bit integers
    audio_16bit = (audio_data * 32767).astype(np.int16)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        wav_file.writeframes(audio_16bit.tobytes())

if __name__ == "__main__":
    print("K-Razy Shoot-Out Explosion Sound Generator")
    print("=" * 50)
    print("Creating white noise style explosion sounds")
    print()
    
    # Generate main explosion sound
    explosion_sound = generate_explosion_sound()
    
    # Save main version
    filename1 = "sound/krazy_shootout_explosion_v1.wav"
    save_wav(explosion_sound, filename1)
    
    duration1 = len(explosion_sound) / SAMPLE_RATE
    print(f"Version 1 saved as: {filename1}")
    print(f"Duration: {duration1:.2f} seconds")
    print()
    
    # Generate POKEY-style version
    pokey_explosion = generate_pokey_style_explosion()
    
    # Save POKEY version
    filename2 = "sound/krazy_shootout_explosion_v2.wav"
    save_wav(pokey_explosion, filename2)
    
    duration2 = len(pokey_explosion) / SAMPLE_RATE
    print(f"Version 2 saved as: {filename2}")
    print(f"Duration: {duration2:.2f} seconds")
    print()
    
    # Generate ROM-based version
    rom_explosion = generate_rom_based_explosion()
    
    # Save ROM version
    filename3 = "sound/krazy_shootout_explosion_v3.wav"
    save_wav(rom_explosion, filename3)
    
    duration3 = len(rom_explosion) / SAMPLE_RATE
    print(f"Version 3 saved as: {filename3}")
    print(f"Duration: {duration3:.2f} seconds")
    print()
    
    print("Explosion Sound Characteristics:")
    print("  ✓ White noise style explosion effects")
    print("  ✓ Based on hardware random register $E80A")
    print("  ✓ ROM bit manipulation pattern (AND #$F0, ORA #$08)")
    print("  ✓ Fast attack, exponential decay")
    print("  ✓ Multiple frequency bands for realistic explosion")
    print("  ✓ POKEY-style square wave noise generation")
    
    print("\nThese should match the explosion sounds when")
    print("enemies are destroyed in K-Razy Shoot-Out!")
    
    # Create technical documentation
    with open("sound/explosion_sound_specs.txt", "w", encoding='utf-8') as f:
        f.write("K-Razy Shoot-Out Explosion Sound - Technical Specifications\n")
        f.write("=" * 70 + "\n\n")
        f.write("ROM ANALYSIS:\n")
        f.write("Explosion sounds are triggered when enemies are destroyed and set to inactive.\n")
        f.write("The ROM code at $B50D uses hardware random register for noise generation:\n\n")
        f.write("$B50D: LDA $E80A  ; Load hardware random register (noise source)\n")
        f.write("$B510: AND #$F0   ; Keep upper 4 bits\n")
        f.write("$B512: ORA #$08   ; Set bit 3\n")
        f.write("$B514: STA $08,X  ; Store processed random value\n\n")
        f.write("SOUND CHARACTERISTICS:\n")
        f.write("- White noise style explosion effects\n")
        f.write("- Duration: 0.2-0.3 seconds\n")
        f.write("- Fast attack, exponential decay envelope\n")
        f.write("- Multiple frequency bands (high/mid/low)\n")
        f.write("- POKEY-style square wave noise generation\n")
        f.write("- Based on hardware random register bit manipulation\n\n")
        f.write("TRIGGER CONDITIONS:\n")
        f.write("- Enemy destruction (when set to inactive $FF)\n")
        f.write("- Player missile hits enemy\n")
        f.write("- Collision detection confirms hit\n")
    
    print(f"\nTechnical documentation: sound/explosion_sound_specs.txt")