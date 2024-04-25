#! /bin/bash

set -e

echo ""
echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo "Setting environment variables"
source ./set_pico_envars

# https://nuttx.apache.org/docs/latest/quickstart/install.html

echo "Installing NuttX dependencies"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get install -qqy --no-install-recommends \
  automake \
  binutils-dev \
  bison \
  build-essential \
  g++-multilib \
  gcc-multilib \
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
  python3-pip \
  python3-venv \
  texinfo \
  u-boot-tools \
  util-linux \
  xxd

echo "Installing KConfig tools"
sudo apt-get install -qqy --no-install-recommends \
  kconfig-frontends

echo "Creating 'nuttx-venv' Python virtual environment'"
python3 -m venv $NUTTX_VENV
source $NUTTX_VENV/bin/activate
pip install --upgrade kconfiglib
deactivate

echo "Finished!!"
