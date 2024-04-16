#! /bin/bash

set -e

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

echo "Cloning ESP-IDF repository"
rm -fr $HOME/esp; mkdir --parents $HOME/esp; pushd $HOME/esp
git clone -b v5.2.1 --recursive https://github.com/espressif/esp-idf.git

echo "Installing tools"
cd esp-idf
./install.sh esp32s3,esp32c3,esp32c6

popd

echo "Finished!"
