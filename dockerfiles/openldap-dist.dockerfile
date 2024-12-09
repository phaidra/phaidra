FROM bitnami/openldap:2.6.9-debian-12-r0
ADD ../container_init/openldap/init.ldif /ldifs/init.ldif
