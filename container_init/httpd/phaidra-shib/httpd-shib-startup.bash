cp /mnt/startup/conf/phaidra-shib.conf /usr/local/apache2/conf/httpd.conf
cp /mnt/startup/conf/fullchain.pem /usr/local/apache2/conf/server.crt
cp /mnt/startup/conf/privkey.pem /usr/local/apache2/conf/server.key
cp /mnt/startup/conf/sp-signing-key.pem \
   /mnt/startup/conf/sp-signing-cert.pem \
   /mnt/startup/conf/sp-encrypt-key.pem \
   /mnt/startup/conf/sp-encrypt-cert.pem \
   /mnt/startup/conf/aconet-metadata-signing.crt \
   /mnt/startup/conf/attribute-map.xml \
   /mnt/startup/conf/attribute-policy.xml \
   /mnt/startup/conf/security-policy.xml \
   /mnt/startup/conf/shibboleth2.xml \
   /etc/shibboleth/
sed -i \
    -e "s|__PHAIDRA_HOSTNAME__|${PHAIDRA_HOSTNAME}|" \
    -e "s|__ENTITY_ID__|${SHIB_ENTITY_ID}|" \
    -e "s|__DISCO_URL__|${SHIB_DISCO_URL}|" \
    -e "s|__SHIB_METADATA_FILE__|${SHIB_METADATA_FILE}|" \
    -e "s|__SHIB_METADATA__|${SHIB_METADATA}|" \
    -e "s|__SHIB_METADATA_CERT__|${SHIB_METADATA_CERT}|" \
    /etc/shibboleth/shibboleth2.xml
chown _shibd:_shibd /etc/shibboleth/sp-*
/etc/init.d/shibd start
httpd-foreground
