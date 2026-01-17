#!/usr/bin/env python3
"""
Generate enemy firing sound effect from K-Razy Shoot-Out
Based on analysis of enemy firing sound code at $B4A8-$B4B1
"""

import numpy as np
import wave
import struct

def generate_square_wave(frequency, duration, sample_rate, amplitude=0.3):
    """Generate a square wave with harmonics for authentic POKEY sound"""
    if frequency == 0:
        # Silence
        return np.zeros(int(sample_rate * duration))
    
    # Generate time array
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    
    # Generate square wave with harmonics (POKEY characteristic)
    wave = np.zeros_like(t)
    
    # Fundamental frequency
    wave += amplitude * np.sign(np.sin(2 * np.pi * frequency * t))
    
    # Add harmonics for richer POKEY sound
    wave += amplitude * 0.3 * np.sign(np.sin(2 * np.pi * frequency * 3 * t))
    wave += amplitude * 0.1 * np.sign(np.sin(2 * np.pi * frequency * 5 * t))
    
    return wave

def pokey_frequency_to_hz(pokey_value):
    """
    Convert POKEY frequency value to Hz
    POKEY formula: freq = 1.79MHz / (2 * (pokey_value + 1))
    """
    if pokey_value == 0:
        return 0
    
    # Atari 5200 POKEY clock frequency
    pokey_clock = 1789772.5  # 1.79MHz
    
    # POKEY frequency calculation
    frequency = pokey_clock / (2 * (pokey_value + 1))
    
    return frequency

def generate_enemy_firing_sound():
    """
    Generate the enemy firing sound effect
    Based on code analysis:
    - Parameter: $AC (172 decimal)
    - Duration: $04 frames at 59.92 Hz = ~67ms
    - POKEY register: $E803
    """
    
    sample_rate = 44100
    
    # Enemy firing sound parameters from code analysis
    pokey_param = 0xAC  # 172 decimal
    duration_frames = 4  # $B6 = $04
    frame_rate = 59.92   # Atari 5200 NTSC VBI frequency
    
    # Calculate actual duration
    duration = duration_frames / frame_rate  # ~0.067 seconds
    
    print(f"Enemy Firing Sound Parameters:")
    print(f"POKEY Parameter: ${pokey_param:02X} ({pokey_param})")
    print(f"Duration: {duration_frames} frames @ {frame_rate} Hz = {duration*1000:.1f}ms")
    
    # Convert POKEY parameter to frequency
    # The parameter $AC might be used differently than direct frequency
    # Let's try different interpretations
    
    # Interpretation 1: Direct POKEY frequency value
    base_freq = pokey_frequency_to_hz(pokey_param)
    print(f"Base frequency (direct): {base_freq:.1f} Hz")
    
    # Interpretation 2: Modified frequency (common in games)
    # Often games use lookup tables or modify the base value
    modified_freq = pokey_frequency_to_hz(pokey_param // 2)
    print(f"Modified frequency (÷2): {modified_freq:.1f} Hz")
    
    # Interpretation 3: Higher frequency (for sharp attack sound)
    high_freq = pokey_frequency_to_hz(pokey_param // 4)
    print(f"High frequency (÷4): {high_freq:.1f} Hz")
    
    # Generate multiple versions to compare
    sounds = []
    
    # Version 1: Sharp attack sound (typical for enemy firing)
    # Start high and decay quickly
    attack_duration = duration * 0.3
    decay_duration = duration * 0.7
    
    # Attack phase - high frequency
    attack_freq = high_freq
    attack_wave = generate_square_wave(attack_freq, attack_duration, sample_rate, 0.4)
    
    # Decay phase - lower frequency with envelope
    decay_freq = modified_freq
    decay_wave = generate_square_wave(decay_freq, decay_duration, sample_rate, 0.3)
    
    # Apply envelope to decay
    decay_envelope = np.linspace(1.0, 0.0, len(decay_wave))
    decay_wave *= decay_envelope
    
    enemy_fire_sound = np.concatenate([attack_wave, decay_wave])
    sounds.append(("enemy_fire_sharp", enemy_fire_sound))
    
    # Version 2: Sustained tone (alternative interpretation)
    sustained_wave = generate_square_wave(modified_freq, duration, sample_rate, 0.3)
    # Apply quick attack envelope
    envelope = np.ones_like(sustained_wave)
    attack_samples = int(sample_rate * 0.01)  # 10ms attack
    envelope[:attack_samples] = np.linspace(0, 1, attack_samples)
    sustained_wave *= envelope
    sounds.append(("enemy_fire_sustained", sustained_wave))
    
    # Version 3: Pulse sound (short burst)
    pulse_freq = base_freq
    pulse_wave = generate_square_wave(pulse_freq, duration, sample_rate, 0.35)
    # Apply sharp envelope
    pulse_envelope = np.ones_like(pulse_wave)
    fade_samples = int(len(pulse_wave) * 0.3)
    pulse_envelope[-fade_samples:] = np.linspace(1, 0, fade_samples)
    pulse_wave *= pulse_envelope
    sounds.append(("enemy_fire_pulse", pulse_wave))
    
    return sounds

def save_wav(filename, audio_data, sample_rate=44100):
    """Save audio data as WAV file"""
    # Normalize audio
    audio_data = audio_data / np.max(np.abs(audio_data))
    
    # Convert to 16-bit integers
    audio_data = (audio_data * 32767).astype(np.int16)
    
    # Save as WAV
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(audio_data.tobytes())
    
    print(f"Saved: {filename}")

def main():
    print("K-Razy Shoot-Out Enemy Firing Sound Generator")
    print("=" * 50)
    
    # Generate enemy firing sounds
    sounds = generate_enemy_firing_sound()
    
    # Save all versions
    for name, audio in sounds:
        filename = f"krazy_{name}.wav"
        save_wav(filename, audio)
    
    # Create info file
    with open("enemy_firing_sounds_info.txt", "w") as f:
        f.write("K-Razy Shoot-Out Enemy Firing Sound Effects\n")
        f.write("=" * 45 + "\n\n")
        f.write("Generated from code analysis of enemy firing routine at $B4A8-$B4B1\n\n")
        f.write("Sound Parameters:\n")
        f.write("- POKEY Parameter: $AC (172 decimal)\n")
        f.write("- Duration: 4 frames @ 59.92 Hz = ~67ms\n")
        f.write("- POKEY Register: $E803\n\n")
        f.write("Generated Versions:\n")
        f.write("1. krazy_enemy_fire_sharp.wav - Sharp attack with decay (most likely)\n")
        f.write("2. krazy_enemy_fire_sustained.wav - Sustained tone\n")
        f.write("3. krazy_enemy_fire_pulse.wav - Pulse burst\n\n")
        f.write("The sharp attack version is most likely correct for enemy firing,\n")
        f.write("as it provides the distinctive 'zap' sound typical of enemy weapons\n")
        f.write("in 1980s arcade games.\n")
    
    print("\nGenerated enemy firing sound effects!")
    print("Check the WAV files to hear the different interpretations.")

if __name__ == "__main__":
    main()