SOLR_SALT=${SOLR_SALT}
SOLR_SALTED_HASH=$(printf ${SOLR_SALT}${SOLR_PASS} | openssl dgst -sha256 -binary | openssl dgst -sha256 -binary | base64)
SOLR_ENCODED_SALT=$(printf ${SOLR_SALT} | base64)
sed -i \
    -e "s|__SOLR_USER__|${SOLR_USER}|g" \
    -e "s|__SOLR_SALTED_HASH__|${SOLR_SALTED_HASH}|g" \
    -e "s|__SOLR_ENCODED_SALT__|${SOLR_ENCODED_SALT}|g" \
    /var/solr/data/security.json
solr-precreate phaidra /mnt/solr/phaidra_core
solr-foreground
