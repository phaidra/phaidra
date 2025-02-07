FROM ubuntu:jammy-20240627.1
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
imagemagick libvips-tools libyaml-syck-perl libmongodb-perl libnet-amazon-s3-perl
apt-get clean
EOF

RUN mkdir -pv /opt/pixelgecko
WORKDIR /opt/pixelgecko
ENTRYPOINT ["perl", "pixelgecko.pl", "--watch"]
