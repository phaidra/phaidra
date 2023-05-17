FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive
RUN touch /etc/default/iipsrv
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends \
    iipimage-server libapache2-mod-fcgid apache2 apache2-utils
apt-get clean
EOF
EXPOSE 80
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]