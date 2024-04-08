# Setting up the Development Environment

## Usage
1. Hardware
    - Host: I use a Raspberry Pi CM4 with 4 GB of RAM. I am running
PiOS "legacy" 64-bit - the one based on Debian "bullseye". There may be
other configurations that will work but I don't have time to test
them.
    - PicoVision display: As far as I know, most HDMI displays
designed to work with a Raspberry Pi will work with the PicoVision.

2. Edit the environment variables. The file `set_pico_envars` defines
all the environment variables needed for the rest of the scripts.
The scripts all do `source set_pico_envars` to read them.

3. Run the numbered scripts in order:
    - 1pico-toolchain.sh -- you will need to reboot after running this one.
    - 2pimoroni-repos.sh
    - 3build-examples.sh
    - 4MicroPython.sh

4. Documentation: for C/C++ development, refer to
<https://www.raspberrypi.com/documentation/microcontrollers/c_sdk.html>. The
setup steps have already been done, so you can start at
<https://www.raspberrypi.com/documentation/microcontrollers/c_sdk.html#raspberry-pi-pico-cc-sdk>.

    For MicroPython development, start with
    <https://www.raspberrypi.com/documentation/microcontrollers/micropython.html>.
    Then read the Pimoroni PicoVision documentation at
    <https://github.com/pimoroni/picovision>.

## Script details

### The Pico toolchain
`1pico-toolchain.sh` installs all the C/C++ SDK tools. You will need to reboot
after running this.

### Pimroni repositories
`2pimoroni-repos.sh` installs the Pimoroni repositories required for CLAMS
development.

### Building the examples
`3build-examples.sh` builds all the Raspberry Pi and Pimoroni examples. This
takes a bit of time, but it's a necessary test of the toolchain, and as a
bonus supplies numerous firmware examples to experiment with! On my Raspberry
Pi 4GB CM4 it takes about 35 minutes.

### MicroPython tools
`4MicroPython.sh` downloads the firmware files for PicoVision MicroPython.
It then installs `python3-venv` if needed, then creates a virtual environment
`mpremote` in this directory, and then installs `mpremote` there.

To use `mpremote`:

    source ./mpremote/bin/activate
    mpremote --help

If you want to remove MicroPython and load other firmware, put the PicoVision
in bootloader mode using `mpremote bootloader` and install `flash_nuke.uf2`.
That will erase the flash and put the PicoVision CPU back in bootloader mode.
Then you can load another `.uf2` file into the PicoVision.

### Listing the firmware files in the examples
Once you've built all the examples, `list-uf2-files.sh` will list all of
the firmware files it built!

## Update 2024-02-18: testing on other hosts
I've done a bit of testing on other hosts. The C/C++ portions should run in
any recent Ubuntu or Debian system, including rootless containers. However,
the MicroPython host interface is another story.

The issue is that the `mpremote` tool uses a serial USB device, usually 
`/dev/ttyACM0`, and frequently runs into permission problems. When I
first ran this back in October of 2023 I had no issues with the Pi CM4,
but now that is also giving me grief. I'm not doing much with
MicroPython but the Picovision is supposed to be a MicroPython and C/C++
device and that's not currently the case for some hosts.

If you run into this, the workaround is to do `sudo chmod a+rw /dev/ttyXXXX`,
where `XXXX` is the device you see using `mpremote connect list`. Even with
that, I've seen the permissions get reset on some Linux hosts. 
