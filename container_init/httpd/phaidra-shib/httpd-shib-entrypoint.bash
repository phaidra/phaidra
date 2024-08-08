cp /ssl/privkey.pem /usr/local/apache2/conf/server.key
cp /ssl/fullchain.pem /usr/local/apache2/conf/server.crt
cp /shibboleth-certs/sp-signing-key.pem \
   /shibboleth-certs/sp-signing-cert.pem \
   /shibboleth-certs/sp-encrypt-key.pem \
   /shibboleth-certs/sp-encrypt-cert.pem \
   /shib-init/aconet-metadata-signing.crt \
   /shib-init/attribute-map.xml \
   /shib-init/attribute-policy.xml \
   /shib-init/shibboleth2.xml \
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
