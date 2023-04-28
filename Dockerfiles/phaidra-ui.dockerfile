FROM node:16-bullseye
RUN <<EOF
apt-get update
apt-get install git ca-certificates -y
apt-get clean
EOF
RUN git clone https://github.com/phaidra/phaidra-vue-components.git
WORKDIR phaidra-vue-components
RUN git checkout c08f9502633d217650103f11173b8fa911bd05c7
RUN <<EOF
npm install
EOF
WORKDIR /
RUN git clone https://github.com/phaidra/phaidra-ui.git
WORKDIR phaidra-ui
RUN git checkout 738304b5516b2b78fba4ec935d4e1bc986fd49b9
RUN npm install
RUN npm install /phaidra-vue-components
RUN unlink config/phaidra-ui.js
ADD phaidra-ui.js config/
RUN <<EOF
sed -i "s|transpile: \['phaidra-vue-components', 'vuetify/lib'\]|\
transpile: \['phaidra-vue-components', 'vuetify/lib'\]\n  },\n  router: {\n    base: '/ui/'|" \
nuxt.config.js
EOF
