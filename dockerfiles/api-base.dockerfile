FROM ubuntu:jammy-20260210.1 AS builder
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends unzip
EOF
ADD --checksum=sha256:5b46c15340d0eb8cb10d9b110b455ca4c2719b58f394f6c892b6eae887b67f4a \
    https://github.com/mozilla/pdf.js/releases/download/v5.5.207/pdfjs-5.5.207-legacy-dist.zip \
    /pdfjs.zip
RUN unzip /pdfjs.zip -d /pdfjs
ADD https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.32.4.tar.gz /swagger
RUN tar -xzf /swagger

ADD --checksum=sha256:1b914059963acbfd5d3d344d9bc7b6370d10bb745d61c0a0b7015d1c990fcc0d \
    https://github.com/videojs/video.js/releases/download/v8.23.4/video-js-8.23.4.zip \
    /video-js.zip
RUN unzip /video-js.zip -d /video-js

ADD --checksum=sha256:9274bbcec8d96168626c732b5d31c775aa8cfb7eaa0599bec0c175908a2c1ce2 \
    https://raw.githubusercontent.com/mrdoob/three.js/r128/build/three.min.js \
    /threejs/three.min.js
ADD --checksum=sha256:02bb4ade710f3e607329e37a21f098bc3ac70eb6e33daf8a65e79f4db785e7b2 \
    https://raw.githubusercontent.com/mrdoob/three.js/r128/examples/js/controls/OrbitControls.js \
    /threejs/OrbitControls.js
ADD --checksum=sha256:5c15967ba830918a9caea6338712c994c354bccd4edc4569bde411c3ec06a3e6 \
    https://raw.githubusercontent.com/mrdoob/three.js/r128/examples/js/loaders/GLTFLoader.js \
    /threejs/GLTFLoader.js

ADD --checksum=sha256:6893d569e972ee621faebd884a54ca77357080fcf71ce234731d271ec712f3fc \
    https://cdn.jsdelivr.net/npm/replaywebpage@2.4.4/ui.js \
    /replayweb/ui.js
ADD --checksum=sha256:395b5b099c48f5e6cebdc4d64e85267e9a58e100c4cbb7869eddad62ec5ec081 \
    https://cdn.jsdelivr.net/npm/replaywebpage@2.4.4/sw.js \
    /replayweb/sw.js

ADD --checksum=sha256:43caefc0eb119c8152e573a028c78c8b8a0497da20055358104c273fe2b98eac \
    https://cdn.jsdelivr.net/npm/mirador@3.4.3/dist/mirador.min.js \
    /mirador/mirador.min.js
ADD --checksum=sha256:82467ff9dff8e95451472ff5c9d6206072b575748436af88585f5d26d4bdb8ab \
    https://cdn.jsdelivr.net/npm/mirador@3.4.3/dist/mirador.min.js.map \
    /mirador/mirador.min.js.map

ADD https://github.com/ruven/iipmooviewer/archive/86bfcc698c969ce290d7c4f5a586483458d1f752.tar.gz /iipmooviewer.tar.gz
RUN <<EOF
tar -xzf /iipmooviewer.tar.gz
rm -f /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/images/newAnnotation.png \
      /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/images/newAnnotation.svg
EOF

ADD --checksum=sha256:7080be17f847e0b358801c713e8db0c901ab07d7c3345098cc8b9476212dcecf \
    https://cdn.jsdelivr.net/npm/@3dweb/360javascriptviewer@1.8.56/lib/JavascriptViewer.js \
    /360viewer/JavascriptViewer.min.js

ADD https://github.com/cnr-isti-vclab/3DHOP/archive/refs/tags/4.3.tar.gz /3dhop.tar.gz
RUN tar -xzf /3dhop.tar.gz

ADD --checksum=sha256:bee3e9334ea86dd63e184598f31fb16750881c2da1a6f097a66e0f66a95b3d54 \
    https://github.com/googlefonts/roboto-3-classic/releases/download/v3.015/Roboto_v3.015.zip \
    /roboto.zip
RUN unzip /roboto.zip -d /roboto

ADD https://iptoasn.com/data/ip2country-v4.tsv.gz /ip2country/ip2country-v4.tsv.gz
ADD https://iptoasn.com/data/ip2country-v6.tsv.gz /ip2country/ip2country-v6.tsv.gz
RUN gunzip /ip2country/ip2country-v4.tsv.gz /ip2country/ip2country-v6.tsv.gz

FROM ubuntu:jammy-20260210.1
ENV DEBIAN_FRONTEND=noninteractive
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
    cpanminus build-essential \
    libnet-ldap-perl libio-socket-ssl-perl libsereal-perl libcrypt-cbc-perl libcrypt-urandom-perl \
    libmath-random-isaac-xs-perl libmime-lite-perl libswitch-perl liblog-log4perl-perl liblog-dispatch-filerotate-perl \
    liblwp-useragent-determined-perl libxml-writer-perl libxml-libxml-perl libxml-parser-perl libxml-xpath-perl \
    libsoap-lite-perl libdbd-mysql-perl libdata-messagepack-perl libdatetime-perl libdatetime-format-iso8601-perl \
    libclone-perl libmime-lite-perl libdbix-connector-perl libjson-perl libjson-validator-perl libcgi-pm-perl libxml-libxslt-perl \
    libcache-fastmmap-perl liblocale-maketext-lexicon-perl libyaml-syck-perl libmongodb-perl libmojolicious-perl \
    libmojo-jwt-perl libmojolicious-plugin-i18n-perl libmojolicious-plugin-authentication-perl git libtemplate-perl libhtml-formattext-withlinks-perl libmodule-build-tiny-perl libdbd-sqlite3-perl libtest-needs-perl libtest-memory-cycle-perl libtest-output-perl libtest-exception-perl libtest-warn-perl libfile-mimeinfo-perl libdatetime-format-mail-perl libjson-xs-perl \
    libnet-ip-perl libauthen-sasl-perl
