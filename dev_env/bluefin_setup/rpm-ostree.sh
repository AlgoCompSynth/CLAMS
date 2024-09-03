#! /usr/bin/env bash

set -e

echo "Installing Pico SDK dependecies"
rpm-ostree install --idempotent --allow-inactive \
  autoconf \
  automake \
  capstone-devel \
  cmake \
  hidapi-devel \
  libftdi-devel \
  libtool \
  libusb1-devel \
  make \
  minicom \
  pkgconf \
  python3-devel \
  python3-pip \
  screen \
  texinfo \
  tmux \
  2>&1 | tee rpm-ostree.log

echo "Finished"
