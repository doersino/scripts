#!/bin/bash

# http://neondust.tumblr.com/post/97723922505/simple-tumblr-backup-script-for-mac-os-x-and-linux
# https://gist.github.com/doersino/7e3e5db591e42bf543e1

# BLOGS is a space-separated list of the blogs you want to backup. You can omit
# the ".tumblr.com" part if you want.
BLOGS="neondust.tumblr.com aufgeloest.tumblr.com hejlisten.tumblr.com animesignage.tumblr.com animerrrrrrrroll.tumblr.com gerhardgundermann.tumblr.com apleasantflight.tumblr.com forgotten.tumblr.com"
# OUT is the directory where the backups will be stored. For each blog, a date-
# suffixed subdirectory will be created here.
OUT="$HOME/Desktop/backups"
# TEMP is the directory where the required software will be cached. It will be
# created and removed automatically.
TEMP="$OUT/.backup-tumblr-temp"
# OPTIONS is a space-separated list of options passed to tumblr_backup.py for
# all blogs. This feature is intended for experienced users. Refer to
# https://github.com/bbolli/tumblr-utils/blob/master/tumblr_backup.md#options
# for a listing of all options or take a look at these examples:
# Only backup the newest 42 posts: --count=42
# Only backup posts from the current year: --period=y
# Backup a password-protected (private) blog: --private=YOUR_PASSWORD_HERE
# Only backup posts tagged "selfie": --tags=selfie
# Only backup posts tagged "trek", "wars" or "gate": --tags=trek,wars,gate
# Only backup text posts: --type=text
# Only backup video and audio posts: --type=video,audio
OPTIONS=""
# Everything below this line should just work™.

# the cleanup function needs to be defined at the top so we can call it whenever
# the user chooses to abort
function tb_clean_up {
	printf "Cleaning up... "
	rm -r "$TEMP"
	printf "done\n"
	exit $1
}

# setup
printf "Setting environment up... "
trap "tb_clean_up 1" INT
PATH=$TEMP:$PATH
PYTHONPATH=$TEMP:$PYTHONPATH
printf "done\n"

# download required software
printf "Downloading required software... "
mkdir -p $TEMP
if [ -n $(command -v curl) ]; then
	curl -sS "https://raw.githubusercontent.com/bbolli/xmltramp/master/xmltramp.py" > "$TEMP/xmltramp.py"
	curl -sS "https://raw.githubusercontent.com/bbolli/tumblr-utils/master/tumblr_backup.py" > "$TEMP/tumblr_backup"
else
	wget -qP "$TEMP/" "https://raw.githubusercontent.com/bbolli/xmltramp/master/xmltramp.py"
	wget -qO "$TEMP/tumblr_backup" "https://raw.githubusercontent.com/bbolli/tumblr-utils/master/tumblr_backup.py"
fi
chmod 744 "$TEMP/tumblr_backup"
printf "done\n"

# this is where the magic happens
for BLOG in $BLOGS; do
	if [ -n "$OPTIONS" ]; then
		tumblr_backup $OPTIONS --outdir "$OUT/$BLOG"_$(date +%F) $BLOG
	else
		tumblr_backup --outdir "$OUT/$BLOG"_$(date +%F) $BLOG
	fi
done

# clean up
tb_clean_up 0
