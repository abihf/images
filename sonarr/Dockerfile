FROM dhi.io/alpine-base:3.23-dev AS base
WORKDIR /app

FROM base AS downloader
ARG SONARR_VERSION=4.0.16.2946
ADD --link https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.develop.${SONARR_VERSION}.linux-musl-x64.tar.gz sonarr.tar.gz
RUN tar -xzf sonarr.tar.gz && \
  mv Sonarr bin && \
  rm -rf "bin/Sonarr.Update" && rm sonarr.tar.gz
COPY <<EOF "package_info"
PackageVersion=${SONARR_VERSION}
PackageAuthor=[abihf](https://github.com/abihf/images)
UpdateMethod=Docker
Branch=develop
EOF

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=downloader /app/ /app/
ENV COMPlus_EnableDiagnostics=0
EXPOSE 8989

VOLUME ["/config"]
WORKDIR /app/bin
ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/bin/Sonarr", "--nobrowser", "--data=/config" ]