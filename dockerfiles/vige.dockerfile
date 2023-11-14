FROM debian:bookworm-20231030
ENV DEBIAN_FRONTEND noninteractive
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
jq libxml-xpath-perl html2text file gdebi curl parallel
apt-get clean
EOF
COPY ./../third-parties/mongodb-mongosh_2.0.2_amd64.deb /
RUN <<EOF
gdebi --quiet --non-interactive  mongodb-mongosh_2.0.2_amd64.deb
rm mongodb-mongosh_2.0.2_amd64.deb
EOF
RUN mkdir /opt/vige
WORKDIR /opt/vige
