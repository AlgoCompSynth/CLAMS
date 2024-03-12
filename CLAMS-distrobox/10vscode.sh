#! /bin/bash

set -e

echo "Setting bash aliases"
cat bash_aliases >> $HOME/.bash_aliases
source $HOME/.bash_aliases

echo "Upgrading Linux"
sudo apt-get update -qq && sudo apt-get upgrade -qqy
sudo apt-get -qqy autoremove

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
ls -l ./vscode-repo.deb
sudo apt-get install -y ./vscode-repo.deb
echo "You can ignore messages about unsandboxed downloads"
echo "Removing VSCode installer"
rm -f ./vscode-repo.deb

echo "Restart bash to activate aliases"
echo "Finished!!"
