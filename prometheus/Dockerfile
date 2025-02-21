FROM prom/prometheus:latest
RUN apt-get update && apt-get install -y gettext

COPY prometheus.yml.template /etc/prometheus/prometheus.yml.template

ENTRYPOINT [ "/bin/sh", "-c", "envsubst < /etc/prometheus/prometheus.yml.template > /etc/prometheus/prometheus.yml && exec prometheus --config.file=/etc/prometheus/prometheus.yml" ]
