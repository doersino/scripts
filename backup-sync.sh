#!/bin/bash

# Performs a verbose rsync with predefined flags, configurable default
# arguments, only the most important options (dry-run, (even more) increased
# verbosity, and excludes), and sanity checking.
#
# Usage:
# ./backup-sync.sh [-n] [-v] [-e EXCLUDE] [-f FLAGS] [-d] [SRC] [DEST]
#
# (If SRC or DEST are not given, the defaults will be used.)
#
# Options:
# -n	dry run
# -v	verbose (equivalent to the rsync flags "--progress --stats")
# -e	exclude pattern (multiple -e options possible)
# -f	additional rsync options
# -d	debug :)
#
# Exit codes:
# 0-100: rsync exit codes
# 101: User failed to confirm rsync
# 102: SRC or DEST does not exist or is not a directory

# config
FLAGS="-xavh --delete --exclude-from=$(dirname $0)/backup-sync-exclude.txt"
DEFAULT_SRC="/Volumes/one/"
DEFAULT_DEST="/Volumes/two/"

# handle options and arguments
DRYRUN=""
EXCLUDE=""
FLAGS2=""
DEBUG=0

while [ "${1:0:1}" = "-" ]; do
	if [ "$1" = "-n" ]; then
		DRYRUN="-n"
		shift
	fi
	if [ "$1" = "-v" ]; then
		FLAGS="$FLAGS --progress --stats"
		shift
	fi
	if [ "$1" = "-e" ]; then
		EXCLUDE="$EXCLUDE--exclude $2 "
		shift 2
	fi
	if [ "$1" = "-f" ]; then
		FLAGS2="$2 "
		shift 2
	fi
	if [ "$1" = "-d" ]; then
		DEBUG=1
		shift
	fi
done

if [ "$#" -eq 2 ]; then
	SRC="$1"
	DEST="$2"
else
	SRC="$DEFAULT_SRC"
	DEST="$DEFAULT_DEST"
fi

# print debug info
if [ "$DEBUG" -eq 1 ]; then
	echo "DRYRUN=$DRYRUN"
	echo "EXCLUDE=$EXCLUDE"
	echo "FLAGS2=$FLAGS2"
	echo "SRC=$SRC"
	echo "DEST=$DEST"
	echo rsync $DRYRUN $FLAGS $EXCLUDE$FLAGS2"$SRC" "$DEST"
	echo
fi

# check if both source and destination exist and are directories
[ ! -d "$SRC" ] && printf "\e[1;30m$SRC\e[0m is not a directory.\n" >&2
[ ! -d "$DEST" ] && printf "\e[1;30m$DEST\e[0m is not a directory.\n" >&2
{ [ ! -d "$SRC" ] || [ ! -d "$DEST" ]; } && exit 102

# confirm action
printf "About to perform a" >&2
[ -n "$DRYRUN" ] && printf " \e[1;30mdry-run\e[0m " >&2 || printf "n " >&2
printf "rsync " >&2
{ [ -n "$EXCLUDE" ] || [ -n "$FLAGS2" ]; } && printf "with additional options \e[1;30m$EXCLUDE$FLAGS2\e[0m" >&2
printf "from \e[1;30m$SRC\e[0m to \e[1;30m$DEST\e[0m.\n" >&2
read -p "Continue (y/N)? "
[ "$REPLY" = "y" ] || exit 101

# rsync, do your thing
rsync $DRYRUN $FLAGS $EXCLUDE$FLAGS2"$SRC" "$DEST"
exit $?
