![](https://gitlab.phaidra.org/phaidra-dev/phaidra-docker/badges/main/pipeline.svg?ignore_skipped=true)

[[_TOC_]]

# About this repository

We currently have an [automated installer for
phaidra](https://gitlab.phaidra.org/phaidra-dev/phaidra-demo), which
allows to set up an instance in about 15min. However, setup is still
bound to the underlying operating system (Ubuntu 22.04-LTS), which
brings quite some complexity to the end-user. Here we try to abstract
the system further and allow for easier integration into CI/CD workflows
using containerization via docker, and to achieve better portability to
other platforms supporting this kind of containerization.

The goal of this project is to allow an interested person to run the
command `docker compose up -d` from a clone of this repo and have
phaidra running on his/her computer, without modifying the computer (and
have things easily removed with `docker compose down` as well).

## Build status

We have a minimal CI activated (see the status badge at the top of this
readme) – right now it only builds the docker images as defined in the
`./dockerfiles` directory. This is for testing purposes and runs on
every commit to this repo, as a semi-manual verification if any
cpanm-modules break the api-build.

# Technical sketch

## Standalone

![](./pictures/construction_standalone.svg)

## With external webserver

This is work in progress.

![](./pictures/construction_external_webserver.svg)

# System requirements

We recommend using a dedicated machine for a Phaidra instance. You will
need a recent Docker installed, plus the package `uidmap` for running
docker rootless.

## Docker notes

### set up rootlesskit

We run the docker services in rootless mode, to avoid uneccesary
privileges for the services themselves. From a formerly priviledged
docker one can do the following to change this:

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ docker --version
Docker version 23.0.4, build f480fb1
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ dockerd-rootless-setuptool.sh install
[ERROR] Aborting because rootful Docker (/var/run/docker.sock) is running and accessible. Set --force to ignore.
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ sudo systemctl disable --now docker.service docker.socket
[sudo] password for daniel: 
Synchronizing state of docker.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable docker
Removed /etc/systemd/system/multi-user.target.wants/docker.service.
Removed /etc/systemd/system/sockets.target.wants/docker.socket.
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ sudo reboot
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ dockerd-rootless-setuptool.sh install
[INFO] Creating /home/daniel/.config/systemd/user/docker.service
[INFO] starting systemd service docker.service
+ systemctl --user start docker.service
+ sleep 3
+ systemctl --user --no-pager --full status docker.service
● docker.service - Docker Application Container Engine (Rootless)
     Loaded: loaded (/home/daniel/.config/systemd/user/docker.service; disabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-04-28 09:13:53 CEST; 3s ago
       Docs: https://docs.docker.com/go/rootless/
   Main PID: 4572 (rootlesskit)
      Tasks: 47
     Memory: 146.8M
        CPU: 244ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/docker.service
             ├─4572 rootlesskit --net=slirp4netns --mtu=65520 --slirp4netns-sandbox=auto --slirp4netns-seccomp=auto --disable-host-loopback --port-driver=builtin --copy-up=/etc --copy-up=/run --propagation=rslave /usr/bin/dockerd-rootless.sh
             ├─4583 /proc/self/exe --net=slirp4netns --mtu=65520 --slirp4netns-sandbox=auto --slirp4netns-seccomp=auto --disable-host-loopback --port-driver=builtin --copy-up=/etc --copy-up=/run --propagation=rslave /usr/bin/dockerd-rootless.sh
             ├─4604 slirp4netns --mtu 65520 -r 3 --disable-host-loopback --enable-sandbox --enable-seccomp 4583 tap0
             ├─4611 dockerd
             └─4635 containerd --config /run/user/1000/docker/containerd/containerd.toml --log-level info

Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318881682+02:00" level=warning msg="WARNING: No io.max (wbps) support"
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318884510+02:00" level=warning msg="WARNING: No io.max (riops) support"
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318887369+02:00" level=warning msg="WARNING: No io.max (wiops) support"
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318890069+02:00" level=warning msg="WARNING: bridge-nf-call-iptables is disabled"
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318892767+02:00" level=warning msg="WARNING: bridge-nf-call-ip6tables is disabled"
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318904479+02:00" level=info msg="Docker daemon" commit=cbce331 graphdriver=vfs version=23.0.4
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.318974136+02:00" level=info msg="Daemon has completed initialization"
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.332416560+02:00" level=info msg="[core] [Server #10] Server created" module=grpc
Apr 28 09:13:53 pcherzigd64 systemd[1834]: Started Docker Application Container Engine (Rootless).
Apr 28 09:13:53 pcherzigd64 dockerd-rootless.sh[4611]: time="2023-04-28T09:13:53.337229354+02:00" level=info msg="API listen on /run/user/1000/docker.sock"
+ DOCKER_HOST=unix:///run/user/1000/docker.sock /usr/bin/docker version
Client: Docker Engine - Community
 Version:           23.0.4
 API version:       1.42
 Go version:        go1.19.8
 Git commit:        f480fb1
 Built:             Fri Apr 14 10:32:17 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          23.0.4
  API version:      1.42 (minimum version 1.12)
  Go version:       go1.19.8
  Git commit:       cbce331
  Built:            Fri Apr 14 10:32:17 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.20
  GitCommit:        2806fc1057397dbaeefbea0e4e17bddfbd388f38
 runc:
  Version:          1.1.5
  GitCommit:        v1.1.5-0-gf19387a
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
 rootlesskit:
  Version:          1.1.0
  ApiVersion:       1.1.1
  NetworkDriver:    slirp4netns
  PortDriver:       builtin
  StateDir:         /tmp/rootlesskit2619484379
 slirp4netns:
  Version:          1.0.1
  GitCommit:        6a7b16babc95b6a3056b33fb45b74a6f62262dd4
+ systemctl --user enable docker.service
Created symlink /home/daniel/.config/systemd/user/default.target.wants/docker.service → /home/daniel/.config/systemd/user/docker.service.
[INFO] Installed docker.service successfully.
[INFO] To control docker.service, run: `systemctl --user (start|stop|restart) docker.service`
[INFO] To run docker.service on system startup, run: `sudo loginctl enable-linger daniel`

[INFO] Creating CLI context "rootless"
Successfully created context "rootless"
[INFO] Using CLI context "rootless"
Current context is now "rootless"

[INFO] Make sure the following environment variable(s) are set (or add them to ~/.bashrc):
export PATH=/usr/bin:$PATH

[INFO] Some applications may require the following environment variable too:
export DOCKER_HOST=unix:///run/user/1000/docker.sock

daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ sudo loginctl enable-linger daniel
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ cat << 'EOF' >> /home/daniel/.bashrc 
> export DOCKER_HOST=unix:///run/user/1000/docker.sock
> EOF
daniel@pcherzigd64:~/gitlab.phaidra.org/herzigd64/phaidra-docker$ source ~/.bashrc
```

### change port forwarding mode for rootlesskit

To receive original client IPs into the webserver-containers (to be able
to restrict access to parts of the website) we have to change the
default rootlesskit-port-driver. If we don't, any access will seem to
come from the docker host, which nulls the sense of logging the IP.

``` example
mkdir ~/.config/systemd/user/docker.service.d
echo "[Service]" >> ~/.config/systemd/user/docker.service.d/override.conf
echo 'Environment="DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER=slirp4netns"' >> ~/.config/systemd/user/docker.service.d/override.conf
systemctl --user daemon-reload
systemctl --user restart docker
```

### allow priviledged ports for slirp4netns

To allow opening ports 80 and 443 for unpriviledged slirp4netns we need
to dedicately allow it:

``` example
echo "net.ipv4.ip_unprivileged_port_start=0" | sudo tee /etc/sysctl.d/99-rootless.conf
sudo sysctl --system
```

# System startup

## testing/dev

To start up a local testinstance of phaidra, which will run on
<http://localhost:8899> you need this repo on your computer and then run
`docker compose up -d` from the base-directory of the repo. Depending on
your internet connection and PC power, the set up will last about
10-30min.

## productive/ssl

If you want to spin up a productive version of phaidra, you will
additionaly need the following things:

-   A DNS-entry for your host's IP.
-   SSL-certificate and -key (put them into the certs-folder of this
    repo and name them `privkey.pem` and `fullchain.pem`).
-   firewall with port 80 and 443 open.

Once you've got these prerequisites, change into the `prod` directory of
this repo, put FQDN and IP into the lower section of the `.env` file (in
the `prod` directory) and run `docker compose up -d` from there.

## using an external webserver

If you prefer to use your own webserver, that is already installed on
your system, this is also possible:

There is [an nginx configuration file in this
repo](./webserver_configs/nginx-external/phaidra-nginx.conf), that can
be copied to `/etc/nginx/sites-available` and symlinked to
`/etc/nginx/sites-enabled/`. Unlink the default config and restart nginx
(`sudo systemctl restart nginx.service`) to have it ready for the
dockerized phaidra system. If you change stuff, or just want to verify
run `sudo nginx -t` to debug the configuration.

Also, you will find [an apache configuration file in this
repo](./webserver_configs/apache-external/phaidra-apache.conf).
Activation is slightly more complicated than with nginx, but should be
feasable, if one has worked with apache before (we need features not
activated by default, but they're included with the standard modules).
First, run `echo "Listen 8899" | sudo tee -a /etc/apache2/ports.conf` to
give apache the chance to listen on port 8899 (where our dev-version
serves). Then activate the necessary modules with
`sudo a2enmod proxy proxy_http`. As a last step copy the config file to
`/etc/apache2/sites-available`, disable the default configuration and
run `sudo a2ensite phaidra-apache.conf` followed by
`sudo systemctl restart apache2.service`. If you change stuff, or just
want to verify run `sudo apachectl configtest` to debug the
configuration.

If you visit <http://localhost:8899> you will get a
`502 Bad Gateway`-Error for nginx and a (slightly more comprehensive)
`Service unavailable` for apache in your browser. That is fine, PHAIDRA
has not been started yet.

Change to the `external_webserver` directory in this repo and run
`docker compose up -d` to start it up. At first run, this command will
run for a few minutes, as some images will have to be downloaded and
partly built as well.

NOTE: If you make changes to files mentioned in the `dockerfiles`
directory of this repo, make sure to remove the built images before
running `docker compose up -d`. Otherwise you will keep on using the old
images and notice not difference. E.g. if one does a change to
`components/phaidra-api/PhaidraAPI.json` one will also have to run
`docker rmi phaidra-docker-phaidra-api` to have it rebuilt on a new
startup.

## running containers after startup

After starting the program you should see the following containers
running:

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker$ docker ps
CONTAINER ID   IMAGE                                  COMMAND                  CREATED         STATUS                            PORTS                                       NAMES
66000e95199e   phaidra-ui                             "npm run start"          4 seconds ago   Up 1 second                       0.0.0.0:3001->3001/tcp, :::3001->3001/tcp   phaidra-ui-1
2b3a7bdfa4ee   phaidra-pixelgecko                     "perl pixelgecko.pl …"   4 seconds ago   Up 1 second                                                                   phaidra-pixelgecko-1
500a9b42b8c9   phaidra-api                            "hypnotoad -f phaidr…"   4 seconds ago   Up 2 seconds                      0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   phaidra-api-1
6afdad0abd8c   dbgate/dbgate:5.2.5                    "docker-entrypoint.s…"   4 seconds ago   Up 2 seconds                      0.0.0.0:7777->3000/tcp, :::7777->3000/tcp   phaidra-dbgate-1
ff1982420f09   phaidra-solr                           "docker-entrypoint.s…"   4 seconds ago   Up 2 seconds                      0.0.0.0:8983->8983/tcp, :::8983->8983/tcp   phaidra-solr-1
7e5ba84114cc   fcrepo/fcrepo:6.4.0                    "catalina.sh run"        4 seconds ago   Up 2 seconds                      0.0.0.0:9999->8080/tcp, :::9999->8080/tcp   phaidra-fedora-1
cd3ba700db29   mongo:5                                "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds                      27017/tcp                                   phaidra-mongodb-phaidra-1
4909c7ef8002   mariadb:10.5                           "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds                      3306/tcp                                    phaidra-mariadb-fedora-1
0a1466876040   ghcr.io/ldapaccountmanager/lam:8.4     "/usr/bin/dumb-init …"   4 seconds ago   Up 2 seconds (health: starting)   0.0.0.0:8888->80/tcp, :::8888->80/tcp       phaidra-lam-1
a0889d7dc75b   mariadb:11.0.2-jammy                   "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds                      3306/tcp                                    phaidra-mariadb-phaidra-1
86e86def9f8d   phaidra-imageserver                    "/usr/sbin/apachectl…"   4 seconds ago   Up 3 seconds                      0.0.0.0:8081->80/tcp, :::8081->80/tcp       phaidra-imageserver-1
5269bd16590a   bitnami/openldap:2.6.4-debian-11-r44   "/opt/bitnami/script…"   4 seconds ago   Up 3 seconds                      1389/tcp, 1636/tcp                          phaidra-openldap-1
```

## available webservices after startup

-   PHAIDRA web-interface at <http://localhost:8899> (available in your
    network).
-   PHAIDRA API at <http://localhost:8899/api> (available in your
    network).
-   Webinterface to view, query (and if you for some reason need to –
    manipulate) the databases at <http://localhost:8899/dbgate>
    (available on your computer only).
-   Webinterface to manage users at <http://localhost:8899/lam>
    (available on your computer only, default credentials
    admin/adminpassword).
-   Webinterface to Apache Solr at <http://localhost:8899/solr>
    (available on your computer only).
-   Webinterface to the underlying datastore at
    <http://localhost:8899/fcrepo> (available on your computer only,
    default credentials fedoraAdmin/fedoraAdmin).

## new folders on your system after startup

`docker compose up -d` will create directories in
`$HOME/.local/share/docker/volumes` to store data created by PHAIDRA
over system shutdowns, etc. After startup it should look like this:

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker$ docker volume ls --filter label=com.docker.compose.project=phaidra
DRIVER    VOLUME NAME
local     phaidra_api_logs
local     phaidra_dbgate
local     phaidra_fedora
local     phaidra_mariadb_fedora
local     phaidra_mariadb_phaidra
local     phaidra_mongodb_phaidra
local     phaidra_openldap
local     phaidra_pixelgecko
local     phaidra_solr
## sample volume inspection
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker$ docker volume inspect phaidra_api_logs 
[
    {
        "CreatedAt": "2023-07-07T14:02:51+02:00",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "phaidra",
            "com.docker.compose.version": "2.18.1",
            "com.docker.compose.volume": "api_logs"
        },
        "Mountpoint": "/home/daniel/.local/share/docker/volumes/phaidra_api_logs/_data",
        "Name": "phaidra_api_logs",
        "Options": null,
        "Scope": "local"
    }
]
## listing the directories the 'standard way'
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker$ ls -lha ~/.local/share/docker/volumes/phaidra*
/home/daniel/.local/share/docker/volumes/phaidra_api_logs:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   2 daniel daniel 4.0K Jul  7 14:06 _data

