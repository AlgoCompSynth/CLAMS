#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating fresh $PICO_ARDUINO_PATH"
rm -fr $PICO_ARDUINO_PATH
mkdir --parents $PICO_ARDUINO_PATH

pushd $PICO_ARDUINO_PATH
  echo ""
  echo "Downloading Arduino IDE zipfile"
  rm -f $ARDUINO_IDE_ZIPFILE
  /usr/bin/time curl -sOL $ARDUINO_IDE_URL

  echo "Installing"
  rm -fr $ARDUINO_IDE_PATH
  /usr/bin/time unzip \
    $ARDUINO_IDE_ZIPFILE \
    > extract.log 2>&1
popd

echo "Creating logfile directory $ARDUINO_LOGFILES_PATH"
rm -fr $ARDUINO_LOGFILES_PATH
mkdir --parents $ARDUINO_LOGFILES_PATH

echo "Install complete"
