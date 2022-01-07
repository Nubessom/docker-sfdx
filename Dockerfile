# Set base image
FROM debian:stable-slim as build

# Configure base image
RUN apt-get update \
    && apt-get install --assume-yes wget \
                                    xz-utils
                                         
                       
# Clean up
RUN apt-get autoremove --assume-yes \
    && apt-get clean --assume-yes \
    && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI binary
WORKDIR /
RUN mkdir -p /usr/local/lib/sfdx
RUN wget -qO- https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz | tar xJ -C /usr/local/lib/sfdx --strip-components 1
RUN ln -sf /usr/local/lib/sfdx/bin/sfdx /usr/local/bin/sfdx

# Make sure we have latest SFDX version and all related plugins
RUN sfdx update

### LAST STAGE
FROM debian:stable-slim as run
###

# Install openssl for key decryption
RUN apt-get update \
    && apt-get install --assume-yes openssl \
                                    jq \
                                    curl \
                                    git \
                                    openjdk-11-jdk-headless

# Clean up
RUN apt-get autoremove --assume-yes \
    && apt-get clean --assume-yes \
    && rm -rf /var/lib/apt/lists/*

# Setup CLI exports
ENV SFDX_AUTOUPDATE_DISABLE=false \
    SFDX_DOMAIN_RETRY=300 \
    SFDX_DISABLE_APP_HUB=true \
    SFDX_LOG_LEVEL=DEBUG \
    SFDX_PROJECT_AUTOUPDATE_DISABLE_FOR_PACKAGE_CREATE=true \
    SFDX_PROJECT_AUTOUPDATE_DISABLE_FOR_PACKAGE_VERSION_CREATE=true \
    SFDX_DISABLE_TELEMETRY=true \
    TERM=xterm-256color

#Move SFDX CLI from BUILD stage
COPY --from=build /usr/local/lib/sfdx /usr/local/lib/sfdx
RUN ln -sf /usr/local/lib/sfdx/bin/sfdx /usr/local/bin/sfdx

# Install sfdx scanner plagin - https://forcedotcom.github.io/sfdx-scanner/
RUN sfdx plugins:install @salesforce/sfdx-scanner

# Show version of Salesforce CLI
RUN sfdx --version && sfdx plugins --core
