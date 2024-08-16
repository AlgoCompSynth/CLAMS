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

    for repo in \
      $PICO_SDK_URL $PICOTOOL_URL $PICO_EXAMPLES_URL $PICO_EXTRAS_URL $PICO_PLAYGROUND_URL
    do
      git clone --recursive $repo
    done

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
    pushd $PICO_UTILITIES_PATH
      curl -sOL \
        "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe_on_pico.uf2"
      curl -sOL \
        "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe.uf2"

      echo "Downloading flash_nuke.uf2"
      # https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#resetting-flash-memory
      curl -sOL "https://datasheets.raspberrypi.com/soft/flash_nuke.uf2"
    popd

  popd

popd

echo "Finished!"
