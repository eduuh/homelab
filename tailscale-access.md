# Accessing Homarr over Tailscale

This guide explains how to access your Hom3. If the script detects the wrong hostname, you can manually set it:
   ```bash
   export TAILSCALE_HOSTNAME=yourpreferredhostname
   ./homelab.sh deploy
   ```ashboard from any device connected to your Tailnet.

## Prerequisites

1. Tailscale installed and running on your Docker Swarm manager node
2. Tailscale installed on any client devices you want to access Homarr from
3. MagicDNS enabled in your Tailnet (recommended)

## Setup Instructions

### 1. Ensure Tailscale is Running

On your Docker Swarm manager node:

```bash
tailscale status
```

Make note of the hostname (e.g., `node1`). This will be used in the URL.

### 2. Enable MagicDNS in Tailscale Admin Console

1. Go to https://login.tailscale.com/admin/dns
2. Enable MagicDNS
3. Wait for changes to propagate (usually just a few minutes)

### 3. Configure Homarr with Tailscale

The deployment script automatically configures Homarr to use your Tailscale hostname.
The URL will be in the format: `http://homarr.<tailscale-hostname>`

### 4. Access Homarr from Tailnet Devices

From any device connected to your Tailnet:

1. Open a web browser
2. Navigate to `http://homarr.<tailscale-hostname>`
   - For example: `http://homarr.node1`
   - Replace `node1` with your actual Tailscale hostname

If MagicDNS is not enabled, you can still access using the Tailscale IP address:
1. Get the Tailscale IP with `tailscale status` on the host machine
2. Access via `http://<tailscale-ip>:80`

### 5. Custom Domain Name (Optional)

If you prefer a simpler domain across your Tailnet:

1. Edit your Tailscale ACLs to add a custom nameserver entry:
   ```json
   "derpmap": {
     "Nameservers": ["100.100.100.100"],
     "Domains": ["homelab.internal"],
   }
   ```

2. Add DNS records in your Tailscale admin console:
   - Name: `homarr.homelab.internal`
   - Value: `<tailscale-ip-of-host>`

3. Update traefik configuration to use this domain

## Troubleshooting

1. **Cannot access Homarr from Tailnet device**
   - Verify both devices are connected to Tailnet: `tailscale status`
   - Check that the host machine is reachable: `ping <tailscale-hostname>`
   - Verify Traefik is properly routing requests: Check Traefik logs

2. **MagicDNS not working**
   - Make sure MagicDNS is enabled in Tailscale admin console
   - Run `tailscale up --accept-dns` on clients to ensure they use Tailscale DNS
   - Some clients may need to restart the Tailscale service

3. **Wrong hostname detected**
   - If the script detects the wrong hostname, you can manually set it:
   ```bash
   export TAILSCALE_HOSTNAME=yourpreferredhostname
   ./deploy-homarr.sh
   ```

## Advanced Configuration

### Exposing Other Services

To expose other services over Tailscale, follow the same pattern:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`myservice.${TAILSCALE_HOSTNAME:-home}`)"
  - "traefik.http.services.myservice.loadbalancer.server.port=<service-port>"
```

### Securing with HTTPS

Tailscale provides end-to-end encryption, but if you want HTTPS:

1. Set up a certificate with Traefik (Let's Encrypt or self-signed)
2. Configure Traefik to use the certificate
3. Access via `https://homarr.<tailscale-hostname>`
