#! /usr/bin/env bash

set -e

echo "Installing base packages"
sudo apt-get install -y \
  apt-file \
  build-essential \
  cmake \
  file \
  gcc-arm-none-eabi \
  gdb-multiarch \
  git-lfs \
  libnewlib-arm-none-eabi \
  libpam-systemd \
  libstdc++-arm-none-eabi-newlib \
  libusb-1.0-0-dev \
  lsb-release \
  lynx \
  man-db \
  minicom \
  pkg-config \
  plocate \
  speedtest-cli \
  systemd \
  time \
  tree \
  vim-nox \
  zsh

echo "Finished"
