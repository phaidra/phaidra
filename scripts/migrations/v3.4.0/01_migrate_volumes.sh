#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PROJECT=phaidra ./migrate_volumes.sh
#
# This script:
#   - Creates new volumes with the renamed scheme
#   - Copies data from old volumes to new volumes
#   - Does NOT remove old volumes

PROJECT="${PROJECT:-phaidra}"

# Mapping: old_name -> new_name (without project prefix).
declare -A MAP=(
  [mariadb_fedora]="mariadb-fedora"
  [mariadb_phaidra]="mariadb-phaidra"
  [mongodb_phaidra]="mongodb-phaidra"
  [pixelgecko]="derivates-images"
  [converted_3d]="derivates-3d"
  [converted_360]="derivates-expanded"
  [pdf-extraction]="derivates-extracts"
  [vige-mongosh]="agent-opencast-mongosh"
  [vige]="agent-opencast-work"
)

vol_exists() {
  docker volume inspect "$1" >/dev/null 2>&1
}

ensure_volume() {
  local v="$1"
  if ! vol_exists "$v"; then
    echo "Creating volume: $v"
    docker volume create "$v" >/dev/null
  fi
}

containers_using_volume() {
  docker ps --filter "volume=$1" --format '{{.ID}}' || true
}

copy_volume() {
  local src="$1"
  local dst="$2"

  echo "Copying data: $src -> $dst"
  docker run --rm -v "$src:/from:ro" -v "$dst:/to" alpine:3.19 sh -c 'apk add --no-cache rsync && rsync -a /from/ /to/'

  echo "Sizes after copy:"
  docker run --rm -v "${src}:/from:ro" alpine:3.19 sh -c 'du -sh /from 2>/dev/null || true'
  docker run --rm -v "${dst}:/to"     alpine:3.19 sh -c 'du -sh /to   2>/dev/null || true'
}

is_volume_empty() {
  local v="$1"
  docker run --rm -v "${v}:/mount" alpine:3.19 sh -c 'test -z "$(ls -A /mount 2>/dev/null)"'
}

for old in "${!MAP[@]}"; do
  new="${MAP[$old]}"
  src="${PROJECT}_${old}"
  dst="${PROJECT}_${new}"

  echo "------------------------------------------------------------"
  echo "Migrating volume:"
  echo "  Old: ${src}"
  echo "  New: ${dst}"

  if ! vol_exists "$src"; then
    echo "WARNING: Source volume does not exist: $src — skipping."
    continue
  fi

  used_by=$(containers_using_volume "$src")
  if [[ -n "$used_by" ]]; then
    echo "ERROR: Running containers are using volume $src:"
    echo "$used_by"
    echo "Please stop them (docker compose down) and re-run."
    exit 1
  fi

  ensure_volume "$dst"

  if ! is_volume_empty "$dst"; then
    echo "WARNING: Destination volume $dst is not empty — skipping copy to avoid overwriting."
    continue
  fi

  copy_volume "$src" "$dst"
  echo "Migration completed for: $src -> $dst"
done

echo "------------------------------------------------------------"
echo "All requested migrations processed."