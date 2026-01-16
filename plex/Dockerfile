FROM archlinux:base-devel AS builder
WORKDIR /build/plex-media-server-plexpass

ARG PLEX_VERSION=1.43.0.10389
ARG PLEX_PKG_SUM=8be686aa6
ADD --link https://github.com/archlinux/aur.git#plex-media-server-plexpass /build/plex-media-server-plexpass
ADD --link https://downloads.plex.tv/plex-media-server-new/${PLEX_VERSION}-${PLEX_PKG_SUM}/redhat/plexmediaserver-${PLEX_VERSION}-${PLEX_PKG_SUM}.x86_64.rpm plexmediaserver-${PLEX_VERSION}-${PLEX_PKG_SUM}.x86_64.rpm
RUN useradd -m nonroot && chown -R nonroot:nonroot /build
USER nonroot
RUN makepkg --noconfirm -s && mv plex-media-server-plexpass-*.pkg.tar.zst /build/plex-media-server-plexpass.pkg.tar.zst

FROM archlinux:base
RUN useradd -r -d /config -s /usr/bin/nologin plex
RUN --mount=type=bind,from=builder,source=/build/plex-media-server-plexpass.pkg.tar.zst,target=/plex.pkg.tar.zst \
    pacman -U --noconfirm /plex.pkg.tar.zst
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_TMPDIR="/tmp" \
    PLEX_MEDIA_SERVER_USER="plex"
USER plex
VOLUME [ "/config" ]
CMD [ "/usr/lib/plexmediaserver/Plex Media Server" ]