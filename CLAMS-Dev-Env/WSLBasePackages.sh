#! /usr/bin/env bash

set -e

echo "Installing base packages"
sudo apt-get update
sudo apt-get install -y \
  apt-file \
  file \
  git-lfs \
  libpam-systemd \
  lsb-release \
  lynx \
  man-db \
  plocate \
  speedtest-cli \
  systemd \
  time \
  tmux \
  tree \
  vim-nox \
  zsh

echo "Finished"
