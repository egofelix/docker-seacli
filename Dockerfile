FROM debian:buster-slim

MAINTAINER EgoFelix <docker@egofelix.de>

# Copy over the assets.
COPY docker-entrypoint.sh /entrypoint.sh

# Install seaf-cli and oathtool, prepare the user.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
      apt-transport-https gnupg ca-certificates && \
    apt-key adv --fetch-keys https://linux-clients.seafile.com/seafile.asc && \
    mkdir -p /etc/apt/sources.list.d/ && \
    echo "deb https://linux-clients.seafile.com/seafile-deb/buster/ stable main" > /etc/apt/sources.list.d/seafile.list && \
    apt-get update && apt-get install --no-install-recommends -y \
      seafile-cli && \
    apt-get purge --yes gnupg && apt-get autoremove --yes && \
    apt-get clean && apt-get autoclean && \
    rm -rf \
        /var/log/fsck/*.log \
        /var/log/apt/*.log \
        /var/cache/debconf/*.dat-old \
        /var/lib/apt/lists/* && \
    mkdir /library/ && \
    mkdir /root/.seafile && \
    chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
