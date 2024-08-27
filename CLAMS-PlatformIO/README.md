# CLAMS-PlatformIO

The eventual goal here is to build a distrobox for devloping portable
CLAMS Forth using PlatformIO and Arduino command line tools. The short
term goal is to act as a test rig for the RP2350 port of
[Arduino-Pico](https://github.com/earlephilhower/arduino-pico)
on a Raspberry Pi Pico W and the following RP2350 boards:

- [SparkFun Pro Micro - RP2350](https://www.sparkfun.com/products/24870),
- [Pimoroni Pico Plus 2](https://shop.pimoroni.com/products/pimoroni-pico-plus-2), and
- [Challenger+ RP2350 WiFi6/BLE5](https://ilabs.se/challenger-rp2350-wifi-ble/).

## Usage

1. Install
[Distrobox](https://github.com/89luca89/distrobox)
and its dependencies. I do most of my development using
[Universal Blue Bluefin DX](https://docs.projectbluefin.io/bluefin-dx),
which has this built in. Distrobox is available on most recent Linux
distributions including Ubuntu 24.04 LTS in Windows Subsystem for
Linux. I will be testing on that environment at some point.

2. On the Distrobox host, run

    ```
    ./1RecreateDistrobox.sh
    ```

    This will create the container `CLAMS-PlatformIO`.

3. Do what it says: `distrobox enter CLAMS-PlatformIO`. You will be in the container
with a default `bash` prompt.

4. Edit `vimrc` for your terminal environment. I use a dark background, so that's the
default. Then run

    ```
    ./2CommandLineSetup.sh
    zsh
    ```

    This will set up the `zsh` theme `powerlevel10k` and set you up with an
    informative prompt. If you want to change the prompt, run `p10k configure`.

    If you prefer `bash`, type `bash` instead of `zsh`. This will give you a
    prompt patterned after the one used in Ubuntu 22.04 LTS.

5. Run








    ./
3Upgrades.sh
4LinuxDeps.sh
bash_aliases
bashrc
distrobox.ini
edit-me-then-run-4-git-config.sh
Installers
p10k.zsh
README.md
vimrc
zshrc
