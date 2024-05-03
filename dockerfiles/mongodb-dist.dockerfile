FROM mongo:5
ADD ../container_init/mongodb/init_oai_sets.json /mnt/init_oai_sets.json
ADD ../container_init/mongodb/mongodb-after-entry.sh /docker-entrypoint-initdb.d/mongodb-after-entry.sh
