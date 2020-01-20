# Set base image
FROM debian:stable-slim as run

# Install openssl for key decryption and curl
RUN apt-get update && apt-get install -y openssl \
                                         curl

RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs

RUN npm install sfdx-cli --global

# Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN npm cache clean --force

# Setup CLI exports
ENV SFDX_AUTOUPDATE_DISABLE=false \
    SFDX_DOMAIN_RETRY=300 \
    SFDX_DISABLE_APP_HUB=true \
    SFDX_LOG_LEVEL=DEBUG \
    TERM=xterm-256color
