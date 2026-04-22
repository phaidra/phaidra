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

function get_engage_thumbnail {
    jq -r '.[] | select(.channel|index("engage-player")) | .attachments[] | select(.flavor|index("presentation/player+preview")) | .url' $1
}

function get_mpids {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval \
        'db.jobs.find({"oc_mpid": {$exists: true}, "agent": "opencast", "status": "sent"}).forEach(r=>print(JSON.stringify(r)))' | \
        jq -r '.oc_mpid'
}

function get_pid {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval 'JSON.stringify(db.jobs.findOne({ oc_mpid: "'$1'"}))' | \
        jq -r '.pid'
}

function set_status {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
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
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval 'db.jobs.findOneAndUpdate({ pid: "'$1'", "agent": "opencast" }, { $set: { "'$2'": "'$3'" } }, { sort: { created: -1 } })'
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
                set_url $PID_FOCUS 'oc_player_url' \
                        $(get_player_url "$MPID-publications.json") \
                        > /dev/null
                set_url $PID_FOCUS 'oc_search_thumbnail' \
                        $(get_engage_thumbnail "$MPID-publications.json") \
                        > /dev/null
                set_status $MPID $STATUS > /dev/null
                rm "$MPID-publications.json"
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
