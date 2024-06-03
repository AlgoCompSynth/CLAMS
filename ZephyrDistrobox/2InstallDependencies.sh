#! /usr/bin/env bash

set -e

echo "Defining LOGFILE"
export LOGFILE=$PWD/Logs/Dependencies.log

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
  >> $LOGFILE 2>&1

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
/usr/bin/time pip install west \
  >> $LOGFILE 2>&1

echo "Getting Zephyr source code"
/usr/bin/time west init $ZEPHYR_PROJECT \
  >> $LOGFILE 2>&1
pushd $ZEPHYR_PROJECT
/usr/bin/time west update \
  >> $LOGFILE 2>&1

echo "Exporting Zephyr CMake package"
/usr/bin/time west zephyr-export \
  >> $LOGFILE 2>&1

echo "Installing Python dependencies in virtual environment"
/usr/bin/time pip install -r $ZEPHYR_PROJECT/zephyr/scripts/requirements.txt \
  >> $LOGFILE 2>&1

echo "Wrapping up"
popd
deactivate
echo "PATH: $PATH"

echo ""
echo "Finished"
