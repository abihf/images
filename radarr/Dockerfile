
FROM dhi.io/alpine-base:3.24-dev AS base
WORKDIR /app

FROM base AS downloader
ARG RADARR_VERSION=6.4.0.10523
ADD --link https://github.com/Radarr/Radarr/releases/download/v${RADARR_VERSION}/Radarr.master.${RADARR_VERSION}.linux-musl-core-x64.tar.gz radarr.tar.gz
RUN tar -xzf radarr.tar.gz && \
  mv Radarr bin && \
  rm -rf "bin/Radarr.Update" && rm radarr.tar.gz
COPY <<EOF "package_info"
PackageVersion=${RADARR_VERSION}
PackageAuthor=[abihf](https://github.com/abihf/images)
UpdateMethod=Docker
Branch=master
EOF

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=downloader /app/ /app/
ENV COMPlus_EnableDiagnostics=0

VOLUME ["/config"]
EXPOSE 7878
WORKDIR /app/bin

ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/bin/Radarr", "--nobrowser", "--data=/config" ]
