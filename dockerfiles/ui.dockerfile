# ---------- Build stage ----------
FROM node:22-bookworm-slim AS builder

# Enable pnpm via corepack
RUN corepack enable && corepack prepare pnpm@9 --activate

# App sources
RUN mkdir -p /usr/local/phaidra
ADD ./../src/phaidra-ui /usr/local/phaidra/phaidra-ui
ADD ./../src/phaidra-vue-components /usr/local/phaidra/phaidra-vue-components

WORKDIR /usr/local/phaidra/phaidra-ui

# Build-time env (keep devDeps available)
ENV NUXT_TELEMETRY_DISABLED=1
ENV NUXT_NO_SOURCEMAP=1
ENV NODE_OPTIONS="--max-old-space-size=8192"
ENV HOST=0.0.0.0
ENV PORT=3001

# Install deps (includes devDependencies such as sass-embedded)
RUN pnpm install --frozen-lockfile

# Build Nuxt
RUN pnpm build


# ---------- Runtime stage ----------
FROM node:22-bookworm-slim

# PM2
RUN npm i -g pm2@latest

WORKDIR /app

# Copy only the built output
COPY --from=builder /usr/local/phaidra/phaidra-ui/.output ./.output
COPY --from=builder /usr/local/phaidra/phaidra-ui/ecosystem.config.js ./ecosystem.config.js

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3001
EXPOSE 3001