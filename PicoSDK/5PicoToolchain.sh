#! /bin/bash

set -e

export SUPPORTED_BOARDS="$PWD/SupportedBoards.log"

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

pushd $CLAMS_BASE

  echo ""
  echo "Creating fresh $PICO_PATH"
  rm -fr $PICO_PATH
  mkdir --parents $PICO_PATH

  echo ""
  echo "Cloning Raspberry Pi Pico SDK repositories"
  pushd $PICO_PATH

    git clone --recursive $PICO_SDK_URL
    git clone --recursive $PICO_EXAMPLES_URL
    git clone --recursive $PICO_EXTRAS_URL
    git clone --recursive $PICO_PLAYGROUND_URL
    git clone --recursive $FREERTOS_KERNEL_URL

    echo ""
    echo "Listing supported boards to $SUPPORTED_BOARDS"
    ls -l $PICO_PATH/pico-sdk/src/boards/include/boards > $SUPPORTED_BOARDS

  popd

  echo ""
  echo "Cloning Pico utilities"
  pushd $PICO_UTILITIES_PATH
    rm -fr $PICOTOOL_REPO_PATH; git clone --recursive $PICOTOOL_URL $PICOTOOL_REPO_PATH
    rm -fr $OPENOCD_REPO_PATH; git clone --depth=1 $OPENOCD_URL $OPENOCD_REPO_PATH

    echo ""
    echo "Building picotool"
    pushd $PICOTOOL_REPO_PATH
      mkdir build
      cd build
      cmake ../
      make -j`nproc`
      cp picotool $PICO_UTILITIES_PATH
    popd

    echo ""
    echo "Building openocd"
    pushd $OPENOCD_REPO_PATH
      ./bootstrap
      ./configure --enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio --disable-werror
      make -j`nproc`
      cp src/openocd $PICO_UTILITIES_PATH
    popd

    echo ""
    echo "Downloading Debug Probe firmware"
    curl -sOL $DEBUG_PROBE_FIRMWARE

  popd

popd

echo "Finished"
