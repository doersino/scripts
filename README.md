# scripts
Various scripts that don't really necessitate their own repository:

* `.bashrc`: My `.bashrc`.
* `256-colors.sh`: OS X/Terminal.app-compatible version of the color demo script available at [http://misc.flogisoft.com/bash/tip_colors_and_formatting#colors2](http://misc.flogisoft.com/bash/tip_colors_and_formatting#colors2).
* `backup_gists.py`: Clone or update a user's public gists. Usage: backup_gists.py USERNAME [DIR] [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/af1ba2bb16b12542b41d/revisions)
* `backup_sync.sh`: Rsync wrapper with sanity checking for some of the most common use cases. [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/ecca3ca9f6254b9c6041/revisions)
* `backup_sync_exclude.txt`: Used by `backup_sync.sh` as an exclude patterns file.
* `backup_tumblr.sh`: Simple way of backing up one or multiple Tumblr blogs to date-prefixed folders; downloads and removes required software (except Python) automatically. http://neondust.tumblr.com/post/97723922505/simple-tumblr-backup-script-for-mac-os-x-and-linux [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/7e3e5db591e42bf543e1/revisions)
* `backup_uberspace.sh`: Creates a backup of your Uberspace home folder, as well as your websites and MySQL databases. [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/faaaf53484f77d97e9b9/revisions)
* `colors_and_formatting.sh`: OS X/Terminal.app-compatible version of the color demo script available at [http://misc.flogisoft.com/bash/tip_colors_and_formatting#colors_and_formatting_16_colors](http://misc.flogisoft.com/bash/tip_colors_and_formatting#colors_and_formatting_16_colors).
* `imagesnap_avoidmemoryleak.sh`: Avoids the memory leak occuring when capturing many webcam pictures using imagesnap version 0.2.5 by regularly restarting the command. [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/fdca8e065eb30e030ef2/revisions)
* `it.sh`: Save keystrokes when controlling iTunes remotely.
* `move_small_images.sh`: Using `sips`, move images in the current directory that would be too small to be a 1440x900 desktop wallpaper to a subdirectory "small".
* `move_vertical_images.sh`: Using `sips`, move vertical images in the current directory to a subdirectory "vertical".
* `settitle.sh`: Sets the window/tab title on an OS X terminal. [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/4644810/revisions)
* `setvolume.sh`: Sets the volume on a Mac. [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/55af01ec4223a10c4ee8/revisions)
* `tripcode_words.php`: Generate tripcodes containing words, be default based on a list read from `/usr/share/dict/words`.
* `webcam_dl.sh`: Downloads a webcam image, overlays the date/time, and compress past images into ZIP and MP4 format. [(Imported from Gist: click here for previous revisions.)](https://gist.github.com/doersino/ade1edd8fe154ea30ba4/revisions)

## License (MIT)

This license applies to any file in this repository unless otherwise noted.

```
The MIT License (MIT)

Copyright (c) 2015 Noah Doersing

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
