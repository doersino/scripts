#!/bin/bash

# http://www.reddit.com/r/spacex/comments/2pwjni/live_video_of_asds_in_port/cn19n2i?context=7
# https://gist.github.com/doersino/ade1edd8fe154ea30ba4
#
# This script downloads a webcam image to a date/hour-labeled directory,
# creating intermediate directories as required, making sure that the image is
# not corrupt, and optionally overlaying the current date and time on the image
# and maintaining a mirror of the webcam. Any images from the previous day will
# optionally be ZIP-compressed and compiled into a MP4 video after the first
# download of each day.
#
# The output is quite verbose for debugging purposes, so you may want to discard
# it by appending >/dev/null 2>&1 to the call.
#
# Run this script either
# * manually whenever you want to download the current webcam image,
# * in a bash loop (e.g. while sleep 30; do bash webcam_dl.sh; done),
# * or, especially for long-term monitoring, with cron (keep in mind that cron
#   can only run a command once per minute or less frequently) or runwhen.
#
# Tested on Mac OS X and CentOS.
#
# Dependencies:
# * Required: curl, grep, zip
# * Optional: jpeginfo, imagemagick (identify, mogrify), ghostscript, ffmpeg
#     * if found, jpeginfo will be used to detect corrupt images if FILE_EXT is
#       either "jpg" or "jpeg", otherwise identify will be used
#     * if neither jpeginfo nor identify can be found, corrupt images won't be
#       detected and removed
#     * if mogrify can't be found or isn't configured to work with ghostscript,
#       images won't be annotated with the current date and time
#     * if ffmpeg can't be found, no video will be created
#
# In case you're considering using this to spy on somebody: please don't.

# BEGIN CONFIG -----------------------------------------------------------------

WEBCAM_URL="http://www.centennialbulb.org/ctbulb.jpg"
APPEND_TIMESTAMP=1  # try to fool potential server-side caching? (1: determine
                    # whether to use ? or & as delimiter automatically, 0: don't
                    # append timestamp, string: use the value assigned to this
                    # variable as delimiter)
CURL_FLAGS=""       # useful if the webcam requires a particular --referer

BASE_DIR="$HOME"                       # no trailing slash!
#FILENAME=$(date +%Y-%m-%dT%H:%M:%SZ)  # ISO 8601
FILENAME=$(date +%s)                   # UNIX timestamp
FILE_EXT="jpg"                         # whatever image format the webcam outputs
JPEGINFO_PATH=$(which jpeginfo)        # path of jpeginfo executable
IDENTIFY_PATH=$(which identify)        # path of imagemagick's identify executable

OVERLAY_TIME=1                 # overlay the current date and time on each webcam image?
MOGRIFY_PATH=$(which mogrify)  # path of imagemagick's mogrify executable

COPY_TO_BASE_DIR=1  # copy the latest webcam image to BASE_DIR/latest.FILE_EXT,
                    # essentially creating a mirror of the webcam?

COMPRESS=1                   # create daily ZIP archive and MP4 video of yesterday's images?
FFMPEG_PATH=$(which ffmpeg)  # path of ffmpeg executable
VIDEO_FPS=24                 # framerate of the generated video

# END CONFIG -------------------------------------------------------------------

function echo_debug {
	echo -e "\033[1;34m$1\033[0m" # bold/blue
}

function download_image {
	URL="$WEBCAM_URL"
	if [ "$APPEND_TIMESTAMP" = "1" ]; then
		if grep -q '?' <<< "$URL"; then # determine if we need to prepend ? or &
			URL="$URL"'&'
		else
			URL="$URL"'?'
		fi
		URL="$URL$(date +%s)"
	elif [ "$APPEND_TIMESTAMP" != "0" ]; then
		URL="$URL$APPEND_TIMESTAMP$(date +%s)"
	fi

	echo_debug "Downloading $URL to $FILE..."
	curl $CURL_FLAGS "$URL" > "$FILE"
}

DAY=$(date -u +"%Y-%m-%d")
HOUR=$(date -u +"%H")

# create directory BASE_DIR/YYYY-MM-DD/HH if not exists
if [ ! -d "$BASE_DIR/$DAY/$HOUR" ]; then
	echo_debug "Creating directory $BASE_DIR/$DAY/$HOUR..."
	mkdir -p "$BASE_DIR/$DAY/$HOUR"
fi

# download image
FILE="$BASE_DIR/$DAY/$HOUR/$FILENAME.$FILE_EXT"
download_image

