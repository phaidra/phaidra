mariadb-dump -h mariadb-phaidra -u root -p${MARIADB_ROOT_PASSWORD} -x ${PHAIDRADB} | gzip > /mnt/database-dumps/$(date +%F-%H-%M-%S)-${PHAIDRADB}.sql.gz
