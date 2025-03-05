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

Creates a properly configured `.env` file:
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

## Stack Components

1. **Loki** - Stores and indexes log data (port 3100)
2. **Promtail** - Reads logs from the host and ships to Loki
3. **Grafana** - Web UI for querying logs
4. **Prometheus** - Collects metrics from multiple client instances
5. **Caddy** - Reverse proxy for Grafana with SSL and enhanced security

## SSL Certificate Setup

The stack uses Caddy for automatic SSL certificate management. For initial certificate acquisition:

1. **Initial Certificate Setup**
   ```bash
   # Stop the Caddy container
   docker stop loki-stack-grafana_reverse_proxy-1
   
   # Run temporary Caddy instance for certificate acquisition
   docker compose -f docker-compose.loki.yml run --rm -p 80:80 grafana_reverse_proxy caddy run --config /etc/caddy/Caddyfile
   ```
   - Wait until you see "certificate obtained successfully" in the logs
   - Press Ctrl+C to stop the temporary container
   - Restart the stack with `docker compose -f docker-compose.loki.yml up -d`

2. **Why This Approach?**
   - Avoids permanently exposing port 80
   - Only temporarily opens port 80 for initial certificate acquisition
   - Subsequent renewals happen over port 443

3. **Certificate Renewal**
   - Automatic renewal happens over port 443
   - No manual intervention needed
   - Caddy handles all renewal processes

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
   ```

## Security Considerations

1. **Network Security**
   - Restrict port 3100 (Loki) to your VPC private network only
   - Configure security groups appropriately
   - Port 80 should only be temporarily opened for initial SSL setup

2. **Authentication**
   - Use strong passwords for Grafana
   - Consider implementing additional security measures like network-level restrictions

3. **TLS Encryption**
   - Grafana UI uses HTTPS with Let's Encrypt/ZeroSSL
   - Consider VPN for agent-to-Loki communication

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Check if port 80 is accessible during initial setup
   - Verify domain DNS points to your server
   - Check Caddy logs: `docker logs loki-stack-grafana_reverse_proxy-1`

2. **Component Issues**
   - Promtail issues: `docker logs loki-stack-grafana_promtail-1`
   - Loki issues: `docker logs loki-stack-loki-1`
   - Grafana issues: `docker logs loki-stack-grafana-1`

3. **Stack Management**
   - Full stack restart: `docker compose -f docker-compose.loki.yml restart`
   - Check stack status: `docker compose -f docker-compose.loki.yml ps`
   - View all logs: `docker compose -f docker-compose.loki.yml logs -f`

For detailed installation instructions, see [INSTALL.md](INSTALL.md).
