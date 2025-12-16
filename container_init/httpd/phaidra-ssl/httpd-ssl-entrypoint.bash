EXTRA_FLAGS=
if [ "${HTTPD_ACME_ENABLE}" = "true" ]; then
  EXTRA_FLAGS="-D ACME"
else
  cp /ssl/fullchain.pem /usr/local/apache2/conf/server.crt
  cp /ssl/privkey.pem /usr/local/apache2/conf/server.key
fi
exec httpd-foreground ${EXTRA_FLAGS}

