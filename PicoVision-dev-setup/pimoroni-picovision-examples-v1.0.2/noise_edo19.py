# This basic example shows how you can use PicoSynth to play simple tones.
# It doesn't do anything with the display.

# synthesizer imports
from picosynth import PicoSynth, Channel

# initialize display
from picovision import PicoVision, PEN_RGB555
from picovector import PicoVector, ANTIALIAS_X16

# general imports
import time
import math

display = PicoVision(PEN_RGB555, 640, 480)
display.set_font("bitmap8")
vector = PicoVector(display)
vector.set_antialiasing(ANTIALIAS_X16)
vector.set_font("/floppy_birb/OpenSans-Regular.af", 50)

VOLUME = 0.5

# this handy list converts notes into frequencies
TONES = {
    "B0": 31,
    "C1": 33,
    "CS1": 35,
    "D1": 37,
    "DS1": 39,
    "E1": 41,
    "F1": 44,
    "FS1": 46,
    "G1": 49,
    "GS1": 52,
    "A1": 55,
    "AS1": 58,
    "B1": 62,
    "C2": 65,
    "CS2": 69,
    "D2": 73,
    "DS2": 78,
    "E2": 82,
    "F2": 87,
    "FS2": 93,
    "G2": 98,
    "GS2": 104,
    "A2": 110,
    "AS2": 117,
    "B2": 123,
    "C3": 131,
    "CS3": 139,
    "D3": 147,
    "DS3": 156,
    "E3": 165,
    "F3": 175,
    "FS3": 185,
    "G3": 196,
    "GS3": 208,
    "A3": 220,
    "AS3": 233,
    "B3": 247,
    "C4": 262,
    "CS4": 277,
    "D4": 294,
    "DS4": 311,
    "E4": 330,
    "F4": 349,
    "FS4": 370,
    "G4": 392,
    "GS4": 415,
    "A4": 440,
    "AS4": 466,
    "B4": 494,
    "C5": 523,
    "CS5": 554,
    "D5": 587,
    "DS5": 622,
    "E5": 659,
    "F5": 698,
    "FS5": 740,
    "G5": 784,
    "GS5": 831,
    "A5": 880,
    "AS5": 932,
    "B5": 988,
    "C6": 1047,
    "CS6": 1109,
    "D6": 1175,
    "DS6": 1245,
    "E6": 1319,
    "F6": 1397,
    "FS6": 1480,
    "G6": 1568,
    "GS6": 1661,
    "A6": 1760,
    "AS6": 1865,
    "B6": 1976,
    "C7": 2093,
    "CS7": 2217,
    "D7": 2349,
    "DS7": 2489,
    "E7": 2637,
    "F7": 2794,
    "FS7": 2960,
    "G7": 3136,
    "GS7": 3322,
    "A7": 3520,
    "AS7": 3729,
    "B7": 3951,
    "C8": 4186,
    "CS8": 4435,
    "D8": 4699,
    "DS8": 4978
}

# do 19-EDO calculations
base_frequency = 130.8128 # an octave below middle C
notes_per_octave = 19
ratio = math.pow(2.0, (1.0 / notes_per_octave))
frequencies = [base_frequency]

# PicoSynth uses 16-bit integer frequencies :-(
rounded_frequencies = [round(base_frequency)] 

for index in range(1, 2 * notes_per_octave + 1):
    frequencies.append(ratio * frequencies[index - 1])
    rounded_frequencies.append(round(frequencies[index]))

# named 19-EDO scales from https://en.xen.wiki/w/Strictly_proper_19edo_scales
## 3 3 3 3 3 4 Deutone[6]
## 1 3 3 3 3 3 3 Deutone[7]
## 2 2 3 3 3 3 3 Major Locrian
## 2 3 2 3 3 2 4 Harmonic Minor
## 2 3 2 3 3 3 3 Melodic Minor
## 2 3 2 4 2 3 3 Harmonic Major
## 2 3 3 2 3 3 3 Meantone[7]
## 2 2 3 2 2 3 2 3 Sensi[8]
## 2 2 2 2 2 2 2 2 3 Negri[9]
## 1 2 2 2 2 2 2 2 2 2 Negri[10]

# named 19-EDO chords from https://en.xen.wiki/w/19edo_chords

