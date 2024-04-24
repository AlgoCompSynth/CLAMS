#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo "Adding Arm tools to PATH"
export PATH=$NUTTX_TOOLS/gcc-arm-none-eabi/bin:$PATH

echo "Adding ESP32-C3/C6 tools to PATH"
export PATH=$NUTTX_TOOLS/riscv-none-elf-gcc/bin:$PATH

echo "Adding ESP32-S3 tools to PATH"
export PATH=$NUTTX_TOOLS/xtensa-esp32s3-elf-gcc/bin:$PATH
source $NUTTX_PATH/esptool/bin/activate

echo "Adding kconfig front ends to PATH"
export PATH=$NUTTX_TOOLS/kconfig-frontends/bin:$PATH

echo "Adding rust tools to PATH"
export PATH=$NUTTX_TOOLS/rust/cargo/bin:$PATH
echo "Setting default rust to stable"
rustup default stable

echo "Adding wasi-sdk to PATH"
export PATH=$NUTTX_TOOLS/wasi-sdk/bin:$PATH

echo ""
echo "PATH: $PATH"

pushd $NUTTX_PATH/nuttx

  echo ""
  echo "Creating fresh directory for failed tests"
  export NUTTX_FAILED_TESTS=$NUTTX_PATH/failed_tests
  rm -fr $NUTTX_FAILED_TESTS; mkdir --parents $NUTTX_FAILED_TESTS

  for configuration in \
   `grep -E \
      "esp32c3-devkit|esp32c6-devkitc|esp32s3-devkit|raspberrypi-pico|sim:|teensy-4" \
      "sim:" \
      $NUTTX_PATH/supported-configurations.txt \
      | grep -v "z80" \
      | sort -u`
  do
    echo ""
    echo ""
    echo "Testing configuration $configuration"
    result_path_name=$NUTTX_TESTS/`echo $configuration | sed 's/:/../g'`

    if [ ! -d "$result_path_name" ]
    then
      echo "...creating $result_path_name"
      mkdir --parents $result_path_name
  
      echo "...cleaning"
      make distclean > $result_path_name/clean.log 2>&1
      echo "...configuring"
      ./tools/configure.sh -l $configuration > $result_path_name/configure.log 2>&1
      echo "...compiling and linking"
      /usr/bin/time make > $result_path_name/make.log 2>&1 || true
  
      if [ ! -x nuttx ]
      then
        echo "...make failed - moving logfiles to $NUTTX_FAILED_TESTS"
        mv $result_path_name $NUTTX_FAILED_TESTS
        continue
      fi

      # make artifacts like Pico SDK makes
      ln -s nuttx nuttx.elf
      if [[ "$configuration" =~ "esp32c3" ]]
      then
        riscv-none-elf-objdump -d nuttx.elf > nuttx.dis
      elif [[ "$configuration" =~ "esp32c6" ]]
      then
        riscv-none-elf-objdump -d nuttx.elf > nuttx.dis
      elif [[ "$configuration" =~ "esp32s3" ]]
      then
        xtensa-esp32s3-elf-objdump -d nuttx.elf > nuttx.dis
      elif [[ "$configuration" =~ "sim" ]]
      then
        /usr/bin/objdump -d nuttx.elf > nuttx.dis
      else
        arm-none-eabi-objdump -d nuttx.elf > nuttx.dis
      fi

      echo "...saving $configuration artifacts to $result_path_name"
      cp nuttx* $result_path_name/

    fi

  done

popd

echo "Finished!"
