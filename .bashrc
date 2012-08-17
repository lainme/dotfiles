#--------------------------------------------------
#alias
#--------------------------------------------------
#web
alias webon='lighttpd -f $HOME/.lighttpd.conf'
alias weboff='killall lighttpd'

#screen
alias scl='screen -ls'
alias scq='quitscr'
alias scr='screen -raAd'

#software
alias s-install='yaourt -S'
alias s-purge='yaourt -Rsn'
alias s-search='yaourt -Ss'
alias s-show='yaourt -Si'
alias s-update='yaourt -Sy'
alias s-upgrade='yaourt -Syu'
alias s-clean='yaourt -Sc'
alias s-full-upgrade='yaourt -Syua'
alias s-full-clean='yaourt -Scc'

#color output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

#quick launch
alias sshproxy='ssh -qTfnN -D 8707 vps'

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
export PS1='\u@\h:\w\$ '

#debian packaging
export DEBEMAIL=lainme993@gmail.com
export DEBFULLNAME="lainme"

#xterm-256
export TERM=xterm-256color

#editor
export EDITOR=vim

#path
export PATH=$PATH:$HOME/bin

#--------------------------------------------------
#others
#--------------------------------------------------
#chsdir
source $HOME/bin/chs_completion
complete -o filenames -F _filedir_xspec file

#be evil
source ~/.evil_rc
