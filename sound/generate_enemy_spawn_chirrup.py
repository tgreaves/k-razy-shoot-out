#!/usr/bin/env python3
"""
K-Razy Shoot-Out Enemy Spawn Chirrup Sound Generator
Creates the distinctive "chirrup" sound when enemies spawn/appear
"""

import numpy as np
import wave

# Audio parameters
SAMPLE_RATE = 44100
AMPLITUDE = 0.3

def pokey_frequency_to_hz(pokey_value):
    """Convert POKEY register value to Hz using exact Atari formula"""
    return 1789773 / (2 * (pokey_value + 1))

def generate_enemy_spawn_chirrup():
    """Generate the enemy spawn chirrup sound based on ROM analysis"""
    
    print("Generating K-Razy Shoot-Out Enemy Spawn Chirrup Sound...")
    print("Based on $B7 timer system and $E803 POKEY register")
    print()
    
    # Sound parameters from ROM analysis
    # $B7 starts at $A0 (160) and decrements to $A0 (completion)
    # Each decrement writes to $E803 (POKEY sound register)
    
    start_value = 0xA0  # 160 - initial $B7 value
    end_value = 0xA0    # 160 - completion value (when timer stops)
    
    # The sound is created by the decrementing countdown
    # Let's simulate this as a frequency sweep
    
    # Convert POKEY values to frequencies
    # Higher POKEY values = lower frequencies
    base_freq_hz = pokey_frequency_to_hz(start_value)
    
    # Lower by 4 octaves (divide by 16)
    start_freq_hz = base_freq_hz / 16
    
    # The chirrup is a quick ascending frequency sweep
    # As the timer decrements, the frequency changes
    duration = 0.15  # Short chirrup duration
    
    print(f"POKEY value: ${start_value:02X} ({start_value})")
    print(f"Original frequency: {base_freq_hz:.1f} Hz")
    print(f"Lowered frequency (4 octaves down): {start_freq_hz:.1f} Hz")
    print(f"Duration: {duration:.2f} seconds")
    print()
    
    # Generate time array
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    # Create ascending frequency chirrup
    # Start at base frequency and sweep up quickly
    end_freq_hz = start_freq_hz * 2.5  # Sweep up to higher frequency
    
    # Exponential frequency sweep (chirrup characteristic)
    freq_sweep = start_freq_hz * np.exp(t * np.log(end_freq_hz / start_freq_hz) / duration)
    
    # Generate the swept tone
    # We need to integrate the frequency to get the phase
    phase = 2 * np.pi * np.cumsum(freq_sweep) / SAMPLE_RATE
    
    # Generate square wave (POKEY characteristic)
    chirrup_wave = np.sign(np.sin(phase))
    
    # Apply envelope - quick attack, fast decay (chirrup characteristic)
    envelope = np.exp(-t * 8)  # Fast exponential decay
    
    # Add slight attack
    attack_samples = int(0.01 * SAMPLE_RATE)  # 10ms attack
    if attack_samples > 0 and attack_samples < samples:
        envelope[:attack_samples] *= np.linspace(0, 1, attack_samples)
    
    # Combine wave and envelope
    chirrup_audio = chirrup_wave * envelope * AMPLITUDE
    
    return chirrup_audio

