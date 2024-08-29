#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating $zipfile"
pushd $PICO_EXAMPLES_PATH
  zip -9r cleansers.zip `find . -name "flash_nuke.uf2"`
  zip -9r cleansers.zip `find . -name "hello_usb.uf2"`
  mv cleansers.zip $CLAMS_BASE
popd

echo "Finished"
