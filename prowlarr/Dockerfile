ARG PROWLARR_VERSION=2.3.2.5245

FROM dhi.io/alpine-base:3.23-dev AS base

FROM base AS downloader
WORKDIR /app
ARG PROWLARR_VERSION
ADD --link https://github.com/Prowlarr/Prowlarr/releases/download/v${PROWLARR_VERSION}/Prowlarr.develop.${PROWLARR_VERSION}.linux-musl-core-x64.tar.gz prowlarr.tar.gz
RUN tar -xzf prowlarr.tar.gz && \
  mv Prowlarr bin && \
  rm -rf "bin/Prowlarr.Update"
COPY <<EOF "package_info"
PackageVersion=${PROWLARR_VERSION}
PackageAuthor=[abihf](https://github.com/abihf/images)
UpdateMethod=Docker
Branch=develop
EOF

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=downloader /app /app

ENV COMPlus_EnableDiagnostics=0

WORKDIR /app/bin
VOLUME ["/config"]
EXPOSE 9696

ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/bin/Prowlarr", "--nobrowser", "--data=/config" ]
