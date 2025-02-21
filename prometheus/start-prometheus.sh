#!/bin/sh

set -e

# Substitute the environment variable in the template file
sed "s/\${NODE_EXPORTER_CLIENT}/${NODE_EXPORTER_CLIENT}/g" /etc/prometheus/prometheus.yml.template > /etc/prometheus/prometheus.yml

# Start Prometheus with the generated configuration file
exec prometheus --config.file=/etc/prometheus/prometheus.yml
