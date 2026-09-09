#!/usr/bin/env bash
# Poll Mongo jobs with agent=opencastfetch, download media from OpenCast,
# POST OCTETS to PHAIDRA, activate the inactive object, and mark the job done.

set -u

WORK_DIR="${OC_FETCHER_WORK_DIR:-/opt/agent-opencast/fetcher}"
SLEEP_EMPTY="${OC_FETCHER_SLEEP_EMPTY:-10}"
SLEEP_BETWEEN="${OC_FETCHER_SLEEP_BETWEEN:-5}"
PHAIDRA_API_URL="${PHAIDRA_API_URL:-http://api:3000}"
PHAIDRA_API_USER="${PHAIDRA_API_USER:-${PHAIDRA_ADMIN_USER:-phaidraAdmin}}"
PHAIDRA_API_PASS="${PHAIDRA_API_PASS:-${PHAIDRA_ADMIN_PASSWORD:-}}"

mkdir -p "$WORK_DIR"

function mongosh_eval {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u "$M_USER" \
        -p "$M_PASS" \
        "mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB" \
        --eval "$1"
}

function claim_job {
    mongosh_eval '
        const doc = db.jobs.findOneAndUpdate(
            { agent: "opencastfetch", status: "new", oc_mpid: { $exists: true, $ne: "" } },
            { $set: { status: "in_progress", started: Math.floor(Date.now() / 1000) } },
            { sort: { created: -1 }, returnDocument: "after" }
        );
        if (doc) { print(JSON.stringify(doc)); }
    '
}

function set_job_status {
    local job_id="$1"
    local status="$2"
    local msg="${3:-}"
    mongosh_eval "
        const update = { status: '$status', finished: Math.floor(Date.now() / 1000) };
        if ('$msg' !== '') { update.error = '$msg'; }
        db.jobs.findOneAndUpdate(
            { _id: ObjectId('$job_id'), agent: 'opencastfetch' },
            { \$set: update },
            { }
        );
    " >/dev/null
}

function encode_pid {
    printf '%s' "$1" | sed 's|:|%3A|'
}

function api_curl {
    curl --silent --show-error --fail-with-body \
        --user "$PHAIDRA_API_USER:$PHAIDRA_API_PASS" \
        "$@"
}

function set_inactive_status {
    local pid="$1"
    local status="$2"
    local enc
    enc=$(encode_pid "$pid")
    api_curl \
        -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"status\":\"$status\"}" \
        "$PHAIDRA_API_URL/inactive-objects/$enc/status" \
        >/dev/null 2>&1 || true
}

function pick_media_track {
    local media_json="$1"
    jq -c '
      (map(select(.flavor == "presentation/source")) | .[0])
      // (map(select(.flavor == "presenter/source")) | .[0])
      // (map(select((.flavor // "") | test("source"))) | sort_by(-(.size // 0)) | .[0])
      // (map(select(.has_video == true)) | sort_by(-(.size // 0)) | .[0])
      // (sort_by(-(.size // 0)) | .[0])
      | select(.uri != null)
      | {uri: .uri, mimetype: (.mimetype // "video/mp4"), flavor: (.flavor // ""), filename: (.filename // "")}
    ' <<<"$media_json"
}

function extension_for_mimetype {
    case "$1" in
        video/mp4) echo mp4 ;;
        video/webm) echo webm ;;
        video/x-matroska|video/matroska) echo mkv ;;
        video/quicktime) echo mov ;;
        video/mpeg) echo mpg ;;
        audio/mpeg) echo mp3 ;;
        *) echo bin ;;
    esac
}

function download_track {
    local uri="$1"
    local dest="$2"
    curl --silent --show-error --fail \
        --user "$OC_USER:$OC_PASS" \
        --location \
        --output "$dest" \
        "$uri"
}

function upload_octets {
    local pid="$1"
    local file="$2"
    local mimetype="$3"
    local enc
    enc=$(encode_pid "$pid")
    api_curl \
        -X POST \
        -F "file=@${file};type=${mimetype};filename=$(basename "$file")" \
        -F "mimetype=${mimetype}" \
        "$PHAIDRA_API_URL/object/$enc/data"
}

function activate_object {
    local pid="$1"
    local enc
    enc=$(encode_pid "$pid")
    api_curl \
        -X POST \
        "$PHAIDRA_API_URL/inactive-objects/$enc/activate?notify=1"
}

