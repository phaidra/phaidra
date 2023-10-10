FROM debian:bullseye-20230919
ENV DEBIAN_FRONTEND noninteractive
RUN <<EOF
apt-get update
apt-get install --yes --quiet --no-install-recommends\
    mariadb-client cron
EOF
COPY ./../third-parties/mongodb-database-tools-debian11-x86_64-100.8.0.tgz /
RUN <<EOF
tar xf mongodb-database-tools-debian11-x86_64-100.8.0.tgz \
    --directory /usr/local/bin/ \
    --strip=2 \
    mongodb-database-tools-debian11-x86_64-100.8.0/bin/mongodump
rm mongodb-database-tools-debian11-x86_64-100.8.0.tgz
EOF
CMD ["/bin/bash"]
