#! /bin/bash

set -e

source set_pico_envars

echo ""
echo "Installing Linux build tools"
sudo dnf -y install \
  arm-none-eabi-binutils-cs \
  arm-none-eabi-gcc-cs \
  arm-none-eabi-gcc-cs-c++ \
  arm-none-eabi-newlib \
  cmake \
  ninja-build

echo ""
echo "Finished"
