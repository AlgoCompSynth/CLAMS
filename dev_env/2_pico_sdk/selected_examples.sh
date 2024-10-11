#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating selected_examples.zip"
pushd $PICO_EXAMPLES_PATH
  for suffix in uf2 elf dis
  do
    zip -9r selected_examples.zip `find . -name "blink.$suffix"`
    zip -9r selected_examples.zip `find . -name "flash_nuke.$suffix"`
    zip -9r selected_examples.zip `find . -name "hello_serial.$suffix"`
    zip -9r selected_examples.zip `find . -name "hello_usb.$suffix"`
    zip -9r selected_examples.zip `find . -name "tinyusb*.$suffix"`
  done
  mv selected_examples.zip $CLAMS_BASE

  pushd $CLAMS_BASE
    echo "Unpacking selected_examples.zip"
    rm -fr build_*
    unzip selected_examples.zip
  popd

popd

echo "Finished"
