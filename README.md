# Loki Stack for Production on EC2

This repository sets up a **production-ready** log aggregation stack using **Grafana Loki** on an EC2 instance with Docker. It collects logs from:

- **Caddy** (located at `/var/log/caddy/access.log` and `/var/log/caddy/caddy.log`)
- **Docker containers** (via Docker Service Discovery)

You’ll be able to **view** and **query** these logs through **Grafana** in a web UI.

---

## 1. Repository Overview

### Services

1. **Loki** (`grafana/loki`)  
   Stores and indexes log data.  
2. **Promtail** (`grafana/promtail`)  
   Reads logs from the host (Caddy, Docker) and ships them to Loki.  
3. **Grafana** (`grafana/grafana`)  
   Provides a web UI for querying and visualizing logs.
4. **Prometheus** (`prom/prometheus`)  
   Collects and stores metrics data for monitoring and alerting.
5. **Caddy** (`caddy`)  
   Acts as a reverse proxy for Grafana, providing SSL and enhanced security.

---

## 2. Prerequisites

- **EC2 instance** (Linux-based) with **Docker** already installed.
- Proper **SSH** access to your EC2.
- Security groups allowing inbound traffic on:
  - **TCP 8443** (Grafana)  
- **Git** for pulling/pushing this repo to your instance.

---

## 3. Setup Instructions

### 3.1 Clone This Repo on Your Local Machine

```bash
git clone <YOUR_REPO_URL> loki-stack
cd loki-stack
```

Feel free to customize the `.yml` files to your needs (ports, volume mounts, etc.).
**Copy and rename the `.env.template` file to `.env` and fill it with the appropriate values for your environment:**
- `DOMAIN_ROOT=example.com` (the domain the service will be hosted on, using port 8443)
- `EMAIL=your-email@example.com` (used for TLS certificate registration)
- `BASIC_AUTH_PASSWORD=your-secure-password` (used for basic authentication)

### 3.2 Push to Your Remote Repository

If needed, initialize the repo, add a remote, and push:

```bash
git init
git add .
git commit -m "Add Loki stack configs"
git remote add origin <YOUR_REPO_URL>
git push -u origin main
```

### 3.3 On Your EC2 Staging/Production Box

1. **SSH** into the EC2 instance.
2. **Clone** or **pull** the repo:

```bash
git clone <YOUR_REPO_URL> loki-stack
cd loki-stack
```

3. **Spin up the stack**:

```bash
docker compose -f docker-compose.loki.yml up -d
```

This brings up **Loki**, **Promtail**, **Prometheus** and **Grafana** in the background.

---

## 4. File-by-File Explanation

### 4.1 `docker-compose.loki.yml`

- **Loki** listens on `3100`, storing data in `loki_data` volume.
- **Promtail** reads logs:
  - `/var/log/caddy` (mounted read-only)  
  - Docker containers at `/var/lib/docker/containers`
  - Docker socket `/var/run/docker.sock` for container discovery
- **Grafana** on port `3000` with local data at `grafana_data`.

### 4.2 `loki-config.yml`

- Stores log data in `/loki` on the container’s filesystem (mapped to `loki_data`).
- Uses an **in-memory ring** for discovery.

### 4.3 `promtail-config.yml`

- **Scrape Caddy logs** under `/var/log/caddy/*.log`.  
- **Scrape Docker logs** via Docker SD.  
- Sends everything to `http://loki:3100`.

---

## 5. Using Grafana

1. **Access** Grafana at `https://YOUR-DOMAIN:8443`.
2. **Login** with `admin` / `admin` (you’ll be prompted to reset your password).
3. Go to **Configuration → Data Sources → Add data source → Loki** and set URL to `http://loki:3100`.
4. Go to **Configuration → Data Sources → Add data source → Prometheus** and set URL to `http://prometheus:9090`.
5. Import the **Node Exporter Full** dashboard template by navigating to **Create → Import** and entering the dashboard ID or JSON file.

---

## 6. Integrating with Your Deploy Script

If you have a script like:

```bash
# ./deploy.sh staging|prod [logs]
# ...
```

You can either:

- **Keep the Loki stack** separate, starting it manually:
  ```bash
  docker compose -f docker-compose.loki.yml up -d
  ```
- **Integrate** it into your existing Compose setup if you want a unified `docker compose up -d`.

Just ensure that Promtail mounts the correct paths so it can read Caddy and Docker logs.

---

## 7. Production Considerations

1. **Secure Grafana**  
   - Restrict port `3000` in your EC2 Security Group.
   - Use strong admin credentials.
   - **Caddy** provides SSL and acts as a reverse proxy with TLS.

2. **Disk Space**  
   - Monitor `loki_data` usage.
   - Rotate or prune old logs if limited storage.

3. **Backups**  
   - If logs are critical, back up the `loki_data` directory or the entire EC2 volume.
   - Consider object storage (S3, etc.) for large or long-term retention.

4. **Scaling**  
   - For high volumes, look into Loki’s distributed mode or external storage.

---

## 8. Troubleshooting

- **Promtail Logs**  
  ```bash
  docker logs promtail
  ```
  Check for file permission or mounting issues.

- **Loki Logs**  
  ```bash
  docker logs loki
  ```
  Look for ingestion or filesystem errors.

- **Grafana Logs**
  If logs don’t appear:
  - Confirm Data Source is set to `http://loki:3100`.
  - Verify security group and firewall rules.
  - Check logs in `docker logs grafana`.


- **Caddy Logs**  
  ```bash
  docker logs grafana_reverse_proxy
  ```
  Look for ingestion or filesystem errors.

---

## 9. Managing the Logging Stack with the Manage Script

This repository includes a handy shell script—`manage.sh`—that simplifies the routine operations of your logging stack (Loki, Promtail, Grafana, and Caddy). With a single command, you can start, stop, restart, or check the status of the entire stack.

### 9.1 Overview

The `manage.sh` script provides the following commands:

- **start**: Launches all the services in the background using Docker Compose.
- **stop**: Shuts down and removes the containers.
- **restart**: Stops the stack, waits briefly for a graceful shutdown, then starts it up again.
- **status**: Displays the current status of all the containers in the stack.

### 9.2 Usage

1. **Make the Script Executable:**

   Before using the script, ensure it has executable permissions:

   ```bash
   chmod +x manage.sh

2. **Running the Script**

   * Start: `./manage_logging.sh start`
   * Stop: `./manage_logging.sh stop`
   * Restart: `./manage_logging.sh restart`
   * Status: `./manage_logging.sh status`

## 10. License & Acknowledgments

- **Grafana Loki** is [Apache 2.0 licensed](https://github.com/grafana/loki).
- **Promtail** and **Grafana** are also open source under permissive licenses.

Feel free to modify and use this stack in your own production or staging environments!

