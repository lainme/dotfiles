#!/bin/bash
# package the Dropbox directory for configuration

cd $HOME

$HOME/bin/cleandropbox.sh

git clone https://gist.github.com/4441125.git arch-post

cp arch-post/arch-post.sh arch-post.sh

tar --exclude="home/config/.config/fcitx/table/*" --exclude="home/config/.irssi/*" --exclude="home/config/.mpd/*" --exclude="home/config/.vim/*" --exclude="home/config/.git" --exclude="home/Documents/*" --exclude="home/Music/*" --exclude="home/Pictures/Wallpapers" --exclude="home/reference/*" --exclude="home/results/*" --exclude="home/Templates/*" --exclude="Public" --exclude="exchange" --exclude="develop" --exclude="cluster" --exclude="server" --exclude=".dropbox.cache" --exclude=".dropbox" --exclude="sysconf/dropbox.tar.gz" -cpzf $HOME/Dropbox/sysconf/dropbox.tar.gz Dropbox arch-post.sh

rm -rf arch-post arch-post.sh
