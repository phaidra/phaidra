mariadb-dump -h mariadb-fedora -u root -p${MARIADB_ROOT_PASSWORD} -x ${FEDORADB} | gzip > /mnt/database-dumps/$(date +%F-%H-%M-%S)-${FEDORADB}.sql.gz
