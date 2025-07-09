# Homelab Setup

This repository contains the Docker Compose configuration for a homelab setup with various services including IT-Tools, Portainer, Homarr, NetAlertX, Uptime Kuma, and Nginx Proxy Manager for HTTPS.

## Services Overview

- **IT-Tools**: A collection of useful IT tools
- **Portainer**: Docker container management UI
- **Homarr**: A simple, yet powerful dashboard for your server
- **NetAlertX**: Network device monitoring and alerting
- **Uptime Kuma**: Uptime monitoring solution
- **Nginx Proxy Manager**: Reverse proxy with SSL/TLS certificate management

## Running the Setup

To run the homelab services using the Docker Compose file:

```bash
# Start all services in the background
docker compose -f firewall-compose.yaml up -d

# View logs for all services
docker compose -f firewall-compose.yaml logs

# View logs for a specific service
docker compose -f firewall-compose.yaml logs [service-name]

# Stop all services
docker compose -f firewall-compose.yaml down

# Restart a specific service
docker compose -f firewall-compose.yaml restart [service-name]
```

## Service Access

Once the services are running, you can access them at:

- IT-Tools: http://localhost:8080
- Portainer: http://localhost:9000
- Homarr: http://localhost:7575
- NetAlertX: Access through host network
- Uptime Kuma: http://localhost:3001
- Nginx Proxy Manager: http://localhost:81 (admin interface)

## HTTPS Setup with Nginx Proxy Manager

### Initial Login

1. Access Nginx Proxy Manager at http://localhost:81
2. Login with default credentials:
   - Email: `admin@example.com`
   - Password: `changeme`
3. You'll be prompted to change your password on first login

### Setting up a Proxy Host

1. Go to "Proxy Hosts" tab and click "Add Proxy Host"
2. Configure your domain:
   - Domain Names: Enter your domain or subdomain
   - Scheme: http
   - Forward Hostname/IP: Name of your service (e.g., `uptime-kuma`)
   - Forward Port: Internal port of the service (e.g., `3001`)
3. Enable SSL:
   - Click on the SSL tab
   - Request a new SSL certificate with Let's Encrypt or use a custom certificate
   - Choose "Force SSL" to redirect HTTP to HTTPS

### Using Custom Nginx Configurations

For advanced users who need custom Nginx settings:

1. Custom configuration files are stored in `./nginx-proxy-manager/custom/`
2. A sample configuration file is provided at `./nginx-proxy-manager/custom/proxy-settings.conf`
3. To use these configurations:
   - When editing a Proxy Host, go to the "Advanced" tab
   - In the "Custom Nginx Configuration" field, add:
     ```
     include /etc/nginx/custom/proxy-settings.conf;
     ```
   - This will include your custom settings for that specific proxy host

## Data Persistence

All services are configured with persistent storage:

- Homarr data: `./homarr/appdata`
- NetAlertX data: `./netalertx/config` and `./netalertx/db`
- Uptime Kuma data: `./uptime-kuma`
- Portainer data: Docker volume `portainer_data`
- Nginx Proxy Manager data: `./nginx-proxy-manager/data` and `./nginx-proxy-manager/letsencrypt`