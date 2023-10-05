FROM httpd:2.4.57-bookworm
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends \
pandoc
apt-get clean
EOF
