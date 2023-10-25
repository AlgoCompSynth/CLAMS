#! /bin/bash

set -e

echo "Downloading diagram"
curl -s \
  "https://cdn.shopify.com/s/files/1/0174/1800/files/picovision_diagram.pdf?v=1696414342" > picovision_diagram.pdf

export PICOVISION_VERSION="1.0.2"
echo "Downloading Python release $PICOVISION_VERSION"
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-examples-v$PICOVISION_VERSION.zip" #\
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-v$PICOVISION_VERSION-micropython.uf2"
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-widescreen-v$PICOVISION_VERSION-micropython.uf2"
curl -sL \
  "https://github.com/pimoroni/picovision/archive/refs/tags/v$PICOVISION_VERSION.zip" > source-v$PICOVISION_VERSION.zip

echo "Downloading flash_nuke.uf2"
curl -sOL https://datasheets.raspberrypi.com/soft/flash_nuke.uf2

echo "Unpacking examples"
rm -fr python-examples; mkdir -p python-examples; cd python-examples
unzip ../pimoroni-picovision-examples-v$PICOVISION_VERSION.zip
cd ..

echo "Unpacking source"
rm -fr picovision-$PICOVISION_VERSION
unzip source-v$PICOVISION_VERSION.zip
