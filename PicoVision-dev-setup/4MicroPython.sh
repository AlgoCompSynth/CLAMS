#! /bin/bash

set -e

source set_pico_envars

echo "Downloading MicroPython release $PICOVISION_VERSION"
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-v$PICOVISION_VERSION-micropython.uf2"
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-widescreen-v$PICOVISION_VERSION-micropython.uf2"

echo "Downloading flash_nuke.uf2"
# https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#resetting-flash-memory
curl -sOL https://datasheets.raspberrypi.com/soft/flash_nuke.uf2

echo "Finished!"
