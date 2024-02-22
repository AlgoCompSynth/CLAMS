#! /bin/bash

set -e

echo "Creating fresh apio venv"
python3 -m venv --clear host-apio

echo "Activating apio venv"
source host-apio/bin/activate

echo "Downloading the latest APIO dev version (with pico-ice support):"
pip install --upgrade pip
pip install --upgrade apio
apio --version
 
echo "Downloading and installing oss-cad-suite"
apio install -a

echo "Setting environment variables"
export OSS_CAD_SUITE="$HOME/.apio/packages/tools-oss-cad-suite"
export PATH="$PATH:$OSS_CAD_SUITE/bin"

echo "Testing the examples"
rm -fr examples; mkdir examples; pushd examples
for example in `apio examples --list | grep "iCE40-UP5K"`
do

  echo "Fetching example $example"
  apio examples -d $example
  pushd $example
 
  echo "Setting the board to 'pico-ice'"
  apio init --sayyes --board pico-ice
 
  echo "Building the project using yosys/nextpnr"
  apio build || true
 
  popd

done

popd

deactivate
