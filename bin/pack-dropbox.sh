#!/bin/bash
# package the Dropbox directory for configuration

cd $HOME

cp $HOME/bin/arch-post.sh $HOME/

tar --exclude="home/config/.gnupg/*" --exclude="home/config/.ssh/*" --exclude="home/config/.irssi/*" --exclude="home/config/.config/fcitx/*" --exclude="home/config/.purple/*" --exclude="home/config/.vim/*" --exclude="home/config/.git" --exclude="home/reference/*" --exclude="home/Documents/*" --exclude="home/Music/*" --exclude="home/Pictures/wallpaper" --exclude="Public" --exclude="exchange" --exclude=".dropbox.cache" --exclude=".dropbox" --exclude="sysconf/dropbox.tar.gz" -cpzf $HOME/Dropbox/sysconf/dropbox.tar.gz Dropbox arch-post.sh

rm $HOME/arch-post.sh
