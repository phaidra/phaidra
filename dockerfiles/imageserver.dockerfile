FROM ubuntu:jammy-20240627.1

ENV DEBIAN_FRONTEND=noninteractive
RUN touch /etc/default/iipsrv
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
    iipimage-server libapache2-mod-fcgid apache2 apache2-utils
apt-get clean
echo 'FcgidInitialEnv BASE_URL "${OUTSIDE_HTTP_SCHEME}://${PHAIDRA_HOSTNAME}${PHAIDRA_PORTSTUB}${PHAIDRA_HOSTPORT}/api/imageserver?IIIF=\' >> /etc/apache2/mods-enabled/iipsrv.conf
EOF

EXPOSE 80
ADD ../container_init/imageserver/imageserver-entrypoint.bash /imageserver-entrypoint.bash
ENTRYPOINT ["bash", "/imageserver-entrypoint.bash"]
