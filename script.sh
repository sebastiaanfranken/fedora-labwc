#!/usr/bin/bash

# This script transforms a Fedora Minimal install into Fedora Minimal + LabWC.

# This is the name that is used to identify the script in the system journal.
SCRIPTNAME=fedora-labwc

# The calling users' id through sudo
CALLING_USER_ID=$(env | grep ^SUDO_UID | cut -d '=' -f2)

# The calling users' group id through sudo
CALLING_GROUP_ID=$(env | grep ^SUDO_GID | cut -d '=' -f2)

# The calling users' home dir through sudo
CALLING_USER_HOME=$(getent passwd ${CALLING_USER_ID} | awk -F ':' '{print $6}')

# Set the script language
LANG=C

# Set option(s) passed to DNF
DNFOPTIONS="-y"

# This function makes it easier to log to the system journal
# while outputting the same message to the screen.
log() {
	systemd-cat -t ${SCRIPTNAME} echo "${1}"
	echo "${1}"
}

# Check if this script is being run by either root or someone
# with sudo privileges.
if [[ $(id -u) -gt 0 ]]; then
	echo "Nope. Run this with sudo:"
	echo "sudo bash $(basename ${0})"
	exit 1
fi

# Install VIM. Nano sucks.
log "Installing VIM."
dnf install vim ${DNFOPTIONS}

# Swap nano-default-editor for vim-default-editor so VIM becomes
# the system default editor.
log "Swapping nano-default-editor for vim-default-editor"
dnf swap nano-default-editor vim-default-editor ${DNFOPTIONS}

# This gets split into two batches because the first one has
# --setopt=install_weak_deps=False added to teh DNF options.
log "Installing base packages batch 1 of 2."
dnf install labwc greetd greetd-selinux gtkgreet xdg-utils xdg-user-dirs wayland-logout sway foot kanshi pcmanfm fastfetch wl-clipboard ${DNFOPTIONS} --setopt=install_weak_deps=False

log "Installing base pacakges batch 2 of 2."
dnf install firefox libreoffice libreoffice-gtk3 eza xed xreader waybar

# Set 'graphical.target` as the new default runlevel and enable greetd
log "Setting 'graphical.target' as the new default runlevel, and enabling greetd.service."
systemctl set-default graphical.target
systemctl enable greetd.servvice

# Make a backup of the existing file '/etc/greetd/config.toml'
log "Making a backup of '/etc/greetd/config.toml' to '/etc/greetd/config.toml.bak'."
cp /etc/greetd/config.toml /etc/greetd/config.toml.bak

# Get the new version from the repo.
log "Downloading custom version of '/etc/greetd/config.toml'."
curl https://raw.githubusercontent.com/sebastiaanfranken/fedora-labwc/main/files/etc/greetd/config.toml -o /etc/greetd/config.toml

# Make a backup of the existing file '/etc/greetd/environments'
log "Making a backup of '/etc/greetd/environments' to '/etc/greetd/environments.bak'."
cp /etc/greetd/environments /etc/greetd/environments.bak

# Get the new version from the repo
log "Downloading custom version of '/etc/greetd/environments'."
curl https://raw.githubusercontent.com/sebastiaanfranken/fedora-labwc/main/files/etc/greetd/environments -o /etc/greetd/environments

# Get the custom file '/etc/greetd/gtkgreet.css' from the repo
log "Downloading custom file '/etc/greetd/gtkgreet.css'."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/etc/greetd/gtkgreet.css -o /etc/greetd/gtkgreet.css

# Get the custom file '/etc/greetd/sway-config' from the repo
log "Downloading custom file '/etc/greetd/sway-config'."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/etc/greetd/sway-config -o /etc/greetd/sway-config

# Get the custom file '~/.config/foot/foot.ini' from the repo. Create the folder
# for it first, though
log "Creating the '~/.config/foot' folder and downloading the '~/.config/foot/foot.ini' file."
mkdir -p "${CALLING_USER_HOME}/.config/foot/"
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/foot/foot.ini -o "${CALLING_USER_HOME}/.config/foot/foot.ini"

