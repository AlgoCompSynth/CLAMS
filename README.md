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

The initial target for CLAMS is the Raspberry Pi Zero 2 W. The
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
Faust community, including AI toolmakers.

## Project status

This is the first alpha release, `v0.7.5`. It has most of what I want and can be
installed on a Raspberry Pi Zero 2 W or any larger Raspberry Pi. It is currently
based on Alpine Edge and uses some packages, especially Faust, from the
[Alpine testing repository](https://wiki.alpinelinux.org/wiki/Repositories#Using_testing_repository).
A formal release candidate will not happen until at least Faust has migrated out
of testing into an Alpine stable release.

## Contributing

I'm actively looking for feature requests and, to a lesser extent, testers.
Setting this up is a bit tricky; see the README in `alpine-setup` for the details.

I'm not at the moment looking for pull requests and will unceremoniously delete them.
If you want to work on something,
[open an issue](https://github.com/AlgoCompSynth/CLAMS/issues/new).

## Why ChucK?

ChucK is a strongly-timed real-time music programming language. In addition to the
classic digital sythesis techniques, like FM, virtual analogue, granular, and sample
playback, ChucK allows creating music algorithmically, one sample at a time.
