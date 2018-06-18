# Dockerfile
# Pull nodejs into the container (based on alpine).
FROM ztrixack/node:1.0.0

# Create tag label for contact me.
LABEL maintainer="ztrixack.th@gmail.com" \
      description="Microservice Build Container" \
      version="1.0.0"

# Set environment variables.
ENV NPM_CONFIG_LOGLEVEL=warn \
    WORKSPACE="/home/src/app"

# Run updates and install deps.
RUN npm install -g pm2 && \
    npm cache clean --force && \
    rm -rf /usr/lib/node_modules/pm2/LICENSE \
        /usr/lib/node_modules/pm2/*.md /usr/lib/node_modules/pm2/GNU-AGPL-3.0.txt && \
    mkdir -p $WORKSPACE

# Create app directory
WORKDIR $WORKSPACE