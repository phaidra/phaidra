FROM mariadb:11.0.2-jammy
ADD ../container_init/mariadb/phaidradb/phaidradb_grafana.sql /docker-entrypoint-initdb.d/phaidradb_grafana.sql
ADD ../container_init/mariadb/phaidradb/phaidradb.sql.gz /docker-entrypoint-initdb.d/phaidradb.sql.gz
