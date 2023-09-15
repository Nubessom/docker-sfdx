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
RUN mkdir -p /usr/local/cli/sf 
RUN wget -qO- https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz | tar xJ -C /usr/local/cli/sf --strip-components 1


### LAST STAGE
FROM debian:stable-slim as run
###

# Install openssl for key decryption
RUN apt-get update \
    && apt-get install --assume-yes openssl \
				    ca-certificates-java \
                                    jq \
                                    curl \
                                    git \
                                    openjdk-17-jdk-headless

# Clean up
RUN apt-get autoremove --assume-yes \
    && apt-get clean --assume-yes \
    && rm -rf /var/lib/apt/lists/*

# Setup CLI exports
ENV SF_AUTOUPDATE_DISABLE=false \
    SF_DOMAIN_RETRY=300 \
    SF_LOG_LEVEL=debug \
    SF_PROJECT_AUTOUPDATE_DISABLE_FOR_PACKAGE_CREATE=true \
    SF_PROJECT_AUTOUPDATE_DISABLE_FOR_PACKAGE_VERSION_CREATE=true \
    SF_DISABLE_TELEMETRY=true \
    TERM=xterm-256color

ENV PATH=/usr/local/cli/sf/bin:$PATH

#Move SF CLI from BUILD stage
COPY --from=build /usr/local/cli/sf /usr/local/cli/sf

# Installing CLI Plugins for Packaging - https://github.com/salesforcecli/plugin-packaging
RUN sf plugins install @salesforce/plugin-packaging

# Install sfdx scanner plagin - https://forcedotcom.github.io/sfdx-scanner/
RUN sf plugins install @salesforce/sfdx-scanner

# install SFDX-Git-Delta plugin - https://github.com/scolladon/sfdx-git-delta
RUN echo y | sf plugins install sfdx-git-delta

# Show version of Salesforce CLI
RUN sf --version && sf plugins --core

