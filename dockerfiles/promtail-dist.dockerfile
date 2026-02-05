FROM grafana/promtail:3.6.4
ADD ../container_init/promtail/promtail-local-config.yaml \
    /etc/promtail/config.yaml
