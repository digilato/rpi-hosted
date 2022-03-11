#!/bin/bash


function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

# Make sure we have an internet connection. Can't do anything otherwise.
function check_internet() {
  printf "Checking if you are online..."
  
  if  curl -q --fail http://github.com; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

# Find architecture. Current options include 'armv7' 'aarch64' 'armv6' 'x86_64' 
function uname_arch() {
  ARCH=$(uname -m)
  case $ARCH in
    x86_64) ARCH="x86_64" ;;
    aarch64) ARCH="aarch64" ;;
    armv6*) ARCH="armv6" ;;
    armv7*) ARCH="armv7" ;;
    armhf) ARCH="armv7" ;;
  esac
  # echo ${ARCH}
}

#Prepare the file to download
# Check internet
check_internet

# Check architecture
uname_arch

# Get operating system
OPSYS=$(uname -s | awk '{print tolower($0)}')  # options include 'darwin' 'linux' or 'windows'

# Which package to download
COMPOSE_PACKAGE=docker-compose-$OPSYS-$ARCH

# Get latest version
GITHUB_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/docker/compose/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

# Prepare the download URL
GITHUB_URL="https://github.com/docker/compose/releases/download/$GITHUB_VERSION/$COMPOSE_PACKAGE"




sudo mkdir -p /usr/local/lib/docker/cli-plugins || error "Failed to create plugins directory."
echo "Downloading Docker Compose $GITHUB_VERSION for \"$OPSYS $ARCH\" from $GITHUB_URL"
sudo curl -SL "$GITHUB_URL" -o /usr/local/lib/docker/cli-plugins/docker-compose || error "Failed to download Docker Compose."
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose || error "Failed to add executable."
printf "Installed: "
exec docker compose version

