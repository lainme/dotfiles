#!/bin/bash
# Semi-auto installation of Archlinux. Assume this script and Dropbox directory is already in /tmp directory
# steps to be done manually:
#   - restore the ssl certificate (server)
#   - remove CNNIC certificate
#   - install additional non-free softwares
#   - ssh key and related
#   - router (if needed)
#   - change evince visibility

#--------------------------------------------------
# helper functions
#--------------------------------------------------
function helper_usage(){
    echo -e "DESCRIPTION: Archlinux installation script. Most functionalities requires root permissions"
    echo -e "USAGE: autoinstall.sh FUNCTION-NAME"
    echo -e "Main functions:"
    echo -e ""
    echo -e "\tconfigure_base   - configure base system after chroot when installing"
    echo -e "\tconfigure_post   - configure arch system after installation and reboot"
    echo -e ""
    echo -e "Core functions in configure_post step:"
    echo -e ""
    echo -e "\tsetup_software   - install softwares"
    echo -e "\tsetup_system     - system settings"
    echo -e "\tsetup_user       - user settings"
    echo -e ""
    echo -e "Optional functions in configure_post step:"
    echo -e ""
    echo -e "\tsetup_notebook   - notebook configurations"
    echo -e "\tsetup_thinkpad   - thinkpad configurations"
    echo -e "\tsetup_homeserv   - home server configurations"
    echo -e ""
    echo -e "User functions:"
    echo -e ""
    echo -e "\tuser_symlink     - make symbol link for user files/configurations"
}

