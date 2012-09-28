#!/bin/bash
# post-installation of Archlinux. Assume this script and Dropbox directory is already in /tmp directory
# TODO:
# 1. video driver selection with hardware acceleration setup
# 2. user configuration file modification
# 3. thinkpad/other switch
# 4. recommends software list

#--------------------------------------------------
#helper
#--------------------------------------------------
function show_help(){
    echo -e "DESCRIPTION: Archlinux post-installation script. Please run as root"
    echo -e "USAGE: arch-post.sh FUNCTION-NAME"
    echo -e "Main functions:"
    echo -e ""
    echo -e "\tconfigure_system    - configur system when installing"
    echo -e "\tinit                - run all post-install functions"
    echo -e ""
    echo -e "Core functions:"
    echo -e ""
    echo -e "\tinit_post           - initialize post installation"
    echo -e "\tinstall_software    - install softwares"
    echo -e "\tsettings_system     - change system settings"
    echo -e "\tsettings_user       - change user settings"
    echo -e "\tvbox_guest          - install virtualbox guest additions"
    echo -e ""
    echo -e "Individual software installation functions:"
    echo -e ""
    echo -e "\tinstall_yaourt      - install yaourt"
    echo -e "\tinstall_epstool     - install epstool"
    echo -e "\tinstall_mendeley    - install mendeley"
    echo -e "\tinstall_intel       - install Intel compiler"
    echo -e ""
    echo -e "Misc functions:"
    echo -e ""
    echo -e "\tsymlink             - make symbol link"
}

