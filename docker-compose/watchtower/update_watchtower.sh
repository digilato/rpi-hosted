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

watchtower_name=$(docker ps | grep watchtower | awk '{print $2}')

docker compose down

# remove the old image, mainly for "latest". If a version then prevents accumulation.
docker rmi "$watchtower_name" || error "Failed to remove/untag images from the container!"

docker compose up -d || error "Failed to execute newer version of watchtower!"