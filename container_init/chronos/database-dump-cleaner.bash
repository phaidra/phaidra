find /mnt/database-dumps -type f -name "*${PHAIDRADB}*" -ctime +30 -delete
find /mnt/database-dumps -type f -name "*${FEDORADB}*" -ctime +30 -delete
find /mnt/database-dumps -type f -name "*mongodb*" -ctime +30 -delete
