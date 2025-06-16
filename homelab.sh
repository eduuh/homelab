#!/bin/bash
# homelab.sh - Unified management script for Docker Swarm Homelab
# Usage: ./homelab.sh [deploy|status|remove|help]

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Function to display script usage
show_help() {
  echo -e "${BLUE}Docker Swarm Homelab Management Script${NC}"
  echo
  echo "Usage: ./homelab.sh [command]"
  echo
  echo "Commands:"
  echo "  deploy   - Deploy or update the full homelab stack"
  echo "  status   - Show status of the homelab stack services and nodes"
  echo "  remove   - Remove the homelab stack"
  echo "  help     - Show this help message"
  echo
  echo "Examples:"
  echo "  ./homelab.sh deploy    # Deploy the homelab stack"
  echo "  ./homelab.sh status    # Check the status of services and nodes"
  echo "  ./homelab.sh remove    # Remove the homelab stack"
  echo
}

# Function to check if Docker Swarm is initialized
check_swarm() {
  if ! docker info &>/dev/null; then
    echo -e "${RED}Error: Docker is not running or not accessible.${NC}"
    exit 1
  fi
  
  if ! docker info | grep -q "Swarm: active"; then
    echo -e "${RED}Docker Swarm is not active. Please initialize it first:${NC}"
    echo "Run: docker swarm init (on the first node)"
    echo "Then join other nodes using the command provided by the init."
    exit 1
  fi
}

# Function to get Tailscale hostname
get_tailscale_hostname() {
  if ! command -v tailscale &>/dev/null; then
    echo -e "${YELLOW}Tailscale not found. Using default hostname.${NC}"
    export TAILSCALE_HOSTNAME="homelab"
    return
  fi
  
  export TAILSCALE_HOSTNAME=$(tailscale status --self 2>/dev/null | head -1 | awk '{print $2}')
  if [ -z "$TAILSCALE_HOSTNAME" ] || [ "$TAILSCALE_HOSTNAME" == "self" ]; then
    echo -e "${YELLOW}Could not automatically detect Tailscale hostname${NC}"
    echo "Please provide a hostname for your Tailscale node:"
    read -p "> " TAILSCALE_HOSTNAME
    if [ -z "$TAILSCALE_HOSTNAME" ]; then
      TAILSCALE_HOSTNAME="homelab"
      echo -e "Using default hostname: ${YELLOW}$TAILSCALE_HOSTNAME${NC}"
    fi
  fi
  echo -e "Using Tailscale hostname: ${GREEN}$TAILSCALE_HOSTNAME${NC}"
}

# Function to ensure required network exists
ensure_network() {
  if ! docker network ls | grep -q "traefik-public"; then
    echo -e "${YELLOW}Creating traefik-public network...${NC}"
    docker network create --driver overlay --attachable traefik-public
  else
    echo -e "${GREEN}traefik-public network already exists.${NC}"
  fi
}

# Function to create necessary directories
create_directories() {
  echo -e "${BLUE}Creating necessary directories...${NC}"
  mkdir -p ./.conf/homarr/config
  mkdir -p ./.conf/homarr/icons
  mkdir -p ./.conf/homarr/data
}

# Function to deploy the homelab stack
deploy_homelab() {
  check_swarm
  get_tailscale_hostname
  
  # Check node status
  echo -e "${BLUE}=== Current Swarm Node Status ===${NC}"
  docker node ls
  echo -e "${BLUE}===============================${NC}"
  
  ensure_network
  create_directories
  
  # Deploy the combined homelab stack
  echo -e "${GREEN}Deploying combined Homelab stack (Traefik + Homarr)...${NC}"
  docker stack deploy -c homelab-stack.yml homelab
  
  # Show status of services
  echo -e "${BLUE}=== Deployed Services ===${NC}"
  docker service ls
  echo -e "${BLUE}=========================${NC}"
  
  echo
  echo -e "${GREEN}Your Homelab services are now available:${NC}"
  echo -e "- Homarr: ${BLUE}http://homarr.${TAILSCALE_HOSTNAME:-homelab}${NC}"
  echo -e "- Traefik Dashboard: ${BLUE}http://traefik.${TAILSCALE_HOSTNAME:-homelab}${NC}"
  echo
  echo "Since you're using Tailscale, you can access these from any device in your Tailnet"
  echo -e "For example, if this node's Tailscale hostname is 'node1', access via: ${BLUE}http://homarr.node1${NC}"
  echo
  echo "Make sure Tailscale is running on all nodes with MagicDNS enabled for hostname resolution"
}

# Function to show status of the homelab
show_status() {
  echo -e "${BLUE}=== Docker Swarm Node Status ===${NC}"
  docker node ls
  echo
  
  echo -e "${BLUE}=== Homelab Stack Services ===${NC}"
  docker stack services homelab 2>/dev/null || echo -e "${YELLOW}No homelab services found.${NC}"
  echo
  
  echo -e "${BLUE}=== Service Details ===${NC}"
  docker service ps homelab_traefik 2>/dev/null || echo -e "${YELLOW}Traefik service not found.${NC}"
  echo
  docker service ps homelab_homarr 2>/dev/null || echo -e "${YELLOW}Homarr service not found.${NC}"
  echo

  if docker stack ls | grep -q "homelab"; then
    get_tailscale_hostname
    echo -e "${GREEN}Available endpoints:${NC}"
    echo -e "- Homarr: ${BLUE}http://homarr.${TAILSCALE_HOSTNAME:-homelab}${NC}"
    echo -e "- Traefik Dashboard: ${BLUE}http://traefik.${TAILSCALE_HOSTNAME:-homelab}${NC}"
  else
    echo -e "${YELLOW}Homelab stack is not deployed. Use './homelab.sh deploy' to deploy it.${NC}"
  fi
}

# Function to remove the homelab
remove_homelab() {
  if ! docker stack ls | grep -q "homelab"; then
    echo -e "${YELLOW}Homelab stack is not currently deployed.${NC}"
    return
  fi
  
  read -p "Are you sure you want to remove the Homelab stack? This will stop all services. [y/N]: " confirm
  
  if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
  fi
  
  echo -e "${RED}Removing Homelab stack...${NC}"
  docker stack rm homelab
  
  echo "Waiting for services to be removed..."
  sleep 5
  
  echo -e "${BLUE}Current services:${NC}"
  docker service ls
  
  echo -e "${YELLOW}Would you like to remove the traefik-public network as well?${NC}"
  echo -e "${YELLOW}(Only do this if no other stacks use it) [y/N]:${NC} "
  read remove_network
  
  if [[ $remove_network == [yY] || $remove_network == [yY][eE][sS] ]]; then
    echo -e "${RED}Removing traefik-public network...${NC}"
    docker network rm traefik-public
  fi
  
  echo -e "${GREEN}Done. You can redeploy the stack with ./homelab.sh deploy${NC}"
}

# Main script execution
case "$1" in
  deploy)
    deploy_homelab
    ;;
  status)
    show_status
    ;;
  remove)
    remove_homelab
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    if [ -z "$1" ]; then
      show_help
    else
      echo -e "${RED}Unknown command: $1${NC}"
      echo
      show_help
    fi
    exit 1
    ;;
esac

exit 0
