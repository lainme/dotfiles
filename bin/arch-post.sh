#!/bin/bash
# post-installation of Archlinux. Assume Dropbox directory is already in /tmp directory
#--------------------------------------------------
#special
#--------------------------------------------------
function show_help(){
    echo "DESCRIPTION: Archlinux post-installation script. Please run as root"
    echo "USAGE: arch-post.sh FUNCTION-NAME"
    echo "List of function:"
    echo "init              - fresh install, run all functions"
    echo "init_post         - initialize post installation (manually configuration needed)"
    echo "install_software  - install softwares"
    echo "settings_system   - change system settings"
    echo "settings_user     - change user settings"
    echo "install_mendeley  - install mendeley"
    echo "install_intel     - install Intel compiler"
    echo "symlink           - make symbol link"
}

function install_epstool(){
    #change directory
    cd /tmp

    #obtain pkgbuild
    yaourt -G epstool

    #change download link
    cd /tmp/epstool
    sed -i "s|\(source[^\"']*\)[^ ]*\(.*\)|\1 \"$EPSDLINK\" \2|" PKGBUILD

    #build/install
    makepkg PKGBUILD
    pacman -U --noconfirm epstool*.pkg.tar.xz

}

function mksymlink(){
    #arguments
    args=("$@")
    
    #regex
    if [ -z $3 ];then
        regex="/.*/p"
    else
        regex=$3
    fi

    #find all files
    files=(`find -L $1 -mindepth 1 -maxdepth 1 | sed -rn "$regex"`)

    for file in ${files[*]}; do
        #strip file name
        file=${file##*/}

        #delete existing
        if [ ! -h $2/$file ];then
            rm -rf $2/$file
        fi

        #make symbol link
        ln -sf $1/$file $2/
    done
}

function symlink(){
    #public 
    mksymlink $USERHOME/Dropbox $USERHOME "/Public/p"

    #home
    mksymlink $USERHOME/Dropbox/home $USERHOME

    #configuration
    mksymlink $USERHOME/config $USERHOME "/(\.config|\.gnome2|\.local)/d;p"
    mksymlink $USERHOME/config/.config $USERHOME/.config
    mksymlink $USERHOME/config/.gnome2 $USERHOME/.gnome2
    mksymlink $USERHOME/config/.local/share/gnome-shell $USERHOME/.local/share/gnome-shell "/extensions/p"
}

#--------------------------------------------------
#common tasks
#--------------------------------------------------
function init_post(){
    #--------------------------------------------------
    #add user
    #--------------------------------------------------
    #add networkmanager group
    groupadd networkmanager

    #add user
    useradd -m -g users -G audio,games,lp,optical,power,scanner,storage,video,wheel,networkmanager,network -s /bin/bash $USERNAME
    
    #--------------------------------------------------
    #initialize package manager
    #--------------------------------------------------
    #mv Dropbox dir
    mv /tmp/Dropbox $USERHOME/Dropbox
    chown $USERNAME:users -R $USERHOME/Dropbox

    #configure pacman
    cp $USERHOME/Dropbox/sysconf/pacman/mirrorlist  > /etc/pacman.d/mirrorlist
    cp $USERHOME/Dropbox/sysconf/pacman/pacman.conf > /etc/pacman.conf

    #install necessary package
    pacman -Syu --noconfirm yaourt linux-headers sudo

    #--------------------------------------------------
    #configure user
    #--------------------------------------------------
    #setup password
    passwd $USERNAME

    #configure sudo
    visudo
}

function install_software(){
    #--------------------------------------------------
    #Xorg and drivers
    #--------------------------------------------------
    #Xorg
    yaourt -S --noconfirm xorg-server xorg-xinit xorg-server-utils xorg-xprop mesa

    #video drivers (open source)
    yaourt -S --noconfirm xf86-video-intel libva-driver-intel 
    yaourt -S --noconfirm xf86-video-nouveau xf86-video-ati xf86-video-vesa #compatibility

    #touchpad
    yaourt -S --noconfirm xf86-input-synaptics

    #--------------------------------------------------
    #desktop environment
    #--------------------------------------------------
    #gnome-shell essential
    yaourt -S --noconfirm gnome-control-center gnome-shell gnome-themes-standard gdm gnome-keyring xdg-user-dir
    yaourt -S --noconfirm nautilus nautilus-open-terminal
    yaourt -S --noconfirm ntfs-3g ntfsprogs

    #interface
    yaourt -S --noconfirm faenza-icon-theme
    yaourt -S --noconfirm wqy-microhei
    yaourt -S --noconfirm freetype2-ubuntu fontconfig-ubuntu libxft-ubuntu cairo-ubuntu 

    #utils
    yaourt -S --noconfirm lm_sensors hddtemp base-completion net-tools ntp openssh gparted
    yaourt -S --noconfirm os-prober #for multiple OS

    #laptop
    yaourt -S --noconfirm tlp ethtool smartmontools tlp-rdw 
    yaourt -S --noconfirm thinkfan acpi_call-git tp_smapi #Thinkpad only

    #--------------------------------------------------
    #development tools
    #--------------------------------------------------
    #AUR
    yaourt -S --noconfirm nampcap 

    #personal
    yaourt -S --noconfirm git python gcc-fortran python-matplotlib-git doxygen graphviz
    yaourt -S --noconfirm lighttpd php-cgi php-gd php-sqlite

    #--------------------------------------------------
    #other softwares
    #--------------------------------------------------
    #Video and Audio
    yaourt -S --noconfirm mpd mpc
    yaourt -S --noconfirm mplayer-vaapi gnome-mplayer 

    #IM
    yaourt -S --noconfirm skype lib32-libpulse
    yaourt -S --noconfirm pidgin pidgin-lwqq-git gnome-shell-pidgin
    yaourt -S --noconfirm irssi

    #Text editing/processing
    yaourt -S --noconfirm texlive-latexextra rubber latex-beamer-ctan minted
    yaourt -S --noconfirm gvim ctags

    #other
    yaourt -S --noconfirm xbindkeys scrot xsel  #scripts
    yaourt -S --noconfirm evince poppler-data #PDF
    yaourt -S --noconfirm file-roller p7zip archive-mounter #archiver
    yaourt -S --noconfirm fcitx-gtk3 fcitx-configtool fcitx-cloudpinyin fcitx-googlepinyin fcitx-gtk2 #input method
    yaourt -S --noconfirm firefox chromium flashplugin icedtea-web-java7 aliedit #browser
    yaourt -S --noconfirm eog gimp inkscape #photo
    yaourt -S --noconfirm dropbox nautilus-dropbox #dropbox
    yaourt -S --noconfirm hotot-gtk3-git screen aria2 conky-lua xterm #misc

    #special
    install_epstool
}

function settings_system(){
   #networkmanager
   mkdir -p /etc/polkit-1/localauthority/50-local.d
   cp $USERHOME/Dropbox/sysconf/org.freedesktop.NetworkManager.pkla /etc/polkit-1/localauthority/50-local.d/

   #Thinkfan
   cp $USERHOME/Dropbox/sysconf/modprobe.conf /etc/modprobe.d/
   cp $USERHOME/Dropbox/sysconf/thinkfan.conf /etc/

   #grub
   cp $USERHOME/Dropbox/sysconf/grub.conf /etc/default/grub 
   grub-mkconfig -o /boot/grub/grub.cfg

   #other
   cp -r $USERHOME/Dropbox/sysconf/font-config /etc/fonts #Ubuntu font configuration
   cp $USERHOME/Dropbox/sysconf/rc.conf /etc/ #rc.conf
   (while :; do echo ""; done ) | sensors-detect #sensors setup

}

function settings_user(){
    #symbol link   
    symlink
    
    #update user directory
    sudo -u $USERNAME xdg-user-dirs-update

    #avatar
    sudo cp $USERHOME/Pictures/avatar/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME
    sudo cp $USERHOME/Dropbox/sysconf/gnome-account.conf /var/lib/AccountsService/users/$USERNAME
}

#--------------------------------------------------
#local software
#--------------------------------------------------
function install_mendeley(){
    #pre-request
    yaourt -S --noconfirm libpng12

    #download
    sudo -u $USERNAME aria2c http://www.mendeley.com/client/get/100-2/ -d $USERDOWN

    #install
    sudo -u $USERNAME tar -xjf $USERDOWN/mendeleydesktop* -C $USERSOFT
    sudo -u $USERNAME mv $USERSOFT/mendeleydesktop* $USERSOFT/mendeley
    sudo -u $USERNAME cp $USERSOFT/mendeley/share/applications/mendeleydesktop.desktop $USERHOME/.local/share/applications/
    sudo -u $USERNAME cp -r $USERSOFT/mendeley/share/icons/ $USERHOME/.local/share/icons/
    sudo -u $USERNAME ln -s $USERSOFT/mendeley/bin/mendeleydesktop $USERHOME/.local/share/mendeleydesktop
}

function install_intel(){
    #pre-request
    yaourt -S --noconfirm cpio

    #download
    sudo -u $USERNAME aria2c http://registrationcenter-download.intel.com/akdlm/irc_nas/$INTELNUM/l_fcompxe_intel64_$INTELVER.tgz -d $USERDOWN

    #install
    sudo -u $USERNAME tar -xzf $USERDOWN/l_fcompxe_intel64_$INTELVER.tgz -C $USERDOWN
    sudo -u $USERNAME mkdir -p $USERHOME/intel
    sudo -u $USERNAME cp $USERHOME/Dropbox/sysconf/intel/licenses $USERHOME/intel/
    sudo -u $USERNAME sed -i "s|\(PSET_INSTALL_DIR\).*|\1=$USERSOFT/intel|" $USERHOME/Dropbox/sysconf/intel/install.ini
    sudo -u $USERNAME $USERDOWN/l_fcompxe_intel64_$INTELVER/install.sh --silent $USERHOME/Dropbox/sysconf/intel/install.ini
}

#--------------------------------------------------
#sequence
#--------------------------------------------------
function init(){
    init_post
    install_software
    settings_system
    settings_user
    install_mendeley
    install_intel
}

#--------------------------------------------------
#main
#--------------------------------------------------
#main configuration
USERNAME=lainme #user name
USERHOME=/home/$USERNAME #user home directory
USERDOWN=/home/$USERNAME/Downloads #download directory
USERSOFT=/home/$USERNAME/software  #local software directory

#Intel
INTELNUM=2671
INTELVER=2011.11.339

#epstool
EPSDLINK="http://archive.ubuntu.com/ubuntu/pool/universe/e/epstool/epstool_3.08+repack.orig.tar.gz"

if [ -z $1 ];then
    show_help
else
    $1
fi
