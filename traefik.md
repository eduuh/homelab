# Traefik Configuration

Traefik is now part of the unified homelab stack and is managed through the `homelab.sh` script.

## Network Setup

The traefik-public network is automatically created by the script, but can be created manually if needed:

```bash
docker network create \
 --driver=overlay \
 --attachable \
 traefik-public
```

## Deployment

To deploy Traefik (as part of the homelab stack):

```bash
./homelab.sh deploy
```

Traefik will be accessible at: http://traefik.[hostname]

## Configuration

Traefik's configuration is defined in the `homelab-stack.yml` file. Key settings include:

- API dashboard enabled (accessible at port 8080)
- Docker Swarm mode provider enabled
- Web (HTTP) and WebSecure (HTTPS) entrypoints defined
- Logging in debug mode
