#! /bin/bash

set -e

echo "Checking RAM capacity"
export RAM_MEGABYTES=`free --mega | grep Mem: | sed 's/^Mem: *//' | sed 's/ .*$//'`
if [ "$RAM_MEGABYTES" -lt "3800" ]
then
  echo "$RAM_MEGABYTES is insufficient - aborting!"
  exit -255
fi

echo "Installing gforth"
pushd $HOME/Projects/gforth
./BUILD-FROM-SCRATCH
make -j`nproc` 2>&1 | tee /tmp/make.log
cd doc; make pdf 2>&1 | tee ../pdf.log; cd ..
popd
