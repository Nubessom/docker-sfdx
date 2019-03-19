# Set base image
FROM debian:stable-slim as build

# Configure base image
RUN apt-get update && apt-get install -y wget \
                                         xz-utils
                       
# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI binary
WORKDIR /
RUN mkdir /sfdx
RUN wget -qO- https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz | tar xJ -C sfdx --strip-components 1
RUN /sfdx/install
RUN rm -rf /sfdx

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

COPY --from=build /usr/local/lib/sfdx /usr/local/lib/sfdx
RUN ln -sf /usr/local/lib/sfdx/bin/sfdx /usr/local/bin/sfdx
RUN sfdx update

# Show version of Salesforce CLI
RUN sfdx --version && sfdx plugins --core
