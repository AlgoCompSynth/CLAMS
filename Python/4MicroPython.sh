#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Downloading Base CircuitPython"
curl -sOL $CIRCUITPYTHON_DOWNLOAD
echo "Downloading Base MicroPython"
curl -sOL $MICROPYTHON_DOWNLOAD
echo "Downloading SparkFun Pro Micro RP2350 MicroPython"
curl -sOL $SPARKFUN_PRO_MICRO_RP2350_MICROPYTHON_DOWNLOAD

echo "Downloading flash_nuke.uf2"
# https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#resetting-flash-memory
pushd ..
curl -sOL https://datasheets.raspberrypi.com/soft/flash_nuke.uf2
popd

echo "Finished!"
