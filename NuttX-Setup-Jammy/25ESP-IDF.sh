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

echo "Cloning ESP-IDF repository"
rm -fr $ESP_IDF_PATH; mkdir --parents $ESP_IDF_PATH; pushd $ESP_IDF_PATH
git clone -b v$ESP_IDF_VERSION --recursive https://github.com/espressif/esp-idf.git

echo "Installing tools"
cd esp-idf
./install.sh esp32s3,esp32c3,esp32c6

popd

echo "Finished!"
