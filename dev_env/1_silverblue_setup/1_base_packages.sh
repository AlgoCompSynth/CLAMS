#! /usr/bin/env bash

set -e

echo "Upgrading"
/usr/bin/time rpm-ostree upgrade \
  > 1_base_packages.log 2>&1
echo "Installing Pico SDK dependecies"
/usr/bin/time rpm-ostree install --idempotent --allow-inactive \
  autoconf \
  automake \
  capstone-devel \
  cmake \
  file \
  git-lfs \
  glibc-devel.i686 \
  hidapi-devel \
  libftdi-devel \
  libtool \
  libusb1-devel \
  lsb-release \
  lynx \
  make \
  minicom \
  pkgconf \
  plocate \
  python3-pip \
  screen \
  speedtest-cli \
  texinfo \
  tmux \
  time \
  tree \
  usbutils \
  vim-enhanced \
  zsh \
  >> 1_base_packages.log 2>&1

echo "Copying 'set_pico_envars' to $HOME"
cp ../set_pico_envars $HOME/

rpm-ostree status

echo "Finished"
