#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/5_esp32.log
rm --force $LOGFILE

echo "Installing Arduino ESP32 from package release"
arduino-cli core update-index \
  >> $LOGFILE 2>&1
arduino-cli core install esp32:esp32 \
  >> $LOGFILE 2>&1

echo "Finished"