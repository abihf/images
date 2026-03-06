FROM dhi.io/alpine-base:3.23-dev AS base
WORKDIR /app

FROM base AS downloader
ARG NAVIDROME_VERSION=0.60.3
ADD --link https://github.com/navidrome/navidrome/releases/download/v${NAVIDROME_VERSION}/navidrome_${NAVIDROME_VERSION}_Linux_x86_64.tar.gz navidrome.tar.gz
RUN tar -xzf navidrome.tar.gz && \
  rm navidrome.tar.gz && \
  chmod 0755 /app/navidrome
COPY <<EOF "package_info"
PackageVersion=${NAVIDROME_VERSION}
PackageAuthor=[abihf](https://github.com/abihf/images)
UpdateMethod=Docker
EOF

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache ca-certificates tini
COPY --link --from=downloader /app /app
ENV ND_DATAFOLDER=/config \
    ND_MUSICFOLDER=/music
VOLUME ["/config", "/music"]
EXPOSE 4533
WORKDIR /app
ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/navidrome" ]
