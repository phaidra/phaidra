FROM grafana/grafana:12.4.1
ADD --chown=grafana:root ../container_init/grafana/ds.yaml /etc/grafana/provisioning/datasources/ds.yaml
ADD --chown=grafana:root ../container_init/grafana/dd.yaml /etc/grafana/provisioning/dashboards/dd.yaml
ADD --chown=grafana:root ../container_init/grafana/dashboards/* /mnt/grafana/dashboards/