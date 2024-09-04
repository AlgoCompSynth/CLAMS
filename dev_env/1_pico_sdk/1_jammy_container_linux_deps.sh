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
  gcc-multilib \
  gdb-multiarch \
  libftdi-dev \
  libtool \
  libusb-1.0-0-dev \
  make \
  minicom \
  pkg-config \
  python3-dev \
  python3-pip \
  python3-tk \
  python3-venv \
  screen \
  texinfo \
  usbutils \
  > 1_linux_deps.log 2>&1

./install_arm_compiler.sh*
./install_risc_v_compiler.sh*

echo "Finished"
