#!/bin/bash

# Performs a backup of the default font folders on a single-user Mac (see
# https://support.apple.com/en-us/HT201722, ignores "Network" and "Classic").
# After running this script, you'll find a directory named "Fonts_YYYY-MM-DD" on
# your desktop.

DIR="$HOME/Desktop/backups/Fonts_$(date +%F)"

[ "$1" = "-v" ] && set -o xtrace

mkdir -p "$DIR/Library/Fonts/"
cp -a "/Library/Fonts/" "$DIR/Library/Fonts/"

mkdir -p "$DIR/System/Library/Fonts/"
cp -a "/System/Library/Fonts/" "$DIR/System/Library/Fonts/"

mkdir -p "$DIR$HOME/Library/Fonts/"
cp -a "$HOME/Library/Fonts/" "$DIR$HOME/Library/Fonts/"
