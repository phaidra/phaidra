FROM node:20.0-bullseye-slim
RUN <<EOF
apt-get update
apt-get install git ca-certificates -y
apt-get clean
EOF
ARG CACHEBUST=1
ARG PHAIDRA_HOSTNAME
ARG PHAIDRA_PORTSTUB
ARG PHAIDRA_HOSTPORT
ARG OUTSIDE_HTTP_SCHEME
ARG PHAIDRA_PRIMARY_COLOR
RUN mkdir -p /usr/local/phaidra
ADD ./../src/phaidra-ui /usr/local/phaidra/phaidra-ui
ADD ./../src/phaidra-vue-components /usr/local/phaidra/phaidra-vue-components
WORKDIR /usr/local/phaidra/phaidra-vue-components
RUN <<EOF
npm install
EOF
WORKDIR /usr/local/phaidra/phaidra-ui
RUN <<EOF
sed -i "s|<HOST_WITH_OR_WITHOUT_PORT>|${PHAIDRA_HOSTNAME}${PHAIDRA_PORTSTUB}${PHAIDRA_HOSTPORT}|g" \
    ./nuxt.config.js
sed -i "s|<OUTSIDE_HTTP_SCHEME>|${OUTSIDE_HTTP_SCHEME}|" \
    ./nuxt.config.js
sed -i "s|<OUTSIDE_HTTP_SCHEME>|${OUTSIDE_HTTP_SCHEME}|" \
    ./config/phaidra-ui.js
sed -i "s|<HOST_WITH_OR_WITHOUT_PORT>|${PHAIDRA_HOSTNAME}${PHAIDRA_PORTSTUB}${PHAIDRA_HOSTPORT}|g" \
    ./config/phaidra-ui.js
sed -i "s|<PHAIDRA_PRIMARY_COLOR>|${PHAIDRA_PRIMARY_COLOR}|g" \
    ./config/phaidra-ui.js
EOF
ENV HOST=0.0.0.0
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3001
EXPOSE 3001
RUN <<EOF
npm install
npm install /usr/local/phaidra/phaidra-vue-components
EOF
RUN <<EOF
npm run build
EOF
ENTRYPOINT ["npm", "run", "start"]
