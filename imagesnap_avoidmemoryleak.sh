#!/bin/bash

# Avoids the memory leak occuring when capturing many webcam pictures using
# imagesnap version 0.2.5 by regularly restarting the command.
#
# As a result, the interval between successive pictures is not always exactly as
# specified in $IMAGESNAP_CONFIG. To get as close to it as possible, set
# $RESTART_INTERVAL to some multiple of the -t interval.
# By default, imagesnap is configured to wait 1s before taking the first
# picture: without this delay, the first picture tends to be underexposed.
#
# Usage: Execute this bash script. Any parameters will be passed to imagesnap.
# The -t and -w flags are already set to sensible values below, but can be
# overridden when calling this script.

CAPTURE_INTERVAL="2.5"
RESTART_INTERVAL="15"

IMAGESNAP_PATH="$(which imagesnap)"
IMAGESNAP_CONFIG="-t $CAPTURE_INTERVAL -w 1 $@"

# ------------------------------------------------------------------------------

# Create temp directory
if [ ! -d "imagesnap_avoidmemoryleak_temp" ]; then
	mkdir "imagesnap_avoidmemoryleak_temp"
fi
cd "imagesnap_avoidmemoryleak_temp"

# Renames and moves pictures sequentially depending on $COUNTER, and increments
# $COUNTER. This should only be called in the temp directory after an imagesnap
# process terminates
function imagesnap_avoidmemoryleak_rename {
	for SOURCE in snapshot*; do
		DATESTRING=${SOURCE:14}
		TARGET="../snapshot-$(printf %05d ${COUNTER%.*})$DATESTRING"

		mv "$SOURCE" "$TARGET"
		let COUNTER="$COUNTER+1"
	done
}

# When the user exits, this makes sure the current imagesnap process is killed,
# the remaining pictures in the temp directory are renamed and moved properly,
# and the temp directory is removed
function imagesnap_avoidmemoryleak_cleanup {
	echo "Exiting..."
	kill $IMAGESNAP_PID
	imagesnap_avoidmemoryleak_rename
	cd ..
	rmdir "imagesnap_avoidmemoryleak_temp"
	exit
}
trap "imagesnap_avoidmemoryleak_cleanup" INT

# Main loop
COUNTER="0"
while true; do
	# Start a background imagesnap process and kill it after a while
	"$IMAGESNAP_PATH" $IMAGESNAP_CONFIG &
	IMAGESNAP_PID=$!
	sleep "$RESTART_INTERVAL"
	kill $IMAGESNAP_PID
	wait $IMAGESNAP_PID 2>/dev/null # hide termination messages

	# Rename and move captured images
	imagesnap_avoidmemoryleak_rename
done
