#!/bin/bash

# could also use (works debian and RPi OS):  $(ip route get 8.8.8.8 | awk '{gsub(".*src",""); print $1; exit}')
# could also use (works debian and RPi OS): ip=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
# Also works Could we use this for Teleport IP Address?: `hostname --all-ip-addresses | awk '{print $1}'` 
# Need to test on other OS's to see how they work.
# DOES NOT WORK ON DEBIAN (no eth0!): $(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

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


function get_user_input() {
  printf "===============================\n"
  printf "Pi-hole Web UI password.\n"
  printf "===============================\n"
  printf " "
  printf "Please set the password to use for the pihole webUI\n"
  read -rp '>  ' PIHOLE_PASS
  

}


function create_env_config() {

  FILE=.env
  if test -f "$FILE"; then
    echo "$FILE file already exists. Skipping..."
  else
    get_user_input
    printf "Creating local .env file for docker compose configuration\n"
    cat > .env <<EOL
# pihole environment variables. Edit HERE and NOT in the pihole.yaml docker_compose file to maintain
# changes across updates! Otherwise changes will be overwritten will pulling updates with git!
---
TIMEZONE='America/Toronto'  #change to appropriate timezone according to https://en.wikipedia.org/wiki/List_of_tz_database_time_zones 
EXTERNAL_IP=$(ip route get 8.8.8.8 | awk '{gsub(".*src",""); print $1; exit}')
HTTP_PORT=680  #behind proxy, change if not using proxy
HTTPS_PORT=6443  #behind proxy, change if not using proxy
PIHOLE_VERSION=latest  #allows for pegging to specific version if desired
PIHOLE_PASS=$PIHOLE_PASS
CLOUDFLARE_VERSION=latest  #allows for pegging to specific version if desired

EOL
  fi
}


check_internet

create_env_config  


sudo mkdir -p /docker_binding/pihole/pihole || error "Failed to create bindings directory."
sudo mkdir -p /docker_bind/pihole/dnsmasq.d || error "Failed to create bindings directory."

exec docker compose -f pihole.yaml up -d