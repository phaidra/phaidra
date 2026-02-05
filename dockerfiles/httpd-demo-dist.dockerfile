FROM httpd:2.4.66-trixie
ADD ../container_init/httpd/phaidra-demo/conf/phaidra-demo.conf \
    /usr/local/apache2/conf/httpd.conf
