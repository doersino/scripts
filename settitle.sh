function settitle() {
    echo -ne "\033]0;${@:1}\007"
}
