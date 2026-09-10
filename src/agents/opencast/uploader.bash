ACL_PUBLIC='{"acl":{"ace":[{"allow":true,"role":"ROLE_ADMIN","action":"read"},{"allow":true,"role":"ROLE_ADMIN","action":"write"},{"allow":true,"role":"ROLE_ANONYMOUS","action":"read"}]}}'

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
    JOB=$(claim_job || true)
    if [[ -z "$JOB" ]]
    then
        sleep 10
    else
        JOB_ID=$(jq -r '._id.$oid // ._id' <<<"$JOB")
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
