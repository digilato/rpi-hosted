#!/bin/bash

SERVICE_NAME='pihole'

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

# pihole_pid=$(docker ps | grep "$SERVICE_NAME" | awk '{print $1}')
pihole_name=$(docker ps | grep "$SERVICE_NAME" | awk '{print $2}')

# cloudflared_pid=$(docker ps | grep cloudflared | awk '{print $1}')
cloudflared_name=$(docker ps | grep cloudflared | awk '{print $2}')

docker compose -f "$SERVICE_NAME".yaml down || error "Failed to birng down pihole!"

sudo docker rmi "$pihole_name" || error "Failed to remove/untag images from the container!"
sudo docker rmi "$cloudflared_name" || error "Failed to remove/untag images from the container!"

echo "Taking the opportunity to backup data volume while stopped (i.e., inactive database)."
mkdir -p backup
sudo tar cvfz backup/"$SERVICE_NAME"_"$(date +%Y%m%d)".tar.gz /docker_bind/"$SERVICE_NAME" || error "Failed to back up authelia docker_bind!"

exec docker compose -f "$SERVICE_NAME".yaml up -d || error "Failed to execute newer version of Nginx Proxy Manager!"
