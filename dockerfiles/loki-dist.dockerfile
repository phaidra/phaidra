FROM grafana/loki:3.3.2
ADD ../container_init/loki/loki-docker-config.yaml \
    /etc/loki/local-config.yaml:ro
