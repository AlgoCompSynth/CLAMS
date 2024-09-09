#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/2_mbed_rp2040.log
rm -f $LOGFILE

echo "Installing Arduino MBED RP2040 core"
arduino-cli core install arduino:mbed_rp2040 \
  >> $LOGFILE 2>&1

echo "Listing MBED RP2040 boards to mbed_rp2040_boards.log"
arduino-cli board listall | grep "arduino:mbed_rp2040" > mbed_rp2040_boards.log

echo "Listing MBED RP2040 examples to mbed_rp2040_examples.log"
find $HOME/.arduino15/packages/arduino/hardware/mbed_rp2040 -name 'examples' \
  | sort -u \
  > mbed_rp2040_examples.log

echo "Finished"
