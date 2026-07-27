FROM node:22-bookworm-slim
RUN <<EOF
apt-get update
apt-get install git ca-certificates -y
apt-get clean
EOF
ARG CACHEBUST=1
RUN mkdir -p /usr/local/phaidra
ADD ./../src/phaidra-ui /usr/local/phaidra/phaidra-ui
ADD ./../src/phaidra-vue-components /usr/local/phaidra/phaidra-vue-components
WORKDIR /usr/local/phaidra/phaidra-vue-components
RUN <<EOF
npm install
EOF
WORKDIR /usr/local/phaidra/phaidra-ui
ENV HOST=0.0.0.0
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3001
ENV CHOKIDAR_USEPOLLING=true
ENV CHOKIDAR_INTERVAL=250
ENV VITE_USE_POLLING=true
ENV VITE_WATCH_INTERVAL=250
EXPOSE 3001
RUN <<EOF
npm i -g pm2@latest
npm install
npm install /usr/local/phaidra/phaidra-vue-components
EOF
