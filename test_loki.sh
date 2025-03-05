#!/bin/bash
#
# test_loki.sh - Test Loki configuration and help with debugging
#
# Usage:
#   chmod +x test_loki.sh
#   ./test_loki.sh

set -e

echo "=========================================================="
echo "  Loki Configuration Test Script"
echo "=========================================================="
echo ""

# Function to display progress
progress() {
  echo ""
  echo ">>> $1"
  echo ""
}

# Check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "Error: docker is required but not installed."
  exit 1
fi

# Check if loki-config.yml exists
if [ ! -f "loki-config.yml" ]; then
  echo "Error: loki-config.yml not found in the current directory."
  exit 1
fi

# Test Loki configuration
progress "Testing Loki configuration..."
docker run --rm -v $(pwd)/loki-config.yml:/etc/loki/config/loki-config.yml:ro grafana/loki:latest -config.file=/etc/loki/config/loki-config.yml -target=all -print-config-stderr 2>&1 | grep -v level=info

# Check exit code
if [ $? -eq 0 ]; then
  progress "Loki configuration test passed!"
else
  progress "Loki configuration test failed. Please check the errors above."
  exit 1
fi

# Restart the stack
progress "Would you like to restart the stack with the new configuration? (y/n)"
read -p "> " restart
if [[ "$restart" == "y" || "$restart" == "Y" ]]; then
  progress "Restarting the stack..."
  docker compose -f docker-compose.loki.yml down
  docker compose -f docker-compose.loki.yml up -d
  
  # Wait for services to start
  sleep 5
  
  # Check Loki logs
  progress "Checking Loki logs..."
  docker compose -f docker-compose.loki.yml logs loki | tail -n 20
fi

progress "Done!"
exit 0 