FROM alpine:3.15 AS base

FROM base AS downloader
RUN apk add --no-cache dpkg
ARG PLEX_URL=https://downloads.plex.tv/plex-media-server-new/1.43.0.10467-2b1ba6e69/debian/plexmediaserver_1.43.0.10467-2b1ba6e69_amd64.deb
ADD --link ${PLEX_URL} plex.deb
RUN dpkg -x /plex.deb /downloaded


FROM base AS vainfo
RUN apk add --no-cache meson ninja build-base libva-dev
ADD --link https://github.com/intel/libva-utils.git /libva-utils

RUN --mount=type=cache,target=/libva-utils/build <<EOF sh -euo pipefail
cd /libva-utils
meson setup build \
  -Ddrm=true \
  -Dx11=false \
  -Dwayland=false \
  -Dtests=false
ninja -C build vainfo/vainfo
mv build/vainfo/vainfo /vainfo
EOF


FROM base
RUN apk add --no-cache libstdc++ libva mesa-va-gallium mesa-dri-gallium openssl ca-certificates
COPY --link --from=downloader /downloaded /
COPY --link --chmod=0755 --from=vainfo /vainfo /usr/bin/vainfo
ENV HOME="/config" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    LIBVA_DRIVERS_PATH="/usr/lib/dri"
# USER nonroot:nonroot
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]