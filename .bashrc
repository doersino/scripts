export GOPATH=$HOME/Documents/code/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin # DBS1
export PATH=$PATH:/opt/local/bin # DBS1 (Zorba)
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

# ctrl+D must be pressed twice to exit
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

# set up the command prompt
function __prompt_command() {
	local EXIT=$?
	if [ $EXIT -eq 0 ]; then
		PS1="\[\033[1;32m\]"
	else
		PS1="\[\033[1;31m\]"
	fi
	PS1+="[$EXIT \u@\h \w]\[\033[0;1m\]\n\$\[\033[0m\] "
}
PROMPT_COMMAND=__prompt_command

# write to history file immediately (and not only during exit)
PROMPT_COMMAND="$PROMPT_COMMAND; history -a"


#############
## ALIASES ##
#############

# cd
alias ..='cd ..'   # go up one directory
alias -- -='cd -'  # the command is actually -

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
alias c='clear'
alias grep='grep --color=auto'  # highlight search phrase
alias timestamp='date +%s'
alias gpom='git push origin master'
alias pingg='prettyping --nolegend -i 0.1 google.com'
alias ip='curl ifconfig.me'
alias up='uptime'               # drop the "time". just "up". it's cleaner.
alias batt='pmset -g batt'      # battery status
alias nosleep='pmset noidle'    # keep computer awake indefinately
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend" #lock screen
alias rmdsstore="find . -name '*.DS_Store' -type f -delete"  # recursive!
alias refresh-bashrc='source ~/.bashrc'

# image operations
alias 2png='mogrify -format png'
alias 2jpg='mogrify -format jpg -quality 95'
alias png2jpg='for i in *.png; do mogrify -format jpg -quality 95 "$i" && rm "$i"; done'
alias png2jpg90='for i in *.png; do mogrify -format jpg -quality 90 "$i" && rm "$i"; done'
alias resize1k='sips --resampleWidth 1000'
alias jpg2mp4='ffmpeg -framerate 24 -pattern_type glob -i '"'"'*.jpg'"'"' -pix_fmt yuv420p out.mp4'

# applications
alias s='open -a Sublime\ Text\ 2'
alias chrome='open -a Google\ Chrome'
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'

# personal
alias ping='ping -c 1000'
alias ubuntussh='ssh -XY ubuntu.local'
alias hejssh='ssh -4 doersino@draco.uberspace.de'
alias hejquota='hejssh quota -gsl'
#alias unissh='ssh zxmqp63@134.2.2.38'
#alias unigateway='ssh -Y doersing@cgcontact.informatik.uni-tuebingen.de'
#alias startlubuntuvm='/Applications/VirtualBox.app/Contents/MacOS/VBoxManage startvm Lubuntu'
#alias stoplubuntuvm='/Applications/VirtualBox.app/Contents/MacOS/VBoxManage controlvm Lubuntu acpipowerbutton && sleep 1 && /Applications/VirtualBox.app/Contents/MacOS/VBoxManage controlvm Lubuntu keyboardputscancode 1c'


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