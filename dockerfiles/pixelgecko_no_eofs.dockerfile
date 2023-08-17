FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --yes --quiet --no-install-recommends \
    libvips-tools libyaml-syck-perl libmongodb-perl
RUN apt-get clean

ADD ./../components/pixelgecko /opt/pixelgecko
COPY ./../image_components/pixelgecko/pixelgecko.yml /etc/

WORKDIR /opt/pixelgecko
ENTRYPOINT ["perl", "pixelgecko.pl", "--watch"]
