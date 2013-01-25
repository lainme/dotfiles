#--------------------------------------------------
#alias
#--------------------------------------------------
#lighttpd
alias webon="lighttpd -f $HOME/.lighttpd.conf"
alias weboff="killall -u lainme lighttpd"

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

#fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

#path
if [ ! -z $LD_LIBRARY_PATH ];then
    export PRESERVE_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
fi
export PATH=$HOME/bin:$HOME/.local/bin:$PATH
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
    . $HOME/.evil_rc
fi
