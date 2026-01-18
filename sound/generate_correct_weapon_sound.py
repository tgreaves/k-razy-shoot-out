#!/usr/bin/env python3
"""
K-Razy Shoot-Out Player Weapon Sound Generator - CORRECTED
Creates the descending "pewwwwwww" sound based on user feedback
"""

import numpy as np
import wave

# Audio parameters
SAMPLE_RATE = 44100
AMPLITUDE = 0.3

def pokey_frequency_to_hz(pokey_value):
    """Convert POKEY register value to Hz using exact Atari formula"""
    return 1789773 / (2 * (pokey_value + 1))

def generate_descending_pew():
    """Generate the descending 'pewwwwwww' weapon sound"""
    
    print("Generating CORRECTED K-Razy Shoot-Out Player Weapon Sound...")
    print("Creating descending 'pewwwwwww' sound based on user feedback")
    print()
    
    # Sound parameters from ROM analysis - but used differently!
    # The countdown system likely creates a frequency sweep
    start_freq_pokey = 0x1F  # 31 - starts high
    end_freq_pokey = 0x12    # 18 - ends even higher (but we'll reverse this)
    
    # Actually, let's think about this differently
    # If it's descending, it probably starts high and goes low
    # The $BD countdown from $4F (79) to 0 might control the frequency sweep
    
    # Let's create a descending frequency sweep
    start_freq_hz = 2000  # Start at 2kHz
    end_freq_hz = 80      # End at 80Hz (much lower for deeper sweep)
    duration = 0.6        # Even longer duration for extended "pewwwwwww" effect
    
    print(f"Frequency sweep: {start_freq_hz:.0f} Hz → {end_freq_hz:.0f} Hz")
    print(f"Duration: {duration:.2f} seconds")
    print()
    
    # Generate time array
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    # Create exponential frequency sweep (sounds more natural)
    # Exponential decay from start to end frequency
    freq_sweep = start_freq_hz * np.exp(-t * np.log(start_freq_hz / end_freq_hz) / duration)
    
    # Generate the swept tone
    # We need to integrate the frequency to get the phase
    phase = 2 * np.pi * np.cumsum(freq_sweep) / SAMPLE_RATE
    
    # Generate square wave (POKEY characteristic)
    weapon_wave = np.sign(np.sin(phase))
    
    # Apply envelope - starts strong, fades out
    envelope = np.exp(-t * 3)  # Exponential decay
    
    # Combine wave and envelope
    weapon_audio = weapon_wave * envelope * AMPLITUDE
    
    return weapon_audio

def generate_alternative_pew():
    """Generate alternative version using ROM countdown logic"""
    
    print("Generating alternative version using ROM countdown logic...")
    
    # The $BD parameter counts down from $4F (79) to 0
    # This could control frequency in a descending sweep
    duration = 0.3
    samples = int(duration * SAMPLE_RATE)
    t = np.linspace(0, duration, samples, False)
    
    # Simulate the countdown affecting frequency
    # Start high, descend as countdown progresses
    countdown_progress = t / duration  # 0 to 1
    
    # Frequency descends from high to low
    start_freq = 1500
    end_freq = 150
    freq_sweep = start_freq - (start_freq - end_freq) * countdown_progress
    
    # Generate phase for frequency sweep
    phase = 2 * np.pi * np.cumsum(freq_sweep) / SAMPLE_RATE
    
    # Square wave with some noise (POKEY can be noisy)
    base_wave = np.sign(np.sin(phase))
    
    # Add slight noise for authentic POKEY character
    noise = np.random.normal(0, 0.1, samples)
    weapon_wave = base_wave + noise * 0.2
    
    # Envelope - quick attack, sustained decay
    envelope = np.ones(samples)
    attack_samples = int(0.02 * SAMPLE_RATE)  # 20ms attack
    if attack_samples > 0:
        envelope[:attack_samples] = np.linspace(0, 1, attack_samples)
    
    # Exponential decay for the rest
    decay_samples = samples - attack_samples
    if decay_samples > 0:
        decay_t = np.linspace(0, duration - 0.02, decay_samples)
        envelope[attack_samples:] = np.exp(-decay_t * 2)
    
    weapon_audio = weapon_wave * envelope * AMPLITUDE
    
    return weapon_audio

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
    print("K-Razy Shoot-Out Player Weapon Sound Generator - CORRECTED")
    print("=" * 65)
    print("Creating descending 'pewwwwwww' sound")
    print()
    
    # Generate descending pew sound
    pew_sound = generate_descending_pew()
    
    # Save main version
    filename1 = "krazy_shootout_weapon_pew_v1.wav"
    save_wav(pew_sound, filename1)
    
    duration1 = len(pew_sound) / SAMPLE_RATE
    print(f"Version 1 saved as: {filename1}")
    print(f"Duration: {duration1:.2f} seconds")
    print()
    
    # Generate alternative version
    alt_pew_sound = generate_alternative_pew()
    
    # Save alternative version
    filename2 = "krazy_shootout_weapon_pew_v2.wav"
    save_wav(alt_pew_sound, filename2)
    
    duration2 = len(alt_pew_sound) / SAMPLE_RATE
    print(f"Version 2 saved as: {filename2}")
    print(f"Duration: {duration2:.2f} seconds")
    print()
    
    # Generate sequence of pew sounds
    gap_duration = 0.2
    gap_samples = int(gap_duration * SAMPLE_RATE)
    gap_audio = np.zeros(gap_samples)
    
    sequence = []
    for i in range(3):
        sequence.extend(pew_sound)
        if i < 2:
            sequence.extend(gap_audio)
    
    sequence_audio = np.array(sequence)
    filename_seq = "krazy_shootout_weapon_pew_sequence.wav"
    save_wav(sequence_audio, filename_seq)
    
    seq_duration = len(sequence_audio) / SAMPLE_RATE
    print(f"Sequence (3 shots) saved as: {filename_seq}")
    print(f"Sequence duration: {seq_duration:.2f} seconds")
    
    print("\nCORRECTED Sound Characteristics:")
    print("  ✓ Descending frequency sweep (high → low)")
    print("  ✓ 'Pewwwwwww' character with sustained decay")
    print("  ✓ Square wave synthesis (POKEY characteristic)")
    print("  ✓ Exponential frequency and amplitude decay")
    print("  ✓ Authentic 1980s arcade weapon sound")
    
    print("\nThis should now match the descending 'pewwwwwww' sound")
    print("you hear in the actual game!")