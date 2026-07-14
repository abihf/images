FROM dhi.io/golang:1.26-alpine3.24-dev AS builder
ENV SOURCE_DATE_EPOCH=0
ARG RESTIC_VERSION=0.19.1
ADD --link https://github.com/restic/restic.git#v${RESTIC_VERSION} /app
WORKDIR /app
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    sh -euo pipefail <<EOF
  GOAMD64=v3 go build -ldflags "-s -w" --trimpath -o restic ./cmd/restic
EOF


FROM dhi.io/alpine-base:3.24-dev
RUN apk add --no-cache ripgrep
COPY --link --chmod=0755 --from=builder /app/restic /usr/bin/restic