#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/3_arduino_pico_git.log
rm -f $LOGFILE

# https://github.com/earlephilhower/arduino-pico?tab=readme-ov-file#installing-via-git
echo "Cloning repository"
mkdir --parents $ARDUINO_PICO_PATH; rm -fr $ARDUINO_PICO_PATH
/usr/bin/time git clone \
  $ARDUINO_PICO_URL \
  $ARDUINO_PICO_PATH \
  >> $LOGFILE 2>&1

pushd $ARDUINO_PICO_PATH
  echo "Updating submodules"
  /usr/bin/time git submodule update --init \
  >> $LOGFILE 2>&1

  echo "Updating Pico SDK submodules"
  cd pico-sdk
  /usr/bin/time git submodule update --init \
  >> $LOGFILE 2>&1

  echo "Downloading tools"
  cd ../tools
  /usr/bin/time python3 ./get.py \
  >> $LOGFILE 2>&1
popd

echo "Listing Arduino Pico boards to arduino_pico_git_boards.log"
arduino-cli board listall | grep "pico:rp2040" > arduino_pico_git_boards.log

echo "Listing Arduino Pico examples to arduino_pico_git_examples.log"
find $ARDUINO_PICO_PATH/ -name 'examples' \
  | sort -u \
  > arduino_pico_git_examples.log

echo "Finished"
