FROM ubuntu:jammy-20240627.1
ENV DEBIAN_FRONTEND=noninteractive
RUN touch /etc/default/iipsrv
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends \
    iipimage-server libapache2-mod-fcgid apache2 apache2-utils
apt-get clean
EOF
EXPOSE 80
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
