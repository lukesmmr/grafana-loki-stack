# Installation Guide for Grafana Loki Stack on EC2

This guide provides step-by-step instructions for setting up the Grafana Loki Stack on a new Ubuntu EC2 instance.

## Quick Start

For a quick setup on a fresh Ubuntu EC2 instance, follow these steps:

1. SSH into your EC2 instance:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   ```

2. Clone this repository:
   ```bash
   git clone <YOUR_REPO_URL> grafana-loki
   cd grafana-loki
   ```

3. Run the complete setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   This script will run all the installation steps in sequence:
   - Check system requirements
   - Set up environment variables
   - Install dependencies
   - Start the stack

## Manual Installation

If you prefer to run each step manually, follow these instructions:

1. Make the installation scripts executable:
   ```bash
   chmod +x check_system.sh setup_env.sh install.sh manage.sh
   ```

2. Check if your system meets the requirements:
   ```bash
   ./check_system.sh
   ```
   This script will verify that your system has the necessary resources and software.

3. Set up your environment variables:
   ```bash
   ./setup_env.sh
   ```
   This interactive script will help you create the `.env` file with proper bcrypt hashed passwords.

4. Run the installation script with sudo:
   ```bash
   sudo ./install.sh
   ```

5. Start the Grafana Loki stack:
   ```bash
   ./manage.sh start
   ```

## Complete Setup Script

The `setup.sh` script automates the entire installation process by running all the individual scripts in sequence:

1. **Checks system requirements** using `check_system.sh`
   - Verifies operating system, system resources, required software, configuration files, and port availability

2. **Sets up environment variables** using `setup_env.sh`
   - Guides you through creating the `.env` file with proper bcrypt hashed passwords

3. **Installs dependencies** using `install.sh`
   - Updates the system, installs Docker and Docker Compose, and sets up necessary directories

4. **Starts the stack** using `manage.sh start`
   - Launches all the services in the background using Docker Compose

This is the easiest way to set up the entire stack with a single command.

## System Requirements Check

The `check_system.sh` script helps you verify that your system meets the requirements for running the Grafana Loki Stack. It checks:

1. **Operating System**
   - Verifies if you're running Ubuntu (recommended)

2. **System Resources**
   - CPU: Minimum 2 cores recommended
   - Memory: Minimum 4GB RAM recommended
   - Disk Space: Minimum 10GB free space recommended

3. **Required Software**
   - Docker and Docker Compose
   - Python 3 (for bcrypt password hashing)

4. **Configuration Files**
   - Checks if all required configuration files exist
   - Verifies that the `.env` file contains all necessary variables

5. **Port Availability**
   - Checks if required ports (3100, 8443, 9090) are available

Running this script before installation helps identify potential issues that might prevent the stack from running properly.

## Environment Setup Helper

The `setup_env.sh` script helps you create a properly configured `.env` file with correctly formatted bcrypt hashed passwords. It:

1. Checks for Python 3 and installs it if needed (with your permission)
2. Installs the bcrypt Python package if needed
3. Guides you through setting up:
   - Domain information (domain root and email for Let's Encrypt)
   - Node Exporter client IPs
   - Loki authentication credentials (with bcrypt password hashing)
   - Grafana authentication credentials (with bcrypt password hashing)
4. Creates the `.env` file with proper formatting for Docker Compose

This script is particularly helpful for handling the bcrypt password hashing required by the stack, ensuring that the `$` symbols are properly doubled for Docker Compose environment variables.

## What the Installation Script Does

The `install.sh` script automates the following tasks:

1. **Updates the system packages**
   - Runs `apt-get update` and `apt-get upgrade`

2. **Installs essential dependencies**
   - apt-transport-https, ca-certificates, curl, gnupg, lsb-release
   - git, jq, htop, vim, nano

3. **Installs Docker**
   - Adds Docker's official GPG key
   - Configures the Docker repository
   - Installs Docker Engine
   - Starts and enables the Docker service
   - Adds the current user to the docker group

4. **Installs Docker Compose**
   - Installs the Docker Compose plugin
   - Verifies the installation

5. **Sets up necessary directories**
   - Creates `/var/log/caddy` for Caddy logs

6. **Configures environment variables**
   - Uses the `.env` file created by `setup_env.sh` or copies from `.env.template`

7. **Makes the management script executable**
   - Sets execute permissions on `manage.sh`

## Manual Environment Setup (Alternative)

If you prefer to set up the environment variables manually:

1. Copy the template file:
   ```bash
   cp .env.template .env
   ```

2. Edit the file:
   ```bash
   nano .env
   ```

3. For bcrypt password hashing, you can use Python:
   ```bash
   python3 -c "import bcrypt; print(bcrypt.hashpw('your-password'.encode('utf-8'), bcrypt.gensalt()).decode('utf-8'))"
   ```
   
   Remember to double the `$` symbols in the hash for Docker Compose (e.g., `$$2y$$05$$...` instead of `$2y$05$...`).

## Security Considerations

Before running the stack in production, consider the following security measures:

1. **Network Security**
   - Configure EC2 security groups to restrict access to only necessary ports
   - Ensure port 3100 (Loki) is only accessible from your VPC private network

2. **Authentication**
   - Set strong passwords in the `.env` file for both Grafana and Loki
   - Regularly rotate credentials

3. **TLS Encryption**
   - The stack uses Caddy to automatically obtain and manage TLS certificates
   - Ensure your domain DNS is properly configured to point to your EC2 instance

## Troubleshooting

If you encounter issues during installation:

1. **Check the installation logs**
   - The script outputs detailed information about each step

2. **Docker group membership**
   - If you can't run Docker commands without sudo after installation, log out and log back in

3. **Docker Compose issues**
   - Verify Docker Compose is installed: `docker compose version`

4. **Environment variables**
   - Ensure all required variables in the `.env` file are properly set
   - Check that bcrypt hashed passwords have doubled `$` symbols

5. **Firewall or security group issues**
   - Check that necessary ports are open in your EC2 security groups

## Next Steps

After successful installation:

1. Access Grafana at `https://logs.YOUR-DOMAIN:8443`
2. Log in with the credentials set in your `.env` file
3. Configure data sources for Loki and Prometheus
4. Import dashboards or create your own

For more detailed information about using the stack, refer to the main `README.md` file.

## Maintenance

To manage your Grafana Loki stack:

- **Start the stack**: `./manage.sh start`
- **Stop the stack**: `./manage.sh stop`
- **Restart the stack**: `./manage.sh restart`
- **Check status**: `./manage.sh status`

## Updating

To update the stack to the latest versions:

1. Pull the latest changes from the repository
2. Edit the Docker Compose file if needed to update image versions
3. Restart the stack: `./manage.sh restart` 