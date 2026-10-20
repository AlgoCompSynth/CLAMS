# CLAMS - Command Line Algorithmic Music System

> "Happy as a clam? You know what? I've never seen a happy clam. In
> fact, most of them were pretty steamed!" -Buck Borasky, Frontier
> Programmer

CLAMS is a minimalist system for making computer music on Raspberry Pi
single-board computers, compute modules and microcontrollers. CLAMS
features

- Minimalist approach based on Alpine Linux and Lua,
- Mutiple connection options - USB, USB gadget, wired / wireless
Ethernet and Bluetooth,
- The Faust music programming language development toolchain, and
- Cross-development environments for common musical computers,
including the RP2040, RP2350, Daisy Seed, PJRC Teensy and Bela.

## Why Alpine?

The initial target for CLAMS is the Raspberry Pi Zero 2 W. The
available RAM on a freshly-booted Zero 2 W with a wired connection
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

## Why Lua?
Lua is a simple and elegant scripting language used in many musical tools, including
Reaper and Renoise. It can also be used as a scripting language for the Linux
WirePlumber session manager. Other Lua-aware tools are also supplied - the NeoVim
editor, the LuajIT high-speed Lua interpreter and Fennel, a dialect of Scheme that
uses the Lua / LuaJIT runtime.

## Why Faust?
Faust is an optimizing compiler for computer music programming. Target environments
include the Daisy Seed, PJRC Teensy, Bela, Rust and WebAssembly. There is a vibrant
Faust community, including AI toolmakers.
