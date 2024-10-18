# Use Debian as the base image and install Node.js 18.x from the official Node.js repository
FROM debian:bullseye-slim as base

# Install dependencies: Node.js 18.x, npm, tini (for process management), and necessary tools
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg2 \
    tini \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pm2 \
    && rm -rf /var/lib/apt/lists/*

# Set the environment to production
ENV NODE_ENV=production

# Create a user 'octofarm' and set up the working directory and permissions
RUN useradd -ms /bin/bash octofarm \
    && mkdir -p /app /scripts \
    && chown -R octofarm:octofarm /app /scripts

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

# Switch to the 'octofarm' user and set the working directory
USER octofarm
WORKDIR /app

# Ensure the entrypoint script has execute permissions
RUN chmod +x ./docker/entrypoint.sh

# Use tini to manage the main process and prevent zombie processes
ENTRYPOINT ["/usr/bin/tini", "--"]

# Default command to start the application
CMD ["./docker/entrypoint.sh"]
