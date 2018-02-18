############################
# Website Deployment using
# - Git (Source)
# - Node / NPM (Building)
# - H2O (Serving)

# Base Alpine Image
FROM gliderlabs/alpine:3.4

# Maintainer Meta
MAINTAINER Connor Hartley <vectrixu@gmail.com>

# Install common dependencies
RUN apk --no-cache add \
        curl \
        ca-certificates \
        zip \
        unzip \
        openssl \
        openssh \
        sudo \
        tar \
        bash \
        git \
        nodejs \
        build-base

# Install application dependencies
RUN apk --no-cache add --virtual build-dependencies \
        cmake \
        ninja-build \
        mruby \
        libmruby-dev \
        checkinstall \
        python-sphinx \
        libcunit1-dev \
        nettle-dev \
    && git clone ${LIBUV_EXTRA_ARGS} https://github.com/libuv/libuv \
      	&& cd libuv \
        && sh autogen.sh \
        && ./configure \
        && make -j $(($(nproc)+1)) \
        && make install \
    && git clone ${WSLAY_EXTRA_ARGS} https://github.com/tatsuhiro-t/wslay \
        && cd wslay \
        && cmake -G 'Ninja' . \
      	&& ninja \
      	&& ninja install \
    && git clone ${H2O_EXTRA_ARGS} https://github.com/h2o/h2o --recursive \
        && cd h2o \
        && cmake -G 'Ninja' -DWITH_BUNDLED_SSL=OFF . \
        && ninja \
        && ninja install \
    && mkdir -p /etc/h2o /var/run/h2o /var/log/h2o \
    && touch /var/run/h2o/access-log /var/run/h2o/error-log \
    && apk del build-dependencies

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
