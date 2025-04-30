# Helpers for dev containers

## Copy files between host computer and the dev container

Here's an example of copying the ssh key from host computer to the dev container:
```bash
docker cp ~/.ssh/id_rsa <containerid>:/home/vscode/.ssh/id_rsa
```

## Clean up after a dev container

```bash
# Stop and Remove the Container
docker stop <container_name>
docker rm <container_name>
# Remove the Associated Volume (if needed)
docker volume ls
docker volume rm <volume_name>
# Clean Up Docker Images and Networks (deeper cleanup)
docker image prune -a
docker system prune -a
```

