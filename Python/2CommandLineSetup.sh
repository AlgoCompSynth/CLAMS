#! /bin/bash

set -e

echo "Cloning powerlevel10k"
rm -fr $HOME/powerlevel10k*
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k-media.git $HOME/powerlevel10k-media

echo "Downloading patched MesloLG Nerd fonts"
mkdir --parents $HOME/.fonts
pushd $HOME/.fonts
cp $HOME/powerlevel10k-media/*.ttf .
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
git config --global user.email "znmeb@znmeb.net"
git config --global user.name "M. Edward (Ed) Borasky"

echo "Creating $HOME/.local/bin and $HOME/bin"
mkdir --parents $HOME/.local/bin
mkdir --parents $HOME/bin

echo "Finished"
