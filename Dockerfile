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

# Check if the /app/docker directory exists, if not, create it and then copy the entrypoint.sh script
RUN mkdir -p /app/docker \
    && chmod +x /app/docker

# Copy entrypoint.sh to /app/docker/
COPY docker/entrypoint.sh /app/docker/entrypoint.sh

# Ensure entrypoint.sh has execute permissions
RUN chmod +x /app/docker/entrypoint.sh

# Install dependencies
WORKDIR /app
RUN npm ci --omit=dev

# Use tini from /usr/bin to manage the main process and prevent zombie processes
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start MongoDB and then run the OctoFarm application
CMD ["/bin/bash", "/app/docker/entrypoint.sh"]
