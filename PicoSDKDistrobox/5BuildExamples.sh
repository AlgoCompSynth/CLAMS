#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Downloading the examples"
pushd $PICO_PATH
rm -fr $PICO_EXAMPLES_TARBALL $PICO_EXAMPLES_PATH
wget --quiet $PICO_EXAMPLES_URL
tar xf $PICO_EXAMPLES_TARBALL

echo "Finished!"
exit

  pushd $dir
  echo ""
  echo "Configuring $dir"
  rm -fr build; mkdir build; cd build
  cmake .. -DCMAKE_BUILD_TYPE=Debug -DPICO_SDK_POST_LIST_DIRS=$PICO_EXTRAS_PATH 2>&1 | tee cmake.log
  echo "Compiling $dir"
  /usr/bin/time make -j`nproc` 2>&1 | tee make.log || true
  popd

