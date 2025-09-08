#!/bin/sh

# Replace placeholders in the Prometheus configuration file
sed -i "s|\${FEDORA_ADMIN_USER}|${FEDORA_ADMIN_USER}|g" /etc/prometheus/prometheus.yml
sed -i "s|\${FEDORA_ADMIN_PASS}|${FEDORA_ADMIN_PASS}|g" /etc/prometheus/prometheus.yml

# Start Prometheus
exec /bin/prometheus "$@"