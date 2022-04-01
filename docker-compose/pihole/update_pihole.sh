#!/bin/bash


function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  
  if wget -q --spider http://github.com; then
    printf "Online. Continuing.\n"
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

check_internet

pihole_name=$(docker ps | grep pihole | awk '{print $2}')
cloudflared_name=$(docker ps | grep cloudflared | awk '{print $2}')

docker compose down || error "Failed to birng down pihole!"

sudo docker rmi "$pihole_name" || error "Failed to remove/untag pihole image from Docker!"
sudo docker rmi "$cloudflared_name" || error "Failed to remove/untag cloudflared image from Docker!"

printf "Taking the opportunity to backup data volume while stopped (i.e., inactive database).\n"
mkdir -p backup
sudo tar cvfz backup/pihole_"$(date +%Y%m%d)".tar.gz /docker_bind/pihole || error "Failed to back up pihole docker_bind!\n"

docker compose up -d || error "Failed to execute newer version of Nginx Proxy Manager!\n"
