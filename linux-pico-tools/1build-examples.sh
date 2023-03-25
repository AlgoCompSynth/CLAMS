#! /bin/bash

set -e

source set_pico_envars

for dir in $PICO_EXAMPLES_PATH $PICO_PLAYGROUND_PATH $PICO_PIMORONI_PATH
do
  pushd $dir
  echo ""
  echo "Building $dir"
  sleep 5
  rm -fr build; mkdir build; cd build
  cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=Debug 2>&1 | tee cmake.log
  /usr/bin/time ninja -j `nproc` 2>&1 | tee ninja.log
  popd
done

echo ""
echo "Finished!"
