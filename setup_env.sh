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

# Check if python3 is installed for potential future use
if ! command -v python3 &> /dev/null; then
  echo "Python 3 is required for some operations."
  read -p "Do you want to install Python 3 and pip? (y/n): " install_python
  if [[ "$install_python" == "y" || "$install_python" == "Y" ]]; then
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
  else
    echo "Python 3 is recommended. Continuing anyway."
  fi
fi

# Install bcrypt if not already installed - for Grafana password hashing
if ! python3 -c "import bcrypt" &> /dev/null; then
  echo "Installing bcrypt Python package..."
  pip3 install bcrypt
fi

# Function to generate bcrypt hash
generate_bcrypt_hash() {
  local password=$1
  local hash=$(python3 -c "import bcrypt; print(bcrypt.hashpw('$password'.encode('utf-8'), bcrypt.gensalt()).decode('utf-8'))")
  # Double the $ for Docker Compose environment variables
  echo "${hash//\$/\$\$}"
}

# Collect domain information
read -p "Enter your domain root (e.g., example.com): " domain_root
read -p "Enter your email address (for Let's Encrypt): " email

# Collect Node Exporter client information
read -p "Enter comma-separated list of Node Exporter clients (e.g., 10.0.0.1:9100,10.0.0.2:9100): " node_exporter_clients

# Collect Grafana authentication information
read -p "Enter username for Grafana authentication: " grafana_user
read -sp "Enter password for Grafana authentication: " grafana_password
echo ""
grafana_password_hash=$(generate_bcrypt_hash "$grafana_password")

# Create .env file
cat > .env << EOF
DOMAIN_ROOT=$domain_root
EMAIL=$email
NODE_EXPORTER_CLIENTS=$node_exporter_clients
EOF

echo ""
echo "Environment file (.env) has been created successfully!"
echo "You can now run the installation script: sudo ./install.sh"
echo ""
echo "Note: Make sure to set up Grafana authentication through the UI after installation."

exit 0
