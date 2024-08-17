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
  echo "Cloning Raspberry Pi repositories"
  pushd $PICO_PATH

    git clone --recursive $PICO_SDK_URL
    git clone --recursive $PICOTOOL_URL
    git clone --recursive $PICO_EXAMPLES_URL
    git clone --recursive $PICO_EXTRAS_URL
    git clone --recursive $PICO_PLAYGROUND_URL
    git clone --recursive $FREERTOS_KERNEL_URL

    echo ""
    echo "Listing supported boards to $SUPPORTED_BOARDS"
    ls -l $PICO_PATH/pico-sdk/src/boards/include/boards > $SUPPORTED_BOARDS

    echo ""
    echo "Installing picotool"

    pushd $PICOTOOL_PATH
      rm -fr build; mkdir build; cd build
      cmake .. 2>&1 | tee cmake.log
      make 2>&1 | tee make.log
      sudo make install
      picotool version
    popd

    echo ""
    echo Downloading latest debug probe firmware!
    mkdir --parents $PICO_UTILITIES_PATH
    pushd $PICO_UTILITIES_PATH
      curl -sOL \
        "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe_on_pico.uf2"
      curl -sOL \
        "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe.uf2"
    popd

  popd

popd

echo "Finished"
