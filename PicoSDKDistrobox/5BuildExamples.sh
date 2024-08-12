#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

pushd $PICO_EXAMPLES_PATH
echo ""
echo "Configuring $PICO_EXAMPLES_PATH"
rm -fr build; mkdir build; cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug 2>&1 | tee cmake.log
echo "Compiling $PICO_EXAMPLES_PATH"
/usr/bin/time make -j`nproc` 2>&1 | tee make.log || true
popd
