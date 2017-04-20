#!/bin/sh

SCRIPTS_DIR="/usr/local/etc/pisound"
BACKUP_DIR="/usr/local/etc/pisound-backups/"`date +"%F.%T"`

if test -e $SCRIPTS_DIR && [ -n "$(ls -A $SCRIPTS_DIR)" ] ; then
	echo "Backing up scripts in $SCRIPTS_DIR to $BACKUP_DIR"
	mkdir -p $BACKUP_DIR
	if test -e $SCRIPTS_DIR/backups; then
		echo "Migrating $SCRIPTS_DIR/backups to $BACKUP_DIR"
		mv $SCRIPTS_DIR/backups/* $BACKUP_DIR/
		rm -r $SCRIPTS_DIR/backups/
	fi
	mv $SCRIPTS_DIR/* $BACKUP_DIR/
fi

mkdir -p $SCRIPTS_DIR
cp -pR $(dirname $(readlink -f $0))/pisound-btn/* $SCRIPTS_DIR
