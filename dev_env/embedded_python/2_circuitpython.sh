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

  export BASE_URL="https://downloads.circuitpython.org/bin"
  export VERSION="9.2.0-beta.0"
  for uf2 in \
    "adafruit_feather_rp2350/en_US/adafruit-circuitpython-adafruit_feather_rp2350-en_US-$VERSION.uf2" \
    "sparkfun_pro_micro_rp2350/en_US/adafruit-circuitpython-sparkfun_pro_micro_rp2350-en_US-$VERSION.uf2" \
    "raspberry_pi_pico/en_US/adafruit-circuitpython-raspberry_pi_pico-en_US-$VERSION.uf2" \
    "raspberry_pi_pico_w/en_US/adafruit-circuitpython-raspberry_pi_pico_w-en_US-$VERSION.uf2" \
    "arduino_nano_rp2040_connect/en_US/adafruit-circuitpython-arduino_nano_rp2040_connect-en_US-$VERSION.uf2" \
    "pimoroni_pico_dv_base/en_US/adafruit-circuitpython-pimoroni_pico_dv_base-en_US-$VERSION.uf2" \
    "pimoroni_pico_dv_base_w/en_US/adafruit-circuitpython-pimoroni_pico_dv_base_w-en_US-$VERSION.uf2" \
    "pimoroni_keybow2040/en_US/adafruit-circuitpython-pimoroni_keybow2040-en_US-$VERSION.uf2"
  do
    echo "Downloading $BASE_URL/$uf2"
    curl -sOL $BASE_URL/$uf2
  done

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
