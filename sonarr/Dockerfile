FROM dhi.io/alpine-base:3.22-dev AS base
WORKDIR /app

FROM base AS downloader
ARG SONARR_VERSION=4.0.16.2946
ADD --link https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.develop.${SONARR_VERSION}.linux-musl-x64.tar.gz sonarr.tar.gz
RUN tar -xf sonarr.tar.gz

# image for running
FROM base
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=downloader /app/Sonarr /app/Sonarr

CMD [ "tini", "--", "/app/Sonarr/Sonarr", "--nobrowser", "--data=/config" ]