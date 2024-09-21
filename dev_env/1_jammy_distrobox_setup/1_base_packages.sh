#! /usr/bin/env bash

set -e

echo "Installing base packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update \
  > 1_base_packages.log 2>&1
sudo apt-get install --assume-yes \
  apt-file \
  autoconf \
  automake \
  build-essential \
  ccache \
  cmake \
  dfu-util \
  device-tree-compiler \
  file \
  g++ \
  gcc \
  g++-multilib \
  gcc-multilib \
  gdb-multiarch \
  git-lfs \
  gperf \
  libftdi-dev \
  libmagic1 \
  libpam-systemd \
  libsdl2-dev \
  libtool \
  libusb-1.0-0-dev \
  lsb-release \
  lynx \
  make \
  man-db \
  minicom \
  ninja-build \
  pkg-config \
  plocate \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-tk \
  python3-venv \
  python3-wheel \
  screen \
  speedtest-cli \
  systemd \
  texinfo \
  time \
  tmux \
  tree \
  usbutils \
  vim \
  xz-utils \
  wget \
  zsh \
  >> 1_base_packages.log 2>&1

echo "Copying 'set_pico_envars' to $HOME"
cp ../set_pico_envars $HOME/

echo "Finished"
