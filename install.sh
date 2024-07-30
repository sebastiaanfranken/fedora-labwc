#!/usr/bin/env bash

# This script transforms a Fedora Minimal install into Fedora Minimal + LabWC.

# Set the script language *first*
LANG=C

# Check if this script is being run by either root or someone
# with sudo privileges.
#
# shellcheck disable=SC2086
if [[ $(id -u) -gt 0 ]]; then
	echo "Nope. Run this with sudo:"
	echo "sudo bash $(basename ${0})"
	exit 1
fi

# This is the name that is used to identify the script in the system journal.
SCRIPTNAME=fedora-labwc

# The calling users' id through sudo
CALLING_USER_ID=$(env | grep ^SUDO_UID | cut -d '=' -f2)

# The calling users' group id through sudo
CALLING_GROUP_ID=$(env | grep ^SUDO_GID | cut -d '=' -f2)

# The calling users' home dir through sudo
# shellcheck disable=SC2086
CALLING_USER_HOME=$(getent passwd ${CALLING_USER_ID} | awk -F ':' '{print $6}')

# Set option(s) passed to DNF
DNFOPTIONS=-y

# These configuration files are applied system wide.
SYSTEMFILES=(
	"/etc/greetd/config.toml"
	"/etc/greetd/environments"
	"/etc/greetd/gtkgreet.css"
	"/etc/greetd/sway-config"
)

# The configuration files are applied user wide.
# shellcheck disable=SC2088
USERFILES=(
	"~/.config/foot/foot.ini"
	"~/.config/kanshi/config"
	"~/.config/labwc/autostart"
	"~/.config/labwc/menu.xml"
	"~/.config/labwc/rc.xml"
	"~/.config/fastfetch/config.jsonc"
	"~/.config/swaylock/config"
	"~/.config/waybar/config.jsonc"
	"~/.config/waybar/style.css"
	"~/.config/htop/htoprc"
	"~/.config/sway/config"
)

# Array of file(s) to ignore
IGNOREFILES=()

if [[ -f "${CALLING_USER_HOME}/.config/${SCRIPTNAME}-ignore-files.conf" ]]; then
	while read -r LINE; do
		IGNOREFILES+=("${LINE}")
	done < "${CALLING_USER_HOME}/.config/${SCRIPTNAME}-ignore-files.conf"
fi

# This function makes it easier to log to the system journal
# while outputting the same message to the screen.
log() {
	systemd-cat -t ${SCRIPTNAME} echo "${1}"
	echo "${1}"
}

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
dnf install labwc greetd greetd-selinux gtkgreet xdg-utils xdg-user-dirs wayland-logout sway foot kanshi pcmanfm fastfetch wl-clipboard htop ${DNFOPTIONS} --setopt=install_weak_deps=False

log "Installing base pacakges batch 2 of 2."
dnf install firefox libreoffice libreoffice-gtk3 eza xed xreader waybar swaylock ${DNFOPTIONS}

# Set 'graphical.target` as the new default runlevel and enable greetd
log "Setting 'graphical.target' as the new default runlevel, and enabling greetd.service."
systemctl set-default graphical.target
systemctl enable greetd.service

# Loop over the SYSTEMFILES array and check if the file mentioned exists.
# If it does and it is mentioned in the IGNOREFILES array the file is ignored.
# If it does and it is *not* mentioned in the IGNOREFILES array the file is (dirty)
# backed up and overwritten.
for SYSTEMFILE in "${SYSTEMFILES[@]}"; do
	if [[ "${IGNOREFILES[*]}" =~ ${SYSTEMFILE} ]]; then
		log "Not processing '${SYSTEMFILE}'. It is listed in '${CALLING_USER_HOME}/.config/${SCRIPTNAME}-ignore-files.conf'."
	else
		DIRNAME=$(dirname "${SYSTEMFILE}")

		log "Processing '${SYSTEMFILE}'."

		# Check if the directory containing the file(s) exists.
		# If it doesn't create it.
		if ! [[ -d "${DIRNAME}" ]]; then
			log "The required directory '${DIRNAME}' does not exist. Creating that."
			mkdir -p "${DIRNAME}"
		fi

		# Check if the file exists. If it does make a dirty backup.
		if [[ -f "${SYSTEMFILE}" ]]; then
			log "The file '${SYSTEMFILE}' is found, making a copy."
			cp "${SYSTEMFILE}" "${SYSTEMFILE}.bak"
		fi

		# Download the file from Github and put it in the right spot.
		curl "https://raw.githubusercontent.com/sebastiaanfranken/fedora-labwc/main/files/${SYSTEMFILE:1}" -o "${SYSTEMFILE}"
	fi
