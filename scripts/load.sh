#!/usr/bin/env bash

HOURS=$1
DIR=/Volumes/Keys
KEY=$DIR/id_ed25519

if [ -z "$HOURS" ]; then
	HOURS=1
fi

/usr/bin/ssh-add -D
/usr/bin/ssh-add -t "${HOURS}"H $KEY
/usr/sbin/diskutil umount force $DIR
