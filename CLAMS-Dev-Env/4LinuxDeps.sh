#! /usr/bin/env bash

set -e

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
  python3-venv \
  texinfo \
  thonny \
  > 4LinuxDeps.log 2>&1

./Installers/install-arm-compiler.sh*
./Installers/install-risc-v-compiler.sh*

echo "Finished"
