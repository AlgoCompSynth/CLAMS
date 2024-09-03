#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating cleansers.zip"
pushd $PICO_EXAMPLES_PATH
  zip -9r cleansers.zip `find . -name "blink.uf2"`
  zip -9r cleansers.zip `find . -name "hello_serial.uf2"`
  zip -9r cleansers.zip `find . -name "hello_usb.uf2"`
  mv cleansers.zip $CLAMS_BASE
popd

echo "Finished"
