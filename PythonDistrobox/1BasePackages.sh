#! /usr/bin/env bash

set -e

echo "Installing base packages"
sudo apt-get install -y \
  apt-file \
  file \
  git-lfs \
  lsb-release \
  lynx \
  plocate \
  speedtest-cli \
  time \
  tree \
  vim-nox \
  zsh

echo "Finished"
