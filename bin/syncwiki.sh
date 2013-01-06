#!/bin/bash

rsync --delete -azvv -e "ssh lainme.com" :/var/www/lainme.com/ $HOME/lighttpd/dokuwiki
