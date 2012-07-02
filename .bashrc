#--------alias--------
#web
alias webon='lighttpd -f $HOME/.lighttpd.conf'
alias weboff='killall lighttpd'

#screen
alias scl='screen -ls'
alias scq='quitscr'
alias scr='screen -raAd'

#software
if [ `uname -n` == "lainme-ubuntu" ] ;then
    alias s-install='sudo aptitude install'
    alias s-purge='sudo aptitude purge'
    alias s-search='aptitude search'
    alias s-show='aptitude show'
    alias s-update='sudo aptitude update'
    alias s-upgrade='sudo aptitude safe-upgrade'
fi

if [ `uname -n` == "lainme-arch" ];then
    alias s-install='yaourt'
    alias s-purge='yaourt -Rsn'
    alias s-search='yaourt -Ss'
    alias s-show='yaourt -Si'
    alias s-update='yaourt -Sy'
    alias s-upgrade='yaourt -Syu'
    alias s-full='yaourt -Syua'
    alias s-clean='yaourt -Sc'
fi

#color output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

#quick launch
if [ -d /home/data ];then
    alias ufs='vim -S /home/data/research/ufs/project.vim'
    alias sage='/home/data/software/sage/sage'
    alias sagenb='nohup /home/data/software/sage/sage -n open_viewer="False" port="4000" require_login="False" &> /dev/null &'
fi
alias sshproxy='ssh -qTfnN -D 8707 vps'

#--------functions--------
function quitscr() { 
    screen -X -S $1 quit
}

#create link in cygwin
function mklink() {
    if [ -z $2 ] || [ -z $1 ];then
        echo "Usage: mklink target link"
        return
    fi

    if [ -d $1 ];then
        target=`cygpath -w $1`
        link=`cygpath -w $2`
        cmdstr="cygstart -- cmd /c 'cpau -k -u administrator -ex \"mklink /d $link $target\" -lwp'"
        eval $cmdstr
    elif [ -f $1 ];then
        ln $1 $2
    else
        echo "Not a file or directory"
        return
    fi
}

#open file in gvim
function gvim() {
    if [ `uname -o` == "Cygwin" ];then
        if [ -n "$*" ];then
            args=`cygpath -w -- "$*"`
        else
            args=""
        fi
        cygstart -- /cygdrive/c/Program\ Files\ \(x86\)/Vim/vim73/gvim.exe "$args"
    else
        gvim "$*"
    fi
}

#--------environment variables--------
#set prompt
PS1='\u@\h:\w\$ '

#path
if [ -d $HOME/bin ];then
    export PATH=$PATH:$HOME/bin
fi

#debian packaging
DEBEMAIL=lainme993@gmail.com
DEBFULLNAME="lainme"
export DEBEMAIL DEBFULLNAME

#xterm-256
export TERM=xterm-256color

#editor
export EDITOR=vim

#bash completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

#chsdir
if [ -f $HOME/bin/chs_completion ];then
    . $HOME/bin/chs_completion
    complete -o filenames -F _filedir_xspec file
fi

#intel
if [ -f /home/data/software/intel/bin/compilervars.sh ];then
    source /home/data/software/intel/bin/compilervars.sh intel64
fi

#be evil
if [ -f $HOME/.evil_rc ];then
    source ~/.evil_rc
fi
