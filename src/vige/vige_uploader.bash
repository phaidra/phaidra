ACL_PUBLIC='{"acl":{"ace":[{"allow":true,"role":"ROLE_ADMIN","action":"read"},{"allow":true,"role":"ROLE_ADMIN","action":"write"},{"allow":true,"role":"ROLE_ANONYMOUS","action":"read"}]}}'

# function definitions
function get_new_jobs {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval \
        'db.jobs.find({"agent": "vige", "status": "new"}).forEach(r=>print(JSON.stringify(r)))' | \
        jq -r '.pid'
}

function get_path {
        mongosh \
            --quiet \
            --authenticationDatabase admin \
            -u $M_USER \
            -p $M_PASS \
            mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
            --eval \
            'JSON.stringify(db.jobs.findOne({pid: "'$1'"}))' | \
            jq -r '.path'
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
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval \
        'db.jobs.findOneAndUpdate({ pid: "'$1'" }, { $set: { 'oc_mpid': "'$2'", 'status': "sent" } })'
}

function get_suffix {
    file $1 --extension | awk '{ print $2 }' | awk -F'/' '{ print $1 }'
}

# algorithm
while true
do
    if [[ -z "$(get_new_jobs)" ]]
    then
        sleep 10
    else
        for PID in $(get_new_jobs)
        do
            printf "%s -- uploading.\n" $PID
            PID_UPLOAD=$(echo $PID | sed 's|:|_|')
            ORIGINAL_FILE=$(get_path $PID)
            SUFFIX=$(get_suffix $ORIGINAL_FILE)
            if [[ -z $SUFFIX ]] || [[ $SUFFIX == "???" ]]
            then
                FILETYPE="mpeg"
            else
                FILETYPE=$SUFFIX
            fi
            LINKNAME="$PID_UPLOAD.$FILETYPE"
            ln -s $ORIGINAL_FILE $LINKNAME
            OC_MPID=$(upload_file_get_mpid $PID_UPLOAD "$ACL_PUBLIC" $LINKNAME)
            if [[ -z $OC_MPID ]]
            then
                printf "$PID -- upload failed, trying again later.\n"
            else
                printf "%s -- uploaded. oc_mpid: %s.\n" $PID $OC_MPID
                set_mpid_sent $PID $OC_MPID > /dev/null
            fi
            unlink $LINKNAME
        done
    fi
done
