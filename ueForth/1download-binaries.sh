#! /bin/bash

set -e

echo "Downloading raw files"
curl -sOL https://eforth.storage.googleapis.com/releases/ESP32forth-7.0.6.19.zip
curl -sOL https://eforth.storage.googleapis.com/releases/ESP32forth-7.0.5.4.zip
curl -sOL https://eforth.storage.googleapis.com/releases/ESP32forth-7.0.7.18.zip
curl -sOL https://eforth.storage.googleapis.com/releases/ueforth-pico-ice-7.0.7.18.zip
curl -sOL https://eforth.storage.googleapis.com/releases/ueforth-7.0.6.19.linux
curl -sOL https://eforth.storage.googleapis.com/releases/ueforth-7.0.5.4.linux
curl -sOL https://eforth.storage.googleapis.com/releases/ueforth-7.0.7.18.linux

echo "Making Linux files executable"
chmod +x *.linux

echo "Unpacking beta pico-ice firmware"
rm -fr pico-ice; mkdir pico-ice; cd pico-ice
unzip -o ../ueforth-pico-ice-7.0.7.18.zip; cd ..

echo "Unpacking beta ESP32forth"
rm -fr ESP32forth; mkdir ESP32forth; cd ESP32forth
unzip -o ../ESP32forth-7.0.7.18.zip; cd ..

echo "Finished!"
