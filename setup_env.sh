#!/bin/bash
#
# setup_env.sh - Helper script to set up environment variables for Grafana Loki Stack
#
# This script helps set up the .env file for the Grafana Loki Stack
#
# Usage:
#   chmod +x setup_env.sh
#   ./setup_env.sh

set -e

echo "=========================================================="
echo "  Environment Setup Helper for Grafana Loki Stack"
echo "=========================================================="
echo ""

# Check if .env file exists
if [ -f .env ]; then
  read -p ".env file already exists. Do you want to overwrite it? (y/n): " overwrite
  if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
    echo "Exiting without changes."
    exit 0
  fi
fi

# Check if docker is installed for Caddy password hashing
if ! command -v docker &> /dev/null; then
  echo "Docker is required for Caddy password hashing."
  echo "Please install Docker first."
  exit 1
fi

# Function to generate Caddy password hash
generate_caddy_hash() {
  local password=$1
  local hash=$(docker run --rm caddy:latest caddy hash-password --plaintext "$password")
  echo "$hash"
}

# Collect domain information
read -p "Enter your domain root (e.g., example.com): " domain_root
read -p "Enter your email address (for Let's Encrypt): " email

# Collect Node Exporter client information
read -p "Enter comma-separated list of Node Exporter clients (e.g., 10.0.0.1:9100,10.0.0.2:9100): " node_exporter_clients

# Collect Basic Auth information
read -p "Enter username for Basic Authentication [admin]: " basic_auth_username
basic_auth_username=${basic_auth_username:-admin}

read -sp "Enter password for Basic Authentication: " basic_auth_password
echo ""
echo "Generating password hash for Basic Authentication..."
basic_auth_password_hash=$(generate_caddy_hash "$basic_auth_password")

# Create .env file
cat > .env << EOF
DOMAIN_ROOT=$domain_root
EMAIL=$email
NODE_EXPORTER_CLIENTS=$node_exporter_clients

# Basic Authentication for Grafana
BASIC_AUTH_USERNAME=$basic_auth_username
BASIC_AUTH_PASSWORD_HASH=$basic_auth_password_hash
EOF

echo ""
echo "Environment file (.env) has been created successfully!"
echo "You can now run the installation script: sudo ./install.sh"
echo ""
echo "Note: You will need to authenticate with both:"
echo "1. Basic Authentication (username: $basic_auth_username)"
echo "2. Grafana's own authentication (default: admin/admin)"

exit 0
