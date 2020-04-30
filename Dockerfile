FROM debian:stable-slim

LABEL "com.github.actions.name"="Cloud Foundry Plugin CLI"
LABEL "com.github.actions.description"="Deploy and manage Cloud Foundry services (including plugins e.g. for zero-downtime deployment)"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="blue"

RUN apt-get update
RUN apt-get install -y ca-certificates uuid-runtime jq wget

RUN echo "deb [trusted=yes] https://packages.cloudfoundry.org/debian stable main" > /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN apt-get update
RUN apt-get install -y cf-cli

# RUN cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org && \
#     cf install-plugin -f -r CF-Community cf-puppeteer
ADD cf-puppeteer-linux /cf-puppeteer-linux
# RUN cf install-plugin -f /cf-puppeteer-linux

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
