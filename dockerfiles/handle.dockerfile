FROM alpine:3.23
ARG HANDLE_VERSION=9.3.2
ENV SERVER_ADMIN_FULL_ACCESS="true"
ENV ALLOW_NA_ADMINS="true"
ENV ALLOW_RECURSION="false"

ADD https://www.handle.net/hnr-source/handle-${HANDLE_VERSION}-distribution.tar.gz /opt

RUN mkdir -p /opt/handle-data/logs && touch /opt/handle-data/logs/access.log && touch /opt/handle-data/logs/error.log &&\
    tar -xzf /opt/handle-${HANDLE_VERSION}-distribution.tar.gz --directory /opt/ &&\
    rm -f /opt/handle-${HANDLE_VERSION}-distribution.tar.gz &&\
    mv /opt/handle-${HANDLE_VERSION} /opt/handle
RUN apk add --no-cache openjdk21-jre-headless gettext-envsubst &&\
    ln -sf /dev/stdout /opt/handle-data/logs/access.log &&\
    ln -sf /dev/stderr /opt/handle-data/logs/error.log &&\
    ln -sf /opt/handle-data/.handle /root/.handle


COPY --chmod=700 ./container_init/handle/handle-entrypoint.sh /handle-entrypoint.sh
COPY ./container_init/handle/siteinfo.json.template /siteinfo.json.template
COPY ./container_init/handle/config.dct.template /config.dct.template

EXPOSE 8000/tcp
EXPOSE 2641/tcp
EXPOSE 2641/udp

ENTRYPOINT [ "/handle-entrypoint.sh" ]
