#!/bin/bash

DOMAINS=("lainme.com" "demxs.com")
for domain in ${DOMAINS[*]}; do
    if [ -d $HOME/archive/$domain ]; then
        cd $HOME/archive/$domain
        git fetch
        git pull
    fi
done
