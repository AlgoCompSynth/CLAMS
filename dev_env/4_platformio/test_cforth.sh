#! /usr/bin/env bash

set -e

export HERE=$PWD

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing Linux dependencies"
sudo apt-get update
sudo apt-get install -y \
  libc6-dev-i386 \
  libc6-dev-i386-cross \
  screen \
  2>&1 | tee dependencies.log

echo "Activating CLAMS Python virtual environment"
source $ACTIVATE_CLAMS_VENV

echo "Creating $HOME/Projects if necessary"
mkdir --parents $HOME/Projects

echo "Cloning cforth repository"
pushd $HOME/Projects

  rm -fr cforth
  git clone https://github.com/AlgoCompSynth/cforth.git
  pushd cforth

  echo "Building host cforth"
  pio run --verbose 2>&1 | tee $HERE/host-build.log

  echo "Copying host cforth to $HOME/.local/bin"
  cp .pio/build/host_forth/forth.dic $HOME/.local/bin/forth.dic
  cp .pio/build/host_forth/program $HOME/.local/bin/cforth

  echo "Building Raspberry Pi Pico cforth"
  pio run --verbose --environment pico --target upload 2>&1 | tee $HERE/pico-build.log

  echo "Connect to cforth via"
  echo ""
  echo "    screen /dev/ttyACM0 115200"
  echo ""

  popd

popd
echo "Deactivating CLAMS Python virtual environment"
deactivate

echo "Finished"
