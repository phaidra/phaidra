FROM httpd:2.4.62-bookworm
ADD ../container_init/httpd/phaidra-demo/conf/httpd.conf \
    /usr/local/apache2/conf/httpd.conf
