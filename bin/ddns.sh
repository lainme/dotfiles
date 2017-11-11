#!/bin/bash

CURIP=$(cat $HOME/.ddns)
NEWIP=$(curl -s ipinfo.io/ip)
HOSTS=$(hostname)
if [ $CURIP == $NEWIP ];then
    exit 0
fi
if [ -z $NEWIP ];then
    exit 0
fi
echo $NEWIP > $HOME/.ddns

sed -i -e "/lainme-$HOSTS/{N;s/[0-9.]\+/$NEWIP/}" $HOME/Dropbox/home/.ssh/config
