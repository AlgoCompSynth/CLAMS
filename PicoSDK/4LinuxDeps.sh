#! /usr/bin/env bash

set -e

echo "Installing base packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -qqy --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  cmake \
  g++ \
  gcc \
  gcc-arm-none-eabi \
  gdb-multiarch \
  libftdi-dev \
  libnewlib-arm-none-eabi \
  libstdc++-arm-none-eabi-newlib \
  libtool \
  libusb-1.0-0-dev \
  minicom \
  pkg-config \
  texinfo

./install-risc-v-compiler.sh

echo "Finished"
