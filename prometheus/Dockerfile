FROM prom/prometheus:latest

# Copy our custom envsubst script with executable permissions (0755) directly.
COPY --chmod=0755 envsubst /usr/local/bin/envsubst
COPY prometheus.yml.template /etc/prometheus/prometheus.yml.template

# Use envsubst to perform substitution on container start.
ENTRYPOINT [ "/bin/sh", "-c", "envsubst < /etc/prometheus/prometheus.yml.template > /etc/prometheus/prometheus.yml && exec prometheus --config.file=/etc/prometheus/prometheus.yml" ]
