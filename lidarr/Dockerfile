
FROM dhi.io/alpine-base:3.24-dev AS base
WORKDIR /app

FROM base AS downloader
ARG LIDARR_VERSION=3.1.6.5079
ADD --link https://github.com/Lidarr/Lidarr/releases/download/v${LIDARR_VERSION}/Lidarr.master.${LIDARR_VERSION}.linux-musl-core-x64.tar.gz lidarr.tar.gz
RUN tar -xzf lidarr.tar.gz && \
  mv Lidarr bin && \
  rm -rf "bin/Lidarr.Update" && rm lidarr.tar.gz
COPY <<EOF "package_info"
PackageVersion=${LIDARR_VERSION}
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
EXPOSE 8686
WORKDIR /app/bin

ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/bin/Lidarr", "--nobrowser", "--data=/config" ]
