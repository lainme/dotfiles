#--------alias--------
#web
alias webon='lighttpd -f ~/.lighttpd.conf'
alias weboff='killall lighttpd'

#screen
alias scl='screen -ls'
alias scq='quitscr() { screen -X -S $1 quit; };quitscr'
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
fi

#color output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

#quick launch
if [ -d /home/data ];then
    alias ufs='vim -S /home/data/research/ufs/project.vim'
    alias sage='/home/data/software/sage/sage'
    alias sagenb='nohup /home/data/software/sage/sage -n open_viewer="False" port="4000" require_login="False" &> /dev/null &'
    alias tec360='/home/data/software/tecplot/bin/tec360'
fi
alias sshproxy='ssh -qTfnN -D 8707 vps'

#--------environment variables--------
#set prompt
PS1='\u@\h:\w\$ '

#path
export PATH=$PATH:$HOME/bin

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
. $HOME/bin/chs_completion
complete -o filenames -F _filedir_xspec file

#intel
if [ -f /home/data/software/intel/bin/compilervars.sh ];then
    source /home/data/software/intel/bin/compilervars.sh intel64
fi
