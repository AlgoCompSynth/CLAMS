#! /bin/bash

set -e

echo "Installing gforth"
pushd $HOME/Projects/gforth
sudo make install
hash -r
gforth --version
popd
