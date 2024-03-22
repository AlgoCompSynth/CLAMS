#! /bin/bash

set -e

source ./set_pico_envars
pushd $NUTTX_PATH/nuttx

  for configuration in `grep raspberrypi-pico $NUTTX_PATH/supported-configurations.txt`
  do
    echo ""
    echo ""
    echo "Testing configuration $configuration"
    result_path_name=$NUTTX_PATH/`echo $configuration | sed 's/:/../g'`

    if [ ! -d "$result_path_name" ]
    then
      echo "...creating $result_path_name"
      mkdir --parents $result_path_name
  
      echo "...cleaning"
      make distclean || true
      echo "...configuring"
      ./tools/configure.sh -l $configuration 2>&1 | tee $result_path_name/configure.log
      echo "...compiling and linking"
      /usr/bin/time make 2>&1 | tee $result_path_name/make.log || true
  
      # make artifacts like Pico SDK makes
      ln -s nuttx nuttx.elf
      arm-none-eabi-objdump -d nuttx.elf > nuttx.dis
  
      echo "...saving $configuration artifacts to $result_path_name"
      cp nuttx* $result_path_name/
      ls -dl $result_path_name/*
    fi

  done

popd

echo "Finished!"
