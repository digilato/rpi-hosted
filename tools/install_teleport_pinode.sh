#!/bin/bash
# This if for installation on machines that do not already have Teleport as part of the repo. For future, we could 
# to a test and automate the repo addition and installation OR the tarball, similar to how docker install script works.

VERSION=v8.2.0 # Could automate for latest, but individuals might not want this. Find latest at https://goteleport.com/teleport/download/
OPSYS=$(uname -s | awk '{print tolower($0)}')  # 'darwin' 'linux' or 'windows'
ARCH=$(uname -m)
case $ARCH in
    i386|i686) ARCH=386 ;;
    x86_64) ARCH=amd64 ;;
    armhf|armv7*) ARCH=arm ;;
    aarch64*) ARCH=arm64 ;;
esac

TELEPORT_PACKAGE=teleport-$VERSION-$OPSYS-$ARCH-bin.tar.gz

AUTH_SERVER=teleport.example.com # Used to be manual, now prompts below. 
# Use port 3025 if internal, or port 443 for external v8+ (or 3080 for older port dependent setup)
PORT=3080


####################


function check_root_user() {
  if [ "$EUID" -ne 0 ]; then
    printf 'This script requires sudo/root permissions'
    exit
  fi
}

function clean_teleport() {
  printf "Removing existing teleport install"
  rm -rf /var/lib/teleport
  rm /usr/local/bin/teleport
  rm /etc/teleport.yaml
  rm /tmp/"$TELEPORT_PACKAGE"
  rm -rf /tmp/teleport
}

function get_user_input() {
  printf "==============================="
  printf "Ensure you have run the following in the main teleport server to get the auth token and ca-pin."
  printf "sudo tctl tokens add --type=node"
  printf "==============================="
  printf " "
  printf "What is the domain name or IP for the Auth Server?: "
  printf "   e.g., teleport.example.com  (note: WITHOUT http://) "  
  read -r AUTH_SERVER
  printf " "
  printf "What is the name of this RPi node?: "
  read -r NODE_NAME
  printf " "
  printf "Enter the auth token: "
  read -r AUTH_TOKEN
  printf " "
  printf "Enter ca-pin (eg.'sha256:2154125...'): "
  read -r CA_PIN

  printf 'Auth Server: %s ' "$AUTH_SERVER"
  printf 'Node Name: %s ' "$NODE_NAME"
  printf 'Auth Token: %s ' "$AUTH_TOKEN"
  printf 'CA Pin: %s' "$CA_PIN"
  printf ""
  printf "This script will delete your existing teleport install?"
  printf "Continue with these settings? (y\n)"

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
  printf "Creating Teleport Config in /etc/teleport.yaml"
  cat > /etc/teleport.yaml <<EOL
---
teleport:
  nodename: ${NODE_NAME}
  ca_pin: ${CA_PIN}
  auth_token: "${AUTH_TOKEN}"
  auth_servers:
  - "${AUTH_SERVER}:${PORT}"
  # advertise_ip is for internal networks and not using a tunnel. Easiest to just use tunnel
  # advertise_ip: $(hostname --all-ip-addresses | awk '{print $1}')
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
    command: ["/bin/sh", "-c", "hostname --all-ip-addresses | awk '{print $1}'"]
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
  printf "Starting systemd teleport.service"
  sudo systemctl daemon-reload
  sudo systemctl enable teleport
  sudo systemctl restart teleport
}

function get_teleport_status() {
  printf "Checking teleport status"
  sleep 5
  sudo journalctl -u teleport | tail -n 100
}


printf "=== TELEPORT NODE INSTALLER ==="
check_root_user
clean_teleport
get_user_input
install_teleport
create_teleport_config
systemd_start
get_teleport_status
