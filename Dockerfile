# Use Debian as the base image
FROM debian:bullseye-slim as base

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg2 \
    lsb-release \
    tini \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g pm2 \
    && rm -rf /var/lib/apt/lists/*

# Add MongoDB repository and install MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && apt-get update \
    && apt-get install -y mongodb-org \
    && rm -rf /var/lib/apt/lists/*

# Set environment to production
ENV NODE_ENV=production
ENV MONGO=mongodb://localhost:27017/octofarm

# Create a user 'octofarm' and set up the working directory and permissions
RUN useradd -ms /bin/bash octofarm \
    && mkdir -p /app /scripts /data/db \
    && chown -R octofarm:octofarm /app /scripts /data/db

# Copy the server directory to /app
COPY server /app/server
# Ensure correct working directory
WORKDIR /app/server

# Copy package.json and package-lock.json to /app
COPY server/package.json /app/package.json
COPY server/package-lock.json /app/package-lock.json

# Install dependencies using npm install instead of npm ci
WORKDIR /app
RUN npm install --omit=dev

# Create the /app/docker directory inside the container
RUN mkdir -p /app/docker
WORKDIR /app/docker

# Copy entrypoint.sh to /app/docker/ and ensure it has execute permissions
COPY docker/entrypoint.sh /app/docker/entrypoint.sh
RUN chmod +x /app/docker/entrypoint.sh

# Use tini from /usr/bin to manage the main process and prevent zombie processes
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start MongoDB and then run the OctoFarm application
CMD ["/bin/bash", "./docker/entrypoint.sh"]
