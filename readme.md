# Docker Swarm Homelab

This repository contains the configuration for a 4-node Docker Swarm homelab setup with Traefik and Homarr dashboard, accessible via Tailscale.

- 1 Node is in the cloud (leader for docker swarm)

## Features

- **Docker Swarm** orchestration across multiple nodes
- **Traefik** reverse proxy for service routing and load balancing
- **Homarr** dashboard for managing and monitoring services
- **Tailscale** integration for secure access from any device in your Tailnet

## Quick Setup

1. Install Docker on all nodes ([instructions](./docker.md))
2. Initialize Docker Swarm on manager node:
   ```bash
   docker swarm init --advertise-addr <MANAGER-IP>
   ```
3. Join worker nodes using the command output from the init step
4. Deploy the homelab stack:
   ```bash
   ./homelab.sh deploy
   ```

## Management

The `homelab.sh` script provides a unified interface for all operations:

```bash
./homelab.sh deploy    # Deploy or update the stack
./homelab.sh status    # Check status of services and nodes
./homelab.sh remove    # Remove the stack
./homelab.sh help      # Show usage information
```

## Accessing Services

Access your services through Tailscale from any connected device:

- **Homarr Dashboard**: `http://homarr.[hostname]`
- **Traefik Dashboard**: `http://traefik.[hostname]`

Where `[hostname]` is your server's Tailscale hostname.

## Stack Components

### Traefik

- Automatic service discovery and load balancing
- Routing of requests to appropriate services
- Dashboard for monitoring routes

### Homarr

- Service monitoring and management dashboard
- Docker container overview
- System statistics and customizable widgets

## Documentation

- [Docker Setup](docker.md) - Docker installation guide
- [Swarm Management](swarm-management.md) - Docker Swarm management
- [Tailscale Access](tailscale-access.md) - Secure access via Tailscale
- [SSH Setup](ssh.md) - SSH configuration

## Maintenance

### Regular Tasks

- [ ] Update nodes every 2 weeks
- [ ] Check logs periodically: `docker service logs homelab_traefik`
- [ ] Monitor resource usage: `./homelab.sh status`

### Node Configuration

The cluster consists of 3 nodes:

- **azure1**: Manager node (primary controller)
- **Home1**: Worker node
- **Home2**: Worker node
- **Home3**: Worker node (leader)
