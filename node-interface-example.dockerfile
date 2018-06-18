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
    # Build for production with minification.
    npm run build --production && \
    # clean cache
    npm cache clean --force && \
    # zip production files
    tar -cf $WORKSPACE/production.tar build && \
    # Remove all temp file
    rm -rf -R $TEMP

# ---- Release Stage ----
# Pull nodejs with pm2 into the container (based on alpine).
FROM ztrixack/node-interface:1.0.0 AS release

# copy production files
COPY --from=dependencies /src/production.tar ./

# extract files
RUN tar -xf production.tar && \
    rm -rf -R production.tar

# Set the command to start the node server.
CMD serve -s . --port $PORT