#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

check_internet

authelia_pid=$(docker ps | grep authelia | awk '{print $1}')
authelia_name=$(docker ps | grep authelia | awk '{print $2}')

sudo docker stop "$authelia_pid" || error "Failed to stop portainer!"
sudo docker rm "$authelia_pid" || error "Failed to remove portainer container!"
sudo docker rmi "$authelia_name" || error "Failed to remove/untag images from the container!"

echo "Taking the opportunity to backup data volume while stopped (i.e., inactive database)."
mkdir -p "$(pwd)"/backup
sudo tar -cvfz "$(pwd)"/backup/authelia_"$(date +%Y%m%d)".tar.gz /docker_bind/authelia || error "Failed to back up authelia docker_bind!"

exec docker compose -f authelia.yaml up -d || error "Failed to execute newer version of Nginx Proxy Manager!"
