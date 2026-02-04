#!/usr/bin/env bash
set -euo pipefail

VOLUME_NAME="phaidra_solr"

# Resolve repo root based on this script’s location:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

SRC_PHAIDRA_DIR="${REPO_ROOT}/container_init/solr/phaidra_core/conf"
SRC_PAGES_DIR="${REPO_ROOT}/container_init/solr/phaidra_pages_core/conf"

# Sanity checks
[[ -f "${SRC_PHAIDRA_DIR}/solrconfig.xml" ]] || { echo "Missing ${SRC_PHAIDRA_DIR}/solrconfig.xml" >&2; exit 1; }
[[ -f "${SRC_PAGES_DIR}/solrconfig.xml"   ]] || { echo "Missing ${SRC_PAGES_DIR}/solrconfig.xml" >&2; exit 1; }

# Run a helper container to perform the copy inside Docker space (avoids host perms)
docker run --rm \
  -v "${VOLUME_NAME}:/vol" \
  -v "${SRC_PHAIDRA_DIR}:/src/phaidra:ro" \
  -v "${SRC_PAGES_DIR}:/src/phaidra_pages:ro" \
  debian:bookworm-slim \
  bash -euo pipefail -c '
set -euo pipefail

copy_one() {
  local core="$1"
  local src="/src/${core}/solrconfig.xml"
  local dest_dir="/vol/data/${core}/conf"
  local dest="${dest_dir}/solrconfig.xml"

  mkdir -p "$dest_dir"

  # Determine target ownership and permissions
  local uid gid mode
  if [ -e "$dest" ]; then
    uid="$(stat -c "%u" "$dest")"
    gid="$(stat -c "%g" "$dest")"
    mode="$(stat -c "%a" "$dest")"
  else
    uid="$(stat -c "%u" "$dest_dir")"
    gid="$(stat -c "%g" "$dest_dir")"
    mode="0644"
  fi

  # Idempotency: copy only if content differs
  if [ -f "$dest" ]; then
    if [ "$(sha256sum "$src" | awk "{print \$1}")" = "$(sha256sum "$dest" | awk "{print \$1}")" ]; then
      echo "Up-to-date: $dest"
      return 0
    fi
    cp -a -- "$dest" "$dest.bak.$(date +%Y%m%d-%H%M%S)"
    echo "Backup created: $dest.bak.*"
  fi

  cp -f -- "$src" "$dest"
  chmod "$mode" "$dest" || true
  chown "$uid:$gid" "$dest" || true

  echo "Copied: $src -> $dest (uid=$uid gid=$gid mode=$mode)"
}

copy_one phaidra
copy_one phaidra_pages
'
echo "Done."