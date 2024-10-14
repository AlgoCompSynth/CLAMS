#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/3_build_host_cforth.log
rm -f $LOGFILE

echo "Clearing PlatformIO caches"
rm --force --recursive $HOME/.platformio $CFORTH_PATH/.pio

echo "Activating PlatformIO virtual environment"
source $ACTIVATE_PLATFORMIO_VENV

pushd $CFORTH_PATH
  date +"%F %T" \
    >> $LOGFILE 2>&1
  echo "Building host cforth"
  /usr/bin/time pio run --verbose \
    >> $LOGFILE 2>&1
  date +"%F %T" \
    >> $LOGFILE 2>&1
popd

echo "Deactivating"
deactivate

echo "Finished"
