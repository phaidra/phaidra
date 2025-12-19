FROM node:20-slim

WORKDIR /app

COPY src/agents/3d/package*.json ./
RUN npm install

COPY src/agents/3d/ .

CMD ["node", "index.js"]
