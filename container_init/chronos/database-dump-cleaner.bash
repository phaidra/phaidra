printf "############################################################\n"
printf "### cleaning up old database dumps #########################\n"
printf "############################################################\n"
printf "### deleting mariadb phaidra dumps: ########################\n"
find /mnt/database-dumps -type f \
     -name "*${PHAIDRADB}*" \
     -ctime +30 -delete -print | \
    grep \/ || printf "### nothing older than 30 days, doing nothing.\n"
printf "############################################################\n"
printf "### deleting mariadb fedora dumps: #########################\n"
find /mnt/database-dumps -type f \
     -name "*${FEDORADB}*" \
     -ctime +30 -delete -print | \
    grep \/ || printf "### nothing older than 30 days, doing nothing.\n"
printf "############################################################\n"
printf "### deleting old mongodb phaidra dumps: ####################\n"
find /mnt/database-dumps -type f \
     -name "*mongodb*" \
     -ctime +30 -delete -print | \
    grep \/ || printf "### nothing older than 30 days, doing nothing.\n"
printf "############################################################\n"
printf "### done. ##################################################\n"
printf "############################################################\n"
