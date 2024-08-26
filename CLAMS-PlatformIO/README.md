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
