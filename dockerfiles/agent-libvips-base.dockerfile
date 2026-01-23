FROM ubuntu:jammy-20251001
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
libcgif-dev \
build-essential \
meson \
ninja-build \
file \
python3-pip \
bc \
wget \
libfftw3-dev \
libopenexr-dev \
libgsf-1-dev \
libglib2.0-dev \
liborc-dev \
libopenslide-dev \
libmatio-dev \
libwebp-dev \
libjpeg-turbo8-dev \
libexpat1-dev \
libexif-dev \
libtiff5-dev \
libcfitsio-dev \
libpoppler-glib-dev \
librsvg2-dev \
libpango1.0-dev \
libopenjp2-7-dev \
liblcms2-dev \
libimagequant-dev \
curl ca-certificates \
imagemagick libyaml-syck-perl libmongodb-perl libnet-amazon-s3-perl
apt-get clean
EOF


RUN curl -L -o /tmp/vips.tar.gz https://github.com/libvips/libvips/archive/refs/tags/v8.18.0.tar.gz \
 && cd /tmp \
 && tar xzf vips.tar.gz \
 && cd libvips-8.18.0 \
 && meson setup build --buildtype=release --prefix=/usr \
 && cd build \
 && meson compile \
 && meson test \
 && meson install \
 && ldconfig \
 && cd / \
 && rm -rf /tmp/libvips-8.18.0 /tmp/vips.tar.gz


RUN mkdir -pv /opt/agent-libvips
WORKDIR /opt/agent-libvips
ENTRYPOINT ["perl", "agent-libvips.pl", "--watch"]
