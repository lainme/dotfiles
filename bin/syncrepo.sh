#!/bin/bash

if [ "$1" = "--send" ];then
    sudo rsync -rv --delete /var/lib/pacman/sync/   /run/media/lainme/Linux/pacman/sync/
    sudo rsync -rv --delete /var/cache/pacman/pkg/  /run/media/lainme/Linux/pacman/pkg/
    sudo rsync -av --delete /home/lainme/Dropbox/   /run/media/lainme/Linux/Dropbox/
elif [ "$1" = "-receive" ];then
    sudo rsync -rv --delete /run/media/lainme/Linux/pacman/sync/    /var/lib/pacman/sync/
    sudo rsync -rv --delete /run/media/lainme/Linux/pacman/pkg/     /var/cache/pacman/pkg/
    sudo rsync -av --delete /run/media/lainme/Linux/Dropbox/        /home/lainme/Dropbox/
fi
