#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/1_clone_cforth.log
rm -f $LOGFILE

echo "Cloning fresh cforth project repository"
mkdir --parents $CFORTH_PATH
pushd $CFORTH_PATH/..
  rm --force --recursive $CFORTH_PATH
  /usr/bin/time git clone $CFORTH_URL \
    >> $LOGFILE 2>&1
popd

echo "Appending test envioronments to $CFORTH_PATH/platformio.ini"
cat testing_platformio.ini >> $CFORTH_PATH/platformio.ini

echo "Finished"
