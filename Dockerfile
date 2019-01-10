FROM docker:18.06.1-ce

MAINTAINER Dmitry Morgachev <izonder@gmail.com>

ENV NODE_VERSION=v10.15.0 \
    NODE_PREFIX=/usr \
    YARN_VERSION=v1.13.0 \
    YARN_PREFIX=/usr/share/yarn \
    YARN_BINARY=/usr/bin

RUN set -x \

##############################################################################
# Install dependencies
##############################################################################

    && apk add --no-cache \
        ca-certificates \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        libstdc++ \
        linux-headers \
        make \
        paxctl \
        python \

##############################################################################
# Install Node
# Based on https://github.com/mhart/alpine-node/blob/master/Dockerfile (thank you)
# Note: we use ipv4.pool.sks-keyservers.net instead of ha.pool.sks-keyservers.net
# due to the issue: https://bugs.launchpad.net/ubuntu/+source/gnupg2/+bug/1625845
##############################################################################

    # Download and validate the NodeJs source
    && gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        56730D5401028683275BD23C23EFEFE93C4CFFFE \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    && mkdir /node_src \
    && cd /node_src \
    && curl -o node-${NODE_VERSION}.tar.gz -sSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz \
    && curl -o SHASUMS256.txt.asc -sSL https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt.asc \
    && gpg --verify SHASUMS256.txt.asc \
    && grep node-${NODE_VERSION}.tar.gz SHASUMS256.txt.asc | sha256sum -c - \

    # Compile and install
    && cd /node_src \
    && tar -zxf node-${NODE_VERSION}.tar.gz \
    && cd node-${NODE_VERSION} \
    && export GYP_DEFINES="linux_use_gold_flags=0" \
    && ./configure --prefix=${NODE_PREFIX} --without-npm --fully-static \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && make -j${NPROC} -C out mksnapshot BUILDTYPE=Release \
    && paxctl -cm out/Release/mksnapshot \
    && make -j${NPROC} \
    && make install \
    && paxctl -cm ${NODE_PREFIX}/bin/node \

##############################################################################
# Install yarn
##############################################################################

    && curl -o /tmp/yarn-${YARN_VERSION}.tar.gz -sSL https://github.com/yarnpkg/yarn/releases/download/${YARN_VERSION}/yarn-${YARN_VERSION}.tar.gz \
    && tar -zxf /tmp/yarn-${YARN_VERSION}.tar.gz -C /tmp \
    && mv -f /tmp/yarn-${YARN_VERSION} ${YARN_PREFIX} \
    && ln -sf ${YARN_PREFIX}/bin/yarn ${YARN_BINARY}/yarn \
    && ln -sf ${YARN_PREFIX}/bin/yarnpkg ${YARN_BINARY}/yarnpkg \

##############################################################################
# Clean up
##############################################################################

    && apk del \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        libstdc++ \
        linux-headers \
        make \
        paxctl \
        python \

    && rm -rf \
        /node_src \
        /tmp/* \
        /var/cache/apk/* \
        ${NODE_PREFIX}/share/man \
        ${NODE_PREFIX}/lib/node_modules \
        ${NODE_PREFIX}/include
