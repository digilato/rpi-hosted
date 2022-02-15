#!/bin/bash

# allow specifying different destination directory
DIR="${DIR:-"$HOME/.local/bin"}"

OPSYS=$(uname -s | awk '{print tolower($0)}')  # 'darwin' 'linux' or 'windows'

# map different architecture variations to the available binaries
ARCH=$(uname -m)
case $ARCH in
    i386|i686|x86_64) ARCH=amd64 ;;
    armv6*) ARCH=arm ;;
    armv7*) ARCH=arm ;;
    aarch64*) ARCH=arm64 ;;
esac


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


# prepare the download URL
GITHUB_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/bcicen/ctop/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
GITHUB_FILE="ctop-${GITHUB_LATEST_VERSION}-${OPSYS}-${ARCH}"
GITHUB_URL="https://github.com/bcicen/ctop/releases/download/${GITHUB_LATEST_VERSION}/${GITHUB_FILE}"

echo "$GITHUB_URL"

# install/update the local binary
# curl -L -o ctop "$GITHUB_URL"
# install -Dm 755 ctop -t "$DIR"
# rm ctop

# sudo wget "https://github.com/bcicen/ctop/releases/download/$VERSION/$CTOP_PACKAGE" -O /usr/local/bin/ctop
# sudo chmod +x /usr/local/bin/ctop


# docker run --rm -ti \
#  --name=ctop \
#  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
#  quay.io/vektorlab/ctop:latest