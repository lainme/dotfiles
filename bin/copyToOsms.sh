#!/bin/bash

read -sp 'DevicePassword: ' password
echo
scp -o PreferredAuthentications=keyboard-interactive -P 50022 $1 ruijie.wang@172.18.1.251:10.18.0.117:lainme:$password:$2

