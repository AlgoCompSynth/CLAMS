#! /bin/bash

set -e

echo "Synchronizing distribution"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get autoremove -qqy

echo ""
echo "Installing command line tools"
sudo apt-get install -qqy --no-install-recommends \
  apt-file \
  build-essential \
  cmake \
  git \
  git-lfs \
  htop \
  info \
  libusb-dev \
  locate \
  man-db \
  minicom \
  ninja-build \
  pkg-config \
  python3-venv \
  screen \
  software-properties-common \
  time \
  tmux \
  tree \
  usbutils \
  vim-nox \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting

echo ""
echo "Updating databases"
sudo apt-file update
sudo mandb

echo "Finished!!"
