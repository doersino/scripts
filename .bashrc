#!/bin/bash

export PATH="$HOME/Dropbox:$PATH" # backup scripts
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin # DBS
export PATH="$HOME/Library/Haskell/bin:$PATH" # FP

######################################
## HISTORY, SHELL, AND LESS OPTIONS ##
######################################

# read this number of lines into history buffer on startup
export HISTSIZE=10000

# HISTFILESIZE is set *after* bash reads the history file (which is done after
# reading any configs like .bashrc). If it is unset at this point it is set to
# the same value as HISTSIZE. Therefore we must set it to NIL, in which case it
# isn't "unset", but doesn't have a value either, enabling us to keep an
# essentially infite history
export HISTFILESIZE=""

# don't put duplicate lines in the history, ignore same sucessive entries, and
# ignore lines that start with a space
export HISTCONTROL=ignoreboth

# shell options
shopt -s histappend  # merge session histories
shopt -s cmdhist     # combine multiline commands in history
shopt -s cdspell     # make cd try to fix typos

bind "set completion-ignore-case on"  # case-insensitive cd completion
bind "set show-all-if-ambiguous on"   # make it unnecessary to press Tab twice
                                      # when there is more than one match

# make it so ctrl+D must be pressed twice to exit
export IGNOREEOF=1

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
	local EXIT=$?
	if [ $EXIT -eq 0 ]; then
		PS1="\[\033[1;32m\]"
	else
		PS1="\[\033[1;31m\]"
	fi

	# first line
	PS1+="[$EXIT \u@\h "

	# directory string (adapted from http://stackoverflow.com/a/26555347)
	# adjust width by changing factor in "n=0.6*n"
	PS1+='$(pwd|awk -F/ -v "n=$(tput cols)" -v "h=^$HOME" '\''{sub(h,"~");n=0.6*n;b=$1"/"$2} length($0)<=n || NF==3 {print;next;} NF>3{b=b"/.../"; e=$NF; n-=length(b $NF); for (i=NF-1;i>3 && n>length(e)+1;i--) e=$i"/"e;} {print b e;}'\'')'

	# end first line
	PS1+="]\[\033[0;1m\]"

	# git prompt
	if declare -f __git_ps1 > /dev/null; then
		PS1+="$(__git_ps1 " (%s)")"
	fi

	# second line
	PS1+="\n\$\[\033[0m\] "

	# set terminal title to basename of cwd
	PS1="\e]0;\W\a""$PS1"
}
PROMPT_COMMAND=__prompt_command

# write to history file immediately (and not only during exit)
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

# utilities
alias grep='grep --color=auto'     # highlight search phrase
alias timestamp='date +%s'
alias pingg='prettyping --nolegend -i 0.1 google.com'
alias ip='curl ipinfo.io/ip'
alias up='uptime'                  # drop the "time". just "up". it's cleaner.
alias batt='pmset -g batt'         # battery status
alias dim='pmset displaysleepnow'  # turn the display off
alias sleepnow='pmset sleepnow'    # sleep immediately
alias nosleep='pmset noidle'       # keep computer awake indefinitely
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"  # lock screen
alias rmdsstore="find . -name '*.DS_Store' -type f -delete"  # recursive!
alias reallyemptytrash="rm -r ~/.Trash/*"  # because sometimes the system needs a little help
alias refresh-bashrc='source ~/.bashrc'
alias s='subl'
alias brewdeps='echo "Listing all installed homebrew packages along with packages that depend on them:"; brew list -1 | while read cask; do echo -ne "\x1B[1;34m$cask \x1B[0m"; brew uses $cask --installed | awk '"'"'{printf(" %s ", $0)}'"'"'; echo ""; done'  # via https://www.thingy-ma-jig.co.uk/blog/22-09-2014/homebrew-list-packages-and-what-uses-them

# git
alias g='git'
alias gpom='git push origin master'
alias grau='git remote add upstream'  # argument: clone url of remote upstream repo
alias gmakeeven='git fetch upstream && git checkout master && git merge upstream/master && git push origin master'  # in a fork, assuming no local changes have been made, fetch all new commits from upstream, merge them into the fork, and finally push
alias gitslog='git log --pretty=oneline --abbrev-commit -n 15'  # compact log

# image operations
alias 2png='mogrify -format png'
alias 2jpg='mogrify -format jpg -quality 95'
alias png2jpg='for i in *.png; do mogrify -format jpg -quality 95 "$i" && rm "$i"; done'
alias png2jpg90='for i in *.png; do mogrify -format jpg -quality 90 "$i" && rm "$i"; done'
alias resize1k='mogrify -resize 1000'
alias jpg2mp4='ffmpeg -framerate 24 -pattern_type glob -i '"'"'*.jpg'"'"' -pix_fmt yuv420p out.mp4'

# personal
alias ping='ping -c 1000'
alias exssh='ssh -XY 192.168.0.3'
alias exmcs='ssh -t 192.168.0.3 "screen -r mcs"'  # minecraft server
alias exdls='md ~/Desktop/exdls; scp -rp 192.168.0.3:/home/noah/Downloads/ ~/Desktop/exdls/'
alias hejssh='ssh -4 doersino@draco.uberspace.de'
alias hejquota='hejssh quota -gsl'


###############
## FUNCTIONS ##
###############

# sets the window/tab title in an OS X terminal
# https://github.com/doersino/scripts/blob/master/settitle.sh
function settitle() {
	echo -ne "\033]0;${@:1}\007"
}

# mkdir and cd to the directory that was just created
function mkcd() {
	local USAGE
	USAGE="usage: mkcd DIRECTORY_NAME"
	if [ -z "$1" ]; then
		echo -e "$USAGE"; return 1
	fi
	mkdir -p "$1" && cd "$_";
}

# list all distinct file extensions in the current directory and, if the -r flag
# is set, its subdirectories
function extensions() {
	local MAXDEPTH="-maxdepth 1"
	if [[ $1 == "-r" ]]; then
		MAXDEPTH=""
	fi
	find . $MAXDEPTH -type f | perl -ne 'print $1 if m/\.([^.\/]+)$/' | sort -u;
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
