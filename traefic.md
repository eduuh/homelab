## On manager Node

docker network create \
 --driver=overlay \
 --attachable \
 traefik-public

## deploy

docker stack deploy -c traefik.yml traefik