apt-get clean
EOF
# run after installation of libjson-xs-perl,
# otherwise libcpanel-json-xs-perl will be chosen, which breaks api-create
RUN <<EOF
apt-get install --yes --quiet --no-install-recommends libchi-perl
apt-get clean
EOF
RUN <<EOF
cpanm -n Mojolicious::Plugin::Database Mojolicious::Plugin::Session \
      Mojolicious::Plugin::Log::Any Mojolicious::Plugin::CHI \
      Mojolicious::Plugin::Prometheus \
      IO::Scalar Crypt::Rijndael MIME::Base64 File::MimeInfo::Magic \
      XML::SAX XML::Parser::PerlSAX File::Find::utf8  MIME::Lite::TT::HTML Storable UNIVERSAL::require Mojo::IOLoop::Delay
EOF
# see https://github.com/tyldum/mojolicious-plugin-prometheus/pull/27
# this is not published on CPAN, so directly plug in the files. Not ideal, but works for now
ADD https://raw.githubusercontent.com/tyldum/mojolicious-plugin-prometheus/4e8d19f6564be45f8e7d92cd7d31aabd7a64989c/lib/Mojolicious/Plugin/Prometheus.pm /usr/local/share/perl/5.34.0/Mojolicious/Plugin/Prometheus.pm
ADD https://raw.githubusercontent.com/tyldum/mojolicious-plugin-prometheus/4e8d19f6564be45f8e7d92cd7d31aabd7a64989c/lib/Mojolicious/Plugin/Prometheus/Collector/Perl.pm /usr/local/share/perl/5.34.0/Mojolicious/Plugin/Prometheus/Collector/Perl.pm
# add perl s3 packages
RUN <<EOF
apt-get install --yes --quiet --no-install-recommends libnet-amazon-s3-perl
apt-get clean
EOF
ADD ../src/phaidra-api /usr/local/phaidra/phaidra-api
# add files from builder
COPY --from=builder /pdfjs /usr/local/phaidra/phaidra-api/public/pdfjs
COPY --from=builder /swagger-ui-5.32.4/dist/* /usr/local/phaidra/phaidra-api/public/swagger-ui/
COPY --from=builder /video-js/video.min.js /video-js/video-js.min.css /usr/local/phaidra/phaidra-api/public/video-js/
COPY --from=builder /threejs/three.min.js /threejs/OrbitControls.js /threejs/GLTFLoader.js /usr/local/phaidra/phaidra-api/public/threejs/build/
COPY --from=builder /replayweb/ui.js /replayweb/sw.js /usr/local/phaidra/phaidra-api/public/replayweb/
COPY --from=builder /mirador/mirador.min.js /mirador/mirador.min.js.map /usr/local/phaidra/phaidra-api/public/mirador/
COPY --from=builder \
    /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/js/iipmooviewer-2.0-min.js \
    /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/js/mootools-core-1.6.0-compressed.js \
    /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/css/iip.min.css \
    /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/src/annotations.js \
    /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/src/annotations-edit.js \
    /iipmooviewer-86bfcc698c969ce290d7c4f5a586483458d1f752/images/ \
    /usr/local/phaidra/phaidra-api/public/iipmooviewer/
COPY --from=builder /360viewer/JavascriptViewer.min.js /usr/local/phaidra/phaidra-api/public/360viewer/
COPY --from=builder /3DHOP-4.3/minimal/js /usr/local/phaidra/phaidra-api/public/3dhop/js
COPY --from=builder /3DHOP-4.3/minimal/skins /usr/local/phaidra/phaidra-api/public/3dhop/skins
COPY --from=builder /3DHOP-4.3/minimal/stylesheet /usr/local/phaidra/phaidra-api/public/3dhop/stylesheet
COPY --from=builder /roboto/web/static/Roboto-Light.ttf   /usr/local/phaidra/phaidra-api/public/fonts/roboto/roboto-300.ttf
COPY --from=builder /roboto/web/static/Roboto-Regular.ttf /usr/local/phaidra/phaidra-api/public/fonts/roboto/roboto-400.ttf
COPY --from=builder /roboto/web/static/Roboto-Medium.ttf  /usr/local/phaidra/phaidra-api/public/fonts/roboto/roboto-500.ttf
COPY --from=builder /ip2country/ip2country-v4.tsv /usr/local/phaidra/phaidra-api/public/ip2country/
COPY --from=builder /ip2country/ip2country-v6.tsv /usr/local/phaidra/phaidra-api/public/ip2country/
WORKDIR /usr/local/phaidra/phaidra-api/
EXPOSE 3000
ENTRYPOINT ["hypnotoad", "-f", "phaidra-api.cgi"]
