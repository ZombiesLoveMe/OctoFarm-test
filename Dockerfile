# Use Alpine Linux 3.14 as the base image
# Node.js version 14.17.0 is installed from Alpine 3.14's package repository
FROM alpine:3.14 as base

# Install Node.js, npm, and tini for process management
RUN apk add --no-cache --virtual .base-deps \
    nodejs \
    npm \
    tini

# Set the environment to production
ENV NODE_ENV=production

# Install the latest version of npm and pm2 (process manager)
RUN npm install -g npm@latest
RUN npm install -g pm2

# Create a user 'octofarm' and set up the working directory and permissions
RUN adduser -D octofarm --home /app && \
    mkdir -p /scripts && \
    chown -R octofarm:octofarm /scripts/

# Begin the build process
FROM base as compiler

# Install build dependencies for compiling native addons
RUN apk add --no-cache --virtual .build-deps \
    alpine-sdk \
    make \
    gcc \
    g++ \
    python3

# Set working directory to /tmp/app for temporary app build files
WORKDIR /tmp/app

# Copy server-side package files to the build directory
COPY server/package.json ./server/package.json
COPY server/package-lock.json ./server/package-lock.json

# Set working directory to /tmp/app/server for installing server dependencies
WORKDIR /tmp/app/server

# Install production dependencies using npm ci (clean install)
RUN npm ci --omit=dev

# Remove build dependencies after installing server packages to reduce image size
RUN apk del .build-deps

# Reset working directory to /tmp/app
WORKDIR /tmp/app

# Runtime stage for the final image
FROM base as runtime

# Copy the compiled node_modules from the build stage and assign the correct permissions
COPY --chown=octofarm:octofarm --from=compiler /tmp/app/server/node_modules /app/server/node_modules
# Copy the rest of the application files and set ownership to the 'octofarm' user
COPY --chown=octofarm:octofarm . /app

# Clean up temporary files
RUN rm -rf /tmp/app

# Switch to the 'octofarm' user
USER octofarm
# Set the working directory to /app
WORKDIR /app

# Ensure the entrypoint script has execute permissions
RUN chmod +x ./docker/entrypoint.sh

# Use tini as the entrypoint to manage zombie processes
ENTRYPOINT [ "/sbin/tini", "--" ]
# Run the entrypoint script to start the application
CMD ["./docker/entrypoint.sh"]
