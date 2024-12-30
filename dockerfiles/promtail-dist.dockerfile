FROM grafana/promtail:3.3.2
ADD ../container_init/promtail/promtail-local-config.yaml \
    /etc/promtail/config.yaml
