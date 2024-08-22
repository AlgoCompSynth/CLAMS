#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/3UpgradePforth.log

echo "Checking RAM capacity"
export RAM_MEGABYTES=`free --mega | grep Mem: | sed 's/^Mem: *//' | sed 's/ .*$//'`
if [ "$RAM_MEGABYTES" -lt "3800" ]
then
  echo "$RAM_MEGABYTES is insufficient - aborting!"
  exit -255
fi

echo "Cloning pforth"
mkdir --parents $HOME/Projects
pushd $HOME/Projects
rm -fr pforth*
/usr/bin/time git clone https://github.com/philburk/pforth.git > /tmp/clone.log 2>&1

echo "Configuring pforth"
pushd pforth
rm -fr build; mkdir build; cd build
cmake ..

echo "Configuring pforth"
make

echo "Installing pforth"
sudo cp ../fth/pforth_standalone /usr/local/bin/pforth
echo "bye" | pforth

popd

echo "Finished"
