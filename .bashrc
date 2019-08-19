#!/bin/bash

###############
## TEMPORARY ##
###############

# postgres
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/10/bin"

alias psn='psql -c "drop database scratch;"; psql -c "create database scratch;"'
alias psf='psql -d scratch -f'
alias psr='psql -d scratch'


##########
## PATH ##
##########

export PATH="$PATH:/usr/local/sbin:/Applications/Sublime Text.app/Contents/SharedSupport/bin:/Applications/Sublime Merge.app/Contents/SharedSupport/bin/"


######################################
## HISTORY, SHELL, AND LESS OPTIONS ##
######################################

# read this number of lines into history buffer on startup
export HISTSIZE=1000000

# HISTFILESIZE is set *after* bash reads the history file (which is done after
# reading any configs like .bashrc). If it is unset at this point it is set to
# the same value as HISTSIZE. Therefore we must set it to NIL, in which case it
# isn't "unset", but doesn't have a value either, enabling us to keep an
# essentially infite history
export HISTFILESIZE=""

# don't put duplicate lines in the history, ignore same sucessive entries, and
# ignore lines that start with a space
export HISTCONTROL=ignoreboth

# require ctrl-D to be pressed twice, not once, in order to exit
export IGNOREEOF=1

# shell options
shopt -s histappend  # merge session histories
shopt -s cmdhist     # combine multiline commands in history
shopt -s cdspell     # make cd try to fix typos

bind '"\e[B": history-search-forward'   # instead of just walking the history,
                                        # perform a search on up...
bind '"\e[A": history-search-backward'  # ...and down arrow press
bind 'set completion-ignore-case on'    # case-insensitive cd completion
bind 'set show-all-if-ambiguous on'     # remove the need to press Tab twice
                                        # when there is more than one match

# colored man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'         # end the info box
export LESS_TERMCAP_so=$'\E[01;42;30m'  # begin the info box
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# hakase no suki nano nano
export EDITOR=nano

# keep git from speaking german
export LC_ALL=en_US.UTF-8


####################
## COMMAND PROMPT ##
####################

