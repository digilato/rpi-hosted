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

nginx_pid=$(docker ps | grep nginx-proxy-manager | awk '{print $1}')
nginx_name=$(docker ps | grep nginx-proxy-manager | awk '{print $2}')

sudo docker stop "$nginx_pid" || error "Failed to stop portainer!"
sudo docker rm "$nginx_pid" || error "Failed to remove portainer container!"
sudo docker rmi "$nginx_name" || error "Failed to remove/untag images from the container!"

echo "Taking the opportunity to backup data volume while stopped (i.e., inactive database)."
mkdir -p backup
sudo tar cvfz backup/nginxproxymanager_"$(date +%Y%m%d)".tar.gz /docker_bind/nginxproxymanager || error "Failed to back up authelia docker_bind!"

exec docker compose -f nginxproxymanager.yaml up -d || error "Failed to execute newer version of Nginx Proxy Manager!"
