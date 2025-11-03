FROM iipsrv/iipsrv:1.3

RUN echo 'server.port = env.LIGHTTPD_PORT' >> /etc/lighttpd/lighttpd.conf &&\
  mkdir -p /etc/lighttpd/log &&\
  chown -R :root /etc/lighttpd/log &&\
  chmod -R g+rwx /etc/lighttpd/log &&\
  sed -i 's#fcgi-bin#iipsrv#g' /etc/lighttpd/lighttpd.conf &&\
  sed -i 's#/var/log/lighttpd#/etc/lighttpd/log#g' /etc/lighttpd/lighttpd.conf &&\
  sed -i 's#^.*pid-file.*$#server.pid-file = "/tmp/lighttpd.pid"#g' /etc/lighttpd/lighttpd.conf &&\
  chown -R lighttpd:root /etc/lighttpd

SHELL ["/bin/sh", "-c"]
ENTRYPOINT lighttpd -f /etc/lighttpd/lighttpd.conf && iipsrv --bind ${HOST}:${PORT}
