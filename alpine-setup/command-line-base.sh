#! /bin/sh

set -eu

echo "....Setting up home directory"
# https://wiki.alpinelinux.org/wiki/OpenRC_User_Services#User_runlevels
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects $HOME/.config/rc/runlevels/console

echo "....Setting startup dotfiles"
cat profile >> $HOME/.profile

if [ "$(grep 'end aliases' $HOME/.bashrc 2> /dev/null | wc -l)" = "0" ]
then

echo "....Appending aliases to $HOME/.bashrc"
cat << ALIASES_END >> $HOME/.bashrc

# begin aliases

# workaround for ghostty clients
if [ "\$TERM" = "xterm-ghostty" ]
then
  export TERM="xterm-256color"

fi

alias l='ls -CF --color=auto'
alias ll='ls -Fltr'
alias la='ls -FAltr'
alias vi=nvim
alias vim=nvim

export EDITOR=nvim
export VISUAL=nvim

# end aliases

ALIASES_END

fi

echo "....Setting neovim configuration files"
mkdir --parents $HOME/.config
cp -rp nvim $HOME/.config

echo "....Setting starship configuration file"
cp starship.toml $HOME/.config/

if [ "$(grep starship $HOME/.bashrc | wc -l)" = "0" ]
then
  echo "....Appending starship init to $HOME/.bashrc"
  echo "" >> $HOME/.bashrc
  echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

fi

echo "....Changing $USER shell to /bin/bash"
doas chsh --shell "/bin/bash" $USER

echo "....Finished"
echo ""
