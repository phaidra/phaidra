FROM grafana/loki:3.6.4
ADD ../container_init/loki/loki-docker-config.yaml \
    /etc/loki/local-config.yaml:ro
