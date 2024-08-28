#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

export LOGFILE="$PWD/2ArduinoPicoGit.log"
echo "LOGFILE: $LOGFILE"

# https://arduino-pico.readthedocs.io/en/latest/install.html#installing-via-git
echo "Installing Arduino Pico from GitHub"
mkdir --parents $ARDUINO_PICO_PATH; rm -fr $ARDUINO_PICO_PATH
/usr/bin/time git clone $ARDUINO_PICO_URL $ARDUINO_PICO_PATH \
  >> $LOGFILE 2>&1

pushd $ARDUINO_PICO_PATH
  echo "Updating main submodules"
  /usr/bin/time git submodule update --init \
    >> $LOGFILE 2>&1
  echo "Updating Pico SDK submodules"
  cd pico-sdk
  /usr/bin/time git submodule update --init \
    >> $LOGFILE 2>&1
  echo "Installing tools"
  cd ../tools
  /usr/bin/time python3 ./get.py \
    >> $LOGFILE 2>&1
popd

echo "Listing Arduino Pico boards to arduino-pico-boards.log"
arduino-cli board search pico:rp2040 > arduino-pico-boards.log

echo "Listing Arduino Pico examples to arduino-pico-examples.log"
find $HOME/Arduino/hardware/pico -name 'examples' \
  | sed 's;^.*Arduino/hardware/;;' \
  | sort -u \
  > arduino-pico-examples.log

echo "Listing connected boards"
arduino-cli board list

echo "Finished"
