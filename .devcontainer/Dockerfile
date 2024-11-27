# https://docs.docker.com/reference/dockerfile/

FROM ubuntu:24.04

WORKDIR /workdir

# ------------------------------------------------------------------------------

RUN \
    apt-get \
        update \
    && \
    apt-get \
        install \
            --assume-yes \
            git \
            gnupg2 \
    && \
    apt-get \
        clean \
    && \
    echo;

# ------------------------------------------------------------------------------

RUN \
    apt-get \
        install \
            --assume-yes \
            make \
            file \
            jq \
            curl \
            exiftool \
            nodejs \
            imagemagick \
    && \
    apt-get \
        clean \
    && \
    echo;
