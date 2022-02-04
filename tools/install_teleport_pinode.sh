#!/bin/bash

export version=v8.1.1 # Could automate for latest, but individuals might not want this. Find latest at https://goteleport.com/teleport/download/
export os=$(uname -s) | awk '{print tolower($0)}'  # 'darwin' 'linux' or 'windows'
# TODO: Automate this portion.
export arch=arm # '386' 'arm' on linux or 'amd64' for all distros 

TELEPORT_PACKAGE=teleport-$version-$os-$arch-bin.tar.gz

AUTH_SERVER=teleport.example.com # Used to be manual, now prompts below. TODO: For personal use, could use this as defualt
# Use port 3025 if internal, or port 443 for external v8+ (or 3080 for older port dependent setup)
PORT=3080


####################


function check_root_user() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo/root permissions"
    exit
  fi
}

function clean_teleport() {
  echo "Removing existing teleport install"
  rm -rf /var/lib/teleport
  rm /usr/local/bin/teleport
  rm /etc/teleport.yaml
  rm /tmp/"$TELEPORT_PACKAGE"
  rm -rf /tmp/teleport
}

function get_user_input() {
  echo "==============================="
  echo "Ensure you have run the following in the main teleport server to get the auth token and ca-pin."
  echo "sudo tctl tokens add --type=node"
  echo "==============================="
  echo " "
  echo "What is the domain name or for the Auth Server?: "
  echo "   e.g., teleport.example.com  (note: WITHOUT http://) "  
  read -r AUTH_SERVER
  echo " "
  echo "What is the name of this pi node?: "
  read -r NODE_NAME
  echo " "
  echo "Enter the auth token: "
  read -r AUTH_TOKEN
  echo " "
  echo "Enter ca-pin (eg.'sha256:2154125...'): "
  read -r CA_PIN

  echo "Auth Server: $AUTH_SERVER"
  echo "Node Name: $NODE_NAME"
  echo "Auth Token: $AUTH_TOKEN"
  echo "CA Pin: $CA_PIN"
  echo ""
  echo "This script will delete your existing teleport install?"
  echo "Continue with these settings? (y\n)"

  read -r RESPONSE
  if [ "$RESPONSE" = "n" ] || [ "$RESPONSE" = "N" ]; then
    exit 0
  fi
}

function install_teleport() {
  echo "Installing teleport"
  cd /tmp || exit
  curl -O https://get.gravitational.com/"$TELEPORT_PACKAGE"
  tar -xzf "$TELEPORT_PACKAGE"
  cd teleport || exit
  sudo ./install
  cp "$PWD"/examples/systemd/teleport.service /etc/systemd/system/teleport.service
  cd /tmp || exit
  rm -rf teleport
  rm "$TELEPORT_PACKAGE"
}

function create_teleport_config() {
  echo "Creating Teleport Config in /etc/teleport.yaml"
  cat > /etc/teleport.yaml <<EOL
---
teleport:
  nodename: ${NODE_NAME}
  ca_pin: ${CA_PIN}
  auth_token: "${AUTH_TOKEN}"
  auth_servers:
  - "${AUTH_SERVER}:${PORT}"
  #advertise_ip: $(hostname -I)
auth_service:
  enabled: false
proxy_service:
  enabled: false
ssh_service:
  enabled: true
  labels:
    env: CHANGEME
  commands:
  - name: Hostname
    command: [hostname]
    period: 10m0s
  - name: IP
    command: ["/usr/bin/hostname", "-I"]
    period: 10m0s
  - name: uptime
    command: ["/usr/bin/uptime", "-p"]
    period: 10m0s
  - name: pro
    command: ["/usr/bin/uname", "-m"]
    period: 24h0m0s
  - name: os
    command: ["/usr/bin/uname", "-o"]
    period: 24h0m0s
EOL
}

function systemd_start() {
  echo "Starting systemd teleport.service"
  sudo systemctl daemon-reload
  sudo systemctl enable teleport
  sudo systemctl restart teleport
}

function get_teleport_status() {
  echo "Checking teleport status"
  sleep 5
  sudo journalctl -u teleport | tail -n 100
}


echo "=== TELEPORT NODE INSTALLER ==="
check_root_user
clean_teleport
get_user_input
install_teleport
create_teleport_config
systemd_start
get_teleport_status
