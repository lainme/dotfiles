#!/bin/bash
#
# Softwares require manual installation:
#   cow, dropbox, mendeley, inconsolata, graphical card driver (if needed), faenza-icon-theme, wps-office, skype

#--------------------------------------------------
# helper functions
#--------------------------------------------------
function helper_command(){
    echo -e "DESCRIPTION: CentOS installation script. Most functionalities requires root permissions"
    echo -e "USAGE: autoinstall-centos.sh FUNCTION-NAME"
    echo -e ""
    echo -e "\tconfigure   - configure system"
}

function helper_symlink(){
    args=("$@")

    if [ -z $3 ];then
        regex="/.*/p"
    else
        regex=$3
    fi

    # target dir
    $RUNASUSR mkdir -p $2

    OIFS="$IFS"
    IFS=$'\n'
    for file in `find -L $1 -mindepth 1 -maxdepth 1 | sed -rn "$regex"`; do
        IFS="$OIFS"

        # strip file name
        file=${file##*/}

        # delete existing
        if [ ! -h "$2/$file" ];then
            rm -rf "$2/$file"
        fi

        # make symbol link
        $RUNASUSR ln -sf "$1/$file" $2/

        IFS=$'\n'
    done
    IFS="$OIFS"
}

#--------------------------------------------------
# functions in configure
#--------------------------------------------------
function setup_package(){
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
    rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
    rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm
    wget https://copr.fedorainfracloud.org/coprs/librehat/shadowsocks/repo/epel-7/librehat-shadowsocks-epel-7.repo -O /etc/yum.repos.d/librehat-shadowsocks-epel-7.repo

    #--------------------------------------------------
    # others
    #--------------------------------------------------
    yum install ufw shadowsocks-libev # network tools
    yum install ntfs-3g # disk tools
    yum install bash-completion-extras xterm screen # other tools
    yum install doxygen graphviz # development tools
    yum install im-chooser fcitx fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 fcitx-configtool fcitx-configtool # IME
    yum install vim-X11 ctags # text editor
    yum install p7zip # archiver
    yum install gnome-mplayer # video and audio
    yum install gimp inkscape # image
    yum install rubber libreoffice # office
    yum install aria2 filezilla subversion subversion-gnome git-svn # file transfers
    yum install xsel # script
}

function setup_system(){
    cp -r $USERHOME/Dropbox/system/fontconfig/* /etc/fonts/conf.d
    cp -r $USERHOME/Dropbox/system/common/wgetrc /etc/wgetrc

    # network
    sed -i "s/\(GRUB_CMDLINE_LINUX.*\)\"/\1 net.ifnames=0 biosdevname=0\"/" /etc/default/grub
    grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

    # ufw
    ufw enable
    ufw default deny

    # systemd services
    systemctl enable ufw
}

function setup_person(){
    helper_symlink $USERHOME/Dropbox/home $USERHOME "/(\.config$|\.local$|\.cow$|\.ssh$|\.gitignore$|\.subversion$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.local/share              $USERHOME/.local/share "/(data$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.local/share/data         $USERHOME/.local/share/data
    helper_symlink $USERHOME/Dropbox/home/.config                   $USERHOME/.config
    helper_symlink $USERHOME/Dropbox/home/.cow                      $USERHOME/.cow
    helper_symlink $USERHOME/Dropbox/home/.ssh                      $USERHOME/.ssh
    helper_symlink $USERHOME/Dropbox/home/.subversion               $USERHOME/.subversion

    # avatar
    cp $USERHOME/Dropbox/system/account/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME

    # fix background locating
    mkdir -p $USERHOME/.cache/gnome-control-center
    ln -sf $USERHOME/Pictures/Wallpapers $USERHOME/.cache/gnome-control-center/backgrounds

    # ssh client
    $RUNASUSR ssh-keygen -t rsa
}

function setup_homeserv(){
    echo "SSH: port for ssh-server"
    read port
    ufw allow $port

    conf="Protocol 2\nPort $port\n"
    conf="$conf\nChallengeResponseAuthentication no\nPasswordAuthentication no\nPermitRootLogin no\nServerKeyBits 2048\n"
    conf="$conf\nAllowGroups $USERNAME\nAllowUsers $USERNAME\n"
    conf="$conf\nSubsystem sftp /usr/lib/openssh/sftp-server"
    echo -e $conf > /etc/ssh/sshd_config
    systemctl restart sshd

    # ddns
    command="*/5 * * * * $USERHOME/bin/ddns.sh &> /dev/null"
    (echo "$command") | crontab -u $USERNAME -
}

#--------------------------------------------------
# main functions
#--------------------------------------------------
function configure(){
    setup_package
    setup_system
    setup_person

    if [ "$HOMESERV" == "1" ];then
        setup_homeserv
    fi
}

#--------------------------------------------------
# main
#--------------------------------------------------
# main configuration
USERNAME=lainme
USERHOME=/home/$USERNAME

# switching configuration
HOMESERV=1

# installation commands
RUNASUSR="sudo -u $USERNAME"

if [ -z $1 ];then
    helper_command
else
    $@
fi
