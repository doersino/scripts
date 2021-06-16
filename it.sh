# Save keystrokes for some common actions when controlling iTunes or Apple Music
# remotely with AppleScript. This might pop up a permissions dialog the first
# time it's run.
#
# - `it` sans arguements will pause or resume playback.
# - `it ?` displays information about the currently playing track.
# - `it prev` and `prev next` do what you'd expect them to do.
# - Any other arguments will be passed to AppleScript, as in `tell application
#   "<ITUNES>" to ...`.
#
# https://github.com/doersino/scripts/blob/master/it.sh

function it() {

    # select available player
    ITUNES="iTunes"
    if [ -d "/System/Applications/Music.app" ]; then
        ITUNES="Music"
    fi

    # do the things
    if [ -z "$1" ]; then
        osascript -e "tell application \"$ITUNES\" to playpause"
    elif [ "$1" = "?" ]; then
        osascript -e "tell application \"$ITUNES\" to get name of current track"
        printf "\033[90mby \033[0m"
        osascript -e "tell application \"$ITUNES\" to get artist of current track"
        printf "\033[90mon \033[0m"
        osascript -e "tell application \"$ITUNES\" to get album of current track"
    elif [ "$1" = "prev" ]; then
        osascript -e "tell application \"$ITUNES\" to play previous track"
    elif [ "$1" = "next" ]; then
        osascript -e "tell application \"$ITUNES\" to play next track"
    else
        osascript -e "tell application \"$ITUNES\" to $1"
    fi
}
