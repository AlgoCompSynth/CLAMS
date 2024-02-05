#! /bin/bash

set -e

source set_pico_envars

echo ""
echo "Removing existing Pico tools!"
rm -fr $PICO_PATH; mkdir --parents $PICO_PATH

pushd $PICO_PATH

echo ""
echo "Downloading Pico SDK"
sleep 5
git clone https://github.com/raspberrypi/pico-sdk.git \
  --branch "1.5.1" --recurse-submodules --quiet

echo ""
echo "Downloading Pico examples"
sleep 5
git clone https://github.com/raspberrypi/pico-examples.git \
  --branch "sdk-1.5.1" --recurse-submodules --quiet

echo ""
echo "Downloading Pico extras"
sleep 5
git clone https://github.com/raspberrypi/pico-extras.git \
  --branch "sdk-1.5.1" --recurse-submodules --quiet

echo ""
echo "Downloading Pico playground"
sleep 5
git clone https://github.com/raspberrypi/pico-playground.git \
  --branch "sdk-1.5.1" --recurse-submodules --quiet

echo ""
echo "Downloading Pimoroni examples"
sleep 5
git clone https://github.com/pimoroni/pimoroni-pico.git \
  --branch "v1.21.0" --recurse-submodules --quiet

echo ""
echo "Downloading OpenOCD"
sleep 5
git clone https://github.com/raspberrypi/openocd.git \
  --branch "rp2040-v0.12.0" --recursive --depth=1 --quiet

echo ""
echo "Downloading picotool"
sleep 5
git clone https://github.com/raspberrypi/picotool.git \
  --branch "1.1.2" --quiet

popd

echo ""
echo "Finished"
