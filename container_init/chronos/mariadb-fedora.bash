printf "############################################################\n"
printf "### check fedora mariadb integrity #########################\n"
printf "############################################################\n"
mysqlcheck \
    -h ${MARIADB_FEDORA_HOST} \
    -u root \
    -p${MARIADB_ROOT_PASSWORD} \
    ${FEDORADB}
printf "############################################################\n"
printf "### dump fedora mariadb ####################################\n"
printf "############################################################\n"
if mariadb-dump \
       --verbose \
       -h ${MARIADB_FEDORA_HOST} \
       -u root \
       -p${MARIADB_ROOT_PASSWORD} \
       -x ${FEDORADB} | \
        gzip > /mnt/database-dumps/$(date +%F-%H-%M-%S)-${FEDORADB}.sql.gz
then
    printf "############################################################\n"
    printf "### done ###################################################\n"
    printf "############################################################\n"
else
    printf "############################################################\n"
    printf "### something went wrong, do not rely on this dump #########\n"
    printf "############################################################\n"
fi

    
