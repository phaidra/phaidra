FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive

RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
libvips-tools libyaml-syck-perl libmongodb-perl
apt-get clean
EOF

RUN mkdir -pv /opt/pixelgecko
WORKDIR /opt/pixelgecko

ENTRYPOINT ["perl", "pixelgecko.pl", "--watch"]
