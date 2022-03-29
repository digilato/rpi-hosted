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


function create_env_config() {

  FILE=.env
  if test -f "$FILE"; then
    echo "$FILE file already exists. Skipping..."
  else
    get_user_input
    printf "Creating local .env file for docker compose configuration\n"
    cat > .env <<EOL
# autoheal environment variables. Edit HERE and NOT in the docker_compose.yaml file to maintain
# changes across updates! Otherwise changes will be overwritten when pulling updates with git!
# Additional details can be found at https://github.com/willfarrell/docker-autoheal

AUTOHEAL_VERSION=1.2.0
WEBHOOK_URL=""    # post message to the webhook if a container was restarted (or restart failed)

# below are advanced defaults that typically don't need to be touched
AUTOHEAL_CONTAINER_LABEL=autoheal
AUTOHEAL_INTERVAL=5   # check every 5 seconds
AUTOHEAL_START_PERIOD=0   # wait 0 seconds before first health check
AUTOHEAL_DEFAULT_STOP_TIMEOUT=10   # Docker waits max 10 seconds (the Docker default) for a container to stop before killing during restarts (container overridable via label, see below)
CURL_TIMEOUT=30     # --max-time seconds for curl requests to Docker API

EOL
  fi
}


check_internet

create_env_config  

printf "Settings (e.g., version or webhook) need to be configured in the .env file.\n"
printf "\n"

vi .env

printf "===============================================================\n\n"
printf "Please make the necessary changes then execute the following: \n\n"
printf "docker compose up -d \n"
printf "\n"
printf "===============================================================\n\n"


# read -r RESPONSE
# if [ "$RESPONSE" = "n" ] || [ "$RESPONSE" = "N" ]; then
#   exit 0
# fi

#exec docker compose up -d