function yaourt_install(){
    #arguments
    args=("$@")
    
    #if not install, return
    if [ "${args[0]}" != "-S" ];then
        yaourt --noconfirm $@ 1> /dev/null
        return
    fi

    #check if install
    for ((i=1; i<=$#-1; i++));do  
        string=`pacman -Qi ${args[i]} 2> /dev/null`
        if [ -z "$string" ];then
            echo "Installing: ${args[i]}"
            yaourt --noconfirm $1 ${args[i]} 1> /dev/null #install
        fi
    done
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

    #target dir
    $RUNASUSR mkdir -p $2

    for file in ${files[*]}; do
        #strip file name
        file=${file##*/}

        #delete existing
        if [ ! -h $2/$file ];then
            rm -rf $2/$file
        fi

        #make symbol link
        $RUNASUSR ln -sf $1/$file $2/
    done
}

function symlink(){
    #home
    mksymlink $USERHOME/Dropbox/home $USERHOME

    #configuration
    mksymlink $USERHOME/config $USERHOME "/(\.config|\.gnome2|\.local)/d;p"
    mksymlink $USERHOME/config/.config $USERHOME/.config
    mksymlink $USERHOME/config/.gnome2 $USERHOME/.gnome2
    mksymlink $USERHOME/config/.local/share/gnome-shell $USERHOME/.local/share/gnome-shell "/extensions/p"

    rm -rf $USERHOME/.git $USERHOME/.gitignore
}

#--------------------------------------------------
#special install
#--------------------------------------------------
function install_yaourt(){
    #change directory
    cd /tmp

    #obtain pkgbuild
    curl -L https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz > package-query.tar.gz
    curl -L https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz > yaourt.tar.gz

    #extract
    tar -xzf yaourt.tar.gz
    tar -xzf package-query.tar.gz

    #build package-query
    cd /tmp/package-query
    makepkg --asroot PKGBUILD
    pacman -U --noconfirm package-query*.pkg.tar.xz

    #build yaourt
    cd /tmp/yaourt
    makepkg --asroot PKGBUILD
    pacman -U --noconfirm yaourt*.pkg.tar.xz
}

function install_epstool(){
    #change directory
    cd /tmp

    #obtain pkgbuild
    curl -L https://aur.archlinux.org/packages/ep/epstool/epstool.tar.gz > epstool.tar.gz
    tar -xzf epstool.tar.gz

    #change download link
    cd /tmp/epstool
    sed -i "s|\(source[^\"']*\)[^ ]*\(.*\)|\1 \"$EPSDLINK\" \2|" PKGBUILD

    #build/install
    makepkg --asroot PKGBUILD
    $BUILDCMD -U --noconfirm epstool*.pkg.tar.xz
}

#--------------------------------------------------
#common tasks
#--------------------------------------------------
function configure_system(){
    #--------------------------------------------------
    #pre-installation
    #--------------------------------------------------
    pacman -Syu --noconfirm linux-headers sudo yajl

    #--------------------------------------------------
    #configure user
    #--------------------------------------------------
    #add user
    useradd -m -g users -G audio,games,lp,optical,power,scanner,storage,video,wheel,network -s /bin/bash $USERNAME

    #setup password
    echo ">>>>>>set password for $USERNAME:"
    passwd $USERNAME

    #configure sudo (don't use visudo ?)
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

    #--------------------------------------------------
    #prepare Dropbox directory
    #--------------------------------------------------
    $RUNASUSR cp -r /tmp/Dropbox $USERHOME/Dropbox
    $RUNASUSR cp /tmp/arch-post.sh $USERHOME/

    #--------------------------------------------------
    #set root passwd
    #--------------------------------------------------
    echo ">>>>>>set password for ROOT:"
    passwd

    #--------------------------------------------------
    #system init configuration
    #--------------------------------------------------
    #hostname
    echo "$HOSTNAME" > /etc/hostname
    sed -i "s/\(127.0.0.1.*localhost\).*$/\1\t$HOSTNAME/" /etc/hosts
    sed -i "s/\(::1.*localhost\).*$/\1\t$HOSTNAME/" /etc/hosts

    #locale
    for locale in ${OSLOCALE[*]}; do
        sed -i "s/^#\($locale.*\)/\1/" /etc/locale.gen
    done
    locale-gen
    echo "LANG=${OSLOCALE[0]}" > /etc/locale.conf
    
    #timezone
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

    #hardware clock
    hwclock --systohc --utc

    #--------------------------------------------------
    #ramdisk
    #--------------------------------------------------
    for hook in ${CPIOHOOK[*]}; do
        sed -n "s|\(^HOOKS.* \w\+\)|\1 $hook|p" /etc/mkinitcpio.conf
    done
    mkinitcpio -p linux

    #--------------------------------------------------
    #grub
    #--------------------------------------------------
    #install
    pacman -S --noconfirm grub-bios os-prober
    grub-install --target=i386-pc --recheck $BIOSDEVI

    #configure
    cp $USERHOME/Dropbox/sysconf/grub.conf /etc/default/grub 
    grub-mkconfig -o /boot/grub/grub.cfg
}

function init_post(){
    #configure pacman
    cp $USERHOME/Dropbox/sysconf/pacman/mirrorlist  /etc/pacman.d/mirrorlist
    cp $USERHOME/Dropbox/sysconf/pacman/pacman.conf /etc/pacman.conf

    #architecture change
    if [ "$SYSTARCH" != "x86_64" ];then
        sed -i -r "N;N;s|(^\[multilib\].*\n.*\n.*)||" /etc/pacman.conf
    fi

    #install necessary package
    install_yaourt
}

function install_software(){
    #--------------------------------------------------
    #Xorg and drivers
    #--------------------------------------------------
    #Xorg
    $BUILDCMD -S xorg-server xorg-xinit xorg-server-utils xorg-xprop mesa

    #video drivers (open source)
    $BUILDCMD -S xf86-video-intel libva-driver-intel 
    $BUILDCMD -S xf86-video-nouveau xf86-video-ati xf86-video-vesa #compatibility

    #touchpad
    $BUILDCMD -S xf86-input-synaptics

    #--------------------------------------------------
    #desktop environment
    #--------------------------------------------------
    #gnome-shell essential
    $BUILDCMD -S gnome-control-center gnome-shell gnome-themes-standard gdm gnome-keyring xdg-user-dirs
    $BUILDCMD -S nautilus nautilus-open-terminal

    #interface
    $BUILDCMD -S faenza-icon-theme wqy-microhei

    #font
    $BUILDCMD -Rdd freetype2 fontconfig libxft cairo 2>/dev/null #remove conflicting
    $BUILDCMD -S freetype2-ubuntu fontconfig-ubuntu libxft-ubuntu cairo-ubuntu 

    #utils
    $BUILDCMD -S lm_sensors hddtemp bash-completion net-tools ntp openssh ufw
    $BUILDCMD -S ntfs-3g ntfsprogs #ntfs support

    #laptop
    $BUILDCMD -S tlp ethtool smartmontools tlp-rdw 
    $BUILDCMD -S thinkfan acpi_call-git tp_smapi #Thinkpad only

    #--------------------------------------------------
    #development tools
    #--------------------------------------------------
    #AUR
    $BUILDCMD -S namcap 

    #personal
    $BUILDCMD -S git python gcc-fortran python-matplotlib-git doxygen graphviz
    $BUILDCMD -S lighttpd php-cgi php-gd php-sqlite

    #--------------------------------------------------
    #other softwares
    #--------------------------------------------------
    #IM
    $BUILDCMD -S pidgin irssi skype
    if [ "$SYSTARCH" == "x86_64" ];then #skype on 64bit
        $BUILDCMD -S lib32-libpulse
    fi

    #Text editing/processing
    $BUILDCMD -S texlive-latexextra rubber latex-beamer-ctan minted
    $BUILDCMD -S gvim ctags

    #other
    $BUILDCMD -S mpd mpc mplayer-vaapi gnome-mplayer #video and audio
    $BUILDCMD -S evince poppler-data #PDF
    $BUILDCMD -S scrot xsel #script
    $BUILDCMD -S file-roller p7zip archive-mounter #archiver
    $BUILDCMD -S fcitx-gtk3 fcitx-configtool fcitx-cloudpinyin fcitx-googlepinyin fcitx-gtk2 #input method
    $BUILDCMD -S firefox flashplugin icedtea-web-java7 aliedit #browser
    $BUILDCMD -S eog gimp inkscape #photo
    $BUILDCMD -S dropbox nautilus-dropbox #dropbox
    $BUILDCMD -S hotot-gtk3-git screen aria2 conky-lua xterm #misc
    $BUILDCMD -S remmina freerdp vino #remote desktop

    #special
    install_epstool
}

function settings_system(){
    #networkmanager
    mkdir -p /etc/polkit-1/localauthority/50-local.d
    cp $USERHOME/Dropbox/sysconf/org.freedesktop.NetworkManager.pkla /etc/polkit-1/localauthority/50-local.d/

    #Thinkfan
    cp $USERHOME/Dropbox/sysconf/thinkfan/modprobe.conf /etc/modprobe.d/
    cp $USERHOME/Dropbox/sysconf/thinkfan/thinkfan.conf /etc/

    #other
    cp $USERHOME/Dropbox/sysconf/rc.conf /etc/ #rc.conf
    cp -r $USERHOME/Dropbox/sysconf/font-config /etc/fonts #ubuntu-font
    (while :; do echo ""; done ) | sensors-detect #sensors

    #ufw
    ufw enable
    ufw default deny
}

function settings_user(){
    #update user directory
    $RUNASUSR xdg-user-dirs-update

    #symbol link   
    symlink
    
    #avatar
    cp $USERHOME/Pictures/avatar/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME
    cp $USERHOME/Dropbox/sysconf/gnome-account.conf /var/lib/AccountsService/users/$USERNAME
}

function vbox_guest(){
    $BUILDCMD -S virtualbox-archlinux-additions
    echo -e "vboxguest\nvboxsf\nvboxvideo" > /etc/modules-load.d/vbox.conf
}

#--------------------------------------------------
#local software
#--------------------------------------------------
function install_mendeley(){
    #pre-request
    $BUILDCMD -S libpng12

    #download
    $RUNASUSR aria2c -c http://www.mendeley.com/client/get/100-2/ -d $USERDOWN

    #install
    $RUNASUSR mkdir -p $USERSOFT
    $RUNASUSR mkdir -p $USERHOME/.local/share/applications
    $RUNASUSR tar -xjf $USERDOWN/mendeleydesktop* -C $USERSOFT
    $RUNASUSR mv $USERSOFT/mendeleydesktop* $USERSOFT/mendeley
    $RUNASUSR cp $USERSOFT/mendeley/share/applications/mendeleydesktop.desktop $USERHOME/.local/share/applications/
    $RUNASUSR sed -i "s|^Exec.*|Exec=$USERSOFT/mendeley/bin/mendeleydesktop|" $USERHOME/.local/share/applications/mendeleydesktop.desktop
    $RUNASUSR cp -r $USERSOFT/mendeley/share/icons/ $USERHOME/.local/share/icons/
}

function install_intel(){
    #pre-request
    $BUILDCMD -S cpio

    #download
    $RUNASUSR aria2c -c http://registrationcenter-download.intel.com/akdlm/irc_nas/$INTELNUM/l_fcompxe_intel64_$INTELVER.tgz -d $USERDOWN

    #extract
    $RUNASUSR mkdir -p $USERSOFT
    $RUNASUSR tar -xzf $USERDOWN/l_fcompxe_intel64_$INTELVER.tgz -C $USERDOWN

    #move license 
    $RUNASUSR mkdir -p $USERHOME/intel/licenses
    $RUNASUSR cp $USERHOME/Dropbox/sysconf/intel/*.lic $USERHOME/intel/licenses/

    #configure .ini file
    $RUNASUSR cp $USERHOME/Dropbox/sysconf/intel/install.ini $USERDOWN/l_fcompxe_intel64_$INTELVER/
    $RUNASUSR sed -i "s|\(PSET_INSTALL_DIR\).*|\1=$USERSOFT/intel|" $USERDOWN/l_fcompxe_intel64_$INTELVER/install.ini

    #install
    $RUNASUSR $USERDOWN/l_fcompxe_intel64_$INTELVER/install.sh --silent $USERDOWN/l_fcompxe_intel64_$INTELVER/install.ini

    #move license
    $RUNASUSR mkdir -p $USERSOFT/intel/licenses
    $RUNASUSR mv $USERHOME/intel/licenses/*.lic $USERSOFT/intel/licenses/

    #delete not needed
    $RUNASUSR rm -rf $USERHOME/intel
}

#--------------------------------------------------
#collect
#--------------------------------------------------
function init(){
    init_post
    install_software
    settings_system
    settings_user

    #local softwares
    for software in ${LOCALPRG[*]}; do
        install_$software
    done

    #virtualbox guest
    if [ "$VBOXINST" == "1" ];then
        vbox_guest
    fi
}

#--------------------------------------------------
#main
#--------------------------------------------------
#main configuration
USERNAME=lainme #user name (Danger, do not change!)
USERHOME=/home/$USERNAME #user home directory
USERDOWN=/home/$USERNAME/Downloads #download directory
USERSOFT=/home/$USERNAME/software  #local software directory
LOCALPRG=("mendeley" "intel") #local softwares to install
SYSTARCH=x86_64 #system architecture
HOSTNAME=lainme-arch #hostname
OSLOCALE=("en_US.UTF-8") #system locales. First one is default
TIMEZONE="Asia/Hong_Kong" #timezone
CPIOHOOK=() #additional hooks added to mkinitcpio.conf
BIOSDEVI=/dev/sda #device to install grub
VBOXINST=0 #build for virtualbox?

#installation commands
BUILDCMD="yaourt_install"
RUNASUSR="sudo -u $USERNAME" #run as normal user

#Intel compiler version
INTELNUM=2724
INTELVER=2013.0.079

#epstool
EPSDLINK="http://archive.ubuntu.com/ubuntu/pool/universe/e/epstool/epstool_3.08+repack.orig.tar.gz"

if [ -z $1 ];then
    show_help
else
    $@
fi
