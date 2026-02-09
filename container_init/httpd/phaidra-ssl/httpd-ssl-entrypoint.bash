EXTRA_FLAGS=
if [ "${HTTPD_ACME_ENABLE}" = "true" ]; then
  EXTRA_FLAGS="-D ACME"
else
  cp /ssl/fullchain.pem /usr/local/apache2/conf/server.crt
  cp /ssl/privkey.pem /usr/local/apache2/conf/server.key
fi

if [ "${HTTPD_ACME_EAB_ENABLE}" = "true" ]; then
  EXTRA_FLAGS="$EXTRA_FLAGS -D ACME_EAB"
fi

if [ "${HTTPD_PFSA_ENABLE}" = "true" ]; then
  EXTRA_FLAGS="$EXTRA_FLAGS -D PFSA"
fi

if [ -n "$HTTPD_PFSA_REDIRECT_FQDN" ]; then
  EXTRA_FLAGS="$EXTRA_FLAGS -D PFSA_REDIRECT"
fi

if [ "${HTTPD_NOINDEX_ENABLE}" = "true" ]; then
  EXTRA_FLAGS="$EXTRA_FLAGS -D NOINDEX"
fi

exec httpd-foreground ${EXTRA_FLAGS}

