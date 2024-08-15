#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Building the regular examples"
export PICO_BOARD=sparkfun_promicro_rp2350
for dir in $PICO_EXAMPLES_PATH $PICO_PLAYGROUND_PATH
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

echo "Building the Pimoroni examples"
export PICO_BOARD=pico_w
for dir in $PIMORONI_PICO_PATH $PICOVISION_PATH $PICOVISION_PROJECTS_PATH
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
