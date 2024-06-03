#! /usr/bin/env bash

set -e

echo ""
./upgrades.sh

echo "Creating $HOME/.local/bin and $HOME/bin"
mkdir --parents $HOME/.local/bin
mkdir --parents $HOME/bin

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
cp bashrc $HOME/.bashrc
cp bash_aliases $HOME/.bash_aliases
cp vimrc $HOME/.vimrc
cp zshrc $HOME/.zshrc
cp p10k.zsh $HOME/.p10k.zsh

echo "Setting git configuration"
git config --global pull.rebase false
git config --global push.default simple

echo "Finished"
