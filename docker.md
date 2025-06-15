## Docker

Installing docker on all the homelabs.

```
yay -Syu docker
```

## configure start on boot

```
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

## Docker swarm

use docker swarm join generate by this command for other commands

```
docker swarm init


```

op item get "docker-swarm" --vault "dev" --field "password"

### Shown running container

```
docker stack ls
docker stack services homarr

```

## deploy to a docker swarm

export DOCKER_HOST=ssh://eduuh@home2
docker stack deploy -c docker-compose.yml homarr
