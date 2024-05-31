printf "############################################################\n"
printf "### check phaidra mariadb integrity ########################\n"
printf "############################################################\n"
mysqlcheck \
    -h ${MARIADB_PHAIDRA_HOST} \
    -u root \
    -p${MARIADB_ROOT_PASSWORD} \
    ${PHAIDRADB}
printf "############################################################\n"
printf "### dump phaidra mariadb ###################################\n"
printf "############################################################\n"
if mariadb-dump \
       --verbose \
       -h ${MARIADB_PHAIDRA_HOST} \
       -u root \
       -p${MARIADB_ROOT_PASSWORD} \
       -x ${PHAIDRADB} | \
        gzip > /mnt/database-dumps/$(date +%F-%H-%M-%S)-${PHAIDRADB}.sql.gz
then
    printf "############################################################\n"
    printf "### done ###################################################\n"
    printf "############################################################\n"
else
    printf "############################################################\n"
    printf "### something went wrong, do not rely on this dump #########\n"
    printf "############################################################\n"
fi
