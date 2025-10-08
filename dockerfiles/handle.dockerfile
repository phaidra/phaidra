FROM alpine AS temp
ADD https://www.handle.net/hnr-source/handle-9.3.2-distribution.tar.gz /opt
RUN tar -xzf /opt/handle-9.3.2-distribution.tar.gz --directory /opt/

FROM alpine:3 AS handle
RUN mkdir -p /opt/handle/logs && touch /opt/handle/logs/access.log &&\
 touch /opt/handle/logs/error.log &&\
 mkdir -p /opt/handle-data/logs
RUN apk add --no-cache openjdk21-jre-headless openssl gettext-envsubst &&\
    ln -sf /dev/stdout /opt/handle-data/logs/access.log &&\
    ln -sf /dev/stderr /opt/handle-data/logs/error.log
COPY --from=temp /opt/handle-9.3.2/ /opt/handle
COPY ./container_init/handle/handle-entrypoint.sh /handle-entrypoint.sh
COPY ./container_init/handle/siteinfo.json.template /siteinfo.json.template

EXPOSE 2641
EXPOSE 8000

RUN chmod u+x,g+x,o+x /handle-entrypoint.sh
ENTRYPOINT [ "/handle-entrypoint.sh" ]
