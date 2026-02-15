FROM dhi.io/node:20-alpine3.23-dev AS builder
WORKDIR /app
ARG OVERSEERR_COMMIT=b0a15d3809554610cd835b3e2474d5c6663cb8a9
ADD --link https://github.com/sct/overseerr.git#${OVERSEERR_COMMIT} /app
RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile

RUN --mount=type=cache,target=/app/.next/cache yarn build

RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile --production

# ------------------
# image for running

FROM dhi.io/node:20-alpine3.23
WORKDIR /app
COPY --link --from=builder /app/package.json /app/next.config.js /app/overseerr-api.yml ./
COPY --link --from=builder /app/node_modules ./node_modules
COPY --link --from=builder /app/public ./public
COPY --link --from=builder /app/dist ./dist
COPY --link --from=builder /app/.next ./.next
VOLUME [ "/app/config/" ]
ENV NODE_ENV=production
CMD [ "node", "./dist/index.js" ]
