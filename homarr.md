# Homarr Dashboard

Homarr is now part of the unified homelab stack and is managed through the `homelab.sh` script.

## Deployment

To deploy Homarr (as part of the homelab stack):

```bash
./homelab.sh deploy
```

Homarr will be accessible at: http://homarr.[hostname]

## Updating Homarr

To update Homarr to the latest version:

```bash
# Pull the latest image
docker pull ghcr.io/ajnart/homarr:latest

# Redeploy the stack with the new image
./homelab.sh deploy
```

## Volume Locations

Homarr data is stored in the following locations:
- Configuration: `./.conf/homarr/config`
- Icons: `./.conf/homarr/icons`
- General data: `./.conf/homarr/data`

## Removing Homarr

Homarr can be removed as part of the homelab stack:

```bash
./homelab.sh remove
```
