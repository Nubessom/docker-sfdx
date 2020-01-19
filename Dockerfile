# Set base image
FROM debian:stable-slim as build

# Configure base image
RUN apt-get update && apt-get install -y curl

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI binary
WORKDIR /
RUN npm install sfdx-cli --global

### LAST STAGE
FROM debian:stable-slim as run
###

# Install openssl for key decryption
RUN apt-get update && apt-get install -y openssl

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Setup CLI exports
ENV SFDX_AUTOUPDATE_DISABLE=false \
    SFDX_DOMAIN_RETRY=300 \
    SFDX_DISABLE_APP_HUB=true \
    SFDX_LOG_LEVEL=DEBUG \
    TERM=xterm-256color

