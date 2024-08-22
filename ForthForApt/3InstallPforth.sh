#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/3UpgradePforth.log

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
