#! /bin/bash

set -e

echo ""; sleep 2
echo "Setting bash aliases"
cat bash_aliases >> $HOME/.bashrc
source $HOME/.bashrc
if [ -e "$HOME/.zshrc" ]
then
  echo "Setting zsh aliases"
  cat bash_aliases >> $HOME/.zshrc
fi

echo ""; sleep 2
echo "Synchronizing distribution"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get autoremove -qqy

echo ""; sleep 2
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

echo ""; sleep 2
echo "Updating databases"
sudo apt-file update
sudo mandb

echo ""; sleep 2
echo "Creating fresh CLAMS-venv"
python3 -m venv --clear CLAMS-venv

echo ""; sleep 2
echo "Activating CLAMS-venv"
source CLAMS-venv/bin/activate

echo ""; sleep 2
echo "Installing Python packages"
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
