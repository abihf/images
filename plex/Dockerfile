FROM dhi.io/alpine-base:3.24-dev AS base

FROM base AS downloader
RUN apk add --no-cache dpkg
ARG PLEX_URL=https://downloads.plex.tv/plex-media-server-new/1.43.5.11079-b3b13e506/debian/plexmediaserver_1.43.5.11079-b3b13e506_amd64.deb
ADD --link ${PLEX_URL} plex.deb
RUN dpkg -x /plex.deb /downloaded 

FROM base
RUN apk add --no-cache libstdc++ ca-certificates libelf gcompat
COPY --link --from=downloader /downloaded /

ENV HOME="/config" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    LIBVA_DRIVERS_PATH="/usr/lib/dri"
# USER nonroot:nonroot
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]