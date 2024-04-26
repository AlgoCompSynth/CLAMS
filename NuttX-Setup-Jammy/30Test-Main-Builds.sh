#! /bin/bash

set -e

echo "Setting PATH"
source ./source-me-to-set-NuttX-PATH.sh

pushd $NUTTX_PATH/nuttx

  echo ""
  echo "Creating fresh directory for failed tests"
  rm -fr $NUTTX_FAILED_TESTS; mkdir --parents $NUTTX_FAILED_TESTS

  for configuration in \
   `grep -E \
      "esp32c3-devkit|esp32c6-devkitc|esp32s3-devkit|raspberrypi-pico|teensy-4" \
      $NUTTX_PATH/supported-configurations.txt \
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
