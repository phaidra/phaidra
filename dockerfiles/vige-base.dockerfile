FROM ubuntu:jammy-20251001
ENV DEBIAN_FRONTEND=noninteractive
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
jq libxml-xpath-perl html2text file gdebi curl parallel \
wget gnupg 
apt-get clean
EOF
RUN <<EOF
wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | tee /etc/apt/trusted.gpg.d/server-7.0.asc
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
tee /etc/apt/sources.list.d/mongodb-org-7.0.list
EOF
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet mongodb-mongosh
EOF
RUN mkdir /opt/vige
WORKDIR /opt/vige
ENTRYPOINT ["bash", "/mnt/vige/vige_controller.bash"]
