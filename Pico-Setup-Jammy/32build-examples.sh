#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo "Building the examples"
for dir in $PICO_EXAMPLES_PATH $PICO_PLAYGROUND_PATH $PICO_PIMORONI_PATH $PICO_PICOVISION_PROJECTS_PATH
do
  pushd $dir
  echo ""
  echo "Configuring $dir"
  rm -fr build; mkdir build; cd build
  cmake .. -DCMAKE_BUILD_TYPE=Debug -DPICO_SDK_POST_LIST_DIRS=$PICO_EXTRAS_PATH 2>&1 | tee cmake.log
  echo "Compiling $dir"
  /usr/bin/time make -j`nproc` 2>&1 | tee make.log || true
  popd
done

echo "Finished!"
