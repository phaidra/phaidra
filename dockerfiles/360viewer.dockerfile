FROM node:20-slim

WORKDIR /app

COPY src/360viewer/package*.json ./
RUN npm install

COPY src/360viewer/ .

CMD ["node", "index.js"]

