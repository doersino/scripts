#!/bin/bash

##########
## TEMP ##
##########

#export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/9.5/bin"
#export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.6/bin
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/10/bin"

alias sn='psql -c "drop database scratch;"; psql -c "create database scratch;"'
alias sf='psql -d scratch -f'
alias sr='psql -d scratch'


##########
## PATH ##
##########

export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"


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

# require ctrl-D to be pressed twice, not once, on order to exit
export IGNOREEOF=1

# shell options
shopt -s histappend  # merge session histories
shopt -s cmdhist     # combine multiline commands in history
shopt -s cdspell     # make cd try to fix typos

bind "set completion-ignore-case on"  # case-insensitive cd completion
bind "set show-all-if-ambiguous on"   # make it unnecessary to press Tab twice
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

    # git prompt, which will be stored in a variable for now
    GITPROMPT=""
    GITPROMPTLEN=""
    if declare -f __git_ps1 > /dev/null; then
        GITPROMPT="$(__git_ps1 "(%s)")"
        GITPROMPTLEN="$(echo $GITPROMPT | wc -c | xargs)"
    fi

    # start first line
    PS1+="["

    # print exit code only if it's non-zero
    EXITLEN="0"
    if [ ! $EXIT -eq 0 ]; then
        PS1+="$EXIT "
        EXITLEN="$(echo $EXIT | wc -c | xargs)"
    fi

    # directory string (adapted from http://stackoverflow.com/a/26555347),
    # adjust width by changing operands in expression between "sub(h,"~");" and
    # ";b=$1"/"$2", although that shouldn't be necessary
    PS1+='$(pwd|awk -F/ -v "w=$(tput cols)" -v "h=^$HOME" -v "g=$GITPROMPTLEN" -v "e=$EXITLEN" '\''{sub(h,"~");n=w-g-e;b=$1"/"$2} length($0)<=n || NF==3 {print;next;} NF>3{b=b"/.../"; p=$NF; n-=length(b $NF); for (i=NF-1;i>3 && n>length(p)+length($i)+1;i--) p=$i"/"p;} {print b p;}'\'')'

    # add git prompt and end first line
    PS1+="]\[\033[0;1m\]"
    if [ ! -z "$GITPROMPT" ]; then
        PS1+=" $GITPROMPT"
    fi
    PS1+="\n"

    # second line
    PS1+="\$\[\033[0m\] "

    # set terminal title to basename of cwd
    PS1="\e]0;\W\a""$PS1"
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
alias ll='ls -lh'  # list and human-readable filesizes
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
alias reallyemptytrash="rm -r ~/.Trash/*"  # because sometimes the system needs a little help
alias brewdeps='echo "Listing all installed homebrew packages along with packages that depend on them:"; brew list -1 | while read cask; do echo -ne "\x1B[1;34m$cask \x1B[0m"; brew uses $cask --installed | awk '"'"'{printf(" %s ", $0)}'"'"'; echo ""; done'  # via https://www.thingy-ma-jig.co.uk/blog/22-09-2014/homebrew-list-packages-and-what-uses-them
alias highlight='pygmentize -f terminal'   # syntax highlighting
alias bashrc='s ~/.bashrc'
alias refresh-bashrc='source ~/.bashrc'

# git
alias g='git'
alias gs='g status'  # collision with ghostscript executable
alias gd='g diff'
alias gds='g diff --staged'
alias gdl='git diff master@{1} master'  # diff after pulling
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

# image operations
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
alias exssh='ssh -XY 192.168.0.3'
alias exmcs='ssh -t 192.168.0.3 "screen -r mcs"'  # minecraft server
alias exdls='scp -rp 192.168.0.3:/home/noah/Downloads/ ~/Desktop/exdls/'
alias exdls2='scp -rp 192.168.0.3:/home/noah/Downloads/ /Volumes/Time\ Capsule/exdls/'

# website
alias hejssh='ssh -4 doersino@draco.uberspace.de'
alias hejquota='hejssh quota -gsl'
alias hejserve='bundle exec jekyll serve'
alias hejservei='bundle exec jekyll serve --incremental'

# backup
alias backup-do='/Users/noah/Dropbox/code/backup/backup-do.sh'
alias backup-fonts='/Users/noah/Dropbox/code/backup/backup-fonts.sh'
alias backup-gists='/Users/noah/Dropbox/code/backup/backup-gists.sh'
alias backup-sync='/Users/noah/Dropbox/code/backup/backup-sync.sh'
alias backup-tumblr='/Users/noah/Dropbox/code/backup/backup-tumblr.sh'
alias backup-uberspace='/Users/noah/Dropbox/code/backup/backup-uberspace.sh'
alias backup-various='/Users/noah/Dropbox/code/backup/backup-various.sh'

# downloads
alias simonstalenhag='cd ~/Desktop; mkdir simonstalenhag; cd simonstalenhag; curl http://www.simonstalenhag.se | grep bilderbig | cut -d"\"" -f2 | sed "s,//,/,g" | uniq | sed -e "s/^/http:\/\/www.simonstalenhag.se\//" | xargs wget'
alias davebull='cd "/Volumes/Time Capsule" && { youtube-dl --no-check-certificate -o "%(timestamp)s_%(title)s-%(id)s.%(ext)s" https://www.twitch.tv/japaneseprintmaking/videos/all; cd -; }'
alias datesbull='cd "/Volumes/Time Capsule" && { ls -1 *.mp4 | cut -d _ -f 1 | gawk '"'"'{ print strftime("%c", $0); }'"'"'; cd -; }'
alias backupbull='cd "/Volumes/Time Capsule" && { cp -n *.mp4 "/Volumes/TOSHIBA EXT/dave/"; cd -; }'



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
# applescript
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
