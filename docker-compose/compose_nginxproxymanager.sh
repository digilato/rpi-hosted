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

mkdir -p /docker_bind/nginxproxymanager/data || error "Failed to create bindings directory."
mkdir -p /docker_bind/nginxproxymanager/letsencrypt || error "Failed to create bindings directory."

exec docker compose -f nginxproxymanager.yaml up -d