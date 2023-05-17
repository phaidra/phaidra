FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends \
    cpanminus build-essential \
    libnet-ldap-perl libio-socket-ssl-perl libsereal-perl libcrypt-cbc-perl libcrypt-urandom-perl \
    libmath-random-isaac-xs-perl libmime-lite-perl libswitch-perl liblog-log4perl-perl liblog-dispatch-filerotate-perl \
    liblwp-useragent-determined-perl libxml-writer-perl libxml-libxml-perl libxml-parser-perl libxml-xpath-perl \
    libsoap-lite-perl libdbd-mysql-perl libdata-messagepack-perl libdatetime-perl libdatetime-format-iso8601-perl \
    libclone-perl libmime-lite-perl libdbix-connector-perl libjson-perl libcgi-pm-perl libxml-libxslt-perl \
    libcache-fastmmap-perl liblocale-maketext-lexicon-perl libyaml-syck-perl libmongodb-perl libmojolicious-perl \
    libmojolicious-plugin-i18n-perl libmojolicious-plugin-authentication-perl git
apt-get clean
EOF
RUN <<EOF
cpanm Mojolicious::Plugin::Database Mojolicious::Plugin::Session Mojolicious::Plugin::CHI \
      Mojolicious::Plugin::Log::Any Mojolicious::Plugin::Prometheus \
      IO::Scalar Crypt::Rijndael MIME::Base64 File::MimeInfo::Magic \
      XML::SAX XML::Parser::PerlSAX File::Find::utf8  MIME::Lite::TT::HTML Storable UNIVERSAL::require
EOF
RUN <<EOF
yes | cpanm --uninstall Cpanel::JSON::XS
EOF
RUN <<EOF
cpanm Mojo::IOLoop::Delay
EOF
RUN mkdir -pv /usr/local/phaidra
RUN mkdir -pv /var/log/phaidra
COPY ./../configs/phaidra-api/phaidra.yml /etc/
WORKDIR /usr/local/phaidra/
ARG CACHEBUST=1
RUN git clone https://github.com/phaidra/phaidra-api.git
COPY ./../configs/phaidra-api/PhaidraAPI.json /usr/local/phaidra/phaidra-api/
RUN unlink /usr/local/phaidra/phaidra-api/log4perl.conf
COPY ./../configs/phaidra-api/log4perl.conf /usr/local/phaidra/phaidra-api/
WORKDIR /usr/local/phaidra/phaidra-api/
RUN git checkout 1223fccbdd2c2f717f0d9d388a006cb194f21a31
EXPOSE 3000
ENTRYPOINT ["hypnotoad", "-f", "phaidra-api.cgi"]