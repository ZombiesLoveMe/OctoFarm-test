# Use Debian as the base image
FROM debian:bullseye-slim as base

# Install common dependencies: curl, ca-certificates, gnupg2, tini, and wget
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg2 \
    lsb-release \
    tini \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x from NodeSource (handle errors more gracefully)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y --fix-missing --fix-broken nodejs \
    && npm install -g pm2 \
    && rm -rf /var/lib/apt/lists/*

# Add MongoDB repository and install MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && apt-get update \
    && apt-get install -y --fix-missing --fix-broken mongodb-org \
    && rm -rf /var/lib/apt/lists/*

# Set environment to production
ENV NODE_ENV=production
ENV MONGO=mongodb://localhost:27017/octofarm

# Create a user 'octofarm' and set up the working directory and permissions
RUN useradd -ms /bin/bash octofarm \
    && mkdir -p /app /scripts /data/db \
    && chown -R octofarm:octofarm /app /scripts /data/db

# Build stage
FROM base as builder

# Install build dependencies for compiling native addons
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for the build
WORKDIR /tmp/app

# Copy server-side package files
COPY server/package.json ./server/package.json
COPY server/package-lock.json ./server/package-lock.json

WORKDIR /tmp/app/server

# Install production dependencies using npm ci
RUN npm ci --omit=dev

# Runtime stage
FROM base as runtime

# Copy the compiled node_modules from the builder stage
COPY --chown=octofarm:octofarm --from=builder /tmp/app/server/node_modules /app/server/node_modules

# Copy the rest of the application files and set ownership to 'octofarm'
COPY --chown=octofarm:octofarm . /app

# Set up MongoDB to run with the container
# Initialize MongoDB on container startup and create the OctoFarm database
RUN echo '#!/bin/bash\n\
mongod --fork --logpath /var/log/mongod.log --dbpath /data/db --bind_ip_all\n\
npm run build-client\n\
exec "$@"' > /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

# Switch to the 'octofarm' user and set the working directory
USER octofarm
WORKDIR /app

# Ensure the entrypoint script has execute permissions
RUN chmod +x ./docker/entrypoint.sh

# Use tini to manage the main process and prevent zombie processes
ENTRYPOINT ["/sbin/tini", "--"]

# Start MongoDB and then run the OctoFarm application
CMD ["/bin/bash", "/docker-entrypoint.sh", "./docker/entrypoint.sh"]
