# syntax=docker/dockerfile:1.7

ARG DEBIAN_VERSION=12

# STAGE 1 - build
FROM debian:${DEBIAN_VERSION}-slim AS build

# BUILD FROM SOURCE:
ARG APP_VERSION=v4.1.1

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/tmp/build \
    apt-get update \
    && echo "Installing dependencies ..." \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    make \
    cmake \
    nasm \
    pkg-config \
    libpng-dev \
    zlib1g-dev \
    perl \
    && echo "Building mozjpeg ..." \
    && git clone https://github.com/mozilla/mozjpeg.git /tmp/build \
    && cd /tmp/build \
    && git checkout ${APP_VERSION} \
    && mkdir build && cd build \
    && cmake -G"Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DENABLE_STATIC=ON \
    -DENABLE_SHARED=OFF \
    .. \
    && make -j$(nproc) \
    && make install \
    && echo "Building mozjpeg ... OK" 

# STAGE 2 - RELEASE
FROM debian:${DEBIAN_VERSION}-slim AS release
COPY --from=build /usr/local/bin /usr/local/bin

# define app userspace
WORKDIR /app
CMD [ "cjpeg" ]
