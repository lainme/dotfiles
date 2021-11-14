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

removePath() {
    if [ ! -d $2 ]; then
        echo $1
        return 0;
    fi
    if [ -z $1 ]; then
        echo $2
        return 0;
    fi
    parsed=$(echo "$1" | sed -e "s|:$2[^:]*||g")
    echo $parsed
}

appendPath() {
    if [ ! -d $2 ]; then
        echo $1
        return 0;
    fi
    if [ -z $1 ]; then
        echo $2
        return 0;
    fi
    parsed=$(echo "$1" | sed -e "s|:$2[^:]*||g")
    echo $2:$parsed
}

#--------------------------------------------------
#environment variables
#--------------------------------------------------
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export TERM=xterm-256color
export EDITOR=vim

export PATH=$(appendPath "$PATH" /usr/local/sbin)
export PATH=$(appendPath "$PATH" /usr/local/bin)
export LIBRARY_PATH=$(appendPath "$LIBRARY_PATH" /usr/local/lib)
export LIBRARY_PATH=$(appendPath "$LIBRARY_PATH" /usr/local/lib64)
export LD_LIBRARY_PATH=$(appendPath "$LD_LIBRARY_PATH" /usr/local/lib)
export LD_LIBRARY_PATH=$(appendPath "$LD_LIBRARY_PATH" /usr/local/lib64)
export XDG_DATA_DIRS=$(appendPath "$XDG_DATA_DIRS" /usr/local/share)

export PATH=$(appendPath "$PATH" $HOME/.local/bin)
export LIBRARY_PATH=$(appendPath "$LIBRARY_PATH" $HOME/.local/lib)
export LIBRARY_PATH=$(appendPath "$LIBRARY_PATH" $HOME/.local/lib64)
export LD_LIBRARY_PATH=$(appendPath "$LD_LIBRARY_PATH" $HOME/.local/lib)
export LD_LIBRARY_PATH=$(appendPath "$LD_LIBRARY_PATH" $HOME/.local/lib64)
export XDG_DATA_DIRS=$(appendPath "$XDG_DATA_DIRS" $HOME/.local/share)

export PATH=$(appendPath "$PATH" $HOME/bin)

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
