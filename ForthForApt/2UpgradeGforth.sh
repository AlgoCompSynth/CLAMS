#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/2UpgradeGforth.log

echo "Git preparation"
./gforth-git-prep.sh \
  >> $LOGFILE 2>&1
echo "Build from scratch"
./gforth-git-make.sh \
  >> $LOGFILE 2>&1
echo "Install to /usr/local"
./gforth-git-install.sh \

echo "Finished"
