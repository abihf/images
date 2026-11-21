# AGENT.md: Building secure images on dhi.io

Rules for adding or changing images in this repo. Base images come from Docker Hardened Images (`dhi.io`). Look at an existing image (`sonarr`, `restic`, `suwayomi`) before writing a new one.

## Layout

```
<app>/
  Dockerfile   # the image
  update.sh    # bumps the Dockerfile ARGs to the latest upstream version
utils.sh       # helpers: get_latest_github_release_tag, get_latest_github_commit, update_docker_arg
update-all.sh  # runs every */update.sh
```

- Published to `ghcr.io/abihf/images/<app>` (`:latest` and `:<git sha>`), `linux/amd64` only.
- CI (`.github/workflows/build.yml`) builds only the directories whose `Dockerfile` changed. It also generates an SBOM and a provenance attestation.
- `scan.yml` runs Trivy weekly. Findings are CRITICAL and HIGH.
- Add a row to the README table for each new image.

## Choosing a base

- Use `dhi.io/...` for every stage. The exception is `ubuntu-dev`, which is a dev image and pins `ubuntu` by digest.
- **Runtime stage:** use the smallest DHI image that already contains what the app needs, for example `dhi.io/eclipse-temurin:27-alpine` for a JAR. Use `dhi.io/alpine-base:<ver>-dev` only if you must `apk add` something.
- **Build stages:** use `-dev` or `-sdk` variants, for example `golang:*-alpine*-dev`, `dotnet:*-sdk-alpine*` and `node:*-alpine*-dev`. Never ship them as the final stage.
- Pin the exact tag (`3.24`, `1.26-alpine3.24-dev`). Never use `latest`. For non-DHI bases, also pin `@sha256:` and write an `update.sh` that refreshes it.
- Check that the tag exists first: `docker buildx imagetools inspect dhi.io/<name>:<tag>`. This needs `docker login dhi.io`.

## Multi-stage pattern

1. Fetch the source in its own stage and build in a `-dev` or `-sdk` stage.
2. Copy only the artifacts into the final stage: `COPY --link --chmod=0755 --from=builder /app/bin /usr/bin/app`.
3. Set `ENV SOURCE_DATE_EPOCH=0` in build stages so builds are reproducible.
4. Use cache mounts for package managers, so caches stay out of layers:
   `RUN --mount=type=cache,target=/go/pkg/mod ...`
5. Make the binary small and reproducible, for example Go `-ldflags "-s -w" --trimpath`. Target `GOAMD64=v3`, since only amd64 is built.
6. Use `ADD --link` and `COPY --link` so layers stay independent and cache well.

## Runtime hardening

- **Non-root:** DHI images already define a `nonroot` user. Don't switch back to root in the final stage. Files copied in must be readable and, where needed, executable by that user. Use `--chmod=0755` or `--chmod=0644` on `ADD` and `COPY`. Most past permission bugs (e.g. `suwayomi`) came from missing `--chmod`.
- **Packages:** install the minimum, with `apk add --no-cache`. Don't add shells, compilers, curl, wget or sudo to the final stage.
- **Writable paths:** declare data paths with `VOLUME` or document them. The app must not need to write anywhere else. Set `HOME` or app data paths explicitly if the app writes to home.
- **PID 1:** use `tini` as the entrypoint for apps that spawn children: `ENTRYPOINT ["tini", "--"]`.
- **Telemetry:** disable runtime telemetry and diagnostics, for example `COMPlus_EnableDiagnostics=0`.
- **Secrets:** never put them in `ARG`, `ENV` or `COPY`. Build args are visible in image history. Pass runtime secrets as environment variables or files at deploy time.
- **Ports:** only `EXPOSE` the ports the app actually listens on.
- Prefer the exec form of `CMD` and `ENTRYPOINT`.

## Supply chain

- Fetch sources at a pinned commit or tag: `ADD --link https://github.com/org/repo.git#${COMMIT} /app`. Release binaries go through `ARG VERSION=x.y.z`.
- No `curl | sh`, no unpinned downloads, and no `latest`.
- Every version, commit and digest is an `ARG` with a default value on its own line, in the form `ARG NAME=value`, so `update_docker_arg` can rewrite it.
- Redeclare an `ARG` inside each stage that uses it.

## update.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../utils.sh"

VERSION="$(get_latest_github_release_tag "Org/Repo" | sed 's/^v//')"
update_docker_arg "APP_VERSION" "$VERSION"
echo "Updated app to $VERSION"
```

- `update.sh` must be idempotent and must only touch `ARG` lines.
- `update-all.sh` picks up every `*/update.sh` automatically.
- Commit messages are `<app>: <change>`, for example `suwayomi: fix jar permissions`.

## Minimal example

```dockerfile
FROM dhi.io/golang:1.26-alpine3.24-dev AS builder
ENV SOURCE_DATE_EPOCH=0
ARG APP_VERSION=1.2.3
ADD --link https://github.com/org/app.git#v${APP_VERSION} /app
WORKDIR /app
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOAMD64=v3 go build -ldflags "-s -w" -trimpath -o app ./cmd/app

FROM dhi.io/alpine-base:3.24-dev
RUN apk add --no-cache tini
COPY --link --chmod=0755 --from=builder /app/app /usr/bin/app
EXPOSE 8080
VOLUME ["/config"]
ENTRYPOINT ["tini", "--"]
CMD ["app", "--config", "/config"]
```

## Verification checklist

Run these before committing:

1. `docker build ./<app>` succeeds.
2. The container runs as non-root: `docker run --rm --entrypoint id <image>`.
3. The app starts and can write to its volume paths when run as the intended user.
4. `trivy image <image>` shows no new CRITICAL or HIGH findings. If a finding is unfixable, note why in the PR.
5. `docker images` shows a size in line with similar images here. If it is much larger, something build-only leaked into the final stage.
6. `bash <app>/update.sh` runs cleanly and leaves the `Dockerfile` unchanged apart from `ARG` values.
