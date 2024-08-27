#! /usr/bin/env bash

set -e

export LOGFILE="$PWD/5ArduinoPicoGit.log"
echo "LOGFILE: $LOGFILE"
echo "Removing any existing $HOME/Arduino"
rm -fr $HOME/Arduino

# https://arduino-pico.readthedocs.io/en/latest/install.html#installing-via-git
echo "Installing Arduino Pico from GitHub"
mkdir --parents $HOME/Arduino/hardware/pico
/usr/bin/time git clone https://github.com/earlephilhower/arduino-pico.git $HOME/Arduino/hardware/pico/rp2040 \
  >> $LOGFILE 2>&1

pushd $HOME/Arduino/hardware/pico/rp2040
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
find $HOME/Arduino/hardware/pico -name 'examples' | sed 's;^.*Arduino/hardware/;;' | sort -u > arduino-pico-examples.log

echo "Listing connected boards"
arduino-cli board list

echo "Finished"
