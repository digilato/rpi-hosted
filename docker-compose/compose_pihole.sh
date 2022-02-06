#!/bin/sh

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

check_internet


EXTERNAL_IP=$(ip route get 8.8.8.8 | awk '{gsub(".*src",""); print $1; exit}')
export EXTERNAL_IP

echo "Using IP address $EXTERNAL_IP"
echo "What password should be used for pihole web UI?"
printf ">  "
read -r PIHOLE_PASS

export PIHOLE_PASS

mkdir -p /docker_binding/pihole/pihole || error "Failed to create bindings directory."
mkdir -p /docker_bind/pihole/dnsmasq.d || error "Failed to create bindings directory."

exec docker compose -f pihole.yaml up -d