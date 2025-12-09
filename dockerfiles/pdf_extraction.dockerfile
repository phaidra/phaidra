FROM node:20-slim

WORKDIR /app

# Install Java for Apache Tika
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jre-headless curl && \
    rm -rf /var/lib/apt/lists/*

# Install Apache Tika App
ENV TIKA_VERSION=3.2.3
RUN mkdir -p /opt/tika && \
    curl -L "https://downloads.apache.org/tika/$TIKA_VERSION/tika-app-$TIKA_VERSION.jar" -o /opt/tika/tika-app.jar
# Copy worker sources and install deps
COPY src/pdf_extraction/package*.json ./
RUN npm install --omit=dev
COPY src/pdf_extraction/ .

# Environment defaults (override via docker-compose)
ENV MONGO_AGENT_DB=paf_mongodb \
    TIKA_APP_JAR=/opt/tika/tika-app.jar

# Run the Node worker loop
CMD ["node", "index.js"]


