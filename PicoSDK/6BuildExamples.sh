#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME
export PICO_BOARD=sparkfun_promicro_rp2350

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Building the examples"
for dir in $PICO_EXAMPLES_PATH $PICO_PLAYGROUND_PATH $PICO_PIMORONI_PATH $PICO_PICOVISION_PROJECTS_PATH
do
  pushd $dir
  echo ""
  echo "Configuring $dir"
  rm -fr build; mkdir build; cd build
  cmake .. -DCMAKE_BUILD_TYPE=Debug -DPICO_SDK_POST_LIST_DIRS=$PICO_EXTRAS_PATH > cmake.log 2>&1
  echo "Compiling $dir"
  /usr/bin/time make -j`nproc` > make.log 2>&1
  popd
done

echo "Finished"
