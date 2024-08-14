#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME
export PICO_BOARD=sparkfun_promicro_rp2350

echo ""
echo "Setting environment variables"
source ../set_pico_envars

pushd $PICO_EXAMPLES_PATH
echo ""
echo "Configuring $PICO_EXAMPLES_PATH"
rm -fr build; mkdir build; cd build
/usr/bin/time cmake .. -DCMAKE_BUILD_TYPE=Debug > cmake.log 2>&1
echo "Compiling $PICO_EXAMPLES_PATH"
/usr/bin/time make -j`nproc` > make.log 2>&1 || true
popd
