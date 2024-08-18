#! /bin/bash

set -e

function sdk_build {
  pushd $dir > /dev/null

    target="$dir/build_${PICO_BOARD}_${PICO_PLATFORM}"
    echo ""
    echo "Re-creating $target"
    rm -fr $target; mkdir $target; pushd $target > /dev/null

      echo "Configuring $target"
      cmake .. \
        -DCMAKE_BUILD_TYPE=Debug \
        -DPICO_SDK_POST_LIST_DIRS=$PICO_EXTRAS_PATH \
        > cmake.log 2>&1

      echo "Compiling $target"
      if [ "${#SJMAKE}" -gt "0" ]
      then
        echo "Single-job 'make' enabled"
        /usr/bin/time make -j1 > make.log 2>&1
      else
        /usr/bin/time make -j`nproc` > make.log 2>&1
      fi

      popd > /dev/null

    popd > /dev/null
}

echo ""
echo ""
echo "If you want to run in single-job 'make' mode for troubleshooting,"
echo "restart this script with a non-empty parameter string as the first"
echo "argument."
sleep 10
export SJMAKE=$1

echo ""
export UF2_FILES="$PWD/uf2Files.log"
echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME
echo "Setting environment variables"
source ../set_pico_envars

echo ""
echo ""
echo "Building the rp2350 examples"
for dir in \
  $PICO_EXAMPLES_PATH \
  $PICO_PLAYGROUND_PATH
do

  for board in \
    sparkfun_promicro_rp2350 \
    pimoroni_pico_plus2_rp2350 \
    ilabs_challenger_rp2350_bconnect \
    ilabs_challenger_rp2350_wifi_ble
  do
    export PICO_BOARD=$board

    for platform in rp2350-riscv rp2350-arm-s
    do
      export PICO_PLATFORM=$platform
      sdk_build $SJMAKE
    done

  done

done

echo ""
echo "Building the pico_w examples"
for dir in \
  $PICO_EXAMPLES_PATH \
  $PICO_PLAYGROUND_PATH
do
    export PICO_BOARD=pico_w
    export PICO_PLATFORM=rp2040
    sdk_build $SJMAKE
done

echo ""
echo "Listing uf2 files to $UF2_FILES"
./list-uf2-files.sh > $UF2_FILES

echo "Finished"
