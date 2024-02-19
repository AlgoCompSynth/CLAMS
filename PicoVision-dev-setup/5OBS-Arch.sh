#! /bin/bash

echo "Installing OBS Studio"
yay --sync --refresh --needed --noconfirm \
  libfdk-aac \
  libva-intel-driver \
  libva-mesa-driver \
  luajit \
  obs-studio \
  sndio \
  v4l2loopback-dkms

echo "Finished"
