# Docker Swarm Management with Homarr

This document provides instructions for managing your 3-node Docker Swarm cluster with Homarr dashboard.

## System Overview

- **Nodes**: 3-node Docker Swarm cluster
- **Dashboard**: Homarr (running on manager node)
- **Reverse Proxy**: Traefik
- **Network**: traefik-public (overlay network)
- **Connectivity**: Tailscale for secure access across devices

## Initial Setup

1. Initialize Docker Swarm on your first node (if not already done):
   ```bash
   docker swarm init --advertise-addr <MANAGER-IP>
   ```

2. Join worker nodes to the swarm using the command provided by the init command.
   ```bash
   docker swarm join --token <TOKEN> <MANAGER-IP>:2377
   ```

3. Run the unified management script to set up the homelab stack:
   ```bash
   ./homelab.sh deploy
   ```

## Accessing Homarr

1. Access Homarr through Tailscale:
   - From any device in your Tailnet: `http://homarr.<tailscale-hostname>`
   - Example: `http://homarr.node1` (where node1 is your server's Tailscale hostname)
   - See `tailscale-access.md` for detailed instructions on Tailscale setup

2. Alternative local access: http://homarr.home
   - For devices on the same local network not using Tailscale

2. Initial Configuration:
   - On first access, Homarr will guide you through setup
   - Add your Docker services as widgets
   - Set up monitoring for your nodes

## Configuring Homarr for Swarm Management

1. **Docker Integration**:
   - Homarr automatically detects Docker services through the mounted Docker socket
   - Add Docker widgets to monitor containers across your swarm

2. **Service Monitoring**:
   - Add service-specific widgets for each critical service
   - Set up health checks to monitor service status

3. **Dashboard Organization**:
   - Group services by node or function
   - Use categories to organize your dashboard

## Common Management Tasks

### Viewing Node Status
```bash
docker node ls
```

### Scaling Services
```bash
docker service scale <SERVICE-NAME>=<NUMBER>
```

### Updating Services
```bash
docker service update --image <NEW-IMAGE> <SERVICE-NAME>
```

### Inspecting Services
```bash
docker service inspect <SERVICE-NAME>
```

### Viewing Service Logs
```bash
docker service logs <SERVICE-NAME>
```

## Updating Homarr

To update Homarr:

```bash
cd /Users/eduuh/projects/homelab
docker stack deploy -c .conf/homarr/docker-compose.yaml homarr
```

## Removing Homarr

If needed:

```bash
docker stack rm homarr
```

## Adding More Nodes

1. On the manager node, get the join token:
   ```bash
   docker swarm join-token worker
   ```

2. On the new node, run the provided join command.

3. Labels can be added to nodes for targeted deployments:
   ```bash
   docker node update --label-add role=app-server <NODE-NAME>
   ```

## Troubleshooting

- **Service Not Deploying**: Check node constraints and resource availability
- **Network Issues**: Verify overlay network connectivity
- **Dashboard Not Accessible**: Check Traefik logs and configuration
- **Node Communication**: Ensure ports 2377, 7946, and 4789 are open between nodes

## Next Steps for Enhancement

1. Add node monitoring with Prometheus and Grafana
2. Implement secure access with HTTPS
3. Set up alerting for service disruptions
4. Configure backups for critical configuration
