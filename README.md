Command Line Algorithmic Music System (CLAMS)
================
M. Edward (Ed) Borasky

> “I’ve never seen a happy clam. In fact, most of them were really
> steamed.” \~ M. Edward (Ed) Borasky

## What is this?

CLAMS is a text-based interactive environment for composing and
performing music on a [Raspberry Pi Pico WH microcontroller
board](https://sbcshop.myshopify.com/products/raspberry-pi-pico-wh?variant=40047914090579).
This board costs about \$9US and includes soldered male headers, a
debugging connector, and a 2.4 GHz WiFi transceiver. CLAMS could be
ported to other boards that use the RP2040 microcontroller, but I have
no plans to do so. To hear or record the music, you will need a
[Pimoroni Pico Audio
Pack](https://shop.pimoroni.com/products/pico-audio-pack?variant=32369490853971).

## How does it work?

CLAMS is a domain-specific language built on a Forth compiler /
interpreter. The user connects to the board, either by USB or a wireless
connection, and enters CLAMS / Forth code interactively.

## Why Forth?

> “Premature optimization may be the root of all evil, but it is damned
> fun!” \~ M. Edward (Ed) Borasky

1.  Forth is an extensible interactive operating system. It supports
    editing, assembling, compiling, debugging and running real-time
    tasks from a terminal.
2.  Forth is efficient. A well-designed Forth will usually run a task at
    no worse than half the speed of a hand-optimized assembly version.
    CLAMS has several optimizations built in for the ultimate speed.
3.  Forth is lean. There are very few concepts to learn, there is
    minimal run-time overhead in RAM, and the whole package takes up
    much less flash space than MicroPython or CircuitPython.

## What about [Forth standard](https://forth-standard.org/standard/words) compatibility?

Not really. CLAMS is a tightly-optimized minimal Forth; it won’t even
contain all of the standard’s [core word
set](https://forth-standard.org/standard/core). Why not?

The RP2040 is both limited and complex. It uses the ARM Cortex M0+
instruction set, which doesn’t even have a 32-bit multiply that produces
a 64-bit product. Division is handled by a co-processor. There are also
co-processors for programmable I/O and interpolation /
multiply-accumulate operations.

That said, if a word in CLAMS does exist in one of the standard word
sets, it will function the way it does in the standard. The search order
word set will be implemented, and all of the specialized co-processor
operations will be in specialized vocabularies.

## What about portability?

Again, not really. There are a number of other microcontroller music
boards, most notably the Electro-Smith Daisy and the Rebel Technology
OWL platforms. But they have their own SDKs and there’s not much need to
port CLAMS to them. There are also a number of audio projects that use
the Teensy, which also has a comprehensive audio library. Also, the
Daisy, OWL and Teensy processors are all more powerful than the RP2040.

By contrast, there’s not much for the Raspberry Pi Pico. There are some
simple demos, and there’s a Eurorack module with an open source
MicroPython software platform. CLAMS is more bare-metal.

## References
