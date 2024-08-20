#! /usr/bin/env bash

set -e

echo "Installing Linux dependencies"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -qqy --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  cmake \
  g++ \
  gcc \
  gdb-multiarch \
  libftdi-dev \
  libtool \
  libusb-1.0-0-dev \
  minicom \
  pkg-config \
  texinfo

./install-risc-v-compiler.sh
./install-arm-compiler.sh

echo "Finished"