/home/daniel/.local/share/docker/volumes/phaidra_dbgate:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   5 daniel daniel 4.0K Jul  7 14:02 _data

/home/daniel/.local/share/docker/volumes/phaidra_fedora:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   3 daniel daniel 4.0K Jul  7 14:03 _data

/home/daniel/.local/share/docker/volumes/phaidra_mariadb_fedora:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   5 100998 100998 4.0K Jul  7 14:06 _data

/home/daniel/.local/share/docker/volumes/phaidra_mariadb_phaidra:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   6 100998 100998 4.0K Jul  7 14:06 _data

/home/daniel/.local/share/docker/volumes/phaidra_mongodb_phaidra:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   4 100998 100998 4.0K Jul  7 14:06 _data

/home/daniel/.local/share/docker/volumes/phaidra_openldap:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   4 daniel daniel 4.0K Jul  7 14:02 _data

/home/daniel/.local/share/docker/volumes/phaidra_pixelgecko:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxr-xr-x   2 daniel daniel 4.0K Jul  7 14:02 _data

/home/daniel/.local/share/docker/volumes/phaidra_solr:
total 88K
drwx-----x   3 daniel daniel 4.0K Jul  7 14:02 .
drwx-----x 710 daniel daniel  76K Jul  7 14:05 ..
drwxrwx---   4 108982 daniel 4.0K Jul  7 14:02 _data
## check volume sizes
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker$ sudo du -sh ~/.local/share/docker/volumes/phaidra_*
[sudo] password for daniel: 
16K    /home/daniel/.local/share/docker/volumes/phaidra_api_logs
32K    /home/daniel/.local/share/docker/volumes/phaidra_dbgate
320K   /home/daniel/.local/share/docker/volumes/phaidra_fedora
138M   /home/daniel/.local/share/docker/volumes/phaidra_mariadb_fedora
174M   /home/daniel/.local/share/docker/volumes/phaidra_mariadb_phaidra
301M   /home/daniel/.local/share/docker/volumes/phaidra_mongodb_phaidra
212K   /home/daniel/.local/share/docker/volumes/phaidra_openldap
8.0K   /home/daniel/.local/share/docker/volumes/phaidra_pixelgecko
440K   /home/daniel/.local/share/docker/volumes/phaidra_solr
```

You might notice that inspecting the actual sizes of the directories
requires `sudo` – this is due to the fact that solr, mariadb, and
mongodb volumes make use of a separate user from within the container.
The UIDs all come from the range your user is allowed to assign to using
the `newuidmap` and `newgidmap` programs deriving from the `uidmap`
package mentioned under system requirements. One can see this as a
reminder to be careful when manipulating this kind of data (at least the
databases can be manipulated from <http://localhost:8899/dbgate> without
special permissions).

# real time system usage logging

To see which containers are using which amount of CPU and RAM and
network I/O you can use the following command:

``` example
docker ps --quiet | xargs docker stats ## from anywhere
CONTAINER ID   NAME                        CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O   PIDS
455ad9777d42   phaidra-ui-1                0.00%     135MiB / 15.03GiB     0.88%     13.5kB / 125kB    0B / 0B     23
025d5c342c1c   phaidra-pixelgecko-1        0.00%     78.43MiB / 15.03GiB   0.51%     186kB / 401kB     0B / 0B     1
7346d39eb84d   phaidra-pixelgecko-3        0.00%     78.57MiB / 15.03GiB   0.51%     185kB / 399kB     0B / 0B     1
4ee9c8cabda9   phaidra-pixelgecko-2        0.00%     51.49MiB / 15.03GiB   0.33%     185kB / 397kB     0B / 0B     1
0941b6d5bb52   phaidra-pixelgecko-4        0.00%     78.62MiB / 15.03GiB   0.51%     186kB / 401kB     0B / 0B     1
9fff2d288c4c   phaidra-api-1               0.01%     308.3MiB / 15.03GiB   2.00%     980kB / 1.24MB    0B / 0B     5
bfa27c63e834   phaidra-dbgate-1            0.00%     24.83MiB / 15.03GiB   0.16%     2.08kB / 224B     0B / 0B     12
8bd0ac73790f   phaidra-fedora-1            0.29%     732MiB / 15.03GiB     4.76%     412kB / 397kB     0B / 0B     61
885a8d01ec2c   phaidra-solr-1              0.90%     741.2MiB / 15.03GiB   4.82%     29.2kB / 68.1kB   0B / 0B     54
12228f49c27f   phaidra-mariadb-phaidra-1   0.02%     231.1MiB / 15.03GiB   1.50%     3.68kB / 1.22kB   0B / 0B     11
e5445ae621c8   phaidra-lam-1               0.00%     25.67MiB / 15.03GiB   0.17%     2.01kB / 0B       0B / 0B     8
9d4eb920bf7c   phaidra-mariadb-fedora-1    0.02%     92.2MiB / 15.03GiB    0.60%     156kB / 137kB     0B / 0B     18
452ef909aedf   phaidra-openldap-1          0.00%     22.67MiB / 15.03GiB   0.15%     41.1kB / 44.3kB   0B / 0B     4
3046ff568558   phaidra-mongodb-phaidra-1   0.50%     189.2MiB / 15.03GiB   1.23%     1.72MB / 828kB    0B / 0B     45
6071bb9f8544   phaidra-imageserver-1       0.00%     32.39MiB / 15.03GiB   0.21%     14.4kB / 226kB    0B / 0B     65
```

# Complete cleanup

During development things can become very cluttered. A pretty complete
cleanup (at the cost of an image rebuild) can be achieved by running the
following commands:

``` example
# shut down and remove running containers (from the repo directory)
docker compose down

