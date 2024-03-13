#! /bin/bash

set -e

echo ""; sleep 2
echo "Setting bash aliases"
cat bash_aliases >> $HOME/.bashrc
source $HOME/.bashrc

echo ""; sleep 2
echo "Installing command line tools"
sudo dnf install -y \
  cmake \
  git \
  git-lfs \
  info \
  libusb1-devel \
  man-db \
  minicom \
  ninja-build \
  pkg-config \
  screen \
  time \
  tmux \
  tree \
  usbutils \
  vim

echo ""; sleep 2
echo "Updating databases"
sudo mandb

echo ""; sleep 2
echo "Creating fresh CLAMS-venv"
python3 -m venv --clear CLAMS-venv

echo ""; sleep 2
echo "Activating CLAMS-venv"
source CLAMS-venv/bin/activate

echo ""; sleep 2
echo "Installing packages"
pip install --upgrade pip
pip install --upgrade \
  kconfiglib \
  mpremote 

echo ""; sleep 2
echo "Deactivating CLAMS-venv"
deactivate

echo ""; sleep 2
echo "Restart bash to activate aliases"

echo ""; sleep 2
echo "Finished!!"
