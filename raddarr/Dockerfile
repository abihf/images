
FROM dhi.io/alpine-base:3.23-dev AS base
WORKDIR /app

FROM base AS downloader
ARG RADARR_VERSION=6.1.1.10317
ADD --link https://github.com/Radarr/Radarr/releases/download/v${RADARR_VERSION}/Radarr.develop.${RADARR_VERSION}.linux-musl-core-x64.tar.gz radarr.tar.gz
RUN tar -xzf radarr.tar.gz

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=downloader /app/Radarr/ /app/Radarr/

VOLUME ["/config"]
EXPOSE 7878

ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/Radarr/Radarr", "--nobrowser", "--data=/config" ]
