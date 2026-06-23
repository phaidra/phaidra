FROM grafana/grafana:12.4.1
ADD ../container_init/grafana/ds.yaml /etc/grafana/provisioning/datasources/ds.yaml
ADD ../container_init/grafana/dd.yaml /etc/grafana/provisioning/dashboards/dd.yaml
ADD ../container_init/grafana/dashboards /mnt/grafana/dashboards
RUN mkdir -p /etc/grafana/provisioning/dashboards/apache
COPY container_init/grafana/dashboards/apache/apache.json /etc/grafana/provisioning/dashboards/apache/
RUN chown -R grafana:grafana /etc/grafana/provisioning/dashboards/apache

RUN mkdir -p /etc/grafana/provisioning/dashboards/fedora
COPY container_init/grafana/dashboards/fedora/fedora.json /etc/grafana/provisioning/dashboards/fedora/
RUN chown -R grafana:grafana /etc/grafana/provisioning/dashboards/fedora
