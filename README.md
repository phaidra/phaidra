![](https://gitlab.phaidra.org/phaidra-dev/phaidra-docker/badges/main/pipeline.svg?ignore_skipped=true)

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
___
![alt text](./pictures/running_phaidra.png "Screenshot of PHAIDRA landing page")*Running PHAIDRA website*
___

# About this repository

This repo hosts the source code and the docker-compose startup file of the
[PHAIDRA](https://phaidra.org/) (Permanent Hosting, Archiving and
Indexing of Digital Resources and Assets) software, developed at the
[Vienna University Computer Center](https://zid.univie.ac.at/en/).

The aim of this project is to provide a high-quality, easy-to-set-up
web-based digital archiving system for academic institutions and other
organizations that need to provide a solution for long-term-archiving of
valuable data and metadata about the stored objects.

We provide various flavors for different use cases, from a demo version
running on a local desktop computer for evaluation, to an shibboleth-enabled
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

# Docker compose profiles

We are using docker profiles to start up the relevant containers for the desired use case.

We highly recommend to use the `--project-name $PROJECT_NAME_OF_YOUR_LIKING` flag to the `docker compose` command, as this will allow you to easily identify the persistant docker volumes which will be created to store your valuable data.

## Profiles using versioned images including all code

+ `demo-local`: for an evaluation installation, serving PHAIDRA on `http://localhost:8899`. Uses only local storage.
+ `demo-s3`: for an evaluation installation, serving PHAIDRA on `http://localhost:8899`. Uses an S3-bucket for the object repository and images converted to the format supported by IIPImage.
+ `ssl-local`: for broadcasting/production use, serving PHAIDRA on `https://$YOURDOMAIN`. Uses only local storage.
+ `ssl-s3`: for broadcasting/production use, serving PHAIDRA on `https://$YOURDOMAIN`. Uses an S3-bucket for the object repository and images converted to the format supported by IIPImage.
+ `shib-local`: for broadcasting/production use, serving PHAIDRA on `https://$YOURDOMAIN`. Uses only local storage.  Uses an external shibboleth-idp for authentication.
+ `shib-s3`: for broadcasting/production use, serving PHAIDRA on `https://$YOURDOMAIN`. Uses an S3-bucket for the object repository and images converted to the format supported by IIPImage.  Uses an external shibboleth-idp for authentication.

## Profiles bindmounting the repository's code

+ `demo-local-dev`: see above.
+ `demo-s3-dev`: see above.
+ `ssl-local-dev`: see above.
+ `ssl-s3-dev`: see above.
+ `shib-local-dev`: see above.
+ `shib-s3-dev`: see above.

## Extra profiles
### Standalone
+ `website`: For convenient development of our website at [www.phaidra.org](https://www.phaidra.org).
### Add-On
+ `external-opencast`: can be added to any of the profiles that use local storage, if an external opencast-streaming-server is available to you. Uses a versioned image including all code.
+ `external-opencast-dev`: can be added to any of the dev-profiles that use local storage, if an external opencast-streaming-server is available to you. Uses bindmounted code from the repository.


# Run it
All default values assume that you are running docker rootless as the first non-root user with uid 1000 on your linux computer.  This is what we strongly recommend.  However, if this does not match your reality, please check the following options:
## Linux user on docker rootless, but not uid 1000
+ Please set the variable `HOST_DOCKER_SOCKET` to `/run/user/$YOUR-UID/docker.sock` in an `.env` file.  You can get your uid quickly by running `id -u`.
## Users running priviledged ('normal') docker (Linux and Windows Docker based on wsl2)
+ Please set the variable `ADMIN_IP_LIST` to `172.29.5.1` in an `.env` file for the demo/localhost version. This is to reach the admin area. For ssl/shib see below.
+ Please set the variable `HOST_DOCKER_SOCKET` to `/var/run/docker.sock` in an `.env` file. This is to get proper service monitoring.
## Users running priviledged ('normal') docker (OSX)
+ Please set the variable `ADMIN_IP_LIST` to `192.168.65.1` in an `.env` file for the demo/localhost version. This is to reach the admin area. For ssl/shib see below.
+ Please set the variable `HOST_DOCKER_SOCKET` to `/var/run/docker.sock` in an `.env` file. This is to get proper service monitoring.

## Demo version with local storage
###  Prerequisites
+ make sure no other service is using port 8899 on your computer.

### Startup
Run the following command to get PHAIDRA running on `http://localhost:8899`:

```
docker compose --project-name $PROJECT_NAME_OF_YOUR_LIKING --profile demo-local up -d
```

## Demo version with S3 storage
### Prerequisites
+ make sure no other service is using port 8899 on your computer.
+ set the following variables in your `.env` file:
  + `S3_ACCESS_KEY`
  + `S3_SECRET_KEY`
  + `S3_BUCKETNAME`
  + `S3_CACHESIZE`: in Bytes, defaults to 100000000 (100MB).
  + `S3_REGION`

### Startup
Run the following command to get PHAIDRA running on `http://localhost:8899`:

```
docker compose --project-name $PROJECT_NAME_OF_YOUR_LIKING --profile demo-s3 up -d
```

## SSL version with local storage
###  Prerequisites
+ make sure no other service is using ports 80 and 443 on your computer.
+ a DNS-entry pointing to your computer's IP-address.
+ SSL-certificate and -key (put them into the `certs/httpd` and name them `privkey.pem` and `fullchain.pem` -- **make sure your user has read access on these files**).  Certificates acquired from the [certbot tool](https://certbot.eff.org/) should do the job as they contain the full chain of certificates.
+ firewall with port 80 and 443 open on your computer.
+ set the following variables in your `.env` file:
  + `ADMIN_IP_LIST`: List of space-delimited IP addresses that should be allowed to reach the admin area. This includes the static IP address of your computer, if you access the installation through your local browser. If you access your installation from localhost by modifying `/etc/hosts` you will want to keep the gateway address in there as well (10.0.2.2 [default] for rootless docker on Linux, 172.29.5.1 for priviledged docker on Linux or Windows,  192.168.65.1 for priviledged docker on OSX).
  + `OUTSIDE_HTTP_SCHEME="https"`
  + `PHAIDRA_HOSTPORT=""`
  + `PHAIDRA_PORTSTUB=""`
  + `PHAIDRA_HOSTNAME="$YOUR-FQDN"`

###  Startup
Run the following command to get PHAIDRA running on `https://$YOUR-FQDN`:

```
docker compose --project-name $PROJECT_NAME_OF_YOUR_LIKING --profile ssl-local up -d
```

## SSL version with S3 storage
###  Prerequisites
+ make sure no other service is using ports 80 and 443 on your computer.
+ a DNS-entry pointing to your computer's IP-address.
+ SSL-certificate and -key (put them into the `certs/httpd` and name them `privkey.pem` and `fullchain.pem` -- **make sure your user has read access on these files**).  Certificates acquired from the [certbot tool](https://certbot.eff.org/) should do the job as they contain the full chain of certificates.
+ firewall with port 80 and 443 open on your computer.
+ set the following variables in your `.env` file:
  + `ADMIN_IP_LIST`: List of space-delimited IP addresses that should be allowed to reach the admin area. This includes the static IP address of your computer, if you access the installation through your local browser. If you access your installation from localhost by modifying `/etc/hosts` you will want to keep the gateway address in there as well (10.0.2.2 [default] for rootless docker on Linux, 172.29.5.1 for priviledged docker on Linux or Windows,  192.168.65.1 for priviledged docker on OSX).
  + `OUTSIDE_HTTP_SCHEME="https"`
  + `PHAIDRA_HOSTPORT=""`
  + `PHAIDRA_PORTSTUB=""`
  + `PHAIDRA_HOSTNAME="$YOUR-FQDN"`
  + `S3_ACCESS_KEY`
  + `S3_SECRET_KEY`
  + `S3_BUCKETNAME`
  + `S3_CACHESIZE`: in Bytes, defaults to 100000000 (100MB).
  + `S3_REGION`

###  Startup
Run the following command to get PHAIDRA running on `https://$YOUR-FQDN`:

```
docker compose --project-name $PROJECT_NAME_OF_YOUR_LIKING --profile ssl-s3 up -d
```

## Shibboleth version with local storage
NOTE: This profile is not as straight forward, as the built-in apache2 webserver will act as a Shibboleth-SP, which requires registration at your organization's Shibboleth IDP.  It's very likely that you need to modify a row of variables, depending on your organization.
###  Prerequisites
+ make sure no other service is using ports 80 and 443 on your computer.
+ a DNS-entry pointing to your computer's IP-address.
+ SSL-certificate and -key (put them into the `certs/httpd` and name them `privkey.pem` and `fullchain.pem` -- **make sure your user has read access on these files**).  Certificates acquired from the [certbot tool](https://certbot.eff.org/) should do the job as they contain the full chain of certificates.
+ generate certificates for communication with your idp by running the commands below and put them into `certs/shibboleth`:
```
openssl req -new -x509 -nodes -newkey rsa:2048 -keyout sp-encrypt-key.pem -days $DESIRED_VALIDITY_TIME -subj '/CN=$YOUR_FQDN' -out sp-encrypt-cert.pem
openssl req -new -x509 -nodes -newkey rsa:2048 -keyout sp-signing-key.pem -days $DESIRED_VALIDITY_TIME -subj '/CN=$YOUR_FQDN' -out sp-signing-cert.pem
```
+ firewall with port 80 and 443 open on your computer.
+ set the following variables in your `.env` file:
  + `ADMIN_IP_LIST`: List of space-delimited IP addresses that should be allowed to reach the admin area. This includes the static IP address of your computer, if you access the installation through your local browser. If you access your installation from localhost by modifying `/etc/hosts` you will want to keep the gateway address in there as well (10.0.2.2 [default] for rootless docker on Linux, 172.29.5.1 for priviledged docker on Linux or Windows,  192.168.65.1 for priviledged docker on OSX).
  + `OUTSIDE_HTTP_SCHEME="https"`
  + `PHAIDRA_HOSTPORT=""`
  + `PHAIDRA_PORTSTUB=""`
  + `PHAIDRA_HOSTNAME="$YOUR-FQDN"`
  + `SHIB_DISCO_URL`: shibboleth discovery URL. eg: `https://eduid.at/ds/wayf/` (default).
  + `SHIB_METADATA_CERT`: shibboleth metadata signing certificate. eg: `aconet-metadata-signing.crt` (default)
  + `SHIB_METADATA_FILE`: shibboleth metadata file. eg: `aconet-registered.xml` (default).
  + `SHIB_METADATA`: shibboleth metadata file url. eg: `https://eduid.at/md/aconet-registered.xml` (default)
  + `SHIB_ENTITY_ID`: shibboleth weblogin address. eg: `https://weblogin.univie.ac.at/shibboleth` (default)
  + `SHIB_MAIL`: shibboleth mail attribute. eg: `mail` (default)
  + `SHIB_GIVEN_NAME`: shibboleth given name attribute. eg: `givenName`(default)
  + `SHIB_SURNAME`: shibboleth surname attribute. eg: `sn` (default)
  + `SHIB_USERNAME`: shibboleth username attribute. eg: `uid` (default)
  + `SHIB_AFFILIATION`: shibboleth affiliation attribute. eg: `affiliation` (default)
  + `SHIB_REQUIRED_AFFILIATIONS`: comma-separated list of required attributes to log in to PHAIDRA. eg: `staff@univie.ac.at,employee@univie.ac.at,member@univie.ac.at` (default)

###  Startup

Run the following command to get PHAIDRA running on `https://$YOUR-FQDN`:

```
docker compose --project-name $PROJECT_NAME_OF_YOUR_LIKING --profile shib-local up -d
```

After startup, download your SP's Metadata file by visiting `https://$YOUR-FQDN/Shibboleth.sso/Metadata`. You will have to hand this file to the IDP-manager of your organization and ask for registration.  After that, users matching the list in `SHIB_REQUIRED_AFFILIATIONS` should be able to log in and upload their files to your system.

## Shibboleth version with S3 storage
NOTE: This profile is not as straight forward, as the built-in apache2 webserver will act as a Shibboleth-SP, which requires registration at your organization's Shibboleth IDP.  It's very likely that you need to modify a row of variables, depending on your organization.
###  Prerequisites
+ make sure no other service is using ports 80 and 443 on your computer.
+ a DNS-entry pointing to your computer's IP-address.
+ SSL-certificate and -key (put them into the `certs/httpd` and name them `privkey.pem` and `fullchain.pem` -- **make sure your user has read access on these files**).  Certificates acquired from the [certbot tool](https://certbot.eff.org/) should do the job as they contain the full chain of certificates.
+ generate certificates for communication with your idp by running the commands below and put them into `certs/shibboleth`:
```
openssl req -new -x509 -nodes -newkey rsa:2048 -keyout sp-encrypt-key.pem -days $DESIRED_VALIDITY_TIME -subj '/CN=$YOUR_FQDN' -out sp-encrypt-cert.pem
openssl req -new -x509 -nodes -newkey rsa:2048 -keyout sp-signing-key.pem -days $DESIRED_VALIDITY_TIME -subj '/CN=$YOUR_FQDN' -out sp-signing-cert.pem
```
+ firewall with port 80 and 443 open on your computer.
+ set the following variables in your `.env` file:
  + `ADMIN_IP_LIST`: List of space-delimited IP addresses that should be allowed to reach the admin area. This includes the static IP address of your computer, if you access the installation through your local browser. If you access your installation from localhost by modifying `/etc/hosts` you will want to keep the gateway address in there as well (10.0.2.2 [default] for rootless docker on Linux, 172.29.5.1 for priviledged docker on Linux or Windows,  192.168.65.1 for priviledged docker on OSX).
  + `OUTSIDE_HTTP_SCHEME="https"`
  + `PHAIDRA_HOSTPORT=""`
  + `PHAIDRA_PORTSTUB=""`
  + `PHAIDRA_HOSTNAME="$YOUR-FQDN"`
  + `SHIB_DISCO_URL`: shibboleth discovery URL. eg: `https://eduid.at/ds/wayf/` (default).
  + `SHIB_METADATA_CERT`: shibboleth metadata signing certificate. eg: `aconet-metadata-signing.crt` (default)
  + `SHIB_METADATA_FILE`: shibboleth metadata file. eg: `aconet-registered.xml` (default).
  + `SHIB_METADATA`: shibboleth metadata file url. eg: `https://eduid.at/md/aconet-registered.xml` (default)
  + `SHIB_ENTITY_ID`: shibboleth weblogin address. eg: `https://weblogin.univie.ac.at/shibboleth` (default)
  + `SHIB_MAIL`: shibboleth mail attribute. eg: `mail` (default)
  + `SHIB_GIVEN_NAME`: shibboleth given name attribute. eg: `givenName`(default)
  + `SHIB_SURNAME`: shibboleth surname attribute. eg: `sn` (default)
  + `SHIB_USERNAME`: shibboleth username attribute. eg: `uid` (default)
  + `SHIB_AFFILIATION`: shibboleth affiliation attribute. eg: `affiliation` (default)
  + `SHIB_REQUIRED_AFFILIATIONS`: comma-separated list of required attributes to log in to PHAIDRA. eg: `staff@univie.ac.at,employee@univie.ac.at,member@univie.ac.at` (default)
  + `S3_ACCESS_KEY`
  + `S3_SECRET_KEY`
  + `S3_BUCKETNAME`
  + `S3_CACHESIZE`: in Bytes, defaults to 100000000 (100MB).
  + `S3_REGION`

###  Startup

Run the following command to get PHAIDRA running on `https://$YOUR-FQDN`:

```
docker compose --project-name $PROJECT_NAME_OF_YOUR_LIKING --profile shib-s3 up -d
```

After startup, download your SP's Metadata file by visiting `https://$YOUR-FQDN/Shibboleth.sso/Metadata`. You will have to hand this file to the IDP-manager of your organization and ask for registration.  After that, users matching the list in `SHIB_REQUIRED_AFFILIATIONS` should be able to log in and upload their files to your system.

# Default credentials on administration sites
- **LDAP Account Manager** (from the Webinterface: Manage Phaidra -> Manage Users):
  - user: `admin`
  - password: `adminpassword`.
  These credentials can be altered at first startup through the variables `LDAP_ADMIN_USERNAME` and `LDAP_ADMIN_PASSWORD` at first startup in your `.env` file.
    - There are three default users built in for testing purposes (logging into Phaidra, uploading, etc) `pone`, `ptwo`, and `barchiver`.  They all share the same password `1234`.
    - These users can be accessed/altered/deleted from **LDAP Account manager**.
- **Fedora** (from the Webinterface: Manage Phaidra -> Inspect Object Repository):
  - username: `fedoraAdmin`
  - password: `1234`
  - These credentials can be altered in the `.env` file through the variables `FEDORA_ADMIN_USER` and `FEDORA_ADMIN_PASS`.
- **Grafana** (from the Webinterface: Manage Phaidra -> Inspect Running Services):
  - username: `phaidra`
  - password: `phaidra`
  - These credentials can be altered at first startup in the `.env` file through the variables `GF_SECURITY_ADMIN_USER` and `GF_SECURITY_ADMIN_PASS`.
- **DbGate** (from the Webinterface: Manage Phaidra -> Inspect Databases)
  - username: `phaidra`
  - password: `phaidra`
  - Here only the password can be modified in the `.env` file through the variable `DBGATE_PASS`.  If you want to change the username as well, please change it in the `docker-compose.yaml` file in the `dbgate:` section.  The corresponding variable is called `LOGINS`. You will have to put the username into the variable in the next line `LOGIN_PASSWORD_[username]` as well, that's why we can't centrally manage this from `.env` for now.
- **Solr** (from the Webinterface: Manage Phaidra -> Inspect Search Engine)
  - username: `phaidra`
  - password: `phaidra`
  - These credentials can be modified in the `.env` file through the variables `SOLR_USER` and `SOLR_PASS`. You might also want to change `SOLR_SALT` to some random string for a more random encryption of the credentials within solr.
- the **api**
  - username: `phaidraAdmin`
  - password: `12345`
  - These credentials can be modified in the `.env` file through the variables `PHAIDRA_ADMIN_USER` and `PHAIDRA_ADMIN_PASSWORD`.  You might also want to change `PHAIDRA_ENCRYPTION_KEY` and `PHAIDRA_SECRET` to enhance privacy.
# Monitoring PHAIDRA

___
![alt text](./pictures/dashboard.png "Screenshot of PHAIDRA Grafana Dashboard")*Monitoring Dashboard*
___

There is a Grafana dashboard at `http://localhost:8899/grafana`, respectively `https://YOUR_FQDN/grafana`, that displays the containers' system usage and their logs.

One can also use the following shell command to monitor the system usage
of PHAIDRA over all containers from the machine where it is running (here from an instance started with
`docker compose --project-name eval-shib-opencast-3 --profile shib-local --profile external-opencast up -d`):

``` example
# COMMAND:
docker stats
# EXPECTED OUTPUT:
CONTAINER ID   NAME                                      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
24943d669203   eval-shib-opencast-3-ui-1                 0.00%     168.6MiB / 15.03GiB   1.10%     348kB / 519kB     282MB / 2.26MB    23
8cce9848c02b   eval-shib-opencast-3-pixelgecko-1         0.00%     132.8MiB / 15.03GiB   0.86%     245kB / 405kB     105MB / 6MB       1
ac15e22ef241   eval-shib-opencast-3-api-1                0.02%     372.1MiB / 15.03GiB   2.42%     1.83MB / 2.06MB   100MB / 4.1kB     5
784499d895b4   eval-shib-opencast-3-chronos-1            0.01%     5.281MiB / 15.03GiB   0.03%     4.16kB / 1.03kB   25.6MB / 28.7kB   3
901bf54873ad   eval-shib-opencast-3-promtail-1           0.72%     46.36MiB / 15.03GiB   0.30%     41.8kB / 517kB    203MB / 532kB     13
cdd6e92565ce   eval-shib-opencast-3-fedora-1             0.28%     768.1MiB / 15.03GiB   4.99%     1.23MB / 446kB    411MB / 6.55MB    61
66a0cbf84a1f   eval-shib-opencast-3-dbgate-1             0.00%     27.15MiB / 15.03GiB   0.18%     2.52kB / 224B     129MB / 4.1kB     11
ad395ac37d5b   eval-shib-opencast-3-vige-1               0.05%     109.1MiB / 15.03GiB   0.71%     1.24MB / 1.92MB   308MB / 811kB     8
f101f8234c40   eval-shib-opencast-3-grafana-1            0.52%     70.17MiB / 15.03GiB   0.46%     31.4kB / 6.38kB   397MB / 47.4MB    19
e1d172582a49   eval-shib-opencast-3-lam-1                0.01%     28.56MiB / 15.03GiB   0.19%     2.23kB / 0B       160MB / 86kB      8
daf4baed79e5   eval-shib-opencast-3-mariadb-fedora-1     0.01%     118.3MiB / 15.03GiB   0.77%     202kB / 184kB     164MB / 88.9MB    18
2860983af946   eval-shib-opencast-3-openldap-1           0.00%     24.69MiB / 15.03GiB   0.16%     67.6kB / 38.2kB   48.5MB / 729kB    4
6d11aafaf265   eval-shib-opencast-3-httpd-shib-local-1   0.02%     116.2MiB / 15.03GiB   0.75%     4.26MB / 2.4MB    165MB / 1.87MB    126
a91e94bdebfd   eval-shib-opencast-3-solr-1               0.85%     753.1MiB / 15.03GiB   4.89%     46.5kB / 112kB    282MB / 1.01MB    53
c39b0dae4593   eval-shib-opencast-3-loki-1               0.62%     60.25MiB / 15.03GiB   0.39%     519kB / 39.8kB    176MB / 3.01MB    13
aca9aed2d582   eval-shib-opencast-3-mongodb-phaidra-1    0.52%     265.7MiB / 15.03GiB   1.73%     1.68MB / 1.55MB   627MB / 7.82MB    39
6e82b65d8b3a   eval-shib-opencast-3-mariadb-phaidra-1    0.02%     221.7MiB / 15.03GiB   1.44%     14.8kB / 8.59kB   216MB / 105MB     13
d2880e7de5ff   eval-shib-opencast-3-imageserver-1        0.01%     29.06MiB / 15.03GiB   0.19%     7.22kB / 132kB    31.9MB / 24.6kB   65
4715e3861ba8   eval-shib-opencast-3-cadvisor-1           5.59%     243.6MiB / 15.03GiB   1.58%     227kB / 16.3MB    89.1MB / 0B       16
e5d2101e4c53   eval-shib-opencast-3-prometheus-1         0.00%     202.4MiB / 15.03GiB   1.32%     17.1MB / 273kB    185MB / 3.01MB    13
e4a874e58527   eval-shib-opencast-3-node-exporter-1      0.00%     13.94MiB / 15.03GiB   0.09%     29.2kB / 597kB    40.6MB / 0B       6
```

# Data persistance and integrity
`docker compose up -d` will create directories in
`$HOME/.local/share/docker/volumes` (`/var/lib/docker/volumes` in case you run rootful docker) to persist data created by PHAIDRA
over docker restarts or whole system reboots.  These directories are the ones that need to be backupped to prevent data loss in case 
of hardware failure.

Objects loaded into PHAIDRA are automatically checksummed using the [SHA512-algorithm](https://en.wikipedia.org/wiki/SHA-2) by the underlying
repository software [Fedora](https://fedora.lyrasis.org/).  By default, PHAIDRA triggers a recalculation of the checksums on every 2nd day of the month.  Results of these scans are visible on the built-in Grafana Dashboard for early hardware-failure detection.

Depending on `--project-name $PROJECT_NAME_OF_YOUR_LIKING` the volumes will be prefixed with `$PROJECT_NAME_OF_YOUR_LIKING`.

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

In the folder `./src` one will find `phaidra-api`, `phaidra-ui`,
and `phaidra-vue-components`, and `pixelgecko`, the core components of PHAIDRA.
See the notes in the following subsections for provenance.

### phaidra-api

This directory derives from commit c880c4159c5d68b25426451f4822f744a53ef680 of
the repo at <https://github.com/phaidra/phaidra-api>.

### phaidra-ui

This directory derives from commit 5c9455373d36f4756e9caa2af989fac4dbd28f9f of
the repo at <https://github.com/phaidra/phaidra-ui>.

### phaidra-vue-components

This directory derives from commit 64f8b9870a0bc66a6b4a58fec5dfe6c2431e72d7 of
the repo at <https://github.com/phaidra/phaidra-vue-components.git>.

### pixelgecko

This directory derives from commit be0af173eaac297289fa51843b69327f7c95242c of the repo at
<https://gitlab.phaidra.org/phaidra-dev/pixelgecko>.

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
 Version:           25.0.1
 API version:       1.44
 Go version:        go1.21.6
 Git commit:        29cf629
 Built:             Tue Jan 23 23:09:46 2024
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          25.0.1
  API version:      1.44 (minimum version 1.24)
  Go version:       go1.21.6
  Git commit:       71fa3ab
  Built:            Tue Jan 23 23:09:46 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.27
  GitCommit:        a1496014c916f9e62104b33d1bb5bd03b0858e59
 runc:
  Version:          1.1.11
  GitCommit:        v1.1.11-0-g4bccb38
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
 rootlesskit:
  Version:          2.0.0
  ApiVersion:       1.1.1
  NetworkDriver:    slirp4netns
  PortDriver:       slirp4netns
  StateDir:         /run/user/1000/dockerd-rootless
 slirp4netns:
  Version:          1.2.0
  GitCommit:        656041d45cfca7a4176f6b7eed9e4fe6c11e8383
```

``` bash
docker info
```

``` example
Client: Docker Engine - Community
 Version:    25.0.1
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.12.1
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.24.2
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 22
  Running: 20
  Paused: 0
  Stopped: 2
 Images: 28
 Server Version: 25.0.1
 Storage Driver: fuse-overlayfs
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: a1496014c916f9e62104b33d1bb5bd03b0858e59
 runc version: v1.1.11-0-g4bccb38
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  rootless
  cgroupns
 Kernel Version: 6.1.0-17-amd64
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
    configurations (see [upstream documentation](https://docs.docker.com/engine/security/rootless/#limiting-resources)). One can do the following to change this:

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
   
   To activate the docker metrics endpoint, create the file `~/.config/docker/daemon.json` and add the following (the code below is for a rootless setup, for priviledged docker see the [upstream documentation](https://docs.docker.com/config/daemon/prometheus/)):
   
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