# Get the custom file '~/.config/kanshi/config' from the repo. Create the folder
# for it first, though.
log "Creating the '~/.config/kanshi/' folder and downloading the '~/.config/kanshi/config' file."
mkdir -p "${CALLING_USER_HOME}/.config/kanshi/"
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/kanshi/config -o "${CALLING_USER_HOME}/.config/kanshi/config"

# Create the '~/.config/labwc/` folder first since there are a few files that
# need to get downloaded to it.
log "Creating the '~/.config/labwc/' folder."
mkdir -p "${CALLING_USER_HOME}/.config/labwc/"

# Get the custom file '~/.config/labwc/autostart' from the repo.
log "Downloading the '~/.config/labwc/autostart' file."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/labwc/autostart -o "${CALLING_USER_HOME}/.config/labwc/autostart"

# Get the custom file '~/.config/labwc/menu.xml' from the repo.
log "Downloading the '~/.config/labwc/menu.xml' file."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/labwc/autostart -o "${CALLING_USER_HOME}/.config/labwc/menu.xml"

# Get the custom file '~/.config/labwc/rc.xml' from the repo.
log "Downloading the '~/.config/labwc/rc.xml' file."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/labwc/autostart -o "${CALLING_USER_HOME}/.config/labwc/rc.xml"

# Get the custom file '~/.config/fastfetch/config.jsonc` from the repo. Create the folder
# for it first, though.
log "Creating the '~/.config/fastfetch' folder and downloading the '~/.config/fastfetch/config.jsonc' file."
mkdir -p "${CALLING_USER_HOME}/.config/fastfetch/"
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/fastfetch/config.jsonc -o "${CALLING_USER_HOME}/.config/fastfetch/config.jsonc"

# Get the custom file '~/.config/swaylock/config` from the repo. Create the fodler
# for it first, though.
log "Creating the '~/.config/swaylock' folder and downloading the '~/.config/swaylock/config' file."
mkdir -p "${CALLING_USER_HOME}/.config/swaylock/"
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/swaylock/config -o "${CALLING_USER_HOME}/.config/swaylock/config"

# Create the '~/.config/waybar/' folder first since there are a few files that
# need to get downloaded to it.
log "Creating the '~/.config/waybar/' folder."
mkdir -p "${CALLING_USER_HOME}/.config/waybar/"

# Get the custom file '~/.config/waybar/config.jsonc' from the repo.
log "Downloading the '~/.config/waybar/config.jsonc' file."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/waybar/config.jsonc -o "${CALLING_USER_HOME}/.config/waybar/config.jsonc"

# Get the custom file '~/.config/waybar/style.css' from the repo.
log "Downloading the '~/.config/waybar/style.css' file."
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/config/waybar/style.css -o "${CALLING_USER_HOME}/.config/waybar/style.css"

# Set the correct owner and group to the just created files and folders.
log "Setting correct owner and group to files and folders just created in '~/.config/'."
chown -R ${CALLING_USER_ID}:${CALLING_GROUP_ID} "${CALLING_USER_HOME}/.config/"
restorecon -RF "${CALLING_USER_HOME}/.config(/.*)"

# Get the custom theme file '~/.local/share/themes/fedora-labwc/openbox-3/themerc' from the repo.
log "Creating the '~/.local/share/themes/fedora-labwc/openbox-3/' folder and downloading the '~/.local/share/themes/fedora-labwc/openbox-3/themerc' file."
mkdir -p "${CALLING_USER_HOME}/.local/share/themes/fedora-labwc/openbox-3/"
curl https://github.com/sebastiaanfranken/fedora-labwc/raw/main/files/local/share/themes/fedora-labwc/openbox-3/themerc -o "${CALLING_USER_HOME}/.local/share/themes/fedora-labwc/openbox-3/themerc"

# Set the correct owner and group to the just created files and folders.
log "Setting correct owner and group to files and folders just created in '~/.local/share/themes/'."
chown -R ${CALLING_USER_ID}:${CALLING_GROUP_ID} "${CALLING_USER_HOME}/.local/share/themes/"
restorecon -RF "${CALLING_USER_HOME}/.local/share/themes(/.*)"

# Everything has been installed and configured. Reboot to apply the changes.
log "Everything has been installed and configured. Reboot to apply the changes."

exit 0