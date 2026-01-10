
FROM dhi.io/alpine-base:3.23-dev AS base
WORKDIR /app

FROM base AS downloader
ARG PROWLARR_VERSION=2.3.2.5245
ADD --link https://github.com/Prowlarr/Prowlarr/releases/download/v${PROWLARR_VERSION}/Prowlarr.develop.${PROWLARR_VERSION}.linux-musl-core-x64.tar.gz prowlarr.tar.gz
RUN tar -xzf prowlarr.tar.gz && \
  rm -rf "Prowlarr/Prowlarr.Update" && \
  echo -e "PackageVersion=${PROWLARR_VERSION}\nPackageAuthor=[abihf](https://github.com/abihf/images)\nUpdateMethod=Docker\nBranch=develop" > "Prowlarr/package_info"

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=downloader /app/Prowlarr/ /app/Prowlarr/

VOLUME ["/config"]
EXPOSE 9696

ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/Prowlarr/Prowlarr", "--nobrowser", "--data=/config" ]
