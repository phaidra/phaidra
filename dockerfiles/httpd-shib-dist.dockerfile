FROM phaidraorg/httpd-shib-base:latest
ADD ../container_init/httpd/phaidra-shib/conf/phaidra-shib.conf /usr/local/apache2/conf/httpd.conf
ADD ../container_init/httpd/phaidra-shib/conf/aconet-metadata-signing.crt /shib-init/
ADD ../container_init/httpd/phaidra-shib/conf/attribute-map.xml /shib-init/
ADD ../container_init/httpd/phaidra-shib/conf/attribute-policy.xml /shib-init/
ADD ../container_init/httpd/phaidra-shib/conf/security-policy.xml /shib-init/
ADD ../container_init/httpd/phaidra-shib/conf/shibboleth2.xml /shib-init/
ADD ../container_init/httpd/phaidra-shib/httpd-shib-entrypoint.bash /
ENTRYPOINT ["bash", "/httpd-shib-entrypoint.bash"]
