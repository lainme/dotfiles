#!/bin/bash

DOMAINS=("lainme.com")
for domain in ${DOMAINS[*]}; do
    cd $HOME/archive/$domain
    git fetch
    git pull
done
