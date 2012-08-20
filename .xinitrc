#!/bin/bash

#xbindkeys
xbindkeys &

#conky
sleep 15 && conky &

#mpd
mpd &

#pidgin
pidgin &

#be evil
source ~/.evil_init
