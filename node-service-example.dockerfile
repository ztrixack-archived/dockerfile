# Dockerfile

# ---- Dependencies Stage ----
# Pull nodejs 8.11.2 into the container (based on alpine).
FROM ztrixack/node:1.0.0 AS dependencies

# Set environment variables.
ENV WORKSPACE="/src" \
    TEMP="/tmp"

# Create workspace.
RUN mkdir -p $WORKSPACE $TEMP

# Copy app source to workspace.
COPY . $TEMP

# install node packages.
# install ALL node_modules, including 'devDependencies'.
RUN cd $TEMP && \
    npm install && \
    npm install --only=dev && \
    # Build for production with minification.
    npm run build --production && \
    # Remove node_modules
    rm -rf -R node_modules && \
    # install production node_modules.
    npm install --only=production && \
    # clean cache
    npm cache clean --force && \
    # remove unnecessary files
    find . \( \
        -type d -name "test*" -o \
        -type f -name "*.spec.*" -o \
        -type f -name "*.md" -o \
        -type f -name "VERSION" -o \
        -type f -name "LICENSE" -o \
        -type f -name "license" -o \
        -type f -name "Makefile" \
        \) -print0 | xargs -0 -I {} /bin/rm -rf "{}" && \
    # zip production files
    tar -cf $WORKSPACE/production.tar node_modules build processes.json && \
    # Remove all temp file
    rm -rf -R $TEMP

# ---- Release Stage ----
# Pull nodejs with pm2 into the container (based on alpine).
FROM ztrixack/node-service:1.0.0 AS release

# copy production files
COPY --from=dependencies /src/production.tar ./

# extract files
RUN tar -xf production.tar && \
    rm -rf -R production.tar && \
    touch .env

# Set the command to start the node server.
CMD pm2 start --no-daemon processes.json