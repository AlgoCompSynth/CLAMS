#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

export DATE=`date -Iseconds`
export LOGFILE="$ARDUINO_LOGFILE_PATH/arduino-$DATE.log"
mkdir --parents $ARDUINO_LOGFILE_PATH
echo "Starting Arduino IDE with logs on $LOGFILE"
$ARDUINO_IDE_PATH/arduino-ide 2>&1 | tee $LOGFILE
