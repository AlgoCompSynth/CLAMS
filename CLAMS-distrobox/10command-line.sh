#! /bin/bash

set -e

echo ""
echo "Setting bash aliases"
cat bash_aliases >> $HOME/.bash_aliases
source $HOME/.bash_aliases

echo ""
echo "Upgrading Linux"
sudo apt-get update -qq && sudo apt-get upgrade -qqy
sudo apt-get -qqy autoremove

echo ""
echo "Installing command line tools"
sudo apt-get install -qqy --no-install-recommends \
  apt-file \
  build-essential \
  cmake \
  git \
  git-lfs \
  man-db \
  minicom \
  ninja-build \
  python3-venv \
  screen \
  time \
  tmux \
  tree \
  vim-nox

echo ""
echo "Updating databases"
sudo mandb
sudo apt-file update

echo ""
echo "Restart bash to activate aliases"
echo ""
echo "Finished!!"
