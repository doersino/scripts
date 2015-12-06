#!/bin/bash

# Using sips, move images in the current directory that would be too small to be
# a 1440x900 desktop wallpaper to a subdirectory "small". This assumes that the
# current directory only contains images.

mkdir small

for i in *
do
	width="$(sips -g pixelWidth "$i"  | grep pixelWidth | awk '{print $2}')"
	height="$(sips -g pixelHeight "$i" | grep pixelHeight | awk '{print $2}')"
	if (( ($width < 1440) || ($height < 900) ))
	then
		echo "$i"
		mv "$i" "small/$i";
	fi
done
