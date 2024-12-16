echo "FcgidInitialEnv BASE_URL \"${OUTSIDE_HTTP_SCHEME}://${PHAIDRA_HOSTNAME}${PHAIDRA_PORTSTUB}${PHAIDRA_HOSTPORT}/api/imageserver?IIIF=\"" >> /etc/apache2/mods-enabled/iipsrv.conf
/etc/init.d/shibd start
httpd-foreground