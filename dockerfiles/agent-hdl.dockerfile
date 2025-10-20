FROM node:20-slim

WORKDIR /app

COPY src/agents/hdl/package*.json ./
RUN npm install

COPY src/agents/hdl/ .

CMD ["node", "index.js"]