function helper_yaourt(){
    args=("$@")
    
    # if not install, return
    if [ "${args[0]}" != "-S" ];then
        yaourt --noconfirm $@ 1> /dev/null
        return
    fi

    # check if install
    for ((i=1; i<=$#-1; i++));do  
        string=`pacman -Qi ${args[i]} 2> /dev/null`
        if [ -z "$string" ];then
            echo "Installing: ${args[i]}"
            yaourt --noconfirm $1 ${args[i]} 1> /dev/null # install
        fi
    done
}

function helper_symlink(){
    args=("$@")
    
    # regex
    if [ -z $3 ];then
        regex="/.*/p"
    else
        regex=$3
    fi

    # find all files
    files=(`find -L $1 -mindepth 1 -maxdepth 1 | sed -rn "$regex"`)

    # target dir
    $RUNASUSR mkdir -p $2

    for file in ${files[*]}; do
        # strip file name
        file=${file##*/}

        # delete existing
        if [ ! -h $2/$file ];then
            rm -rf $2/$file
        fi

        # make symbol link
        $RUNASUSR ln -sf $1/$file $2/
    done
}

#--------------------------------------------------
# user functions
#--------------------------------------------------
function user_symlink(){
    helper_symlink $USERHOME/Dropbox/home $USERHOME "/(\.config$|\.git$|\.gitignore$|sysconf$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.config $USERHOME/.config "/(dconf$)/d;p"
}

#--------------------------------------------------
# core functions in configure_post setp
#--------------------------------------------------
function setup_software(){
    #--------------------------------------------------
    # Xorg and drivers
    #--------------------------------------------------
    # Xorg
    $BUILDCMD -S xorg-server xorg-xinit xorg-server-utils xorg-xprop mesa

    # video drivers (open source)
    $BUILDCMD -S xf86-video-intel libva-intel-driver
    $BUILDCMD -S xf86-video-nouveau xf86-video-ati xf86-video-vesa # compatibility

    # touchpad
    $BUILDCMD -S xf86-input-synaptics

    #--------------------------------------------------
    # desktop environment
    #--------------------------------------------------
    # gnome-shell essential
    $BUILDCMD -S gnome-control-center gnome-shell gnome-themes-standard gdm gnome-keyring xdg-user-dirs
    $BUILDCMD -S nautilus nautilus-open-terminal

    # interface
    $BUILDCMD -S faenza-icon-theme wqy-microhei

    # font
    $BUILDCMD -Rdd freetype2 fontconfig cairo 2>/dev/null # remove conflicting
    $BUILDCMD -S freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu 

    # utils
    $BUILDCMD -S lm_sensors hddtemp bash-completion net-tools ntp openssh ufw moreutils setconf ntfs-3g dosfstools

    #--------------------------------------------------
    # other softwares
    #--------------------------------------------------
    $BUILDCMD -S fcitx-gtk3 fcitx-gtk2 fcitx-configtool # input method
    $BUILDCMD -S file-roller p7zip archive-mounter # archiver
    $BUILDCMD -S gvim ctags # text editor
    $BUILDCMD -S evince poppler-data # PDF
    $BUILDCMD -S mendeleydesktop # literature management
    $BUILDCMD -S git # development
    $BUILDCMD -S texlive-latexextra rubber latex-beamer-ctan minted epstool # latex
    $BUILDCMD -S pidgin pidgin-lwqq-git pidgin-libnotify irssi skype # IM
    $BUILDCMD -S mpd mpc mplayer-vaapi gnome-mplayer # video and audio
    $BUILDCMD -S eog gimp inkscape # photo
    $BUILDCMD -S firefox flashplugin icedtea-web-java7 aliedit # browser
    $BUILDCMD -S dropbox nautilus-dropbox # dropbox
    $BUILDCMD -S screen conky-lua xterm # misc
    $BUILDCMD -S scrot xsel # script

    if [ "$SYSTARCH" == "x86_64" ];then # skype on 64bit
        $BUILDCMD -S lib32-libpulse
    fi
}

function setup_system(){
    # fonts
    cp -r $USERHOME/Dropbox/home/sysconf/fontconfig/* /etc/fonts/conf.avail
    cp -r $USERHOME/Dropbox/home/sysconf/fontconfig/* /etc/fonts/conf.d
    cp -r $USERHOME/Dropbox/home/sysconf/fonts /usr/share/fonts/additions

    # other
    cp $USERHOME/Dropbox/home/sysconf/common/blacklist.conf /etc/modprobe.d/blacklist.conf # blacklist
    (while :; do echo ""; done ) | sensors-detect # sensors

    # ufw
    ufw enable
    ufw default deny

    # systemd services
    systemctl enable gdm
    systemctl enable NetworkManager
    systemctl enable NetworkManager-dispatcher
    systemctl enable hddtemp
    systemctl enable lm_sensors
    systemctl enable ntpd
    systemctl enable ufw
}

function setup_user(){
    # update user directory
    $RUNASUSR xdg-user-dirs-update

    # symbol link   
    user_symlink
    
    # avatar
    cp $USERHOME/Dropbox/home/sysconf/account/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME
    cp $USERHOME/Dropbox/home/sysconf/account/gnome-account.conf /var/lib/AccountsService/users/$USERNAME
}

#--------------------------------------------------
# optional functions in configure_post setp
#--------------------------------------------------
function setup_notebook(){
    # power management
    $BUILDCMD -S tlp ethtool smartmontools tlp-rdw 

    # systemd services
    systemctl enable tlp-init
}

function setup_thinkpad(){
    $BUILDCMD -S thinkfan acpi_call-git tp_smapi

    # thinkfan configuration
    cp $USERHOME/Dropbox/home/sysconf/thinkfan/modprobe.conf /etc/modprobe.d/thinkfan.conf
    cp $USERHOME/Dropbox/home/sysconf/thinkfan/thinkfan.conf /etc/

    # systemd services
    systemctl enable thinkfan
}

function setup_homeserv(){
    $BUILDCMD -S sage-mathematics # sage server
    $BUILDCMD -S lighttpd php-cgi php-gd php-sqlite # web server
    $BUILDCMD -S exim # email server
    $BUILDCMD -S simplejobm # job manager

    # sage server
    mkdir -p /srv/sage
    chown sagemath:sagemath /srv/sage
    usermod -d /srv/sage sagemath
    cp $USERHOME/Dropbox/home/sysconf/sage/sage-notebook.service /etc/systemd/system/sage-notebook.service

    # web server
    cp $USERHOME/Dropbox/home/sysconf/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf

    # email server
    cp $USERHOME/Dropbox/home/sysconf/exim/exim.conf /etc/mail/exim.conf

    # ssh server
    cp $USERHOME/Dropbox/home/sysconf/sshd/sshd_config /etc/ssh/sshd_config

    # systemd services
    systemctl enable sage-notebook
    systemctl enable lighttpd
    systemctl enable sshd

    # ufw port
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
}

#--------------------------------------------------
# main functions
#--------------------------------------------------
function configure_base(){
    #--------------------------------------------------
    # configure pacman
    #--------------------------------------------------
    # configuration files
    cp /tmp/Dropbox/home/sysconf/pacman/mirrorlist  /etc/pacman.d/mirrorlist
    cp /tmp/Dropbox/home/sysconf/pacman/pacman.conf /etc/pacman.conf

    # architecture change
    if [ "$SYSTARCH" != "x86_64" ];then
        sed -i -r "N;N;s|(^\[multilib\].*\n.*\n.*)||" /etc/pacman.conf
    fi

    # install necessary packages
    pacman -Syu --noconfirm linux-headers sudo yajl yaourt

    #--------------------------------------------------
    # configure user
    #--------------------------------------------------
    # add user
    groupadd lainme
    useradd -m -g $USERNAME -G wheel -s /bin/bash $USERNAME

    # setup password
    echo ">>>>>>set password for $USERNAME:"
    passwd $USERNAME

    # configure sudo
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
    echo 'Defaults env_keep += "HOME"' >> /etc/sudoers
    
    #--------------------------------------------------
    # set root passwd
    #--------------------------------------------------
    echo ">>>>>>set password for ROOT:"
    passwd

    #--------------------------------------------------
    # system base configuration
    #--------------------------------------------------
    # hostname
    echo "$HOSTNAME" > /etc/hostname

    # locale
    for locale in ${OSLOCALE[*]}; do
        sed -i "s/^#\($locale.*\)/\1/" /etc/locale.gen
    done
    locale-gen
    echo "LANG=${OSLOCALE[0]}" > /etc/locale.conf
    
    # timezone
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

    # hardware clock
    hwclock --systohc --utc

    #--------------------------------------------------
    # ramdisk
    #--------------------------------------------------
    for hook in ${CPIOHOOK[*]}; do
        sed -n "s|\(^HOOKS.* \w\+\)|\1 $hook|p" /etc/mkinitcpio.conf
    done
    mkinitcpio -p linux

    #--------------------------------------------------
    # grub
    #--------------------------------------------------
    # install
    pacman -S --noconfirm grub-bios os-prober
    grub-install --target=i386-pc --recheck $GRUBDEVI

    # configure
    cp /tmp/Dropbox/home/sysconf/common/grub.conf /etc/default/grub 
    grub-mkconfig -o /boot/grub/grub.cfg

    #--------------------------------------------------
    # prepare Dropbox directory
    #--------------------------------------------------
    $RUNASUSR cp -r /tmp/Dropbox $USERHOME/Dropbox
    $RUNASUSR cp /tmp/arch-post.sh $USERHOME/
}

function configure_post(){
    setup_software
    setup_system
    setup_user

    if [ "$NOTEBOOK" == "1" ];then
        setup_notebook
    fi

    if [ "$THINKPAD" == "1" ];then
        setup_thinkpad
    fi

    if [ "$HOMESERV" == "1" ];then
        setup_homeserv
    fi
}

#--------------------------------------------------
# main
#--------------------------------------------------
# main configuration
USERNAME=lainme # user name (danger, do not change!)
USERHOME=/home/$USERNAME # user home directory
SYSTARCH=x86_64 # system architecture
HOSTNAME=lainme-home # hostname
OSLOCALE=("en_US.UTF-8") # system locales. First one is default
TIMEZONE="Asia/Hong_Kong" # timezone
CPIOHOOK=() # additional hooks added to mkinitcpio.conf
GRUBDEVI=/dev/sda # device to install grub

# switching configuration
NOTEBOOK=1
THINKPAD=1
HOMESERV=0

# installation commands
BUILDCMD="helper_yaourt"
RUNASUSR="sudo -u $USERNAME" # run as normal user

if [ -z $1 ];then
    show_help
else
    $@
fi

