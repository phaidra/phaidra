ACL_PUBLIC='{"acl":{"ace":[{"allow":true,"role":"ROLE_ADMIN","action":"read"},{"allow":true,"role":"ROLE_ADMIN","action":"write"},{"allow":true,"role":"ROLE_ANONYMOUS","action":"read"}]}}'
MAX_IN_FLIGHT="${OC_MAX_IN_FLIGHT:-5}"
SLEEP_AT_CAP="${OC_UPLOAD_SLEEP_AT_CAP:-10}"

if ! [[ "$MAX_IN_FLIGHT" =~ ^[1-9][0-9]*$ ]]; then
    printf 'OC_MAX_IN_FLIGHT must be a positive integer, got: %s\n' "$MAX_IN_FLIGHT" >&2
    exit 1
fi

if ! [[ "$SLEEP_AT_CAP" =~ ^[1-9][0-9]*$ ]]; then
    printf 'OC_UPLOAD_SLEEP_AT_CAP must be a positive integer, got: %s\n' "$SLEEP_AT_CAP" >&2
    exit 1
fi

function get_in_flight_count {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u "$M_USER" \
        -p "$M_PASS" \
        "mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB" \
        --eval 'print(db.jobs.countDocuments({ agent: "opencast", status: { $in: ["uploading", "sent"] } }))'
}

function claim_job {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u "$M_USER" \
        -p "$M_PASS" \
        "mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB" \
        --eval \
        'const doc = db.jobs.findOneAndUpdate(
            { agent: "opencast", status: "new" },
            { $set: { status: "uploading", started: Math.floor(Date.now() / 1000) } },
            { sort: { created: 1 }, returnDocument: "after" }
        );
        if (doc) { print(JSON.stringify(doc)); }'
}

function release_job {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u "$M_USER" \
        -p "$M_PASS" \
        "mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB" \
        --eval \
        'db.jobs.findOneAndUpdate({ _id: ObjectId("'$1'"), agent: "opencast" }, { $set: { status: "new" } })'
}

function upload_file_get_mpid {
    curl \
        --silent \
        --user "$OC_USER:$OC_PASS" "$OC_INGEST_URL/$OC_WORKFLOW" \
        --form creator="$OC_USER" \
        --form title="$1" \
        --form flavor="presentation/source" \
        --form acl="$2" \
        --form "BODY=@$3" | \
        xpath -q -e /wf:workflow/wf:mediaPackageId | \
        html2text | \
        paste -s -d ''
}

function set_mpid_sent {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
    -u "$M_USER" \
    -p "$M_PASS" \
    "mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB" \
        --eval \
    'db.jobs.findOneAndUpdate({ _id: ObjectId("'$1'"), agent: "opencast" }, { $set: { oc_mpid: "'$2'", status: "sent" } })'
}

function get_suffix {
    file $1 --extension | awk '{ print $2 }' | awk -F'/' '{ print $1 }'
}

# algorithm
while true
do
    IN_FLIGHT=$(get_in_flight_count || true)
    if ! [[ "$IN_FLIGHT" =~ ^[0-9]+$ ]]; then
        printf 'Unable to determine the number of in-flight Opencast jobs; retrying in %s seconds.\n' "$SLEEP_AT_CAP" >&2
        sleep "$SLEEP_AT_CAP"
        continue
    fi

    printf 'Opencast in-flight jobs: %s/%s.\n' "$IN_FLIGHT" "$MAX_IN_FLIGHT"

    if (( IN_FLIGHT >= MAX_IN_FLIGHT )); then
        printf 'Opencast in-flight job limit reached (%s/%s); waiting %s seconds.\n' "$IN_FLIGHT" "$MAX_IN_FLIGHT" "$SLEEP_AT_CAP"
        sleep "$SLEEP_AT_CAP"
        continue
    fi

    JOB=$(claim_job || true)
    if [[ -z "$JOB" ]]
    then
        sleep 10
    else
        JOB_ID=$(jq -r '._id | if type == "object" then .["$oid"] else . end' <<<"$JOB")
        PID=$(jq -r '.pid' <<<"$JOB")
        ORIGINAL_FILE=$(jq -r '.path' <<<"$JOB")
        printf "%s -- uploading.\n" "$PID"
        PID_UPLOAD=$(echo "$PID" | sed 's|:|_|')
        SUFFIX=$(get_suffix "$ORIGINAL_FILE")
        if [[ -z $SUFFIX ]] || [[ $SUFFIX == "???" ]]
        then
            FILETYPE="mpeg"
        else
            FILETYPE=$SUFFIX
        fi
        LINKNAME="$PID_UPLOAD.$FILETYPE"
        ln -s "$ORIGINAL_FILE" "$LINKNAME"

        OC_MPID=$(upload_file_get_mpid "$PID_UPLOAD" "$ACL_PUBLIC" "$LINKNAME")
        if [[ -z $OC_MPID ]]
        then
            printf "%s -- upload failed, trying again later.\n" "$PID"
            release_job "$JOB_ID" > /dev/null
        else
            printf "%s -- uploaded. oc_mpid: %s.\n" "$PID" "$OC_MPID"
            set_mpid_sent "$JOB_ID" "$OC_MPID" > /dev/null
        fi
        unlink "$LINKNAME"
    fi
done
