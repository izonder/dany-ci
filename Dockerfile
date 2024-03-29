FROM docker:23.0

MAINTAINER Dmitry Morgachev <izonder@gmail.com>

ENV NODE_VERSION=v18.16.0 \
    NODE_PREFIX=/usr \
    NODE_RELEASE_KEYS=https://raw.githubusercontent.com/nodejs/release-keys/HEAD \
    YARN_VERSION=v1.22.19 \
    YARN_PREFIX=/usr/share/yarn \
    YARN_BINARY=/usr/bin

RUN set -eux \
\
##############################################################################
# Prepare user
##############################################################################
\
    && addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
\
##############################################################################
# Install dependencies
##############################################################################
\
    && apk add --no-cache libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
        xz \
\
##############################################################################
# Install Node
# Based on https://github.com/mhart/alpine-node/blob/master/Dockerfile (thank you)
# New PGP keyservers due to: https://github.com/nodejs/docker-node/issues/1500
##############################################################################
\
    # gpg keys from https://github.com/nodejs/release-keys \
    && for KEY_ID in $(curl -sSL "${NODE_RELEASE_KEYS}/keys.list" | xargs); do \
        curl -sSL "${NODE_RELEASE_KEYS}/keys/${KEY_ID}.asc" | gpg --import; \
    done \
\
    # Download and validate the NodeJs source
    && mkdir /node_src \
    && cd /node_src \
    && curl -o node-${NODE_VERSION}.tar.xz -fsSLO --compressed https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.xz \
    && curl -o SHASUMS256.txt.asc -fsSLO --compressed https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt.asc \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-${NODE_VERSION}.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
\
    # Compile and install
    && cd /node_src \
    && tar -Jxpf node-${NODE_VERSION}.tar.xz \
    && cd node-${NODE_VERSION} \
    && ./configure --prefix=${NODE_PREFIX} --without-npm \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
\
##############################################################################
# Install yarn
##############################################################################
\
    && for server in \
        keyserver.ubuntu.com \
        keys.openpgp.org \
   ; do \
        gpg --keyserver $server --recv-keys \
            6A010C5166006599AA17F08146C2130DFD2497F5 \
        && break; \
    done \
\
    # Download, validate and install the Yarn source
    && curl -o /tmp/yarn-${YARN_VERSION}.tar.gz -sSL https://github.com/yarnpkg/yarn/releases/download/${YARN_VERSION}/yarn-${YARN_VERSION}.tar.gz \
    && curl -o /tmp/yarn-${YARN_VERSION}.tar.gz.asc -sSL https://github.com/yarnpkg/yarn/releases/download/${YARN_VERSION}/yarn-${YARN_VERSION}.tar.gz.asc \
    && gpg --verify /tmp/yarn-${YARN_VERSION}.tar.gz.asc \
    && tar -zxf /tmp/yarn-${YARN_VERSION}.tar.gz -C /tmp \
    && mv -f /tmp/yarn-${YARN_VERSION} ${YARN_PREFIX} \
    && ln -sf ${YARN_PREFIX}/bin/yarn ${YARN_BINARY}/yarn \
    && ln -sf ${YARN_PREFIX}/bin/yarnpkg ${YARN_BINARY}/yarnpkg \
\
##############################################################################
# Clean up
##############################################################################
\
    && apk del .build-deps \
    && rm -rf \
        /node_src \
        /tmp/* \
        /var/cache/apk/* \
        /usr/share/man
