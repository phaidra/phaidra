![](https://gitlab.phaidra.org/phaidra-dev/phaidra-docker/badges/main/pipeline.svg?ignore_skipped=true)

___
![alt text](./pictures/running_phaidra.png "Screenshot of PHAIDRA landing page")*Running PHAIDRA website*
___

# About this repository

This repo hosts the source code and docker-compose files of the
[PHAIDRA](https://phaidra.org/) (Permanent Hosting, Archiving and
Indexing of Digital Resources and Assets) software, developed at the
[Vienna University Computer Center](https://zid.univie.ac.at/en/).

The aim of this project is to provide a high-quality, easy-to-set-up
web-based digital archiving system for academic institutions and other
organizations that need to provide a solution for long-term-archiving of
valuable data and metadata about the stored objects.

We provide various flavors for different use cases, from a demo version
running on a local desktop computer for evaluation, to an SSO-enabled
server version.

# Setup
For all versions you will need a recent [Docker
Installation](https://docs.docker.com/engine/install/), ideally on a
Linux distribution (PHAIDRA is mainly developed on Ubuntu and Debian).

Assuming you already have a running standard Docker installation you can either
continue that way, as it should not interfere with the code of this
repo.

However, we recommend using docker rootless to stay in sync with
this repo's documentation. There is extensive official [upstream
documentation](https://docs.docker.com/engine/security/rootless/) how to
do that.

See section [Docker Notes](#docker-notes) below to see what we do on a typical installation for running PHAIDRA on rootless containers.

# Run it

See the sections below for version-specific instructions.

## Demo Version

###  Demo specific prerequisites
None, just make sure no other service is using port 8899 on your
computer.

###  Demo Startup

After the following commands have finished, you will have a PHAIDRA
instance running on `http://localhost:8899`, that you can visit in
your browser.  See the screenshot below for what you can expect.

``` example
cd compose_demo
cp ../.env.template .env
# adjust variables  in .env if uid !=1000 or on rootful Docker -- see notes below.
docker compose up -d
```

**NOTE for users running unpriviledged Docker, but not with uid 1000:** Please change the environment variable `HOST_DOCKER_SOCKET` in the `.env` file to contain your actual (you can check with the command `id -u`).

**NOTE for users running priviledged Docker:** if running rootful  Docker, please change the environment variable `LOCAL_ADMIN_IP` in the `.env` file to "172.29.5.1" (Linux and Win11 Docker Desktop based on WSL), or "192.168.65.1" (Docker Desktop on OSX) and `HOST_DOCKER_SOCKET` to `/var/run/docker.sock` (all of the mentioned ones).


## SSL Version

###  SSL specific prerequisites

-   A DNS-entry for your computer's IP-address.
-   SSL-certificate and -key (put them into the
    `./container_init/httpd/phaidra-ssl/conf`-directory of this repo and name them
    `privkey.pem` and `fullchain.pem` -- **make sure your user has read access on these files**).
-   firewall with port 80 and 443 open on your computer.
-   properly set variables in `./compose_ssl/.env` (`PHAIDRA_HOSTNAME`, `PHAIDRA_HOST_IP`, [`REMOTE_ADMIN_IP`]).

###  SSL Startup

Change to the folder `./compose_ssl` and run compose. After the
setup has finished, PHAIDRA will run on
`https://$YOUR-DNS-ENTRY`.

``` example
cd compose_ssl
cp ../.env.template .env
# adjust variables  in .env if uid !=1000 or on rootful Docker -- see notes below.
# set proper values in '.env'
docker compose up -d
```

**NOTE for users running unpriviledged Docker, but not with uid 1000:** Please change the environment variable `HOST_DOCKER_SOCKET` in the `.env` file to contain your actual (you can check with the command `id -u`).

**NOTE for users running priviledged Docker:** if running rootful  Docker, please change the environment variable `LOCAL_ADMIN_IP` in the `.env` file to "172.29.5.1" (Linux and Win11 Docker Desktop based on WSL), or "192.168.65.1" (Docker Desktop on OSX) and `HOST_DOCKER_SOCKET` to `/var/run/docker.sock` (all of the mentioned ones).


## Shibboleth SSO Version

###  Shibboleth specific prerequisites

-   A DNS-entry for your computer's IP-address.
-   SSL-certificate and -key (put them into the
    `./container_init/httpd/phaidra-shib/conf`-directory of this repo and name them
    `privkey.pem` and `fullchain.pem` -- **make sure your user has read access on these files**).
-   firewall with port 80 and 443 open on your computer.
-   encryption and signing keys/certs for Shibboleth (plus the
    registration at your organization's IdP). You can create the
    required key/cert-pairs with the commands below (put the
    results into the `./container_init/httpd/phaidra-shib/conf` folder of this repo -- 
    **make sure your user has read access on these files**).
-   properly set variables in `./compose_shib/.env` (`PHAIDRA_HOSTNAME`, `PHAIDRA_HOST_IP`, [`REMOTE_ADMIN_IP`]).

``` example
openssl req -new -x509 -nodes -newkey rsa:2048 -keyout sp-encrypt-key.pem -days $DESIRED_VALIDITY_TIME -subj '/CN=$YOUR_FQDN' -out sp-encrypt-cert.pem
openssl req -new -x509 -nodes -newkey rsa:2048 -keyout sp-signing-key.pem -days $DESIRED_VALIDITY_TIME -subj '/CN=$YOUR_FQDN' -out sp-signing-cert.pem
```

###  Shibboleth Startup

Change to the folder `./compose_shib` and run compose. After the
setup has finished you will have PHAIDRA running on
`https://$YOUR-DNS-ENTRY`.

``` example
cd compose_shib
cp ../.env.template .env
# adjust variables  in .env if uid !=1000 or on rootful Docker -- see notes below.
# set proper values in '.env'
docker compose up -d
```
**NOTE for users running unpriviledged Docker, but not with uid 1000:** Please change the environment variable `HOST_DOCKER_SOCKET` in the `.env` file to contain your actual (you can check with the command `id -u`).

**NOTE for users running priviledged Docker:** if running rootful  Docker, please change the environment variable `LOCAL_ADMIN_IP` in the `.env` file to "172.29.5.1" (Linux and Win11 Docker Desktop based on WSL), or "192.168.65.1" (Docker Desktop on OSX) and `HOST_DOCKER_SOCKET` to `/var/run/docker.sock` (all of the mentioned ones).

# Default credentials on administration sites
- **LDAP Account Manager** (from the Webinterface: Manage Phaidra -> Manage Users):
  - password: `adminpassword`.
  This password can be altered in the `.env` file located next through the `LDAP_ADMIN_PASSWORD` variable.
    - There are three default users built in for testing purposes (logging into Phaidra, uploading, etc) `pone`, `ptwo`, and `barchiver`.  They all share the same password `1234`.
    - These users can be accessed/altered/deleted from **LDAP Account manager**.
- **Fedora** (from the Webinterface: Manage Phaidra -> Inspect Object Repository):
  - username: `fedoraAdmin`
  - password: `1234`
  - These credentials can be altered in the `.env` file through the variables `FEDORA_ADMIN_USER` and `FEDORA_ADMIN_PASS`.
- **Grafana** (Manage Phaidra -> Inspect Running Services):
  - username: `phaidra`
  - password: `phaidra`
  - These credentials can be altered in the `.env` file through the variables `GF_SECURITY_ADMIN_USER` and `GF_SECURITY_ADMIN_PASS`.
- **DbGate** (Manage Phaidra -> Inspect Databases)
  - username: `phaidra`
  - password: `phaidra`
  - Here only the password can be modified in the `.env` file through the variable `DBGATE_PASS`.  If you want to change the username as well, please change it in the `docker-compose.yaml` file in the `dbgate:` section.  The corresponding variable is called `LOGINS`. You will have to put the username into the variable in the next line `LOGIN_PASSWORD_[username]` as well, that's why we can't centrally manage this from `.env` for now.
- **Solr** (Manage Phaidra -> Inspect Search Engine)
  - username: `phaidra`
  - password: `phaidra`
  - These credentials can be modified in the `.env` file through the variables `SOLR_USER` and `SOLR_PASS`.

# Monitoring PHAIDRA

___
![alt text](./pictures/dashboard.png "Screenshot of PHAIDRA Grafana Dashboard")*Monitoring Dashboard*
___

There is a Grafana dashboard at `http://localhost:8899/grafana`, respectively `https://YOUR_FQDN/grafana`, that displays the containers' system usage and their logs.

One can also use the following shell command to monitor the system usage
of PHAIDRA over all containers from the machine where it is running (here from an instance started from
`./compose_demo`):

``` example
# COMMAND:
docker stats
# EXPECTED OUTPUT:
CONTAINER ID   NAME                             CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
2bb9181196e3   phaidra-demo-httpd-1             0.01%     21.17MiB / 15.03GiB   0.14%     992B / 0B         86kB / 0B         83
d5c8257aa717   phaidra-demo-ui-1                18.34%    99.45MiB / 15.03GiB   0.65%     293kB / 2.99kB    0B / 0B           23
c299d72a9014   phaidra-demo-pixelgecko-1        0.00%     51.57MiB / 15.03GiB   0.34%     10.8kB / 16kB     0B / 0B           1
e93244f3ba88   phaidra-demo-api-1               0.02%     165.1MiB / 15.03GiB   1.07%     1.1kB / 0B        0B / 0B           6
27e17164d2fb   phaidra-demo-promtail-local-1    0.43%     35.2MiB / 15.03GiB    0.23%     2.35kB / 23.7kB   0B / 0B           13
6f0be828c7fa   phaidra-demo-dbgate-1            0.00%     24.66MiB / 15.03GiB   0.16%     1.55kB / 224B     0B / 4.1kB        11
7447d44812fd   phaidra-demo-chronos-1           0.01%     4.066MiB / 15.03GiB   0.03%     1.14kB / 0B       0B / 0B           3
6ca74551692f   phaidra-demo-fedora-1            0.61%     663.8MiB / 15.03GiB   4.31%     17.9kB / 15.2kB   430kB / 53.2kB    61
b90acb3c2ed4   phaidra-demo-grafana-1           0.12%     103.7MiB / 15.03GiB   0.67%     12.2kB / 2.29kB   1.2MB / 471kB     16
2ab547cb9044   phaidra-demo-lam-1               0.00%     22.41MiB / 15.03GiB   0.15%     1.1kB / 0B        0B / 0B           8
5327ab50d22d   phaidra-demo-mongodb-phaidra-1   0.33%     171.2MiB / 15.03GiB   1.11%     17.6kB / 9.73kB   1.79MB / 213kB    32
98a46ef375a5   phaidra-demo-loki-1              0.35%     33.71MiB / 15.03GiB   0.22%     25.2kB / 1.29kB   3.77MB / 53.2kB   13
53af68cacba3   phaidra-demo-mariadb-phaidra-1   0.01%     197.7MiB / 15.03GiB   1.28%     1.47kB / 0B       16.5MB / 8.19kB   25
6330011bf5b3   phaidra-demo-solr-1              0.82%     724.3MiB / 15.03GiB   4.71%     1.36kB / 0B       1.41MB / 168kB    55
684d95cc0ac4   phaidra-demo-mariadb-fedora-1    0.02%     100.1MiB / 15.03GiB   0.65%     16.7kB / 16.5kB   26.3MB / 8.19kB   36
469f52362bf8   phaidra-demo-openldap-1          0.00%     12.5MiB / 15.03GiB    0.08%     1.36kB / 0B       614kB / 0B        2
2fed9080a1a8   phaidra-demo-cadvisor-1          3.48%     47.25MiB / 15.03GiB   0.31%     5.48kB / 271kB    0B / 0B           15
43c851042af1   phaidra-demo-prometheus-1        0.07%     225.4MiB / 15.03GiB   1.46%     291kB / 5.64kB    98.3MB / 29.2MB   14
c186e3959156   phaidra-demo-imageserver-1       0.01%     25.73MiB / 15.03GiB   0.17%     1.56kB / 0B       0B / 0B           57
e875a9d3e4e8   phaidra-demo-node-exporter-1     0.00%     8.68MiB / 15.03GiB    0.06%     2.12kB / 13.9kB   0B / 0B           6
```

# Data persistance

`docker compose up -d` will create directories in
`$HOME/.local/share/docker/volumes` (`/var/lib/docker/volumes` in case you run rootful docker) to persist data created by PHAIDRA
over docker restarts or whole system reboots.  These directories are the ones that need to be backupped to prevent data loss in case 
of hardware failure.

Depending on the PHAIDRA version you set up, the volumes will be prefixed differently (`phaidra-demo`, `phaidra-ssl`, `phaidra-shib`).

See the section [Graphical System overview](#graphical-system-overview) for how these directories are connected to the containers.

# Uninstalling

If you want to uninstall PHAIDRA from your computer, this can be done very easy. See the commands below to reset your system
to a 'clean slate'.

## Shut down running PHAIDRA
In case you have an instance running, make sure to shut it down using the following command (from `./compose_demo`, `./compose_ssl`, or `compose_shib`, depending on your installation -- here shown from `./compose_demo`):

``` example
# COMMAND:
docker compose down
# EXPECTED OUTPUT:
[+] Running 21/21
 ✔ Container phaidra-demo-httpd-1            Removed                                                                                                                                                         10.5s 
 ✔ Container phaidra-demo-promtail-local-1   Removed                                                                                                                                                          0.5s 
 ✔ Container phaidra-demo-chronos-1          Removed                                                                                                                                                         10.3s 
 ✔ Container phaidra-demo-imageserver-1      Removed                                                                                                                                                         10.4s 
 ✔ Container phaidra-demo-node-exporter-1    Removed                                                                                                                                                          0.4s 
 ✔ Container phaidra-demo-pixelgecko-1       Removed                                                                                                                                                         10.3s 
 ✔ Container phaidra-demo-lam-1              Removed                                                                                                                                                          0.5s 
 ✔ Container phaidra-demo-prometheus-1       Removed                                                                                                                                                          0.6s 
 ✔ Container phaidra-demo-cadvisor-1         Removed                                                                                                                                                          0.4s 
 ✔ Container phaidra-demo-openldap-1         Removed                                                                                                                                                          0.2s 
 ✔ Container phaidra-demo-grafana-1          Removed                                                                                                                                                          0.2s 
 ✔ Container phaidra-demo-ui-1               Removed                                                                                                                                                          0.7s 
 ✔ Container phaidra-demo-solr-1             Removed                                                                                                                                                         10.2s 
 ✔ Container phaidra-demo-dbgate-1           Removed                                                                                                                                                          0.3s 
 ✔ Container phaidra-demo-loki-1             Removed                                                                                                                                                          1.7s 
 ✔ Container phaidra-demo-api-1              Removed                                                                                                                                                         10.2s 
 ✔ Container phaidra-demo-fedora-1           Removed                                                                                                                                                          0.4s 
 ✔ Container phaidra-demo-mongodb-phaidra-1  Removed                                                                                                                                                          0.3s 
 ✔ Container phaidra-demo-mariadb-phaidra-1  Removed                                                                                                                                                          0.4s 
 ✔ Container phaidra-demo-mariadb-fedora-1   Removed                                                                                                                                                          0.4s 
 ✔ Network phaidra-demo_phaidra-network      Removed                                                                                                                                                          0.3s 
```

## Remove persisted data
The following command will remove the volumes (aka directories under `$HOME/.local/share/docker/volumes`) associated with your PHAIDRA installation.  As mentioned above, replace `phaidra-demo` with `phaidra-ssl` or `phaidra-shib`, depending on your installation. This command can be run from anywhere.

```
# COMMAND:
docker volume rm $(docker volume ls --filter label=com.docker.compose.project=phaidra-demo --quiet)
# EXPECTED OUTPUT:
phaidra-demo_chronos-database-dumps
phaidra-demo_chronos-oai-logs
phaidra-demo_chronos-sitemaps
phaidra-demo_dbgate
phaidra-demo_fedora
phaidra-demo_grafana
phaidra-demo_loki
phaidra-demo_mariadb_fedora
phaidra-demo_mariadb_phaidra
phaidra-demo_mongodb_phaidra
phaidra-demo_openldap
phaidra-demo_pixelgecko
phaidra-demo_prometheus
phaidra-demo_solr
```

## Remove docker images built by compose
The following command will remove the docker images associated with your PHAIDRA installation.  As mentioned above, replace `phaidra-demo` with `phaidra-ssl` or `phaidra-shib`, depending on your installation. This command can be run from anywhere.

```
# COMMAND:
docker image rm $(docker image ls --filter label=com.docker.compose.project=phaidra-demo --quiet)
# EXPECTED OUTPUT (hashes are matter of change):

docker image rm $(docker image ls --filter label=com.docker.compose.project=phaidra-demo --quiet)
Untagged: phaidra-demo-ui:latest
Deleted: sha256:473336b19091df7aec4e549ae0f41ba7cea0147a08e86e335cebe64e88f16812
```
## Clean up Docker caches
In case you are developing and changing  a lot of components, dockerfiles and docker-compose files, 
things can become cluttered. To remove everything including build caches, you can run 
 the following command:
```
# COMMAND:
docker system prune --filter label=com.docker.compose.project=phaidra-demo
# EXPECTED OUTPUT (hashes are matter of change):
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

  Items to be pruned will be filtered with:
  - label=com.docker.compose.project=phaidra-demo

Are you sure you want to continue? [y/N] y
Deleted build cache objects:
sdl2d1br7kafdbimje1mvnmcm
0y4fc4chlvvlf9ympvbi3h37j
lx580e9zlrrs6dzfw1247d7x4
p81oaunxrw4de8mpp3oia27f3
45oaxmp0r7pngo84iya3igpym
hqtg1tvrqmjeuvdokuma5p1y4
kszrbhbfsfvagcx54mekzw4j4
nm2hc7xeptjojpek1256mwlvp
xdvgebzum8wnrsbj0poyndj3v
lzrhk1629jdlntkb4pvlw1clh
5vkh6rj8yc31r5gne4mkc3wgu
y5c1jjawslm4ssyhjdqf12ibu
1uyu18l6pgkiqsyajaz6vqz2g
1rnbo6rxc6wodh80sd68r93ld
ne83pvp97gqd4oauva00yb66m
s9dhiz747swweozuud6btaj9u
uaud8ag4o9a8kawgwuk8pmpha
v0euks58k48gzj6mrpv05ccbu
mm5wynaaa2uisxf5wz07p5bgr
zi08c1l51g875skbamva4apj1
9v4skh7wvq8sykhmdrbfbcdwn
rwxb4dfywim5ei5jakwbndxff
20i064t10ggfwza36tpeaa3wx
8ovjkuagpwkrf76rqfpsyfs4w
u1k2n1xunxiuuan7prr0vcnka
mfv3xb4m680254nhkjx9qdvbv
87ct1aqauu50a1n6ez7sci4n7
psboew29ukh1tlvl97k910v6j
wswvaob7jw2m5nlm5ssafg0w0
mqqwviao74tl6m8l36imbde38
s0ffaz2qle584dvfruk3394mg
rxk1j3outxlzl1stamnlcm7b7
y6yvejbejixa1eiwb39ycd69y
rzhy1frfe4sfo5u78t725zip5

Total reclaimed space: 1.878GB
```

# Technical Notes
## Graphical System Overview
###  PHAIDRA Demo
System when running `docker compose up -d` from directory
`./compose_demo` (Phaidra available on `http://localhost:8899`, see
section [Demo specific prerequisites](#demo-specific-prerequisites)).

![](./pictures/construction_demo.svg)

###  PHAIDRA SSL
System when running `docker compose up -d` from directory
`./compose_ssl` (Phaidra available on `https://$YOUR_FQDN`, see
section [SSL specific prerequisites](#ssl-specific-prerequisites)).

![](./pictures/construction_ssl.svg)

###  PHAIDRA Shibboleth
System when running `docker compose up -d` from directory
`./compose_shib` (Phaidra available on `https://$YOUR_FQDN`, see
section [Shibboleth specific prerequisites](#shibboleth-specific-prerequisites)).

![](./pictures/construction_shib.svg)

## Directory structure of this repository

``` example
.
├── compose_demo
├── compose_shib
├── compose_ssl
├── container_init
│   ├── api
│   ├── chronos
│   ├── grafana
│   ├── httpd
│   ├── loki
│   ├── mariadb
│   ├── mongodb
│   ├── openldap
│   ├── promtail
│   ├── solr
│   └── vige
├── dockerfiles
├── docs
├── pictures
├── src
│   ├── phaidra-api
│   ├── phaidra-ui
│   ├── phaidra-vue-components
│   ├── pixelgecko
│   └── vige
└── third-parties

26 directories
```

## Phaidra Components

In the folder `./components` one will find `phaidra-api`, `phaidra-ui`,
and `phaidra-vue-components`, and `pixelgecko`, the core components of PHAIDRA.
See the notes in the following subsections for provenance.

### phaidra-api

This directory derives from commit c880c4159c5d68b25426451f4822f744a53ef680 of
the repo at <https://github.com/phaidra/phaidra-api> (symlinks and
git history stripped).

### phaidra-ui

This directory derives from commit 5c9455373d36f4756e9caa2af989fac4dbd28f9f of
the repo at <https://github.com/phaidra/phaidra-ui> (symlinks and
git history stripped).

### phaidra-vue-components

This directory derives from commit 64f8b9870a0bc66a6b4a58fec5dfe6c2431e72d7 of
the repo at <https://github.com/phaidra/phaidra-vue-components.git> (git history stripped).

### pixelgecko

This directory derives from commit be0af173eaac297289fa51843b69327f7c95242c of the repo at
<https://gitlab.phaidra.org/phaidra-dev/pixelgecko> (git history stripped).

## Software in use

[PHAIDRA](https://phaidra.org/) is based on the shoulders of the
following great pieces of software (in alphabetical order):

-   [Apache HTTP server](https://httpd.apache.org/)
-   [Apache Solr](https://solr.apache.org/)
-   [DbGate](https://dbgate.org/)
-   [Debian](https://www.debian.org/)
-   [Docker](https://www.docker.com/)
-   [LDAP Account Manager](https://www.ldap-account-manager.org/lamcms/)
-   [Lyrasis Fedora](https://fedora.lyrasis.org/)
-   [MariaDB](https://mariadb.org/)
-   [MongoDB](https://www.mongodb.com/)
-   [OpenLDAP](https://www.openldap.org/)
-   [Perl](https://www.perl.org/)
-   [Shibboleth](https://www.shibboleth.net/)
-   [Ubuntu](https://ubuntu.com/)
-   [Vue.js](https://vuejs.org/)


## Docker Notes
Below you see what we use at the time of writing (Fri Sep 15 01:18:31 PM
CEST 2023):

``` bash
docker version
```

``` example
Client: Docker Engine - Community
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:08:17 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:08:17 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.24
  GitCommit:        61f9fd88f79f081d64d6fa3bb1a0dc71ec870523
 runc:
  Version:          1.1.9
  GitCommit:        v1.1.9-0-gccaecfc
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
 rootlesskit:
  Version:          1.1.1
  ApiVersion:       1.1.1
  NetworkDriver:    slirp4netns
  PortDriver:       slirp4netns
  StateDir:         /tmp/rootlesskit1246533479
 slirp4netns:
  Version:          1.2.0
  GitCommit:        656041d45cfca7a4176f6b7eed9e4fe6c11e8383
```

``` bash
docker info
```

``` example
Client: Docker Engine - Community
 Version:    24.0.7
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.11.2
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.21.0
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 1
  Running: 0
  Paused: 0
  Stopped: 1
 Images: 26
 Server Version: 24.0.7
 Storage Driver: fuse-overlayfs
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 61f9fd88f79f081d64d6fa3bb1a0dc71ec870523
 runc version: v1.1.9-0-gccaecfc
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  rootless
  cgroupns
 Kernel Version: 6.1.0-13-amd64
 Operating System: Debian GNU/Linux 12 (bookworm)
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 15.03GiB
 Name: pcherzigd64
 ID: 4d080886-f0a3-4478-bac7-ebadf0ccfd68
 Docker Root Dir: /home/daniel/.local/share/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
```

As one can see above, we are using Docker's rootlesskit, to avoid
uneccessary privileges for the dockerized components. This also means,
that the user starting up the program does not need root/admin
privileges on the machine running PHAIDRA.

Nevertheless, setting up Docker itself will need a system admin user.
Below we describe the steps that we use for rootless Docker with
priviledged ports and (needed for http and https traffic on the
SSL-enabled versions) and client-IP forwarding (needed for restricting
access to parts of the system).

### set up rootlesskit

1.  turn off running priviledged docker service

``` example
sudo systemctl disable --now docker.service docker.socket
sudo reboot
```

2.  install uidmap package

    The `uidmap` package is available in both ubuntu and Debian official
    repositories and is needed for Docker's rootlesskit to properly
    function.

``` example
sudo apt install uidmap
```

3.  install rootlesskit

``` example
echo "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock" >> ~/.bashrc
echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bashrc
source ~/.bashrc
dockerd-rootless-setuptool.sh install
# activate autostart of services
sudo loginctl enable-linger $USER
```

4.  change port-forwarding mode for rootlesskit to slirp4netns

    In order to receive the original client IPs accessing the webserver,
    we change the port-forwarding mode of the rootlesskit (the default
    one drops IPs and nginx/apache only receive the docker
    network-bridge address, which does not allow for IP-filtering
    administrative parts of the system as a consequence).

``` example
mkdir -p ~/.config/systemd/user/docker.service.d
echo "[Service]" >> ~/.config/systemd/user/docker.service.d/override.conf
echo 'Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER=slirp4netns"' >> ~/.config/systemd/user/docker.service.d/override.conf
systemctl --user daemon-reload
systemctl --user restart docker
```

5.  allow priviledged ports for slirp4netns

    To allow opening ports 80 and 443 for unpriviledged slirp4netns we
    need to dedicately allow it (setcap will not work for this):

``` example
echo "net.ipv4.ip_unprivileged_port_start=0" | sudo tee /etc/sysctl.d/99-rootless.conf
sudo sysctl --system
```

6.  add cpuset support

    By default docker cpuset limitations are not enabled for rootless
    configurations. One can do the following to change this. (see:
    <https://docs.docker.com/engine/security/rootless/#limiting-resources>)

``` example
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers
cpu memory pids
sudo su -
mkdir -p /etc/systemd/system/user@.service.d
cat > /etc/systemd/system/user@.service.d/delegate.conf << EOF
> [Service]
> Delegate=cpu cpuset io memory pids
> EOF
systemctl daemon-reload
exit
cat /sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers
cpuset cpu io memory pids
systemctl --user restart docker
```

7.  activate br_netfilter kernel module
    
    You might run into the issue, that docker version warns about `WARNING: bridge-nf-call-iptables is disabled` and 
    `WARNING: bridge-nf-call-ip6tables is disabled`. You can get rid of this warning by running `sudo modprobe br_netfilter`.
    To make this change persistent on systemd-enabled systems (here tested on Debian-12), you can run the following command:
    ```
    echo "br_netfilter" | sudo tee -a /etc/modules-load.d/br_netfilter.conf
    ```
8. configure prometheus monitorability
   
   To activate the docker metrics endpoint, create the file `~/.config/docker/daemon.json` and add the following:
   
   ```
   {
     "metrics-addr": "0.0.0.0:9323"
   }
   ```
   
   Also, add the following line to `~/.config/systemd/user/docker.service.d/override.conf`:
   
   ```
   Environment=DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="-p 0.0.0.0:9323:9323/tcp"
   ```
   
   Then, run the following, to apply the changes:
   
   ```
   systemctl --user daemon-reload
   systemctl --user restart docker.service
   ```

