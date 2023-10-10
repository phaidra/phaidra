find /mnt/database-dumps -type f -name "*${PHAIDRADB}*" | sort -r | tail -n+8 | xargs rm
find /mnt/database-dumps -type f -name "*${FEDORADB}*" | sort -r | tail -n+8 | xargs rm
find /mnt/database-dumps -type f -name "*mongodb*" | sort -r | tail -n+8 | xargs rm
