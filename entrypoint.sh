#!/bin/sh
# vim: set noet :

##############################################################################
# Default
##############################################################################

if [ -z "${ABUILD_UID}" ]; then
	ABUILD_UID=1000
fi
if [ -z "${ABUILD_GID}" ]; then
	ABUILD_GID=1000
fi

##############################################################################
# Check
##############################################################################

if echo -n "${ABUILD_UID}" | grep -Eqsv '^[0-9]+$'; then
	echo "ABUILD_UID: '${ABUILD_UID}'"
	echo 'Please numric value: ABUILD_UID'
	exit 1
fi
if [ "${ABUILD_UID}" -le 0 ]; then
	echo "ABUILD_UID: '${ABUILD_UID}'"
	echo 'Please 0 or more: ABUILD_UID'
	exit 1
fi
if [ "${ABUILD_UID}" -ge 60000 ]; then
	echo "ABUILD_UID: '${ABUILD_UID}'"
	echo 'Please 60000 or less: ABUILD_UID'
	exit 1
fi

if echo -n "${ABUILD_GID}" | grep -Eqsv '^[0-9]+$'; then
	echo "ABUILD_GID: '${ABUILD_GID}'"
	echo 'Please numric value: ABUILD_GID'
	exit 1
fi
if [ "${ABUILD_GID}" -le 0 ]; then
	echo "ABUILD_GID: '${ABUILD_GID}'"
	echo 'Please 0 or more: ABUILD_GID'
	exit 1
fi
if [ "${ABUILD_GID}" -ge 60000 ]; then
	echo "ABUILD_GID: '${ABUILD_GID}'"
	echo 'Please 60000 or less: ABUILD_GID'
	exit 1
fi

##############################################################################
# Clear
##############################################################################

if getent passwd | awk -F ':' -- '{print $1}' | grep -Eqs '^builder$'; then
	deluser 'builder'
fi
if getent passwd | awk -F ':' -- '{print $3}' | grep -Eqs "^${ABUILD_UID}$"; then
	deluser "${ABUILD_UID}"
fi
if getent group | awk -F ':' -- '{print $1}' | grep -Eqs '^builder$'; then
	delgroup 'builder'
fi
if getent group | awk -F ':' -- '{print $3}' | grep -Eqs "^${ABUILD_GID}$"; then
	delgroup "${ABUILD_GID}"
fi

##############################################################################
# Group
##############################################################################

addgroup -g "${ABUILD_GID}" 'builder'

##############################################################################
# User
##############################################################################

adduser -u "${ABUILD_UID}" -G 'abuild' -h '/builder' -D 'builder'

##############################################################################
# Initialize
##############################################################################

su - builder -c 'abuild-keygen -a -n -q'

chown -R 'builder:builder' '/builder/.abuild'
chown -R 'builder:builder' '/builder/aports'
chown -R 'builder:builder' '/builder/packages'
chown -R 'builder:builder' '/var/cache/distfiles'

##############################################################################
# Builing
##############################################################################

if [ "$1" = 'abuild' ]; then
	set -e
	exec su - builder -c abuild
fi

exec su - builder -c "$@"