# remove persisted data from previous runs (from anywhere)
docker volume rm $(docker volume ls --filter label=com.docker.compose.project=phaidra --quiet)

# cleanup docker matter (build caches, images..., from anywhere)
docker system prune --all
```

# Known issues

We keep searching.

# Phaidra Components

In the folder `./components` one will find `phaidra-api`, `phaidra-ui`,
and `phaidra-vue-components`. These are copies of the public github
repos, adapted for use in the docker context here. See the notes in the
following subsections.

## phaidra-api

This is a checkout of commit c880c4159c5d68b25426451f4822f744a53ef680 of
the repo at <https://github.com/phaidra/phaidra-api> with symlinks and
git history stripped:

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-api$ git log -n1
commit c880c4159c5d68b25426451f4822f744a53ef680 (HEAD -> master, origin/master)
Author: Rasta <hudak.rastislav@gmail.com>
Date:   Mon May 22 16:08:59 2023 +0200

    avoiding empty eq
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-api$ find . -type l
./public/xsd/uwmetadata
./log4perl.conf
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-api$ find . -type l -exec rm -v {} \;
removed './public/xsd/uwmetadata'
removed './log4perl.conf'
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-api$ rm -v .gitignore && rm -rv .git
removed '.gitignore'
removed directory '.git/refs/tags'
removed '.git/refs/heads/master'
removed directory '.git/refs/heads'
removed directory '.git/refs/remotes'
removed directory '.git/refs'
removed '.git/info/exclude'
removed directory '.git/info'
removed '.git/HEAD'
removed '.git/index'
removed '.git/hooks/applypatch-msg.sample'
removed '.git/hooks/pre-commit.sample'
removed '.git/hooks/push-to-checkout.sample'
removed '.git/hooks/post-update.sample'
removed '.git/hooks/pre-merge-commit.sample'
removed '.git/hooks/update.sample'
removed '.git/hooks/commit-msg.sample'
removed '.git/hooks/pre-push.sample'
removed '.git/hooks/pre-applypatch.sample'
removed '.git/hooks/pre-rebase.sample'
removed '.git/hooks/pre-receive.sample'
removed '.git/hooks/fsmonitor-watchman.sample'
removed '.git/hooks/prepare-commit-msg.sample'
removed directory '.git/hooks'
removed '.git/config'
rm: remove write-protected regular file '.git/objects/pack/pack-7e94ef195971c977ba26038f46db4d3026adbcc7.pack'? yes
removed '.git/objects/pack/pack-7e94ef195971c977ba26038f46db4d3026adbcc7.pack'
rm: remove write-protected regular file '.git/objects/pack/pack-7e94ef195971c977ba26038f46db4d3026adbcc7.idx'? yes
removed '.git/objects/pack/pack-7e94ef195971c977ba26038f46db4d3026adbcc7.idx'
removed directory '.git/objects/pack'
removed directory '.git/objects/info'
removed directory '.git/objects'
removed directory '.git/branches'
removed '.git/logs/refs/heads/master'
removed directory '.git/logs/refs/heads'
removed directory '.git/logs/refs/remotes'
removed directory '.git/logs/refs'
removed '.git/logs/HEAD'
removed directory '.git/logs'
removed '.git/packed-refs'
removed '.git/description'
removed directory '.git'
```

