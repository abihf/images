FROM scratch AS downloader

ARG PLEX_URL=https://downloads.plex.tv/plex-media-server-new/1.43.0.10389-8be686aa6/debian/plexmediaserver_1.43.0.10389-8be686aa6_amd64.deb
ADD --link ${PLEX_URL} plex.deb

FROM ubuntu:24.04
RUN --mount=type=bind,from=downloader,source=/plex.deb,target=/plex.deb \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y /plex.deb libva2 libva-drm2 libdrm2 libdrm-amdgpu1 mesa-va-drivers vainfo
ENV HOME="/config" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    LIBVA_DRIVERS_PATH="/usr/lib/x86_64-linux-gnu/dri"
USER nonroot:nonroot
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]