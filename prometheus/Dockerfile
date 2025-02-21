FROM prom/prometheus:latest

COPY prometheus.yml.template /etc/prometheus/prometheus.yml.template
COPY start-prometheus.sh /start-prometheus.sh

RUN chmod +x /start-prometheus.sh

ENTRYPOINT ["/start-prometheus.sh"]
