ARG ADGUARDHOME_COMMIT=81fcaf3a6eff96024c3f12cccdfe995819c87ae1

FROM dhi.io/node:24-alpine3.22-dev AS ui
ENV SOURCE_DATE_EPOCH=0
ARG ADGUARDHOME_COMMIT
ADD --link --keep-git-dir=true https://github.com/AdguardTeam/AdGuardHome.git#${ADGUARDHOME_COMMIT} /app
WORKDIR /app/client
RUN --mount=type=cache,target=/root/.npm \
  npm install
RUN npm run build-prod

FROM dhi.io/golang:1-alpine3.23-dev AS builder
ENV SOURCE_DATE_EPOCH=0
ARG ADGUARDHOME_COMMIT
ADD --link --keep-git-dir=true https://github.com/AdguardTeam/AdGuardHome.git#${ADGUARDHOME_COMMIT} /app
WORKDIR /app
COPY --link --from=ui /app/build build
ENV CHANNEL=edge
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    sh -euo pipefail <<EOF
git fetch --tags
version_pkg='github.com/AdguardTeam/AdGuardHome/internal/version'
version="\$(sh ./scripts/make/version.sh)"
ldflags="-s -w"
ldflags="\${ldflags} -X \${version_pkg}.version=\${version}"
ldflags="\${ldflags} -X \${version_pkg}.channel=${CHANNEL}"
ldflags="\${ldflags} -X \${version_pkg}.committime=${SOURCE_DATE_EPOCH}"
CGO_ENABLED=0 GOAMD64=v3 go build -ldflags "\${ldflags}" --trimpath -o AdGuardHome .
EOF

# ------------------
# image for running

FROM scratch
COPY --link --from=dhi.io/golang:1-alpine3.23-dev /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --link --from=builder /app/AdGuardHome /usr/bin/AdGuardHome
VOLUME [ "/opt/adguardhome/conf/", "/opt/adguardhome/work/" ]
ENTRYPOINT [ "/usr/bin/AdGuardHome" ]
CMD [ "--no-check-update", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work/" ]

