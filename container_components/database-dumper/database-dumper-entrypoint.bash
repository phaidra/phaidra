declare -p | grep -E 'MARIADB_ROOT_PASSWORD|PHAIDRADB|FEDORADB|MONGODB_PHAIDRA_USER|MONGODB_PHAIDRA_PASSWORD' > /container.env
crontab /mnt/database-dumper/database-dumper-crontab.txt
service cron start
tail -F anything
