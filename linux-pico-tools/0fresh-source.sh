#! /bin/bash

set -e

source set_pico_envars

echo ""
echo "Removing existing Pico tools!"
rm -fr $PICO_PATH; mkdir --parents $PICO_PATH

echo ""
echo "Installing Linux build tools"
sudo apt-get update
sudo apt-get -qqy upgrade
sudo apt-get -qqy install \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  cmake \
  gcc-arm-none-eabi \
  git \
  libftdi-dev \
  libnewlib-arm-none-eabi \
  libstdc++-arm-none-eabi-newlib \
  libtool \
  libusb-1.0-0-dev \
  ninja-build \
  software-properties-common \
  texinfo \
  time \
  tree

pushd $PICO_PATH

echo ""
echo "Downloading Pico SDK"
sleep 5
git clone https://github.com/raspberrypi/pico-sdk.git --recurse-submodules --quiet

echo ""
echo "Downloading Pico examples"
sleep 5
git clone https://github.com/raspberrypi/pico-examples.git --recurse-submodules --quiet

echo ""
echo "Downloading Pico extras"
sleep 5
git clone git@github.com:AlgoCompSynth/pico-extras.git --recurse-submodules --quiet

echo ""
echo "Downloading Pico playground"
sleep 5
git clone git@github.com:AlgoCompSynth/pico-playground.git --recurse-submodules --quiet

echo ""
echo "Downloading Pimoroni examples"
sleep 5
git clone -b main git@github.com:AlgoCompSynth/pimoroni-pico.git --recurse-submodules --quiet

echo ""
echo "Downloading OpenOCD"
sleep 5
git clone https://github.com/raspberrypi/openocd.git --branch rp2040 --recursive --depth=1 --quiet

echo ""
echo "Downloading picotool"
sleep 5
git clone https://github.com/raspberrypi/picotool.git --branch master --quiet

popd

echo ""
echo "Finished"
