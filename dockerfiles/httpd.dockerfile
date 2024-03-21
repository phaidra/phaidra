FROM httpd:2.4.58-bookworm
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
pandoc
apt-get clean
EOF
