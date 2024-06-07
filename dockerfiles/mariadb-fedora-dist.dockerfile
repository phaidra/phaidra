FROM mariadb:10.5
../container_init/mariadb/fedoradb/fedoradb_grafana.sql /docker-entrypoint-initdb.d/fedoradb_grafana.sql
