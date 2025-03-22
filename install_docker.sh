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

curl -sSL https://get.docker.com | sh || error "Failed to install Docker."

# Add the user to the docker group so sudo is not required
sudo usermod -aG docker $USER || error "Failed to add user to the Docker usergroup."

# mkdir for volume binding which is easier to backup with cron and tar than docker volumes
sudo mkdir /docker_bind || error "Failed to add directory for binding docker data."


#############################################
# TODO: Still need to see about autoamtically adding backup for the docker_bind directory
#
# Create an automated back up in /etc/cron.weekly/docker_backup with the contents.
# -----
# #!/bin/bash
# DATE=$(date +%Y%m%d)
# BACKUP_DIR=/PATH TO/docker_backup
# 
# # timestamp each backup #
# tar zcvpf "$BACKUP_DIR"/docker_backup-$DATE.tar.gz /docker_bind
# 
# # Delete files older than 100 days #
# find $BACKUP_DIR/* -mtime +100 -exec rm {} \;
# -----
#
# # change user to root and chmod 755 docker_backup
# 
#############################################
# Could also see about automating (optional) docker container upgrades
# with docker compose pull, but this could cause issues depending on which 
# docker compose we are targetting. Better to use something like watchtower
# with NOTIFY only, and then use the update_XXXX.sh script so that a backup 
# of the data is run before the upgrade so that it can easily be restored if
# there are any issues.
##############################################





echo "Remember to logoff/reboot for the changes to take effect."

