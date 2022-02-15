#!/bin/bash

export VERSION=0.7.6 # Could automate for latest, but individuals might not want this. Find latest at https://goteleport.com/teleport/download/
OPSYS=$(uname -s | awk '{print tolower($0)}')  # 'darwin' 'linux' or 'windows'
export OPSYS
# TODO: Automate this portion.
export ARCH=arm # '386' 'arm' on linux or 'amd64' for all distros 

CTOP_PACKAGE=ctop-$VERSION-$OPSYS-$ARCH



function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  
  if wget -q --spider http://github.com; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

check_internet

sudo wget "https://github.com/bcicen/ctop/releases/download/$VERSION/$CTOP_PACKAGE" -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop


# docker run --rm -ti \
#  --name=ctop \
#  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
#  quay.io/vektorlab/ctop:latest