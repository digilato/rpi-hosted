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

sudo mkdir -p /docker_bind/authelia/data || error "Failed to create bindings directory."
sudo mkdir -p /docker_bind/authelia/letsencrypt || error "Failed to create bindings directory."


# TODO: NEED TO COPT SAMPLE FILES


exec docker compose -f authelia.yaml up -d  || error "Failed to start Nginx Proxy Manager"