function process_job {
    local job_json="$1"
    local job_id pid oc_mpid workfile media_json track uri mimetype flavor filename ext

    job_id=$(jq -r '._id.$oid // ._id' <<<"$job_json")
    pid=$(jq -r '.pid' <<<"$job_json")
    oc_mpid=$(jq -r '.oc_mpid' <<<"$job_json")

    printf "%s -- opencastfetch start (oc_mpid=%s)\n" "$pid" "$oc_mpid"

    if [[ -z "$pid" || -z "$oc_mpid" || "$pid" == "null" || "$oc_mpid" == "null" ]]; then
        printf "%s -- missing pid/oc_mpid, marking failed\n" "$pid"
        [[ -n "$job_id" && "$job_id" != "null" ]] && set_job_status "$job_id" "failed" "missing pid or oc_mpid"
        return
    fi

    if [[ -z "$PHAIDRA_API_PASS" ]]; then
        printf "%s -- PHAIDRA_API_PASS not set\n" "$pid"
        set_job_status "$job_id" "failed" "PHAIDRA_API_PASS not set"
        set_inactive_status "$pid" "Error: agent not configured"
        return
    fi

    set_inactive_status "$pid" "Downloading from OpenCast..."

    media_json=$(curl --silent --show-error --fail-with-body \
        --user "$OC_USER:$OC_PASS" \
        -H 'Accept: application/json' \
        "$OC_EVENTS_URL/$oc_mpid/media") || {
        printf "%s -- failed to list OC media\n" "$pid"
        set_job_status "$job_id" "failed" "failed to list OC media"
        set_inactive_status "$pid" "Error downloading from OpenCast"
        return
    }

    track=$(pick_media_track "$media_json")
    if [[ -z "$track" || "$track" == "null" ]]; then
        printf "%s -- no suitable media track\n" "$pid"
        set_job_status "$job_id" "failed" "no suitable media track"
        set_inactive_status "$pid" "Error: no media in OpenCast"
        return
    fi

    uri=$(jq -r '.uri' <<<"$track")
    mimetype=$(jq -r '.mimetype' <<<"$track")
    flavor=$(jq -r '.flavor' <<<"$track")
    filename=$(jq -r '.filename // empty' <<<"$track")
    ext=$(extension_for_mimetype "$mimetype")
    if [[ -n "$filename" && "$filename" == *.* ]]; then
        workfile="$WORK_DIR/${pid//:/_}_$(basename "$filename")"
    else
        workfile="$WORK_DIR/${pid//:/_}_${flavor//\//_}.$ext"
    fi

    printf "%s -- downloading flavor=%s\n" "$pid" "$flavor"
    if ! download_track "$uri" "$workfile"; then
        printf "%s -- download failed\n" "$pid"
        set_job_status "$job_id" "failed" "download failed"
        set_inactive_status "$pid" "Error downloading from OpenCast"
        rm -f "$workfile"
        return
    fi

    if [[ ! -s "$workfile" ]]; then
        printf "%s -- downloaded file empty\n" "$pid"
        set_job_status "$job_id" "failed" "empty download"
        set_inactive_status "$pid" "Error downloading from OpenCast"
        rm -f "$workfile"
        return
    fi

    set_inactive_status "$pid" "Uploading to PHAIDRA..."
    printf "%s -- uploading OCTETS (%s)\n" "$pid" "$mimetype"
    if ! upload_octets "$pid" "$workfile" "$mimetype"; then
        printf "%s -- OCTETS upload failed\n" "$pid"
        set_job_status "$job_id" "failed" "OCTETS upload failed"
        set_inactive_status "$pid" "Error uploading to PHAIDRA"
        rm -f "$workfile"
        return
    fi

    set_inactive_status "$pid" "Activating object..."
    printf "%s -- activating\n" "$pid"
    if ! activate_object "$pid"; then
        printf "%s -- activate failed\n" "$pid"
        set_job_status "$job_id" "failed" "activate failed"
        set_inactive_status "$pid" "Error activating object"
        rm -f "$workfile"
        return
    fi

    set_job_status "$job_id" "finished"
    printf "%s -- opencastfetch finished\n" "$pid"
    rm -f "$workfile"
}

# algorithm
while true
do
    JOB=$(claim_job || true)
    if [[ -z "$JOB" ]]; then
        sleep "$SLEEP_EMPTY"
        continue
    fi
    process_job "$JOB" || true
    sleep "$SLEEP_BETWEEN"
done
