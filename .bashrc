#--------------------------------------------------
#alias
#--------------------------------------------------
alias scl="screen -ls"
alias scq="quitscr"
alias scr="screen -raAd"

alias ls="ls --color=always"
alias grep="grep --color=always"

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
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export TERM=xterm-256color
export EDITOR=vim

MY_PATH=$HOME/bin:$HOME/.local/bin:$PATH
MY_INCLUDE=$HOME/.local/include:$INCLUDE
MY_LIBRARY_PATH=$HOME/.local/lib:$LIBRARY_PATH
MY_LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
export PATH=${MY_PATH%:}
export INCLUDE=${MY_INCLUDE%:}
export LIBRARY_PATH=${MY_LIBRARY_PATH%:}
export LD_LIBRARY_PATH=${MY_LD_LIBRARY_PATH%:}
if [ ! -z $LD_LIBRARY_PATH ];then
    export PRESERVE_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH=$PRESERVE_LD_LIBRARY_PATH

#--------------------------------------------------
#others
#--------------------------------------------------
if [ -f $HOME/.extrarc ];then
    . $HOME/.extrarc
fi
