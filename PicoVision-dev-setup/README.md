# Setting up the Development Environment

## Usage
1. Get a PicoVision and a display. As far as I know, most HDMI displays
designed to work with a Raspberry Pi will work with the PicoVision.

2. Edit the environment variables. The file `set_pico_envars` defines
all the environment variables needed for the rest of the scripts.
The scripts all do `source set_pico_envars` to read them.

3. Run the numbered scripts in order:
- 0mambaforge.sh
- 1pico-toolchain.sh
- 2pimoroni-repos.sh
- 3build-examples.log
- 3build-examples.sh
- 4MicroPython.sh

4. Documentation: for C/C++ development, refer to
<https://www.raspberrypi.com/documentation/microcontrollers/c_sdk.html>. The
setup steps have already been done, so you can start at
<https://www.raspberrypi.com/documentation/microcontrollers/c_sdk.html#raspberry-pi-pico-cc-sdk>.

    For MicroPython development, start with
    <https://www.raspberrypi.com/documentation/microcontrollers/micropython.html>.
    Then read the Pimoroni PicoVision documentation at
    <https://github.com/pimoroni/picovision>. I strongly recommend using
    Mamba virtual environments for all Python development. To get started,
    type `mamba activate PicoVision`. From there, you can use the
    `mpremote` command line utility to manage your PicoVision board.

## Script details

### Mambaforge
My Python development process heavily depends on the Mamba package and environment
manager (<ihttps://mamba.readthedocs.io/en/latest/index.html>). The script
`0mambaforge.sh` checks to see if Mambaforge is installed. If it isn't,
`0mambaforge.sh` installs it. Once Mambaforge is installed, the script
creates a virtual environment named `PicoVision` which contains `Python`,
`pip` and the MicroPython command line utility `mpremote`. See
<https://docs.micropython.org/en/latest/reference/mpremote.html> for
`mpremote` documentation.

### The Pico toolchain
`1pico-toolchain.sh` installs all the C/C++ SDK tools.

### Pimroni repositories
`2pimoroni-repos.sh` installs the Pimoroni repositories required for CLAMS
development.

### Building the examples
`3build-examples.sh` builds all the Raspberry Pi and Pimoroni examples. This
takes a bit of time, but it's a necessary test of the toolchain, and as a
bonus supplies numerous firmware examples to experiment with!

### MicroPython tools
`4MicroPython.sh` downloads the firmware files for PicoVision MicroPython.
If you want to remove MicroPython and load other firmware, put the PicoVision
in bootloader mode and install `flash_nuke.uf2`. It will erase the flash and
put the PicoVision CPU back in bootloader mode.

### Listing the firmware files in the examples
Once you've built all the examples, `list-uf2-files.sh` will list all of
the firmware files it built!
