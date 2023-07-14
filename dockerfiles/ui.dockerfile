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
