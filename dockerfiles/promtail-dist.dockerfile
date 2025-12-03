FROM grafana/promtail:3.6.2
ADD ../container_init/promtail/promtail-local-config.yaml \
    /etc/promtail/config.yaml
