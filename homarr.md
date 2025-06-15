## Updating Homarr

```
docker stack deploy -c docker-compose.yaml homarr

```

To update, navigate to the directory with the docker-compose.yaml located.
Stop Homarr using docker compose down
Pull the newest image of Homarr using docker compose pull
Start Homarr again using docker compose up -d (-d for detached mode - start in background)
Delete the old image using docker image prune (Warning: this also removes you other unused images - not just Homarr)

## Re-deploy

docker stack rm homarr
