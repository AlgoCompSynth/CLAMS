#! /bin/bash

set -e

echo "Synchronizing distribution"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get autoremove -qqy

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
  vim-nox

echo "Updating databases"
sudo apt-file update
sudo mandb

echo "Creating fresh CLAMS-venv"
python3 -m venv --clear CLAMS-venv

echo "Activating CLAMS-venv"
source CLAMS-venv/bin/activate

echo "Installing Python packages"
pip install --upgrade pip
pip install --upgrade \
  kconfiglib \
  mpremote 

echo "Deactivating CLAMS-venv"
deactivate

echo "Finished!!"
