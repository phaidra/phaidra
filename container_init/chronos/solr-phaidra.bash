printf "############################################################\n"
printf "### triggering solr backup via replication handler #########\n"
printf "############################################################\n"

SOLR_BACKUP_USER="${SOLR_USER:-solradmin}"
SOLR_BACKUP_PASS="${SOLR_PASS:-xxx}"
SOLR_BACKUP_HOST="${SOLR_HOST:-solr}"
SOLR_BACKUP_COLLECTION="${SOLR_COLLECTION:-phaidra}"
SOLR_BACKUP_LOCATION="/mnt/database-dumps"

BACKUP_URL="http://${SOLR_BACKUP_HOST}:8983/solr/${SOLR_BACKUP_COLLECTION}/replication"

printf "### calling: %s?command=backup&location=%s\n" "${BACKUP_URL}" "${SOLR_BACKUP_LOCATION}"

if curl -sS -u "${SOLR_BACKUP_USER}:${SOLR_BACKUP_PASS}" \
       "${BACKUP_URL}?command=backup&location=${SOLR_BACKUP_LOCATION}"
then
    printf "############################################################\n"
    printf "### solr backup request sent successfully ##################\n"
    printf "############################################################\n"
else
    printf "############################################################\n"
    printf "### solr backup request FAILED #############################\n"
    printf "############################################################\n"
fi


