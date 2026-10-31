# CLAMS - Command Line Algorithmic Music System

> "Happy as a clam? You know what? I've never seen a happy clam. In
> fact, most of them were pretty steamed!" - Buck Borasky, Frontier
> Programmer

## What is this?

The goal of CLAMS is to get the most possible computer music out of the
smallest possible computers. The current version is aimed at Raspberry
Pi single-board computers, compute modules and microcontrollers. CLAMS
features

- A minimalist command line approach based on [Alpine
Linux](https://wiki.alpinelinux.org/wiki/Main_Page),
- Multiple connection options - USB, HDMI, wired / wireless Ethernet and
Bluetooth,
- Audio plumbing:
    - [PipeWire](https://docs.pipewire.org/) with ALSA, JACK, and
    PulseAudio compatibility support,
    - [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/),
    - [rtkit](https://gitlab.freedesktop.org/pipewire/rtkit),
- The
[FluidSynth](https://www.fluidsynth.org/) SoundFont-based synthesizer,
- The
[Faust](https://faust.grame.fr/) functional music programming language
and development toolchain, and
- The [GCC 15](https://gcc.gnu.org/onlinedocs/15.3.0/)
and [LLVM 20](https://releases.llvm.org/20.1.0/docs/index.html)
toolchains.

## Intended use case

CLAMS is primarily intended for use on a
[Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/)
or larger as a software platform, either stand-alone with a monitor,
heyboard and mouse, or headless on a network with a wired or wireless
connection. I'm not a hardware maker in any sense. If you are, and
want to build a musical device using this software with a Pi board
inside, I'd love to hear about it, but I cannot offer any practical
support on hardware issues. The closest CLAMS will ever get to the Pi
hardware is 64-bit Arm assembly language.

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

Faust is an optimizing compiler for computer music programming. Target
environments include the Daisy Seed, PJRC Teensy, Bela, Rust and
WebAssembly. There is a vibrant Faust community, including AI
toolmakers. Faust comes with many examples and has an extensive online
manual. See also [Audio Signal Processing in
FAUST](https://ccrma.stanford.edu/~jos/aspf/) and [Faust and AI
Programming](https://ccrma.stanford.edu/~jos/pdf/IFC26-handout.pdf`).

## The command line

The CLAMS command line uses the standard Linux `bash` shell instead of
the minimalist `ash` shell Alpine Linux provides as a default. The
[Starship](https://starship.rs/) cross-shell prompt generator is
included. For best results you will need a [nerd
font](https://www.nerdfonts.com/) ***in your terminal emulator***. The
Cascaydia Cove nerd font is installed with CLAMS if you're using CLAMS
on a stand-alone console, and you can copy it to your host for a 
headless system.

Also installed:
- [Neovim](https://neovim.io/doc/),
- [tmux](https://tmux.app/doc/),
- [LuaJIT](https://luajit.org/),
- [Fennel](https://fennel-lang.org/), and
- [Lynx](https://lynx.browser.org/).

## Project status / road map

This is the first alpha release, `v0.7.5`. It has most of what I want
and can be installed on a Raspberry Pi Zero 2 W or any larger Raspberry
Pi. It is currently based on Alpine Edge and uses some packages, most
notably Faust, from the [Alpine testing
repository](https://wiki.alpinelinux.org/wiki/Repositories#Using_testing_repository).
A formal release candidate will not happen until at least Faust has
migrated out of testing into an Alpine stable release.

For the road map, see <https://github.com/AlgoCompSynth/CLAMS/issues>
and <https://github.com/orgs/AlgoCompSynth/projects/26>. My near-term
plan is mostly testing the Faust examples to see what will and what
won't run in the limited-capacity Zero 2 W. There are a couple of
upstream issues blocking some planned features I need to document as
well.

## Contributing

I'm actively looking for feature requests and, to a lesser extent,
testers. Setting this up is a bit tricky; see
[./getting-started](./getting-started) for the details. For feature
requests, questions about usage and bug reports, open an issue at
<https://github.com/AlgoCompSynth/CLAMS/issues/new>.

There are numerous music software packages for Linux already. The ones
I've included are the ones best suited to a command line environment.
I'd love to include Pure Data, SuperCollider and trackers, but they
depend on graphical user interfaces that might be problematic on the
Raspberry Pi Zero 2 W with only 512 MB of RAM.

## Capacity notes

CPU and RAM capacity are unlikely to be an issue for MIDI or audio. The
Zero 2 W has four 1 GHz 64-bit Arm cores that include the Neon SIMD
instructions. And the available RAM is more than enough for most
conceivable audio processing. Many commercial musical instruments use
microcontrollers with much less CPU and RAM capacity than the Zero 2 W.

Where the rough edges are is RAM usage during compilation. Faust is a
compiler, and most of its outputs need to be compiled with the target
device's compiler. Optimizing compilers use a fair amount of RAM. As a
result, on the Zero 2 W, using multiple cores in compiling is often
problematic, and some code won't even compile with a single `make`
job.

So there are going to be some interesting musical artifacts that can't
be produced for the Zero 2 W ***on*** the Zero 2 W. If you're interested
in cross-development of musical software / firmware with CLAMS, you
might well need a larger Raspberry Pi. I have an 8 GB Pi 4 and a 16 GB
Pi 5 I can use to determine the requirements of large examples that
break in the Zero 2 W. Nobody will stop you from developing for the
Zero 2 W on your Pi 500+.

There is also a GPU on the Pi Zero 2 W and by default Alpine reserves
64 MB of RAM for it. There is quite a bit of software for it but I do
not have using it on the road map yet.
