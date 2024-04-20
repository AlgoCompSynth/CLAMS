#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
source set_pico_envars

echo ""
echo "Installing NuttX dependencies"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get install -qqy \
  automake \
  binutils-dev \
  bison \
  build-essential \
  flex \
  gettext \
  genromfs \
  gperf \
  libelf-dev \
  libexpat-dev \
  libgmp-dev \
  libisl-dev \
  libmpc-dev \
  libmpfr-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libtool \
  picocom \
  pkg-config \
  texinfo \
  u-boot-tools \
  util-linux \
  xxd

echo ""
echo "Installing KConfig tools"
sudo apt-get install -qqy \
  kconfig-frontends

echo "Finished!!"
