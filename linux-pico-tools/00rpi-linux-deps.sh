#! /bin/bash

set -e

source set_pico_envars

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

echo ""
echo "Finished"
