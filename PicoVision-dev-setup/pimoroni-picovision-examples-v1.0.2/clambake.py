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

# functions
def scale_frequencies(scale_degrees, freq_table, root):

    # contstruct lists
    notes = [root]
    frequencies = [freq_table[root]]
    index = 0
    for degree in scale_degrees:
        notes.append(notes[index] + degree)
        index += 1
        frequencies.append(freq_table[notes[index]])
    return frequencies

def arpeggio_frequencies(arpeggio_degrees, freq_table, root):

    # contstruct lists
    notes = []
    frequencies = []
    for degree in arpeggio_degrees:
        note = root + degree
        notes.append(note)
        frequencies.append(freq_table[note])
    return frequencies

# scale and arpeggio / chord data
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

SCALES_19_EDO = {
    "deutone_6": [3, 3, 3, 3, 3, 4], # Deutone[6]
    "deutone_7": [1, 3, 3, 3, 3, 3, 3], # Deutone[7]
    "major_locrian": [2, 2, 3, 3, 3, 3, 3], # Major Locrian
    "harmonic_minor": [2, 3, 2, 3, 3, 2, 4], # Harmonic Minor
    "melodic_minor": [2, 3, 2, 3, 3, 3, 3], # Melodic Minor
    "harmonic_major": [2, 3, 2, 4, 2, 3, 3], # Harmonic Major
    "meantone_7": [2, 3, 3, 2, 3, 3, 3], # Meantone[7]
    "sensi_8": [2, 2, 3, 2, 2, 3, 2, 3], # Sensi[8]
    "negri_9": [2, 2, 2, 2, 2, 2, 2, 2, 3], # Negri[9]
    "negri_10": [1, 2, 2, 2, 2, 2, 2, 2, 2, 2] # Negri[10]
}

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

# Arpeggios
ARPEGGIOS_19_EDO = {
    "major seventh": [0, 6, 11, 17],
    "dominant seventh": [0, 6, 11, 16],
    "harmonic seventh": [0, 6, 11, 15],
    "sixth": [0, 6, 11, 14],
    "minor seventh": [0, 5, 11, 16],
    "minor major seventh": [0, 5, 11, 17],
    "minor augmented six": [0, 5, 11, 15],
    "minor six": [0, 5, 11, 14],
    "minor seven flat six": [0, 5, 13, 16],
    "supermajor seventh": [0, 7, 11, 18],
    "subminor seventh": [0, 4, 11, 15],
    "diminished seven": [0, 5, 10, 15],
    "minor seven flat five": [0, 5, 10, 16],
    "augmented seven": [0, 6, 12, 16],
    "major seven sharp five": [0, 6, 12, 18]
}

# main program
display = PicoVision(PEN_RGB555, 640, 480)
BLACK = display.create_pen(0, 0, 0)
AMBER = display.create_pen(0xFF, 0xBF, 0)

vector = PicoVector(display)
vector.set_antialiasing(ANTIALIAS_X16)
FONT_SIZE = 36
vector.set_font("/floppy_birb/OpenSans-Regular.af", FONT_SIZE)

VOLUME = 0.5

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

# create a new synthesizer
synth = PicoSynth()

# create a new noise channel
noise = synth.channel(0)

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


# Introduction
display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("CLAMS", 0, 0)
vector.text("- (Command Line Algorithmic Music System)", 0, FONT_SIZE)
vector.text("- A work in progress on GitHub at", 0, 2*FONT_SIZE)
vector.text("- AlgoCompSynth/CLAMS", 0, 3*FONT_SIZE)
display.update()
time.sleep(12.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("What is CLAMS?", 0, 0)
vector.text("- Interactive live coding system", 0, FONT_SIZE)
vector.text("- Based on Forth", 0, 2*FONT_SIZE)
vector.text("- Optimized for Pimoroni PicoVision", 0, 3*FONT_SIZE)
vector.text("- Generates both audio and HDMI video", 0, 4*FONT_SIZE)
display.update()
time.sleep(12.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("Musical goals", 0, 0)
vector.text("- Algorithmic composition", 0, FONT_SIZE)
vector.text("- Algorithmic timbre design", 0, 2*FONT_SIZE)
vector.text("- Microtonal scales and chords", 0, 3*FONT_SIZE)
vector.text("- Dynamic stochastic synthesis", 0, 4*FONT_SIZE)
display.update()
time.sleep(12.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("Language goals", 0, 0)
vector.text("- Collaborative interactions", 0, FONT_SIZE)
vector.text("- Command line / terminal UI", 0, 2*FONT_SIZE)
vector.text("- Easy to extend", 0, 3*FONT_SIZE)
display.update()
time.sleep(12.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("Related projects on GitHub", 0, 0)
vector.text("- AlgoCompSynth/Eikosany", 0, FONT_SIZE)
vector.text("- AlgoCompSynth/consonaR", 0, 2*FONT_SIZE)
vector.text("- AlgoCompSynth/AlgoCompSynth-One", 0, 3*FONT_SIZE)
display.update()
time.sleep(12.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("Project status", 0, 0)
vector.text("- TL;DR - not ready for prime time", 0, FONT_SIZE)
vector.text("- First release by Christmas", 0, 2*FONT_SIZE)
vector.text("- Will run on Pimoroni PicoVision", 0, 3*FONT_SIZE)
display.update()
time.sleep(12.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("So while we're waiting ...", 0, 0)
vector.text("- Demo of target arpeggios and scales", 0, FONT_SIZE)
vector.text("- Done with MicroPython on the PicoVision", 0, 2*FONT_SIZE)
vector.text("- Recorded with OBS Studio", 0, 3*FONT_SIZE)
vector.text("- Released version will have better synth!", 0, 4*FONT_SIZE)
display.update()
time.sleep(12.0)

for name, degrees in ARPEGGIOS_19_EDO.items():
    scale_label = f"Arpeggio {name} frequencies:"
    frequencies = arpeggio_frequencies(degrees, rounded_frequencies, 0)
    frequency_label = f"{frequencies}"

    display.set_pen(BLACK)
    display.clear()
    display.set_pen(AMBER)
    vector.text(scale_label, 0, 0)
    vector.text(frequency_label, 0, FONT_SIZE)
    display.update()

    for freq in frequencies:
        noise.frequency(freq)
        noise.trigger_attack()
        time.sleep(0.5)
        noise.trigger_release()

    frequencies.reverse()
    for freq in frequencies:
        noise.frequency(freq)
        noise.trigger_attack()
        time.sleep(0.5)
        noise.trigger_release()

    time.sleep(2.0)

display.set_pen(BLACK)
display.clear()
time.sleep(2.0)
for name, degrees in SCALES_19_EDO.items():
    scale_label = f"Scale {name} frequencies:"
    frequencies = scale_frequencies(degrees, rounded_frequencies, 0)
    frequency_label = f"{frequencies}"

    display.set_pen(BLACK)
    display.clear()
    display.set_pen(AMBER)
    vector.text(scale_label, 0, 0)
    vector.text(frequency_label, 0, FONT_SIZE)
    display.update()

    for freq in frequencies:
        noise.frequency(freq)
        noise.trigger_attack()
        time.sleep(0.5)
        noise.trigger_release()

    frequencies.reverse()
    for freq in frequencies:
        noise.frequency(freq)
        noise.trigger_attack()
        time.sleep(0.5)
        noise.trigger_release()

    time.sleep(2.0)

display.set_pen(BLACK)
display.clear()
display.set_pen(AMBER)
vector.text("Thanks for watching!", 0, 0)
display.update()
time.sleep(3600.0)
