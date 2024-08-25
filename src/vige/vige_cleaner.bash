# functions

function get_deletion_objects {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval \
        'db.jobs.find({"oc_mpid": {$exists: true}, "agent": "vige", "status": {"$in": ["TO_DELETE", "DEL_REQUESTED"]}}).forEach(r=>print(JSON.stringify(r)))' | \
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

function delete_stream {
    curl \
        --silent \
        --user "$OC_USER:$OC_PASS" \
        -X "DELETE" \
        "$OC_EVENTS_URL/$1"
}

function get_mongo_status {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval 'JSON.stringify(db.jobs.findOne({ pid: "'$1'"}))' | \
        jq -r '.status'
}

function set_mongo_status {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval 'db.jobs.findOneAndUpdate({ pid: "'$1'" }, { $set: { 'status': "'$2'" } })'
}


function check_deletion {
    curl \
        --silent \
        --user "$OC_USER:$OC_PASS" \
        "$OC_EVENTS_URL/$1"
}


function cleanup_mongo_entries {
    mongosh \
        --quiet \
        --authenticationDatabase admin \
        -u $M_USER \
        -p $M_PASS \
        mongodb://$MONGODB_PHAIDRA_HOST/$M_AGENT_DB \
        --eval 'db.jobs.findOneAndUpdate({ pid: "'$1'" }, { $unset: { oc_api_video: "" , oc_engage_video: "", oc_mpid: "", oc_player_url: "", oc_admin_video: "" } })'
}

# algorithm
while true
do
    if [ -z "$(get_deletion_objects)" ]
    then
        sleep 10
    else
        for MPID in $(get_deletion_objects)
        do
            PID_FOCUS=$(get_pid $MPID)
            MONGO_STATUS=$(get_mongo_status $PID_FOCUS)
            if [ $MONGO_STATUS == "TO_DELETE" ]
            then
                printf "Sending deletion request for: %s (%s).\n" $PID_FOCUS $MPID
                delete_stream $MPID
                set_mongo_status $PID_FOCUS "DEL_REQUESTED" > /dev/null
            else
                DELETION_STATE=$(check_deletion $MPID)
                if [[ "${DELETION_STATE}" == *"Cannot find"* ]]
                then
                    cleanup_mongo_entries $PID_FOCUS
                    set_mongo_status $PID_FOCUS "OC_DELETED_$(date -I)" > /dev/null
                    printf "Opencast stream successfully deleted for: %s.\n" $PID_FOCUS
                fi
            fi
        done
        sleep 60
    fi
done

                    
                
                
                
