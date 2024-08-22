#! /bin/bash

set -e

source ./ram-check.sh

echo "Installing gforth dependencies"
mkdir --parents $HOME/Projects
pushd $HOME/Projects
rm -fr gforth*
git clone https://git.savannah.gnu.org/git/gforth/
cd gforth
source ./install-deps.sh 2>&1 | tee /tmp/install-deps.log
popd
