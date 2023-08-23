FROM httpd:2.4.57-bookworm
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends \
libapache2-mod-shib
apt-get clean
EOF
ARG PHAIDRA_HOSTNAME
COPY ./shibboleth/aconet-metadata-signing.crt /etc/shibboleth/
COPY ./shibboleth/shibboleth2.xml /etc/shibboleth/
RUN <<EOF
sed -i "s|__PHAIDRA_HOSTNAME__|${PHAIDRA_HOSTNAME}|" \
/etc/shibboleth/shibboleth2.xml
EOF
COPY ./dockerfiles/httpd_shib_entrypoint.bash /
ENTRYPOINT ["/bin/bash", "/httpd_shib_entrypoint.bash"]
