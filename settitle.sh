function settitle() {
    local USAGE
    USAGE="usage: settitle WINDOW_TITLE"
    if [ -z "$1" ]; then
        echo -e "$USAGE"; return 1
    fi
    echo -ne "\033]0;$1\007"
}