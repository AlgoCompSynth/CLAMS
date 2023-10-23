#! /bin/bash

set -e

echo "Downloading diagram"
wget -nc \
  "https://cdn.shopify.com/s/files/1/0174/1800/files/picovision_diagram.pdf?v=1696414342" -O picovision_diagram.pdf || true

export PICOVISION_VERSION="1.0.2"
echo "Downloading Python release $PICOVISION_VERSION"
wget -nc \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-examples-v$PICOVISION_VERSION.zip" || true
wget -nc \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-v$PICOVISION_VERSION-micropython.uf2" || true
wget -nc \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-widescreen-v$PICOVISION_VERSION-micropython.uf2" || true
wget -nc \
  "https://github.com/pimoroni/picovision/archive/refs/tags/v$PICOVISION_VERSION.zip" -O source-v$PICOVISION_VERSION.zip || true

echo "Unpacking examples"
rm -fr python-examples; mkdir -p python-examples; cd python-examples
unzip ../pimoroni-picovision-examples-v$PICOVISION_VERSION.zip
cd ..

echo "Unpacking source"
rm -fr picovision-$PICOVISION_VERSION
unzip source-v$PICOVISION_VERSION.zip
