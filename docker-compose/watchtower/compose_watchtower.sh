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


function create_env_config() {

  FILE=.env
  if test -f "$FILE"; then
    echo "$FILE file already exists. Skipping..."
  else
    get_user_input
    printf "Creating local .env file for docker compose configuration\n"
    cat > .env <<EOL
# watchtower environment variables. Edit HERE and NOT in the docker_compose.yaml file to maintain
# changes across updates! Otherwise changes will be overwritten will pulling updates with git!

TIMEZONE='America/Toronto'  #change to appropriate timezone according to https://en.wikipedia.org/wiki/List_of_tz_database_time_zones 
TZ='America/Toronto'
WATCHTOWER_NOTIFICATION_EMAIL_FROM='support@gmail.com'  #email address in the 'from' field
WATCHTOWER_NOTIFICATION_EMAIL_TO='username@example.com'  #email address the messsage should be sent to
WATCHTOWER_NOTIFICATION_EMAIL_SERVER='smtp.gmail.com'  #example if using gmail account
WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT='465'  #example if using gmail account
WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER='support@gmail.com'  #email address used for SMTP authentication
WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD='Pa55w0rd!'  #password for SMTP authentication

EOL
  fi
}


check_internet

create_env_config  

printf "Email settings need to be configured in the .env file."
printf "Please make the necessary changes then execute the following: "
printf "docker compose up -d"

# read -r RESPONSE
# if [ "$RESPONSE" = "n" ] || [ "$RESPONSE" = "N" ]; then
#   exit 0
# fi

# exec docker compose up -d