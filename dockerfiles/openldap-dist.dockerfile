FROM bitnami/openldap:2.6.6-debian-11-r59
ADD ../container_init/openldap/init.ldif /ldifs/init.ldif
