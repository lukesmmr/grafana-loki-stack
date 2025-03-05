#!/bin/bash
#
# setup.sh - Complete setup script for Grafana Loki Stack on Ubuntu EC2
#
# This script runs all the installation steps in sequence:
# 1. Checks system requirements
# 2. Sets up environment variables
# 3. Installs dependencies
# 4. Starts the stack
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh

set -e

echo "=========================================================="
echo "  Complete Setup for Grafana Loki Stack"
echo "  For Ubuntu EC2 Instances"
echo "=========================================================="
echo ""

# Make all scripts executable
chmod +x check_system.sh setup_env.sh install.sh manage.sh

# Step 1: Check system requirements
echo "Step 1: Checking system requirements..."
./check_system.sh

# Ask user if they want to continue
read -p "Do you want to continue with the setup? (y/n): " continue_setup
if [[ "$continue_setup" != "y" && "$continue_setup" != "Y" ]]; then
  echo "Setup aborted."
  exit 0
fi

# Step 2: Set up environment variables
echo ""
echo "Step 2: Setting up environment variables..."
./setup_env.sh

# Step 3: Install dependencies
echo ""
echo "Step 3: Installing dependencies..."
echo "This step requires sudo privileges."
sudo ./install.sh

# Step 4: Start the stack
echo ""
echo "Step 4: Starting the Grafana Loki stack..."
./manage.sh start

echo ""
echo "Setup completed successfully!"
echo "You can now access Grafana at https://logs.YOUR-DOMAIN:8443"
echo "For more information, refer to the README.md and INSTALL.md files."

exit 0
