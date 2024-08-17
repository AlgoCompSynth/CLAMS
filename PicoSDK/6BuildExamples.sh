#! /bin/bash

set -e

function sdk_build {
  pushd $dir > /dev/null

    target="$dir/build_$PICO_BOARD"
    echo ""
    echo "Re-creating $target"
    rm -fr $target; mkdir $target; pushd $target > /dev/null

      echo "Configuring $target"
      cmake .. \
        -DCMAKE_BUILD_TYPE=Debug \
        -DPICO_SDK_POST_LIST_DIRS=$PICO_EXTRAS_PATH \
        > cmake.log 2>&1

      echo "Compiling $target"
      /usr/bin/time make -j`nproc` > make.log 2>&1

      popd

    popd
}

export UF2_FILES="$PWD/uf2Files.log"
echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME
echo "Setting environment variables"
source ../set_pico_envars

echo ""
echo ""
echo "Building the regular examples"
for dir in \
  $PICO_EXAMPLES_PATH \
  $PICO_PLAYGROUND_PATH
do

  for board in \
    pico_w \
    sparkfun_promicro_rp2350 \
    pimoroni_pico_plus2_rp2350 \
    ilabs_challenger_rp2350_bconnect \
    ilabs_challenger_rp2350_wifi_ble
  do
    export PICO_BOARD=$board
    sdk_build
  done

done

echo ""
echo "Listing uf2 files to $UF2_FILES"
./list-uf2-files.sh > $UF2_FILES

echo "Finished"
