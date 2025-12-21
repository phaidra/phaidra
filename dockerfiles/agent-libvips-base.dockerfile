FROM ubuntu:jammy-20251001
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
imagemagick libvips-tools libyaml-syck-perl libmongodb-perl libnet-amazon-s3-perl
apt-get clean
EOF

RUN mkdir -pv /opt/agent-libvips
WORKDIR /opt/agent-libvips
ENTRYPOINT ["perl", "agent-libvips.pl", "--watch"]
