#--------------------------------------------------
#alias
#--------------------------------------------------
#screen
alias scl="screen -ls"
alias scq="quitscr"
alias scr="screen -raAd"

#color output
alias ls="ls --color=auto"
alias grep="grep --color=auto"

#other
alias sshproxy="ssh -qTfnN"
alias checksums='setconf PKGBUILD $(makepkg -g 2>/dev/null | pee "head -1 | cut -d= -f1" "cut -d= -f2") ")"'

#--------------------------------------------------
#functions
#--------------------------------------------------
quitscr() { 
    screen -X -S $1 quit
}

#--------------------------------------------------
#environment variables
#--------------------------------------------------
#set prompt
export PS1="\u@\h:\w\$ "

#xterm-256
export TERM=xterm-256color

#editor
export EDITOR=vim

#path
if [ ! -z $LD_LIBRARY_PATH ];then
    export PRESERVE_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
fi
export PATH=$HOME/bin:$PATH
export LD_LIBRARY_PATH=$PRESERVE_LD_LIBRARY_PATH

#--------------------------------------------------
#others
#--------------------------------------------------
#bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#extra
if [ -f $HOME/.extrarc ];then
    . $HOME/.extrarc
fi
