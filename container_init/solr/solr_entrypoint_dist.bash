SOLR_SALTED_HASH=$(printf ${SOLR_SALT}${SOLR_PASS} | openssl dgst -sha256 -binary | openssl dgst -sha256 -binary | base64)
SOLR_ENCODED_SALT=$(printf ${SOLR_SALT} | base64)
mkdir -pv /var/solr/data
cp -n /tmp/security.json /var/solr/data/security.json
cp -n /tmp/log4j2.xml /var/solr/log4j2.xml
sed -i \
    -e "s|__SOLR_USER__|${SOLR_USER}|g" \
    -e "s|__SOLR_SALTED_HASH__|${SOLR_SALTED_HASH}|g" \
    -e "s|__SOLR_ENCODED_SALT__|${SOLR_ENCODED_SALT}|g" \
    /var/solr/data/security.json
precreate-core phaidra /tmp/phaidra_core_init
precreate-core phaidra_pages /tmp/phaidra_pages_core_init
solr-foreground
