#! /bin/bash

set -e

echo "Checking RAM capacity"
export RAM_MEGABYTES=`free --mega | grep Mem: | sed 's/^Mem: *//' | sed 's/ .*$//'`
if [ "$RAM_MEGABYTES" -lt "3800" ]
then
  echo "$RAM_MEGABYTES is insufficient - aborting!"
  exit -255
fi

echo "Installing gforth dependencies"
mkdir --parents $HOME/Projects
pushd $HOME/Projects
sudo rm -fr gforth*
git clone https://git.savannah.gnu.org/git/gforth/
cd gforth
source ./install-deps.sh 2>&1 | tee /tmp/install-deps.log
popd
