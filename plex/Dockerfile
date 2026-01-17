FROM scratch AS downloader

ARG PLEX_URL=https://downloads.plex.tv/plex-media-server-new/1.43.0.10389-8be686aa6/debian/plexmediaserver_1.43.0.10389-8be686aa6_amd64.deb
ADD --link ${PLEX_URL} plex.deb

FROM dhi.io/debian-base:trixie
RUN --mount=type=bind,from=downloader,source=/plex.deb,target=/plex.deb \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y /plex.deb libva2 libva-drm2 mesa-va-drivers
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_TMPDIR="/tmp" \
    PLEX_MEDIA_SERVER_USER="plex" \
    LD_LIBRARY_PATH="/usr/lib/plexmediaserver/lib:/usr/lib:/usr/lib/x86_64-linux-gnu" \
    LIBVA_DRIVERS_PATH="/usr/lib/x86_64-linux-gnu/dri"
USER nonroot:nonroot
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]