Command Line Algorithmic Music System (CLAMS)
================
M. Edward (Ed) Borasky

> “I’ve never seen a happy clam. In fact, most of them were really
> steamed.” ~ M. Edward (Ed) Borasky

## Update - 2024-11-05

Two more audio libraries for Arduino have come to my attention:

1. [Seeed Arduino Audio](https://github.com/Seeed-Studio/Seeed_Arduino_Audio): This appears to be a port
of the Teensy audio library to a generic Arduino board.
2. [Mozzi](https://github.com/sensorium/Mozzi): This is a full-featured digital synthesizer. I've seen
references to Mozzi in books on musical applications of Arduino, most notably _Arduino for Musicians_
by Brent Edstrom.

## Update - 2024-10-25

I haven't posted much here other than code for the past few months. Like many folks,
I was caught off-guard by the
[Raspberry Pi Pico 2 / RP2350 announcement on 2024-08-08](https://www.raspberrypi.com/news/raspberry-pi-pico-2-our-new-5-microcontroller-board-on-sale-now/).
That led to me acquiring several boards from some of the partners, and a complete
rethinking of my development environment and long-term goals for the project.

The development environment is working mostly to my satisfaction. There are some
enhancements I want to make, but I can build projects for RP2040 and RP2350
boards and ***some*** other Arm Cortex M and ***some*** ESP32 boards.

And that leads into the goal shift. Portability is now highly desirable.
I want to be able to run on ESP32-S3, -C3 and -C6 boards, Teensy 4.1
boards, and Electro-Smith Daisy boards in addition to RP2040 and RP2350
boards.

The only development framework / platform that supports this diversity is
Arduino. PlatrformiO can do it, but it uses Arduino under the hood, adding
a number of moving parts. So I need to develop a Forth that works on all
these boards using the Arduino tools.

The Teensy and the Daisy already have both Arduino support and extensive
audio libraries, so all I need to build there is the Forth control
structure. For the other boards, there are two excellent libraries I can use:
[Arduino Audio Tools](https://github.com/pschatzmann/arduino-audio-tools.git)
and [AMY](https://github.com/shorepine/amy.git). My plan is to have both,
assuming there is space in the flash on the boards.

Finally, I am going to restructure this repository using Git submodules.
There will be one submodule for the development environment:
<https://github.com/AlgoCompSynth/CLAMS-devel.git>, one for the documentation:
<https://github.com/AlgoCompSynth/CLAMS-doc.git>, and one for the Forth itself:
<https://github.com/AlgoCompSynth/CLAMS-Forth.git>.

* * * * *

## Overview

`CLAMS` is a text-based interactive environment for composing and
performing music and visuals on a [Pimoroni
PicoVision](https://shop.pimoroni.com/products/picovision?variant=41048911904851).
It can be made to work on other boards using the RP2040 microcontroller,
but you will need additional hardware.

## How does it work?

`CLAMS` is a domain-specific language built on a Forth compiler /
interpreter. The user connects to the board via a serial connection and
enters `CLAMS` / Forth code interactively.

## Why Forth?

> “Premature optimization may be the root of all evil, but it is damned
> fun!” ~ M. Edward (Ed) Borasky

1.  Forth <https://www.forth.com/starting-forth/> is an extensible
    interactive operating system. It supports editing, assembling,
    compiling, debugging and running real-time tasks from a terminal.

2.  Forth is efficient. A well-designed Forth will usually run a task at
    no worse than half the speed of a hand-optimized assembly version.
    `CLAMS` will have several optimizations built in for the ultimate
    speed.

3.  Forth is lean. There are very few concepts to learn, there is
    minimal run-time overhead in RAM, and the whole package takes up
    much less flash space than MicroPython or CircuitPython.

## What about Forth 2012 standard compatibility?

Not really. `CLAMS` is an extended subset of the standard. It won’t
contain all of the standard’s core word set, and it will contain some
extensions to support real-time audio and the RP2040 hardware.

The RP2040 is both limited and complex. It uses the ARM Cortex M0+
instruction set, which doesn’t even have a 32-bit multiply that produces
a 64-bit product. Division is handled by a co-processor. There are also
co-processors for programmable I/O and interpolation /
multiply-accumulate operations.

That said, if a word in `CLAMS` does exist in one of the standard word
sets, it should function the way it does in the standard. The search
order word set will be implemented, and all of the specialized
co-processor operations will be in specialized word sets.

## What about portability?

Again, not really. There are a number of other micro-controller music
boards, most notably the [Electro-Smith
Daisy](https://www.electro-smith.com/daisy%20%22Electro-Smith%20Daisy%22)
and the [Rebel Technology
OWL](https://github.com/RebelTechnology/OpenWare "Rebel Technology on GitHub")
platforms. But they have their own SDKs, so there’s not much need to
port `CLAMS` to them. There are also a number of audio projects that use
the [Teensy® USB Development
Board](https://www.pjrc.com/teensy/ "Teensy Home Page"), which has a
[comprehensive audio
library](https://www.pjrc.com/teensy/td_libs_Audio.html "Teensy Audio Library").
Also, the Daisy, OWL and Teensy processors are all more powerful than
the RP2040.

By contrast, there’s not much for the Raspberry Pi Pico / RP2040. There
are some simple demos, a few do-it-yourself hardware offerings, and
there’s the [Allen Synthesis
EuroPi](https://allensynthesis.co.uk/modules/europi.html%20%22EuroPi%20module%22),
a Eurorack module with an open source MicroPython software platform.
`CLAMS` will be a different approach.

The overall concept is an interactive language for making music on
Raspberry Pi Pico / RP2040. I’m aiming for
[ChucK](https://chuck.stanford.edu/ "ChucK Home Page") (Salazar et al.
2014) semantics with Forth syntax - a single text-based language to
implement both the definitions of synthesized instruments and the
sequences of sounds they make, intended for [live coding /
algorave](https://github.com/toplap/awesome-livecoding "Awesome Live Coding list on GitHub")
performances.
