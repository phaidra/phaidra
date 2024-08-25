FROM grafana/loki:3.0.0
ADD ../container_init/loki/loki-docker-config.yaml \
    /etc/loki/local-config.yaml:ro
