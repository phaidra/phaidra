FROM prom/prometheus:v2.52.0
ADD ../container_init/prometheus/prometheus.yaml /etc/prometheus/prometheus.yml
