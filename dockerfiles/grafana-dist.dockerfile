FROM grafana/grafana:11.6.9
ADD ../container_init/grafana/ds.yaml /etc/grafana/provisioning/datasources/ds.yaml
ADD ../container_init/grafana/dd.yaml /etc/grafana/provisioning/dashboards/dd.yaml
ADD ../container_init/grafana/dashboards /mnt/grafana/dashboards
