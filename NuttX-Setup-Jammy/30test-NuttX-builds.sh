#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo "Adding esp32s3 tools to PATH"
export PATH=$NUTTX_TOOLS/xtensa-esp32s3-elf-gcc/bin:$PATH
source $NUTTX_PATH/esptool/bin/activate

echo ""
echo "Adding esp32-c3 tools to PATH"
export PATH=$NUTTX_TOOLS/riscv-none-elf-gcc/bin:$PATH

echo ""
echo "PATH: $PATH"

pushd $NUTTX_PATH/nuttx

echo ""
echo "Creating fresh test output directory"
rm -fr $NUTTX_TESTS; mkdir --parents $NUTTX_TESTS

  for configuration in \
    'esp32c6-devkitc:esp32c3-devkit|esp32s3-devkit|raspberrypi-pico|teensy-4' \
   `grep -E \
      $NUTTX_PATH/supported-configurations.txt`
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
      make distclean || true
      echo "...configuring"
      ./tools/configure.sh -l $configuration > $result_path_name/configure.log 2>&1
      echo "...compiling and linking"
      /usr/bin/time make > $result_path_name/make.log 2>&1
  
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
      else
        arm-none-eabi-objdump -d nuttx.elf > nuttx.dis
      fi

      echo "...saving $configuration artifacts to $result_path_name"
      cp nuttx* $result_path_name/
      ls -dl $result_path_name/*
    fi

  done

popd

echo "Finished!"
