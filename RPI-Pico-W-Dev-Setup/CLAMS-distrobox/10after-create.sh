#! /bin/bash

set -e

echo "Defining locale"
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export ARCH=`uname -m`
if [ $ARCH == "aarch64" ]
then
  echo "Downloading $ARCH VSCode installer"
  curl -sL "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64" > vscode-repo.deb
elif [ $ARCH == "x86_64" ]
then
  echo "Downloading $ARCH VSCode installer"
  curl -sL "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > vscode-repo.deb
else
  echo "$ARCH: Unknown architecture - exiting with error -1024!!"
  exit -1024
fi

echo "Installing VSCode"
sudo apt install ./vscode-repo.deb
echo "Removing VSCode installer"
rm -f ./vscode-repo.deb
