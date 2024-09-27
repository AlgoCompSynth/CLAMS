#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/2_arduino_pico.log

# https://arduino-pico.readthedocs.io/en/latest/install.html#installing-via-arduino-cli
echo "Installing Arduino Pico from package release"
arduino-cli config add board_manager.additional_urls $ARDUINO_PICO_PACKAGE_URL \
  >> $LOGFILE 2>&1
arduino-cli core update-index \
  >> $LOGFILE 2>&1
arduino-cli core install rp2040:rp2040 \
  >> $LOGFILE 2>&1
arduino-cli core list

echo "Listing Arduino Pico boards to board-listall.txt"
arduino-cli board listall > board-listall.txt

echo "Listing Arduino Pico examples to arduino_pico_examples.log"
find $HOME/.arduino15/packages/rp2040/hardware/rp2040 -name 'examples' \
  | sort -u \
  > arduino_pico_examples.log

echo "Finished"
