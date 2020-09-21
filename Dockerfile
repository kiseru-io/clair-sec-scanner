FROM debian:buster-20200720-slim

MAINTAINER kiseru.io

# https://docs.docker.com/develop/sdk/#docker-ee-and-ce-api-mismatch
ENV DOCKER_API_VERSION=1.37

EXPOSE 9279

# install docker engine
RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install  --no-install-suggests apt-transport-https ca-certificates gnupg curl -y && \
    sh -c "echo deb https://apt.dockerproject.org/repo debian-jessie main > /etc/apt/sources.list.d/docker.list" && \ 
    apt-key adv --list-public-keys --with-fingerprint --with-colons && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    apt-get update && \
    apt-cache policy docker-engine && \
    apt-get install --no-install-recommends --no-install-suggests docker -y

# add clair-scanner binary
RUN curl -ksL https://github.com/arminc/clair-scanner/releases/download/v12/clair-scanner_linux_amd64 -o /usr/local/bin/clair-scanner && \
    chmod +x /usr/local/bin/clair-scanner && touch /usr/local/default-whitelist.yaml

# override with docker-compose
CMD []
