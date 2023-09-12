FROM httpd:2.4.57-bookworm
ARG PHAIDRA_HOSTNAME
ARG SHIB_ENTITY_ID
ARG SHIB_DISCO_URL
ARG SHIB_METADATA
ARG SHIB_METADATA_FILE
ARG SHIB_METADATA_CERT
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends \
libapache2-mod-shib
apt-get clean
EOF
COPY ./shibboleth/aconet-metadata-signing.crt /etc/shibboleth/
COPY ./shibboleth/shibboleth2.xml /etc/shibboleth/
RUN <<EOF
sed -i "s|__PHAIDRA_HOSTNAME__|${PHAIDRA_HOSTNAME}|" \
/etc/shibboleth/shibboleth2.xml
sed -i "s|__ENTITY_ID__|${SHIB_ENTITY_ID}|" \
/etc/shibboleth/shibboleth2.xml
sed -i "s|__DISCO_URL__|${SHIB_DISCO_URL}|" \
/etc/shibboleth/shibboleth2.xml
sed -i "s|__SHIB_METADATA_FILE__|${SHIB_METADATA_FILE}|" \
/etc/shibboleth/shibboleth2.xml
sed -i "s|__SHIB_METADATA__|${SHIB_METADATA}|" \
/etc/shibboleth/shibboleth2.xml
sed -i "s|__SHIB_METADATA_CERT__|${SHIB_METADATA_CERT}|" \
/etc/shibboleth/shibboleth2.xml
EOF
COPY ./dockerfiles/httpd_shib_entrypoint.bash /
ENTRYPOINT ["/bin/bash", "/httpd_shib_entrypoint.bash"]
