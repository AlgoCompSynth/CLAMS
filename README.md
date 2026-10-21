# CLAMS - Command Line Algorithmic Music System

> "Happy as a clam? You know what? I've never seen a happy clam. In
> fact, most of them were pretty steamed!" - Buck Borasky, Frontier
> Programmer

## What is this?

The goal of CLAMS is to get the most possible computer music out of
the smallest possible computers. The current version is aimed at
Raspberry Pi single-board computers, compute modules and
microcontrollers. CLAMS features

- A minimalist command-line approach based on
[Alpine Linux](https://wiki.alpinelinux.org/wiki/Main_Page),
- Multiple connection options - USB, HDMI, wired / wireless Ethernet
and Bluetooth,
- Audio plumbing:
    - [PipeWire](https://docs.pipewire.org/) with ALSA, JACK, and PulseAudio
    support,
    - [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/),
    - [rtkit](https://gitlab.freedesktop.org/pipewire/rtkit?anubis_answer=lemon)
- The
[FluidSynth](https://www.fluidsynth.org/) SoundFont-based synthesizer,
- The
[Faust](https://faust.grame.fr/) functional music programming language
and development toolchain,
- The
[ChucK](https://chuck.stanford.edu/) real-time music programming language, and
- The
[Arduino CLI](https://docs.arduino.cc/arduino-cli/) and
[PlatformIO Core](https://docs.platformio.org/en/latest/core/) cross-development
toolchains for common microcontrollers, including the Daisy Seed, PJRC Teensy
and RP2040/2350.

## Why Alpine Linux?

The primary target for CLAMS is the Raspberry Pi Zero 2 W. The
available RAM on a freshly-booted Zero 2 W with a wireles connection
is almost 100 megabytes more for 64-bit Alpine Linux than for 64-bit
Raspberry Pi OS Lite.

- Alpine Linux 64-bit:

    ```
    $ free -h
                  total        used        free      shared  buff/cache   available
    Mem:         415.7M       45.1M      108.9M      340.0K      261.7M      360.0M
    Swap:             0           0           0
    ```

- Raspberry Pi OS Lite 64-bit:

    ```
    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           415Mi       152Mi        81Mi       2.5Mi       235Mi       262Mi
    Swap:          414Mi          0B       414Mi
    ```

## Why Faust?

Faust is an optimizing compiler for computer music programming. Target environments
include the Daisy Seed, PJRC Teensy, Bela, Rust and WebAssembly. There is a vibrant
Faust community, including AI toolmakers. Faust comes with many examples and has an
extensive online manual. See also
[Audio Signal Processing in FAUST](https://ccrma.stanford.edu/~jos/aspf/)

## Why ChucK?

ChucK is a strongly-timed real-time music programming language. In addition to
classic digital sythesis techniques like FM, virtual analogue, granular, and sample
playback, ChucK allows creating music algorithmically, one sample at a time. Like
Faust, ChucK comes with many examples. There is an excellent ChucK textbook at
[Programming for Musicians and Digital Artists](https://www.manning.com/books/programming-for-musicians-and-digital-artists).

## The command line

The CLAMS command line uses the standard Linux `bash` shell instead of the minimalist
shell Alpine Linux provides as a default. The [Starship](https://starship.rs/)
cross-shell prompt generator is included. For best results you will need a
[nerd font](https://www.nerdfonts.com/) ***in your terminal emulator***.

Also installed:
- [Neovim](https://neovim.io/doc/),
- [tmux](https://tmux.app/doc/),
- [LuaJIT](https://luajit.org/),
- [Fennel](https://fennel-lang.org/), and
- [Lynx](https://lynx.browser.org/).

## Project status

This is the first alpha release, `v0.7.5`. It has most of what I want and can be
installed on a Raspberry Pi Zero 2 W or any larger Raspberry Pi. It is currently
based on Alpine Edge and uses some packages, especially Faust, from the
[Alpine testing repository](https://wiki.alpinelinux.org/wiki/Repositories#Using_testing_repository).
A formal release candidate will not happen until at least Faust has migrated out
of testing into an Alpine stable release.

## Contributing

I'm actively looking for feature requests and, to a lesser extent, testers.
Setting this up is a bit tricky; see [./alpine-setup/README.md](./alpine-setup/README.md)
for the details. For feature requests, questions about usage and bug reports, open an
issue at <https://github.com/AlgoCompSynth/CLAMS/issues/new>. I have a few outstanding
upstream issues and plenty of remaining testing / dogfooding queued up, but my primary
focus at this time is exploring the capacity boundaries of the Raspberry Pi Zero 2 W.

## Capacity notes

The CPU is unlikely to be an issue for audio; it has four 1 GHz 64-bit Arm cores
that include the Neon SIMD instructions. And the available RAM is more than enough
for most conceivable audio processing. Many commercial musical instruments use
microcontrollers with much less CPU capacity than the Zero 2 W.

Where the rough edges are is RAM usage during compilation. Faust is a compiler,
and most of its outputs need to be run through the target device's compiler.
Optimizing compilers use a fair amount of RAM; for example, compiling ChucK can use
half of the RAM in the Zero 2 W on some routines.

As a result, on the Zero 2 W, using multiple cores in compiling is often problematic.
So there are going to be some interesting musical artifacts that can't be produced
on the Pi Zero 2 W. If you're interested in cross-development of musical software
with CLAMS, you might well need a larger Raspberry Pi. I have an 8 GB Pi 4 and a
16 GB Pi 5 I can test on, to determine the requirements of large examples that
break in the Zero 2 W.
