# function definitions
function get_status {
    curl \
        --silent \
        --user "$OC_USER:$OC_PASS" \
        "$OC_EVENTS_URL/$1" | \
        jq -r '.processing_state'
}

function get_publications {
    curl \
        --silent \
        --user "$OC_USER:$OC_PASS" \
        "$OC_EVENTS_URL/$1/publications"
}

function get_player_url {
    jq -r '.[] | select(.channel|index("engage-player")) | .url' $1
}

function get_engage_video {
    jq -r '.[] | select(.channel|index("engage-player")) | .media[] | select(.tags|index("720p-quality")) | .url' $1
}    

function get_api_video {
    jq -r '.[] | select(.channel|index("api")) | .media[] | select(.tags|index("720p-quality")) | .url' $1
}

function get_oc_admin_media {
    curl \
        --silent \
        --user "$OC_USER:$OC_PASS" \
        "$OC_EVENTS_URL/$1/media"
}

function get_admin_video {
    jq -r '.[] | select(.flavor|index("presentation/prepared")) | .uri' $1
}

function get_mpids {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://mongodb-phaidra/$M_AGENT_DB \
        --eval \
        'db.jobs.find({"oc_mpid": {$exists: true}, "agent": "vige", "status": "sent"}).forEach(r=>print(JSON.stringify(r)))' | \
        jq -r '.oc_mpid'
}

function get_pid {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://mongodb-phaidra/$M_AGENT_DB \
        --eval 'JSON.stringify(db.jobs.findOne({ oc_mpid: "'$1'"}))' | \
        jq -r '.pid'
}

function set_status {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://mongodb-phaidra/$M_AGENT_DB \
        --eval 'db.jobs.findOneAndUpdate({ oc_mpid: "'$1'" }, { $set: { 'status': "'$2'" } })'
}
    
function print_status {
    printf "%s (%s) -- status: %s\n" $1 $2 $3
}

function set_url {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://mongodb-phaidra/$M_AGENT_DB \
        --eval 'db.jobs.findOneAndUpdate({ pid: "'$1'" }, { $set: { "'$2'": "'$3'" } })'
}

    
# algorithm
while true
do
    if [ -z "$(get_mpids)" ]
    then
        sleep 10
    else
        for MPID in $(get_mpids)
        do
            STATUS=$(get_status $MPID)
            PID_FOCUS=$(get_pid $MPID)
            if [ $STATUS == "SUCCEEDED" ]
            then
                print_status $PID_FOCUS $MPID $STATUS
                get_publications $MPID > "$MPID-publications.json"
                get_oc_admin_media $MPID > "$MPID-admin-media.json"
                set_url $PID_FOCUS 'oc_player_url' \
                        $(get_player_url "$MPID-publications.json") \
                        > /dev/null
                set_url $PID_FOCUS 'oc_engage_video' \
                        $(get_engage_video "$MPID-publications.json") \
                        > /dev/null
                set_url $PID_FOCUS 'oc_api_video' \
                        $(get_api_video "$MPID-publications.json") \
                        > /dev/null
                set_url $PID_FOCUS 'oc_admin_video' \
                        $(get_admin_video "$MPID-admin-media.json") \
                        > /dev/null
                set_status $MPID $STATUS > /dev/null
                rm "$MPID-publications.json" "$MPID-admin-media.json"
            elif [ $STATUS == "FAILED" ]
            then
                print_status $PID_FOCUS $MPID $STATUS
                set_status $MPID $STATUS > /dev/null
            else
                print_status $PID_FOCUS $MPID $STATUS
            fi
        done
        sleep 60
    fi
done
