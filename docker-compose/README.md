# docker_compose

Collection of `docker compose` files that essentially allow deployment of yaml files via portainer, or via CLI is that is the only option. The corresponding installation script will automate the creation of binding volumes, prompt for variables (e.g., passwords, auth_keys, etc.) and initiate `docker compose -f example.yaml up -d`. 

Note: If using the CLI, run `install_docker_compose.sh` first to make sure it's installed.

In the script case, binding volumes are used to ease backup via `cron` and `tar` if desired, without editing scripts. If docker volumes are preferred, it might be easier to make those changes using portainer. Docker volumes might also be preferred if the user will not have access to the CLI to create the binding directories.


