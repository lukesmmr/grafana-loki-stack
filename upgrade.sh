#!/bin/bash
#
# upgrade.sh - Script to upgrade Grafana Loki Stack to the latest versions
#
# This script will:
# 1. Backup the current configuration
# 2. Stop the current stack
# 3. Pull the latest images
# 4. Start the stack with the new images
#
# Usage:
#   chmod +x upgrade.sh
#   ./upgrade.sh

set -e

echo "=========================================================="
echo "  Grafana Loki Stack Upgrade Script"
echo "  Upgrading to latest versions of all components"
echo "=========================================================="
echo ""

# Function to display progress
progress() {
  echo ""
  echo ">>> $1"
  echo ""
}

# Check if docker-compose.loki.yml exists
if [ ! -f "docker-compose.loki.yml" ]; then
  echo "Error: docker-compose.loki.yml not found in the current directory."
  exit 1
fi

# 1. Backup the current configuration
progress "Creating backup of current configuration..."
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp docker-compose.loki.yml "$BACKUP_DIR/"
cp loki-config.yml "$BACKUP_DIR/" 2>/dev/null || true
cp promtail-config.yml "$BACKUP_DIR/" 2>/dev/null || true
cp Caddyfile "$BACKUP_DIR/" 2>/dev/null || true
cp .env "$BACKUP_DIR/" 2>/dev/null || true
echo "Backup created in $BACKUP_DIR"

# 2. Stop the current stack
progress "Stopping the current stack..."
if [ -f "manage.sh" ]; then
  ./manage.sh stop
else
  docker compose -f docker-compose.loki.yml down
fi

# 3. Pull the latest images
progress "Pulling the latest images..."
docker compose -f docker-compose.loki.yml pull

# 4. Start the stack with the new images
progress "Starting the stack with the new images..."
if [ -f "manage.sh" ]; then
  ./manage.sh start
else
  docker compose -f docker-compose.loki.yml up -d
fi

# 5. Final instructions
progress "Upgrade completed!"
echo "The Grafana Loki Stack has been upgraded to:"
echo "- Grafana: latest"
echo "- Loki: latest (with schema v13 and TSDB storage)"
echo "- Promtail: latest"
echo "- Node Exporter: latest"
echo "- Caddy: latest"
echo ""
echo "Please check the status of the stack:"
echo "  ./manage.sh status"
echo ""
echo "Access Grafana at: https://logs.YOUR-DOMAIN:8443"
echo ""
echo "Note: Loki has been configured with schema v13 and TSDB storage engine,"
echo "which provides better performance and enables structured metadata support."
echo ""
echo "If you encounter any issues, you can restore the backup from: $BACKUP_DIR"

exit 0 