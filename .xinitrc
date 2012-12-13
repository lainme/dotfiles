#!/bin/bash

#conky
sleep 15 && conky &

#mpd
mpd &

#pidgin
pidgin &

#be evil
if [ -f $HOME/.evil_init ];then
    source $HOME/.evil_init
fi
