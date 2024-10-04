#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/3_teensyduino.log

# https://www.pjrc.com/teensy/td_download.html
echo "Installing Teensyduino from package release"
arduino-cli config add board_manager.additional_urls $TEENSYDUINO_PACKAGE_URL \
  >> $LOGFILE 2>&1
arduino-cli core update-index \
  >> $LOGFILE 2>&1
arduino-cli core install teensy:avr \
  >> $LOGFILE 2>&1

echo "Finished"
