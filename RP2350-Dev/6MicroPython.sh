#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating fresh $PICO_PYTHON"
rm -fr $PICO_PYTHON
mkdir --parents $PICO_PYTHON
echo ""
pushd $PICO_PYTHON

  echo $PIMORONI_PICO_PLUS2_UF2
  curl -sOL $PIMORONI_PICO_PLUS2_URL
  echo $SPARKFUN_PRO_MICRO_RP2350_UF2
  curl -sOL $SPARKFUN_PRO_MICRO_RP2350_URL

popd

echo ""
echo ""
echo "Note: 'flash_nuke.uf2' files are now board-specific."
echo "You will find them in the appropriate"
echo ""
echo "    $PICO_EXAMPLES_PATH/build_*"
echo ""
echo "directories."
echo ""
echo "Finished"
