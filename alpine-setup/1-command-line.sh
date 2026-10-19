#! /bin/sh

set -eu

# References:
# https://wiki.alpinelinux.org/wiki/Eudev
# https://wiki.alpinelinux.org/wiki/How_to_get_regular_stuff_working 
# https://wiki.alpinelinux.org/wiki/MDNS
# https://wiki.alpinelinux.org/wiki/OpenRC_User_Services#User_runlevels
# https://wiki.alpinelinux.org/wiki/Raspberry_Pi
# https://wiki.alpinelinux.org/wiki/Repositories#Upgrading_to_edge
# https://wiki.alpinelinux.org/wiki/Shell_management
# https://github.com/macmpi/alpine-linux-headless-bootstrap

echo "....Setting up home directories"
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects $HOME/.config/rc/runlevels/console

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/command-line.log
echo "" > $LOGFILE

echo "....Switching to edge release with tagged @testing!"
doas cp repositories /etc/apk/repositories

echo "....Upgrading if needed"
doas apk upgrade -vv \
    >> $LOGFILE 2>&1

echo "....Adding packages"
doas apk add -vv \
    apk-tools-doc \
    avahi \
    avahi-doc \
    avahi-tools \
    bash \
    bash-doc \
    bash-completion \
    bash-completion-doc \
    busybox-doc \
    checkbashisms \
    curl \
    curl-doc \
    doas-doc \
    dbus \
    dbus-doc \
    doas-doc \
    drill \
    file \
    font-cascadia-code-nerd \
    git \
    git-doc \
    fennel5.5 \
    fenneljit \
    fennel-doc \
    htop \
    htop-doc \
    ifupdown-ng-doc \
    iw-doc \
    lua5.5 \
    lua5.5-doc \
    luajit \
    luajit-doc \
    lynx \
    lynx-doc \
    man-pages \
    mandoc \
    mandoc-doc \
    mandoc-apropos \
    mkrundir \
    neovim \
    neovim-doc \
    openrc-doc \
    openssh-doc \
    openssl-doc \
    plocate \
    plocate-doc \
    raspberrypi-bootloader-doc \
    ripgrep \
    ripgrep-doc \
    shadow \
    shadow-doc \
    starship \
    time \
    time-doc \
    tmux \
    tmux-doc \
    tree \
    tree-doc \
    wget \
    wget-doc \
    wpa_supplicant-doc \
    xdg-utils \
    xdg-utils-doc \
    >> $LOGFILE 2>&1

echo "....Setting up udev"
doas setup-devd udev

echo ""
echo "....Setting up services for next reboot"
doas rc-update add avahi-daemon
doas rc-service avahi-daemon start
doas rc-update add dbus
doas rc-service dbus start
echo ""

echo "....Changing $USER shell to /bin/bash"
doas chsh --shell "/bin/bash" $USER

echo "....Setting startup dotfiles"
if [ "$(grep 'end startup code' $HOME/.profile 2> /dev/null | wc -l)" = "0" ]
then
    echo "....Appending startup code to $HOME/.profile"
    cat startup-code.sh >> $HOME/.profile

fi

if [ "$(grep 'end bash aliases' $HOME/.bashrc 2> /dev/null | wc -l)" = "0" ]
then
    echo "....Appending bash aliases to $HOME/.bashrc"
    cat bash-aliases.sh >> $HOME/.bashrc

fi

echo "....Setting neovim configuration files"
mkdir --parents $HOME/.config
cp -rp nvim $HOME/.config

echo "....Setting tmux configuration file"
cp tmux.conf $HOME/.tmux.conf

echo "....Setting starship configuration file"
cp starship.toml $HOME/.config/

if [ "$(grep starship $HOME/.bashrc | wc -l)" = "0" ]
then
  echo "....Appending starship init to $HOME/.bashrc"
  echo "" >> $HOME/.bashrc
  echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

fi

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo ""
echo ""
echo "....Command line setup complete - reboot!"

echo "....Finished"
echo ""