# source git prompt
if [ -e /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
    source /usr/local/etc/bash_completion.d/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="verbose"
fi

# set up the command prompt
function __prompt_command() {

    # green or red depending on the previous command's exit code
    local EXIT=$?
    if [ $EXIT -eq 0 ]; then
        PS1="\[\033[1;32m\]"
    else
        PS1="\[\033[1;31m\]"
    fi

    # git prompt, which we'll store in a variable for now
    GITPROMPT=""
    GITPROMPTLEN=""
    if declare -f __git_ps1 > /dev/null; then
        GITPROMPT="$(__git_ps1 "(%s)")"
        GITPROMPTLEN="$(echo "$GITPROMPT" | wc -c | xargs)"
    fi

    # start first line
    PS1+="["

    # print exit code, but only if it's non-zero
    EXITLEN="0"
    if [ ! $EXIT -eq 0 ]; then
        PS1+="$EXIT "
        EXITLEN="$(echo $EXIT | wc -c | xargs)"
    fi

    # compute maximum length of directory string (this does not account for
    # double-width characters, oh well)
    #                             [              ]                   date
    MAX_PWD_LENGTH=$(($COLUMNS - (1 + $EXITLEN + 1 + $GITPROMPTLEN + 8)))

    PWD=$(pwd)

    # if truncated, replace truncated part of directory string with this
    REPLACE="..."

    # portion of path that's within $HOME, or entire path if not in $HOME
    RESIDUAL=${PWD#$HOME}

    # determine whether we are in $HOME or not
    PREFIX=""
    if [ X"$RESIDUAL" != X"$PWD" ]
    then
        PREFIX="~"
    fi

    # make sure the first few characters of the path are always shown
    PREFIX="$PREFIX"${RESIDUAL:0:12}
    RESIDUAL=${RESIDUAL:12}

    # check if residual path needs truncating to keep the total length below
    # $MAX_PWD_LENGTH, compensate for replacement string
    TRUNC_LENGTH=$(($MAX_PWD_LENGTH - ${#PREFIX} - ${#REPLACE} - 1))
    NORMAL=${PREFIX}${RESIDUAL}
    if [ ${#NORMAL} -ge $(($MAX_PWD_LENGTH)) ]
    then
        NEW_PWD=${PREFIX}${REPLACE}${RESIDUAL:((${#RESIDUAL} - $TRUNC_LENGTH)):$TRUNC_LENGTH}
    else
        NEW_PWD=${PREFIX}${RESIDUAL}
    fi

    # add that to prompt
    PS1+="$NEW_PWD"

    # add git prompt
    PS1+="]\[\033[0;1m\]"
    if [ ! -z "$GITPROMPT" ]; then
        PS1+=" $GITPROMPT"
        MAX_PWD_LENGTH=$((MAX_PWD_LENGTH - 1))
    fi

    # print right-aligned time
    PS1+="$(printf %$(($MAX_PWD_LENGTH - ${#NEW_PWD}))s)"
    PS1+=" \[\033[1;37m\]$(date +%d.%H:%M)\[\033[0;1m\]"
    PS1+="\n"

    # second line: $
    PS1+="\$\[\033[0m\] "

    # set terminal title to basename of cwd
    PS1="\e]0;\W\a""$PS1"

    # and we're done!
}
PROMPT_COMMAND=__prompt_command

# append to history file immediately (and not only during exit)
PROMPT_COMMAND="$PROMPT_COMMAND; history -a"


#############
## ALIASES ##
#############

# ls
alias ls='ls -FG'  # display a trailing slash if entry is directory or star if
                   # entry is executable, also colors
alias ll='ls -lh'  # list mode and human-readable filesizes
alias la='ll -A'   # include dotfiles
alias l1='\ls -1'  # one entry per line

# tree
alias tree='tree -CF'
alias treel='tree -phD --du'
alias treea='treel -a'

# file operations
alias cp='cp -iPRv'
alias mv='mv -iv'
alias mkdir='mkdir -p'
alias md='mkdir'
alias rmdir='rmdir -p'
alias rd='rmdir'
alias zip='zip -r'
alias o='open'
alias f='open -a Finder .'
alias space2_='for i in *; do [[ $i == *" "* ]] && mv "$i" ${i// /_}; done'

# ulitities
alias s='subl'
alias sm='smerge .'
alias grep='grep --color=auto'     # highlight search phrase
alias timestamp='date +%s'
alias pingg='prettyping --nolegend -i 0.1 google.com'
alias ip='curl ipinfo.io/ip'
alias duls='du -h -d1 | sort -r'   # list disk usage statistics for the current folder, via https://github.com/jez/dotfiles/blob/master/util/aliases.sh
alias up='uptime'                  # drop the "time". just "up". it's cleaner.
alias batt='pmset -g batt'         # battery status
alias dim='pmset displaysleepnow'  # turn the display off
alias sleepnow='pmset sleepnow'    # sleep immediately
alias nosleep='pmset noidle'       # keep computer awake indefinitely
alias rmdsstore="find . -name '*.DS_Store' -type f -delete"  # recursive!
alias brewdeps='echo "Listing all installed homebrew packages along with packages that depend on them:"; brew list -1 | while read cask; do echo -ne "\x1B[1;34m$cask \x1B[0m"; brew uses $cask --installed | awk '"'"'{printf(" %s ", $0)}'"'"'; echo ""; done'  # via https://www.thingy-ma-jig.co.uk/blog/22-09-2014/homebrew-list-packages-and-what-uses-them
alias highlight='pygmentize -f terminal'   # syntax highlighting
alias extensions="find . -type f | perl -ne 'print $1 if m/\.([^.\/]+)$/' | sort -u"  # via https://stackoverflow.com/a/1842270
alias bashrc='s ~/.bashrc'
alias refresh-bashrc='source ~/.bashrc'

# git
alias g='git'
alias gs='g status'  # collision with ghostscript executable
alias gd='g diff'
alias gds='g diff --staged'
alias ga='g add'
alias gc='g commit -m'
alias gp='g push'
alias gpom='gp origin master'
alias gl='g log'
alias glg='gl --graph'
alias gls='g log --pretty=oneline --abbrev-commit -n 15'  # short log
alias grau='g remote add upstream'  # argument: clone url of remote upstream repo
alias gmakeeven='g fetch upstream && g checkout master && g merge upstream/master && gpom'  # in a fork, assuming no local changes have been made, fetch all new commits from upstream, merge them into the fork, and finally push
alias gmakeevenforce='g fetch upstream && g checkout master && git reset --hard upstream/master && gpom --force'  # same except will "force pull" from upstream and you'll lose any local changes

# image operations, based on imagemagick and ffmpeg
alias 2png='mogrify -format png'
alias 2jpg='mogrify -format jpg -quality 95'
alias png2jpg='for i in *.png; do mogrify -format jpg -quality 95 "$i" && rm "$i"; done'
alias png2jpg90='for i in *.png; do mogrify -format jpg -quality 90 "$i" && rm "$i"; done'
alias resize1k='mogrify -resize 1000'
alias jpg2mp4='ffmpeg -framerate 24 -pattern_type glob -i '"'"'*.jpg'"'"' -pix_fmt yuv420p out.mp4'


######################
## PERSONAL ALIASES ##
######################

# old laptop
alias exssh='ssh -XY ex.local'
alias exmcs='ssh -t ex.local "screen -r mcs"'  # minecraft server, detach with ctrl + a, then d
alias exdls='scp -rp ex.local:/home/noah/Downloads/ ~/Desktop/exdls/'
alias exdls2='scp -rp ex.local:/home/noah/Downloads/ /Volumes/Time\ Capsule/exdls/'

# website
alias hejssh='ssh -4 doersino@draco.uberspace.de'
alias hejquota='hejssh quota -gsl'
alias hejinstall='bundle install --path ./vendor/bundle'  # the --deployment flag also uses ./vendor/bundle, but requires a Gemfile.lock, which in the case of a Jekyll upgrade may not be current
alias hejserve='bundle exec jekyll serve'
alias hejservei='bundle exec jekyll serve --incremental'

# backup
alias backup-fonts='/Users/noah/Dropbox/code/backup/backup-fonts.sh'
alias backup-gists='/Users/noah/Dropbox/code/backup/backup-gists.sh'
alias backup-tumblr='/Users/noah/Dropbox/code/scripts/backup-tumblr.sh'
alias backup-uberspace='/Users/noah/Dropbox/code/backup/backup-uberspace.sh'
alias backup-do='/Users/noah/Dropbox/code/backup/backup-do.sh'
alias backup-sync='/Users/noah/Dropbox/code/backup/backup-sync.sh'

# dotfiles
alias commitbashrc='echo "Update .bashrc" > /tmp/commitbashrc.txt; cp ~/.bashrc ~/Dropbox/code/scripts/; cd ~/Dropbox/code/scripts/; git add .bashrc; git commit -F /tmp/commitbashrc.txt -e; git push; rm /tmp/commitbashrc.txt; cd -'

# downloads
alias simonstalenhag='cd ~/Desktop; mkdir simonstalenhag; cd simonstalenhag; curl http://www.simonstalenhag.se | grep bilderbig | cut -d"\"" -f2 | sed "s,//,/,g" | uniq | sed -e "s/^/http:\/\/www.simonstalenhag.se\//" | xargs wget'
alias davebull='cd "/Volumes/Time Capsule" && { youtube-dl --no-check-certificate -o "%(timestamp)s_%(title)s-%(id)s.%(ext)s" --download-archive .downloaded --console-title https://www.twitch.tv/japaneseprintmaking/videos/all; cd - >/dev/null; }'
alias datesbull='cd "/Volumes/Time Capsule" && { ls -1 *.mp4 | cut -d _ -f 1 | gawk '"'"'{ print strftime("%c", $0); }'"'"'; cd -; }'
alias backupbull='rsync -auv --progress --stats --include '"'"'./'"'"' --include '"'"'*.mp4'"'"' --exclude '"'"'*'"'"' "/Volumes/Time Capsule/" "/Volumes/one/davebull/"'
alias backupbull2='rsync -auv --progress --stats --include '"'"'./'"'"' --include '"'"'*.mp4'"'"' --exclude '"'"'*'"'"' "/Volumes/Time Capsule/" "/Volumes/two/davebull/"'

# awk depends on an old version of readline? idk, need to run this sometimes after brew upgrade
alias repair-readline='cd /usr/local/opt/readline/lib/ && ln libreadline.8.0.dylib libreadline.7.dylib'

# 22:22
alias 2222='echo "Forever (h)waiting..."; while true; do [[ $(date | cut -d" " -f 4 | cut -d":" -f 1) == $(date | cut -d" " -f 4 | cut -d":" -f 2) ]] && date | cut -d" " -f 4 | cut -d":" -f 1,2 | say; sleep 1; done'

###############
## FUNCTIONS ##
###############

# mkdir and cd to the directory that was just created
function mkcd() {
    mkdir -p "$1" && cd "$_"
}

# sets the window/tab title in an OS X terminal
# https://github.com/doersino/scripts/blob/master/settitle.sh
function settitle() {
    echo -ne "\033]0;${@:1}\007"
}

# change the volume on a mac, from 0 to 7
# https://github.com/doersino/scripts/blob/master/setvolume.sh
function setvolume() {
    local USAGE
    USAGE="usage: setvolume NUMBER_FROM_0_AND_7"
    if [ -z "$1" ]; then
        echo -e "$USAGE"; return 1
    fi
    osascript -e "set volume $1"
}

# save keystrokes for some common actions when controlling itunes remotely with
# applescript (this will pop up a permission dialog the first time it's run)
# https://github.com/doersino/scripts/blob/master/it.sh
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

# extract fonts used in a pdf
# https://stackoverflow.com/a/3489099
function fonts() {
    /usr/local/bin/gs -q -dNODISPLAY "/Users/noah/Dropbox/code/scripts/extractFonts.ps" -c "($1) extractFonts quit"
}

# call a command whenever a file is saved, requires fswatch utility
function onsave() {
    FILE="$1"
    shift
    CMD="$@"
    fswatch -v -o "$FILE" | xargs -n1 -I{} $CMD
}

# create a jpeg version of one or multiple heic files (which can be located in
# different directories; each conversion result ends up "next to" its respective
# original) using sips
function unheic {
    local USAGE
    USAGE="usage: unheic FILES"
    if [ -z "$1" ]; then
        echo -e "$USAGE"; return 1
    fi

    for FILE in "$@"; do
        NO_EXT="${FILE%.*}"
        echo "$NO_EXT"
        sips -s format jpeg "$FILE" --out "$NO_EXT".jpg
    done
    #
}
