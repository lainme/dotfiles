#!/bin/bash
#
# Softwares require manual installation:
#   1.  Inconsolata (https://www.archlinux.org/packages/community/any/ttf-inconsolata/)
#   2.  Faenza-icon-theme (https://www.archlinux.org/packages/community/any/faenza-icon-theme/)
#   3.  Stow (https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz)
#   4.  ADB (https://developer.android.com/studio/releases/platform-tools)
#   5.  Cow (https://github.com/cyfdecyf/cow)
#   6.  Doxygen (https://github.com/doxygen/doxygen.git)
#   7.  GCC (http://mirror.bjtu.edu.cn/gnu/gcc)
#   8.  GLIBC (https://ftp.gnu.org/gnu/glibc)
#   9.  Mendeley (https://www.mendeley.com/download-desktop/)
#   10  Paraview (https://www.paraview.org/download/)
#   11. Rubber (https://launchpad.net/rubber)
#   12. Sage (https://www.sagemath.org/download-linux.html)
#   13. Skype (https://repo.skype.com/latest)
#   14. Texlive (https://www.tug.org/texlive/acquire-netinstall.html)
#   15. Dropbox (upgradedropbox.sh)
#   16. Google chrome (https://www.google.com/chrome/)
#   17. WPS (http://www.wps.cn/product/wpslinux/)
#   18. Teamviewer (https://www.teamviewer.com/en-us/download/linux/)
#   19. Zoom (https://us02web.zoom.us/download)
#   20. Mailspring (https://getmailspring.com/download)

#--------------------------------------------------
# helper functions
#--------------------------------------------------
function helper_command() {
    echo -e "DESCRIPTION: CentOS installation script. Most functionalities requires root permissions"
    echo -e "USAGE: autoinstall-centos.sh FUNCTION-NAME"
    echo -e ""
    echo -e "\tconfigure   - configure system"
}

