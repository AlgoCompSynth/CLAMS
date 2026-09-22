# CLAMS
Command Line Algorithmic Music System

CLAMS is a minimalist system for making computer music on Raspberry Pi
single-board computers, compute modules and microcontrollers. CLAMS
features

- Minimalist approach based on Alpine Linux and Lua,
- Command line music tools - ChucK, Faust and FluidSynth,
- Mutiple connection options - USB, USB gadget, wired / wireless
Ethernet and Bluetooth, and
- A complete RP2040 / RP2350 development toolchain.

## Why Alpine?

The main target for CLAMS is the Raspberry Pi Zero 2 W. The available RAM on a
freshly-booted Zero 2 W with a wired connection is almost 100 megabytes more for
64-bit Alpine Linux than for 64-bit Raspberry Pi OS Lite.

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
