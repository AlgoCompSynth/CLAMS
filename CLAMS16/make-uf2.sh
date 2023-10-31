#! /bin/bash

set -e

rm -fr build; mkdir build; pushd build
cmake ..
make --jobs=`nproc`
ls -Altr
popd
