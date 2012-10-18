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
alias pacman="pacman-color"

#other
alias sshproxy="ssh -qTfnN -D 8707 vps"
alias dquilt="quilt --quiltrc=$HOME/.quiltrc-dpkg"
alias genpatch="diff -Naur --strip-trailing-cr"
alias sage="$HOME/software/sage/sage"
alias sagenb="$HOME/software/sage/sage -n interface='' open_viewer='False' secure='True'"

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
export PATH=$PATH:$HOME/bin

#stow path
if [ -d $HOME/opt ];then
    export PATH=$HOME/opt/bin:$HOME/bin:$PATH
    export INCLUDE=$HOME/opt/include:$INCLUDE
    export LIBRARY_PATH=$HOME/opt/lib:$HOME/opt/lib64:$LIBRARY_PATH
    export LD_LIBRARY_PATH=$HOME/opt/lib:$HOME/opt/lib64:$LD_LIBRARY_PATH
    export XDG_DATA_DIRS=$HOME/opt/share:$XDG_DATA_DIRS
fi

#debian packaging
export DEBEMAIL=lainme993@gmail.com
export DEBFULLNAME="lainme"
export DEB_BUILD_OPTIONS=nocheck
export QUILT_PATCHES=debian/patches
export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"

#--------------------------------------------------
#others
#--------------------------------------------------
#bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#git completion on cluster
if [ -f $HOME/.git-completion.bash ];then
    source $HOME/.git-completion.bash
fi

#be evil
if [ -f $HOME/.evil_rc ];then
    source $HOME/.evil_rc
fi
