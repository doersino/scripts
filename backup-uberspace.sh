#!/bin/bash

# This script creates a backup of your Uberspace home folder, as well as your
# websites and MySQL databases. Configure username and server before running.

USERNAME="doersino"
SERVER="draco"
IN="$USERNAME@$SERVER.uberspace.de"
OUT="$HOME/Desktop/backups/uberspace_$(date +%F)"

function echob() {
    BOLD=$(tput bold)
    NORMAL=$(tput sgr0)
    echo "${BOLD}$@${NORMAL}"
}

function abort() {
    echob "Removing MySQL backup..."
    ssh -4 "$IN" "rm all-databases.sql.gz"
    [[ -d "$OUT" ]] && echob "Removing incomplete local backup..." && rm -r "$OUT"
    exit 1
}

XEROX="rsync -avxhz --progress"  # our copying machine, can also be "scp -pr" if there aren't any weird symlinks

[[ -d "$OUT" ]] && echob "You've already made a backup today, no refill for you!" && exit

echob "Performing a backup of $IN to $OUT in..."
echob "...3"
sleep 1
echob "...2"
sleep 1
echob "...1"
sleep 1
echob "LIFTOFF"

trap "abort" INT

STARTTIME=$(date +%s)

echob "Backing up all MySQL databases..."  # see http://www.gehaxelt.in/blog/ueberspace-backupscript/
ssh -4 "$IN" "mysqldump --defaults-file=~/.my.cnf --user=$USERNAME --compact --comments --dump-date --quick --all-databases | gzip > all-databases.sql.gz"

echob "Backing up home directory, including MySQL backup..."
mkdir -p "$OUT/home/$USERNAME"
$XEROX "$IN:/home/$USERNAME" "$OUT/home/"

echob "Backing up web-accessible files..."
mkdir -p "$OUT/var/www/virtual/$USERNAME"
$XEROX "$IN:/var/www/virtual/$USERNAME" "$OUT/var/www/virtual/"

echob "Removing MySQL backup..."
ssh -4 "$IN" "rm all-databases.sql.gz"

ENDTIME=$(date +%s)
TOTALTIMESECONDS=$(($ENDTIME - $STARTTIME))
TOTALTIMEMINUTES=$(($TOTALTIMESECONDS / 60))

echob "Done! Elapsed time: $TOTALTIMEMINUTES minutes"
