FROM grafana/promtail:3.0.0
ADD ../container_init/promtail/promtail-local-config.yaml \
    /etc/promtail/config.yaml
