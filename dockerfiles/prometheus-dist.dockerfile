FROM prom/prometheus:v2.52.0
ADD ../container_init/prometheus/prometheus.yaml /etc/prometheus/prometheus.yml
ADD ../container_init/prometheus/prometheus-entrypoint.bash /prometheus-entrypoint.bash
ENTRYPOINT ["bash", "/prometheus-entrypoint.bash"]