# check if the downloaded image is corrupt using either jpeginfo or identify and
# retry if neccessary - if the second try isn't successful either, remove the
# image in order to not upset ffmpeg later on
if [ -e "$JPEGINFO_PATH" ] && { [ "$FILE_EXT" = "jpg" ] || [ "$FILE_EXT" = "jpeg" ]; }; then
	if ! "$JPEGINFO_PATH" -c "$FILE" >/dev/null 2>&1; then
		echo_debug "Downloaded image is likely corrupt (jpeginfo). Sleeping 2s and retrying..."
		sleep 2
		download_image
	fi
	if ! "$JPEGINFO_PATH" -c "$FILE" >/dev/null 2>&1; then
		echo_debug "Downloaded image is likely corrupt (jpeginfo). Removing corrupt image..."
		rm "$FILE"
	fi
elif [ -e "$IDENTIFY_PATH" ]; then
	if [ $("$IDENTIFY_PATH" -verbose "$FILE" 2>&1 >/dev/null | wc -l) -ge 1 ]; then
		echo_debug "Downloaded image is likely corrupt (identify). Sleeping 2s and retrying..."
		sleep 2
		download_image
	fi
	if [ $("$IDENTIFY_PATH" -verbose "$FILE" 2>&1 >/dev/null | wc -l) -ge 1 ]; then
		echo_debug "Downloaded image is likely corrupt (identify). Removing corrupt image..."
		rm "$FILE"
	fi
fi

# if the image is empty, remove it in order to not upset ffmpeg later on
if [ -e "$FILE" ] && [ "$(du -k "$FILE" | cut -f1)" -eq 0 ]; then
	echo_debug "Downloaded image is empty. Removing empty image..."
	rm "$FILE"
fi

# overlay the current date and time on the image
if [ "$OVERLAY_TIME" -eq 1 ] && [ -e "$MOGRIFY_PATH" ] && [ -e "$FILE" ]; then
	echo_debug "Overlaying the current date and time on downloaded image..."
	"$MOGRIFY_PATH" -fill black -draw "rectangle 0,0 223,15" -fill white -gravity NorthWest -font Courier -pointsize 15 -annotate +8+2 "$(date -u +'%Y-%m-%d %H:%M:%S') UTC" "$FILE"
fi

# create a mirror of the webcam
if [ "$COPY_TO_BASE_DIR" -eq 1 ] && [ -e "$FILE" ]; then
	echo_debug "Copying the downloaded image to $BASE_DIR/latest.$FILE_EXT"
	\cp "$FILE" "$BASE_DIR/latest.$FILE_EXT"
fi

# create ZIP archive and MP4 video of yesterday's images if there are any (and
# the ZIP archive doesn't already exist)
if [ "$COMPRESS" -eq 1 ]; then
	if [ "$(uname)" = "Darwin" ]; then
		YESTERDAY=$(date -j -v-1d -f "%Y-%m-%d" $DAY "+%Y-%m-%d") # Mac OS X
	else
		YESTERDAY=$(date -u +"%Y-%m-%d" -d "yesterday") # most Linux distributions
	fi
	if [ ! -e "$BASE_DIR/$YESTERDAY.zip" ] && [ -d "$BASE_DIR/$YESTERDAY" ]; then
		echo_debug "Creating ZIP archive of yesterday's images: $BASE_DIR/$YESTERDAY.zip..."
		cd "$BASE_DIR"
		\zip "$YESTERDAY.zip" "$YESTERDAY" # "touch" the ZIP archive
		zip -rv "$YESTERDAY.zip" "$YESTERDAY"

		# TODO this works, but it could *really* use some refactoring
		if [ -e "$FFMPEG_PATH" ]; then
			echo_debug "Creating $VIDEO_FPS fps video of yesterday's images: $BASE_DIR/$YESTERDAY.mp4..."
			mkdir -p "$BASE_DIR/$YESTERDAY/temp"
			find "$BASE_DIR/$YESTERDAY" -name "*.$FILE_EXT" | sort | awk -v q="\"" 'BEGIN{ a=1 }{ printf "cp "q"%s"q" "q"'"$BASE_DIR/$YESTERDAY/temp/"'%05d'".$FILE_EXT"'"q"\n", $0, a++ }' | bash
			"$FFMPEG_PATH" -framerate "$VIDEO_FPS" -i "$BASE_DIR/$YESTERDAY/temp/"%05d.jpg -c:v libx264 -r "$VIDEO_FPS" -pix_fmt yuv420p "$BASE_DIR/$YESTERDAY.mp4"
			rm -r "$BASE_DIR/$YESTERDAY/temp"
		fi

		echo_debug "Removing directory with yesterday's images..."
		rm -r "$BASE_DIR/$YESTERDAY"
	fi
fi

echo_debug "Finished!"
