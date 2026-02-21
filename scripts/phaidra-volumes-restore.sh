#!/bin/bash

# This is just an util script to restore a dump of all PHAIDRA volumes (eg for cloning instance for dev purposes)
# docker compose --profile demo-local down --volumes

set -euo pipefail
shopt -s nullglob  # Expand to null if nothing is found

DUMP_DIR="/tmp/phaidra_dump/docker_volumes"

echo "Starting restore of all dumps from $DUMP_DIR..."
echo

# Loop over all matching tar.gz files
for DUMP_FILE in "$DUMP_DIR"/phaidra_*.tar.gz; do
    VOL=$(basename "$DUMP_FILE" | sed -E 's/_[0-9]{8}-[0-9]{4}\.tar\.gz$//')

    echo "Restoring volume: $VOL"
    echo "From file:        $(basename "$DUMP_FILE")"

    # Create the volume if it doesn't exist
    docker volume inspect "$VOL" >/dev/null 2>&1 || docker volume create "$VOL"

    # Extract dump contents into the volume
    docker run --rm \
        -v "$VOL":/data \
        -v "$DUMP_DIR":/dump \
        alpine sh -c "cd /data && tar xzf /dump/$(basename "$DUMP_FILE")"

    echo "Restored $VOL"
    echo
done
shopt -u nullglob

echo "All phaidra_* dumps restored."
