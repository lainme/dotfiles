#!/bin/sh

rsync --delete -azvv -e "ssh lainme.com" :/srv/http/lainme.com/ $HOME/http/dokuwiki
