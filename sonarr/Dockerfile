ARG SONARR_COMMIT=107e474f9c4c3be14db03f95ffaa22c46246a191
ARG SONARR_REVISION=0
ARG SONARR_BRANCH=v5-develop

FROM dhi.io/alpine-base:3.22-dev AS base
WORKDIR /app

FROM dhi.io/dotnet:10-sdk-alpine3.22 AS be
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache git
ARG SONARR_COMMIT
ADD --link https://github.com/Sonarr/Sonarr.git#${SONARR_COMMIT} /app
WORKDIR /app
ARG SONARR_REVISION
ARG SONARR_BRANCH
RUN sed -i -e "s/<AssemblyVersion>[0-9.*]\+<\/AssemblyVersion>/<AssemblyVersion>5.0.0.${SONARR_REVISION}<\/AssemblyVersion>/;s/<AssemblyConfiguration>[\$()A-Za-z-]\+<\/AssemblyConfiguration>/<AssemblyConfiguration>${SONARR_BRANCH}<\/AssemblyConfiguration>/;" src/Directory.Build.props
RUN --mount=type=cache,target=/root/.nuget/packages \
  --mount=type=cache,target=/app/obj \
  dotnet msbuild -restore src/Sonarr.sln -p:SelfContained=true -p:Configuration=Release -p:Platform=Posix -p:RuntimeIdentifiers=linux-musl-x64 -t:PublishAllRids -p:IlcInstructionSet=x86-64-v3
RUN chmod 0755 /app/_output/net10.0/linux-musl-x64/publish/ffprobe

FROM dhi.io/node:24-alpine3.22-dev AS fe
ENV SOURCE_DATE_EPOCH=0
ARG SONARR_COMMIT
ADD --link https://github.com/Sonarr/Sonarr.git#${SONARR_COMMIT} /app
WORKDIR /app
RUN yarn install
RUN yarn build --env production

# image for running
FROM base
ENV SOURCE_DATE_EPOCH=0
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=be /app/_output/net10.0/linux-musl-x64/publish /app/bin
COPY --link --from=fe /app/_output/UI/ /app/bin/UI/
EXPOSE 8989
ENV COMPlus_EnableDiagnostics=0 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

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