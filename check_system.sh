#!/bin/bash
#
# check_system.sh - Check system requirements and validate setup for Grafana Loki Stack
#
# This script checks if the system meets the requirements for running the Grafana Loki Stack
# and validates the current setup.
#
# Usage:
#   chmod +x check_system.sh
#   ./check_system.sh

set -e

echo "=========================================================="
echo "  System Requirements Check for Grafana Loki Stack"
echo "=========================================================="
echo ""

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to check if a port is in use
port_in_use() {
  netstat -tuln | grep -q ":$1 "
}

# Function to display status
status() {
  if [ $? -eq 0 ]; then
    echo -e "[\e[32m OK \e[0m] $1"
  else
    echo -e "[\e[31m FAIL \e[0m] $1"
    if [ -n "$2" ]; then
      echo "       $2"
    fi
  fi
}

# Check OS
echo "Checking operating system..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  echo "OS: $NAME $VERSION_ID"
  if [[ "$NAME" == *"Ubuntu"* ]]; then
    status "Operating system is Ubuntu"
  else
    status "Operating system is not Ubuntu" "This script is optimized for Ubuntu. Some commands may not work as expected."
  fi
else
  echo "OS: Unknown"
  status "Could not determine operating system" "This script is optimized for Ubuntu. Some commands may not work as expected."
fi

# Check system resources
echo -e "\nChecking system resources..."

# Check CPU
cpu_cores=$(nproc)
echo "CPU cores: $cpu_cores"
if [ "$cpu_cores" -ge 2 ]; then
  status "CPU cores sufficient (minimum 2 recommended)"
else
  status "CPU cores insufficient" "Minimum 2 CPU cores recommended for production use."
fi

# Check memory
mem_total=$(free -m | awk '/^Mem:/{print $2}')
echo "Memory: $mem_total MB"
if [ "$mem_total" -ge 4096 ]; then
  status "Memory sufficient (minimum 4GB recommended)"
else
  status "Memory insufficient" "Minimum 4GB RAM recommended for production use."
fi

# Check disk space
disk_free=$(df -h / | awk 'NR==2 {print $4}')
echo "Free disk space: $disk_free"
if df -h / | awk 'NR==2 {print $4}' | grep -q "G"; then
  free_gb=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
  if [ "${free_gb%.*}" -ge 10 ]; then
    status "Disk space sufficient (minimum 10GB free recommended)"
  else
    status "Disk space may be insufficient" "Minimum 10GB free disk space recommended for production use."
  fi
else
  status "Disk space insufficient" "Minimum 10GB free disk space recommended for production use."
fi

# Check required software
echo -e "\nChecking required software..."

# Check Docker
if command_exists docker; then
  docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
  echo "Docker version: $docker_version"
  status "Docker is installed"
else
  status "Docker is not installed" "Please run the install.sh script to install Docker."
fi

# Check Docker Compose
if command_exists docker && docker compose version &> /dev/null; then
  compose_version=$(docker compose version | awk '{print $4}')
  echo "Docker Compose version: $compose_version"
  status "Docker Compose is installed"
else
  status "Docker Compose is not installed" "Please run the install.sh script to install Docker Compose."
fi

# Check Python (for bcrypt)
if command_exists python3; then
  python_version=$(python3 --version | awk '{print $2}')
  echo "Python version: $python_version"
  status "Python 3 is installed"
  
  # Check bcrypt
  if python3 -c "import bcrypt" &> /dev/null; then
    status "Python bcrypt module is installed"
  else
    status "Python bcrypt module is not installed" "Required for password hashing. Run setup_env.sh to install."
  fi
else
  status "Python 3 is not installed" "Required for password hashing. Run setup_env.sh to install."
fi

# Check configuration files
echo -e "\nChecking configuration files..."

# Check .env file
if [ -f .env ]; then
  status ".env file exists"
  
  # Check required variables
  missing_vars=()
  
  # Domain and email
  grep -q "DOMAIN_ROOT=" .env || missing_vars+=("DOMAIN_ROOT")
  grep -q "EMAIL=" .env || missing_vars+=("EMAIL")
  
  # Node Exporter configuration
  grep -q "NODE_EXPORTER_CLIENTS=" .env || missing_vars+=("NODE_EXPORTER_CLIENTS")
  
  if [ ${#missing_vars[@]} -eq 0 ]; then
    status ".env file contains all required variables"
  else
    status ".env file is missing required variables: ${missing_vars[*]}" "Run setup_env.sh to create a complete .env file."
  fi
else
  status ".env file does not exist" "Run setup_env.sh to create the .env file."
fi

# Check Docker Compose file
if [ -f docker-compose.loki.yml ]; then
  status "docker-compose.loki.yml file exists"
else
  status "docker-compose.loki.yml file does not exist" "This file is required to run the stack."
fi

# Check Loki config
if [ -f loki-config.yml ]; then
  status "loki-config.yml file exists"
else
  status "loki-config.yml file does not exist" "This file is required for Loki configuration."
fi

# Check Promtail config
if [ -f promtail-config.yml ]; then
  status "promtail-config.yml file exists"
else
  status "promtail-config.yml file does not exist" "This file is required for Promtail configuration."
fi

# Check Caddy config
if [ -f Caddyfile ]; then
  status "Caddyfile exists"
else
  status "Caddyfile does not exist" "This file is required for Caddy configuration."
fi

# Check if required ports are available
echo -e "\nChecking port availability..."

# Check port 3100 (Loki)
if ! port_in_use 3100; then
  status "Port 3100 (Loki) is available"
else
  status "Port 3100 (Loki) is already in use" "This port is required for Loki. Stop any service using this port."
fi

# Check port 8443 (Grafana via Caddy)
if ! port_in_use 8443; then
  status "Port 8443 (Grafana via Caddy) is available"
else
  status "Port 8443 (Grafana via Caddy) is already in use" "This port is required for Grafana access. Stop any service using this port."
fi

# Check port 9090 (Prometheus)
if ! port_in_use 9090; then
  status "Port 9090 (Prometheus) is available"
else
  status "Port 9090 (Prometheus) is already in use" "This port is required for Prometheus. Stop any service using this port."
fi

echo -e "\nSystem check completed."
echo "For detailed installation instructions, see the INSTALL.md file."
echo "To set up the environment, run: ./setup_env.sh"
echo "To install dependencies, run: sudo ./install.sh"
echo "To start the stack, run: ./manage.sh start"

exit 0 