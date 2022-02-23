#!/bin/bash

#TODO: make sure things are written in the script directory and not where it was called from (i.e., dirname $0)
#TODO: Add advanced settings as an option in the .env and docker-compse.yaml file so they are an option in the future.

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


function create_env_config() {

  FILE=.env
  if test -f "$FILE"; then
    echo "$FILE file already exists. Skipping..."
  else
    get_user_input
    printf "Creating local .env file for docker compose configuration\n"
    cat > .env <<EOL
# Cloudflare DDNS environment variables. Edit HERE and NOT in the docker-compose.yaml file to maintain
# changes across updates! Otherwise changes will be overwritten will pulling updates with git!
# Advanced settings are available at https://hub.docker.com/r/oznu/cloudflare-ddns/

CFDDNS_VERSION='latest'
API_KEY='XXXXXXXXXXX'
ZONE='example.com'
SUBDOMAIN='subdomain'
PROXIED='true'

EOL
  fi
}


check_internet

create_env_config  

printf "Cloudflare DNS Zone settings need to be configured in the .env file.\n"
printf "\n"

vi .env

printf "===============================================================\n\n"
printf "Please make the necessary changes then execute the following: \n\n"
printf "docker compose up -d \n"
printf "\n"
printf "===============================================================\n\n"


#exec docker compose up -d