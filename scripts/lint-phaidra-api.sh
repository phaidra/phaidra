#!/usr/bin/env bash
# Run phaidra-api lint checks using the same tools and image as GitLab CI.
#
# Usage:
#   ./scripts/lint-phaidra-api.sh          # check (fails on perltidy, like CI)
#   ./scripts/lint-phaidra-api.sh --fix    # format *.pm/*.pl in place with CI perltidy
#
# Override the CI image (must match .gitlab-ci.yml lint job):
#   CICD_IMAGE=docker.io/phaidraorg/cicd:TAG ./scripts/lint-phaidra-api.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CICD_IMAGE="${CICD_IMAGE:-docker.io/phaidraorg/cicd:e9e114ee}"
PHAIDRA_API_REL="src/phaidra-api"
FIX=0

usage() {
  sed -n '2,9p' "$0"
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage 0
      ;;
    --fix)
      FIX=1
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage 1
      ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is required" >&2
  exit 1
fi

run_cicd() {
  local docker_user=(-u "$(id -u):$(id -g)")
  if [[ "${CICD_AS_ROOT:-0}" == "1" ]]; then
    docker_user=(-u 0:0)
  fi
  docker run --rm \
    "${docker_user[@]}" \
    -v "$REPO_ROOT:/work" \
    -w /work \
    "$CICD_IMAGE" \
    "$@"
}

echo "Using CI image: $CICD_IMAGE"
echo

if [[ "$FIX" -eq 1 ]]; then
  echo "==> perltidy (format in place)"
  CICD_AS_ROOT=1 run_cicd sh -ec "cd $PHAIDRA_API_REL && find . -name '*.p[ml]' | xargs -P4 -I{} perltidy -b -bext=/ {}"
  echo "Done. Re-run without --fix to verify."
  exit 0
fi

echo "==> perlcritic $PHAIDRA_API_REL"
# CI collects perlcritic output for code quality reports but does not fail the job.
set +e
run_cicd perlcritic "$PHAIDRA_API_REL"
perlcritic_status=$?
set -e
if [[ "$perlcritic_status" -eq 0 ]]; then
  echo "perlcritic: OK"
else
  echo "perlcritic: reported issues (informational; CI does not fail on this)" >&2
fi
echo

echo "==> perltidy (assert tidy)"
set +e
run_cicd sh -ec "cd $PHAIDRA_API_REL && find . -name '*.p[ml]' | xargs -P4 -I{} perltidy -st -se -ast {} 1> /dev/null"
perltidy_status=$?
set -e
if [[ "$perltidy_status" -ne 0 ]]; then
  echo "perltidy: FAILED (exit $perltidy_status)" >&2
  echo "Run './scripts/lint-phaidra-api.sh --fix' to format with the CI perltidy version." >&2
  exit "$perltidy_status"
fi
echo "perltidy: OK"
