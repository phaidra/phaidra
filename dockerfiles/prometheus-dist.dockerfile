FROM prom/prometheus:v2.55.1
ADD ../container_init/prometheus/prometheus.yaml /etc/prometheus/prometheus.yml
