#!/bin/bash

#xbindkeys
xbindkeys &

#conky
sleep 15 && conky &

#mpd
mpd &

#be evil
source ~/.evil_init
