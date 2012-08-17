#!/bin/bash

#xbindkeys
xbindkeys &

#conky
sleep 15 && conky &

#fcitx
sleep 5 && fcitx &

#mpd
mpd &

#be evil
source ~/.evil_init
