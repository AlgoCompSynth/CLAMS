#! /usr/bin/env bash

set -e


# https://docs.zephyrproject.org/latest/develop/getting_started/index.html
echo ""
echo "Getting CMake repository"
pushd /tmp
wget https://apt.kitware.com/kitware-archive.sh
sudo bash kitware-archive.sh
popd

echo "Installing Linux dependencies"
/usr/bin/time sudo apt-get install -qqy --no-install-recommends \
  ccache \
  cmake \
  device-tree-compiler \
  dfu-util \
  file \
  g++-multilib \
  gcc \
  gcc-multilib \
  git \
  gperf \
  libmagic1 \
  libsdl2-dev \
  make \
  ninja-build \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-tk \
  python3-venv \
  python3-wheel \
  wget \
  xz-utils \
  2>&1 | tee LinuxDependencies.log

echo "Checking versions"
cmake --version
python3 --version
dtc --version

echo "Defining ZEPHYR_PROJECT"
export ZEPHYR_PROJECT=$HOME/zephyrproject
echo "ZEPHYR_PROJECT: $ZEPHYR_PROJECT"

echo "Creating Python virtual environment"
python3 -m venv $ZEPHYR_PROJECT/.venv
source $ZEPHYR_PROJECT/.venv/bin/activate
echo "PATH: $PATH"

echo "Installing 'west'"
pip install west

echo "Getting Zephyr source code"
west init $ZEPHYR_PROJECT
pushd $ZEPHYR_PROJECT
west update

echo "Exporting Zephyr CMake package"
west zephyr-export

echo "Installing Python dependencies in virtual environment"
pip install -r $ZEPHYR_PROJECT/zephyr/scripts/requirements.txt

echo "Wrapping up"
popd
deactivate
echo "PATH: $PATH"

echo ""
echo "Finished"
