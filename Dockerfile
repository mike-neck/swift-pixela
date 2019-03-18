FROM ubuntu:18.04

ARG UBUNTU18=ubuntu18.04
ARG SWIFT5=swift-5.0-DEVELOPMENT-SNAPSHOT-2019-03-10-a

ENV PLATFORM=$UBUNTU18 \
    SWIFT_VER=$SWIFT5

VOLUME /project

RUN \
    apt-get -q update -y && \
    apt-get -q install -y \
        libc6-dev \
        curl \
        clang-7 \
        libxml2 \
        libssl-dev \
        libicu-dev \
        git \
        libcurl4-openssl-dev \
        pkg-config && \
    SWIFT_URL=https://swift.org/builds/swift-5.0-branch/`echo "$PLATFORM" | tr -d .`/$SWIFT_VER/${SWIFT_VER}-{$PLATFORM}.tar.gz && \
    curl -L $SWIFT_URL -o swift.tar.gz && \
    tar -xzf swift.tar.gz --directory / --strip-components=1 && \
    chmod -R o+r /usr/lib/swift && \
    rm swift.tar.gz
