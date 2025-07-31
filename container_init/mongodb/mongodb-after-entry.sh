#!/bin/bash

CHECK=$(mongo --quiet --authenticationDatabase admin -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} mongodb --eval 'db.oai_sets.exists()')

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

# Create a collection for cms templates
mongo --quiet --authenticationDatabase admin -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} mongodb --eval "
db = db.getSiblingDB('mongodb');
db.createCollection('cmstemplates');
"

# Ensure indexes exist for oai_records collection

echo "Creating oai_records collection and indexes (if not present)..."
mongo --quiet --authenticationDatabase admin -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} mongodb --eval "
db = db.getSiblingDB('mongodb');
if (db.oai_records.countDocuments({}) === 0) db.oai_records.insertOne({ _temp: true });
db.oai_records.createIndex({ pid: 1 });
db.oai_records.createIndex({ created: -1 });
db.oai_records.createIndex({ updated: -1 });
db.oai_records.deleteOne({ _temp: true });
"

echo "Indexes created (if they did not already exist)."