function helper_symlink() {
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
function installer_ttf-inconsolata() {
    PKGNAME=ttf-inconsolata

    rm -rf /tmp/$PKGNAME*
    mkdir -p /tmp/$PKGNAME
    wget -O /tmp/$PKGNAME.tar.xz https://www.archlinux.org/packages/community/any/$PKGNAME/download/
    tar -xf /tmp/$PKGNAME.tar.xz -C /tmp/$PKGNAME

    cp -r /tmp/$PKGNAME/etc/fonts/conf.avail/* /etc/fonts/conf.d/
    cp -r /tmp/$PKGNAME/usr/share/fonts/* /usr/share/fonts/
}

function installer_faenza-icon-theme() {
    PKGNAME=faenza-icon-theme

    rm -rf /tmp/$PKGNAME*
    mkdir -p /tmp/$PKGNAME
    wget -O /tmp/$PKGNAME.tar.xz https://www.archlinux.org/packages/community/any/$PKGNAME/download/
    tar -xf /tmp/$PKGNAME.tar.xz -C /tmp/$PKGNAME

    cp -r /tmp/$PKGNAME/usr/* /usr/

    $RUNASUSR gsettings set org.gnome.desktop.interface icon-theme 'Faenza'
}

function installer_stow() {
    PKGNAME=stow

    $RUNASUSR mkdir -p $USERHOME/software/util/bin
    $RUNASUSR ln -sf $USERHOME/Dropbox/home/software/util/bin/$PKGNAME $USERHOME/software/util/bin/
    $RUNASUSR cd $USERHOME/software
    $RUNASUSR util/bin/$PKGNAME util
}

function installer_android() {
    PKGNAME=android

    snap install scrcpy

    $RUNASUSR mkdir -p $USERHOME/software/$PKGNAME/bin
    $RUNASUSR mkdir -p $USERHOME/software/$PKGNAME/share/$PKGNAME
    $RUNASUSR echo '#!/bin/bash' > $USERHOME/software/$PKGNAME/bin/adb
    $RUNASUSR echo '$HOME/software/android/share/android/adb $@' >> $USERHOME/software/$PKGNAME/bin/adb
    $RUNASUSR echo '#!/bin/bash' > $USERHOME/software/$PKGNAME/bin/android-connect
    $RUNASUSR echo 'ADB=$HOME/software/android/share/android/adb scrcpy $@' >> $USERHOME/software/$PKGNAME/bin/android-connect
    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME

    echo "Installing $PKGNAME: please install the package manually"
    echo "PATH: $USERHOME/software/$PKGNAME/share/$PKGNAME"
    echo "URL: https://developer.android.com/studio/releases/platform-tools"
    read -p "Enter to continue"
}

function installer_cow() {
    PKGNAME=cow

    $RUNASUSR cd /tmp
    $RUNASUSR wget git.io/$PKGNAME

    $RUNASUSR bash $PKGNAME

    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME
}

function installer_doxygen() {
    PKGNAME=doxygen

    $RUNASUSR cd /tmp
    $RUNASUSR rm -rf /tmp/$PKGNAME*
    $RUNASUSR git clone https://github.com/$PKGNAME/$PKGNAME.git

    $RUNASUSR mkdir -p $USERHOME/software
    $RUNASUSR cd /tmp/$PKGNAME
    $RUNASUSR mkdir build
    $RUNASUSR cd build
    $RUNASUSR cmake -DCMAKE_INSTALL_PREFIX=$USERHOME/software/$PKGNAME ..
    $RUNASUSR make
    $RUNASUSR make install

    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME
}

function installer_gcc() {
    PKGNAME=gcc-8.2.0

    $RUNASUSR rm -rf /tmp/$PKGNAME*
    $RUNASUSR mkdir -p /tmp/$PKGNAME
    $RUNASUSR wget -O /tmp/$PKGNAME.tar.gz https://mirror.bjtu.edu.cn/gnu/gcc/$PKGNAME/$PKGNAME.tar.gz
    $RUNASUSR tar -xf /tmp/$PKGNAME.tar.gz -C /tmp/$PKGNAME

    $RUNASUSR mkdir -p $USERHOME/software
    $RUNASUSR cd /tmp/$PKGNAME
    $RUNASUSR mkdir build
    $RUNASUSR cd build
    $RUNASUSR ../configure --enable-languages=c,c++,fortran --prefix=$USERHOME/software/$PKGNAME
    $RUNASUSR make
    $RUNASUSR make install

    $RUNASUSR mkdir -p $USERHOME/software/modulefiles/compiler
    $RUNASUSR ln -sf $USERHOME/Dropbox/home/software/modulefiles/compiler/$PKGNAME $USERHOME/software/modulefiles/compiler/
}

function installer_glibc() {
    PKGNAME=glibc-2.27

    $RUNASUSR rm -rf /tmp/$PKGNAME*
    $RUNASUSR mkdir -p /tmp/$PKGNAME
    $RUNASUSR wget -O /tmp/$PKGNAME.tar.gz https://ftp.gnu.org/gnu/glibc/$PKGNAME.tar.gz
    $RUNASUSR tar -xf /tmp/$PKGNAME.tar.gz -C /tmp/$PKGNAME

    $RUNASUSR mkdir -p $USERHOME/software
    $RUNASUSR cd /tmp/$PKGNAME
    $RUNASUSR mkdir build
    $RUNASUSR cd build
    $RUNASUSR ../configure --prefix=$USERHOME/software/$PKGNAME
    $RUNASUSR make
    $RUNASUSR make install
}

function installer_mendeley() {
    PKGNAME=mendeley

    $RUNASUSR rm -rf /tmp/$PKGNAME*
    $RUNASUSR wget -O /tmp/$PKGNAME.tar.bz2 https://www.mendeley.com/autoupdates/installer/Linux-x64/stable-incoming

    $RUNASUSR mkdir -p $USERHOME/software
    $RUNASUSR tar -xf /tmp/$PKGNAME.tar.bz2 -C $USERHOME/software/$PKGNAME
}

function installer_paraview() {
    PKGNAME=paraview

    $RUNASUSR mkdir -p $USERHOME/software/$PKGNAME/bin
    $RUNASUSR mkdir -p $USERHOME/software/$PKGNAME/share/$PKGNAME
    $RUNASUSR echo '#!/bin/bash' > $USERHOME/software/$PKGNAME/bin/$PKGNAME
    $RUNASUSR echo 'cd $HOME/software/paraview/share/paraview/bin/' >> $USERHOME/software/$PKGNAME/bin/$PKGNAME
    $RUNASUSR echo './paraview $@' >> $USERHOME/software/$PKGNAME/bin/$PKGNAME

    echo "Installing $PKGNAME: please install the package manually"
    echo "PATH: $USERHOME/software/$PKGNAME/share/$PKGNAME"
    echo "URL: https://www.paraview.org/download/"
    read -p "Enter to continue"

    $RUNASUSR cd $USERHOME/software/$PKGNAME/share
    $RUNASUSR ln -s $PKGNAME/share/applications .
    $RUNASUSR ln -s $PKGNAME/share/icons .
    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME
}

function installer_rubber() {
    PKGNAME=rubber

    $RUNASUSR rm -rf /tmp/$PKGNAME*
    $RUNASUSR mkdir -p /tmp/$PKGNAME
    $RUNASUSR wget -O /tmp/$PKGNAME.tar.gz https://launchpad.net/rubber/trunk/1.5.1/+download/rubber-1.5.1.tar.gz
    $RUNASUSR tar -xf /tmp/$PKGNAME.tar.gz -C /tmp/$PKGNAME

    $RUNASUSR mkdir -p $USERHOME/software
    $RUNASUSR cd /tmp/$PKGNAME
    $RUNASUSR python setup.py install --prefix=$USERHOME/software/$PKGNAME

    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME
}

function installer_sage() {
    PKGNAME=sage

    $RUNASUSR mkdir -p $USERHOME/software/$PKGNAME/bin
    $RUNASUSR mkdir -p $USERHOME/software/$PKGNAME/share/$PKGNAME
    $RUNASUSR echo '#!/bin/bash' > $USERHOME/software/$PKGNAME/bin/$PKGNAME
    $RUNASUSR echo '$HOME/software/sage/share/sage/bin/sage $@' >> $USERHOME/software/$PKGNAME/bin/$PKGNAME

    echo "Installing $PKGNAME: please install the package manually"
    echo "PATH: $USERHOME/software/$PKGNAME/share/$PKGNAME"
    echo "URL: http://mirror.hust.edu.cn/sagemath/linux/64bit/index.html"
    read -p "Enter to continue"
}

function installer_skype() {
    PKGNAME=skype

    $RUNASUSR wget -O /tmp/skypeforlinux-64.rpm https://repo.skype.com/latest/skypeforlinux-64.rpm
    yum install /tmp/skypeforlinux-64.rpm

    chmod 4755 /usr/share/skypeforlinux/chrome-sandbox

    $RUNASUSR ln -sf $USERHOME/Dropbox/home/software/$PKGNAME $USERHOME/software/
    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME
}

function installer_texlive() {
    PKGNAME=texlive

    echo "Installing $PKGNAME: please install the package manually"
    echo "PATH: $USERHOME/software/$PKGNAME"
    echo "URL: https://www.tug.org/texlive/acquire-netinstall.html"
    read -p "Enter to continue"
}

function installer_dropbox() {
    PKGNAME=dropbox

    $RUNASUSR $USERHOME/bin/upgradedropbox.sh

    $RUNASUSR mkdir -p $USERHOME/software/util/bin
    $RUNASUSR ln -sf $USERHOME/Dropbox/home/software/util/bin/dropboxd $USERHOME/software/util/bin/
    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow util
}

function installer_chrome() {
    PKGNAME=google-chrome

    echo "Installing $PKGNAME: please install the package manually"
    echo "URL: https://www.google.com/chrome/"
    read -p "Enter to continue"
}

function installer_wps() {
    PKGNAME=wps-office

    echo "Installing $PKGNAME: please install the package manually"
    echo "URL: http://www.wps.cn/product/wpslinux/"
    read -p "Enter to continue"
}

function installer_teamviewer() {
    PKGNAME=teamviewer

    echo "Installing $PKGNAME: please install the package manually"
    echo "URL: https://www.teamviewer.com/en-us/download/linux/"
    read -p "Enter to continue"
}

function installer_zoom() {
    PKGNAME=zoom

    echo "Installing $PKGNAME: please install the package manually"
    echo "URL: https://us02web.zoom.us/download"
    read -p "Enter to continue"
}

function installer_mailspring() {
    PKGNAME=mailspring

    echo "Installing $PKGNAME: please install the package manually"
    echo "URL: https://getmailspring.com/download"
    read -p "Enter to continue"
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
    yum-config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo
    wget https://copr.fedorainfracloud.org/coprs/librehat/shadowsocks/repo/epel-7/librehat-shadowsocks-epel-7.repo -O /etc/yum.repos.d/librehat-shadowsocks-epel-7.repo
    sed -i 's|^#baseurl=http://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
    sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

    #--------------------------------------------------
    # Xorg and drivers
    #--------------------------------------------------
    yum groupinstall 'X Window System'

    #--------------------------------------------------
    # desktop environment
    #--------------------------------------------------
    yum install gdm nautilus xdg-user-dirs
    yum install gnome-backgrounds wqy-microhei-fonts dejavu-sans-mono-fonts
    yum install gnome-tweak-tool

    #--------------------------------------------------
    # others
    #--------------------------------------------------
    yum install file-roller-nautilus # desktop environment
    yum install ufw shadowsocks-libev # network tools
    yum install ntfs-3g # disk tools
    yum install bash-completion-extras xterm screen # other tools
    yum install ibus ibus-gtk2 ibus-gtk3 ibus-qt ibus-libpinyin # IME
    yum install vim vim-X11 ctags # text editor
    yum install p7zip # archiver
    yum install gimp # image
    yum install firefox flash-plugin # browser
    yum install filezilla subversion subversion-gnome git-svn # file transfers
    yum install xsel # script
    yum install stow snapd # package management
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
    systemctl enable ufw

    # snapd
    systemctl enable --now snapd.socket
    ln -s /var/lib/snapd/snap /snap
}

function setup_person_symlink(){
    helper_symlink $USERHOME/Dropbox/home $USERHOME "/(\.config$|\.cow$|\.git$|\.gitignore$|\.local$|\.sage$|software$|\.ssh$|\.subversion$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.config           $USERHOME/.config "/(dconf$|fcitx$|mpd$|nautilus$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.cow              $USERHOME/.cow
    helper_symlink $USERHOME/Dropbox/home/.local/share/data $USERHOME/.local/share/data
    helper_symlink $USERHOME/Dropbox/home/.sage             $USERHOME/.sage
    helper_symlink $USERHOME/Dropbox/home/.ssh              $USERHOME/.ssh
    helper_symlink $USERHOME/Dropbox/home/.subversion       $USERHOME/.subversion
}

function setup_person(){
    setup_person_symlink

    # avatar
    mkdir -p /var/lib/AccountsService/icons/$USERHOME
    cp $USERHOME/Dropbox/home/Pictures/avatar/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME

    # fix background locating
    $RUNASUSR mkdir -p $USERHOME/.cache/gnome-control-center
    $RUNASUSR ln -sf $USERHOME/Pictures/Wallpapers $USERHOME/.cache/gnome-control-center/backgrounds

    # fix vim
    $RUNASUSR mkdir -p $USERHOME/software/util/bin
    $RUNASUSR ln -sf /usr/bin/vimx $USERHOME/software/util/bin/vim

    # ssh client
    $RUNASUSR ssh-keygen -t rsa
    chmod 600 $USERHOME/.ssh/*

    # shadowsocks addon
    $RUNASUSR mkdir -p $USERHOME/software/
    $RUNASUSR ln -sf $USERHOME/Dropbox/home/software/v2ray-plugin $USERHOME/software/
}

function setup_homeserv(){
    echo "SSH: port for ssh-server"
    read port
    ufw allow $port

    conf="Protocol 2\nPort $port\n"
    conf="$conf\nChallengeResponseAuthentication no\nPasswordAuthentication no\nPermitRootLogin no\nX11Forwarding yes\n"
    conf="$conf\nAllowGroups $USERNAME\nAllowUsers $USERNAME\n"
    conf="$conf\nSubsystem sftp /usr/lib/openssh/sftp-server"
    echo -e $conf > /etc/ssh/sshd_config
    systemctl enable sshd
    systemctl start sshd

    # SSH tunnel
    yum install autossh
    $RUNASUSR ln -sf $USERHOME/Dropbox/home/software/util/bin/remote-exchange.sh $USERHOME/software/util/bin/
    $RUNASUSR cd $USERHOME/software
    $RUNASUSR stow $PKGNAME
    cp $USERHOME/Dropbox/system/common/remote-exchange.service /etc/systemd/system/
    systemctl enable remote-exchange.service
    systemctl start remote-exchange.service

    # Xrdp
    yum install xrdp
    yum install mate-desktop mate-settings-daemon
    $RUNASUSR echo 'mate-session' > $USERHOME/.Xclients
    cp $USERHOME/Dropbox/system/xrdp/xrdp.ini /etc/xrdp/
    cp $USERHOME/Dropbox/system/xrdp/sesman.ini /etc/xrdp/
    cp $USERHOME/Dropbox/system/common/99-sysctl.conf /etc/sysctl.d/
    systemctl enable xrdp
    systemctl start xrdp
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
