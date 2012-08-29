#!/bin/bash

#conky
sleep 15 && conky &

#mpd
mpd &

#pidgin
pidgin &

#hotot
hotot-gtk3 &

#be evil
source $HOME/.evil_init
