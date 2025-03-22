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

# prowlarr_pid=$(docker ps | grep prowlarr | awk '{print $1}')
prowlarr_name=$(docker ps | grep prowlarr | awk '{print $2}')

docker compose -f prowlarr.yaml down

# Following is to stop a containers started with docker. Proper way is to down for docker compose.
# sudo docker stop "$prowlarr_pid" || error "Failed to stop nginx-proxy-manager!"
# sudo docker rm "$prowlarr_pid" || error "Failed to remove nginx-proxy-manager container!"
sudo docker rmi "$prowlarr_name" || error "Failed to remove/untag images from the container!"

echo "Taking the opportunity to backup data volume while stopped (i.e., inactive database)."
mkdir -p backup
sudo tar cvfz backup/prowlarr_"$(date +%Y%m%d)".tar.gz /docker_bind/prowlarr || error "Failed to back up prowlarr docker_bind!"

exec docker compose -f prowlarr.yaml up -d || error "Failed to execute newer version of Prowlarr!"
