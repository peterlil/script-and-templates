# Helpers for dev containers

## Copy files between host computer and the dev container

Here's an example of copying the ssh key from host computer to the dev container:
```bash
docker cp ~/.ssh/id_rsa <containerid>:/home/vscode/.ssh/id_rsa
```