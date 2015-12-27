function it() {
    if [ -z "$1" ]; then
        osascript -e 'tell application "iTunes" to playpause'
    elif [ "$1" = "?" ]; then
        osascript -e 'tell application "iTunes" to get name of current track'
        printf "\033[90mby \033[0m"
        osascript -e 'tell application "iTunes" to get artist of current track'
        printf "\033[90mon \033[0m"
        osascript -e 'tell application "iTunes" to get album of current track'
    elif [ "$1" = "prev" ]; then
        osascript -e 'tell application "iTunes" to play previous track'
    elif [ "$1" = "next" ]; then
        osascript -e 'tell application "iTunes" to play next track'
    else
        osascript -e "tell application \"iTunes\" to $1"
    fi
}
