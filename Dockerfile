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

RUN apk add --no-cache bash \
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
                          curl \
                          git \
                          libstdc++ \
                          openssh \
                          openssl \
                          perl \
                          tar \
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
    # Install nvm and node.
    && cd \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.7/install.sh | bash \
    && sudo chown root:root /home/container/.nvm \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> $HOME/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> $HOME/.bashrc \
    && bash -c 'source $HOME/.nvm/nvm.sh            && \
                nvm install node                    && \
                npm install -g doctoc urchin        && \
                npm install --prefix "$HOME/.nvm/"' \
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
    && sudo apk del dev-dependencies \
    && rm -rf /var/cache/apk/* \
    # Test that h2o installed.
    && h2o -v

# Expose the HTTP port
EXPOSE 80

# Copy entrypoint
COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
