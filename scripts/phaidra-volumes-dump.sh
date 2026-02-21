#!/bin/bash

# This is just an util script to create a dump of all PHAIDRA volumes (eg for cloning instance for dev purposes)
# docker compose --profile demo-local down --volumes

set -euo pipefail

DUMP_DIR="/tmp/phaidra_dump/docker_volumes"
TIMESTAMP=$(date +%Y%m%d-%H%M)
mkdir -p "$DUMP_DIR"

for vol in $(docker volume ls -q --filter name='^phaidra_'); do
    echo "Backing up $vol..."
    docker run --rm \
        -v "$vol":/data \
        -v "$DUMP_DIR":/dump \
	alpine tar czf "/dump/${vol}_$(date +%Y%m%d-%H%M).tar.gz" -C /data .
done

echo "Backups saved in $DUMP_DIR"
