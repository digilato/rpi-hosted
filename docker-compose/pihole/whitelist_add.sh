#! /bin/bash

if command -v python3 >/dev/null 2>&1; then

    echo "Python3 is installed"
    sudo python3 ./whitelist/scripts/whitelist.py --dir /docker_bind/pihole/pihole/ --docker
    
else

    echo "Python3 must be installed"

fi