#!/bin/bash

hostname=$(echo $HOSTNAME)
ip addr > /tmp/address_information_$hostname
scp /tmp/address_information_$hostname exchange:~/
