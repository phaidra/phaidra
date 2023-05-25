FROM node:20.0-bullseye-slim
RUN <<EOF
apt-get update
apt-get install git ca-certificates -y
apt-get clean
EOF
ARG CACHEBUST=1
RUN mkdir -p /usr/local/phaidra
ADD ./../components/phaidra-ui /usr/local/phaidra/phaidra-ui
ADD ./../components/phaidra-vue-components /usr/local/phaidra/phaidra-vue-components
WORKDIR /usr/local/phaidra/phaidra-vue-components
RUN <<EOF
npm install
EOF
WORKDIR /usr/local/phaidra/phaidra-ui
COPY ./../configs/phaidra-ui/phaidra-ui.js config/
ADD ./../configs/phaidra-ui/ui-components components/ext
ADD ./../configs/phaidra-ui/ui-assets assets/ext
ENV HOST=0.0.0.0
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3001
EXPOSE 3001
RUN <<EOF
npm install
npm install axios@0.24.0
npm install /usr/local/phaidra/phaidra-vue-components
sed -i "s|transpile: \['phaidra-vue-components', 'vuetify/lib'\]|\
transpile: \['phaidra-vue-components', 'vuetify/lib'\]\n  },\n  router: {\n    base: '/ui/'|" \
nuxt.config.js
EOF
RUN <<EOF
npm run build
EOF
ENTRYPOINT ["npm", "run", "start"]
