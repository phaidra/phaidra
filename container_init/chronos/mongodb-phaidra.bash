printf "############################################################\n"
printf "### dumping phaidra mongodb ################################\n"
printf "############################################################\n"
if /usr/bin/mongodump \
       -h mongodb-phaidra \
       -u ${MONGODB_PHAIDRA_USER} \
       -p ${MONGODB_PHAIDRA_PASSWORD} \
       --gzip \
       --archive=/mnt/database-dumps/$(date +%F-%H-%M-%S)-mongodb.tar.gz
then
    printf "############################################################\n"
    printf "### done ###################################################\n"
    printf "############################################################\n"
else
    printf "############################################################\n"
    printf "### something went wrong, do not rely on this dump #########\n"
    printf "############################################################\n"
fi
