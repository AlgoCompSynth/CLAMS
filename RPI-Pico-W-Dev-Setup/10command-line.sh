#! /bin/bash

set -e

echo ""; sleep 2
echo "Setting bash aliases"
cat bash_aliases >> $HOME/.bash_aliases
source $HOME/.bash_aliases

echo ""; sleep 2
echo "Installing Debian backports"
export `grep VERSION_CODENAME /etc/os-release`
sudo cp $VERSION_CODENAME-backports.list /etc/apt/sources.list.d/

echo ""; sleep 2
echo "Upgrading Linux"
sudo apt-get update -qq && sudo apt-get upgrade -qqy
sudo apt-get -qqy autoremove

echo ""; sleep 2
echo "Installing command line tools"
sudo apt-get install -qqy --no-install-recommends \
  apt-file \
  build-essential \
  cmake \
  git \
  git-lfs \
  info \
  libusb-dev \
  man-db \
  minicom \
  ninja-build \
  pkg-config \
  python3-venv \
  screen \
  time \
  tmux \
  tree \
  usbutils \
  vim-nox

echo ""; sleep 2
echo "Updating databases"
sudo mandb
sudo apt-file update

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
