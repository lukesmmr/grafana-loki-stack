#!/bin/bash
#
# install.sh - Initial setup script for Grafana Loki Stack on Ubuntu EC2
#
# This script will:
# 1. Update the system
# 2. Install Docker and Docker Compose
# 3. Set up necessary directories
# 4. Configure environment variables
# 5. Prepare the system to run the manage.sh script
#
# Usage:
#   chmod +x install.sh
#   ./install.sh

set -e

echo "=========================================================="
echo "  Grafana Loki Stack Installation Script"
echo "  For Ubuntu EC2 Instances"
echo "=========================================================="
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as root."
  exit 1
fi

# Function to display progress
progress() {
  echo ""
  echo ">>> $1"
  echo ""
}

# 1. Update the system
progress "Updating system packages..."
apt-get update
apt-get upgrade -y

# 2. Install dependencies
progress "Installing dependencies..."
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  jq \
  htop \
  vim \
  nano

# 3. Install Docker
progress "Installing Docker..."
if ! command -v docker &> /dev/null; then
  # Add Docker's official GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
  # Add Docker repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Install Docker Engine
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io
  
  # Start and enable Docker service
  systemctl start docker
  systemctl enable docker
  
  # Add current user to docker group
  if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    echo "Added user $SUDO_USER to the docker group. You may need to log out and back in for this to take effect."
  fi
  
  echo "Docker installed successfully!"
else
  echo "Docker is already installed."
fi

# 4. Install Docker Compose
progress "Installing Docker Compose..."
if ! command -v docker compose &> /dev/null; then
  # Install Docker Compose plugin
  apt-get update
  apt-get install -y docker-compose-plugin
  
  # Verify installation
  docker compose version
  
  echo "Docker Compose installed successfully!"
else
  echo "Docker Compose is already installed."
fi

# 5. Create necessary directories
progress "Setting up directories..."
mkdir -p /var/log/caddy

# 6. Configure environment variables
progress "Setting up environment variables..."
if [ ! -f .env ]; then
  if [ -f .env.template ]; then
    cp .env.template .env
    echo "Created .env file from template. Please edit it with your specific values."
    echo "You can use: nano .env"
  else
    echo "ERROR: .env.template file not found. Please create a .env file manually."
  fi
fi

# 7. Make manage.sh executable
progress "Making manage.sh executable..."
if [ -f manage.sh ]; then
  chmod +x manage.sh
  echo "manage.sh is now executable."
else
  echo "ERROR: manage.sh not found. Please ensure it exists in the current directory."
fi

# 8. Final instructions
progress "Installation completed!"
echo "To complete the setup:"
echo "1. Edit the .env file with your specific values: nano .env"
echo "2. Run the management script to start the stack: ./manage.sh start"
echo ""
echo "For more information, refer to the README.md file."
echo ""
echo "Note: If you're running this script with sudo, you may need to log out and log back in"
echo "for the docker group membership to take effect."

exit 0