## Triads
### Chord name | Symbol | Notes | Steps | Cents
### Major | C | C E G | 0-6-11 | 0-379-695
### Minor | Cm, C- | C Eb G | 0-5-11 | 0-316-695
### SuperMajor | Csmaj | C E# G | 0-7-11 | 0-442-695
### SubMinor | Csmin | C Ebb G | 0-4-11 | 0-253-695
### sus4 | Csus4 | C F G | 0-8-11 | 0-505-695
### sus2 | Csus2 | C D G | 0-3-11 | 0-189-695
### Diminished | Cdim, C° | C Eb Gb | 0-5-10 | 0-316-632
### Augmented | Caug, C+ | C E G# | 0-6-12 | 0-379-758

## Tetrads - Major chords
### Major seventh | Cmaj7 | C E G B | 0-6-11-17 | 0-379-695-1074
### Dominant seventh | C7 | C E G Bb | 0-6-11-16 | 0-379-695-1011
### Harmonic seventh | Ch7 | C E G Bbb | 0-6-11-15 | 0-379-695-947
### Sixth | C6 | C E G A | 0-6-11-14 | 0-379-695-884

## Tetrads - Minor chords
### Minor seventh | Cm7 | 0-5-11-16 | 0-316-695-1011
### Minor major seventh | Cmmaj7 | 0-5-11-17 | 0-316-695-1074
### Minor augmented six | Cm+6 | 0-5-11-15 | 0-316-695-947
### Minor six | Cm6 | 0-5-11-14 | 0-316-695-884
### Minor seven flat six (NT aeolian seven) | Cm7(b6) [Faeol7] | 0-5-13-16 | 0-316-821-1011

## Tetrads - Supermajor chords
### Supermajor seventh | Csmaj7 | 0-7-11-18 | 0-442-695-1137

## Tetrads - Subminor chords
### Subminor seventh | Csmin7 | 0-4-11-15 | 0-253-695-947

### Tetrads - Diminished chords
### Diminished seven (fully diminished) | Cdim7, C°7 | 0-5-10-15 | 0-316-632-947
### Minor seven flat five (half-diminished) | Cm7(b5), Cø7 | 0-5-10-16 | 0-316-632-1011

## Tetrads - Augmented chords
### Augmented seven | Caug7, C+7, C7#5 | 0-6-12-16 | 0-379-758-1011
### Major seven sharp five | Cmaj7#5 | 0-6-12-18 | 0-379-758-1137

## Pentads (ninth chords) - Major chords
### Major ninth | Cmaj9 | 0-6-11-17-22 | 0-379-695-1074-1389
### Dominant ninth | C9 | 0-6-11-16-22 | 0-379-695-1011-1389
### Dominant seven flat nine | C7(b9) | 0-6-11-16-21 | 0-379-695-1011-1326
### Harmonic ninth | Ch9 | 0-6-11-15-22 | 0-379-695-947-1389
### Harmonic seven flat nine | Ch7(b9) | 0-6-11-15-21 | 0-379-695-947-1326

# initialize synthesizer
synth = PicoSynth()

# create a new noise channel
noise = synth.channel(0)

# change these details to modify the sound
# waveforms you can use are NOISE, SQUARE, SAW, TRIANGLE, SINE, or WAVE
# you can combine more than one, like this: waveforms=Channel.SQUARE | Channel.SAW,
noise.configure(
    waveforms=Channel.TRIANGLE,
    attack=0.1,
    decay=0.1,
    sustain=0.5,
    release=0.1,
    volume=VOLUME
)
# for more details on what attack, decay, sustain and release mean, see:
# https://en.wikipedia.org/wiki/Synthesizer#ADSR_envelope

synth.play()

while True:

    # clear the screen
    display.set_pen(0)
    display.clear()
    display.update()

    # play a scale
    for note in ["C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5"]:
        noise.frequency(TONES[note])
        noise.trigger_attack()
        time.sleep(0.5)

    # and down again
    for note in ["C5", "B4", "A4", "G4", "F4", "E4", "D4", "C4"]:
        noise.frequency(TONES[note])
        noise.trigger_attack()
        time.sleep(0.5)

    # 19 EDO!
    WHITE = display.create_pen(255, 255, 255)
    AMBER = display.create_pen(0xFF, 0xBF, 0)
    for note in rounded_frequencies:
        frequency_label = f"Playing frequency {note}"

        # clear the screen
        display.set_pen(0)
        display.clear()

        # create a pen and set the drawing color
        display.set_pen(AMBER)

        # draw text
        vector.text(frequency_label, 0, 0)
        display.update()

        noise.frequency(note)
        noise.trigger_attack()
        time.sleep(0.5)
