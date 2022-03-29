#!/bin/bash

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

# autoheal_pid=$(docker ps | grep autoheal | awk '{print $1}')
autoheal_name=$(docker ps | grep autoheal | awk '{print $2}')

docker compose down

# Following is to stop a containers started with docker. Proper way is to down for docker compose.
# docker rm "$autoheal_pid" || error "Failed to remove autoheal container!"
docker rmi "$autoheal_name" || error "Failed to remove/untag images from the container!"

docker compose up -d || error "Failed to execute newer version of autoheal!"