#!/bin/bash
#
# 01. Mount partitions to /mnt
# 02. Change pacman mirrors (online only)
# 03. Modify pacstrap to change "-Sy" to "-S" for pacman (offline only)
# 04. Manual install archlinux-keyring in the host (offline only)
# 05. Copy pacman files to the target (offline only)
# 06. Install package: pacstrap /mnt base base-devel
# 07. Generate fstab: genfstab -U /mnt >> /mnt/etc/fstab
# 08. Copy Dropbox folder and this script to /mnt with cp -rp
# 09. Chroot: arch-chroot /mnt
# 10. Move Dropbox folder and this cript to /mnt/tmp
# 11. Modify this script as appropriate.
# 12. Run configure_base.
# 13. Exit chroot and reboot
# 14. Run configure_post with root.
# 15. Install local packages (offline only)
# 16. Install aliedit package
# 16. Manully run systemctl --user parts.
# 17. Setup ssh keys (online only)
# 18. Install non-free softwares

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
# functions in configure_post
#--------------------------------------------------
function setup_package(){
    #--------------------------------------------------
    # prepare
    #--------------------------------------------------
    $BUILDCMD -S archlinux-keyring archlinuxcn-keyring

    #--------------------------------------------------
    # Xorg and drivers
    #--------------------------------------------------
    $BUILDCMD -S xorg-server xorg-xinit xorg-apps mesa
    $BUILDCMD -S xf86-video-intel xf86-video-ati xf86-video-nouveau xf86-input-synaptics

    #--------------------------------------------------
    # desktop environment
    #--------------------------------------------------
    # desktop essentials
    $BUILDCMD -S gdm gnome-shell gnome-control-center gnome-keyring nautilus xdg-user-dirs
    $BUILDCMD -S gnome-backgrounds faenza-icon-theme wqy-microhei ttf-inconsolata
    $BUILDCMD -S gnome-tweak-tool gnome-shell-extension-topicons-plus-git

    #--------------------------------------------------
    # others
    #--------------------------------------------------
    $BUILDCMD -S tlp tlp-rdw ethtool smartmontools x86_energy_perf_policy # tlp
    $BUILDCMD -S dhclient ufw openssh shadowsocks-libev networkmanager-vpnc # network tools
    $BUILDCMD -S ntfs-3g dosfstools gnome-disk-utility gparted # disk tools
    $BUILDCMD -S bash-completion cups xterm screen cron # other tools
    $BUILDCMD -S gcc-fortran cmake # development tools
    $BUILDCMD -S fcitx fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 fcitx-configtool # IME
    $BUILDCMD -S gvim ctags # text editor
    $BUILDCMD -S evince poppler-data mendeleydesktop masterpdfeditor # pdf
    $BUILDCMD -S file-roller p7zip cpio # archiver
    $BUILDCMD -S mpd mpc mplayer gnome-mplayer # video and audio
    $BUILDCMD -S eog gimp inkscape # image
    $BUILDCMD -S firefox google-chrome flashplugin # browser
    $BUILDCMD -S texlive-latexextra texlive-pictures texlive-publishers wps-office # office
    $BUILDCMD -S dropbox dropbox-cli nautilus-dropbox rsync wget aria2 git gvfs-mtp # file transfers
    $BUILDCMD -S scrot xsel setconf # script
    $BUILDCMD -S wine wine-mono wine_gecko winetricks # wine
    $BUILDCMD -S sagemath sage-notebook # sage
    $BUILDCMD -S steam skypeforlinux-preview-bin # misc

    # local packages
    if [ "$OFFLINES" == "0" ];then
        $BUILDCMD -S cow-proxy # network tools
        $BUILDCMD -S latex-beamer rubber-git # office
    fi

    if [ "$SYSTARCH" == "x86_64" ];then
        $BUILDCMD -S lib32-libpulse lib32-alsa-plugins lib32-openal # sound
        $BUILDCMD -S lib32-libldap # required by bigfish client
        $BUILDCMD -S lib32-gtk2 lib32-gtk3 lib32-gdk-pixbuf2 lib32-libva lib32-libpng12 # steam
    fi
}

