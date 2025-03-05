FROM prom/prometheus:latest

COPY --chmod=755 start-prometheus.sh /start-prometheus.sh
COPY prometheus.yml.template /etc/prometheus/prometheus.yml.template

ENTRYPOINT ["/start-prometheus.sh"]
