#!/bin/sh

# could also use (works debian and RPi OS):  $(ip route get 8.8.8.8 | awk '{gsub(".*src",""); print $1; exit}')
# could also use (works debian and RPi OS): ip=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
# Also works Could we use this for Teleport IP Address?: `hostname --all-ip-addresses | awk '{print $1}'` 
# Need to test on other OS's to see how they work.
# DOES NOT WORK ON DEBIAN (no eth0!): $(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

EXTERNAL_IP=$(ip route get 8.8.8.8 | awk '{gsub(".*src",""); print $1; exit}')
export EXTERNAL_IP

exec docker-compose -f pihole.yml up -d