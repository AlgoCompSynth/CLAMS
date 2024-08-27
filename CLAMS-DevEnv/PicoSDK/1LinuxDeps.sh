#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing Linux dependencies"
export DEBIAN_FRONTEND=noninteractive
/usr/bin/time sudo apt-get install -qqy --no-install-recommends \
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
  python3-dev \
  python3-pip \
  python3-tk \
  python3-venv \
  texinfo \
  > 1LinuxDeps.log 2>&1

./install-arm-compiler.sh*
./install-risc-v-compiler.sh*

echo "Finished"