## phaidra-ui

This is a checkout of commit 5c9455373d36f4756e9caa2af989fac4dbd28f9f of
the repo at <https://github.com/phaidra/phaidra-ui> with symlinks and
git history stripped:

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-ui$ git log -n1
commit 5c9455373d36f4756e9caa2af989fac4dbd28f9f (HEAD -> master, origin/master)
Merge: 63d4278 eca211f
Author: Phaidra Devel (phaidra2) <phaidra.devel@univie.ac.at>
Date:   Tue May 9 14:21:44 2023 +0200

    Merge branch 'master' of github.com:phaidra/phaidra-ui
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-ui$ find . -type l -exec rm -v {} \;
removed './config/phaidra-ui.js'
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-ui$ rm .gitignore 
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-ui$ rm -rfv .git
removed directory '.git/refs/tags'
removed '.git/refs/heads/master'
removed directory '.git/refs/heads'
removed directory '.git/refs/remotes'
removed directory '.git/refs'
removed '.git/info/exclude'
removed directory '.git/info'
removed '.git/HEAD'
removed '.git/index'
removed '.git/hooks/applypatch-msg.sample'
removed '.git/hooks/pre-commit.sample'
removed '.git/hooks/push-to-checkout.sample'
removed '.git/hooks/post-update.sample'
removed '.git/hooks/pre-merge-commit.sample'
removed '.git/hooks/update.sample'
removed '.git/hooks/commit-msg.sample'
removed '.git/hooks/pre-push.sample'
removed '.git/hooks/pre-applypatch.sample'
removed '.git/hooks/pre-rebase.sample'
removed '.git/hooks/pre-receive.sample'
removed '.git/hooks/fsmonitor-watchman.sample'
removed '.git/hooks/prepare-commit-msg.sample'
removed directory '.git/hooks'
removed '.git/config'
removed '.git/objects/pack/pack-996b081fad6c6ca2800c42b1c291f1905f007de0.idx'
removed '.git/objects/pack/pack-996b081fad6c6ca2800c42b1c291f1905f007de0.pack'
removed directory '.git/objects/pack'
removed directory '.git/objects/info'
removed directory '.git/objects'
removed directory '.git/branches'
removed '.git/logs/refs/heads/master'
removed directory '.git/logs/refs/heads'
removed directory '.git/logs/refs/remotes'
removed directory '.git/logs/refs'
removed '.git/logs/HEAD'
removed directory '.git/logs'
removed '.git/packed-refs'
removed '.git/description'
removed directory '.git'
```

## phaidra-vue-components

This is a checkout of commit 64f8b9870a0bc66a6b4a58fec5dfe6c2431e72d7 of
the repo at <https://github.com/phaidra/phaidra-vue-components.git> with
git history stripped:

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-vue-components$ git log -n1
commit 64f8b9870a0bc66a6b4a58fec5dfe6c2431e72d7 (HEAD -> master, origin/master)
Author: rasta <hudak.rastislav@gmail.com>
Date:   Tue May 23 12:21:06 2023 +0200

    Update vocabulary.js
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-vue-components$ find . -type l -exec rm -v {} \;
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-vue-components$ rm -v .gitignore 
removed '.gitignore'
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/phaidra-vue-components$ rm -rfv .git
removed directory '.git/refs/tags'
removed '.git/refs/heads/master'
removed directory '.git/refs/heads'
removed directory '.git/refs/remotes'
removed directory '.git/refs'
removed '.git/info/exclude'
removed directory '.git/info'
removed '.git/HEAD'
removed '.git/index'
removed '.git/hooks/applypatch-msg.sample'
removed '.git/hooks/pre-commit.sample'
removed '.git/hooks/push-to-checkout.sample'
removed '.git/hooks/post-update.sample'
removed '.git/hooks/pre-merge-commit.sample'
removed '.git/hooks/update.sample'
removed '.git/hooks/commit-msg.sample'
removed '.git/hooks/pre-push.sample'
removed '.git/hooks/pre-applypatch.sample'
removed '.git/hooks/pre-rebase.sample'
removed '.git/hooks/pre-receive.sample'
removed '.git/hooks/fsmonitor-watchman.sample'
removed '.git/hooks/prepare-commit-msg.sample'
removed directory '.git/hooks'
removed '.git/config'
removed '.git/objects/pack/pack-320ae928aaa1c2aa92b1253da03d7a2ae4802ea1.idx'
removed '.git/objects/pack/pack-320ae928aaa1c2aa92b1253da03d7a2ae4802ea1.pack'
removed directory '.git/objects/pack'
removed directory '.git/objects/info'
removed directory '.git/objects'
removed directory '.git/branches'
removed '.git/logs/refs/heads/master'
removed directory '.git/logs/refs/heads'
removed directory '.git/logs/refs/remotes'
removed directory '.git/logs/refs'
removed '.git/logs/HEAD'
removed directory '.git/logs'
removed '.git/packed-refs'
removed '.git/description'
removed directory '.git'
```

