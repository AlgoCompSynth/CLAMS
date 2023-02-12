Command Line Algorithmic Music System (CLAMS)
================
M. Edward (Ed) Borasky

> “I’ve never seen a happy clam. In fact, most of them were really
> steamed.” \~ M. Edward (Ed) Borasky

## What is this?

`CLAMS` is a text-based interactive environment for composing and
performing music on a [Raspberry Pi Pico H microcontroller
board](https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#raspberry-pi-pico-and-pico-h "Raspberry Pi Pico Website").
This board costs about \$5US and includes soldered male headers and a
debug connector. `CLAMS` could be ported to other boards that use the
RP2040 microcontroller, but I have no plans to do so. To hear or record
the music, you will need a [Pimoroni Pico Audio
Pack](https://shop.pimoroni.com/products/pico-audio-pack?variant=32369490853971).

## How does it work?

`CLAMS` is a domain-specific language built on a Forth compiler /
interpreter. The user connects to the board, either by USB or a wireless
connection, and enters `CLAMS` / Forth code interactively.

## Why Forth?

> “Premature optimization may be the root of all evil, but it is damned
> fun!” \~ M. Edward (Ed) Borasky

1.  Forth (Brodie 2022) is an extensible interactive operating system.
    It supports editing, assembling, compiling, debugging and running
    real-time tasks from a terminal.
2.  Forth is efficient. A well-designed Forth will usually run a task at
    no worse than half the speed of a hand-optimized assembly version.
    `CLAMS` will have several optimizations built in for the ultimate
    speed.
3.  Forth is lean. There are very few concepts to learn, there is
    minimal run-time overhead in RAM, and the whole package takes up
    much less flash space than MicroPython or CircuitPython.

## What about Forth standard (Forth 200x Committee 2012) compatibility?

Not really. `CLAMS` is a tightly-optimized minimal Forth; it won’t even
contain all of the standard’s core word set. Why not?

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
Daisy](https://www.electro-smith.com/daisy "Electro-Smith Daisy") and
the [Rebel Technology
OWL](https://github.com/RebelTechnology/OpenWare "Rebel Technology on GitHub")
platforms. But they have their own SDKs and there’s not much need to
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
EuroPi](https://allensynthesis.co.uk/modules/europi.html "EuroPi module"),
a Eurorack module with an open source MicroPython software platform.
`CLAMS` will be a different approach.

The overall concept is an interactive language for making music on
Raspberry Pi Pico / RP2040. I’m aiming for
[ChucK](https://chuck.stanford.edu/ "ChucK Home Page") (Salazar et al.
2014) semantics with Forth syntax - a single text-based language to
implement both the definitions of synthesized instruments and the
sequences of sounds they make, intended for [live coding /
algorave](https://github.com/toplap/awesome-livecoding "Awesome Live Coding :ist on GitHub")
performances.

## Update 2023-02-10

I’ve gotten back to this project over the past week and I have made a
significant decision. The original plan was to write my own Forth in
assembler using the RP2040 C/C++ SDK. The desiderata were:

- An “interactive macro-assembler”: the programmer could create a Forth
  word as either a sequence of subroutine calls (subroutine threading),
  an assembly-language subroutine (a “CODE” word called as a
  subroutine), or as a macro (position-independent assembly code
  compiled inline).

- Flexible fixed-point and block floating point arithmetic: the RP2040
  does not have hardware floating point, and even though many
  micro-controllers do, fixed point is much more efficient and
  fixed-point digital signal processing is a well-understood technology
  (Padgett and Anderson 2022).

- Word sets aka vocabularies and an RP2040 assembler, with support for
  all the unique features of the RP2040, like the interpolator and the
  libraries in the boot ROM.

- Real-time operating system capabilities - Forth “TASK” operations.

- The ability to build in C/C++ libraries at link time and execute them
  as Forth words.

It turns out that there is an existing Forth that satisfies all of these
(and more!), except for the linking with existing C/C++ libraries. That
Forth is [Travis Bemann’s
`zeptoforth`](https://github.com/tabemann/zeptoforth "zeptoforth on GitHub").

Given the volatile current state of RP2040 audio hardware, there aren’t
really any device-specific libraries I can use aside from the [Arduino
ecosystem](https://github.com/pschatzmann/arduino-audio-tools "Arduino Audio Tools on GitHub")
and MicroPython / CircuitPython. I’ll have to go straight to the
hardware anyhow, and `zeptoforth` has all the low-level words to do that
already. I’ll be using Katz and Gentile (2005), chapter 5 as a guide.

So I will be building `CLAMS` on `zeptoforth`. For those of you
following along at home:

- I’m planning to write enough documentation so that non-Forth
  programmers can follow along. If you’re new to Forth and want to get
  started, Brodie (2022) is the place to start. Note: there are a few
  PDF versions of *Starting Forth* on the web. They may well be older
  versions; the one you want is the web version at
  <https://www.forth.com/starting-forth/0-starting-forth/>
- For those of you that are Forth programmers, the `zeptoforth` words
  are documented at
  [https://github.com/tabemann/zeptoforth/tree/master/html
  (HTML)](https://github.com/tabemann/zeptoforth/tree/master/html "zeptoforth HTML word list")
  and [https://github.com/tabemann/zeptoforth/tree/master/epub
  (EPUB)](https://github.com/tabemann/zeptoforth/tree/master/epub "zeptoforth EPUB word list").
  For more details, see the [`zeptoforth`
  wiki](https://github.com/tabemann/zeptoforth/wiki "zeptoforth wiki").
- There is now a [project
  blog](https://algocompsynth.github.io/CLAMS-Blog/ "CLAMS Project Blog")!
  It’s at <https://algocompsynth.github.io/CLAMS-Blog/>

So, as the saying goes, “Watch this space.” Well … watch ***that***
space!

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-brodie2022" class="csl-entry">

Brodie, Leo. 2022. “Starting Forth.” FORTH, Inc.
<https://www.forth.com/starting-forth/0-starting-forth/>.

</div>

<div id="ref-forth2022" class="csl-entry">

Forth 200x Committee. 2012. “Forth 2012 Standard.” Forth 200x Committee.
<https://forth-standard.org/standard/words>.

</div>

<div id="ref-katz2005embedded" class="csl-entry">

Katz, D. J., and R. Gentile. 2005. *Embedded Media Processing*.
Electronics & Electrical. Elsevier Science.
<https://books.google.com/books?id=4auaDSdzLwsC>.

</div>

<div id="ref-padgett2022fixed" class="csl-entry">

Padgett, W., and D. Anderson. 2022. *Fixed-Point Signal Processing*.
Synthesis Lectures on Signal Processing. Springer International
Publishing. <https://books.google.com/books?id=r4ByEAAAQBAJ>.

</div>

<div id="ref-salazar2014programming" class="csl-entry">

Salazar, S., A. Kapur, G. Wang, and P. Cook. 2014. *Programming for
Musicians and Digital Artists: Creating Music with ChucK*. Manning.
<https://books.google.com/books?id=YzkzEAAAQBAJ>.

</div>

</div>
