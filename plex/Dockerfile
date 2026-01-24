FROM alpine:3.16 AS base

FROM base AS downloader
RUN apk add --no-cache dpkg
ARG PLEX_URL=https://downloads.plex.tv/plex-media-server-new/1.43.0.10467-2b1ba6e69/debian/plexmediaserver_1.43.0.10467-2b1ba6e69_amd64.deb
ADD --link ${PLEX_URL} plex.deb
RUN dpkg -x /plex.deb /downloaded && \
  cd /downloaded/usr/lib/plexmediaserver/lib && \
  rm -f libdrm*.so* libva*.so* libgcompat.so.0 libc.so* ld-musl-x86_64.so.1

FROM base AS dev
RUN --mount=type=cache,target=/var/cache/apk apk add build-base clang lld llvm-dev pkgconf linux-headers py3-pip cmake openssl-dev ninja
ENV CC=clang \
    CXX=clang++ \
    AR=llvm-ar \
    CFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    CXXFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    LDFLAGS="-gz -Wl,-O1,--as-needed,--sort-common,-z,now,-z,pack-relative-relocs,-z,relro,-fuse-ld=lld" \
    SOURCE_DATE_EPOCH=0

RUN pip3 install meson==1.10.0 

FROM dev AS libdrm
ARG LIBDRM_VERSION=2.4.131
ADD --link https://gitlab.freedesktop.org/mesa/libdrm/-/archive/libdrm-${LIBDRM_VERSION}/libdrm-libdrm-${LIBDRM_VERSION}.tar.bz2 /libdrm.tar.bz2
WORKDIR /libdrm
RUN --mount=type=cache,target=/libdrm/build <<EOF sh -euo pipefail
tar -xf /libdrm.tar.bz2 --strip-components=1
meson setup --reconfigure build \
  -Dprefix=/usr \
  -Damdgpu=enabled \
  -Dradeon=enabled \
  -Dintel=disabled \
  -Dnouveau=disabled \
  -Dvmwgfx=disabled \
  -Dtegra=disabled \
  -Dvalgrind=disabled \
  -Dudev=false \
  -Dtests=false || ( cat build/meson-logs/meson-log.txt ; false )
meson compile -C build
DESTDIR=/staging meson install -C build
EOF

FROM dev AS libva
ARG LIBVA_VERSION=2.23.0
ADD --link https://github.com/intel/libva/archive/refs/tags/2.23.0.tar.gz /libva.tar.gz
WORKDIR /libva
COPY --link --from=libdrm /staging /

RUN --mount=type=cache,target=/libva/build <<EOF sh -euo pipefail
tar -xf /libva.tar.gz --strip-components=1
meson setup --reconfigure build \
  -Dprefix=/usr \
  -Ddriverdir=/usr/lib/dri \
  -Dwith_x11=no \
  -Dwith_wayland=no || ( cat build/meson-logs/meson-log.txt ; false )
meson compile -C build
DESTDIR=/staging meson install -C build
EOF

FROM dev AS mesa-va
RUN --mount=type=cache,target=/var/cache/apk apk add py3-mako py3-yaml py3-pip elfutils-dev bison flex
ARG MESA_VERSION=25.3.4
ADD --link https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-${MESA_VERSION}/mesa-mesa-${MESA_VERSION}.tar.bz2 /mesa.tar.bz2
WORKDIR /mesa
COPY --link --from=libdrm /staging /
COPY --link --from=libva /staging /
RUN --mount=type=cache,target=/mesa/build <<EOF sh -euo pipefail
tar -xf /mesa.tar.bz2 --strip-components=1

export CFLAGS="$(echo "\$CFLAGS" | sed 's/-flto=thin//')"
export CXXFLAGS="$(echo "\$CXXFLAGS" | sed 's/-flto=thin//')"

meson setup  --reconfigure build \
  -Db_lto=true \
  -Dprefix=/usr \
  -Dbuildtype=release \
  -Dplatforms= \
  -Dgallium-drivers=radeonsi \
  -Dvulkan-drivers= \
  -Dgallium-va=enabled \
  -Dvideo-codecs=all \
  -Dopengl=false \
  -Dgles1=disabled \
  -Dgles2=disabled \
  -Dglx=disabled \
  -Degl=disabled \
  -Dgbm=disabled \
  -Dllvm=disabled \
  -Dshared-llvm=disabled \
  -Dvalgrind=disabled \
  -Dlibunwind=disabled \
  -Dzstd=disabled \
  -Dbuild-tests=false || ( cat build/meson-logs/meson-log.txt ; false )

meson compile -C build
DESTDIR=/staging meson install -C build
EOF


FROM dev AS vainfo
ADD --link https://github.com/intel/libva-utils.git /libva-utils

COPY --link --from=libdrm /staging /
COPY --link --from=libva /staging /
WORKDIR /libva-utils
RUN <<EOF sh -euo pipefail
meson setup build \
  -Ddrm=true \
  -Dx11=false \
  -Dwayland=false \
  -Dtests=false || ( cat build/meson-logs/meson-log.txt ; false )
ninja -C build vainfo/vainfo
mv build/vainfo/vainfo /vainfo
EOF


FROM base
RUN apk add --no-cache libstdc++ openssl ca-certificates libelf gcompat
COPY --link --from=downloader /downloaded /
COPY --link --from=libdrm /staging/usr/share/libdrm /usr/share/libdrm/
COPY --link --from=libdrm /staging/usr/lib /usr/lib/
COPY --link --from=libva /staging/usr/lib /usr/lib/
COPY --link --chmod=0755 --from=vainfo /vainfo /usr/bin/vainfo
COPY --link --from=mesa-va /staging/usr/lib /usr/lib/
ENV HOME="/config" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    LIBVA_DRIVERS_PATH="/usr/lib/dri"
# USER nonroot:nonroot
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]