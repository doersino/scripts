#!/bin/bash

# Using sips, move vertical images in the current directory to a subdirectory
# "vertical". This assumes that the current directory only contains images.

mkdir vertical

for i in *
do
	width="$(sips -g pixelWidth "$i"  | grep pixelWidth | awk '{print $2}')"
	height="$(sips -g pixelHeight "$i" | grep pixelHeight | awk '{print $2}')"
	if (( $height > $width ))
	then
		echo "$i"
		mv "$i" "vertical/$i";
	fi
done
