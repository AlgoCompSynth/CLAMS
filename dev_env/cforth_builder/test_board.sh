#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

export PIO_ENVIRONMENT=${1-rpipico}
export BOARD_TAG=${2-""}
export LOGFILE="$PWD/${PIO_ENVIRONMENT}${BOARD_TAG}.log"
rm -f $LOGFILE

export TOOL_BIN_PATH="$HOME/.platformio/packages/toolchain-rp2040-earlephilhower/arm-none-eabi/bin/"

echo "Activating PlatformIO virtual environment"
source $ACTIVATE_PLATFORMIO_VENV

pushd $CFORTH_PATH
  date +"%F %T" \
    >> $LOGFILE 2>&1

  echo "Listing USB devices"
  echo "" >> $LOGFILE 2>&1; echo "" >> $LOGFILE 2>&1
  lsusb \
    >> $LOGFILE 2>&1
  echo "" >> $LOGFILE 2>&1; echo "" >> $LOGFILE 2>&1
  echo "Listing relevant TTYs"
  ls -l /dev/ttyACM* \
    >> $LOGFILE 2>&1 || true
  echo "" >> $LOGFILE 2>&1; echo "" >> $LOGFILE 2>&1

  echo "Building and uploading"
  /usr/bin/time pio run --verbose \
    --environment $PIO_ENVIRONMENT \
    --target upload \
    >> $LOGFILE 2>&1

  echo "Sleeping 20 seconds for devices to settle"
  sleep 20

  echo "" >> $LOGFILE 2>&1; echo "" >> $LOGFILE 2>&1
  echo "Listing USB devices"
  lsusb \
    >> $LOGFILE 2>&1
  echo "" >> $LOGFILE 2>&1; echo "" >> $LOGFILE 2>&1
  echo "Listing relevant TTYs"
  ls -l /dev/ttyACM* \
    >> $LOGFILE 2>&1 || true
  date +"%F %T" \
    >> $LOGFILE 2>&1
popd

echo "Deactivating"
deactivate

echo "Fetching firmware files"
cp $CFORTH_PATH/.pio/build/$PIO_ENVIRONMENT/firmware.elf "${PIO_ENVIRONMENT}${BOARD_TAG}.elf"
cp $CFORTH_PATH/.pio/build/$PIO_ENVIRONMENT/firmware.uf2 "${PIO_ENVIRONMENT}${BOARD_TAG}.uf2"
echo "Disassembling"
$TOOL_BIN_PATH/objdump \
  -d \
  "${PIO_ENVIRONMENT}${BOARD_TAG}.elf" \
  > "${PIO_ENVIRONMENT}${BOARD_TAG}.dis"

echo "Active TTYs"
ls -l /dev/ttyACM* || true

echo "Finished"