## pixelgecko

This is a checkout from
<https://gitlab.phaidra.org/phaidra-dev/pixelgecko> at commit
be0af173eaac297289fa51843b69327f7c95242c with git components stripped.

``` example
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components$ git clone git@gitlab.phaidra.org:phaidra-dev/pixelgecko.git
Cloning into 'pixelgecko'...
remote: Enumerating objects: 131, done.
remote: Counting objects: 100% (85/85), done.
remote: Compressing objects: 100% (50/50), done.
remote: Total 131 (delta 32), reused 85 (delta 32), pack-reused 46
Receiving objects: 100% (131/131), 74.98 KiB | 18.75 MiB/s, done.
Resolving deltas: 100% (52/52), done.
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components$ cd pixelgecko/
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/pixelgecko$ git log -n1
commit be0af173eaac297289fa51843b69327f7c95242c (HEAD -> master, origin/master, origin/HEAD)
Author: Daniel Herzig <daniel.herzig@univie.ac.at>
Date:   Wed Feb 1 14:10:40 2023 +0100

    indent properly
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/pixelgecko$ find . -type l
daniel@pcherzigd64:~/gitlab.phaidra.org/phaidra-dev/phaidra-docker/components/pixelgecko$ rm -rf .git .gitignore
```

# export org to markdown and add badge

``` bash
pandoc README.org --to=gfm -o README.md
REV_TMP=$(mktemp)
tac README.md > $REV_TMP
printf "\n%s\n\n\n%s" \
       "[[_TOC_]]" \
       "![](https://gitlab.phaidra.org/phaidra-dev/phaidra-docker/badges/main/pipeline.svg?ignore_skipped=true)" \
       >> $REV_TMP
tac $REV_TMP > README.md
```
