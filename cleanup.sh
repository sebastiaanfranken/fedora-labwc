#!/usr/bin/env bash

# This script removes "dirty backup" (e.g copy) files from ~ and /etc/
# that are created by the install.sh script.
#
# Be careful with this since it just uses find to find any files that end
# with ".bak" and deletes them.

LANG=C

# shellcheck disable=SC2086
if [[ $(id -u) -gt 0 ]]; then
	echo "Nope. Call this with sudo:"
	echo -e "\tsudo bash $(basename ${0})"
	exit 1
fi

CALLING_USER_ID=$(env | grep ^SUDO_UID | cut -d '=' -f2)
# shellcheck disable=SC2086
CALLING_USER_HOME=$(getent passwd ${CALLING_USER_ID} | awk -F ':' '{print $6}')

# Delete dirty backups from /etc/ first
find /etc/ -name "*.bak" -type f -delete 2>/dev/null

# From ~ second
find "${CALLING_USER_HOME}/.config/" -name "*.bak" -type f -delete 2>/dev/null

exit 0