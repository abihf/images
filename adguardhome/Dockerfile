
FROM scratch AS source
ADD --link --keep-git-dir=true https://github.com/AdguardTeam/AdGuardHome.git AdGuardHome


FROM --platform=$BUILDPLATFORM node:24-alpine AS node-builder
WORKDIR /app/AdGuardHome/client
COPY --link --from=source /AdGuardHome/client/package* ./
RUN npm ci

COPY --link --from=source /AdGuardHome/client/ ./
COPY --link --from=source /AdGuardHome/.twosky.json /app/AdGuardHome/

RUN --mount=type=cache,target=/root/.npm \
  npm run build-prod

# ---------------------------------

FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS go-builder
WORKDIR /app/AdGuardHome

RUN apk add --no-cache git make

COPY --link --from=source /AdGuardHome/go.mod /AdGuardHome/go.sum ./
RUN --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  go mod download

COPY --link --from=source /AdGuardHome/ /app/AdGuardHome/

ENV CHANNEL=development
RUN --mount=type=bind,from=node-builder,source=/app/AdGuardHome/build,target=/app/AdGuardHome/build \
  --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg/mod \
  GOAMD64=v3 make go-build


# image for running
FROM alpine:latest
RUN apk add --no-cache ca-certificates && \
  adduser \
    -D \
    -H \
    -s /sbin/nologin \
    -u 1000 \
    agUser

VOLUME /opt/adguardhome/conf
VOLUME /opt/adguardhome/work
EXPOSE 53/tcp 53/udp \
	67/udp \
	68/udp \
	80/tcp \
	443/tcp 443/udp \
	853/tcp 853/udp \
	3000/tcp 3000/udp \
	5443/tcp 5443/udp \
	6060/tcp

WORKDIR /opt/adguardhome/work
COPY --link --from=go-builder /app/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome
COPY --link --from=go-builder /app/AdGuardHome/LICENSE.txt /opt/adguardhome/
USER agUser

CMD [ "/opt/adguardhome/AdGuardHome", \
	"--no-check-update", \
	"-c", "/opt/adguardhome/conf/AdGuardHome.yaml", \
	"-w", "/opt/adguardhome/work" \
]