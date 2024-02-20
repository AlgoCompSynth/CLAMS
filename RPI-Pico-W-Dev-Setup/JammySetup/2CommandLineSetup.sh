#! /bin/bash

set -e

echo "Cloning powerlevel10k"
rm -fr $HOME/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k

echo "Downloading patched MesloLG Nerd fonts"
mkdir --parents $HOME/.fonts
pushd $HOME/.fonts
wget -nc -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -nc -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -nc -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -nc -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
popd

echo "Setting configuration files"
mkdir --parents $HOME/.bashrc.d
cp bash_aliases $HOME/.bashrc.d
cp vimrc $HOME/.vimrc
sudo cp vimrc /root/.vimrc
cp zshrc $HOME/.zshrc
cat bash_aliases >> $HOME/.zshrc

echo "Setting git configuration"
git config --global pull.rebase false
git config --global push.default simple
git config --global user.email "znmeb@znmeb.net"
git config --global user.name "M. Edward (Ed) Borasky"

echo "Creating $HOME/.local/bin and $HOME/bin"
mkdir --parents $HOME/.local/bin
mkdir --parents $HOME/bin

echo "Updating package, manual and locate databases"
sudo apt-file update
sudo mandb
sudo updatedb

echo "Finished"
