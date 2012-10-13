#!/bin/bash

rhome=/home/lainme

rsync --delete -azvv -e "ssh vps" :$rhome/web/lainme.com/ /home/lainme/web/dokuwiki
