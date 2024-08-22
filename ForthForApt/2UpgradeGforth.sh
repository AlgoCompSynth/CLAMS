#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/2UpgradeGforth.log

echo "Preparing git repo"
./gforth-git-prep.sh \
  >> $LOGFILE 2>&1
echo "Building from scratch"
./gforth-git-make.sh \
  >> $LOGFILE 2>&1
echo "Installing to /usr/local"
./gforth-git-install.sh \

echo "Finished"
