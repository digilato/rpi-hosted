# docker_compose

Collection of `docker compose` files that essentially allow deployment of yaml files via portainer, or via CLI if that is the preferred/only option. The corresponding installation script will automate the creation of binding volumes, prompt for variables (e.g., passwords, auth_keys, etc.) and initiate `docker compose -f example.yaml up -d`. 

**Note:** If using the CLI (as opposed to portainer), run `install_docker_compose.sh` first to make sure it's installed.

In the script case, binding volumes are used to ease backup via `cron` and `tar` if desired, without editing scripts. If docker volumes are preferred, it might be easier to make those changes using portainer. Docker volumes might also be preferred if the user will not have access to the CLI to create the binding directories.

TODO: Add scripts to automate backup and restoration of docker volumes, which will ease installation of containers that don't require an externally edited config file (e.g., pihole, nginx-proxy-manager, etc.)

## Future Considerations

1. Use Portainer templates instead of docker compose. Docker compose would still be needed for remote management since updating specific containers (i.e., nginx-proxy-manager, Authelia, and Portainer itself) cannot be done through the Portainer UI since the remote connecition would be lost. Those would need to be done through the UI. The rest could be done through Portainer templates to both ease installation, but also negate any lost changes to docker-compose.yaml files when pulling updated scripts through git. The latter is solved by writing .env files, using those variables within the docker-compose.yaml

2. Move to docker volumes to simplify installation. There was a note on Authelia that binds (NOT volumes) had to be used; why? Is this still correct? Will add scripts to ease backing up volumes that could be used manually or with `cron`. This would help reduce the requirement for hard paths making everything more portable across environments without being so opinionated.



