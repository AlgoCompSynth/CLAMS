#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo "Downloading PicoVision MicroPython"
curl -sOL $PICOVISION_PYTHON_DOWNLOAD
curl -sOL $PICOVISION_PYTHON_WIDESCREEN_DOWNLOAD
echo "Downloading CircuitPython"
curl -sOL $CIRCUITPYTHON_DOWNLOAD
echo "Downloading Base MicroPython"
curl -sOL $MICROPYTHON_DOWNLOAD

echo "Downloading flash_nuke.uf2"
# https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#resetting-flash-memory
curl -sOL https://datasheets.raspberrypi.com/soft/flash_nuke.uf2

echo "Finished!"
