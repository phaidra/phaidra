FROM httpd:2.4.62-bookworm
ADD ../container_init/httpd/phaidra-ssl/conf/phaidra-ssl.conf \
    /usr/local/apache2/conf/httpd.conf
ADD ../container_init/httpd/phaidra-ssl/httpd-ssl-entrypoint.bash \
    /httpd-ssl-entrypoint.bash
ENTRYPOINT ["bash", "/httpd-ssl-entrypoint.bash"]
