FROM ubuntu:jammy-20240627.1
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
cpanm Mojolicious::Plugin::Database Mojolicious::Plugin::Session \
      Mojolicious::Plugin::Log::Any Mojolicious::Plugin::CHI \
      IO::Scalar Crypt::Rijndael MIME::Base64 File::MimeInfo::Magic \
      XML::SAX XML::Parser::PerlSAX File::Find::utf8  MIME::Lite::TT::HTML Storable UNIVERSAL::require Mojo::IOLoop::Delay
EOF
# add perl s3 packages
RUN <<EOF
apt-get install --yes --quiet --no-install-recommends libnet-amazon-s3-perl
apt-get clean
EOF
WORKDIR /usr/local/phaidra/phaidra-api/
EXPOSE 3000
ENTRYPOINT ["hypnotoad", "-f", "phaidra-api.cgi"]
