#! /bin/bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating fresh $PICO_PYTHON_PATH"
rm -fr $PICO_PYTHON_PATH
mkdir --parents $PICO_PYTHON_PATH
echo ""
pushd $PICO_PYTHON_PATH

  echo "Creating virtual environment $CLAMS_VENV"
  python3 -m venv $CLAMS_VENV
  echo "Installing mpremote and thonny"
  source $CLAMS_VENV/bin/activate
  pip3 install --upgrade mpremote thonny
  echo "Deactivating virtual environment $CLAMS_VENV"
  deactivate

  echo "Downloading $PIMORONI_PICO_PLUS2_UF2"
  curl -sOL $PIMORONI_PICO_PLUS2_URL
  echo "Downloading $SPARKFUN_PRO_MICRO_RP2350_UF2"
  curl -sOL $SPARKFUN_PRO_MICRO_RP2350_URL
  echo "Downloading $PICOVISION_MICROPYTHON_UF2"
  curl -sOL $PICOVISION_MICROPYTHON_URL
  echo "Downloading $PICOVISION_WIDESCREEN_MICROPYTHON_UF2"
  curl -sOL $PICOVISION_WIDESCREEN_MICROPYTHON_URL
  echo "Downloading $PICO_W_CIRCUITPYTHON_UF2"
  curl -sOL $PICO_W_CIRCUITPYTHON_URL
  echo "Downloading $PICO_W_MICROPYTHON_UF2"
  curl -sOL $PICO_W_MICROPYTHON_URL
  cp $PICO_W_MICROPYTHON_UF2 MICROPYTHON_$PICO_W_MICROPYTHON_UF2

  echo "Downloading $PICOVISION_EXAMPLES_ZIPFILE"
  curl -sOL $PICOVISION_EXAMPLES_URL
  rm -fr $PICOVISION_EXAMPLES_PATH; mkdir --parents $PICOVISION_EXAMPLES_PATH

  pushd $PICOVISION_EXAMPLES_PATH
    unzip $PICO_PYTHON_PATH/$PICOVISION_EXAMPLES_ZIPFILE
  popd

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
