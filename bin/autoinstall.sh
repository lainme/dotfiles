#!/bin/bash
# Semi-auto installation of Archlinux. Assume this script and Dropbox directory is already in /tmp directory
# Steps to be done manually:
#   - install additional non-free softwares
#   - ssh key and related
# Add hosts: 31.184.194.81

#--------------------------------------------------
# helper functions
#--------------------------------------------------
function helper_command(){
    echo -e "DESCRIPTION: Archlinux installation script. Most functionalities requires root permissions"
    echo -e "USAGE: autoinstall.sh FUNCTION-NAME"
    echo -e ""
    echo -e "\tconfigure_base   - configure system after chroot"
    echo -e "\tconfigure_post   - configure system after reboot"
}

function helper_symlink(){
    args=("$@")

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
# functions in configure_post
#--------------------------------------------------
function setup_package(){
    #--------------------------------------------------
    # Xorg and drivers
    #--------------------------------------------------
    $BUILDCMD -S xorg-server xorg-xinit xorg-server-utils mesa
    $BUILDCMD -S xf86-video-$VIDEODRI xf86-input-synaptics

    #--------------------------------------------------
    # desktop environment
    #--------------------------------------------------
    # look and feel
    $BUILDCMD -Rdd freetype2 fontconfig cairo 2>/dev/null
    $BUILDCMD -S freetype2-ubuntu fontconfig-ubuntu

    # desktop essentials
    $BUILDCMD -S gdm gnome-shell gnome-control-center gnome-keyring nautilus xdg-user-dirs
    $BUILDCMD -S gnome-backgrounds faenza-icon-theme wqy-microhei

    #--------------------------------------------------
    # others
    #--------------------------------------------------
    $BUILDCMD -S ufw openssh # network tools
    $BUILDCMD -S ntfs-3g dosfstools gnome-disk-utility gparted # disk tools
    $BUILDCMD -S bash-completion nautilus-open-terminal # other tools
    $BUILDCMD -S fcitx fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 fcitx-configtool # IME
    $BUILDCMD -S gvim ctags # text editor
    $BUILDCMD -S evince poppler-data # pdf
    $BUILDCMD -S file-roller p7zip # archiver
    $BUILDCMD -S mpd mpc mplayer gnome-mplayer # video and audio
    $BUILDCMD -S eog gimp inkscape # image
    $BUILDCMD -S firefox flashplugin aliedit # browser
    $BUILDCMD -S texlive-latexextra texlive-pictures texlive-publishers latex-beamer-ctan rubber-bzr # latex
    $BUILDCMD -S dropbox nautilus-dropbox bcloud rsync wget # file transfers
    $BUILDCMD -S scrot xsel setconf # script
    $BUILDCMD -S wine wine-mono wine_gecko winetricks # wine
    $BUILDCMD -S sagemath sage-notebook # sage
    $BUILDCMD -S mendeleydesktop git screen xterm steam gnome-calendar skype cow wps-office # misc

    if [ "$SYSTARCH" == "x86_64" ];then
        $BUILDCMD -S lib32-libpulse lib32-alsa-plugins lib32-openal # sound
        $BUILDCMD -S lib32-libldap # required by bigfish client
    fi
}

function setup_sysconf(){
    # fonts
    cp -r $USERHOME/Dropbox/home/sysconf/fontconfig/* /etc/fonts/conf.avail
    cp -r $USERHOME/Dropbox/home/sysconf/fontconfig/* /etc/fonts/conf.d

    # other
    cp $USERHOME/Dropbox/home/sysconf/common/nobeep.conf /etc/modprobe.d/nobeep.conf
    cp $USERHOME/Dropbox/home/sysconf/common/netfilter.conf /etc/modules-load.d/netfilter.conf
    cp $USERHOME/Dropbox/home/sysconf/common/wgetrc /etc/wgetrc

    # tranditional network name
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

    # ufw
    ufw enable
    ufw default deny

    # systemd services
    systemctl enable gdm
    systemctl enable NetworkManager
    systemctl enable NetworkManager-dispatcher
    systemctl enable ufw
}

function setup_usrconf(){
    # update user directory
    $RUNASUSR xdg-user-dirs-update

    # symbol link
    helper_symlink $USERHOME/Dropbox/home $USERHOME "/(\.config$|\.git$|\.gitignore$|sysconf$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.config $USERHOME/.config

    # avatar
    cp $USERHOME/Dropbox/home/sysconf/account/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME
    cp $USERHOME/Dropbox/home/sysconf/account/gnome-account.conf /var/lib/AccountsService/users/$USERNAME

    # services
    systemctl --user enable mpd
    systemctl --user enable sage
    systemctl --user enable cow
}

function setup_notebook(){
    # power management
    $BUILDCMD -S tlp tlp-rdw

    # systemd services
    systemctl enable tlp
    systemctl enable tlp-sleep
    systemctl disable systemd-rfkill.service
}

function setup_thinkpad(){
    $BUILDCMD -S acpi_call tp_smapi
}

#--------------------------------------------------
# main functions
#--------------------------------------------------
function configure_base(){
    #--------------------------------------------------
    # configure pacman
    #--------------------------------------------------
    # configuration files
    pacman -S --noconfirm wget
    cp /tmp/Dropbox/home/sysconf/common/pacman.conf /etc/pacman.conf
    vi /etc/pacman.d/mirrorlist

    # architecture change
    if [ "$SYSTARCH" != "x86_64" ];then
        sed -i -r "N;N;s|(^\[multilib\].*\n.*\n.*)||" /etc/pacman.conf
    fi

    # install necessary packages
    pacman -S --noconfirm linux-headers sudo yajl yaourt

    #--------------------------------------------------
    # configure user
    #--------------------------------------------------
    # add user
    groupadd $USERNAME
    useradd -m -g $USERNAME -G wheel -s /bin/bash $USERNAME

    # setup password
    echo ">>>>>>set password for $USERNAME:"
    passwd $USERNAME

    # configure sudo
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

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
    # boot
    #--------------------------------------------------
    if [ "$PARTTYPE" == "GPT" ];then # GPT partition
        bootctl install
        echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=$ROOTDEVI rw" > /boot/loader/entries/arch.conf
        echo -e "timeout\t5\ndefault\tarch" > /boot/loader/loader.conf
    else
        # install
        pacman -S --noconfirm grub-bios os-prober
        grub-install --target=i386-pc --recheck $GRUBDEVI

        # configure
        cp /tmp/Dropbox/home/sysconf/common/grub.conf /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

    #--------------------------------------------------
    # prepare Dropbox directory
    #--------------------------------------------------
    $RUNASUSR cp -r /tmp/Dropbox $USERHOME/Dropbox
    $RUNASUSR cp /tmp/autoinstall.sh $USERHOME/
}

function configure_post(){
    setup_package
    setup_sysconf
    setup_usrconf

    if [ "$NOTEBOOK" == "1" ];then
        setup_notebook
    fi

    if [ "$THINKPAD" == "1" ];then
        setup_thinkpad
    fi
}

#--------------------------------------------------
# main
#--------------------------------------------------
# main configuration
USERNAME=lainme
USERHOME=/home/$USERNAME
HOSTNAME=$USERNAME
SYSTARCH=x86_64
OSLOCALE=("en_US.UTF-8")
TIMEZONE="Asia/Hong_Kong"
CPIOHOOK=()
PARTTYPE=GPT
ROOTDEVI=/dev/sda6
GRUBDEVI=/dev/sda
VIDEODRI=intel

# switching configuration
NOTEBOOK=1
THINKPAD=1

# installation commands
BUILDCMD="yaourt --noconfirm --needed"
RUNASUSR="sudo -u $USERNAME"

if [ -z $1 ];then
    helper_command
else
    $@
fi
