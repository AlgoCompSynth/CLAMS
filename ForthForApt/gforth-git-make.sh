#! /bin/bash

set -e

source ./ram-check.sh

echo "Installing gforth"
pushd $HOME/Projects/gforth
./BUILD-FROM-SCRATCH
make -j`nproc` 2>&1 | tee /tmp/make.log
cd doc; make pdf 2>&1 | tee ../pdf.log; cd ..
popd
