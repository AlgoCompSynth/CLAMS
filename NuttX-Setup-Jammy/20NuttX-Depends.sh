#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

# https://nuttx.apache.org/docs/latest/quickstart/install.html

echo ""
echo "Installing NuttX dependencies"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get install -qqy --no-install-recommends \
  automake \
  binutils-dev \
  bison \
  build-essential \
  gcc-multilib \
  flex \
  gettext \
  genromfs \
  gperf \
  libasound2-dev \
  libelf-dev \
  libexpat-dev \
  libgmp-dev \
  libisl-dev \
  libmad0-dev \
  libmp3lame-dev \
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
sudo apt-get install -qqy --no-install-recommends \
  kconfig-frontends

echo "Finished!!"
