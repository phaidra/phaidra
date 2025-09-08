#!/bin/sh

# Create a writable copy of the Prometheus configuration file
cp /etc/prometheus/prometheus.yml /tmp/prometheus.yml

# Replace placeholders in the Prometheus configuration file
sed -i "s|\${FEDORA_ADMIN_USER}|${FEDORA_ADMIN_USER}|g" /tmp/prometheus.yml
sed -i "s|\${FEDORA_ADMIN_PASS}|${FEDORA_ADMIN_PASS}|g" /tmp/prometheus.yml

# Start Prometheus
exec /bin/prometheus --config.file=/tmp/prometheus.yml "$@"