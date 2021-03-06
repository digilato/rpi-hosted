#!/bin/bash

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

curl -sSL https://get.docker.com | sh || error "Failed to install Docker."

# Add the user to the docker group so sudo is not required
sudo usermod -aG docker $USER || error "Failed to add user to the Docker usergroup."

# mkdir for volume binding which is easier to backup with cron and tar than docker volumes
sudo mkdir /docker_bind || error "Failed to add directory for binding docker volumes."

echo "Remember to logoff/reboot for the changes to take effect."

