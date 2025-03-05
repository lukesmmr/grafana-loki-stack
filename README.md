# Grafana Loki Stack for Production on EC2

A production-ready log aggregation stack using Grafana Loki on EC2 with Docker. Collects logs from:
- Caddy logs
- Docker containers (via Docker Service Discovery)
- Multiple agent instances (via Loki push API)

## Quick Start

For a complete setup on a fresh Ubuntu EC2 instance:

1. SSH into your EC2 instance
2. Clone this repository:
   ```bash
   git clone <YOUR_REPO_URL> grafana-loki
   cd grafana-loki
   ```
3. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

## Installation Scripts

This repository includes several scripts to simplify setup:

### `setup.sh` - Complete Setup Script

Runs all installation steps in sequence:
```bash
chmod +x setup.sh
./setup.sh
```

### `check_system.sh` - System Requirements Check

Verifies your system meets the requirements:
```bash
chmod +x check_system.sh
./check_system.sh
```

### `setup_env.sh` - Environment Setup Helper

Creates a properly configured `.env` file with bcrypt hashed passwords:
```bash
chmod +x setup_env.sh
./setup_env.sh
```

### `install.sh` - Installation Script

Installs dependencies and prepares the system:
```bash
chmod +x install.sh
sudo ./install.sh
```

### `manage.sh` - Management Script

Manages the Grafana Loki stack:
```bash
./manage.sh {start|stop|restart|status}
```

## Environment Configuration

Copy `.env.template` to `.env` and configure:
- `DOMAIN_ROOT=example.com` (domain for accessing Grafana)
- `EMAIL=your-email@example.com` (for Let's Encrypt)
- `NODE_EXPORTER_CLIENTS=10.0.0.1:9100,10.0.0.2:9100` (comma-separated list of client IPs)
- `LOKI_BASIC_AUTH_USER` and `LOKI_BASIC_AUTH_PW` (for agent authentication)

## Stack Components

1. **Loki** - Stores and indexes log data (port 3100)
2. **Promtail** - Reads logs from the host and ships to Loki
3. **Grafana** - Web UI for querying logs
4. **Prometheus** - Collects metrics from multiple client instances
5. **Caddy** - Reverse proxy for Grafana with SSL and enhanced security

## Using Grafana

1. Access Grafana at `https://logs.YOUR-DOMAIN:8443`
2. Use `admin/admin` for initial Grafana login (you'll be prompted to reset)
3. Configure data sources:
   - Loki: `http://loki:3100`
   - Prometheus: `http://prometheus:9090`

## Agent Setup

To configure agent instances to push logs:

1. Install Promtail on each agent
2. Configure to push logs to central Loki:
   ```yaml
   clients:
     - url: http://CENTRAL_LOKI_PRIVATE_IP:3100/loki/api/v1/push
       basic_auth:
         username: your-loki-username
         password: your-loki-password
   ```

## Security Considerations

1. **Network Security**
   - Restrict port 3100 (Loki) to your VPC private network only
   - Configure security groups appropriately

2. **Authentication**
   - Use strong passwords for Loki authentication
   - Rotate credentials regularly

3. **TLS Encryption**
   - Grafana UI uses HTTPS with Let's Encrypt
   - Consider VPN for agent-to-Loki communication

## Troubleshooting

- **Promtail issues**: `docker logs promtail`
- **Loki issues**: `docker logs loki`
- **Grafana issues**: `docker logs grafana`
- **Caddy issues**: `docker logs grafana_reverse_proxy`

For detailed installation instructions, see [INSTALL.md](INSTALL.md).
