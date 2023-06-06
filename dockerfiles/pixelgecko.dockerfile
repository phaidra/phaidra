FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends \
libvips-tools
apt-get clean
EOF
ADD ./../components/pixelgecko /usr/local/pixelgecko
WORKDIR /usr/local/pixelgecko
