#!/bin/bash

CURIP=$(cat $HOME/.ddns)
NEWIP=$(curl -s ifconfig.co)
HOSTS=$(hostname)
if [ "$CURIP" == "$NEWIP" ];then
    exit 0
fi
if [ -z $NEWIP ];then
    exit 0
fi
echo $NEWIP > $HOME/.ddns

sed -i "/remote-\*/{N;s/[0-9.]\+/$NEWIP/}" $HOME/Dropbox/home/.ssh/config
