FROM dhi.io/alpine-base:3.22-dev AS base
WORKDIR /app

FROM dhi.io/dotnet:10-sdk-alpine3.22 AS be
ADD --link https://github.com/Sonarr/Sonarr.git#v5-develop /app
WORKDIR /app
RUN dotnet msbuild -restore src/Sonarr.sln -p:SelfContained=true -p:Configuration=Release -p:Platform=Posix -p:RuntimeIdentifiers=linux-musl-x64 -t:PublishAllRids -p:IlcInstructionSet=x86-64-v3
# RUN ls _output/net10.0/linux-musl-x64/ && false

FROM dhi.io/node:24-alpine3.22-dev AS fe
ADD --link https://github.com/Sonarr/Sonarr.git#v5-develop /app
WORKDIR /app
RUN yarn install
RUN yarn build --env production

# image for running
FROM base
RUN apk add --no-cache libintl sqlite-libs icu-libs tini
COPY --link --from=be /app/_output/net10.0/linux-musl-x64/ /app/Sonarr
COPY --link --from=fe /app/_output/UI/ /app/Sonarr/UI/
EXPOSE 8989

CMD [ "tini", "--", "/app/Sonarr/Sonarr", "--nobrowser", "--data=/config" ]