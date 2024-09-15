#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating cleansers.zip"
pushd $PICO_EXAMPLES_PATH
  for suffix in uf2 elf dis
  do
    zip -9r cleansers.zip `find . -name "blink.$suffix"`
    zip -9r cleansers.zip `find . -name "flash_nuke.$suffix"`
    zip -9r cleansers.zip `find . -name "hello_serial.$suffix"`
    zip -9r cleansers.zip `find . -name "hello_usb.$suffix"`
  done
  mv cleansers.zip $CLAMS_BASE

  pushd $CLAMS_BASE
    echo "Unpacking cleansers.zip"
    rm -fr build_*
    unzip cleansers.zip
  popd

popd

echo "Finished"
