############################
# Version v0.2.3.alpha

# Base Alpine Image
FROM gliderlabs/alpine:edge

# Maintainer Meta
MAINTAINER Connor Hartley <vectrixu@gmail.com>

# H2O Variables
ENV H2O_ID       h2o
ENV H2O_URL      https://github.com/h2o/h2o.git
ENV H2O_VERSION  tags/v2.2.4

# Node Variables
ENV NODE_VERSION 8.9.4

# Install
RUN apk update \
    # Dependencies
    && apk add --no-cache bash \
                          build-base \
                          curl \
                          git \
                          libstdc++ \
                          openssh \
                          openssl \
                          perl \
                          sudo \
                          tar \
                          unzip \
                          zip \
    # Dev Dependencies
    && apk --update add --virtual dev-dependencies \
                                  bison \
                                  ca-certificates \
                                  cmake \
                                  linux-headers \
                                  ruby \
                                  ruby-dev \
                                  zlib-dev \
    # Install nvm and node.
    && cd \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    # Test that node / npm installed.
    && node -v \
    && npm -v \
    # Clone h2o, build it, then remove the source.
    && git clone ${H2O_URL} ${H2O_ID} \
    && cd ${H2O_ID} \
    && git checkout ${H2O_VERSION} \
    && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on . \
    && make install \
    && cd .. \
    && rm -rf h2o \
    && apk del dev-dependencies \
    && rm -rf /var/cache/apk/* \
    # Test that h2o installed.
    && h2o -v

# Setup account container
RUN adduser -u 1000 -D -h /home/container container \
    && echo "ALL            ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers \
    && chown root:root /usr/bin \
    && chmod u+s /usr/bin/sudo

# User to run the dockerfile as
USER container
ENV USER container
ENV HOME /home/container

WORKDIR /home/container

# Expose the HTTP port
EXPOSE 80

# Copy entrypoint
COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
