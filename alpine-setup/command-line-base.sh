#! /bin/bash

set -eu

echo "....Setting up home directory"
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects

echo "....Setting neovim configuration files"
mkdir --parents $HOME/.config
cp -rp nvim $HOME/.config

echo "....Finished"
echo ""
