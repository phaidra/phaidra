FROM httpd:2.4.62-bookworm
ADD ../container_init/httpd/phaidra-demo/conf/phaidra-demo.conf \
    /usr/local/apache2/conf/httpd.conf
