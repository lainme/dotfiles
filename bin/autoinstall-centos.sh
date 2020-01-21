#!/bin/bash
#
# Softwares require manual installation:
#   1. USB wireless driver (https://github.com/gnab/rtl8812au)
#   2. Dropbox (https://lorenzo.mile.si/dropbox-on-centos7-requires-glibc-2-19/828/)
#   3. Mendeley (https://www.mendeley.com/download-desktop/)
#   4. Inconsolata (https://www.archlinux.org/packages/community/any/ttf-inconsolata/)
#   5. Faenza-icon-theme (https://www.archlinux.org/packages/community/any/faenza-icon-theme/)
#   6. WPS (http://www.wps.cn/product/wpslinux/)
#   7. Skype (https://repo.skype.com/latest)
#   8. Texlive (https://www.tug.org/texlive/acquire-netinstall.html)
#   9. Rubber (https://launchpad.net/rubber)
#   10. Cow (https://github.com/cyfdecyf/cow)
#   11. Graphical driver
#   12. Paraview
#   13. GCC

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
# functions for manual installation
#--------------------------------------------------
function installer_ttf-inconsolata(){
    PKGNAME=ttf-inconsolata
    rm -rf /tmp/$PKGNAME*
    mkdir -p /tmp/$PKGNAME
    wget -O /tmp/$PKGNAME.tar.xz https://www.archlinux.org/packages/community/any/$PKGNAME/download/
    tar -xf $PKGNAME.tar.xz -C /tmp/$PKGNAME
    cp -r /tmp/$PKGNAME/etc/fonts/conf.avail/* /etc/fonts/conf.d/
    cp -r /tmp/$PKGNAME/usr/share/fonts/* /usr/share/fonts/
}

function installer_faenza-icon-theme(){
    PKGNAME=faenza-icon-theme
    rm -rf /tmp/$PKGNAME*
    mkdir -p /tmp/$PKGNAME
    wget -O /tmp/$PKGNAME.tar.xz https://www.archlinux.org/packages/community/any/$PKGNAME/download/
    tar -xf $PKGNAME.tar.xz -C /tmp/$PKGNAME
    cp -r /tmp/$PKGNAME/usr/* /usr/
    $RUNASUSR gsettings set org.gnome.desktop.interface icon-theme 'Faenza'
}

function installer_dropbox(){
    PKGNAME=dropbox
    mkdir -p $USERHOME/.software/bin
    ln -sf $USERHOME/software/dropbox/dropboxd $USERHOME/.software/bin/
}

#--------------------------------------------------
# functions in configure
#--------------------------------------------------
function setup_package(){
    #--------------------------------------------------
    # prepare
    #--------------------------------------------------
    yum remove firewalld yelp
    yum install wget
    yum update
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
    rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
    rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
    wget https://copr.fedorainfracloud.org/coprs/librehat/shadowsocks/repo/epel-7/librehat-shadowsocks-epel-7.repo -O /etc/yum.repos.d/librehat-shadowsocks-epel-7.repo

    #--------------------------------------------------
    # Xorg and drivers
    #--------------------------------------------------
    yum groupinstall 'X Window System'

    #--------------------------------------------------
    # desktop environment
    #--------------------------------------------------
    yum install gdm nautilus xdg-user-dirs
    yum install gnome-backgrounds wqy-microhei-fonts dejavu-sans-mono-fonts
    yum install gnome-tweak-tool gnome-shell-extension-top-icons

    #--------------------------------------------------
    # others
    #--------------------------------------------------
    yum install file-roller-nautilus # desktop environment
    yum install ufw shadowsocks-libev dnsmasq # network tools
    yum install ntfs-3g # disk tools
    yum install bash-completion-extras xterm screen # other tools
    yum install gcc doxygen graphviz cmake3 openmpi3 # development tools
    yum install im-chooser fcitx fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 fcitx-configtool fcitx-pinyin # IME
    yum install vim vim-X11 ctags # text editor
    yum install p7zip # archiver
    yum install gnome-mplayer # video and audio
    yum install gimp inkscape # image
    yum install firefox # browser
    yum install libreoffice # office
    yum install aria2 filezilla subversion subversion-gnome git-svn # file transfers
    yum install xsel # script
}

function setup_system(){
    cp -r $USERHOME/Dropbox/system/fontconfig/* /etc/fonts/conf.d
    cp -r $USERHOME/Dropbox/system/common/wgetrc /etc/wgetrc

    # network
    sed -i "s/\(GRUB_CMDLINE_LINUX.*\)\"/\1 net.ifnames=0 biosdevname=0\"/" /etc/default/grub
    grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

    # disable selinux
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

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
    mkdir -p /var/lib/AccountsService/icons/$USERHOME
    cp $USERHOME/Dropbox/home/Pictures/avatar/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME

    # fix background locating
    $RUNASUSR mkdir -p $USERHOME/.cache/gnome-control-center
    $RUNASUSR ln -sf $USERHOME/Pictures/Wallpapers $USERHOME/.cache/gnome-control-center/backgrounds

    # fix input method selection
    mv /etc/xdg/autostart/org.gnome.SettingsDaemon.Keyboard.desktop /etc/xdg/autostart/org.gnome.SettingsDaemon.Keyboard.desktop.backup
    $RUNASUSR im-chooser
    mv /etc/xdg/autostart/org.gnome.SettingsDaemon.Keyboard.desktop.backup /etc/xdg/autostart/org.gnome.SettingsDaemon.Keyboard.desktop
    $RUNASUSR gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['']"
    $RUNASUSR gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward  "['']"

    # ssh client
    $RUNASUSR ssh-keygen -t rsa
    chmod 600 $USERHOME/.ssh/*
}

function setup_homeserv(){
    # sshd
    echo "SSH: port for ssh-server"
    read port
    ufw allow $port

    conf="Protocol 2\nPort $port\n"
    conf="$conf\nChallengeResponseAuthentication no\nPasswordAuthentication no\nPermitRootLogin no\nX11Forwarding yes\n"
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
