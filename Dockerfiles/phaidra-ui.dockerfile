FROM node:20.0-bullseye-slim
RUN <<EOF
apt-get update
apt-get install git ca-certificates -y
apt-get clean
EOF
RUN git clone https://github.com/phaidra/phaidra-vue-components.git
WORKDIR /phaidra-vue-components
RUN git checkout c08f9502633d217650103f11173b8fa911bd05c7
RUN <<EOF
npm install
EOF
WORKDIR /
RUN git clone https://github.com/phaidra/phaidra-ui.git
WORKDIR /phaidra-ui
RUN mkdir -p components
RUN mkdir -p assets
ADD ./../component_configs/phaidra-ui/ui-components components/ext/
ADD ./../component_configs/phaidra-ui/ui-assets assets/ext/
RUN git checkout 738304b5516b2b78fba4ec935d4e1bc986fd49b9
RUN <<EOF
npm install
EOF
RUN <<EOF
npm install axios@0.24.0
EOF
RUN <<EOF
npm install /phaidra-vue-components
EOF
RUN unlink config/phaidra-ui.js
COPY ./../component_configs/phaidra-ui/phaidra-ui.js config/
RUN <<EOF
sed -i "s|transpile: \['phaidra-vue-components', 'vuetify/lib'\]|\
transpile: \['phaidra-vue-components', 'vuetify/lib'\]\n  },\n  router: {\n    base: '/ui/'|" \
nuxt.config.js
EOF
ENV HOST=0.0.0.0
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3001
EXPOSE 3001
RUN npm run build
ENTRYPOINT ["npm", "run", "start"] 
