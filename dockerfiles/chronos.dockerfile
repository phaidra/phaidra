FROM ubuntu:jammy-20231211.1
ENV DEBIAN_FRONTEND noninteractive
RUN <<EOF
apt-get --quiet update
apt-get install --yes --quiet --no-install-recommends\
    mariadb-client cron libtemplate-perl libmojolicious-perl liblog-log4perl-perl \
    liblog-dispatch-filerotate-perl libmongodb-perl libdatetime-format-iso8601-perl wget
EOF
RUN <<EOF
CURRENT_ARCHITECTURE=$(dpkg --print-architecture)
if [[ $CURRENT_ARCHITECTURE == "amd64" ]]
then
wget -q https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-x86_64-100.9.4.deb
apt install --yes mongodb-database-tools-ubuntu2204-x86_64-100.9.4.deb
rm mongodb-database-tools-ubuntu2204-x86_64-100.9.4.deb
fi
if [[ $CURRENT_ARCHITECTURE == "arm64" ]]
then
wget -q https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2204-arm64-100.9.4.deb
apt install --yes mongodb-database-tools-ubuntu2204-arm64-100.9.4.deb
rm mongodb-database-tools-ubuntu2204-arm64-100.9.4.deb
fi
EOF
