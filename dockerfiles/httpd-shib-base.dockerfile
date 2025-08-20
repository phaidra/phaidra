FROM httpd:2.4.65-trixie
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
libapache2-mod-shib
apt-get clean
EOF