done

# Loop over the USERFILES array and check if the file mentioned exists.
# If it does and it is mentioned in the IGNOREFILES array the file is ignored.
# If it does and it is *not* mentioned in the IGNOREFILES array the file is (dirty)
# backed up and overwritten.
for USERFILE in "${USERFILES[@]}"; do
	if [[ "${IGNOREFILES[*]}" =~ ${USERFILE} ]]; then
		log "Not processing '${USERFILE}'. It is listed in '${CALLING_USER_HOME}/.config/${SCRIPTNAME}-ignore-files.conf'."
	else
		EXPANDED="${CALLING_USER_HOME}/${USERFILE:2}"
		DIRNAME=$(dirname "${EXPANDED}")

		log "Processing '${EXPANDED}'."

		# Check if the directory containing the file(s) exists.
		# If it doesn't create it.
		if ! [[ -d "${DIRNAME}" ]]; then
			log "The required directory '${DIRNAME}' does not exist. Creating that."
			mkdir -p "${DIRNAME}"
		fi

		# Check if the file exists. If it does make a dirty copy.
		if [[ -f "${EXPANDED}" ]]; then
			log "The file '${EXPANDED}' is found, making a copy."
			cp "${EXPANDED}" "${EXPANDED}.bak"
		fi

		# Download the file from Github and put it in the right spot.
		curl "https://raw.githubusercontent.com/sebastiaanfranken/fedora-labwc/main/files/${USERFILE:3}" -o "${EXPANDED}"
	fi
done

# Set the correct user and group ID to the files and folders that were just downloaded
# and created in the users' home dir.
log "Setting the correct user and group ID on the files/folders just downloaded/created."
chown -R "${CALLING_USER_ID}:${CALLING_GROUP_ID}" "${CALLING_USER_HOME}/.config/"

# Process the custom theme and see if the required stuff exists. If it does not, create the
# required folder(s) and download the required file(s) from Github.
if ! [[ -d "${CALLING_USER_HOME}/.local/share/themes/fedora-labwc/openbox-3" ]]; then
	log "The custom theme folder does not exist. Creating it now."
	mkdir -p "${CALLING_USER_HOME}/.local/share/themes/fedora-labwc/openbox-3/"
fi

# Download the themerc for the custom fedora labwc theme even if it exists, overwriting it
log "Downloading the fedora-custom-labwc themerc file."
curl "https://raw.githubusercontent.com/sebastiaanfranken/fedora-labwc/main/files/local/share/themes/fedora-labwc/openbox-3/themerc" -o "${CALLING_USER_HOME}/.local/share/themes/fedora-labwc/openbox-3/themerc"
chown -R "${CALLING_USER_ID}:${CALLING_GROUP_ID}" "${CALLING_USER_HOME}/.local/share/themes/"

# SELinux magic
log "Setting the correct SELinux label(s)"
restorecon -RF "${CALLING_USER_HOME}/.config/"
restorecon -RF "${CALLING_USER_HOME}/.local/share/themes/"

# Done! If everything went according to plan you should now have a labwc install that's customized.
# To see it, reboot the machine now.
log "Done! Reboot the machine now to apply all changes made and to test if everything went as planned."

exit 0
