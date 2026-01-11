FROM --platform=$BUILDPLATFORM dhi.io/alpine-base:3.23-dev AS base

# runtime dependencies
RUN --mount=type=cache,target=/var/cache/apk \
  apk add \
    7zip \
    bash \
    curl \
    libcrypto3 \
    libssl3 \
    python3 \
    qt6-qtbase \
    qt6-qtbase-sqlite \
    tini \
    tzdata \
    zlib


# image for building
FROM base AS builder

# alpine linux packages:
# https://git.alpinelinux.org/aports/tree/community/libtorrent-rasterbar/APKBUILD
# https://git.alpinelinux.org/aports/tree/community/qbittorrent/APKBUILD
RUN --mount=type=cache,target=/var/cache/apk \
  apk add \
    cmake \
    extra-cmake-modules \
    git \
    clang \
    llvm-dev \
    lld \
    make \
    ninja \
    openssl-dev \
    qt6-qtbase-dev \
    qt6-qtbase-private-dev \
    qt6-qttools-dev \
    zlib-dev

ENV CC=clang \
    CXX=clang++ \
    AR=llvm-ar \
    CFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    CXXFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    LDFLAGS="-gz -Wl,-O1,--as-needed,--sort-common,-z,now,-z,pack-relative-relocs,-z,relro,-fuse-ld=lld" \
    SOURCE_DATE_EPOCH=0
 
# prepare boost
ARG BOOST_TAG=boost-1.90.0
ADD --link https://github.com/boostorg/boost/releases/download/${BOOST_TAG}/${BOOST_TAG}-b2-nodocs.tar.xz boost.tar.xz
RUN \
  tar -xf boost.tar.xz && \
  mv boost-* boost && \
  cd boost && \
  mkdir -p /tmp && \
  export TMPDIR=/tmp && \
  ./bootstrap.sh --with-toolset=clang && \
  ./b2 stage --stagedir=./ --with-headers

# build libtorrent
ARG LIBBT_COMMIT=15f596ece8afe3bc09e1c95eb527166bf8417526
ADD --link https://github.com/arvidn/libtorrent.git#${LIBBT_COMMIT} libtorrent
RUN --mount=type=cache,target=/app/libtorrent/build \
  cd libtorrent && \
  cmake \
    -B build \
    -G Ninja \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=20 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
    -DBOOST_ROOT=/boost/lib/cmake \
    -Ddeprecated-functions=OFF && \
  cmake --build build -j $(nproc) && \
  cmake --install build

# build qbittorrent
ARG QBT_COMMIT=e2091541aa7caee2ea85f63cb3055ef58a3dd93a
ADD --link https://github.com/qbittorrent/qBittorrent.git#${QBT_COMMIT} qBittorrent
RUN --mount=type=cache,target=/app/qBittorrent/build \
  cd qBittorrent && \
  cmake \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
    -DBOOST_ROOT=/boost/lib/cmake \
    -DGUI=OFF && \
  cmake --build build -j $(nproc) && \
  cmake --install build


# image for running
FROM base
COPY --link --from=builder /usr/bin/qbittorrent-nox /usr/bin/qbittorrent-nox
VOLUME /config
ENTRYPOINT [ "tini", "--" ]
CMD [ "qbittorrent-nox", "--webui-port=8080", "--profile=/config" ]
