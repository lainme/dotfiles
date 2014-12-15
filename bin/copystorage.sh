#!/bin/bash

MOZF=`ls $HOME/.mozilla/firefox/*.default/webappsstore.sqlite`
BAKF=$HOME/Dropbox/home/Documents/webappsstore.sqlite

if [ "$1"=="update" ];then
    cp $BAKF $MOZF
elif [ "$1"=="backup" ];then
    cp $MOZF $BAKF
fi
