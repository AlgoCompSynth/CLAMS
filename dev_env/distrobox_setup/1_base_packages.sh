#! /usr/bin/env bash

set -e

echo "Installing base packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -qqy \
  apt-file \
  autoconf \
  automake \
  build-essential \
  cmake \
  file \
  g++ \
  gcc \
  gcc-multilib \
  gdb-multiarch \
  git-lfs \
  libftdi-dev \
  libpam-systemd \
  libtool \
  libusb-1.0-0-dev \
  lsb-release \
  lynx \
  make \
  man-db \
  minicom \
  pkg-config \
  plocate \
  python3-dev \
  python3-pip \
  python3-tk \
  python3-venv \
  screen \
  speedtest-cli \
  systemd \
  texinfo \
  time \
  tmux \
  tree \
  usbutils \
  vim-nox \
  zsh \
  > 1_base_packages.log 2>&1

echo "Copying 'set_pico_envars' to $HOME"
cp ../set_pico_envars $HOME/

echo "Finished"
