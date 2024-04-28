#! /bin/bash

set -e

if [ "${#1}" -lt "5" ]
then
  echo "usage: ./build-nuttx.sh configuration"
  echo "where 'configuration' is in the list of supported configurations"
  echo "Exiting with error -1024"
  exit -1024
fi
export configuration=$1

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo "Adding Python virtual environment"
source $NUTTX_VENV/bin/activate

echo "Adding Arm tools to PATH"
export PATH=$NUTTX_TOOLS/gcc-arm-none-eabi/bin:$PATH

echo "Adding ESP32-C3/C6 tools to PATH"
export PATH=$NUTTX_TOOLS/riscv-none-elf-gcc/bin:$PATH

echo "Adding ESP32-S3 tools to PATH"
export PATH=$NUTTX_TOOLS/xtensa-esp32s3-elf-gcc/bin:$PATH

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
echo ""
echo "Testing configuration $configuration"
result_path_name=$NUTTX_TESTS/`echo $configuration | sed 's/:/../g'`

if [ -d "$result_path_name" ]
then
  echo "...creating fresh $result_path_name"
  rm -fr $result_path_name
  mkdir --parents $result_path_name
fi
  
echo "...cleaning"
make distclean > $result_path_name/clean.log 2>&1
echo "...configuring"
./tools/configure.sh -l $configuration > $result_path_name/configure.log 2>&1

echo ""
echo "Edit configuration now!"
sleep 5
make menuconfig

echo ""
echo "...compiling and linking"
/usr/bin/time make > $result_path_name/make.log 2>&1 || true
  
if [ ! -x nuttx ]
then
  echo "...make failed - moving logfiles to $NUTTX_FAILED_TESTS"
  mkdir --parents $NUTTX_FAILED_TESTS
  rm -fr $NUTTX_FAILED_TESTS/$result_path_name
  mv $result_path_name $NUTTX_FAILED_TESTS
  echo "Exiting with error -2048"
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

popd

echo "Finished!"
