FROM grafana/loki:2.9.2
ADD ../container_init/loki/loki-k8s-config.yaml /config.yaml
