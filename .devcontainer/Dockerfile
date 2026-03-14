FROM alpine:latest

RUN apk add --no-cache \
    docker-cli \
    docker-compose \
    bash \
    git \
    curl \
    openssh-client

ENV DOCKER_API_VERSION=1.43
ENV SHELL=/bin/bash

USER root

CMD ["/bin/bash"]
