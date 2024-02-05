#! /bin/bash

set -e

source set_pico_envars

echo ""
echo "Installing Linux build tools"
yay --sync --refresh --needed --noconfirm \
  arm-none-eabi-binutils \
  arm-none-eabi-gcc \
  arm-none-eabi-gdb \
  arm-none-eabi-newlib \
  cmake \
  ninja

echo ""
echo "Finished"
