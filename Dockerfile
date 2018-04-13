############################
# Version v2.0.0

# Base Alpine Image
FROM gliderlabs/alpine:edge

# Maintainer Meta
MAINTAINER Connor Hartley <vectrixu@gmail.com>

# H2O Variables
ENV H2O_ID       h2o
ENV H2O_URL      https://github.com/h2o/h2o.git
ENV H2O_VERSION  tags/v2.2.4

# Project Variables
ENV PROJECT_ID             launchpad
ENV PROJECT_VERSION        v1
ENV PROJECT_PATH           static/
ENV PROJECT_CONFIG         static/.h2o/h2o.conf
ENV PROJECT_TEMP           temp/

# Github Variables
ENV GITHUB_PROJECT  connorhartley/launchpad
ENV GITHUB_VERSION  tags/v1.0.0
ENV GITHUB_FILE     launchpad-1.0.0-dist.tar.gz
ENV GITHUB_TOKEN    temporary

RUN apk add --no-cache bash \
                       curl \
                       tar \
                       sudo

# Setup account container
RUN adduser -u 1000 -D -h /home/container container \
    && echo "ALL            ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers

# User to run the dockerfile as
USER container
ENV USER container
ENV HOME /home/container

WORKDIR /home/container

# Install
RUN sudo apk update \
    # Dependencies
    && sudo apk add --no-cache build-base \
                          git \
                          libstdc++ \
                          openssh \
                          openssl \
                          perl \
                          unzip \
                          zip \
    # Dev Dependencies
    && sudo apk --update add --virtual dev-dependencies \
                                  bison \
                                  ca-certificates \
                                  cmake \
                                  linux-headers \
                                  ruby \
                                  ruby-dev \
                                  zlib-dev \
    # Clone h2o, build it, then remove the source.
    && git clone ${H2O_URL} ${H2O_ID} \
    && cd ${H2O_ID} \
    && git checkout ${H2O_VERSION} \
    && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on . \
    && sudo make install \
    && cd .. \
    && sudo rm -rf h2o \
    && sudo apk del dev-dependencies \
    && sudo rm -rf /var/cache/apk/* \
    # Test that h2o installed.
    && h2o -v

# Expose the HTTP port
EXPOSE 80

# Copy entrypoint
COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
