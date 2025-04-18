FROM node:20-slim

WORKDIR /app

COPY src/3d/package*.json ./
RUN npm install

COPY src/3d/ .

CMD ["node", "index.js"]
