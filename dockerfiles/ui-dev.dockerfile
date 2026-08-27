FROM node:26-trixie-slim
RUN <<EOF
apt-get update
apt-get install git ca-certificates -y
apt-get clean
EOF

# node >25 does NOT ship with corepack
RUN npm install -g corepack
# Since v11, minimumReleaseAge has a default value of 1440: https://pnpm.io/settings/dependency-resolution#minimumreleaseage
RUN corepack enable && corepack prepare pnpm@11 --activate

ARG CACHEBUST=1
RUN mkdir -p /usr/local/phaidra
ADD ./../src/phaidra-ui /usr/local/phaidra/phaidra-ui
ADD ./../src/phaidra-vue-components /usr/local/phaidra/phaidra-vue-components
WORKDIR /usr/local/phaidra/phaidra-vue-components
RUN <<EOF
pnpm install --frozen-lockfile
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
pnpm install --frozen-lockfile
pnpm add /usr/local/phaidra/phaidra-vue-components
EOF
