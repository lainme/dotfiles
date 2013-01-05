#!/bin/bash

sudo rsync --delete -azvv -e "ssh lainme.com -i /home/lainme/.ssh/id_rsa -F /home/lainme/.ssh/config" :/var/www/lainme.com/ /srv/http/dokuwiki

sudo chown -R http:http /srv/http/dokuwiki
