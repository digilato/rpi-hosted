#!/bin/bash

export version=v2.2.3 # Could automate for latest, but individuals might not want this. Find latest at https://github.com/docker/compose/releases
opsys=$(uname -s | awk '{print tolower($0)}')  # 'darwin' 'linux' or 'windows'
export opsys
# TODO: Automate this portion.
export arch=armv7 # options include 'armv7' 'aarch64' 'armv6' 'x86_64' 

compose_package=docker-compose-$opsys-$arch


function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  
  if  wget -q --spider http://github.com; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

check_internet

sudo mkdir -p /usr/local/lib/docker/cli-plugins || error "Failed to create plugins directory."
echo "Downloading Docker Compose $version from https://github.com/docker/compose/releases/download/$version/$compose_package"
sudo curl -SL "https://github.com/docker/compose/releases/download/$version/$compose_package" -o /usr/local/lib/docker/cli-plugins/docker-compose || error "Failed to download Docker Compose."
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose || error "Failed to add executable."
printf "Installed: "
exec docker compose version

# Install older version
# curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || error "Failed to install Docker Compose."

# 