#! /usr/bin/env bash

set -e

echo "Defining LOGFILE"
export LOGFILE=$PWD/Logs/LinuxDependencies.log

# https://docs.zephyrproject.org/latest/develop/getting_started/index.html
echo ""
echo "Getting CMake repository"
pushd /tmp
wget https://apt.kitware.com/kitware-archive.sh \
  >> $LOGFILE 2>&1
sudo bash kitware-archive.sh \
  >> $LOGFILE 2>&1
popd
echo ""

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

echo "Finished"
