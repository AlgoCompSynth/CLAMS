#! /bin/bash

set -e

source set_pico_envars

echo "Downloading MicroPython release $PICOVISION_VERSION"
curl -sOL $PICOVISION_PYTHON_DOWNLOAD
curl -sOL $PICOVISION_PYTHON_WIDESCREEN_DOWNLOAD

echo "Downloading flash_nuke.uf2"
# https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#resetting-flash-memory
curl -sOL https://datasheets.raspberrypi.com/soft/flash_nuke.uf2

# run separate script for mpremote virtual environment
./install-mpremote.sh

echo "Finished!"
