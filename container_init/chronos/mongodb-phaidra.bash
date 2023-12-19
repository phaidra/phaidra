/usr/bin/mongodump -h mongodb-phaidra -u ${MONGODB_PHAIDRA_USER} -p ${MONGODB_PHAIDRA_PASSWORD} --gzip --archive=/mnt/database-dumps/$(date +%F-%H-%M-%S)-mongodb.tar.gz