function setup_system(){
    # fonts
    cp -r $USERHOME/Dropbox/system/fontconfig/* /etc/fonts/conf.avail
    cp -r $USERHOME/Dropbox/system/fontconfig/* /etc/fonts/conf.d

    # other
    cp $USERHOME/Dropbox/system/common/nobeep.conf /etc/modprobe.d/nobeep.conf
    cp $USERHOME/Dropbox/system/common/netfilter.conf /etc/modules-load.d/netfilter.conf
    cp $USERHOME/Dropbox/system/common/wgetrc /etc/wgetrc

    # tranditional network name
    ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

    # ufw
    ufw enable
    ufw default deny

    # systemd services
    systemctl mask systemd-rfkill.service # for tlp.
    systemctl mask systemd-rfkill.socket # for tlp.
    systemctl enable gdm
    systemctl enable NetworkManager
    systemctl enable NetworkManager-dispatcher
    systemctl enable ufw
    systemctl enable tlp
    systemctl enable tlp-sleep
    systemctl enable org.cups.cupsd.service
}

function setup_person(){
    # update user directory
    $RUNASUSR xdg-user-dirs-update

    # symbol link
    helper_symlink $USERHOME/Dropbox/home $USERHOME "/(\.config$|\.local$|\.cow$|\.ssh$|\.sage$|\.git$|\.gitignore$|\.subversion$|intel$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.local/share              $USERHOME/.local/share "/(data|gnome-shell$)/d;p"
    helper_symlink $USERHOME/Dropbox/home/.local/share/data         $USERHOME/.local/share/data
    helper_symlink $USERHOME/Dropbox/home/.local/share/gnome-shell  $USERHOME/.local/share/gnome-shell
    helper_symlink $USERHOME/Dropbox/home/.config                   $USERHOME/.config
    helper_symlink $USERHOME/Dropbox/home/.cow                      $USERHOME/.cow
    helper_symlink $USERHOME/Dropbox/home/.sage                     $USERHOME/.sage
    helper_symlink $USERHOME/Dropbox/home/.ssh                      $USERHOME/.ssh
    helper_symlink $USERHOME/Dropbox/home/.subversion               $USERHOME/.subversion

    # avatar
    cp $USERHOME/Dropbox/system/account/avatar-gnome.png /var/lib/AccountsService/icons/$USERNAME
    cp $USERHOME/Dropbox/system/account/gnome-account.conf /var/lib/AccountsService/users/$USERNAME

    # fix background locating
    ln -sf $USERHOME/Pictures/Wallpapers $USERHOME/.cache/gnome-control-center/backgrounds

    # services (may need to run outside the script)
    systemctl --user enable mpd
    systemctl --user enable sage
    systemctl --user enable cow

    # ssh client
    sudo -u $USERNAME ssh-keygen -t rsa
    echo "SSH: please upload the public key to the servers"
    cat $USERHOME/.ssh/id_rsa.pub
    read -p "Enter to continue"

    # server backup
    $RUNASUSR mkdir -p $USERHOME/archive
    for domain in ${MYDOMAIN[*]}; do
        cd $USERHOME/archive
        $RUNASUSR git clone ssh://lainme@$domain:/home/lainme/repository $domain
    done
    command="0 * * * * /home/$USERNAME/bin/serverbackup.sh &> /dev/null"
    (echo "$command") | crontab -u $USERNAME -
}

function setup_thinkpad(){
    $BUILDCMD -S acpi_call tp_smapi
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
    command="*/5 * * * * /home/$USERNAME/bin/ddns.sh &> /dev/null"
    (echo "$command") | crontab -u $USERNAME -
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
    cp /tmp/Dropbox/system/common/pacman.conf /etc/pacman.conf
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
    echo "127.0.0.1    $HOSTNAME.localdomain   $HOSTNAME" >> /etc/hosts

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
        cp /tmp/Dropbox/system/common/grub.conf /etc/default/grub
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
    setup_system
    setup_person

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
MYDOMAIN=("lainme.com")

# switching configuration
THINKPAD=1
HOMESERV=1
OFFLINES=0

# installation commands
BUILDCMD="yaourt --noconfirm --needed"
RUNASUSR="sudo -u $USERNAME"

if [ -z $1 ];then
    helper_command
else
    $@
fi
