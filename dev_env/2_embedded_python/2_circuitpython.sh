#! /bin/bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating fresh $PICO_CIRCUITPYTHON_PATH"
rm -fr $PICO_CIRCUITPYTHON_PATH
mkdir --parents $PICO_CIRCUITPYTHON_PATH
echo ""
pushd $PICO_CIRCUITPYTHON_PATH

  echo "Downloading $PICO_CIRCUITPYTHON_UF2"
  curl -sOL $PICO_CIRCUITPYTHON_URL
  echo "Downloading $PICO_W_CIRCUITPYTHON_UF2"
  curl -sOL $PICO_W_CIRCUITPYTHON_URL
  echo "Downloading $PICO2_CIRCUITPYTHON_UF2"
  curl -sOL $PICO2_CIRCUITPYTHON_URL

popd

echo ""
echo ""
echo "Note: 'flash_nuke.uf2' files are board-specific."
echo "You will find them in the appropriate"
echo ""
echo "    $PICO_EXAMPLES_PATH/build_*"
echo ""
echo "directories."
echo ""
echo "Finished"
