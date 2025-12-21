FROM node:20-slim

WORKDIR /app

COPY src/agents/obj2gltf/package*.json ./
RUN npm install

COPY src/agents/obj2gltf/ .

CMD ["node", "index.js"]
