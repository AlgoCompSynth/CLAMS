#! /bin/bash

set -e

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

echo ""; sleep 2
echo "Installing VSCode"
ls -l ./vscode-repo.deb
sudo apt-get install -y ./vscode-repo.deb
echo ""; sleep 2
echo "You can ignore messages about unsandboxed downloads"
echo "Removing VSCode installer"
rm -f ./vscode-repo.deb

echo ""; sleep 2
echo "Finished!!"
