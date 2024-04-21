#! /bin/bash

set -e

source set_pico_ice_envars

echo "Downloading PicoVision MicroPython"
curl -sOL $PICO_ICE_DEFAULT_FIRMWARE

echo "Finished!"
