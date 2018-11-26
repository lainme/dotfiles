#!/bin/bash

killall ss-local

ss-local -c $HOME/.cow/config-$1.json &
