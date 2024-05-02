FROM httpd:2.4.58-bookworm
ADD ../container_init/httpd/phaidra-cloudready/conf/httpd.conf \
    /usr/local/apache2/conf/httpd.conf
