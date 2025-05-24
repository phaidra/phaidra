FROM maven:3-openjdk-11 AS build

# Create and use a build directory
WORKDIR /build

# Install git and clone the repository
RUN apt-get update && \
    apt-get install -y git && \
    git clone https://github.com/fcrepo-exts/fcrepo-camel-toolbox.git .

# Add camel-exec dependency to fcrepo-fixity/pom.xml
RUN sed -i '/<dependencies>/a \
    <dependency>\
        <groupId>org.apache.camel</groupId>\
        <artifactId>camel-exec</artifactId>\
        <version>${camel.version}</version>\
    </dependency>' fcrepo-fixity/pom.xml


# Build with maven
RUN mvn clean package -DskipTests

FROM openjdk:11-jre-slim AS app

WORKDIR /usr/local/fcrepo-camel-toolbox

# Copy the built jar and entrypoint script
COPY --from=build /build/fcrepo-camel-toolbox-app/target/fcrepo-camel-toolbox-app-*-driver.jar ./driver.jar
COPY --from=build /build/docker/entrypoint.sh ./
RUN chmod a+x ./entrypoint.sh

# Install MongoDB client tools and curl
RUN apt-get update && \
    apt-get install -y gnupg curl wget && \
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y mongodb-mongosh && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./entrypoint.sh"]
