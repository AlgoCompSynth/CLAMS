#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ./SetEnvars.sh

export LOGFILE=$PWD/Logs/ZephyrProject.log
export SUPPORTED_BOARDS=$PWD/supported-boards.txt

# https://docs.zephyrproject.org/latest/develop/getting_started/index.html

echo "ZEPHYR_HOME: $ZEPHYR_HOME"
echo "Removing any existing $ZEPHYR_HOME"
rm -fr $ZEPHYR_HOME

echo "Creating Python virtual environment"
python3 -m venv $ZEPHYR_VENV
source $ZEPHYR_VENV/bin/activate
echo "PATH: $PATH"

echo "Installing 'west'"
/usr/bin/time pip install west \
  >> $LOGFILE 2>&1

echo "Initializing Zephyr workspace"
/usr/bin/time west init $ZEPHYR_HOME \
  >> $LOGFILE 2>&1

echo ""
pushd $ZEPHYR_HOME
echo "Updating Zephyr workspace"
/usr/bin/time west update \
  >> $LOGFILE 2>&1

echo "Exporting Zephyr CMake package"
/usr/bin/time west zephyr-export \
  >> $LOGFILE 2>&1

echo "Installing Python dependencies in virtual environment"
/usr/bin/time pip install -r $ZEPHYR_HOME/zephyr/scripts/requirements.txt \
  >> $LOGFILE 2>&1

echo "Listing supported boards"
west boards | sort -u > $SUPPORTED_BOARDS
cp $SUPPORTED_BOARDS $ZEPHYR_HOME

echo "Wrapping up"
popd
echo ""
deactivate
echo "PATH: $PATH"

echo ""
echo "Finished"
