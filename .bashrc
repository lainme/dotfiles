#--------------------------------------------------
#alias
#--------------------------------------------------
#web
alias webon="lighttpd -f $HOME/.lighttpd.conf"
alias weboff="killall lighttpd"

#screen
alias scl="screen -ls"
alias scq="quitscr"
alias scr="screen -raAd"

#color output
alias ls="ls --color=auto"
alias grep="grep --color=auto"

#other
alias sshproxy="ssh -qTfnN -D 8707 vps"
alias dquilt="quilt --quiltrc=$HOME/.quitrc-dpkg"

#--------------------------------------------------
#functions
#--------------------------------------------------
function quitscr() { 
    screen -X -S $1 quit
}

#--------------------------------------------------
#environment variables
#--------------------------------------------------
#set prompt
export PS1="\u@\h:\w\$ "

#debian packaging
export DEBEMAIL=lainme993@gmail.com
export DEBFULLNAME="lainme"
export DEB_BUILD_OPTIONS=nocheck

#xterm-256
export TERM=xterm-256color

#editor
export EDITOR=vim

#path
export PATH=$PATH:$HOME/bin

#--------------------------------------------------
#others
#--------------------------------------------------
#bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#chsdir
if [ -f $HOME/bin/chs_completion ];then
    source $HOME/bin/chs_completion
    complete -o filenames -F _filedir_xspec file
fi

#be evil
if [ -f $HOME/.evil_rc ];then
    source $HOME/.evil_rc
fi
