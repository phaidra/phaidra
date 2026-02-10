FROM grafana/promtail:3.6.5
ADD ../container_init/promtail/promtail-local-config.yaml \
    /etc/promtail/config.yaml
