ARG SONARR_COMMIT=fdda9abcbbce7de7e1c213dd7e524201fa53f319
ARG SONARR_REVISION=0
ARG SONARR_BRANCH=v5-develop

FROM dhi.io/alpine-base:3.22-dev AS base
WORKDIR /app

FROM base AS project
ARG SONARR_COMMIT
ADD --link https://github.com/Sonarr/Sonarr.git#${SONARR_COMMIT} /app
RUN find /app -type f ! -name "*.csproj" ! -name "*.sln" ! -name "*.props" ! -name "*.targets" -delete

FROM dhi.io/dotnet:10-sdk-alpine3.22 AS be
ENV SOURCE_DATE_EPOCH=0
WORKDIR /app

# Restore dependencies
COPY --link --from=project /app .
RUN --mount=type=cache,target=/root/.nuget/packages \
  dotnet restore src/Sonarr.sln -r linux-musl-x64

# Copy full source
ARG SONARR_COMMIT
ADD --link https://github.com/Sonarr/Sonarr.git#${SONARR_COMMIT} /app

ARG SONARR_REVISION
ARG SONARR_BRANCH
RUN sed -i -e "s/<AssemblyVersion>[0-9.*]\+<\/AssemblyVersion>/<AssemblyVersion>5.0.0.${SONARR_REVISION}<\/AssemblyVersion>/;s/<AssemblyConfiguration>[\$()A-Za-z-]\+<\/AssemblyConfiguration>/<AssemblyConfiguration>${SONARR_BRANCH}<\/AssemblyConfiguration>/;" src/Directory.Build.props

# Build and publish
ARG TARGET_FRAMEWORK=net10.0
ARG RUNTIME_IDENTIFIER=linux-musl-x64
RUN --mount=type=cache,target=/root/.nuget/packages \
  --mount=type=cache,target=/app/obj \
  --mount=type=cache,target=/app/_output \
  dotnet msbuild -m -v:minimal src/Sonarr.sln \
    -p:SelfContained=true -p:Configuration=Release -p:Platform=Posix \
    -p:RuntimeIdentifier=${RUNTIME_IDENTIFIER} -p:TargetFramework=${TARGET_FRAMEWORK} -t:Publish \
    -p:IlcInstructionSet=x86-64-v3 && \
  mv /app/_output/${TARGET_FRAMEWORK}/${RUNTIME_IDENTIFIER}/publish bin &&
  chmod 0755 /app/bin/ffprobe

# image for frontend build
FROM dhi.io/node:24-alpine3.23-dev AS fe
ENV SOURCE_DATE_EPOCH=0
ARG SONARR_COMMIT
ADD --link https://github.com/Sonarr/Sonarr.git#${SONARR_COMMIT} /app
WORKDIR /app
RUN yarn install
RUN yarn build --env production

# ------------------------
# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=be /app/bin /app/bin
COPY --link --from=fe /app/_output/UI/ /app/bin/UI/
EXPOSE 8989
ENV COMPlus_EnableDiagnostics=0

ARG SONARR_REVISION
ARG SONARR_BRANCH
COPY <<EOF "/app/package_info"
PackageVersion=5.0.0.${SONARR_REVISION}
PackageAuthor=[abihf](https://github.com/abihf/images)
UpdateMethod=Docker
Branch=${SONARR_BRANCH}
EOF

VOLUME ["/config"]
WORKDIR /app/bin
ENTRYPOINT [ "tini", "--" ]
CMD [ "/app/bin/Sonarr", "--nobrowser", "--data=/config" ]