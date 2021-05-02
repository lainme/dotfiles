#!/bin/bash

killall ss-local

sleep 1

ss-local -c $HOME/.cow/config-$1.json &
