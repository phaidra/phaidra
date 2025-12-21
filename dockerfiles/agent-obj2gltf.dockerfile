FROM node:20-slim

WORKDIR /app

<<<<<<< HEAD
COPY src/agents/obj2gltf/package*.json ./
RUN npm install

COPY src/agents/obj2gltf/ .
=======
COPY src/agents/3d/package*.json ./
RUN npm install

COPY src/agents/3d/ .
>>>>>>> ce525203 (Rebase to main and normalize unzip agent and volume)

CMD ["node", "index.js"]
