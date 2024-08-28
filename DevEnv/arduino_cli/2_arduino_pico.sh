#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

export LOGFILE="$PWD/2_arduino_pico.log"
echo "LOGFILE: $LOGFILE"

# https://arduino-pico.readthedocs.io/en/latest/install.html#installing-via-arduino-cli
echo "Installing Arduino Pico from package release"
arduino-cli config add board_manager.additional_urls $ARDUINO_PICO_PACKAGE_URL
arduino-cli core update-index
arduino-cli core install rp2040:rp2040

echo "Listing Arduino Pico boards to arduino_pico_boards.log"
arduino-cli board listall | grep "rp2040:rp2040" > arduino_pico_boards.log

echo "Listing connected boards"
arduino-cli board list

echo "Listing Arduino Pico examples to arduino_pico_examples.log"
find $HOME/.arduino15/packages/rp2040/hardware/rp2040 -name 'examples' \
  | sed 's;^.*/hardware/;;' \
  | sort -u \
  > arduino_pico_examples.log

echo "Finished"
