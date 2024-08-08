FROM httpd:2.4.62-bookworm
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
libapache2-mod-shib
apt-get clean
EOF
