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
alias pacman="pacman-color"

#other
alias sshproxy="ssh -qTfnN"
alias sagenb="sage -n interface='' automatic_login=False secure='True'"

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

#be evil
if [ -f $HOME/.evil_rc ];then
    source $HOME/.evil_rc
fi
