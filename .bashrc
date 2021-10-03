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

appendPath() {
    if [ ! -d $2 ]; then
        echo $1
        return 0;
    fi
    if [ -z $1 ]; then
        echo $2
        return 0;
    fi
    result=$1
    case ":$1:" in
        *":$2:"*) :;; # already there
        *) result="$2:$1";; # add to path
    esac
    echo $result
}

#--------------------------------------------------
#environment variables
#--------------------------------------------------
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export TERM=xterm-256color
export EDITOR=vim

MY_PATH=$(appendPath "$PATH" $HOME/bin)

MY_PATH=$(appendPath "$PATH" $HOME/.local/bin)
MY_LIBRARY_PATH=$(appendPath "$LIBRARY_PATH" $HOME/.local/lib)
MY_LD_LIBRARY_PATH=$(appendPath "$LD_LIBRARY_PATH" $HOME/.local/lib)

MY_PATH=$(appendPath "$PATH" /usr/local/bin)
MY_LIBRARY_PATH=$(appendPath "$LIBRARY_PATH" /usr/local/lib)
MY_LD_LIBRARY_PATH=$(appendPath "$LD_LIBRARY_PATH" /usr/local/lib)

export PATH=${MY_PATH%:}
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
