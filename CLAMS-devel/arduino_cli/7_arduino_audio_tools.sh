#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/7_arduino_audio_tools.log
rm --force $LOGFILE

echo "Enabling GitHub library installs"
arduino-cli config set library.enable_unsafe_install true
arduino-cli config dump

# installing Audio tools
arduino-cli lib install --git-url $ARDUINO_AUDIO_TOOLS_URL \
  >> $LOGFILE 2>&1

echo "Finished"
