#! /usr/bin/env bash

set -e

echo "Installing base packages"
sudo apt-get install -y \
  build-essential \
  cmake \
  gcc-arm-none-eabi \
  gdb-multiarch \
  libnewlib-arm-none-eabi \
  libstdc++-arm-none-eabi-newlib \
  libusb-1.0-0-dev \
  minicom \
  pkg-config

./install-risc-v-compiler.sh

echo "Finished"
