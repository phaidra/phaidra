#!/bin/bash

CHECK=$(mongosh --quiet --authenticationDatabase admin -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} mongodb --eval 'db.oai_sets.exists()')

if [[ "null" == "$CHECK" ]]
then
    echo "Importing default OAI set values."
    mongoimport --authenticationDatabase=admin \
                -u ${MONGO_INITDB_ROOT_USERNAME} \
                -p ${MONGO_INITDB_ROOT_PASSWORD} \
                -d mongodb \
                --jsonArray \
                --collection='oai_sets' \
                --file='/mnt/init_oai_sets.json'
else
    echo "OAI sets exist, not importing default values."
fi

