#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo "Setting environment variables"
source ./set_pico_envars

echo "Linux prerequisites"
sudo apt-get update -qq
sudo apt-get upgrade -qqy
sudo apt-get install -qqy --no-install-recommends \
  bison \
  ccache \
  cmake \
  dfu-util \
  flex \
  git \
  gperf \
  libffi-dev \
  libssl-dev \
  libusb-1.0-0 \
  ninja-build \
  python3 \
  python3-pip \
  python3-venv \
  wget

echo "Installing esptool and imgtool"
pushd $NUTTX_PATH
rm -fr esptool
python3 -m venv esptool
source ./esptool/bin/activate
pip install --upgrade pip
pip install --upgrade esptool imgtool
deactivate
popd

echo "Finished!"
