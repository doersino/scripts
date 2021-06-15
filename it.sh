function it() {
    ITUNES="iTunes"
    if [ -d "/System/Applications/Music.app" ]; then
        ITUNES="Music"
    fi

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
