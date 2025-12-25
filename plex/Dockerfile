FROM scratch AS downloader

ARG PLEX_VERSION=1.42.2.10156-f737b826c
ADD --link https://downloads.plex.tv/plex-media-server-new/${PLEX_VERSION}/debian/plexmediaserver_${PLEX_VERSION}_amd64.deb plex.deb


FROM dhi.io/debian-base:trixie
RUN --mount=type=bind,from=downloader,source=/plex.deb,target=/plex.deb \
    dpkg -i /plex.deb
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_TMPDIR="/tmp" \
    PLEX_MEDIA_SERVER_USER="plex"
USER nonroot:nonroot
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]