def generate_alternative_chirrup():
    """Generate alternative chirrup using different approach"""
    
    print("Generating alternative chirrup using timer countdown simulation...")
    
    # Simulate the actual timer countdown
    duration = 0.12
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    # The timer creates discrete frequency steps
    # Simulate this with a stepped frequency sweep
    base_freq_original = pokey_frequency_to_hz(0xA0)  # 160
    base_freq = base_freq_original / 16  # Lower by 4 octaves
    
    # Create stepped frequency changes
    num_steps = 8  # Number of timer decrements
    step_duration = duration / num_steps
    
    freq_array = np.zeros(samples)
    for i in range(num_steps):
        start_sample = int(i * step_duration * SAMPLE_RATE)
        end_sample = int((i + 1) * step_duration * SAMPLE_RATE)
        if end_sample > samples:
            end_sample = samples
        
        # Each step has slightly higher frequency (ascending chirrup)
        step_freq = base_freq * (1.0 + i * 0.3)
        freq_array[start_sample:end_sample] = step_freq
    
    # Generate phase for stepped frequency
    phase = 2 * np.pi * np.cumsum(freq_array) / SAMPLE_RATE
    
    # Square wave with some noise (POKEY can be noisy)
    base_wave = np.sign(np.sin(phase))
    
    # Add slight noise for authentic POKEY character
    noise = np.random.normal(0, 0.05, samples)
    chirrup_wave = base_wave + noise * 0.3
    
    # Envelope - quick chirrup envelope
    envelope = np.exp(-t * 6)  # Fast decay
    
    chirrup_audio = chirrup_wave * envelope * AMPLITUDE
    
    return chirrup_audio

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
    print("K-Razy Shoot-Out Enemy Spawn Chirrup Sound Generator")
    print("=" * 60)
    print("Creating the distinctive chirrup sound when enemies spawn")
    print()
    
    # Generate main chirrup sound
    chirrup_sound = generate_enemy_spawn_chirrup()
    
    # Save main version
    filename1 = "sound/krazy_shootout_enemy_spawn_chirrup_v1.wav"
    save_wav(chirrup_sound, filename1)
    
    duration1 = len(chirrup_sound) / SAMPLE_RATE
    print(f"Version 1 saved as: {filename1}")
    print(f"Duration: {duration1:.2f} seconds")
    print()
    
    # Generate alternative version
    alt_chirrup_sound = generate_alternative_chirrup()
    
    # Save alternative version
    filename2 = "sound/krazy_shootout_enemy_spawn_chirrup_v2.wav"
    save_wav(alt_chirrup_sound, filename2)
    
    duration2 = len(alt_chirrup_sound) / SAMPLE_RATE
    print(f"Version 2 saved as: {filename2}")
    print(f"Duration: {duration2:.2f} seconds")
    print()
    
    print("Enemy Spawn Chirrup Sound Characteristics:")
    print("  ✓ Based on $B7 timer system ($A0 = 160)")
    print("  ✓ Quick ascending frequency sweep")
    print("  ✓ Short duration (~0.12-0.15 seconds)")
    print("  ✓ Square wave synthesis (POKEY characteristic)")
    print("  ✓ Fast attack and decay (chirrup envelope)")
    print("  ✓ Distinctive from firing sounds")
    
    print("\nThis should match the chirrup sound you hear")
    print("when enemies spawn or appear in the game!")
    
    # Create technical documentation
    with open("sound/enemy_spawn_chirrup_specs.txt", "w", encoding='utf-8') as f:
        f.write("K-Razy Shoot-Out Enemy Spawn Chirrup - Technical Specifications\n")
        f.write("=" * 70 + "\n\n")
        f.write("SOUND SYSTEM ANALYSIS:\n")
        f.write("The enemy spawn chirrup is generated by the $B7 timer system:\n\n")
        f.write("ROM IMPLEMENTATION:\n")
        f.write("- $B7 timer set to $A0 (160) when enemy spawns\n")
        f.write("- Timer decrements at $A69A: SBC #$01\n")
        f.write("- Decremented value written to $E803 (POKEY sound register)\n")
        f.write("- Creates descending/ascending frequency sweep\n")
        f.write("- Timer completes when reaching $A0 (comparison at $A695)\n\n")
        f.write("SOUND CHARACTERISTICS:\n")
        f.write("- Base frequency: ~5.6 kHz (POKEY value $A0)\n")
        f.write("- Duration: ~0.12-0.15 seconds\n")
        f.write("- Envelope: Fast attack, quick decay (chirrup characteristic)\n")
        f.write("- Waveform: Square wave (POKEY synthesis)\n")
        f.write("- Frequency sweep: Ascending chirrup pattern\n\n")
        f.write("TRIGGER CONDITIONS:\n")
        f.write("- Enemy spawning/appearance\n")
        f.write("- Possibly level transitions\n")
        f.write("- Different from firing sounds ($AC = 172)\n")
    
    print(f"\nTechnical documentation: sound/enemy_spawn_chirrup_specs.txt")