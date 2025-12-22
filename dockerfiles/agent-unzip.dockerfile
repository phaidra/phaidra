FROM node:20-slim

WORKDIR /app

COPY src/agents/unzip/package*.json ./
RUN npm install

COPY src/agents/unzip/ .

CMD ["node", "index.js"]

